import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { initializeFirebase, getFirebaseAuth } from './services/firebase.service';
import { initializeDatabase } from './services/database.service';
import { SupabaseClient } from './services/supabase.service';
import { validateConfig } from './config';
import Logger from './utils/logger';
import { KindoraError } from './utils/errors';

// Route imports
import authRoutes from './routes/auth.routes';
import campaignRoutes from './routes/campaign.routes';
import donationRoutes from './routes/donation.routes';
import beneficiaryDonationRoutes from './routes/beneficiary-donation.routes';
import charityRoutes from './routes/charity.routes';
import userRoutes from './routes/user.routes';
import messageRoutes from './routes/message.routes';
import paymentRoutes from './routes/payment.routes';
import chatRoutes from './routes/chat.routes';
import walletRoutes from './routes/wallet.routes';
import storageRoutes from './routes/storage.routes';
import beneficiaryRoutes from './routes/beneficiary.routes';
import feedRoutes from './routes/feed.routes';
import notificationRoutes from './routes/notification.routes';
import { BeneficiaryDonationService } from './services/beneficiary-donation.service';

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

// Diagnostic Endpoint - Check all connections
app.get('/diagnostic', async (req: Request, res: Response) => {
  try {
    const diagnostics: any = {
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV,
      checks: {
        firebase: 'pending',
        supabase: 'pending',
        storage: 'pending',
      },
    };

    // Check Firebase
    try {
      const firebaseAuth = getFirebaseAuth();
      const testUser = await firebaseAuth.getUser('test-uid').catch(() => null);
      diagnostics.checks.firebase = 'connected';
      diagnostics.firebase = {
        status: 'connected',
        projectId: process.env.FIREBASE_PROJECT_ID,
        message: 'Firebase Admin SDK initialized successfully',
      };
    } catch (error: any) {
      diagnostics.checks.firebase = 'error';
      diagnostics.firebase = {
        status: 'error',
        message: error.message,
      };
    }

    // Check Supabase REST API
    try {
      const supabase = new SupabaseClient();
      const testData = await supabase.select('users', { limit: 1 });
      diagnostics.checks.supabase = 'connected';
      diagnostics.supabase = {
        status: 'connected',
        url: process.env.SUPABASE_URL,
        message: `Supabase REST API connected. Found ${testData ? 'users table' : 'no data'}`,
      };
    } catch (error: any) {
      diagnostics.checks.supabase = 'error';
      diagnostics.supabase = {
        status: 'error',
        url: process.env.SUPABASE_URL,
        message: error.message,
      };
    }

    // Check Environment Variables
    diagnostics.environment_vars = {
      SUPABASE_URL: process.env.SUPABASE_URL ? '✓ Set' : '✗ Missing',
      SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY ? '✓ Set' : '✗ Missing',
      FIREBASE_PROJECT_ID: process.env.FIREBASE_PROJECT_ID ? '✓ Set' : '✗ Missing',
      FIREBASE_PRIVATE_KEY: process.env.FIREBASE_PRIVATE_KEY ? '✓ Set' : '✗ Missing',
      FIREBASE_CLIENT_EMAIL: process.env.FIREBASE_CLIENT_EMAIL ? '✓ Set' : '✗ Missing',
      DATABASE_URL: process.env.DATABASE_URL ? '✓ Set' : '✗ Missing',
      JWT_SECRET: process.env.JWT_SECRET ? '✓ Set' : '✗ Missing',
    };

    const allConnected = Object.values(diagnostics.checks).every(v => v === 'connected');
    res.json({
      success: allConnected,
      overall_status: allConnected ? 'healthy' : 'degraded',
      ...diagnostics,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: 'Diagnostic check failed',
      message: error.message,
    });
  }
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
      beneficiary_donations: '/api/beneficiary-donations',
      charities: '/api/charities',
      users: '/api/users',
      messages: '/api/messages',
      payments: '/api/payments',
      chat: '/api/chat',
      feed: '/api/feed',
      storage: '/api/storage',
      beneficiary: '/api/beneficiary',
      notifications: '/api/notifications',
    },
  });
});

apiRouter.use('/auth', authRoutes);
apiRouter.use('/campaigns', campaignRoutes);
apiRouter.use('/donations', donationRoutes);
apiRouter.use('/beneficiary-donations', beneficiaryDonationRoutes);
apiRouter.use('/wallet', walletRoutes);
apiRouter.use('/charities', charityRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/messages', messageRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/chat', chatRoutes);
apiRouter.use('/feed', feedRoutes);
apiRouter.use('/storage', storageRoutes);
apiRouter.use('/beneficiary', beneficiaryRoutes);
apiRouter.use('/notifications', notificationRoutes);

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

    // Recurring beneficiary donation scheduler (wallet-based only).
    // Runs every 60 seconds and processes due installments.
    let isRecurringJobRunning = false;
    setInterval(async () => {
      if (isRecurringJobRunning) return;
      isRecurringJobRunning = true;
      try {
        await BeneficiaryDonationService.processDueRecurringBeneficiaryDonations();
      } catch (error) {
        logger.error('Recurring beneficiary donation job failed:', error);
      } finally {
        isRecurringJobRunning = false;
      }
    }, 60_000);

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
