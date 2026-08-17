import { Server, Socket } from 'socket.io';

export class SocketService {
  private static io: Server;

  static init(io: Server) {
    this.io = io;

    io.on('connection', (socket: Socket) => {
      // Doctor/patient joins a doctor queue room for a given date (YYYY-MM-DD)
      socket.on('joinDoctorQueue', (payload: { doctorId: string; date: string }) => {
        const room = SocketService.doctorQueueRoom(payload.doctorId, payload.date);
        socket.join(room);
      });

      socket.on('leaveDoctorQueue', (payload: { doctorId: string; date: string }) => {
        const room = SocketService.doctorQueueRoom(payload.doctorId, payload.date);
        socket.leave(room);
      });
    });
  }

  static doctorQueueRoom(doctorId: string, date: string) {
    return `doctor:${doctorId}:date:${date}`;
  }

  static emitDoctorQueueUpdate(doctorId: string, date: string, data: any) {
    if (!this.io) return;
    this.io.to(this.doctorQueueRoom(doctorId, date)).emit('queue:update', data);
  }
}