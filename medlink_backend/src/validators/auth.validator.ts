import { body, ValidationChain } from 'express-validator';

export class AuthValidator {
  static register(): ValidationChain[] {
    return [
      body('email')
        .isEmail()
        .withMessage('Please provide a valid email')
        .normalizeEmail(),
      body('password')
        .isLength({ min: 8 })
        .withMessage('Password must be at least 8 characters')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
        .withMessage(
          'Password must contain at least one uppercase letter, one lowercase letter, and one number'
        ),
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
      body('role')
        .isIn(['PATIENT', 'DOCTOR', 'ADMIN'])
        .withMessage('Invalid role'),
      body('phone')
        .optional()
        .matches(/^\+?[1-9]\d{1,14}$/)
        .withMessage('Please provide a valid phone number'),
    ];
  }

  static login(): ValidationChain[] {
    return [
      body('email')
        .isEmail()
        .withMessage('Please provide a valid email')
        .normalizeEmail(),
      body('password').notEmpty().withMessage('Password is required'),
    ];
  }

  static refreshToken(): ValidationChain[] {
    return [
      body('refreshToken')
        .notEmpty()
        .withMessage('Refresh token is required'),
    ];
  }

  static forgotPassword(): ValidationChain[] {
    return [
      body('email')
        .isEmail()
        .withMessage('Please provide a valid email')
        .normalizeEmail(),
    ];
  }

  static resetPassword(): ValidationChain[] {
    return [
      body('token').notEmpty().withMessage('Reset token is required'),
      body('newPassword')
        .isLength({ min: 8 })
        .withMessage('Password must be at least 8 characters')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
        .withMessage(
          'Password must contain at least one uppercase letter, one lowercase letter, and one number'
        ),
    ];
  }

  static changePassword(): ValidationChain[] {
    return [
      body('oldPassword').notEmpty().withMessage('Current password is required'),
      body('newPassword')
        .isLength({ min: 8 })
        .withMessage('Password must be at least 8 characters')
        .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
        .withMessage(
          'Password must contain at least one uppercase letter, one lowercase letter, and one number'
        ),
    ];
  }
}