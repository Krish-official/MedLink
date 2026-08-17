import prisma from '../config/database';
import { firebaseMessaging } from '../config/firebase';

export class NotificationService {
  static async upsertFcmToken(userId: string, token: string) {
    await prisma.fCMToken.upsert({
      where: { token },
      update: { userId },
      create: { userId, token },
    });
  }

  static async createInAppNotification(params: {
    userId: string;
    title: string;
    body: string;
    data?: any;
  }) {
    return prisma.notification.create({
      data: {
        userId: params.userId,
        title: params.title,
        body: params.body,
        data: params.data ?? undefined,
      },
    });
  }

  static async sendToUser(params: {
    userId: string;
    title: string;
    body: string;
    data?: Record<string, string>;
  }) {
    // Save in-app notification
    await this.createInAppNotification({
      userId: params.userId,
      title: params.title,
      body: params.body,
      data: params.data,
    });

    // Push notification (FCM)
    const messaging = firebaseMessaging();
    if (!messaging) return;

    const tokenRows = await prisma.fCMToken.findMany({
      where: { userId: params.userId },
      select: { token: true },
    });

    const tokens = tokenRows.map((t) => t.token);
    if (tokens.length === 0) return;

    const result = await messaging.sendEachForMulticast({
      tokens,
      notification: { title: params.title, body: params.body },
      data: params.data,
    });

    // Cleanup invalid tokens
    const invalidTokens: string[] = [];
    result.responses.forEach((r, idx) => {
      if (!r.success) {
        const code = (r.error as any)?.code ?? '';
        if (
          code.includes('registration-token-not-registered') ||
          code.includes('invalid-argument')
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    if (invalidTokens.length) {
      await prisma.fCMToken.deleteMany({
        where: { token: { in: invalidTokens } },
      });
    }
  }
}