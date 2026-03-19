# Quick Reference Guide - Admin Panel

## 🚀 Quick Start

### 1. Start Development Server
```bash
cd admin_panel
npm start
```

### 2. Login Credentials
- Create account at: `http://localhost:3000/login`
- Or use test account: (configured in Supabase)

### 3. Access Dashboard
After login, you'll be redirected to `/dashboard`

## 📁 Important Files

### Configuration
- `src/supabaseClient.js` - Backend connection
- `src/theme.js` - Colors and styling
- `src/index.js` - React root
- `public/index.html` - HTML template

### Entry Points
- `src/App.js` - Main router (START HERE)
- `src/pages/Dashboard.js` - Main dashboard
- `src/components/Layout.js` - App layout

### State Management
- `src/contexts/ThemeContext.js` - Theme toggle
- `src/contexts/AuthContext.js` - User authentication

## 🎨 Using Theme/Dark Mode

### Access Current Theme
```javascript
import { useTheme } from '@mui/material';
import { useThemeMode } from '../contexts/ThemeContext';

function MyComponent() {
  const theme = useTheme();  // MUI theme object
  const { isDarkMode, toggleTheme } = useThemeMode();  // Theme state

  return (
    <Box sx={{ color: theme.palette.primary.main }}>
      <Button onClick={toggleTheme}>
        {isDarkMode ? '☀️ Light' : '🌙 Dark'}
      </Button>
    </Box>
  );
}
```

### Theme Colors
```javascript
theme.palette.primary.main      // #0C0C79 (light) | #4B4BA3 (dark)
theme.palette.secondary.main    // #FF751F
theme.palette.success.main      // #4CAF50 (light) | #81C784 (dark)
theme.palette.background.default // #F8F9FA (light) | #0F0F23 (dark)
```

## 📊 Adding Charts

### Create Chart Display
```javascript
import { BarChartComponent } from '../components/Charts';
import { Card, CardContent } from '@mui/material';

export default function StatsDashboard() {
  return (
    <Card>
      <CardContent>
        <BarChartComponent />
      </CardContent>
    </Card>
  );
}
```

### Available Charts
```javascript
import {
  BarChartComponent,
  LineChartComponent,
  PieChartComponent,
  AreaChartComponent,
} from '../components/Charts';
```

## 🔐 Authentication Usage

### Check if User is Logged In
```javascript
import { useAuth } from '../contexts/AuthContext';

function MyComponent() {
  const { user, loading, error } = useAuth();

  if (loading) return <CircularProgress />;
  if (!user) return <Navigate to="/login" />;

  return <div>Welcome, {user.email}</div>;
}
```

### Login User
```javascript
const { login } = useAuth();

const handleLogin = async () => {
  try {
    await login('user@example.com', 'password123');
    navigate('/dashboard');
  } catch (err) {
    console.error('Login failed:', err);
  }
};
```

### Logout User
```javascript
const { logout } = useAuth();

const handleLogout = async () => {
  await logout();
  navigate('/login');
};
```

## 🎬 Animations

### Page Transition Animation
```javascript
import { motion } from 'framer-motion';

const pageVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
};

export default function Page() {
  return (
    <motion.div
      variants={pageVariants}
      initial="hidden"
      animate="visible"
    >
      {/* Page content */}
    </motion.div>
  );
}
```

### Hover Animation
```javascript
<motion.div whileHover={{ scale: 1.05 }} transition={{ duration: 0.3 }}>
  <Card>Hover me!</Card>
</motion.div>
```

### Staggered Animation
```javascript
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

export default function List() {
  return (
    <motion.div variants={containerVariants} initial="hidden" animate="visible">
      {items.map((item) => (
        <motion.div key={item.id} variants={itemVariants}>
          {item.name}
        </motion.div>
      ))}
    </motion.div>
  );
}
```

## 📱 Responsive Design

