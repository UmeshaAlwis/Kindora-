# ✨ Admin Panel - Implementation Guide

## 🎯 Setup Instructions

### Step 1: Install Dependencies
```bash
cd admin_panel
npm install
```

### Step 2: Configure Supabase
Open `src/supabaseClient.js` and ensure your credentials are set:
```javascript
const supabaseUrl = 'https://your-project.supabase.co'
const supabaseKey = 'your-anon-key'
```

### Step 3: Start Development
```bash
npm start
```

## 🏗️ Architecture Overview

### Context Providers
The app uses React Context for state management:

1. **ThemeContext** - Manages light/dark theme toggle
   - Located: `src/contexts/ThemeContext.js`
   - Hook: `useThemeMode()`
   - Persists in localStorage

2. **AuthContext** - Handles authentication state
   - Located: `src/contexts/AuthContext.js`
   - Hook: `useAuth()`
   - Syncs with Supabase Auth

### Route Protection
All dashboard routes are wrapped with `ProtectedRoute` component:
```javascript
<ProtectedRoute>
  <Layout>
    <YourComponent />
  </Layout>
</ProtectedRoute>
```

## 📦 Core Components

### Layout Component
Main wrapper component providing:
- Responsive drawer sidebar
- Top app bar with theme toggle
- User menu with logout
- Mobile-friendly hamburger menu
- Navigation to all pages

### Charts Component
Reusable chart components:
- `BarChartComponent` - Bar chart visualization
- `LineChartComponent` - Trend lines
- `PieChartComponent` - Distribution view
- `AreaChartComponent` - Stacked areas

## 🎨 Theming System

### Available Themes
- **Light Theme**: Clean white backgrounds with blue accents
- **Dark Theme**: Dark blue backgrounds with enhanced contrast

### Color Palette
```javascript
// Light Theme
Primary: #0C0C79
Secondary: #FF751F
Success: #4CAF50
Warning: #FFC107
Error: #F44336

// Dark Theme
Primary: #4B4BA3
Background: #0F0F23
```

### Using Themes
```javascript
import { useTheme } from '@mui/material';
import { useThemeMode } from './contexts/ThemeContext';

export default function Component() {
  const muiTheme = useTheme();
  const { isDarkMode, toggleTheme } = useThemeMode();

  return (
    <Button onClick={toggleTheme}>
      Toggle: {isDarkMode ? 'Light' : 'Dark'}
    </Button>
  );
}
```

## 🔐 Authentication Flow

### Login
1. User navigates to `/login` or `/auth`
2. AuthPage component renders login form
3. Supabase handles authentication
4. On success, redirects to `/dashboard`

### Registration
Same page as login with toggle between forms

### Protected Routes
- `/dashboard` - Main dashboard
- `/campaigns` - Campaign management
- `/feed-approvals` - Approval queue
- `/merchandise` - Product management
- `/alerts` - Alert notifications
- `/profile` - User profile

## 📱 Responsive Breakpoints

```javascript
xs: 0px        // Mobile
sm: 600px      // Small tablet
md: 960px      // Tablet
lg: 1280px     // Desktop
xl: 1920px     // Large desktop
```

## 🎬 Animation Types

### Page Transitions
```javascript
const variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } }
};

<motion.div variants={variants} initial="hidden" animate="visible">
```

### Hover Effects
```javascript
<motion.div whileHover={{ scale: 1.05 }}>
  {/* Content */}
</motion.div>
```

## 🗄️ Integration with Supabase

### Fetching Data
```javascript
import { supabase } from '../supabaseClient';

const { data, error } = await supabase
  .from('campaigns')
  .select('*')
  .order('created_at', { ascending: false });
```

### Inserting Data
```javascript
const { data, error } = await supabase
  .from('campaigns')
  .insert([{ name: 'New Campaign' }]);
```

### Updating Data
```javascript
const { data, error } = await supabase
  .from('campaigns')
  .update({ status: 'approved' })
  .eq('id', campaignId);
```

### Real-time Subscriptions
```javascript
const subscription = supabase
  .from('campaigns')
  .on('*', (payload) => {
    console.log('Change:', payload);
  })
  .subscribe();
```

## 📊 Dashboard Features

### Stat Cards
- Total Donations
- Active Campaigns
- Pending Approvals
- Pending Messages
- Merch Orders

### Charts
- Donations Over Time (Area Chart)
- Campaign Performance (Bar Chart)
- User Growth (Line Chart)
- Distribution (Pie Chart)

### Tables
- Beneficiary Approvals
- Campaign Approvals
- Donation Feed Updates
- Merchandise Orders

## 🛠️ Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| react | 19.2.4 | Core framework |
| @mui/material | 7.3.9 | UI components |
| framer-motion | 12.36.0 | Animations |
| recharts | 3.8.0 | Charts |
| @supabase/supabase-js | 2.98.0 | Backend |
| react-router-dom | 7.13.1 | Navigation |
| react-hot-toast | 2.6.0 | Notifications |

## 🎯 Best Practices

### State Management
1. Use Context for global state (theme, auth)
2. Use useState for component-level state
3. Lift state up when shared between components

### Performance
1. Memoize components with `React.memo`
2. Use `useCallback` for event handlers
3. Lazy load routes with `lazy` and `Suspense`

### Code Organization
1. One component per file
2. Group related files in folders
3. Use meaningful names for imports

### Error Handling
1. Always wrap API calls in try-catch
2. Display user-friendly error messages
3. Log errors for debugging

## 🧪 Testing

### Running Tests
```bash
npm test
```

### Test Structure
```javascript
import { render, screen } from '@testing-library/react';
import Component from '../Component';

test('renders correctly', () => {
  render(<Component />);
  expect(screen.getByText('Expected Text')).toBeInTheDocument();
});
```

## 📚 File Reference

| File | Purpose |
|------|---------|
| App.js | Main app router |
| theme.js | MUI theme configuration |
| supabaseClient.js | Supabase initialization |
| contexts/ThemeContext.js | Theme state management |
| contexts/AuthContext.js | Authentication state |
| components/Layout.js | Main layout wrapper |
| components/Charts.js | Chart components |
| components/ProtectedRoute.js | Route guard |
| pages/Dashboard.js | Main dashboard |
| pages/AuthPage.js | Login/Register |
| pages/UserProfile.js | User profile management |

## 🚀 Production Deployment

### Build
```bash
npm run build
```

### Environment Variables
Create `.env.production`:
```
REACT_APP_SUPABASE_URL=https://your-project.supabase.co
REACT_APP_SUPABASE_KEY=your-anon-key
```

### Deploy to Vercel
```bash
npm i -g vercel
vercel
```

## 🆘 Troubleshooting

### Issue: Theme doesn't persist
**Solution**: Check localStorage and ensure ThemeContextProvider wraps entire app

### Issue: Protected routes not working
**Solution**: Ensure AuthProvider wraps BrowserRouter and user is authenticated

### Issue: Charts not responsive
**Solution**: Verify ResponsiveContainer is parent and height is set correctly

### Issue: Slow load times
**Solution**: Code-split routes with React.lazy and Suspense

## 📞 Support

For issues or questions:
1. Check the documentation
2. Review component examples
3. Check browser console for errors
4. Verify Supabase connection

---

**Admin Panel Version**: 1.0.0  
**React Version**: 19.2.4  
**Last Updated**: March 19, 2026
