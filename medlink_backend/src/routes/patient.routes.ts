import { Router } from 'express';
import { PatientController } from '../controllers/patient.controller';
import { BookingController } from '../controllers/booking.controller';
import { PatientValidator } from '../validators/patient.validator';
import { BookingValidator } from '../validators/booking.validator';
import { validate } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { authorize } from '../middlewares/role.middleware';

const router = Router();

// All patient routes require authentication as PATIENT
router.use(authenticate);
router.use(authorize('PATIENT'));

// ═══════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/patient/dashboard
 * @desc    Get patient dashboard data
 * @access  Private (Patient)
 */
router.get('/dashboard', PatientController.getDashboard);

// ═══════════════════════════════════════════════════════════
// PROFILE
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/patient/profile
 * @desc    Get patient profile
 * @access  Private (Patient)
 */
router.get('/profile', PatientController.getProfile);

/**
 * @route   PUT /api/v1/patient/profile
 * @desc    Update patient profile
 * @access  Private (Patient)
 */
router.put(
  '/profile',
  PatientValidator.updateProfile(),
  validate,
  PatientController.updateProfile
);

// ═══════════════════════════════════════════════════════════
// APPOINTMENTS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/patient/appointments
 * @desc    Get all patient appointments
 * @access  Private (Patient)
 */
router.get(
  '/appointments',
  PatientValidator.getAppointments(),
  validate,
  PatientController.getAppointments
);

/**
 * @route   GET /api/v1/patient/appointments/:id
 * @desc    Get appointment details
 * @access  Private (Patient)
 */
router.get('/appointments/:id', PatientController.getAppointmentDetail);

/**
 * @route   POST /api/v1/patient/appointments/:id/cancel
 * @desc    Cancel an appointment
 * @access  Private (Patient)
 */
router.post(
  '/appointments/:id/cancel',
  PatientValidator.cancelAppointment(),
  validate,
  PatientController.cancelAppointment
);

// ═══════════════════════════════════════════════════════════
// MEDICAL RECORDS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/patient/medical-records
 * @desc    Get all medical records
 * @access  Private (Patient)
 */
router.get(
  '/medical-records',
  PatientValidator.getMedicalRecords(),
  validate,
  PatientController.getMedicalRecords
);

/**
 * @route   POST /api/v1/patient/medical-records
 * @desc    Upload a medical record
 * @access  Private (Patient)
 */
router.post(
  '/medical-records',
  PatientValidator.uploadMedicalRecord(),
  validate,
  PatientController.uploadMedicalRecord
);

/**
 * @route   DELETE /api/v1/patient/medical-records/:id
 * @desc    Delete a medical record
 * @access  Private (Patient)
 */
router.delete(
  '/medical-records/:id',
  PatientValidator.deleteMedicalRecord(),
  validate,
  PatientController.deleteMedicalRecord
);

// ═══════════════════════════════════════════════════════════
// PRESCRIPTIONS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/patient/prescriptions
 * @desc    Get all prescriptions
 * @access  Private (Patient)
 */
router.get('/prescriptions', PatientController.getPrescriptions);

/**
 * @route   GET /api/v1/patient/prescriptions/:id
 * @desc    Get prescription details
 * @access  Private (Patient)
 */
router.get('/prescriptions/:id', PatientController.getPrescriptionDetail);

// ═══════════════════════════════════════════════════════════
// VITALS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/patient/vitals
 * @desc    Get vital records
 * @access  Private (Patient)
 */
router.get(
  '/vitals',
  PatientValidator.getVitals(),
  validate,
  PatientController.getVitals
);

/**
 * @route   POST /api/v1/patient/vitals
 * @desc    Add a vital record
 * @access  Private (Patient)
 */
router.post(
  '/vitals',
  PatientValidator.addVital(),
  validate,
  PatientController.addVital
);

// ═══════════════════════════════════════════════════════════
// EMERGENCY
// ═══════════════════════════════════════════════════════════

/**
 * @route   POST /api/v1/patient/emergency-alerts
 * @desc    Create emergency alert
 * @access  Private (Patient)
 */
router.post(
  '/emergency-alerts',
  PatientValidator.createEmergencyAlert(),
  validate,
  PatientController.createEmergencyAlert
);

/**
 * @route   GET /api/v1/patient/emergency-alerts
 * @desc    Get emergency alerts
 * @access  Private (Patient)
 */
router.get('/emergency-alerts', PatientController.getEmergencyAlerts);

/**
 * @route   POST /api/v1/patient/emergency-alerts/:id/resolve
 * @desc    Resolve emergency alert
 * @access  Private (Patient)
 */
router.post(
  '/emergency-alerts/:id/resolve',
  PatientValidator.resolveEmergencyAlert(),
  validate,
  PatientController.resolveEmergencyAlert
);

export default router;