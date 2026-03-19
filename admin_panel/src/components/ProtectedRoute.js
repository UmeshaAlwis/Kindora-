import React, { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../supabaseClient';
import { Box, CircularProgress, Typography, Button, Alert } from '@mui/material';

const ProtectedRoute = ({ children }) => {
  const { user, profile, loading, isAdmin, profileError, signOut, fetchProfile } = useAuth();
  const [promoting, setPromoting] = useState(false);
  const [promoMsg, setPromoMsg] = useState('');

  console.log('ProtectedRoute render - loading:', loading, 'user:', user?.email, 'profile:', profile?.role, 'isAdmin:', isAdmin);

  if (loading) {
    return (
      <Box
        display="flex"
        flexDirection="column"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
        gap={2}
      >
        <CircularProgress size={48} />
        <Typography color="text.secondary">Loading...</Typography>
      </Box>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // Profile couldn't be loaded (RLS blocking, no row, etc.) OR profile exists but not admin
  if (!profile || (profile && !isAdmin)) {
    const handlePromote = async () => {
      setPromoting(true);
      setPromoMsg('');
      try {
        // Try upsert first (handles both create and update)
        const email = user.email || '';
        const { error } = await supabase
          .from('profiles')
          .upsert(
            { id: user.id, name: email.split('@')[0], email, role: 'admin' },
            { onConflict: 'id' }
          );
        
        if (error) {
          // Fallback: try just updating
          const { error: updateErr } = await supabase
            .from('profiles')
            .update({ role: 'admin' })
            .eq('id', user.id);
          if (updateErr) throw updateErr;
        }

        setPromoMsg('Role updated to admin! Reloading...');
        setTimeout(() => window.location.reload(), 1500);
      } catch (err) {
        setPromoMsg('Failed: ' + err.message + '. You may need to disable RLS on the profiles table in Supabase, or manually set your role to admin in the Supabase dashboard.');
      } finally {
        setPromoting(false);
      }
    };

    return (
      <Box
        display="flex"
        flexDirection="column"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
        gap={2}
        p={3}
        textAlign="center"
      >
        <Typography variant="h5" color="error">
          {!profile ? 'Profile Not Found' : 'Access Denied'}
        </Typography>
        <Typography color="text.secondary" maxWidth={500}>
          {!profile
            ? `No profile found for your account (${user.email}). This usually means Row Level Security (RLS) is blocking access, or no profile row exists.`
            : `Your current role is: "${profile.role}". Only admin users can access this panel.`}
        </Typography>
        {profileError && (
          <Alert severity="warning" sx={{ maxWidth: 500 }}>
            Debug info: {profileError}
          </Alert>
        )}
        {promoMsg && (
          <Alert severity={promoMsg.includes('Failed') ? 'error' : 'success'} sx={{ maxWidth: 500 }}>
            {promoMsg}
          </Alert>
        )}
        <Typography variant="body2" color="text.secondary" maxWidth={500} mt={1}>
          Click below to create/update your profile as admin, or go to <strong>Supabase Dashboard → Table Editor → profiles</strong> and set your role to "admin" manually.
        </Typography>
        <Box display="flex" gap={2} mt={2} flexWrap="wrap" justifyContent="center">
          <Button
            variant="contained"
            onClick={handlePromote}
            disabled={promoting}
          >
            {promoting ? <CircularProgress size={20} color="inherit" /> : 'Set My Role to Admin'}
          </Button>
          <Button
            variant="outlined"
            onClick={() => fetchProfile(user.id)}
          >
            Retry Loading Profile
          </Button>
          <Button
            variant="outlined"
            color="error"
            onClick={async () => {
              await signOut();
              window.location.href = '/login';
            }}
          >
            Sign Out
          </Button>
        </Box>
      </Box>
    );
  }

  return children;
};

export default ProtectedRoute;
