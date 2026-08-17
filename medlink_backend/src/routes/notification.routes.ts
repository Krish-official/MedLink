import { Router } from 'express';
import { authenticate } from '../middlewares/auth.middleware';
import { NotificationController } from '../controllers/notification.controller';

const router = Router();
router.use(authenticate);

router.post('/fcm-token', NotificationController.registerFcmToken);
router.get('/', NotificationController.list);
router.patch('/:id/read', NotificationController.markRead);

export default router;