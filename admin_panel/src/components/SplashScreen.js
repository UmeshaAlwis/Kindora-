import React, { useEffect } from 'react';
import { motion } from 'framer-motion';
import { Box } from '@mui/material';
import KindoraLogo from './KindoraLogo';

const SplashScreen = ({ onComplete }) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      onComplete();
    }, 3000);

    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <Box
      sx={{
        width: '100%',
        height: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #0C0C79 0%, #4B4BA3 100%)',
        overflow: 'hidden',
      }}
    >
      <motion.div
        initial={{ opacity: 1, scale: 1 }}
        animate={{ opacity: 0, scale: 0.9 }}
        transition={{ duration: 2.5, delay: 0.5 }}
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          width: '100%',
          height: '100%',
        }}
      >
        <motion.div
          initial={{ scale: 0.5, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.8, type: 'spring', stiffness: 100 }}
        >
          <KindoraLogo size={120} />
          <Box
            sx={{
              fontSize: '12px',
              color: 'rgba(255,255,255,0.6)',
              textAlign: 'center',
              mt: 3,
              letterSpacing: '3px',
              fontFamily: "'Poppins', sans-serif",
              fontWeight: 500,
            }}
          >
            ADMIN CONTROL
          </Box>
        </motion.div>
      </motion.div>
    </Box>
  );
};

export default SplashScreen;
