import { Router } from 'express';
import { authenticate } from '../middlewares/auth.middleware';
import { upload } from '../middlewares/upload.middleware';
import { UploadController } from '../controllers/upload.controller';

const router = Router();

router.use(authenticate);

router.post('/medical-record', upload.single('file'), UploadController.uploadMedicalRecord);
router.post('/prescription', upload.single('file'), UploadController.uploadPrescription);
router.post('/avatar', upload.single('file'), UploadController.uploadAvatar);

export default router;