import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { ResponseUtil } from '../utils/response.util';

export class AuthController {
  // ═══════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════

  static async register(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.register(req.body);
      return ResponseUtil.success(res, result, 'Registration successful', 201);
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════

  static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await AuthService.login(req.body);
      return ResponseUtil.success(res, result, 'Login successful');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH TOKEN
  // ═══════════════════════════════════════════════════════════

  static async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;
      const result = await AuthService.refreshToken(refreshToken);
      return ResponseUtil.success(res, result, 'Token refreshed successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════

  static async logout(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;
      await AuthService.logout(refreshToken);
      return ResponseUtil.success(res, null, 'Logout successful');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET CURRENT USER
  // ═══════════════════════════════════════════════════════════

  static async getCurrentUser(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await AuthService.getCurrentUser(req.user!.userId);
      return ResponseUtil.success(res, user, 'User retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ═══════════════════════════════════════════════════════════

  static async forgotPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { email } = req.body;
      await AuthService.forgotPassword(email);
      return ResponseUtil.success(
        res,
        null,
        'Password reset instructions sent to your email'
      );
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RESET PASSWORD
  // ═══════════════════════════════════════════════════════════

  static async resetPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { token, newPassword } = req.body;
      await AuthService.resetPassword(token, newPassword);
      return ResponseUtil.success(res, null, 'Password reset successful');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CHANGE PASSWORD
  // ═══════════════════════════════════════════════════════════

  static async changePassword(req: Request, res: Response, next: NextFunction) {
    try {
      const { oldPassword, newPassword } = req.body;
      await AuthService.changePassword(
        req.user!.userId,
        oldPassword,
        newPassword
      );
      return ResponseUtil.success(res, null, 'Password changed successfully');
    } catch (error) {
      next(error);
    }
  }
}