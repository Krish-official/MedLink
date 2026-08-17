import { Request, Response, NextFunction } from 'express';
import { ResponseUtil } from '../utils/response.util';
import prisma from '../config/database';
import { NotificationService } from '../services/notification.service';
import { AppError } from '../middlewares/error.middleware';

export class NotificationController {
  static async registerFcmToken(req: Request, res: Response, next: NextFunction) {
    try {
      const { token } = req.body;
      if (!token) throw new AppError('token is required', 400);

      await NotificationService.upsertFcmToken(req.user!.userId, token);
      return ResponseUtil.success(res, null, 'FCM token registered');
    } catch (e) {
      next(e);
    }
  }

  static async list(req: Request, res: Response, next: NextFunction) {
    try {
      const page = req.query.page ? parseInt(req.query.page as string) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string) : 20;

      const [items, total] = await Promise.all([
        prisma.notification.findMany({
          where: { userId: req.user!.userId },
          orderBy: { createdAt: 'desc' },
          skip: (page - 1) * limit,
          take: limit,
        }),
        prisma.notification.count({ where: { userId: req.user!.userId } }),
      ]);

      return ResponseUtil.paginated(res, items, page, limit, total, 'Notifications');
    } catch (e) {
      next(e);
    }
  }

  static async markRead(req: Request, res: Response, next: NextFunction) {
    try {
      const id = req.params.id;

      const notification = await prisma.notification.findFirst({
        where: { id, userId: req.user!.userId },
      });
      if (!notification) throw new AppError('Notification not found', 404);

      await prisma.notification.update({
        where: { id },
        data: { isRead: true },
      });

      return ResponseUtil.success(res, null, 'Marked as read');
    } catch (e) {
      next(e);
    }
  }
}