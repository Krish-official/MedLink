import { Router } from 'express';
import { AdminController } from '../controllers/admin.controller';
import { AdminValidator } from '../validators/admin.validator';
import { validate } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';
import { authorize } from '../middlewares/role.middleware';

const router = Router();

// All admin routes require authentication as ADMIN
router.use(authenticate);
router.use(authorize('ADMIN'));

// ═══════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/admin/dashboard
 * @desc    Get admin dashboard data
 * @access  Private (Admin)
 */
router.get('/dashboard', AdminController.getDashboard);

// ═══════════════════════════════════════════════════════════
// DOCTORS MANAGEMENT
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/admin/doctors
 * @desc    Get all doctors
 * @access  Private (Admin)
 */
router.get(
  '/doctors',
  AdminValidator.getDoctors(),
  validate,
  AdminController.getDoctors
);

/**
 * @route   GET /api/v1/admin/doctors/:id
 * @desc    Get doctor details
 * @access  Private (Admin)
 */
router.get(
  '/doctors/:id',
  AdminValidator.getDoctorDetail(),
  validate,
  AdminController.getDoctorDetail
);

/**
 * @route   POST /api/v1/admin/doctors
 * @desc    Create new doctor
 * @access  Private (Admin)
 */
router.post(
  '/doctors',
  AdminValidator.createDoctor(),
  validate,
  AdminController.createDoctor
);

/**
 * @route   PUT /api/v1/admin/doctors/:id
 * @desc    Update doctor
 * @access  Private (Admin)
 */
router.put(
  '/doctors/:id',
  AdminValidator.updateDoctor(),
  validate,
  AdminController.updateDoctor
);

/**
 * @route   DELETE /api/v1/admin/doctors/:id
 * @desc    Deactivate doctor
 * @access  Private (Admin)
 */
router.delete(
  '/doctors/:id',
  AdminValidator.deleteDoctor(),
  validate,
  AdminController.deleteDoctor
);

// ═══════════════════════════════════════════════════════════
// PATIENTS MANAGEMENT
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/admin/patients
 * @desc    Get all patients
 * @access  Private (Admin)
 */
router.get(
  '/patients',
  AdminValidator.getPatients(),
  validate,
  AdminController.getPatients
);

/**
 * @route   GET /api/v1/admin/patients/:id
 * @desc    Get patient details
 * @access  Private (Admin)
 */
router.get(
  '/patients/:id',
  AdminValidator.getPatientDetail(),
  validate,
  AdminController.getPatientDetail
);

/**
 * @route   PATCH /api/v1/admin/patients/:id/status
 * @desc    Update patient status (activate/deactivate)
 * @access  Private (Admin)
 */
router.patch(
  '/patients/:id/status',
  AdminValidator.updatePatientStatus(),
  validate,
  AdminController.updatePatientStatus
);

// ═══════════════════════════════════════════════════════════
// APPOINTMENTS MANAGEMENT
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/admin/appointments
 * @desc    Get all appointments
 * @access  Private (Admin)
 */
router.get(
  '/appointments',
  AdminValidator.getAppointments(),
  validate,
  AdminController.getAppointments
);

/**
 * @route   PATCH /api/v1/admin/appointments/:id/status
 * @desc    Update appointment status
 * @access  Private (Admin)
 */
router.patch(
  '/appointments/:id/status',
  AdminValidator.updateAppointmentStatus(),
  validate,
  AdminController.updateAppointmentStatus
);

/**
 * @route   DELETE /api/v1/admin/appointments/:id
 * @desc    Delete appointment
 * @access  Private (Admin)
 */
router.delete(
  '/appointments/:id',
  AdminValidator.deleteAppointment(),
  validate,
  AdminController.deleteAppointment
);

// ═══════════════════════════════════════════════════════════
// SYSTEM STATS & SETTINGS
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/admin/stats
 * @desc    Get system statistics
 * @access  Private (Admin)
 */
router.get('/stats', AdminController.getSystemStats);

/**
 * @route   GET /api/v1/admin/settings
 * @desc    Get system settings
 * @access  Private (Admin)
 */
router.get('/settings', AdminController.getSettings);

export default router;