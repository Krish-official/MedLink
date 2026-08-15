import jwt from 'jsonwebtoken';
import { UserRole } from '@prisma/client';

interface TokenPayload {
  userId: string;
  email: string;
  role: UserRole;
}

interface DecodedToken extends TokenPayload {
  iat: number;
  exp: number;
}

export class TokenUtil {
  private static accessSecret = process.env.JWT_ACCESS_SECRET!;
  private static refreshSecret = process.env.JWT_REFRESH_SECRET!;
  private static accessExpiry = process.env.JWT_ACCESS_EXPIRY || '15m';
  private static refreshExpiry = process.env.JWT_REFRESH_EXPIRY || '7d';

  static generateAccessToken(payload: TokenPayload): string {
    return jwt.sign(payload, this.accessSecret, {
      expiresIn: this.accessExpiry,
    });
  }

  static generateRefreshToken(payload: TokenPayload): string {
    return jwt.sign(payload, this.refreshSecret, {
      expiresIn: this.refreshExpiry,
    });
  }

  static verifyAccessToken(token: string): DecodedToken {
    return jwt.verify(token, this.accessSecret) as DecodedToken;
  }

  static verifyRefreshToken(token: string): DecodedToken {
    return jwt.verify(token, this.refreshSecret) as DecodedToken;
  }

  static decodeToken(token: string): DecodedToken | null {
    try {
      return jwt.decode(token) as DecodedToken;
    } catch {
      return null;
    }
  }

  static getExpiryDate(expiry: string): Date {
    // Convert expiry string to milliseconds
    const match = expiry.match(/^(\d+)([mhd])$/);
    if (!match) return new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // Default 7 days

    const value = parseInt(match[1]);
    const unit = match[2];

    let milliseconds = 0;
    switch (unit) {
      case 'm':
        milliseconds = value * 60 * 1000;
        break;
      case 'h':
        milliseconds = value * 60 * 60 * 1000;
        break;
      case 'd':
        milliseconds = value * 24 * 60 * 60 * 1000;
        break;
    }

    return new Date(Date.now() + milliseconds);
  }
}