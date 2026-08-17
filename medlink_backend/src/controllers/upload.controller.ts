import { Request, Response, NextFunction } from 'express';
import { ResponseUtil } from '../utils/response.util';
import { StorageService } from '../services/storage.service';
import { AppError } from '../middlewares/error.middleware';

export class UploadController {
  static async uploadMedicalRecord(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.file) throw new AppError('No file uploaded', 400);

      const result = await StorageService.uploadFile({
        folder: 'medical-records',
        originalName: req.file.originalname,
        mimeType: req.file.mimetype,
        buffer: req.file.buffer,
      });

      return ResponseUtil.success(res, {
        fileUrl: result.fileUrl,
        fileKey: result.fileKey,
        fileType: req.file.mimetype,
        fileSize: req.file.size,
      }, 'File uploaded successfully', 201);
    } catch (e) {
      next(e);
    }
  }

  static async uploadPrescription(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.file) throw new AppError('No file uploaded', 400);

      const result = await StorageService.uploadFile({
        folder: 'prescriptions',
        originalName: req.file.originalname,
        mimeType: req.file.mimetype,
        buffer: req.file.buffer,
      });

      return ResponseUtil.success(res, {
        fileUrl: result.fileUrl,
        fileKey: result.fileKey,
        fileType: req.file.mimetype,
        fileSize: req.file.size,
      }, 'File uploaded successfully', 201);
    } catch (e) {
      next(e);
    }
  }

  static async uploadAvatar(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.file) throw new AppError('No file uploaded', 400);

      const result = await StorageService.uploadFile({
        folder: 'avatars',
        originalName: req.file.originalname,
        mimeType: req.file.mimetype,
        buffer: req.file.buffer,
      });

      return ResponseUtil.success(res, {
        fileUrl: result.fileUrl,
        fileKey: result.fileKey,
        fileType: req.file.mimetype,
        fileSize: req.file.size,
      }, 'Avatar uploaded successfully', 201);
    } catch (e) {
      next(e);
    }
  }
}