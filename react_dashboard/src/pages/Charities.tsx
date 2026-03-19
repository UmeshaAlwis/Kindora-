import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { ApiClient } from '../services/api';

const apiClient = new ApiClient();

interface Charity {
  id: string;
  name: string;
  email: string;
  status: string;
  created_at: string;
}

export default function Charities() {
  const [charities, setCharities] = useState<Charity[]>([]);
  const [loading, setLoading] = useState(true);
  const [status, setStatus] = useState<string>('');

  useEffect(() => {
    const fetchCharities = async () => {
      try {
        setLoading(true);
        const response = await apiClient.getCharities(1, status || undefined);
        setCharities(response.data.data || []);
      } catch (error) {
        console.error('Failed to fetch charities:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchCharities();
  }, [status]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'verified':
        return 'bg-green-100 text-green-700';
      case 'pending':
        return 'bg-yellow-100 text-yellow-700';
      case 'rejected':
        return 'bg-red-100 text-red-700';
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  return (
    <Layout>
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Charities</h1>

        <div className="mb-6 flex gap-4">
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
          >
            <option value="">All Status</option>
            <option value="pending">Pending</option>
            <option value="verified">Verified</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>

        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Name</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Email</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Registered</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {loading ? (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    Loading charities...
                  </td>
                </tr>
              ) : charities.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    No charities found
                  </td>
                </tr>
              ) : (
                charities.map((charity) => (
                  <tr key={charity.id} className="hover:bg-gray-50 transition">
                    <td className="px-6 py-4 text-sm text-gray-900">{charity.name}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{charity.email}</td>
                    <td className="px-6 py-4 text-sm">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(charity.status)}`}>
                        {charity.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {new Date(charity.created_at).toLocaleDateString()}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
}
