import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../supabaseClient';
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
  CircularProgress,
  InputAdornment,
  IconButton,
  Link,
  Divider,
  Container,
} from '@mui/material';
import EmailIcon from '@mui/icons-material/Email';
import LockIcon from '@mui/icons-material/Lock';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import PersonIcon from '@mui/icons-material/Person';
import GoogleIcon from '@mui/icons-material/Google';

const containerVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.6, ease: 'easeOut' },
  },
};

const formVariants = {
  hidden: { opacity: 0, x: 100 },
  visible: {
    opacity: 1,
    x: 0,
    transition: { duration: 0.5, ease: 'easeOut' },
  },
  exit: {
    opacity: 0,
    x: -100,
    transition: { duration: 0.3 },
  },
};

const AuthPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  const [isSignUp, setIsSignUp] = useState(false);
  const [resetMode, setResetMode] = useState(false);
  const { signIn } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await signIn(email, password);
      navigate('/dashboard');
    } catch (err) {
      setError(err.message || 'Invalid credentials');
    } finally {
      setLoading(false);
    }
  };

  const handleSignUp = async (e) => {
    e.preventDefault();
    setError('');

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    setLoading(true);
    try {
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
      });

      if (signUpError) throw signUpError;

      if (data.user) {
        const { error: profileError } = await supabase.from('users').upsert(
          {
            id: data.user.id,
            username: username || email.split('@')[0],
            email: email,
            role: 'Admin',
          },
          { onConflict: 'id' }
        );

        if (profileError) console.warn('Profile error:', profileError);
        setSuccess('Account created! Check your email to confirm.');
        setTimeout(() => {
          setEmail('');
          setPassword('');
          setConfirmPassword('');
          setUsername('');
          setIsSignUp(false);
        }, 2000);
      }
    } catch (err) {
      setError(err.message || 'Sign up failed');
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordReset = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      if (error) throw error;
      setSuccess('Check your email for password reset link');
      setResetMode(false);
      setEmail('');
    } catch (err) {
      setError(err.message || 'Failed to send reset email');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #0C0C79 0%, #4B4BA3 100%)',
        p: 2,
      }}
    >
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <Card
          sx={{
            maxWidth: 480,
            width: '100%',
            p: 4,
            boxShadow: '0 20px 60px rgba(0,0,0,0.3)',
          }}
        >
          <CardContent>
            <motion.div
              variants={containerVariants}
              initial="hidden"
              animate="visible"
            >
              <Box textAlign="center" mb={4}>
                <Typography
                  variant="h3"
                  sx={{
                    fontWeight: 800,
                    background: 'linear-gradient(135deg, #0C0C79 0%, #FF751F 100%)',
                    WebkitBackgroundClip: 'text',
                    WebkitTextFillColor: 'transparent',
                    mb: 1,
                  }}
                >
                  Kindora
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {resetMode
                    ? 'Reset Your Password'
                    : isSignUp
                    ? 'Create Admin Account'
                    : 'Admin Portal'}
                </Typography>
              </Box>

              {error && (
                <motion.div
                  initial={{ opacity: 0, y: -20 }}
                  animate={{ opacity: 1, y: 0 }}
                >
                  <Alert severity="error" sx={{ mb: 3 }}>
                    {error}
                  </Alert>
                </motion.div>
              )}

              {success && (
                <motion.div
                  initial={{ opacity: 0, y: -20 }}
                  animate={{ opacity: 1, y: 0 }}
                >
                  <Alert severity="success" sx={{ mb: 3 }}>
                    {success}
                  </Alert>
                </motion.div>
              )}
            </motion.div>

            <motion.form
              key={resetMode ? 'reset' : isSignUp ? 'signup' : 'login'}
              variants={formVariants}
              initial="hidden"
              animate="visible"
              exit="exit"
              onSubmit={
                resetMode ? handlePasswordReset : isSignUp ? handleSignUp : handleLogin
              }
            >
              {isSignUp && (
                <TextField
                  fullWidth
                  label="Username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                  sx={{ mb: 2.5 }}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <PersonIcon color="action" />
                      </InputAdornment>
                    ),
                  }}
                />
              )}

              <TextField
                fullWidth
                label="Email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                sx={{ mb: 2.5 }}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <EmailIcon color="action" />
                    </InputAdornment>
                  ),
                }}
              />

              {!resetMode && (
                <TextField
                  fullWidth
                  label="Password"
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  sx={{ mb: isSignUp ? 2.5 : 3 }}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <LockIcon color="action" />
                      </InputAdornment>
                    ),
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton onClick={() => setShowPassword(!showPassword)} edge="end">
                          {showPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />
              )}

              {isSignUp && (
                <TextField
                  fullWidth
                  label="Confirm Password"
                  type={showConfirmPassword ? 'text' : 'password'}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                  sx={{ mb: 3 }}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <LockIcon color="action" />
                      </InputAdornment>
                    ),
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton onClick={() => setShowConfirmPassword(!showConfirmPassword)} edge="end">
                          {showConfirmPassword ? <VisibilityOffIcon /> : <VisibilityIcon />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />
              )}

              <Button
                type="submit"
                fullWidth
                variant="contained"
                size="large"
                disabled={loading}
                sx={{
                  py: 1.5,
                  fontSize: '1rem',
                  background: 'linear-gradient(135deg, #0C0C79 0%, #FF751F 100%)',
                  transition: 'all 0.3s ease',
                  '&:hover:not(:disabled)': {
                    transform: 'translateY(-2px)',
                  },
                }}
              >
                {loading ? (
                  <CircularProgress size={24} color="inherit" />
                ) : resetMode ? (
                  'Send Reset Link'
                ) : isSignUp ? (
                  'Create Account'
                ) : (
                  'Sign In'
                )}
              </Button>
            </motion.form>

            {!resetMode && (
              <>
                <Divider sx={{ my: 3 }}>Or</Divider>

                <Button
                  fullWidth
                  variant="outlined"
                  size="large"
                  startIcon={<GoogleIcon />}
                  sx={{ mb: 3, textTransform: 'none' }}
                >
                  Sign in with Google
                </Button>

                <Box textAlign="center" mt={3}>
                  <Typography variant="body2" color="text.secondary">
                    {isSignUp ? 'Already have an account?' : "Don't have an account?"}{' '}
                    <Link
                      component="button"
                      variant="body2"
                      onClick={() => {
                        setIsSignUp(!isSignUp);
                        setError('');
                        setSuccess('');
                      }}
                      sx={{ fontWeight: 600, cursor: 'pointer' }}
                    >
                      {isSignUp ? 'Sign In' : 'Sign Up'}
                    </Link>
                  </Typography>
                </Box>

                {!isSignUp && (
                  <Box textAlign="center" mt={2}>
                    <Link
                      component="button"
                      variant="body2"
                      onClick={() => setResetMode(true)}
                      sx={{ textDecoration: 'none', cursor: 'pointer' }}
                    >
                      Forgot password?
                    </Link>
                  </Box>
                )}
              </>
            )}

            {resetMode && (
              <Box textAlign="center" mt={3}>
                <Link
                  component="button"
                  variant="body2"
                  onClick={() => {
                    setResetMode(false);
                    setError('');
                    setSuccess('');
                    setEmail('');
                  }}
                  sx={{ textDecoration: 'none', cursor: 'pointer' }}
                >
                  Back to Sign In
                </Link>
              </Box>
            )}
          </CardContent>
        </Card>
      </motion.div>
    </Box>
  );
};

export default AuthPage;
