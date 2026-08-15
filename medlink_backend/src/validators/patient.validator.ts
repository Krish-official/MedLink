import { body, query, param } from 'express-validator';

export class PatientValidator {
  // ═══════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════

  static updateProfile() {
    return [
      body('bloodGroup')
        .optional()
        .isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'])
        .withMessage('Invalid blood group'),
      body('allergies')
        .optional()
        .isArray()
        .withMessage('Allergies must be an array'),
      body('chronicDiseases')
        .optional()
        .isArray()
        .withMessage('Chronic diseases must be an array'),
      body('emergencyContact')
        .optional()
        .isObject()
        .withMessage('Emergency contact must be an object'),
      body('address')
        .optional()
        .isString()
        .withMessage('Address must be a string'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════════════════

  static getAppointments() {
    return [
      query('status')
        .optional()
        .isIn(['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW'])
        .withMessage('Invalid status'),
      query('upcoming')
        .optional()
        .isBoolean()
        .withMessage('Upcoming must be a boolean'),
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

  static cancelAppointment() {
    return [
      param('id').isUUID().withMessage('Invalid appointment ID'),
      body('reason')
        .optional()
        .isString()
        .isLength({ max: 500 })
        .withMessage('Reason must be a string with max 500 characters'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // MEDICAL RECORDS
  // ═══════════════════════════════════════════════════════════

  static getMedicalRecords() {
    return [
      query('type')
        .optional()
        .isIn(['LAB_REPORT', 'IMAGING', 'DOCUMENT', 'PRESCRIPTION', 'DISCHARGE', 'OTHER'])
        .withMessage('Invalid record type'),
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

  static uploadMedicalRecord() {
    return [
      body('title')
        .notEmpty()
        .withMessage('Title is required')
        .isLength({ min: 3, max: 200 })
        .withMessage('Title must be between 3 and 200 characters'),
      body('type')
        .isIn(['LAB_REPORT', 'IMAGING', 'DOCUMENT', 'PRESCRIPTION', 'DISCHARGE', 'OTHER'])
        .withMessage('Invalid record type'),
      body('description')
        .optional()
        .isString()
        .isLength({ max: 1000 })
        .withMessage('Description must be max 1000 characters'),
      body('fileUrl')
        .notEmpty()
        .withMessage('File URL is required')
        .isURL()
        .withMessage('Invalid file URL'),
      body('fileType')
        .optional()
        .isString()
        .withMessage('File type must be a string'),
      body('fileSize')
        .optional()
        .isInt({ min: 0 })
        .withMessage('File size must be a positive integer'),
      body('recordDate')
        .optional()
        .isISO8601()
        .withMessage('Invalid record date'),
    ];
  }

  static deleteMedicalRecord() {
    return [
      param('id').isUUID().withMessage('Invalid record ID'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // VITALS
  // ═══════════════════════════════════════════════════════════

  static getVitals() {
    return [
      query('startDate')
        .optional()
        .isISO8601()
        .withMessage('Invalid start date'),
      query('endDate')
        .optional()
        .isISO8601()
        .withMessage('Invalid end date'),
      query('limit')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Limit must be between 1 and 100'),
    ];
  }

  static addVital() {
    return [
      body('bloodPressureSystolic')
        .optional()
        .isFloat({ min: 50, max: 300 })
        .withMessage('Systolic BP must be between 50 and 300'),
      body('bloodPressureDiastolic')
        .optional()
        .isFloat({ min: 30, max: 200 })
        .withMessage('Diastolic BP must be between 30 and 200'),
      body('heartRate')
        .optional()
        .isFloat({ min: 30, max: 250 })
        .withMessage('Heart rate must be between 30 and 250'),
      body('temperature')
        .optional()
        .isFloat({ min: 95, max: 110 })
        .withMessage('Temperature must be between 95 and 110'),
      body('oxygenSaturation')
        .optional()
        .isFloat({ min: 0, max: 100 })
        .withMessage('Oxygen saturation must be between 0 and 100'),
      body('weight')
        .optional()
        .isFloat({ min: 0, max: 500 })
        .withMessage('Weight must be between 0 and 500'),
      body('height')
        .optional()
        .isFloat({ min: 0, max: 300 })
        .withMessage('Height must be between 0 and 300'),
      body('bmi')
        .optional()
        .isFloat({ min: 0, max: 100 })
        .withMessage('BMI must be between 0 and 100'),
      body('notes')
        .optional()
        .isString()
        .isLength({ max: 500 })
        .withMessage('Notes must be max 500 characters'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // EMERGENCY
  // ═══════════════════════════════════════════════════════════

  static createEmergencyAlert() {
    return [
      body('location')
        .optional()
        .isObject()
        .withMessage('Location must be an object'),
      body('message')
        .optional()
        .isString()
        .isLength({ max: 500 })
        .withMessage('Message must be max 500 characters'),
    ];
  }

  static resolveEmergencyAlert() {
    return [
      param('id').isUUID().withMessage('Invalid alert ID'),
    ];
  }
}