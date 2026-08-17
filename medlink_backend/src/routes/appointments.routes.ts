import { Router } from 'express';
import { BookingController } from '../controllers/booking.controller';
import { BookingValidator } from '../validators/booking.validator';
import { validate } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { authorize } from '../middlewares/role.middleware';

const router = Router();

// Patient booking endpoints
router.post(
  '/',
  authenticate,
  authorize('PATIENT'),
  BookingValidator.bookAppointment(),
  validate,
  BookingController.bookAppointment
);

router.post(
  '/:id/reschedule',
  authenticate,
  authorize('PATIENT'),
  BookingValidator.rescheduleAppointment(),
  validate,
  BookingController.rescheduleAppointment
);

export default router;