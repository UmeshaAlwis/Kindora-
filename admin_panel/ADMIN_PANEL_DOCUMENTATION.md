# Kindora Admin Panel - Complete Documentation

## 📋 Project Overview

The Kindora Admin Panel is a modern, responsive React 19 admin dashboard built with Material-UI, featuring real-time data management, user authentication, and interactive data visualization.

## 🎯 Features Implemented

### 1. **Authentication & Authorization**
- ✅ User login with email/password
- ✅ User registration with Supabase Auth
- ✅ Protected routes based on authentication status
- ✅ Session management and persistence
- ✅ Logout functionality

### 2. **Theme Management**
- ✅ Light/Dark mode toggle
- ✅ Theme persistence in localStorage
- ✅ Seamless theme transitions
- ✅ Custom Material-UI theme with Kindora branding
- ✅ Responsive color schemes

### 3. **Data Visualization**
- ✅ Bar Charts (using Recharts)
- ✅ Line Charts (using Recharts)
- ✅ Pie Charts (using Recharts)
- ✅ Area Charts (using Recharts)
- ✅ Responsive chart layouts
- ✅ Theme-aware chart colors

### 4. **Responsive Design**
- ✅ Mobile-first approach
- ✅ Adaptive layouts for tablet and desktop
- ✅ Responsive navigation drawer
- ✅ Mobile-optimized charts
- ✅ Touch-friendly components

### 5. **Animations**
- ✅ Page transition animations (Framer Motion)
- ✅ Component entrance animations
- ✅ Button hover effects
- ✅ Smooth theme transitions
- ✅ Card scale animations

### 6. **UI Components**
- ✅ Dashboard with stat cards
- ✅ Data tables
- ✅ Forms and inputs
- ✅ Cards and containers
- ✅ Alerts and notifications
- ✅ Navigation drawer
- ✅ User avatar with menu

## 📁 Project Structure

```
admin_panel/
├── src/
│   ├── components/
│   │   ├── Layout.js              # Main layout wrapper
│   │   ├── Charts.js              # Reusable chart components
│   │   ├── ProtectedRoute.js      # Route protection
│   │   └── SplashScreen.js        # Splash screen
│   ├── contexts/
│   │   ├── ThemeContext.js        # Theme state management
│   │   └── AuthContext.js         # Authentication state
│   ├── pages/
│   │   ├── Dashboard.js           # Main dashboard
│   │   ├── AuthPage.js            # Login/Register page
│   │   ├── UserProfile.js         # User profile management
│   │   ├── Campaigns.js           # Campaign management
│   │   ├── Users.js               # User management
│   │   ├── Reports.js             # Analytics reports
│   │   └── Analytics.js           # Advanced analytics
│   ├── App.js                     # Main app component
│   ├── theme.js                   # Theme configuration
│   ├── supabaseClient.js          # Supabase setup
│   └── index.js                   # React DOM render
└── package.json
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Supabase account and project

### Installation

1. **Navigate to the admin panel directory:**
```bash
cd admin_panel
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure Supabase:**
- Update `src/supabaseClient.js` with your Supabase project URL and API key

4. **Start the development server:**
```bash
npm start
```

5. **Open browser:**
```
http://localhost:3000
```

## 🎨 Theme Usage

### Switching Themes Programmatically
```javascript
import { useTheme as useCustomTheme } from '../contexts/ThemeContext';

export default function Component() {
  const { isDarkMode, toggleTheme } = useCustomTheme();

  return (
    <button onClick={toggleTheme}>
      {isDarkMode ? '☀️ Light' : '🌙 Dark'}
    </button>
  );
}
```

### Accessing Material-UI Theme
```javascript
import { useTheme } from '@mui/material';

export default function Component() {
  const theme = useTheme();

  return (
    <Box sx={{ color: theme.palette.primary.main }}>
      Styled with MUI theme
    </Box>
  );
}
```

## 🔐 Authentication Usage

### Login
```javascript
import { useAuth } from '../contexts/AuthContext';

export default function LoginComponent() {
  const { login, loading, error } = useAuth();

  const handleLogin = async (email, password) => {
    await login(email, password);
  };

  return (
    // Your login form
  );
}
```

