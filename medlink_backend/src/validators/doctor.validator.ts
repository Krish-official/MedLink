import { body, query, param } from 'express-validator';

export class DoctorValidator {
  // ═══════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════

  static updateProfile() {
    return [
      body('specialty')
        .optional()
        .isString()
        .isLength({ min: 2, max: 100 })
        .withMessage('Specialty must be between 2 and 100 characters'),
      body('qualifications')
        .optional()
        .isString()
        .isLength({ max: 500 })
        .withMessage('Qualifications must be max 500 characters'),
      body('experienceYears')
        .optional()
        .isInt({ min: 0, max: 70 })
        .withMessage('Experience years must be between 0 and 70'),
      body('consultationFee')
        .optional()
        .isInt({ min: 0 })
        .withMessage('Consultation fee must be a positive number'),
      body('clinicAddress')
        .optional()
        .isString()
        .isLength({ max: 500 })
        .withMessage('Clinic address must be max 500 characters'),
      body('bio')
        .optional()
        .isString()
        .isLength({ max: 1000 })
        .withMessage('Bio must be max 1000 characters'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // AVAILABILITY
  // ═══════════════════════════════════════════════════════════

  static createAvailability() {
    return [
      body('dayOfWeek')
        .isIn(['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'])
        .withMessage('Invalid day of week'),
      body('startTime')
        .matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
        .withMessage('Invalid start time format (HH:MM)'),
      body('endTime')
        .matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
        .withMessage('Invalid end time format (HH:MM)'),
      body('slotDuration')
        .optional()
        .isInt({ min: 15, max: 120 })
        .withMessage('Slot duration must be between 15 and 120 minutes'),
      body('maxPatientsPerSlot')
        .optional()
        .isInt({ min: 1, max: 20 })
        .withMessage('Max patients per slot must be between 1 and 20'),
    ];
  }

  static updateAvailability() {
    return [
      param('id').isUUID().withMessage('Invalid availability slot ID'),
      ...DoctorValidator.createAvailability(),
      body('isActive')
        .optional()
        .isBoolean()
        .withMessage('isActive must be a boolean'),
    ];
  }

  static deleteAvailability() {
    return [
      param('id').isUUID().withMessage('Invalid availability slot ID'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS
  // ═══════════════════════════════════════════════════════════

  static createHoliday() {
    return [
      body('date')
        .notEmpty()
        .withMessage('Date is required')
        .isISO8601()
        .withMessage('Invalid date format'),
      body('reason')
        .notEmpty()
        .withMessage('Reason is required')
        .isString()
        .isLength({ min: 3, max: 200 })
        .withMessage('Reason must be between 3 and 200 characters'),
      body('isFullDay')
        .optional()
        .isBoolean()
        .withMessage('isFullDay must be a boolean'),
      body('startTime')
        .optional()
        .matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
        .withMessage('Invalid start time format (HH:MM)'),
      body('endTime')
        .optional()
        .matches(/^([01]\d|2[0-3]):([0-5]\d)$/)
        .withMessage('Invalid end time format (HH:MM)'),
    ];
  }

  static deleteHoliday() {
    return [
      param('id').isUUID().withMessage('Invalid holiday ID'),
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
      query('date')
        .optional()
        .isISO8601()
        .withMessage('Invalid date format'),
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

  static appointmentAction() {
    return [
      param('id').isUUID().withMessage('Invalid appointment ID'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // PATIENTS
  // ═══════════════════════════════════════════════════════════

  static getPatients() {
    return [
      query('q')
        .optional()
        .isString()
        .withMessage('Query must be a string'),
    ];
  }

  static getPatientDetail() {
    return [
      param('id').isUUID().withMessage('Invalid patient ID'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // PRESCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  static getPrescriptions() {
    return [
      query('patientId')
        .optional()
        .isUUID()
        .withMessage('Invalid patient ID'),
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

  static createPrescription() {
    return [
      body('patientId')
        .notEmpty()
        .withMessage('Patient ID is required')
        .isUUID()
        .withMessage('Invalid patient ID'),
      body('diagnosis')
        .notEmpty()
        .withMessage('Diagnosis is required')
        .isString()
        .isLength({ min: 3, max: 500 })
        .withMessage('Diagnosis must be between 3 and 500 characters'),
      body('notes')
        .optional()
        .isString()
        .isLength({ max: 1000 })
        .withMessage('Notes must be max 1000 characters'),
      body('followUpDate')
        .optional()
        .isString()
        .withMessage('Follow-up date must be a string'),
      body('medications')
        .isArray({ min: 1 })
        .withMessage('At least one medication is required'),
      body('medications.*.name')
        .notEmpty()
        .withMessage('Medication name is required'),
      body('medications.*.dosage')
        .notEmpty()
        .withMessage('Medication dosage is required'),
      body('medications.*.frequency')
        .notEmpty()
        .withMessage('Medication frequency is required'),
      body('medications.*.duration')
        .notEmpty()
        .withMessage('Medication duration is required'),
      body('medications.*.instructions')
        .optional()
        .isString()
        .withMessage('Medication instructions must be a string'),
    ];
  }

  static getPrescriptionDetail() {
    return [
      param('id').isUUID().withMessage('Invalid prescription ID'),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // OFFLINE BOOKING
  // ═══════════════════════════════════════════════════════════

  static createOfflineBooking() {
    return [
      body('email')
        .notEmpty()
        .withMessage('Email is required')
        .isEmail()
        .withMessage('Invalid email format'),
      body('firstName')
        .notEmpty()
        .withMessage('First name is required')
        .isString()
        .isLength({ min: 2, max: 50 })
        .withMessage('First name must be between 2 and 50 characters'),
      body('lastName')
        .notEmpty()
        .withMessage('Last name is required')
        .isString()
        .isLength({ min: 2, max: 50 })
        .withMessage('Last name must be between 2 and 50 characters'),
      body('phone')
        .optional()
        .matches(/^\+?[1-9]\d{1,14}$/)
        .withMessage('Invalid phone number'),
      body('scheduledAt')
        .notEmpty()
        .withMessage('Scheduled time is required')
        .isISO8601()
        .withMessage('Invalid date format'),
      body('type')
        .optional()
        .isIn(['CHECKUP', 'FOLLOW_UP', 'EMERGENCY', 'CONSULTATION'])
        .withMessage('Invalid appointment type'),
      body('symptoms')
        .optional()
        .isString()
        .isLength({ max: 1000 })
        .withMessage('Symptoms must be max 1000 characters'),
      body('notes')
        .optional()
        .isString()
        .isLength({ max: 1000 })
        .withMessage('Notes must be max 1000 characters'),
    ];
  }
}