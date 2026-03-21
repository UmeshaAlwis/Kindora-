import express, { Router, Request, Response, NextFunction } from 'express';
import multer from 'multer';
import StorageController from '../controllers/storage.controller';
import { authenticateToken } from '../middleware/auth.middleware';
import Logger from '../utils/logger';

const logger = new Logger('STORAGE_ROUTES');

const router: Router = express.Router();

// Configure multer for in-memory file storage
const upload = multer({
  storage: multer.memoryStorage(), // Store files in RAM
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    // List of allowed MIME types
    const allowedMimes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/x-png',
      'image/webp',
      'image/gif',
      'image/bmp',
      'image/tiff',
      'image/svg+xml',
      'video/mp4',
      'video/quicktime',
      'video/webm',
      'video/x-msvideo',
      'video/x-matroska',
    ];

    // Check MIME type or file extension
    const isAllowedMime = allowedMimes.includes(file.mimetype);
    const isAllowedExtension = /\.(jpg|jpeg|png|gif|bmp|webp|mp4|mov|webm|avi|mkv)$/i.test(file.originalname);

    if (isAllowedMime || isAllowedExtension) {
      logger.info(`File accepted: ${file.originalname} (${file.mimetype})`);
      cb(null, true);
    } else {
      logger.error(`File rejected - MIME: ${file.mimetype}, Name: ${file.originalname}`);
      cb(new Error(`File type not allowed. MIME: ${file.mimetype}, Name: ${file.originalname}`));
    }
  },
});

/**
 * POST /api/storage/upload
 * Upload single image/video to Supabase Storage
 * Protected route - requires authentication
 * Body: { folder?: string (default: 'products') }
 * File: 'image' field in multipart form
 */
router.post(
  '/upload',
  authenticateToken,
  upload.single('image'),
  (req: Request, res: Response, next: NextFunction) => {
    StorageController.uploadImage(req, res);
  }
);

/**
 * POST /api/storage/upload-multiple
 * Upload multiple images/videos to Supabase Storage
 * Protected route - requires authentication
 * Max: 5 files
 * Body: { folder?: string (default: 'products') }
 * Files: 'images' field in multipart form
 */
router.post(
  '/upload-multiple',
  authenticateToken,
  upload.array('images', 5), // Max 5 files
  (req: Request, res: Response, next: NextFunction) => {
    StorageController.uploadMultiple(req, res);
  }
);

/**
 * DELETE /api/storage/delete
 * Delete image from Supabase Storage
 * Protected route - requires authentication
 * Body: { fileName: string, bucket?: string }
 */
router.delete(
  '/delete',
  authenticateToken,
  (req: Request, res: Response, next: NextFunction) => {
    StorageController.deleteImage(req, res);
  }
);

/**
 * Error handling for multer
 */
router.use((error: any, req: Request, res: Response, next: NextFunction) => {
  if (error instanceof multer.MulterError) {
    logger.error(`Multer error: ${error.code} - ${error.message}`);

    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ 
        success: false,
        error: 'File is too large. Maximum size: 10MB',
        code: 'FILE_TOO_LARGE',
      });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ 
        success: false,
        error: 'Too many files. Maximum: 5 files',
        code: 'TOO_MANY_FILES',
      });
    }
    return res.status(400).json({ 
      success: false,
      error: error.message,
      code: error.code,
    });
  } else if (error) {
    logger.error(`Upload error: ${error.message}`);
    return res.status(400).json({ 
      success: false,
      error: error.message,
    });
  }
  next();
});

export default router;
