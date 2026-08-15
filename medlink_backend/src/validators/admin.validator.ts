import { body, query, param } from 'express-validator';

export class AdminValidator {
  // ═══════════════════════════════════════════════════════════
  // DOCTORS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static getDoctors() {
    return [
      query('search')
        .optional()
        .isString()
        .withMessage('Search must be a string'),
      query('specialty')
        .optional()
        .isString()
        .withMessage('Specialty must be a string'),
      query('isAvailable')
        .optional()
        .isBoolean()
        .withMessage('isAvailable must be a boolean'),
      query('page')
        .optional()
        .isInt({ min: 1 })
        .withMessage('Page must be a positive integer'),
      query('limit')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Limit must be between 1 and 100'),
    ];
  }

  static getDoctorDetail() {
    return [
      param('id').isUUID().withMessage('Invalid doctor ID'),
    ];
  }

  static createDoctor() {
    return [
      body('email')
        .isEmail()
        .withMessage('Please provide a valid email')
        .normalizeEmail(),
      body('password')
        .isLength({ min: 8 })
        .withMessage('Password must be at least 8 characters'),
      body('firstName')
        .trim()
        .notEmpty()
        .withMessage('First name is required')
        .isLength({ min: 2, max: 50 })
        .withMessage('First name must be between 2 and 50 characters'),
      body('lastName')
        .trim()
        .notEmpty()
        .withMessage('Last name is required')
        .isLength({ min: 2, max: 50 })
        .withMessage('Last name must be between 2 and 50 characters'),
      body('phone')
        .optional()
        .matches(/^\+?[1-9]\d{1,14}$/)
        .withMessage('Please provide a valid phone number'),
      body('specialty')
        .notEmpty()
        .withMessage('Specialty is required'),
      body('qualifications')
        .optional()
        .isString()
        .withMessage('Qualifications must be a string'),
      body('experienceYears')
        .optional()
        .isInt({ min: 0, max: 70 })
        .withMessage('Experience years must be between 0 and 70'),
      body('consultationFee')
        .optional()
        .isInt({ min: 0 })
        .withMessage('Consultation fee must be a positive number'),
    ];
  }

  static updateDoctor() {
    return [
      param('id').isUUID().withMessage('Invalid doctor ID'),
      body('specialty')
        .optional()
        .isString()
        .withMessage('Specialty must be a string'),
      body('qualifications')
        .optional()
        .isString()
        .withMessage('Qualifications must be a string'),
      body('experienceYears')
        .optional()
        .isInt({ min: 0, max: 70 })
        .withMessage('Experience years must be between 0 and 70'),
      body('consultationFee')
        .optional()
        .isInt({ min: 0 })
        .withMessage('Consultation fee must be a positive number'),
      body('isAvailable')
        .optional()
        .isBoolean()
        .withMessage('isAvailable must be a boolean'),
      body('isActive')
        .optional()
        .isBoolean()
        .withMessage('isActive must be a boolean'),
    ];
  }

  static deleteDoctor() {
    return [
      param('id').isUUID().withMessage('Invalid doctor ID'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // PATIENTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static getPatients() {
    return [
      query('search')
        .optional()
        .isString()
        .withMessage('Search must be a string'),
      query('page')
        .optional()
        .isInt({ min: 1 })
        .withMessage('Page must be a positive integer'),
      query('limit')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Limit must be between 1 and 100'),
    ];
  }

  static getPatientDetail() {
    return [
      param('id').isUUID().withMessage('Invalid patient ID'),
    ];
  }

  static updatePatientStatus() {
    return [
      param('id').isUUID().withMessage('Invalid patient ID'),
      body('isActive')
        .isBoolean()
        .withMessage('isActive must be a boolean'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static getAppointments() {
    return [
      query('status')
        .optional()
        .isIn(['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW'])
        .withMessage('Invalid status'),
      query('doctorId')
        .optional()
        .isUUID()
        .withMessage('Invalid doctor ID'),
      query('patientId')
        .optional()
        .isUUID()
        .withMessage('Invalid patient ID'),
      query('startDate')
        .optional()
        .isISO8601()
        .withMessage('Invalid start date'),
      query('endDate')
        .optional()
        .isISO8601()
        .withMessage('Invalid end date'),
      query('page')
        .optional()
        .isInt({ min: 1 })
        .withMessage('Page must be a positive integer'),
      query('limit')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Limit must be between 1 and 100'),
    ];
  }

  static updateAppointmentStatus() {
    return [
      param('id').isUUID().withMessage('Invalid appointment ID'),
      body('status')
        .isIn(['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW'])
        .withMessage('Invalid status'),
    ];
  }

  static deleteAppointment() {
    return [
      param('id').isUUID().withMessage('Invalid appointment ID'),
    ];
  }
}