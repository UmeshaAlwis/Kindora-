import { Link, useLocation } from 'react-router-dom';
import { BarChart3, Users, Heart, Zap, LogOut } from 'lucide-react';
import { useAuthStore } from '../store/auth.store';

export default function Sidebar() {
  const location = useLocation();
  const { logout } = useAuthStore();

  const isActive = (path: string) => location.pathname === path;

  return (
    <aside className="w-64 bg-white border-r border-gray-200 min-h-screen flex flex-col">
      <div className="p-6">
        <h1 className="text-2xl font-bold text-blue-600">Kindora</h1>
        <p className="text-sm text-gray-500">Admin Dashboard</p>
      </div>

      <nav className="flex-1 px-4 space-y-2">
        <Link
          to="/dashboard"
          className={`flex items-center gap-3 px-4 py-2 rounded-lg transition ${
            isActive('/dashboard')
              ? 'bg-blue-100 text-blue-600'
              : 'text-gray-700 hover:bg-gray-100'
          }`}
        >
          <BarChart3 size={20} />
          <span>Dashboard</span>
        </Link>

        <Link
          to="/users"
          className={`flex items-center gap-3 px-4 py-2 rounded-lg transition ${
            isActive('/users')
              ? 'bg-blue-100 text-blue-600'
              : 'text-gray-700 hover:bg-gray-100'
          }`}
        >
          <Users size={20} />
          <span>Users</span>
        </Link>

        <Link
          to="/charities"
          className={`flex items-center gap-3 px-4 py-2 rounded-lg transition ${
            isActive('/charities')
              ? 'bg-blue-100 text-blue-600'
              : 'text-gray-700 hover:bg-gray-100'
          }`}
        >
          <Heart size={20} />
          <span>Charities</span>
        </Link>

        <Link
          to="/campaigns"
          className={`flex items-center gap-3 px-4 py-2 rounded-lg transition ${
            isActive('/campaigns')
              ? 'bg-blue-100 text-blue-600'
              : 'text-gray-700 hover:bg-gray-100'
          }`}
        >
          <Zap size={20} />
          <span>Campaigns</span>
        </Link>
      </nav>

      <div className="p-4 border-t border-gray-200">
        <button
          onClick={() => {
            logout();
            window.location.href = '/login';
          }}
          className="w-full flex items-center gap-3 px-4 py-2 rounded-lg text-gray-700 hover:bg-red-50 hover:text-red-600 transition"
        >
          <LogOut size={20} />
          <span>Logout</span>
        </button>
      </div>
    </aside>
  );
}
