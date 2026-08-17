import { Router } from 'express';
import { QueueController } from '../controllers/queue.controller';

const router = Router();
router.get('/doctor', QueueController.getDoctorQueue);

export default router;