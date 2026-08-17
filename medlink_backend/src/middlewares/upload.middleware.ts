import multer from 'multer';
import { AppError } from './error.middleware';

const MAX_SIZE_MB = 10;

const allowedMime = new Set([
  'application/pdf',
  'image/jpeg',
  'image/png',
  'image/webp',
]);

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_SIZE_MB * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (!allowedMime.has(file.mimetype)) {
      return cb(new AppError('Invalid file type. Only PDF/JPG/PNG/WEBP allowed', 400));
    }
    cb(null, true);
  },
});