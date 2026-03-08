import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';

const AuthContext = createContext(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [profileError, setProfileError] = useState(null);

  const fetchProfile = async (userId) => {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        console.warn('Profile fetch error:', error.message);
        setProfileError(error.message);

        // Profile doesn't exist — auto-create with admin role
        if (error.code === 'PGRST116') {
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
        }
        return null;
      }

      setProfile(data);
      setProfileError(null);
      return data;
    } catch (err) {
      console.error('Profile fetch exception:', err);
      setProfileError(err.message);
      return null;
    }
  };

  useEffect(() => {
    let mounted = true;

    const getSession = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!mounted) return;
        if (session?.user) {
          setUser(session.user);
          await fetchProfile(session.user.id);
        }
      } catch (err) {
        console.error('Session error:', err);
      } finally {
        if (mounted) setLoading(false);
      }
    };

    getSession();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;
        if (session?.user) {
          setUser(session.user);
          await fetchProfile(session.user.id);
        } else {
          setUser(null);
          setProfile(null);
        }
        setLoading(false);
      }
    );

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

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
