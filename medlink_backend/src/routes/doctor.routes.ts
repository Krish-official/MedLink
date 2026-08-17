import { Router } from 'express';
import { DoctorController } from '../controllers/doctor.controller';
import { DoctorValidator } from '../validators/doctor.validator';
import { validate } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { authorize } from '../middlewares/role.middleware';

const router = Router();

// All doctor routes require authentication as DOCTOR
router.use(authenticate);
router.use(authorize('DOCTOR'));

// ═══════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/dashboard
 * @desc    Get doctor dashboard data
 * @access  Private (Doctor)
 */
router.get('/dashboard', DoctorController.getDashboard);

// ═══════════════════════════════════════════════════════════
// PROFILE
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/profile
 * @desc    Get doctor profile
 * @access  Private (Doctor)
 */
router.get('/profile', DoctorController.getProfile);

/**
 * @route   PUT /api/v1/doctor/profile
 * @desc    Update doctor profile
 * @access  Private (Doctor)
 */
router.put(
  '/profile',
  DoctorValidator.updateProfile(),
  validate,
  DoctorController.updateProfile
);

// ═══════════════════════════════════════════════════════════
// AVAILABILITY
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/availability
 * @desc    Get availability slots
 * @access  Private (Doctor)
 */
router.get('/availability', DoctorController.getAvailability);

/**
 * @route   POST /api/v1/doctor/availability
 * @desc    Create availability slot
 * @access  Private (Doctor)
 */
router.post(
  '/availability',
  DoctorValidator.createAvailability(),
  validate,
  DoctorController.createAvailability
);

/**
 * @route   PUT /api/v1/doctor/availability/:id
 * @desc    Update availability slot
 * @access  Private (Doctor)
 */
router.put(
  '/availability/:id',
  DoctorValidator.updateAvailability(),
  validate,
  DoctorController.updateAvailability
);

/**
 * @route   DELETE /api/v1/doctor/availability/:id
 * @desc    Delete availability slot
 * @access  Private (Doctor)
 */
router.delete(
  '/availability/:id',
  DoctorValidator.deleteAvailability(),
  validate,
  DoctorController.deleteAvailability
);

// ═══════════════════════════════════════════════════════════
// HOLIDAYS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/holidays
 * @desc    Get holidays
 * @access  Private (Doctor)
 */
router.get('/holidays', DoctorController.getHolidays);

/**
 * @route   POST /api/v1/doctor/holidays
 * @desc    Create holiday
 * @access  Private (Doctor)
 */
router.post(
  '/holidays',
  DoctorValidator.createHoliday(),
  validate,
  DoctorController.createHoliday
);

/**
 * @route   DELETE /api/v1/doctor/holidays/:id
 * @desc    Delete holiday
 * @access  Private (Doctor)
 */
router.delete(
  '/holidays/:id',
  DoctorValidator.deleteHoliday(),
  validate,
  DoctorController.deleteHoliday
);

// ═══════════════════════════════════════════════════════════
// APPOINTMENTS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/appointments
 * @desc    Get doctor's appointments
 * @access  Private (Doctor)
 */
router.get(
  '/appointments',
  DoctorValidator.getAppointments(),
  validate,
  DoctorController.getAppointments
);

/**
 * @route   GET /api/v1/doctor/appointments/:id
 * @desc    Get appointment details
 * @access  Private (Doctor)
 */
router.get(
  '/appointments/:id',
  DoctorValidator.appointmentAction(),
  validate,
  DoctorController.getAppointmentDetail
);

/**
 * @route   POST /api/v1/doctor/appointments/:id/start
 * @desc    Start an appointment
 * @access  Private (Doctor)
 */
router.post(
  '/appointments/:id/start',
  DoctorValidator.appointmentAction(),
  validate,
  DoctorController.startAppointment
);

/**
 * @route   POST /api/v1/doctor/appointments/:id/complete
 * @desc    Complete an appointment
 * @access  Private (Doctor)
 */
router.post(
  '/appointments/:id/complete',
  DoctorValidator.appointmentAction(),
  validate,
  DoctorController.completeAppointment
);

// ═══════════════════════════════════════════════════════════
// PATIENTS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/patients
 * @desc    Get doctor's patients
 * @access  Private (Doctor)
 */
router.get(
  '/patients',
  DoctorValidator.getPatients(),
  validate,
  DoctorController.getPatients
);

/**
 * @route   GET /api/v1/doctor/patients/:id
 * @desc    Get patient details
 * @access  Private (Doctor)
 */
router.get(
  '/patients/:id',
  DoctorValidator.getPatientDetail(),
  validate,
  DoctorController.getPatientDetail
);

// ═══════════════════════════════════════════════════════════
// PRESCRIPTIONS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/prescriptions
 * @desc    Get prescriptions
 * @access  Private (Doctor)
 */
router.get(
  '/prescriptions',
  DoctorValidator.getPrescriptions(),
  validate,
  DoctorController.getPrescriptions
);

/**
 * @route   POST /api/v1/doctor/prescriptions
 * @desc    Create prescription
 * @access  Private (Doctor)
 */
router.post(
  '/prescriptions',
  DoctorValidator.createPrescription(),
  validate,
  DoctorController.createPrescription
);

/**
 * @route   GET /api/v1/doctor/prescriptions/:id
 * @desc    Get prescription details
 * @access  Private (Doctor)
 */
router.get(
  '/prescriptions/:id',
  DoctorValidator.getPrescriptionDetail(),
  validate,
  DoctorController.getPrescriptionDetail
);

// ═══════════════════════════════════════════════════════════
// REPORTS & ANALYTICS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/doctor/reports
 * @desc    Get appointment reports
 * @access  Private (Doctor)
 */
router.get('/reports', DoctorController.getReports);

/**
 * @route   GET /api/v1/doctor/reports/demographics
 * @desc    Get patient demographics
 * @access  Private (Doctor)
 */
router.get('/reports/demographics', DoctorController.getDemographics);

/**
 * @route   GET /api/v1/doctor/reports/top-conditions
 * @desc    Get top conditions
 * @access  Private (Doctor)
 */
router.get('/reports/top-conditions', DoctorController.getTopConditions);

// ═══════════════════════════════════════════════════════════
// OFFLINE BOOKING
// ═══════════════════════════════════════════════════════════

/**
 * @route   POST /api/v1/doctor/offline-booking
 * @desc    Create walk-in appointment
 * @access  Private (Doctor)
 */
router.post(
  '/offline-booking',
  DoctorValidator.createOfflineBooking(),
  validate,
  DoctorController.createOfflineBooking
);

// Note: the public doctor directory (search/specialties/slots/:id) lives in
// booking.routes.ts, mounted separately at /api/v1/doctors (no auth required).
// It must NOT live on this router, since everything above requires DOCTOR auth.

export default router;