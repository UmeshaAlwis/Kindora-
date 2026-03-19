import React, { useState, useEffect } from 'react';
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
  Avatar,
  Divider,
  Grid,
  Alert,
  CircularProgress,
  useTheme,
  useMediaQuery,
  Container,
} from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import SaveIcon from '@mui/icons-material/Save';
import CancelIcon from '@mui/icons-material/Cancel';
import { useThemeMode } from '../contexts/ThemeContext';

const UserProfile = () => {
  const { user } = useAuth();
  const { isDarkMode } = useThemeMode();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  
  const [isEditing, setIsEditing] = useState(false);
  const [loading, setLoading] = useState(false);
  const [profile, setProfile] = useState({
    fullName: '',
    phone: '',
    organization: '',
    bio: '',
  });
  const [editedProfile, setEditedProfile] = useState(profile);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    if (user) {
      // Load profile from metadata
      const newProfile = {
        fullName: user.user_metadata?.full_name || '',
        phone: user.user_metadata?.phone || '',
        organization: user.user_metadata?.organization || '',
        bio: user.user_metadata?.bio || '',
      };
      setProfile(newProfile);
      setEditedProfile(newProfile);
    }
  }, [user]);

  const handleEditChange = (field) => (e) => {
    setEditedProfile({ ...editedProfile, [field]: e.target.value });
  };

  const handleSaveProfile = async () => {
    try {
      setLoading(true);
      const { error } = await supabase.auth.updateUser({
        data: {
          full_name: editedProfile.fullName,
          phone: editedProfile.phone,
          organization: editedProfile.organization,
          bio: editedProfile.bio,
        },
      });

      if (error) throw error;
      setProfile(editedProfile);
      setSuccess('Profile updated successfully!');
      setIsEditing(false);
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      setError(err.message || 'Failed to update profile');
      setTimeout(() => setError(''), 3000);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    setEditedProfile(profile);
    setIsEditing(false);
  };

  const containerVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
  };

  return (
    <Container maxWidth="lg">
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <Box sx={{ marginTop: 2, marginBottom: 4 }}>
          <Typography
            variant="h4"
            sx={{
              fontWeight: 800,
              marginBottom: 1,
              color: theme.palette.text.primary,
            }}
          >
            User Profile
          </Typography>
          <Typography variant="body2" sx={{ color: theme.palette.text.secondary }}>
            Manage your account information and preferences
          </Typography>
        </Box>

        {success && (
          <Alert severity="success" sx={{ marginBottom: 3 }}>
            {success}
          </Alert>
        )}
        {error && (
          <Alert severity="error" sx={{ marginBottom: 3 }}>
            {error}
          </Alert>
        )}

        <Grid container spacing={3}>
          {/* Profile Avatar Section */}
          <Grid item xs={12} md={4}>
            <motion.div whileHover={{ scale: 1.02 }}>
              <Card
                sx={{
                  padding: 3,
                  textAlign: 'center',
                  background: `linear-gradient(135deg, ${theme.palette.primary.main}15 0%, ${theme.palette.secondary.main}15 100%)`,
                  border: `2px solid ${theme.palette.primary.main}30`,
                }}
              >
                <Avatar
                  sx={{
                    width: 120,
                    height: 120,
                    margin: '0 auto 20px',
                    background: `linear-gradient(135deg, ${theme.palette.primary.main}, ${theme.palette.secondary.main})`,
                    fontSize: 48,
                    fontWeight: 800,
                  }}
                >
                  {user?.email?.charAt(0).toUpperCase()}
                </Avatar>
                <Typography variant="h5" sx={{ fontWeight: 700, marginBottom: 1 }}>
                  {profile.fullName || 'Not Set'}
                </Typography>
                <Typography
                  variant="body2"
                  sx={{ color: theme.palette.text.secondary, marginBottom: 2 }}
                >
                  {user?.email}
                </Typography>
                <Divider sx={{ marginY: 2 }} />
                <Box sx={{ textAlign: 'left', marginTop: 2 }}>
                  <Typography variant="caption" sx={{ color: theme.palette.text.secondary }}>
                    Status
                  </Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600, color: theme.palette.success.main }}>
                    ✓ Verified
                  </Typography>
                </Box>
              </Card>
            </motion.div>
          </Grid>

          {/* Profile Details Section */}
          <Grid item xs={12} md={8}>
            <motion.div whileHover={{ scale: 1.01 }}>
              <Card
                sx={{
                  background: isDarkMode
                    ? 'rgba(255, 255, 255, 0.05)'
                    : 'rgba(0, 0, 0, 0.02)',
                  backdropFilter: 'blur(10px)',
                  border: `1px solid ${theme.palette.divider}`,
                }}
              >
                <CardContent sx={{ padding: 3 }}>
                  <Box
                    sx={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      marginBottom: 3,
                    }}
                  >
                    <Typography variant="h6" sx={{ fontWeight: 700 }}>
                      Profile Information
                    </Typography>
                    {!isEditing && (
                      <Button
                        startIcon={<EditIcon />}
                        onClick={() => setIsEditing(true)}
                        variant="outlined"
                        size="small"
                      >
                        Edit Profile
                      </Button>
                    )}
                  </Box>

                  <Grid container spacing={2}>
                    <Grid item xs={12}>
                      <TextField
                        fullWidth
                        label="Full Name"
                        value={isEditing ? editedProfile.fullName : profile.fullName}
                        onChange={handleEditChange('fullName')}
                        disabled={!isEditing || loading}
                        variant={isEditing ? 'outlined' : 'filled'}
                      />
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Phone"
                        value={isEditing ? editedProfile.phone : profile.phone}
                        onChange={handleEditChange('phone')}
                        disabled={!isEditing || loading}
                        variant={isEditing ? 'outlined' : 'filled'}
                      />
                    </Grid>

                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Organization"
                        value={isEditing ? editedProfile.organization : profile.organization}
                        onChange={handleEditChange('organization')}
                        disabled={!isEditing || loading}
                        variant={isEditing ? 'outlined' : 'filled'}
                      />
                    </Grid>

                    <Grid item xs={12}>
                      <TextField
                        fullWidth
                        label="Bio"
                        value={isEditing ? editedProfile.bio : profile.bio}
                        onChange={handleEditChange('bio')}
                        disabled={!isEditing || loading}
                        variant={isEditing ? 'outlined' : 'filled'}
                        multiline
                        rows={4}
                      />
                    </Grid>
                  </Grid>

                  {isEditing && (
                    <Box sx={{ display: 'flex', gap: 2, marginTop: 3, justifyContent: 'flex-end' }}>
                      <Button
                        startIcon={<CancelIcon />}
                        onClick={handleCancel}
                        variant="outlined"
                        disabled={loading}
                      >
                        Cancel
                      </Button>
                      <Button
                        startIcon={<SaveIcon />}
                        onClick={handleSaveProfile}
                        variant="contained"
                        fullWidth={isMobile}
                        disabled={loading}
                      >
                        {loading ? <CircularProgress size={20} /> : 'Save Changes'}
                      </Button>
                    </Box>
                  )}
                </CardContent>
              </Card>
            </motion.div>

            {/* Account Security Section */}
            <Card
              sx={{
                marginTop: 3,
                background: isDarkMode
                  ? 'rgba(255, 255, 255, 0.05)'
                  : 'rgba(0, 0, 0, 0.02)',
                backdropFilter: 'blur(10px)',
                border: `1px solid ${theme.palette.divider}`,
              }}
            >
              <CardContent sx={{ padding: 3 }}>
                <Typography variant="h6" sx={{ fontWeight: 700, marginBottom: 2 }}>
                  Account Security
                </Typography>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <Button
                      fullWidth
                      variant="outlined"
                      sx={{
                        padding: 1.5,
                        border: `2px solid ${theme.palette.warning.main}`,
                        color: theme.palette.warning.main,
                      }}
                    >
                      Change Password
                    </Button>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Button
                      fullWidth
                      variant="outlined"
                      sx={{
                        padding: 1.5,
                        border: `2px solid ${theme.palette.info.main}`,
                        color: theme.palette.info.main,
                      }}
                    >
                      Enable 2FA
                    </Button>
                  </Grid>
                </Grid>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </motion.div>
    </Container>
  );
};

export default UserProfile;
