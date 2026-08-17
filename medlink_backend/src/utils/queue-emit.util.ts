import { QueueService } from '../services/queue.service';
import { SocketService } from '../services/socket.service';

export async function emitDoctorQueueSnapshot(doctorId: string, scheduledAtISO: string) {
  const dateKey = scheduledAtISO.slice(0, 10); // YYYY-MM-DD
  const snapshot = await QueueService.getDoctorQueueSnapshot(doctorId, scheduledAtISO);
  SocketService.emitDoctorQueueUpdate(doctorId, dateKey, snapshot);
}