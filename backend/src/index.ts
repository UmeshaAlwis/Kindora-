import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { initializeFirebase } from './services/firebase.service';
import { initializeDatabase } from './services/database.service';
import { validateConfig } from './config';
import Logger from './utils/logger';
import { KindoraError } from './utils/errors';

// Route imports
import authRoutes from './routes/auth.routes';
import campaignRoutes from './routes/campaign.routes';
import donationRoutes from './routes/donation.routes';
import charityRoutes from './routes/charity.routes';
import userRoutes from './routes/user.routes';
import messageRoutes from './routes/message.routes';
import paymentRoutes from './routes/payment.routes';
import chatRoutes from './routes/chat.routes';

// Load environment variables
dotenv.config();
validateConfig();

const app: Express = express();
const PORT = process.env.PORT || 5000;
const logger = new Logger('SERVER');

// Security Middleware
app.use(helmet());

// CORS Configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production'
    ? ['https://kindora.com', 'https://admin.kindora.com']
    : '*',
  credentials: true,
}));

// Body Parser Middleware (MUST come before logging middleware that accesses body)
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Request Logging Middleware - Log all incoming requests
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`\n[${new Date().toISOString()}] 🔵 INCOMING: ${req.method} ${req.path}`);
  console.log('Body:', JSON.stringify(req.body));
  
  // Log response when sent
  const originalSend = res.send;
  res.send = function(data: any) {
    console.log(`[${new Date().toISOString()}] 🟢 RESPONSE: ${req.method} ${req.path} - ${res.statusCode}`);
    return originalSend.call(this, data);
  };
  next();
});

// Logger info middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// Health Check Endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
  });
});

// API Routes
const apiRouter = express.Router();

// API Info endpoint
apiRouter.get('/', (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'Kindora Charity Platform API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      campaigns: '/api/campaigns',
      donations: '/api/donations',
      charities: '/api/charities',
      users: '/api/users',
      messages: '/api/messages',
      payments: '/api/payments',
      chat: '/api/chat',
    },
  });
});

apiRouter.use('/auth', authRoutes);
apiRouter.use('/campaigns', campaignRoutes);
apiRouter.use('/donations', donationRoutes);
apiRouter.use('/charities', charityRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/messages', messageRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/chat', chatRoutes);

app.use('/api', apiRouter);

// 404 Handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    path: req.path,
    method: req.method,
  });
});

// Global Error Handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  logger.error('Request error:', {
    message: err.message,
    path: req.path,
    method: req.method,
    status: err.statusCode || 500,
  });

  const statusCode = err.statusCode || err.status || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { details: err.details }),
  });
});

// Initialize Services and Start Server
async function startServer() {
  try {
    // Initialize Firebase
    await initializeFirebase();
    logger.info('✓ Firebase initialized');

    // Initialize Database
    await initializeDatabase();
    logger.info('✓ Database initialized');

    // Start listening
    const server = app.listen(PORT, () => {
      logger.info(`
╔════════════════════════════════════╗
║  Kindora Backend Server Started    ║
║  Port: ${String(PORT).padEnd(26)}║
║  Environment: ${String(process.env.NODE_ENV || 'development').padEnd(20)}║
║  API: http://localhost:${PORT}/api      ║
╚════════════════════════════════════╝
      `);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('SIGTERM signal received: closing HTTP server');
      server.close(() => {
        logger.info('HTTP server closed');
        process.exit(0);
      });
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

export default app;
