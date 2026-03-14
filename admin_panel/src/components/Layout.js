import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  Typography,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  IconButton,
  Avatar,
  Menu,
  MenuItem,
  Divider,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  Campaign as CampaignIcon,
  Approval as ApprovalIcon,
  ShoppingBag as MerchandiseIcon,
  Message as MessageIcon,
  Menu as MenuIcon,
  Logout as LogoutIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material';
import { supabase } from '../supabaseClient';

const DRAWER_WIDTH = 280;

const menuItems = [
  { label: 'Dashboard', icon: DashboardIcon, path: '/dashboard' },
  { label: 'Campaigns', icon: CampaignIcon, path: '/campaigns' },
  { label: 'Approvals', icon: ApprovalIcon, path: '/approvals' },
  { label: 'Merchandise', icon: MerchandiseIcon, path: '/merchandise' },
  { label: 'Messages', icon: MessageIcon, path: '/messages' },
];

const Layout = ({ children }) => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [mobileOpen, setMobileOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState(null);
  const navigate = useNavigate();
  const location = useLocation();
  const { user, profile } = useAuth();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setAnchorEl(null);
    navigate('/login');
  };

  const isActive = (path) => location.pathname === path;

  const drawer = (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <Box sx={{ p: 2.5, background: 'linear-gradient(135deg, #0C0C79 0%, #1a1a9a 100%)' }}>
        <Typography variant="h6" fontWeight={800} color="white" sx={{ mb: 0.5 }}>
          KINDORA
        </Typography>
        <Typography variant="caption" color="rgba(255,255,255,0.7)">
          Admin Control
        </Typography>
      </Box>
      <Divider />
      <List sx={{ flex: 1, py: 2 }}>
        {menuItems.map((item) => {
          const Icon = item.icon;
          return (
            <ListItem key={item.path} disablePadding sx={{ mb: 0.5, px: 1 }}>
              <ListItemButton
                onClick={() => {
                  navigate(item.path);
                  setMobileOpen(false);
                }}
                sx={{
                  borderRadius: 2,
                  backgroundColor: isActive(item.path) ? 'rgba(12, 12, 121, 0.1)' : 'transparent',
                  borderLeft: isActive(item.path)
                    ? '4px solid #0C0C79'
                    : '4px solid transparent',
                  '&:hover': {
                    backgroundColor: 'rgba(12, 12, 121, 0.05)',
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    color: isActive(item.path) ? '#0C0C79' : 'text.secondary',
                    minWidth: 40,
                  }}
                >
                  <Icon />
                </ListItemIcon>
                <ListItemText
                  primary={item.label}
                  primaryTypographyProps={{
                    fontWeight: isActive(item.path) ? 700 : 500,
                    color: isActive(item.path) ? '#0C0C79' : 'inherit',
                  }}
                />
              </ListItemButton>
            </ListItem>
          );
        })}
      </List>
      <Divider />
      <Box sx={{ p: 2 }}>
        <Typography variant="caption" color="text.secondary" display="block" mb={1}>
          Logged in as
        </Typography>
        <Typography variant="body2" fontWeight={600} noWrap>
          {profile?.name || user?.email || 'Admin'}
        </Typography>
      </Box>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      {/* Desktop Sidebar */}
      {!isMobile && (
        <Drawer
          variant="permanent"
          sx={{
            width: DRAWER_WIDTH,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: DRAWER_WIDTH,
              boxSizing: 'border-box',
              backgroundColor: '#f5f5f5',
              border: 'none',
            },
          }}
        >
          {drawer}
        </Drawer>
      )}

      {/* Mobile Drawer */}
      {isMobile && (
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={() => setMobileOpen(false)}
          sx={{
            '& .MuiDrawer-paper': {
              width: DRAWER_WIDTH,
              backgroundColor: '#f5f5f5',
            },
          }}
        >
          {drawer}
        </Drawer>
      )}

      {/* Main Content */}
      <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        {/* Top AppBar */}
        <AppBar
          position="sticky"
          elevation={0}
          sx={{
            backgroundColor: '#fff',
            borderBottom: '1px solid #e0e0e0',
            ml: isMobile ? 0 : `${DRAWER_WIDTH}px`,
          }}
        >
          <Toolbar>
            {isMobile && (
              <IconButton
                edge="start"
                color="inherit"
                onClick={() => setMobileOpen(true)}
                sx={{ mr: 2, color: '#0C0C79' }}
              >
                <MenuIcon />
              </IconButton>
            )}
            <Box sx={{ flex: 1 }} />
            <IconButton
              onClick={(e) => setAnchorEl(e.currentTarget)}
              sx={{ p: 0 }}
            >
              <Avatar
                sx={{
                  width: 40,
                  height: 40,
                  background: 'linear-gradient(135deg, #FF751F 0%, #FFB84D 100%)',
                  fontWeight: 700,
                  color: '#fff',
                }}
              >
                {(profile?.name || user?.email || 'A').charAt(0).toUpperCase()}
              </Avatar>
            </IconButton>
            <Menu
              anchorEl={anchorEl}
              open={Boolean(anchorEl)}
              onClose={() => setAnchorEl(null)}
              anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
              transformOrigin={{ vertical: 'top', horizontal: 'right' }}
            >
              <MenuItem disabled>
                <Typography variant="body2">
                  {profile?.name || user?.email}
                </Typography>
              </MenuItem>
              <Divider />
              <MenuItem>
                <SettingsIcon fontSize="small" sx={{ mr: 1 }} />
                Settings
              </MenuItem>
              <MenuItem onClick={handleLogout}>
                <LogoutIcon fontSize="small" sx={{ mr: 1 }} />
                Logout
              </MenuItem>
            </Menu>
          </Toolbar>
        </AppBar>

        {/* Page Content */}
        <Box
          sx={{
            flex: 1,
            p: 3,
            backgroundColor: '#fff',
            overflow: 'auto',
          }}
        >
          {children}
        </Box>
      </Box>
    </Box>
  );
};

export default Layout;
