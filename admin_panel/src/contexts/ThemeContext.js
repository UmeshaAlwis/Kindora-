import React, { createContext, useContext, useState, useEffect } from 'react';

const ThemeContext = createContext();

export const useThemeMode = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useThemeMode must be used within ThemeProvider');
  }
  return context;
};

export const ThemeContextProvider = ({ children }) => {
  const [isDarkMode, setIsDarkMode] = useState(() => {
    try {
      const saved = localStorage.getItem('theme-mode');
      return saved ? JSON.parse(saved) : false;
    } catch (error) {
      console.warn('Theme storage error:', error);
      return false;
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('theme-mode', JSON.stringify(isDarkMode));
    } catch (error) {
      console.warn('Failed to save theme:', error);
    }
  }, [isDarkMode]);

  const toggleTheme = () => {
    setIsDarkMode(prev => !prev);
  };

  return (
    <ThemeContext.Provider value={{ isDarkMode, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};
