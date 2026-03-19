# Code Examples - Admin Panel

## Table of Contents
1. [Component Examples](#component-examples)
2. [Authentication Examples](#authentication-examples)
3. [Data Management Examples](#data-management-examples)
4. [Theme & Styling Examples](#theme--styling-examples)
5. [Animation Examples](#animation-examples)
6. [Responsive Design Examples](#responsive-design-examples)

---

## Component Examples

### Basic Component with Theme
```javascript
import React from 'react';
import { Box, Card, CardContent, Typography, useTheme } from '@mui/material';
import { motion } from 'framer-motion';

export default function BasicCard() {
  const theme = useTheme();

  return (
    <motion.div whileHover={{ scale: 1.05 }}>
      <Card sx={{ p: 2 }}>
        <CardContent>
          <Typography 
            variant="h5" 
            sx={{ color: theme.palette.primary.main }}
          >
            Card Title
          </Typography>
          <Typography variant="body2">
            Card content goes here
          </Typography>
        </CardContent>
      </Card>
    </motion.div>
  );
}
```

### Stat Card Component
```javascript
import React from 'react';
import { Box, Card, CardContent, Typography, useTheme } from '@mui/material';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import { motion } from 'framer-motion';

export default function StatCard({ title, value, icon: Icon, color }) {
  const theme = useTheme();

  return (
    <motion.div whileHover={{ scale: 1.05 }}>
      <Card sx={{
        background: `linear-gradient(135deg, ${color}15 0%, ${color}08 100%)`,
        border: `2px solid ${color}30`,
      }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Box sx={{ color }}>
              <Icon sx={{ fontSize: 40 }} />
            </Box>
            <Box>
              <Typography variant="caption" color="textSecondary">
                {title}
              </Typography>
              <Typography variant="h5" sx={{ fontWeight: 700 }}>
                {value}
              </Typography>
            </Box>
          </Box>
        </CardContent>
      </Card>
    </motion.div>
  );
}

// Usage
<StatCard 
  title="Total Donations"
  value="$125,000"
  icon={FavoriteIcon}
  color="#FF1744"
/>
```

### Custom Data Table
```javascript
import React, { useState } from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  useTheme,
} from '@mui/material';

export default function CustomTable({ data }) {
  const theme = useTheme();
  const [page, setPage] = useState(0);
  const rowsPerPage = 10;

  const getStatusColor = (status) => {
    return status === 'approved' ? 'success' : 'warning';
  };

  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow sx={{ backgroundColor: theme.palette.action.hover }}>
            <TableCell>Name</TableCell>
            <TableCell>Email</TableCell>
            <TableCell>Status</TableCell>
            <TableCell align="right">Amount</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {data.slice(page * rowsPerPage, (page + 1) * rowsPerPage).map((row) => (
            <TableRow key={row.id} hover>
              <TableCell>{row.name}</TableCell>
              <TableCell>{row.email}</TableCell>
              <TableCell>
                <Chip 
                  label={row.status}
                  color={getStatusColor(row.status)}
                  size="small"
                />
              </TableCell>
              <TableCell align="right">${row.amount}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
}
```

---

## Authentication Examples

### Login Form Component
```javascript
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import {
  Box,
  TextField,
  Button,
  Alert,
  CircularProgress,
  Container,
} from '@mui/material';
import toast from 'react-hot-toast';

export default function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(email, password);
      toast.success('Login successful!');
      navigate('/dashboard');
    } catch (err) {
      setError(err.message);
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm">
      <Box component="form" onSubmit={handleSubmit} sx={{ mt: 4 }}>
        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
        
        <TextField
          fullWidth
          label="Email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          margin="normal"
          disabled={loading}
          required
        />

        <TextField
          fullWidth
          label="Password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          margin="normal"
          disabled={loading}
          required
        />

        <Button
          fullWidth
          variant="contained"
          sx={{ mt: 3 }}
          disabled={loading}
        >
          {loading ? <CircularProgress size={24} /> : 'Login'}
        </Button>
      </Box>
    </Container>
  );
}
```

### Protected Component Wrapper
```javascript
import React from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Navigate, useLocation } from 'react-router-dom';
import { CircularProgress, Box } from '@mui/material';

export default function ProtectedComponent({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} />;
  }

  return children;
}
```

---

## Data Management Examples

### Fetch Data Hook
```javascript
import { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';

export function useFetchData(table, filters = {}) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchData() {
      try {
        let query = supabase.from(table).select('*');

        // Apply filters
        Object.entries(filters).forEach(([key, value]) => {
          if (value) query = query.eq(key, value);
        });

        const { data, error } = await query;

        if (error) throw error;
        setData(data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [table, filters]);

  return { data, loading, error };
}

// Usage
function MyComponent() {
  const { data: campaigns, loading } = useFetchData('campaigns', { status: 'active' });

  if (loading) return <LoadingSpinner />;

  return <CampaignList campaigns={campaigns} />;
}
```

### Create/Update Hook
```javascript
import { useState } from 'react';
import { supabase } from '../supabaseClient';
import toast from 'react-hot-toast';

export function useManageData(table) {
  const [loading, setLoading] = useState(false);

  const create = async (data) => {
    setLoading(true);
    try {
      const { error } = await supabase.from(table).insert([data]);
      if (error) throw error;
      toast.success('Created successfully');
      return true;
    } catch (err) {
      toast.error(err.message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const update = async (id, data) => {
    setLoading(true);
    try {
      const { error } = await supabase
        .from(table)
        .update(data)
        .eq('id', id);
      if (error) throw error;
      toast.success('Updated successfully');
      return true;
    } catch (err) {
      toast.error(err.message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const delete_ = async (id) => {
    setLoading(true);
    try {
      const { error } = await supabase.from(table).delete().eq('id', id);
      if (error) throw error;
      toast.success('Deleted successfully');
      return true;
    } catch (err) {
      toast.error(err.message);
      return false;
    } finally {
      setLoading(false);
    }
  };

  return { create, update, delete_, loading };
}

// Usage
function EditCampaign({ campaignId }) {
  const { update, loading } = useManageData('campaigns');

  const handleSave = async (formData) => {
    await update(campaignId, formData);
  };

  return (
    <form onSubmit={(e) => { e.preventDefault(); handleSave(formData); }}>
      {/* Form fields */}
    </form>
  );
}
```

### Real-time Subscription
```javascript
import { useEffect, useState } from 'react';
import { supabase } from '../supabaseClient';

export function useRealtime(table) {
  const [data, setData] = useState([]);

  useEffect(() => {
    // Initial fetch
    const fetchData = async () => {
      const { data } = await supabase.from(table).select('*');
      setData(data || []);
    };

    fetchData();

    // Subscribe to changes
    const subscription = supabase
      .from(table)
      .on('*', (payload) => {
        setData((prev) => {
          // Update data based on event type
          if (payload.eventType === 'INSERT') {
            return [...prev, payload.new];
          } else if (payload.eventType === 'UPDATE') {
            return prev.map((item) =>
              item.id === payload.new.id ? payload.new : item
            );
          } else if (payload.eventType === 'DELETE') {
            return prev.filter((item) => item.id !== payload.old.id);
          }
          return prev;
        });
      })
      .subscribe();

    return () => subscription.unsubscribe();
  }, [table]);

  return data;
}

// Usage
function CampaignList() {
  const campaigns = useRealtime('campaigns');

  return (
    <List>
      {campaigns.map((campaign) => (
        <ListItem key={campaign.id}>{campaign.name}</ListItem>
      ))}
    </List>
  );
}
```

---

## Theme & Styling Examples

### Theme-aware Component
```javascript
import React from 'react';
import { Box, useTheme } from '@mui/material';
import { useThemeMode } from '../contexts/ThemeContext';

export default function ThemedBox() {
  const theme = useTheme();
  const { isDarkMode } = useThemeMode();

  return (
    <Box sx={{
      padding: 2,
      backgroundColor: theme.palette.background.paper,
      borderLeft: `4px solid ${theme.palette.primary.main}`,
      borderRadius: 1,
      transition: 'all 0.3s ease',
      '&:hover': {
        boxShadow: theme.shadows[8],
        transform: 'translateX(4px)',
      },
    }}>
      This box adapts to {isDarkMode ? 'dark' : 'light'} mode
    </Box>
  );
}
```

### Custom Styled Component
```javascript
import { styled, Box } from '@mui/material';

const StyledBox = styled(Box)(({ theme }) => ({
  padding: theme.spacing(2),
  borderRadius: theme.shape.borderRadius,
  background: `linear-gradient(135deg, ${theme.palette.primary.main}15 0%, ${theme.palette.secondary.main}15 100%)`,
  border: `1px solid ${theme.palette.divider}`,
  transition: 'all 0.3s ease',
  '&:hover': {
    boxShadow: theme.shadows[4],
  },
}));

export default function StyledComponentExample() {
  return <StyledBox>Styled Component</StyledBox>;
}
```

---

## Animation Examples

### Loading Animation
```javascript
import React from 'react';
import { motion } from 'framer-motion';
import { CircularProgress, Box } from '@mui/material';

export default function LoadingSpinner() {
  return (
    <motion.div
      animate={{ rotate: 360 }}
      transition={{ duration: 1, repeat: Infinity }}
    >
      <CircularProgress />
    </motion.div>
  );
}
```

### List Animation
```javascript
import React from 'react';
import { motion } from 'framer-motion';
import { List, ListItem } from '@mui/material';

export default function AnimatedList({ items }) {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 },
  };

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      <List>
        {items.map((item) => (
          <motion.div key={item.id} variants={itemVariants}>
            <ListItem>{item.title}</ListItem>
          </motion.div>
        ))}
      </List>
    </motion.div>
  );
}
```

---

## Responsive Design Examples

### Responsive Grid
```javascript
import React from 'react';
import { Grid, Card, useTheme, useMediaQuery } from '@mui/material';

export default function ResponsiveGrid() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.between('sm', 'md'));

  return (
    <Grid container spacing={isMobile ? 1 : 3}>
      <Grid item xs={12} sm={6} md={4}>
        <Card>Item 1</Card>
      </Grid>
      <Grid item xs={12} sm={6} md={4}>
        <Card>Item 2</Card>
      </Grid>
      <Grid item xs={12} sm={6} md={4}>
        <Card>Item 3</Card>
      </Grid>
    </Grid>
  );
}
```

### Adaptive Navigation
```javascript
import React, { useState } from 'react';
import {
  AppBar,
  Drawer,
  IconButton,
  useTheme,
  useMediaQuery,
  Box,
  Toolbar,
} from '@mui/material';
import { Menu as MenuIcon, Close as CloseIcon } from '@mui/icons-material';

export default function AdaptiveNav() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [open, setOpen] = useState(false);

  return (
    <>
      <AppBar>
        <Toolbar>
          {isMobile && (
            <IconButton onClick={() => setOpen(!open)}>
              {open ? <CloseIcon /> : <MenuIcon />}
            </IconButton>
          )}
          {isMobile ? (
            <Box>Mobile Menu</Box>
          ) : (
            <Box>Desktop Menu</Box>
          )}
        </Toolbar>
      </AppBar>
      {isMobile && (
        <Drawer open={open} onClose={() => setOpen(false)}>
          Drawer Content
        </Drawer>
      )}
    </>
  );
}
```

---

**Last Updated**: March 19, 2026
