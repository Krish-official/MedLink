import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { AuthValidator } from '../validators/auth.validator';
import { validate } from '../middlewares/validate.middleware';
import { authenticate } from '../middlewares/auth.middleware';

const router = Router();

// ═══════════════════════════════════════════════════════════
// PUBLIC ROUTES
// ═══════════════════════════════════════════════════════════

/**
 * @route   POST /api/v1/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  AuthValidator.register(),
  validate,
  AuthController.register
);

/**
 * @route   POST /api/v1/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post(
  '/login',
  AuthValidator.login(),
  validate,
  AuthController.login
);

/**
 * @route   POST /api/v1/auth/refresh
 * @desc    Refresh access token
 * @access  Public
 */
router.post(
  '/refresh',
  AuthValidator.refreshToken(),
  validate,
  AuthController.refreshToken
);

/**
 * @route   POST /api/v1/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post(
  '/forgot-password',
  AuthValidator.forgotPassword(),
  validate,
  AuthController.forgotPassword
);

/**
 * @route   POST /api/v1/auth/reset-password
 * @desc    Reset password with token
 * @access  Public
 */
router.post(
  '/reset-password',
  AuthValidator.resetPassword(),
  validate,
  AuthController.resetPassword
);

// ═══════════════════════════════════════════════════════════
// PROTECTED ROUTES
// ═══════════════════════════════════════════════════════════

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current user
 * @access  Private
 */
router.get('/me', authenticate, AuthController.getCurrentUser);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post(
  '/logout',
  authenticate,
  AuthValidator.refreshToken(),
  validate,
  AuthController.logout
);

/**
 * @route   POST /api/v1/auth/change-password
 * @desc    Change password
 * @access  Private
 */
router.post(
  '/change-password',
  authenticate,
  AuthValidator.changePassword(),
  validate,
  AuthController.changePassword
);

export default router;