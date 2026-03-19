import express, { Router } from 'express';
import multer from 'multer';
import StorageController from '../controllers/storage.controller';
import { authenticateToken } from '../middleware/auth.middleware';

const router: Router = express.Router();

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(), // Store in memory
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    // Accept image/video MIME types or check by extension
    const allowedMimes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/x-png',
      'image/webp',
      'image/gif',
      'image/bmp',
      'video/mp4',
      'video/quicktime',
      'video/webm',
      'video/x-msvideo',
      'video/x-matroska',
    ];
    
    // Check MIME type or file extension
    if (
      allowedMimes.includes(file.mimetype) ||
      /\.(jpg|jpeg|png|webp|gif|bmp|mp4|mov|webm|avi|mkv)$/i.test(file.originalname)
    ) {
      cb(null, true);
    } else {
      console.error(`[Storage] File rejected - MIME: ${file.mimetype}, Name: ${file.originalname}`);
      cb(new Error(`File type not allowed. MIME: ${file.mimetype}`));
    }
  },
});

/**
 * POST /api/storage/upload
 * Upload single image to Supabase Storage
 * Protected route - requires authentication
 */
router.post(
  '/upload',
  authenticateToken,
  upload.single('image'),
  StorageController.uploadImage
);

/**
 * POST /api/storage/upload-multiple
 * Upload multiple images to Supabase Storage
 * Protected route - requires authentication
 */
router.post(
  '/upload-multiple',
  authenticateToken,
  upload.array('images', 5), // Max 5 files
  StorageController.uploadMultiple
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
  StorageController.deleteImage
);

// Error handling for multer
router.use((error: any, req: any, res: any, next: any) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File is too large' });
    }
    return res.status(400).json({ error: error.message });
  } else if (error) {
    console.error('[Storage] Upload error:', error.message);
    return res.status(400).json({ error: error.message });
  }
  next();
});

export default router;
