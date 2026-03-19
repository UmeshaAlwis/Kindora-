import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { supabase } from '../supabaseClient';

const AuthContext = createContext(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};

// Utility to handle IndexedDB lock errors gracefully
const handleStorageError = (err) => {
  if (err?.message?.includes('Lock broken') || err?.name === 'AbortError') {
    console.warn('Storage lock error (non-critical):', err.message);
    return true;
  }
  return false;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [profileError, setProfileError] = useState(null);

  const fetchProfile = useCallback(async (userId) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        // Handle storage lock errors silently
        if (handleStorageError(error)) {
          console.info('Retrying profile fetch after storage error...');
          // Retry after short delay
          await new Promise(resolve => setTimeout(resolve, 100));
          return fetchProfile(userId);
        }

        console.warn('Profile fetch error:', error.message);
        setProfileError(error.message);

        // Profile doesn't exist — auto-create with admin role
        if (error.code === 'PGRST116') {
          try {
            const { data: session } = await supabase.auth.getSession();
            const email = session?.session?.user?.email || '';
            const { data: newProfile, error: insertErr } = await supabase
              .from('profiles')
              .insert([{ id: userId, name: email.split('@')[0], email, role: 'admin' }])
              .select()
              .single();
            if (!insertErr && newProfile) {
              setProfile(newProfile);
              setProfileError(null);
              return newProfile;
            }
            console.warn('Profile auto-create error:', insertErr?.message);
          } catch (createErr) {
            if (!handleStorageError(createErr)) {
              console.error('Profile creation exception:', createErr);
            }
          }
        }
        return null;
      }

      setProfile(data);
      setProfileError(null);
      return data;
    } catch (err) {
      if (!handleStorageError(err)) {
        console.error('Profile fetch exception:', err);
        setProfileError(err.message);
      }
      return null;
    }
  }, []);

  useEffect(() => {
    let mounted = true;
    let retryCount = 0;
    const maxRetries = 3;

    const getSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!mounted) return;
        if (session?.user) {
          setUser(session.user);
          await fetchProfile(session.user.id);
        }
      } catch (err) {
        if (handleStorageError(err) && retryCount < maxRetries) {
          retryCount++;
          console.info(`Retrying session fetch (${retryCount}/${maxRetries})...`);
          await new Promise(resolve => setTimeout(resolve, 100 * retryCount));
          await getSession();
        } else if (!handleStorageError(err)) {
          console.error('Session error:', err);
        }
      } finally {
        if (mounted) setLoading(false);
      }
    };

    getSession();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;
        try {
          if (session?.user) {
            setUser(session.user);
            await fetchProfile(session.user.id);
          } else {
            setUser(null);
            setProfile(null);
          }
        } catch (err) {
          if (!handleStorageError(err)) {
            console.error('Auth state change error:', err);
          }
        }
        setLoading(false);
      }
    );

    return () => {
      mounted = false;
      subscription?.unsubscribe().catch(err => {
        if (!handleStorageError(err)) {
          console.error('Unsubscribe error:', err);
        }
      });
    };
  }, [fetchProfile]);

  const signIn = async (email, password) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    return data;
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    setUser(null);
    setProfile(null);
  };

  const isAdmin = profile?.role === 'admin';

  return (
    <AuthContext.Provider value={{ user, profile, loading, isAdmin, profileError, signIn, signOut, fetchProfile }}>
      {children}
    </AuthContext.Provider>
  );
};

export default AuthContext;
