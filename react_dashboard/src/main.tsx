import React from 'react';
import ReactDOM from 'react-dom/client';
import { Toaster } from 'react-hot-toast';
import App from './App';
import './styles.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
    <Toaster
      position="top-right"
      toastOptions={{
        duration: 4000,
        style: {
          background: '#ffffff',
          border: '1px solid #e2e4ec',
          boxShadow: '0 4px 24px rgba(12, 12, 121, 0.08)',
          color: '#1a1f36',
          borderRadius: '14px',
          fontFamily: '"Plus Jakarta Sans", system-ui, sans-serif',
        },
        success: {
          iconTheme: { primary: '#0c0c79', secondary: '#fff' },
        },
        error: {
          iconTheme: { primary: '#c62828', secondary: '#fff' },
        },
      }}
    />
  </React.StrictMode>
);

