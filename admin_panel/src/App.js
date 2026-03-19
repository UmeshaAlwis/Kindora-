import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import { Toaster } from 'react-hot-toast';
import { getTheme } from './theme';
import { AuthProvider } from './contexts/AuthContext';
import { ThemeContextProvider, useThemeMode } from './contexts/ThemeContext';
import ProtectedRoute from './components/ProtectedRoute';
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

function AppContent() {
  const [showSplash, setShowSplash] = useState(true);
  const { isDarkMode } = useThemeMode();

  useEffect(() => {
    const timer = setTimeout(() => {
      setShowSplash(false);
    }, 3000);

    return () => clearTimeout(timer);
  }, []);

  if (showSplash) {
    return <SplashScreen onComplete={() => setShowSplash(false)} />;
  }

  return (
    <ThemeProvider theme={getTheme(isDarkMode)}>
      <CssBaseline />
      <Toaster position="top-right" />
      <AuthProvider>
        <BrowserRouter>
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
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

function App() {
  return (
    <ThemeContextProvider>
      <AppContent />
    </ThemeContextProvider>
  );
}

export default App;
