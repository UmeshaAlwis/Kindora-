import { Request, Response } from 'express';
import axios from 'axios';
import Logger from '../utils/logger';

const logger = new Logger('STORAGE_CONTROLLER');

export class StorageController {
  /**
   * Get Supabase Storage API headers with SERVICE_ROLE_KEY (bypasses RLS)
   */
  private static getStorageHeaders(): Record<string, string> {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
    return {
      'Authorization': `Bearer ${serviceRoleKey}`,
      'apikey': serviceRoleKey,
    };
  }

  /**
   * Upload image to Supabase Storage with SERVICE_ROLE_KEY (bypasses RLS)
   */
  static async uploadImage(req: Request, res: Response): Promise<void> {
    try {
      const file = req.file;
      const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';
      const { folder = 'campaigns' } = req.body;

      if (!file) {
        logger.error('No file provided in upload request');
        res.status(400).json({ error: 'No file provided' });
        return;
      }

      // Validate environment
      const supabaseUrl = process.env.SUPABASE_URL;
      const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

      if (!supabaseUrl || !serviceRoleKey) {
        logger.error('Missing Supabase configuration');
        res.status(500).json({ error: 'Supabase configuration missing' });
        return;
      }

      // Create unique filename with timestamp
      const timestamp = Date.now();
      const originalName = file.originalname.replace(/\s+/g, '_');
      const fileName = `${folder}/${folder}_${timestamp}_${originalName}`;
      const filePath = `${bucket}/${fileName}`;

      logger.info(`Uploading file: ${filePath}`);

      // Upload using SERVICE_ROLE_KEY (bypasses RLS policies)
      const uploadUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;
      
      const uploadResponse = await axios.post(uploadUrl, file.buffer, {
        headers: {
          ...StorageController.getStorageHeaders(),
          'Content-Type': file.mimetype,
        },
      });

      // Generate public URL
      const publicUrl = `${supabaseUrl}/storage/v1/object/public/${filePath}`;

      logger.info(`File uploaded successfully: ${publicUrl}`);

      res.status(200).json({
        success: true,
        url: publicUrl,
        fileName,
        bucket,
      });
    } catch (error: any) {
      logger.error(`Upload error: ${error.message}`);
      const errorMessage = error.response?.data?.message || error.message || 'Unknown error';
      res.status(error.response?.status || 500).json({ 
        error: `Upload failed: ${errorMessage}`,
        details: error.response?.data,
      });
    }
  }

  /**
   * Upload multiple images
   */
  static async uploadMultiple(req: Request, res: Response): Promise<void> {
    try {
      const files = req.files;
      const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';
      const { folder = 'campaigns' } = req.body;

      if (!files || !Array.isArray(files) || files.length === 0) {
        res.status(400).json({ error: 'No files provided' });
        return;
      }

      const supabaseUrl = process.env.SUPABASE_URL;
      const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

      if (!supabaseUrl || !serviceRoleKey) {
        res.status(500).json({ error: 'Supabase configuration missing' });
        return;
      }

      const uploadPromises = (files as any[]).map(async (file: any) => {
        const timestamp = Date.now();
        const originalName = file.originalname.replace(/\s+/g, '_');
        const fileName = `${folder}/${folder}_${timestamp}_${originalName}`;
        const filePath = `${bucket}/${fileName}`;

        const uploadUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;

        try {
          const uploadResponse = await axios.post(uploadUrl, file.buffer, {
            headers: {
              ...StorageController.getStorageHeaders(),
              'Content-Type': file.mimetype,
            },
          });

          const publicUrl = `${supabaseUrl}/storage/v1/object/public/${filePath}`;

          return { fileName, url: publicUrl, success: true };
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
      });
    } catch (error: any) {
      logger.error(`Batch upload error: ${error.message}`);
      res.status(500).json({ error: `Upload failed: ${error.message}` });
    }
  }

  /**
   * Delete image from Supabase Storage
   */
  static async deleteImage(req: Request, res: Response): Promise<void> {
    try {
      const { fileName } = req.body;
      const bucket = process.env.SUPABASE_STORAGE_BUCKET || 'Kindora';

      if (!fileName) {
        res.status(400).json({ error: 'fileName is required' });
        return;
      }

      const supabaseUrl = process.env.SUPABASE_URL;

      if (!supabaseUrl) {
        res.status(500).json({ error: 'Supabase configuration missing' });
        return;
      }

      logger.info(`Deleting file: ${fileName} from bucket: ${bucket}`);

      const filePath = `${bucket}/${fileName}`;
      const deleteUrl = `${supabaseUrl}/storage/v1/object/${filePath}`;

      try {
        const deleteResponse = await axios.delete(deleteUrl, {
          headers: StorageController.getStorageHeaders(),
        });

        logger.info(`File deleted successfully: ${fileName}`);

        res.status(200).json({
          success: true,
          message: 'File deleted successfully',
        });
      } catch (error: any) {
        logger.error(`Delete failed: ${error.message}`);
        res.status(error.response?.status || 500).json({ 
          error: `Delete failed: ${error.message}`,
        });
      }
    } catch (error: any) {
      logger.error(`Delete error: ${error.message}`);
      res.status(500).json({ error: `Delete failed: ${error.message}` });
    }
  }
}

export default StorageController;
