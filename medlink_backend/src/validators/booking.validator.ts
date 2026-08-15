import { body, query, param } from 'express-validator';

export class BookingValidator {
  static searchDoctors() {
    return [
      query('query')
        .optional()
        .isString()
        .withMessage('Query must be a string'),
      query('specialty')
        .optional()
        .isString()
        .withMessage('Specialty must be a string'),
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

  static getDoctorDetails() {
    return [
      param('id').isUUID().withMessage('Invalid doctor ID'),
    ];
  }

  static getAvailableSlots() {
    return [
      query('doctorId')
        .notEmpty()
        .withMessage('Doctor ID is required')
        .isUUID()
        .withMessage('Invalid doctor ID'),
      query('date')
        .notEmpty()
        .withMessage('Date is required')
        .isISO8601()
        .withMessage('Invalid date format'),
    ];
  }

  static bookAppointment() {
    return [
      body('doctorId')
        .notEmpty()
        .withMessage('Doctor ID is required')
        .isUUID()
        .withMessage('Invalid doctor ID'),
      body('scheduledAt')
        .notEmpty()
        .withMessage('Scheduled time is required')
        .isISO8601()
        .withMessage('Invalid date format'),
      body('type')
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

  static rescheduleAppointment() {
    return [
      param('id').isUUID().withMessage('Invalid appointment ID'),
      body('scheduledAt')
        .notEmpty()
        .withMessage('New scheduled time is required')
        .isISO8601()
        .withMessage('Invalid date format'),
    ];
  }
}