### Protected Routes
```javascript
import ProtectedRoute from '../components/ProtectedRoute';

<Routes>
  <Route
    path="/dashboard"
    element={
      <ProtectedRoute>
        <Dashboard />
      </ProtectedRoute>
    }
  />
</Routes>
```

## 📊 Chart Components Usage

### Bar Chart
```javascript
import { BarChartComponent } from '../components/Charts';

<Card>
  <BarChartComponent />
</Card>
```

### Line Chart
```javascript
import { LineChartComponent } from '../components/Charts';

<Card>
  <LineChartComponent />
</Card>
```

### Pie Chart
```javascript
import { PieChartComponent } from '../components/Charts';

<Card>
  <PieChartComponent />
</Card>
```

### Area Chart
```javascript
import { AreaChartComponent } from '../components/Charts';

<Card>
  <AreaChartComponent />
</Card>
```

## 🎬 Animations with Framer Motion

### Page Transition
```javascript
import { motion } from 'framer-motion';

const containerVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
};

<motion.div variants={containerVariants} initial="hidden" animate="visible">
  {/* Your content */}
</motion.div>
```

### Hover Effects
```javascript
<motion.div whileHover={{ scale: 1.05 }} transition={{ duration: 0.3 }}>
  {/* Your hoverable content */}
</motion.div>
```

## 📱 Responsive Design Patterns

### Using Media Queries
```javascript
import { useMediaQuery, useTheme } from '@mui/material';

const Component = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));

  return (
    <Box sx={{ display: isMobile ? 'block' : 'flex' }}>
      {/* Responsive content */}
    </Box>
  );
};
```

### Grid Responsive
```javascript
<Grid container spacing={3}>
  <Grid item xs={12} md={6}>
    {/* Half width on desktop, full on mobile */}
  </Grid>
  <Grid item xs={12} md={6}>
    {/* Half width on desktop, full on mobile */}
  </Grid>
</Grid>
```

## 🔗 API Integration with Supabase

### Fetching Data
```javascript
import { supabase } from '../supabaseClient';

const fetchData = async () => {
  const { data, error } = await supabase
    .from('table_name')
    .select('*');
  
  if (error) console.error(error);
  return data;
};
```

### Real-time Subscriptions
```javascript
const subscription = supabase
  .from('table_name')
  .on('*', (payload) => {
    console.log('Change received:', payload);
  })
  .subscribe();
```

## 🎨 Available Colors

### Light Theme
- Primary: `#0C0C79` (Kindora Blue)
- Secondary: `#FF751F` (Orange)
- Success: `#4CAF50`
- Warning: `#FFC107`
- Error: `#F44336`

### Dark Theme
- Primary: `#4B4BA3` (Light Blue)
- Secondary: `#FF751F` (Orange)
- Background: `#0F0F23`
- Paper: `#1A1A3A`

## 📦 Dependencies

- **React**: 19.2.4
- **Material-UI**: 7.3.9
- **Framer Motion**: 12.36.0
- **Recharts**: 3.8.0
- **Supabase**: 2.98.0
- **React Router**: 7.13.1
- **Axios**: 1.13.6

## 🛠️ Available Scripts

### Start Development Server
```bash
npm start
```

### Build for Production
```bash
npm run build
```

### Run Tests
```bash
npm test
```

### Eject Configuration
```bash
npm run eject
```

## 🐛 Troubleshooting

### Theme Not Changing
- Ensure `ThemeContextProvider` wraps your app
- Check localStorage for theme persistence
- Verify MUI theme provider is set correctly

### Charts Not Rendering
- Confirm data is being passed correctly
- Check chart responsiveness on different screen sizes
- Verify Recharts is installed: `npm install recharts`

### Authentication Issues
- Verify Supabase credentials
- Check network requests in browser DevTools
- Ensure user is signed in before accessing protected routes

## 📚 Resources

- [Material-UI Documentation](https://mui.com/)
- [Framer Motion Documentation](https://www.framer.com/motion/)
- [Recharts Documentation](https://recharts.org/)
- [Supabase Documentation](https://supabase.com/docs)
- [React Router Documentation](https://reactrouter.com/)

## 👥 Team

Developed for Kindora - Compassionate Giving Platform

## 📄 License

This project is part of the Kindora platform and follows its licensing terms.

---

**Last Updated**: March 19, 2026

For support or questions, reach out to the development team.
