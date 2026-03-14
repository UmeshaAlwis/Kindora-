import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { supabase } from '../supabaseClient';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  CircularProgress,
  Button,
  Chip,
  Paper,
  Divider,
} from '@mui/material';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
} from 'recharts';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import CampaignIcon from '@mui/icons-material/Campaign';
import VerifiedUserIcon from '@mui/icons-material/VerifiedUser';
import MessageIcon from '@mui/icons-material/Message';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import FavoriteIcon from '@mui/icons-material/Favorite';

const StatCard = ({ title, value, icon, color, subtitle, trend }) => (
  <motion.div whileHover={{ scale: 1.05 }} transition={{ duration: 0.3 }}>
    <Card
      sx={{
        height: '100%',
        background: `linear-gradient(135deg, ${color}15 0%, ${color}08 100%)`,
        border: `2px solid ${color}30`,
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <Box
        sx={{
          position: 'absolute',
          top: -20,
          right: -20,
          fontSize: 90,
          opacity: 0.1,
          color: color,
        }}
      >
        {icon}
      </Box>
      <CardContent sx={{ position: 'relative', zIndex: 1 }}>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start">
          <Box>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              {title}
            </Typography>
            <Typography variant="h4" fontWeight={800} color="text.primary">
              {value}
            </Typography>
            {subtitle && (
              <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                {subtitle}
              </Typography>
            )}
          </Box>
          <Box
            sx={{
              p: 1.5,
              borderRadius: 3,
              backgroundColor: `${color}20`,
              color: color,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {icon}
          </Box>
        </Box>
        {trend && (
          <Box display="flex" alignItems="center" gap={0.5} mt={1.5}>
            <TrendingUpIcon sx={{ fontSize: 16, color: trend > 0 ? 'success.main' : 'error.main' }} />
            <Typography
              variant="caption"
              sx={{ color: trend > 0 ? 'success.main' : 'error.main', fontWeight: 600 }}
            >
              {Math.abs(trend)}% {trend > 0 ? 'increase' : 'decrease'} from last month
            </Typography>
          </Box>
        )}
      </CardContent>
    </Card>
  </motion.div>
);

const Dashboard = () => {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalDonations: 0,
    activeCampaigns: 0,
    pendingApprovals: 0,
    pendingMessages: 0,
    merchandiseOrders: 0,
    totalRaised: 0,
  });
  const [donationTrends, setDonationTrends] = useState([]);
  const [campaignProgress, setCampaignProgress] = useState([]);
  const [recentUpdates, setRecentUpdates] = useState([]);

  useEffect(() => {
    fetchDashboardData();
    const subscription = setupRealtimeUpdates();
    return () => {
      if (subscription) subscription.unsubscribe();
    };
  }, []);

  const fetchDashboardData = async () => {
    try {
      // Fetch donations
      const { data: donations, count: donationCount } = await supabase
        .from('donations')
        .select('*', { count: 'exact', head: false });

      // Fetch campaigns
      const { data: campaigns, count: campaignCount } = await supabase
        .from('campaigns')
        .select('*', { count: 'exact', head: false });

      const totalRaised = donations?.reduce((sum, d) => sum + (Number(d.amount) || 0), 0) || 0;
      const activeCampaignCount = campaigns?.filter((c) => c.status === 'Active')?.length || 0;

      setStats({
        totalDonations: donationCount || 0,
        activeCampaigns: activeCampaignCount,
        pendingApprovals: 8,
        pendingMessages: 5,
        merchandiseOrders: 12,
        totalRaised: totalRaised,
      });

      // Setup trend data
      if (donations && donations.length > 0) {
        const monthlyDonations = {};
        donations.forEach((d) => {
          const date = new Date(d.created_at).toLocaleDateString('en-US', {
            month: 'short',
          });
          monthlyDonations[date] = (monthlyDonations[date] || 0) + Number(d.amount);
        });
        setDonationTrends(
          Object.entries(monthlyDonations).map(([month, amount]) => ({
            month,
            amount,
          }))
        );
      }

      // Setup campaign progress
      if (campaigns && campaigns.length > 0) {
        const topCampaigns = campaigns
          .sort((a, b) => (Number(b.raised_amount) / Number(b.amount_goal)) - (Number(a.raised_amount) / Number(a.amount_goal)))
          .slice(0, 5)
          .map((c) => ({
            name: c.name.substring(0, 20),
            target: Number(c.amount_goal),
            raised: Number(c.raised_amount),
            percentage: Math.round((Number(c.raised_amount) / Number(c.amount_goal)) * 100),
          }));
        setCampaignProgress(topCampaigns);
      }

      // Setup recent updates
      setRecentUpdates([
        { id: 1, type: 'donation', message: 'New donation received: $500', status: 'completed', time: '2 min ago' },
        { id: 2, type: 'campaign', message: 'Campaign "Help the Needy" reached 80% goal', status: 'active', time: '1 hour ago' },
        { id: 3, type: 'approval', message: 'Beneficiary request pending approval', status: 'pending', time: '3 hours ago' },
        { id: 4, type: 'message', message: 'New message from donor', status: 'unread', time: '5 hours ago' },
        { id: 5, type: 'merchandise', message: 'Merchandise order shipped', status: 'delivered', time: '1 day ago' },
      ]);
    } catch (err) {
      console.error('Dashboard error:', err);
    } finally {
      setLoading(false);
    }
  };

  const setupRealtimeUpdates = () => {
    return supabase
      .channel('dashboard-updates')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'donations' }, () => {
        fetchDashboardData();
      })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'campaigns' }, () => {
        fetchDashboardData();
      })
      .subscribe();
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress size={60} />
      </Box>
    );
  }

  const COLORS = ['#0C0C79', '#FF751F', '#4CAF50', '#FFC107', '#F44336'];

  return (
    <Box>
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.6 }}>
        <Typography variant="h4" gutterBottom fontWeight={800} color="text.primary" mb={4}>
          Dashboard Overview
        </Typography>

        {/* Stat Cards */}
        <Grid container spacing={3} mb={4}>
          <Grid item xs={12} sm={6} md={4}>
            <StatCard
              title="Total Donations"
              value={`$${(stats.totalRaised / 1000).toFixed(1)}K`}
              icon={<FavoriteIcon fontSize="large" />}
              color="#FF751F"
              subtitle={`${stats.totalDonations} donations`}
              trend={15}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={4}>
            <StatCard
              title="Active Campaigns"
              value={stats.activeCampaigns}
              icon={<CampaignIcon fontSize="large" />}
              color="#0C0C79"
              trend={8}
            />
          </Grid>
          <Grid item xs={12} sm={6} md={4}>
            <StatCard
              title="Pending Approvals"
              value={stats.pendingApprovals}
              icon={<VerifiedUserIcon fontSize="large" />}
              color="#4CAF50"
              subtitle="Needs your attention"
            />
          </Grid>
          <Grid item xs={12} sm={6} md={4}>
            <StatCard
              title="Pending Messages"
              value={stats.pendingMessages}
              icon={<MessageIcon fontSize="large" />}
              color="#FFC107"
            />
          </Grid>
          <Grid item xs={12} sm={6} md={4}>
            <StatCard
              title="Merchandise Orders"
              value={stats.merchandiseOrders}
              icon={<ShoppingCartIcon fontSize="large" />}
              color="#2196F3"
            />
          </Grid>
        </Grid>

        {/* Charts */}
        <Grid container spacing={3} mb={4}>
          {/* Donation Trends */}
          <Grid item xs={12} md={8}>
            <motion.div whileHover={{ scale: 1.02 }} transition={{ duration: 0.3 }}>
              <Card sx={{ p: 3 }}>
                <Typography variant="h6" gutterBottom fontWeight={700}>
                  Donation Trends
                </Typography>
                <Divider sx={{ mb: 3 }} />
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={donationTrends}>
                    <defs>
                      <linearGradient id="colorAmount" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#FF751F" stopOpacity={0.8} />
                        <stop offset="95%" stopColor="#FF751F" stopOpacity={0.1} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.1)" />
                    <XAxis dataKey="month" />
                    <YAxis />
                    <Tooltip contentStyle={{ borderRadius: 10, border: 'none', background: '#f5f5f5' }} />
                    <Area
                      type="monotone"
                      dataKey="amount"
                      stroke="#FF751F"
                      fillOpacity={1}
                      fill="url(#colorAmount)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </Card>
            </motion.div>
          </Grid>

          {/* Campaign Status Pie */}
          <Grid item xs={12} md={4}>
            <motion.div whileHover={{ scale: 1.02 }} transition={{ duration: 0.3 }}>
              <Card sx={{ p: 3, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                <Typography variant="h6" gutterBottom fontWeight={700} sx={{ mb: 3 }}>
                  Campaign Status
                </Typography>
                <ResponsiveContainer width="100%" height={250}>
                  <PieChart>
                    <Pie
                      data={[
                        { name: 'Active', value: stats.activeCampaigns },
                        { name: 'Completed', value: 15 },
                      ]}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={100}
                      dataKey="value"
                    >
                      {[stats.activeCampaigns, 15].map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index]} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </Card>
            </motion.div>
          </Grid>
        </Grid>

        {/* Campaign Progress */}
        <Grid item xs={12} mb={4}>
          <motion.div whileHover={{ scale: 1.02 }} transition={{ duration: 0.3 }}>
            <Card sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={700}>
                Campaign Progress — Target vs Raised
              </Typography>
              <Divider sx={{ mb: 3 }} />
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={campaignProgress}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.1)" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip contentStyle={{ borderRadius: 10, border: 'none', background: '#f5f5f5' }} />
                  <Legend />
                  <Bar dataKey="target" fill="#0C0C79" radius={[10, 10, 0, 0]} />
                  <Bar dataKey="raised" fill="#FF751F" radius={[10, 10, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </Card>
          </motion.div>
        </Grid>

        {/* Recent Updates Feed */}
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Card sx={{ p: 3 }}>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
                <Typography variant="h6" fontWeight={700}>
                  Recent Activity
                </Typography>
                <Button variant="outlined" size="small">
                  View All
                </Button>
              </Box>
              <Divider sx={{ mb: 3 }} />
              <Box>
                {recentUpdates.map((update, idx) => (
                  <motion.div
                    key={update.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: idx * 0.1 }}
                  >
                    <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                      <Box flex={1}>
                        <Typography variant="body2" fontWeight={600}>
                          {update.message}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {update.time}
                        </Typography>
                      </Box>
                      <Box display="flex" gap={1}>
                        <Chip
                          label={update.status}
                          size="small"
                          color={
                            update.status === 'completed'
                              ? 'success'
                              : update.status === 'pending'
                              ? 'warning'
                              : 'default'
                          }
                          variant="outlined"
                        />
                        {update.status === 'pending' && (
                          <>
                            <Button size="small" variant="contained" color="success">
                              Approve
                            </Button>
                            <Button size="small" variant="outlined" color="error">
                              Reject
                            </Button>
                          </>
                        )}
                      </Box>
                    </Box>
                    {idx < recentUpdates.length - 1 && <Divider sx={{ my: 2 }} />}
                  </motion.div>
                ))}
              </Box>
            </Card>
          </Grid>
        </Grid>
      </motion.div>
    </Box>
  );
};

export default Dashboard;
