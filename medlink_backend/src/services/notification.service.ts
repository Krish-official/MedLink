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
    // store in DB
    await this.createInAppNotification({
      userId: params.userId,
      title: params.title,
      body: params.body,
      data: params.data,
    });

    // send push
    const messaging = firebaseMessaging();
    if (!messaging) return;

    const tokens = await prisma.fCMToken.findMany({
      where: { userId: params.userId },
      select: { token: true },
    });

    const tokenList = tokens.map(t => t.token);
    if (tokenList.length === 0) return;

    await messaging.sendEachForMulticast({
      tokens: tokenList,
      notification: { title: params.title, body: params.body },
      data: params.data,
    });
  }
}