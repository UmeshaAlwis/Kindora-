<!-- Admin Panel Title and Badge -->
<div align="center">

# 💎 Kindora Admin Panel

[![React](https://img.shields.io/badge/React-19.2.4-blue?style=flat-square&logo=react)]()
[![Material-UI](https://img.shields.io/badge/Material%20UI-7.3.9-0081CB?style=flat-square&logo=mui)]()
[![Supabase](https://img.shields.io/badge/Supabase-2.98.0-3fcf8e?style=flat-square&logo=supabase)]()
[![Status](https://img.shields.io/badge/Status-Production%20Ready-green?style=flat-square)]()

A modern, fully-featured React 19 admin dashboard with real-time data management, user authentication, and interactive data visualization.

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Architecture](#-architecture)

</div>

---

## 📋 Features

### 🔐 Authentication & Security
- ✅ **Email/Password Authentication** - Secure user login with password validation
- ✅ **User Registration** - New user signup with email verification
- ✅ **Protected Routes** - Route-level access control based on authentication status
- ✅ **Session Management** - Automatic session persistence and restoration
- ✅ **Supabase Integration** - Enterprise-grade backend authentication

### 🎨 Theme Management
- ✅ **Light/Dark Mode** - Toggle between light and dark themes
- ✅ **Persistent Theme** - Theme preference saved in localStorage
- ✅ **Smooth Transitions** - Seamless theme switching with no page reload
- ✅ **Brand Colors** - Kindora-branded color palette (Blue/Orange)
- ✅ **Responsive Theming** - All components adapt to selected theme

### 📊 Data Visualization
- ✅ **Bar Charts** - Compare metrics with interactive bar charts
- ✅ **Line Charts** - Visualize trends and progressions
- ✅ **Pie Charts** - Show distribution and proportions
- ✅ **Area Charts** - Display stacked area data
- ✅ **Responsive Charts** - Charts adapt to screen size
- ✅ **Theme-Aware Colors** - Charts match selected theme

### 🎯 UI Components (Material-UI)
- ✅ **Responsive Drawer** - Mobile-friendly sidebar navigation
- ✅ **Data Tables** - Sortable, filterable data displays
- ✅ **Cards & Containers** - Modular, reusable layout components
- ✅ **Forms & Inputs** - Complete form controls and validation
- ✅ **Notifications** - Alerts and toast notifications
- ✅ **Avatars & Icons** - User profiles and visual indicators
- ✅ **Accessibility** - WCAG compliant components

### 🚀 Navigation
- ✅ **React Router v7** - Client-side routing
- ✅ **Dynamic Routes** - URL-based page navigation
- ✅ **Protected Routes** - Authentication-gated pages
- ✅ **Smooth Navigation** - Animated page transitions

### 🎬 Animations
- ✅ **Page Transitions** - Smooth entrance animations
- ✅ **Hover Effects** - Interactive component feedback
- ✅ **Scale Animations** - Zoom and scale effects
- ✅ **Staggered Animations** - Sequential item animations
- ✅ **Smooth Transitions** - CSS transitions throughout

### 📱 Responsive Design
- ✅ **Mobile-First** - Optimized for mobile devices
- ✅ **Tablet Support** - Adaptive layouts for tablets
- ✅ **Desktop Layouts** - Full-featured desktop experience
- ✅ **Touch-Friendly** - Large touch targets and spacing
- ✅ **Flexible Grid** - Responsive grid system

### 🗄️ Backend Integration
- ✅ **Real-time Data** - Live data updates from Supabase
- ✅ **Database Connectivity** - Full CRUD operations
- ✅ **User Profiles** - Profile management
- ✅ **Data Persistence** - Secure data storage

---

## 🚀 Quick Start

### Prerequisites
```bash
Node.js >= 16.x
npm or yarn
Supabase account
```

### Installation

1. **Navigate to project**
```bash
cd admin_panel
```

2. **Install dependencies**
```bash
npm install
```

3. **Configure Supabase**
Edit `src/supabaseClient.js`:
```javascript
const supabaseUrl = 'https://your-project.supabase.co'
const supabaseKey = 'your-anon-key'
```

4. **Start development server**
```bash
npm start
```

5. **Open in browser**
```
http://localhost:3000
```

### First Time Setup
1. Go to `/login`
2. Click "Sign Up" to create account
3. Enter email and password
4. You'll be redirected to dashboard

---

## 📁 Project Structure

```
admin_panel/
├── public/
│   ├── index.html           # HTML template
│   └── manifest.json
├── src/
│   ├── components/
│   │   ├── Layout.js        # Main app layout
│   │   ├── Charts.js        # Chart components
│   │   ├── ProtectedRoute.js # Route guard
│   │   └── SplashScreen.js
│   ├── contexts/
│   │   ├── ThemeContext.js  # Theme state
│   │   └── AuthContext.js   # Auth state
│   ├── pages/
│   │   ├── Dashboard.js     # Main dashboard
│   │   ├── AuthPage.js      # Login/Register
│   │   ├── UserProfile.js   # User profile
│   │   ├── Campaigns.js
│   │   ├── Users.js
│   │   └── ...
│   ├── App.js               # Main router
│   ├── theme.js             # MUI theme
│   ├── supabaseClient.js    # Backend setup
│   └── index.js             # Entry point
├── package.json
└── README.md
```

---

## 🎨 Theme Usage

### Toggle Theme
```javascript
import { useThemeMode } from './contexts/ThemeContext';

export default function App() {
  const { isDarkMode, toggleTheme } = useThemeMode();

  return (
    <Button onClick={toggleTheme}>
      {isDarkMode ? '☀️ Light' : '🌙 Dark'}
    </Button>
  );
}
```

### Access Theme Colors
```javascript
import { useTheme } from '@mui/material';

const theme = useTheme();
const primaryColor = theme.palette.primary.main;
```

---

## 🔐 Authentication

### Login
```javascript
import { useAuth } from './contexts/AuthContext';

const { login } = useAuth();
await login('user@example.com', 'password');
```

### Check Auth Status
```javascript
const { user, loading, error } = useAuth();

if (loading) return <Spinner />;
if (!user) return <Navigate to="/login" />;
```

---

## 📊 Charts

### Adding Charts
```javascript
import {
  BarChartComponent,
  LineChartComponent,
  PieChartComponent,
  AreaChartComponent
} from '../components/Charts';

<BarChartComponent />
```

All charts are responsive and theme-aware.

---

## 🎬 Animations

### Page Transition
```javascript
import { motion } from 'framer-motion';

const variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
};

<motion.div variants={variants} initial="hidden" animate="visible">
  {/* Content */}
</motion.div>
```

---

## 📱 Responsive Design

### Media Queries
```javascript
import { useMediaQuery, useTheme } from '@mui/material';

const theme = useTheme();
const isMobile = useMediaQuery(theme.breakpoints.down('md'));
```

### Responsive Grid
```javascript
<Grid container spacing={3}>
  <Grid item xs={12} sm={6} md={4}>
    {/* 1 col mobile, 2 cols tablet, 3 cols desktop */}
  </Grid>
</Grid>
```

---

## 🗄️ Supabase Integration

### Fetch Data
```javascript
import { supabase } from './supabaseClient';

const { data } = await supabase
  .from('campaigns')
  .select('*')
  .order('created_at', { ascending: false });
```

### Real-time Updates
```javascript
supabase
  .from('campaigns')
  .on('*', (payload) => {
    console.log('Change:', payload);
  })
  .subscribe();
```

---

## 🛠️ Available Scripts

| Script | Purpose |
|--------|---------|
| `npm start` | Start development server |
| `npm run build` | Build for production |
| `npm test` | Run test suite |
| `npm run eject` | Eject configuration |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| react | 19.2.4 | UI framework |
| @mui/material | 7.3.9 | Components |
| framer-motion | 12.36.0 | Animations |
| recharts | 3.8.0 | Charts |
| @supabase/supabase-js | 2.98.0 | Backend |
| react-router-dom | 7.13.1 | Routing |
| react-hot-toast | 2.6.0 | Notifications |
| axios | 1.13.6 | HTTP client |

---

## 🎓 Documentation

| Document | Content |
|----------|---------|
| [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) | Architecture and setup |
| [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | Quick lookup guide |
| [CODE_EXAMPLES.md](./CODE_EXAMPLES.md) | Code examples |
| [FEATURES_CHECKLIST.md](./FEATURES_CHECKLIST.md) | Feature status |
| [ADMIN_PANEL_DOCUMENTATION.md](./ADMIN_PANEL_DOCUMENTATION.md) | Full documentation |

---

## 🐛 Troubleshooting

### Theme Not Changing
- Clear browser cache
- Check localStorage permission
- Verify ThemeContextProvider wraps app

### Login Issues
- Check Supabase credentials
- Verify network connection
- Clear session cookies

### Charts Not Rendering
- Verify data format
- Check browser console for errors
- Ensure ResponsiveContainer wrapper

### Mobile Layout Issues
- Use responsive breakpoints
- Check Media Query Hook usage
- Verify Grid spacing

---

## 🚀 Production Deployment

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
Create `.env.production`:
```
REACT_APP_SUPABASE_URL=your_url
REACT_APP_SUPABASE_KEY=your_key
```

---

## 🎯 Best Practices

### Code Organization
✅ One component per file  
✅ Group related files in folders  
✅ Use meaningful naming conventions  

### Performance
✅ Lazy load routes  
✅ Memoize heavy components  
✅ Optimize images  

### Accessibility
✅ Use semantic HTML  
✅ Add alt text to images  
✅ Test with screen readers  

### Security
✅ Never commit secrets  
✅ Use environment variables  
✅ Validate user input  
✅ Sanitize API responses  

---

## 📈 Features Roadmap

- [ ] Advanced filtering
- [ ] Export to CSV/PDF
- [ ] Scheduled reports
- [ ] Email notifications
- [ ] API documentation
- [ ] Mobile app
- [ ] Analytics integration
- [ ] Advanced search

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is part of the Kindora platform and follows its licensing terms.

---

## 📞 Support

For issues, questions, or suggestions:

1. Check the [documentation](./ADMIN_PANEL_DOCUMENTATION.md)
2. Review [code examples](./CODE_EXAMPLES.md)
3. Check browser console for errors
4. Contact the development team

---

## 🙏 Acknowledgments

Built with love for the Kindora community by the development team.

**Technologies Used:**
- React 19.2.4
- Material-UI 7.3.9
- Framer Motion 12.36.0
- Recharts 3.8.0
- Supabase 2.98.0

---

<div align="center">

**Kindora Admin Panel** © 2026

Made with ❤️ for Compassionate Giving

</div>
