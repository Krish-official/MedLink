import { Router } from 'express';
import { BookingController } from '../controllers/booking.controller';
import { BookingValidator } from '../validators/booking.validator';
import { validate } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { authorize } from '../middlewares/role.middleware';

const router = Router();

// ═══════════════════════════════════════════════════════════
// PUBLIC ROUTES (Doctor Search)
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctors
 * @desc    Search doctors
 * @access  Public
 */
router.get(
  '/',
  BookingValidator.searchDoctors(),
  validate,
  BookingController.searchDoctors
);

/**
 * @route   GET /api/v1/doctors/specialties
 * @desc    Get all specialties
 * @access  Public
 */
router.get('/specialties', BookingController.getSpecialties);

/**
 * @route   GET /api/v1/doctors/:id
 * @desc    Get doctor details
 * @access  Public
 */
router.get(
  '/:id',
  BookingValidator.getDoctorDetails(),
  validate,
  BookingController.getDoctorDetails
);

/**
 * @route   GET /api/v1/doctors/slots
 * @desc    Get available time slots
 * @access  Public
 */
router.get(
  '/slots',
  BookingValidator.getAvailableSlots(),
  validate,
  BookingController.getAvailableSlots
);

// ═══════════════════════════════════════════════════════════
// PATIENT ROUTES (Booking)
// ═══════════════════════════════════════════════════════════

/**
 * @route   POST /api/v1/appointments
 * @desc    Book an appointment
 * @access  Private (Patient)
 */
router.post(
  '/appointments',
  authenticate,
  authorize('PATIENT'),
  BookingValidator.bookAppointment(),
  validate,
  BookingController.bookAppointment
);

/**
 * @route   POST /api/v1/appointments/:id/reschedule
 * @desc    Reschedule an appointment
 * @access  Private (Patient)
 */
router.post(
  '/appointments/:id/reschedule',
  authenticate,
  authorize('PATIENT'),
  BookingValidator.rescheduleAppointment(),
  validate,
  BookingController.rescheduleAppointment
);

export default router;