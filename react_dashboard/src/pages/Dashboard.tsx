import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { ApiClient } from '../services/api';

const apiClient = new ApiClient();

interface DashboardStats {
  totalUsers: number;
  totalCharities: number;
  totalCampaigns: number;
  pendingVerifications: number;
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalCharities: 0,
    totalCampaigns: 0,
    pendingVerifications: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [usersRes, charitiesRes, campaignsRes] = await Promise.all([
          apiClient.getUsers(1, 1),
          apiClient.getCharities(1),
          apiClient.getCampaigns(1),
        ]);

        setStats({
          totalUsers: usersRes.data.total || 0,
          totalCharities: charitiesRes.data.total || 0,
          totalCampaigns: campaignsRes.data.total || 0,
          pendingVerifications: charitiesRes.data.data?.filter((c: any) => c.status === 'pending').length || 0,
        });
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  const StatCard = ({ title, value }: { title: string; value: number }) => (
    <div className="bg-white rounded-lg shadow p-6">
      <p className="text-gray-600 text-sm mb-2">{title}</p>
      <p className="text-3xl font-bold text-gray-900">{loading ? '-' : value}</p>
    </div>
  );

  return (
    <Layout>
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard title="Total Users" value={stats.totalUsers} />
          <StatCard title="Total Charities" value={stats.totalCharities} />
          <StatCard title="Total Campaigns" value={stats.totalCampaigns} />
          <StatCard title="Pending Verifications" value={stats.pendingVerifications} />
        </div>

        <div className="mt-8 bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h2>
          <p className="text-gray-600">No recent activity to display.</p>
        </div>
      </div>
    </Layout>
  );
}