### Using Media Queries
```javascript
import { useMediaQuery, useTheme } from '@mui/material';

function ResponsiveComponent() {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const isTablet = useMediaQuery(theme.breakpoints.between('md', 'lg'));

  return (
    <Box sx={{ display: isMobile ? 'block' : 'flex' }}>
      {isMobile ? <MobileLayout /> : <DesktopLayout />}
    </Box>
  );
}
```

### Grid Responsive
```javascript
<Grid container spacing={3}>
  <Grid item xs={12} sm={6} md={4} lg={3}>
    Content takes 1 col on mobile, 1/2 on tablet, 1/3 on desktop
  </Grid>
</Grid>
```

## 🗄️ Supabase Integration

### Fetch Data
```javascript
import { supabase } from '../supabaseClient';

async function fetchCampaigns() {
  const { data, error } = await supabase
    .from('campaigns')
    .select('*')
    .eq('status', 'approved')
    .order('created_at', { ascending: false });

  if (error) console.error('Error:', error);
  return data;
}
```

### Insert Data
```javascript
async function createCampaign(campaignData) {
  const { data, error } = await supabase
    .from('campaigns')
    .insert([campaignData]);

  if (error) console.error('Error:', error);
  return data;
}
```

### Update Data
```javascript
async function updateCampaign(id, updates) {
  const { data, error } = await supabase
    .from('campaigns')
    .update(updates)
    .eq('id', id);

  if (error) console.error('Error:', error);
  return data;
}
```

### Delete Data
```javascript
async function deleteCampaign(id) {
  const { error } = await supabase
    .from('campaigns')
    .delete()
    .eq('id', id);

  if (error) console.error('Error:', error);
}
```

## 🎯 Protected Routes

### Create Protected Component
```javascript
import ProtectedRoute from '../components/ProtectedRoute';
import Layout from '../components/Layout';
import Dashboard from '../pages/Dashboard';

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<AuthPage />} />
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <Layout>
              <Dashboard />
            </Layout>
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}
```

## 🔔 Notifications

### Show Toast
```javascript
import toast from 'react-hot-toast';

// Success
toast.success('Profile updated!');

// Error
toast.error('Something went wrong');

// Custom
toast((t) => (
  <div>
    Custom notification
    <button onClick={() => toast.dismiss(t.id)}>Close</button>
  </div>
));
```

## 🛠️ Common Tasks

### Add New Page
1. Create file in `src/pages/NewPage.js`
2. Import in `App.js`
3. Add route in Routes
4. Add menu item in `components/Layout.js`

### Add New Chart
1. Copy chart data format from `components/Charts.js`
2. Use `ResponsiveContainer` wrapper
3. Import chart component from recharts

### Change Theme Colors
1. Edit `src/theme.js`
2. Update color hex values
3. Changes apply automatically

### Add New Sidebar Menu Item
1. Add to `menuItems` array in `src/components/Layout.js`
2. Import icon from `@mui/icons-material`
3. Create corresponding page and route

## 🐛 Debugging

### Check Auth State
```javascript
const { user, loading, error } = useAuth();
console.log('User:', user);
console.log('Loading:', loading);
console.log('Error:', error);
```

### Check Theme
```javascript
const { isDarkMode } = useThemeMode();
console.log('Dark mode:', isDarkMode);
```

### Check Browser Console
Open DevTools (F12) → Console tab for errors

### Check Network Requests
DevTools → Network tab to verify API calls

## 📞 Common Issues

| Issue | Solution |
|-------|----------|
| Login loop | Check auth state, clear localStorage |
| Theme not changing | Refresh page, check localStorage |
| Charts blank | Verify data format, check console |
| Mobile layout broken | Use responsive breakpoints |
| Slow performance | Check Supabase queries, optimize |

## 🚢 Deployment

### Build for Production
```bash
npm run build
```

### Deploy to Vercel
```bash
npm install -g vercel
vercel
```

### Environment Variables
Create `.env.local`:
```
REACT_APP_SUPABASE_URL=your_url
REACT_APP_SUPABASE_KEY=your_key
```

---

**Last Updated**: March 19, 2026
**Version**: 1.0.0
