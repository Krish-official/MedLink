import bcrypt from 'bcryptjs';
import { UserRole, User, Patient, Doctor, Admin } from '@prisma/client';
import prisma from '../config/database';
import { TokenUtil } from '../utils/token.util';
import { AppError } from '../middlewares/error.middleware';

interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  phone?: string;
}

interface LoginData {
  email: string;
  password: string;
}

interface AuthResponse {
  user: User & {
    patient?: Patient | null;
    doctor?: Doctor | null;
    admin?: Admin | null;
  };
  accessToken: string;
  refreshToken: string;
}

export class AuthService {
  // ═══════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════

  static async register(data: RegisterData): Promise<AuthResponse> {
    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      throw new AppError('Email already registered', 409);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 12);

    // Create user with role-specific record
    const user = await prisma.user.create({
      data: {
        email: data.email,
        password: hashedPassword,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
        role: data.role,
        ...(data.role === 'PATIENT' && {
          patient: {
            create: {},
          },
        }),
        ...(data.role === 'DOCTOR' && {
          doctor: {
            create: {
              specialty: 'General Physician', // Default, can be updated later
              qualifications: '',
              experienceYears: 0,
            },
          },
        }),
        ...(data.role === 'ADMIN' && {
          admin: {
            create: {},
          },
        }),
      },
      include: {
        patient: true,
        doctor: true,
        admin: true,
      },
    });

    // Generate tokens
    const tokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = TokenUtil.generateAccessToken(tokenPayload);
    const refreshToken = TokenUtil.generateRefreshToken(tokenPayload);

    // Store refresh token
    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId: user.id,
        expiresAt: TokenUtil.getExpiryDate(
          process.env.JWT_REFRESH_EXPIRY || '7d'
        ),
      },
    });

    // Remove password from response
    const { password, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      accessToken,
      refreshToken,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════

  static async login(data: LoginData): Promise<AuthResponse> {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email: data.email },
      include: {
        patient: true,
        doctor: true,
        admin: true,
      },
    });

    if (!user) {
      throw new AppError('Invalid credentials', 401);
    }

    // Check if account is active
    if (!user.isActive) {
      throw new AppError('Account is deactivated', 403);
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(data.password, user.password);
    if (!isPasswordValid) {
      throw new AppError('Invalid credentials', 401);
    }

    // Generate tokens
    const tokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = TokenUtil.generateAccessToken(tokenPayload);
    const refreshToken = TokenUtil.generateRefreshToken(tokenPayload);

    // Store refresh token
    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId: user.id,
        expiresAt: TokenUtil.getExpiryDate(
          process.env.JWT_REFRESH_EXPIRY || '7d'
        ),
      },
    });

    // Remove password from response
    const { password, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      accessToken,
      refreshToken,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH TOKEN
  // ═══════════════════════════════════════════════════════════

  static async refreshToken(token: string): Promise<AuthResponse> {
    // Verify refresh token
    let decoded;
    try {
      decoded = TokenUtil.verifyRefreshToken(token);
    } catch {
      throw new AppError('Invalid refresh token', 401);
    }

    // Check if token exists in database
    const storedToken = await prisma.refreshToken.findUnique({
      where: { token },
      include: {
        user: {
          include: {
            patient: true,
            doctor: true,
            admin: true,
          },
        },
      },
    });

    if (!storedToken) {
      throw new AppError('Refresh token not found', 401);
    }

    // Check if token is expired
    if (storedToken.expiresAt < new Date()) {
      await prisma.refreshToken.delete({ where: { token } });
      throw new AppError('Refresh token expired', 401);
    }

    // Generate new tokens
    const tokenPayload = {
      userId: storedToken.user.id,
      email: storedToken.user.email,
      role: storedToken.user.role,
    };

    const accessToken = TokenUtil.generateAccessToken(tokenPayload);
    const newRefreshToken = TokenUtil.generateRefreshToken(tokenPayload);

    // Delete old refresh token and create new one
    await prisma.refreshToken.delete({ where: { token } });
    await prisma.refreshToken.create({
      data: {
        token: newRefreshToken,
        userId: storedToken.user.id,
        expiresAt: TokenUtil.getExpiryDate(
          process.env.JWT_REFRESH_EXPIRY || '7d'
        ),
      },
    });

    // Remove password from response
    const { password, ...userWithoutPassword } = storedToken.user;

    return {
      user: userWithoutPassword,
      accessToken,
      refreshToken: newRefreshToken,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════

  static async logout(token: string): Promise<void> {
    await prisma.refreshToken.deleteMany({
      where: { token },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // LOGOUT ALL DEVICES
  // ═══════════════════════════════════════════════════════════

  static async logoutAll(userId: string): Promise<void> {
    await prisma.refreshToken.deleteMany({
      where: { userId },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // GET CURRENT USER
  // ═══════════════════════════════════════════════════════════

  static async getCurrentUser(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        phone: true,
        avatar: true,
        dateOfBirth: true,
        gender: true,
        role: true,
        isVerified: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
        patient: true,
        doctor: true,
        admin: true,
      },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    return user;
  }

  // ═══════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ═══════════════════════════════════════════════════════════

  static async forgotPassword(email: string): Promise<void> {
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      // Don't reveal if email exists
      return;
    }

    // Generate reset token (simplified - in production use crypto.randomBytes)
    const resetToken = TokenUtil.generateAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // TODO: Send email with reset link
    // await EmailService.sendPasswordResetEmail(user.email, resetToken);

    console.log(`Password reset token for ${email}: ${resetToken}`);
  }

  // ═══════════════════════════════════════════════════════════
  // RESET PASSWORD
  // ═══════════════════════════════════════════════════════════

  static async resetPassword(token: string, newPassword: string): Promise<void> {
    // Verify token
    let decoded;
    try {
      decoded = TokenUtil.verifyAccessToken(token);
    } catch {
      throw new AppError('Invalid or expired reset token', 401);
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Update password
    await prisma.user.update({
      where: { id: decoded.userId },
      data: { password: hashedPassword },
    });

    // Logout all devices
    await this.logoutAll(decoded.userId);
  }

  // ═══════════════════════════════════════════════════════════
  // CHANGE PASSWORD
  // ═══════════════════════════════════════════════════════════

  static async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string
  ): Promise<void> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Verify old password
    const isPasswordValid = await bcrypt.compare(oldPassword, user.password);
    if (!isPasswordValid) {
      throw new AppError('Current password is incorrect', 401);
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Update password
    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    // Logout all other devices
    await this.logoutAll(userId);
  }
}