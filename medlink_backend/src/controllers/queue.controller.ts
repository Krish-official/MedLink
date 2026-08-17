import { Request, Response, NextFunction } from 'express';
import { QueueService } from '../services/queue.service';
import { ResponseUtil } from '../utils/response.util';

export class QueueController {
  static async getDoctorQueue(req: Request, res: Response, next: NextFunction) {
    try {
      const { doctorId, date } = req.query;
      const snapshot = await QueueService.getDoctorQueueSnapshot(
        doctorId as string,
        `${date}T00:00:00.000Z`
      );
      return ResponseUtil.success(res, snapshot, 'Queue retrieved');
    } catch (e) {
      next(e);
    }
  }
}