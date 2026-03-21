import { Request, Response } from 'express';
import multer, { MulterError } from 'multer';
import axios from 'axios';
import Logger from '../utils/logger';

const logger = new Logger('STORAGE_CONTROLLER');

export class StorageController {
  /**
   * Get Supabase Storage API headers with SERVICE_ROLE_KEY
   */
  private static getStorageHeaders(): Record<string, string> {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    
    if (!serviceRoleKey) {
      throw new Error('SUPABASE_SERVICE_ROLE_KEY is not configured');
    }

    return {
      'Authorization': `Bearer ${serviceRoleKey}`,
      'x-upsert': 'true', // Allow overwriting existing files
    };
  }

  /**
   * Upload single image to Supabase Storage
   * POST /api/storage/upload
   */
  static async uploadImage(req: Request, res: Response): Promise<void> {
    try {
      const file = req.file;
      const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';
      const { folder = 'products' } = req.body;

      logger.info(`Upload request - File: ${file?.originalname}, Size: ${file?.size}, Folder: ${folder}`);

      if (!file) {
        logger.error('No file provided in upload request');
        res.status(400).json({ 
          success: false,
          error: 'No file provided' 
        });
        return;
      }

      // Validate file
      if (file.size === 0) {
        logger.error('File is empty');
        res.status(400).json({ 
          success: false,
          error: 'File is empty' 
        });
        return;
      }

      // Validate environment
      const supabaseUrl = process.env.SUPABASE_URL;
      const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

      if (!supabaseUrl || !serviceRoleKey) {
        logger.error('Missing Supabase configuration');
        res.status(500).json({ 
          success: false,
          error: 'Supabase configuration missing',
          details: {
            hasUrl: !!supabaseUrl,
            hasKey: !!serviceRoleKey,
          }
        });
        return;
      }

      // Create unique filename
      const timestamp = Date.now();
      const randomId = Math.random().toString(36).substring(7);
      const originalName = file.originalname
        .replace(/\s+/g, '_')  // Replace spaces with underscores
        .replace(/[^a-zA-Z0-9._-]/g, ''); // Remove special characters
      
      const fileName = `${folder}_${timestamp}_${randomId}_${originalName}`;
      const filePath = `${bucket}/${folder}/${fileName}`;

      logger.info(`Uploading file to Supabase: ${filePath}`);
      logger.info(`File details - MIME: ${file.mimetype}, Size: ${file.size} bytes`);

      // Upload to Supabase using REST API
      const uploadUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;

      logger.info(`Upload URL: ${uploadUrl}`);

      const uploadResponse = await axios.post(uploadUrl, file.buffer, {
        headers: {
          ...StorageController.getStorageHeaders(),
          'Content-Type': file.mimetype || 'application/octet-stream',
        },
      });

      logger.info(`Upload successful - Status: ${uploadResponse.status}`);

      // Generate public URL
      const publicUrl = `${supabaseUrl}/storage/v1/object/public/${filePath}`;

      logger.info(`Public URL generated: ${publicUrl}`);

      res.status(200).json({
        success: true,
        url: publicUrl,
        fileName: fileName,
        bucket: bucket,
        folder: folder,
        message: 'File uploaded successfully',
      });
    } catch (error: any) {
      logger.error(`Upload error: ${error.message}`);
      logger.error(`Error details: ${JSON.stringify(error.response?.data || error.toString())}`);

      const statusCode = error.response?.status || 500;
      const errorMessage = error.response?.data?.message || error.message || 'Upload failed';

      res.status(statusCode).json({
        success: false,
        error: errorMessage,
        details: error.response?.data,
      });
    }
  }

  /**
   * Upload multiple images
   * POST /api/storage/upload-multiple
   */
  static async uploadMultiple(req: Request, res: Response): Promise<void> {
    try {
      const files = req.files as Express.Multer.File[];
      const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';
      const { folder = 'products' } = req.body;

      if (!files || files.length === 0) {
        res.status(400).json({ 
          success: false,
          error: 'No files provided' 
        });
        return;
      }

      if (files.length > 5) {
        res.status(400).json({ 
          success: false,
          error: 'Maximum 5 files allowed' 
        });
        return;
      }

      const supabaseUrl = process.env.SUPABASE_URL;
      const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

      if (!supabaseUrl || !serviceRoleKey) {
        res.status(500).json({ 
          success: false,
          error: 'Supabase configuration missing' 
        });
        return;
      }

      const uploadPromises = files.map(async (file) => {
        const timestamp = Date.now();
        const randomId = Math.random().toString(36).substring(7);
        const originalName = file.originalname
          .replace(/\s+/g, '_')
          .replace(/[^a-zA-Z0-9._-]/g, '');
        
        const fileName = `${folder}_${timestamp}_${randomId}_${originalName}`;
        const filePath = `${bucket}/${folder}/${fileName}`;

        const uploadUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;

        try {
          await axios.post(uploadUrl, file.buffer, {
            headers: {
              ...StorageController.getStorageHeaders(),
              'Content-Type': file.mimetype || 'application/octet-stream',
            },
          });

          const publicUrl = `${supabaseUrl}/storage/v1/object/public/${filePath}`;

          return {
            fileName: fileName,
            url: publicUrl,
            success: true,
          };
        } catch (error: any) {
          logger.error(`Upload failed for ${fileName}: ${error.message}`);
          throw error;
        }
      });

      const results = await Promise.all(uploadPromises);

      logger.info(`Uploaded ${results.length} files successfully`);

      res.status(200).json({
        success: true,
        files: results,
        count: results.length,
        message: `${results.length} files uploaded successfully`,
      });
    } catch (error: any) {
      logger.error(`Batch upload error: ${error.message}`);
      res.status(500).json({ 
        success: false,
        error: `Upload failed: ${error.message}` 
      });
    }
  }

  /**
   * Delete image from Supabase Storage
   * DELETE /api/storage/delete
   */
  static async deleteImage(req: Request, res: Response): Promise<void> {
    try {
      const { fileName, bucket: customBucket } = req.body;
      const bucket = customBucket || process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';

      if (!fileName) {
        res.status(400).json({ 
          success: false,
          error: 'fileName is required' 
        });
        return;
      }

      const supabaseUrl = process.env.SUPABASE_URL;

      if (!supabaseUrl) {
        res.status(500).json({ 
          success: false,
          error: 'Supabase configuration missing' 
        });
        return;
      }

      logger.info(`Deleting file: ${fileName} from bucket: ${bucket}`);

      const filePath = `${bucket}/${fileName}`;
      const deleteUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;

      try {
        await axios.delete(deleteUrl, {
          headers: StorageController.getStorageHeaders(),
        });

        logger.info(`File deleted successfully: ${fileName}`);

        res.status(200).json({
          success: true,
          message: 'File deleted successfully',
          fileName: fileName,
        });
      } catch (error: any) {
        logger.error(`Delete failed: ${error.message}`);
        res.status(error.response?.status || 500).json({
          success: false,
          error: `Delete failed: ${error.message}`,
        });
      }
    } catch (error: any) {
      logger.error(`Delete error: ${error.message}`);
      res.status(500).json({ 
        success: false,
        error: `Delete failed: ${error.message}` 
      });
    }
  }
}

export default StorageController;
