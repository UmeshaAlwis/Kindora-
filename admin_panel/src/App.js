import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline, Box, CircularProgress, Typography } from '@mui/material';
import { Toaster } from 'react-hot-toast';
import { getTheme } from './theme';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { ThemeContextProvider, useThemeMode } from './contexts/ThemeContext';
import ProtectedRoute from './components/ProtectedRoute';
import ErrorBoundary from './components/ErrorBoundary';
import Layout from './components/Layout';
import SplashScreen from './components/SplashScreen';
import AuthPage from './pages/AuthPage';
import Dashboard from './pages/Dashboard';
import Campaigns from './pages/Campaigns';
import FeedApprovals from './pages/FeedApprovals';
import Merchandise from './pages/Merchandise';
import Alerts from './pages/Alerts';
import UserProfile from './pages/UserProfile';

// Wrapper component for protected routes with layout
const ProtectedLayoutRoute = ({ children }) => (
  <ProtectedRoute>
    <Layout>{children}</Layout>
  </ProtectedRoute>
);

// Main routing component that uses auth context
function AppRoutes() {
  const { loading, user } = useAuth();
  console.log('AppRoutes render - loading:', loading, 'user:', user?.email);

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
        <Typography color="text.secondary">Initializing...</Typography>
      </Box>
    );
  }

  return (
    <Routes>
      <Route path="/login" element={<AuthPage />} />
      <Route path="/auth" element={<AuthPage />} />
      <Route
        path="/dashboard"
        element={
          <ProtectedLayoutRoute>
            <Dashboard />
          </ProtectedLayoutRoute>
        }
      />
      <Route
        path="/campaigns"
        element={
          <ProtectedLayoutRoute>
            <Campaigns />
          </ProtectedLayoutRoute>
        }
      />
      <Route
        path="/feed-approvals"
        element={
          <ProtectedLayoutRoute>
            <FeedApprovals />
          </ProtectedLayoutRoute>
        }
      />
      <Route
        path="/merchandise"
        element={
          <ProtectedLayoutRoute>
            <Merchandise />
          </ProtectedLayoutRoute>
        }
      />
      <Route
        path="/alerts"
        element={
          <ProtectedLayoutRoute>
            <Alerts />
          </ProtectedLayoutRoute>
        }
      />
      <Route
        path="/profile"
        element={
          <ProtectedLayoutRoute>
            <UserProfile />
          </ProtectedLayoutRoute>
        }
      />
      <Route path="/" element={user ? <Navigate to="/dashboard" replace /> : <Navigate to="/login" replace />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

function AppContent() {
  const [showSplash, setShowSplash] = useState(true);
  const { isDarkMode } = useThemeMode();

  useEffect(() => {
    const timer = setTimeout(() => {
      console.log('Hiding splash screen');
      setShowSplash(false);
    }, 3000);

    return () => clearTimeout(timer);
  }, []);

  console.log('AppContent render - showSplash:', showSplash);

  if (showSplash) {
    return <SplashScreen onComplete={() => {
      console.log('SplashScreen onComplete called');
      setShowSplash(false);
    }} />;
  }

  return (
    <ThemeProvider theme={getTheme(isDarkMode)}>
      <CssBaseline />
      <Toaster position="top-right" />
      <BrowserRouter>
        <AuthProvider>
          <AppRoutes />
        </AuthProvider>
      </BrowserRouter>
    </ThemeProvider>
  );
}

function App() {
  return (
    <ErrorBoundary>
      <ThemeContextProvider>
        <AppContent />
      </ThemeContextProvider>
    </ErrorBoundary>
  );
}

export default App;
