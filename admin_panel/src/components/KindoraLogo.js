import React from 'react';
import { Box } from '@mui/material';

const KindoraLogo = ({ size = 100, animated = false }) => {
  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 1.5,
      }}
    >
      {/* Logo SVG */}
      <svg
        width={size}
        height={size}
        viewBox="0 0 200 200"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Heart-Hand Icon */}
        <defs>
          <linearGradient id="heartGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style={{ stopColor: '#FF751F', stopOpacity: 1 }} />
            <stop offset="100%" style={{ stopColor: '#FFB84D', stopOpacity: 1 }} />
          </linearGradient>
        </defs>

        {/* Hand shape (left side) */}
        <path
          d="M 60 80 L 50 100 Q 45 115 55 125 Q 70 135 85 125 L 90 80 Z"
          fill="url(#heartGradient)"
        />

        {/* Heart shape (right side) */}
        <path
          d="M 100 50 Q 110 40 115 40 Q 125 40 130 50 Q 135 55 130 70 Q 125 85 100 95 Q 75 85 70 70 Q 65 55 70 50 Q 75 40 85 40 Q 90 40 100 50 Z"
          fill="url(#heartGradient)"
        />
      </svg>

      {/* Text Logo */}
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          fontFamily: "'Poppins', sans-serif",
        }}
      >
        <Box
          component="span"
          sx={{
            fontSize: `${size * 0.6}px`,
            fontWeight: 800,
            color: '#0C0C79',
            lineHeight: 1,
            letterSpacing: '-0.5px',
          }}
        >
          KINDORA
        </Box>
        <Box
          component="span"
          sx={{
            fontSize: `${size * 0.2}px`,
            fontWeight: 500,
            color: '#FF751F',
            letterSpacing: '2px',
            marginTop: '-2px',
          }}
        >
          CARE
        </Box>
      </Box>
    </Box>
  );
};

export default KindoraLogo;
