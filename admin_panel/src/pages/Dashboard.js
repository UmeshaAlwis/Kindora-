import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  CircularProgress,
} from '@mui/material';
import PeopleIcon from '@mui/icons-material/People';
import VolunteerActivismIcon from '@mui/icons-material/VolunteerActivism';
import MonetizationOnIcon from '@mui/icons-material/MonetizationOn';
import CampaignIcon from '@mui/icons-material/Campaign';
import { Line, Doughnut, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

const StatCard = ({ title, value, icon, color, subtitle }) => (
  <Card
    sx={{
      height: '100%',
      background: `linear-gradient(135deg, ${color}15 0%, ${color}08 100%)`,
      border: `1px solid ${color}20`,
    }}
  >
    <CardContent sx={{ p: 3 }}>
      <Box display="flex" justifyContent="space-between" alignItems="flex-start">
        <Box>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            {title}
          </Typography>
          <Typography variant="h4" fontWeight={700}>
            {value}
          </Typography>
          {subtitle && (
            <Typography variant="caption" color="text.secondary">
              {subtitle}
            </Typography>
          )}
        </Box>
        <Box
          sx={{
            p: 1.5,
            borderRadius: 3,
            backgroundColor: `${color}18`,
            color: color,
            display: 'flex',
          }}
        >
          {icon}
        </Box>
      </Box>
    </CardContent>
  </Card>
);

const Dashboard = () => {
  const [stats, setStats] = useState({
    users: 0,
    charities: 0,
    donations: 0,
    campaigns: 0,
    totalDonationAmount: 0,
  });
  const [donationTrends, setDonationTrends] = useState([]);
  const [campaignProgress, setCampaignProgress] = useState([]);
  const [userRoles, setUserRoles] = useState({ admin: 0, donor: 0, charity: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const [usersRes, charitiesRes, donationsRes, campaignsRes, profilesRes] =
        await Promise.all([
          supabase.from('profiles').select('id', { count: 'exact', head: true }),
          supabase.from('charities').select('id', { count: 'exact', head: true }),
          supabase.from('donations').select('*'),
          supabase.from('campaigns').select('*'),
          supabase.from('profiles').select('role'),
        ]);

      const donations = donationsRes.data || [];
      const campaigns = campaignsRes.data || [];
      const profiles = profilesRes.data || [];

      const totalAmount = donations.reduce((sum, d) => sum + (Number(d.amount) || 0), 0);

      setStats({
        users: usersRes.count || 0,
        charities: charitiesRes.count || 0,
        donations: donations.length,
        campaigns: campaigns.length,
        totalDonationAmount: totalAmount,
      });

      // User roles distribution
      const roles = { admin: 0, donor: 0, charity: 0 };
      profiles.forEach((p) => {
        if (roles.hasOwnProperty(p.role)) roles[p.role]++;
      });
      setUserRoles(roles);

      // Donation trends by month
      const monthlyDonations = {};
      donations.forEach((d) => {
        const date = new Date(d.created_at);
        const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
        if (!monthlyDonations[key]) monthlyDonations[key] = 0;
        monthlyDonations[key] += Number(d.amount) || 0;
      });

      const sortedMonths = Object.keys(monthlyDonations).sort();
      const last6Months = sortedMonths.slice(-6);
      setDonationTrends(
        last6Months.map((m) => ({
          month: m,
          amount: monthlyDonations[m],
        }))
      );

      // Campaign progress (top 6)
      const topCampaigns = campaigns
        .filter((c) => c.target_amount > 0)
        .sort((a, b) => b.raised_amount - a.raised_amount)
        .slice(0, 6);
      setCampaignProgress(topCampaigns);
    } catch (err) {
      console.error('Dashboard fetch error:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
        <CircularProgress />
      </Box>
    );
  }

  const donationTrendData = {
    labels: donationTrends.map((d) => {
      const [y, m] = d.month.split('-');
      return new Date(y, m - 1).toLocaleString('default', {
        month: 'short',
        year: '2-digit',
      });
    }),
    datasets: [
      {
        label: 'Donations (LKR)',
        data: donationTrends.map((d) => d.amount),
        borderColor: '#6C63FF',
        backgroundColor: 'rgba(108, 99, 255, 0.1)',
        fill: true,
        tension: 0.4,
        pointRadius: 5,
        pointBackgroundColor: '#6C63FF',
      },
    ],
  };

  const userRoleData = {
    labels: ['Admins', 'Donors', 'Charities'],
    datasets: [
      {
        data: [userRoles.admin, userRoles.donor, userRoles.charity],
        backgroundColor: ['#6C63FF', '#FF6584', '#4CAF50'],
        borderWidth: 0,
        hoverOffset: 8,
      },
    ],
  };

  const campaignBarData = {
    labels: campaignProgress.map((c) =>
      c.title.length > 15 ? c.title.substring(0, 15) + '...' : c.title
    ),
    datasets: [
      {
        label: 'Target',
        data: campaignProgress.map((c) => Number(c.target_amount)),
        backgroundColor: 'rgba(108, 99, 255, 0.3)',
        borderColor: '#6C63FF',
        borderWidth: 1,
        borderRadius: 6,
      },
      {
        label: 'Raised',
        data: campaignProgress.map((c) => Number(c.raised_amount)),
        backgroundColor: 'rgba(76, 175, 80, 0.5)',
        borderColor: '#4CAF50',
        borderWidth: 1,
        borderRadius: 6,
      },
    ],
  };

  return (
    <Box>
      <Typography variant="h5" gutterBottom fontWeight={700}>
        Dashboard Overview
      </Typography>

      {/* Stat Cards */}
      <Grid container spacing={3} mb={4}>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Total Users"
            value={stats.users}
            icon={<PeopleIcon />}
            color="#6C63FF"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Charities"
            value={stats.charities}
            icon={<VolunteerActivismIcon />}
            color="#4CAF50"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Donations"
            value={stats.donations}
            icon={<MonetizationOnIcon />}
            color="#FF6584"
            subtitle={`LKR ${stats.totalDonationAmount.toLocaleString()}`}
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 3 }}>
          <StatCard
            title="Campaigns"
            value={stats.campaigns}
            icon={<CampaignIcon />}
            color="#FFC107"
          />
        </Grid>
      </Grid>

      {/* Charts */}
      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 8 }}>
          <Card sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              Donation Trends
            </Typography>
            <Box sx={{ height: 300 }}>
              <Line
                data={donationTrendData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: { legend: { display: false } },
                  scales: {
                    y: {
                      beginAtZero: true,
                      grid: { color: 'rgba(0,0,0,0.05)' },
                    },
                    x: { grid: { display: false } },
                  },
                }}
              />
            </Box>
          </Card>
        </Grid>
        <Grid size={{ xs: 12, md: 4 }}>
          <Card sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              User Roles
            </Typography>
            <Box sx={{ height: 300, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Doughnut
                data={userRoleData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  cutout: '65%',
                  plugins: {
                    legend: { position: 'bottom' },
                  },
                }}
              />
            </Box>
          </Card>
        </Grid>
        <Grid size={{ xs: 12 }}>
          <Card sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Campaign Progress — Target vs Raised
            </Typography>
            <Box sx={{ height: 350 }}>
              <Bar
                data={campaignBarData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: { legend: { position: 'top' } },
                  scales: {
                    y: {
                      beginAtZero: true,
                      grid: { color: 'rgba(0,0,0,0.05)' },
                    },
                    x: { grid: { display: false } },
                  },
                }}
              />
            </Box>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
