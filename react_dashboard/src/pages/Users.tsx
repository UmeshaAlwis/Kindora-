import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { ApiClient } from '../services/api';

const apiClient = new ApiClient();

interface User {
  id: string;
  email: string;
  full_name: string;
  role: string;
  created_at: string;
}

export default function Users() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true);
        const response = await apiClient.getUsers(page, 20);
        setUsers(response.data.data || []);
      } catch (error) {
        console.error('Failed to fetch users:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchUsers();
  }, [page]);

  return (
    <Layout>
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Users</h1>

        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Name</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Email</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Role</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">Joined</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {loading ? (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    Loading users...
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-4 text-center text-gray-500">
                    No users found
                  </td>
                </tr>
              ) : (
                users.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50 transition">
                    <td className="px-6 py-4 text-sm text-gray-900">{user.full_name}</td>
                    <td className="px-6 py-4 text-sm text-gray-600">{user.email}</td>
                    <td className="px-6 py-4 text-sm">
                      <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-medium">
                        {user.role}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">
                      {new Date(user.created_at).toLocaleDateString()}
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
