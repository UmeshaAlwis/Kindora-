import { create } from 'zustand';

interface User {
  id: string;
  email: string;
  full_name: string;
  role: string;
}

interface AuthStore {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (user: User, token: string) => void;
  logout: () => void;
  setUser: (user: User) => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: (() => {
    const raw = localStorage.getItem('admin_user');
    if (!raw) return null;
    try {
      return JSON.parse(raw) as User;
    } catch (_) {
      return null;
    }
  })(),
  token: localStorage.getItem('access_token'),
  isAuthenticated: !!localStorage.getItem('access_token'),

  login: (user, token) => {
    localStorage.setItem('access_token', token);
    localStorage.setItem('admin_user', JSON.stringify(user));
    set({ user, token, isAuthenticated: true });
  },

  logout: () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('admin_user');
    set({ user: null, token: null, isAuthenticated: false });
  },

  setUser: (user) => {
    set({ user });
  },
}));
