import { Router } from 'express';
import { BookingController } from '../controllers/booking.controller';
import { BookingValidator } from '../validators/booking.validator';
import { validate } from '../middlewares/validate.middleware';

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

// Note: appointment booking (POST /appointments, POST /appointments/:id/reschedule)
// lives in appointments.routes.ts, mounted separately at /api/v1/appointments.

export default router;