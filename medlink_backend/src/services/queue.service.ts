import prisma from '../config/database';

function dayRange(date: Date) {
  const start = new Date(date);
  start.setHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return { start, end };
}

export class QueueService {
  static async getDoctorQueueSnapshot(doctorId: string, dateISO: string) {
    const date = new Date(dateISO);
    const { start, end } = dayRange(date);

    const appointments = await prisma.appointment.findMany({
      where: {
        doctorId,
        scheduledAt: { gte: start, lt: end },
        status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
      },
      include: {
        patient: { include: { user: true } },
      },
      orderBy: [{ scheduledAt: 'asc' }, { createdAt: 'asc' }],
    });

    // queuePosition = index in list (1-based)
    const enriched = appointments.map((a, idx) => ({
      id: a.id,
      scheduledAt: a.scheduledAt,
      status: a.status,
      tokenNumber: a.tokenNumber,
      queuePosition: idx + 1,
      patientName: `${a.patient.user.firstName} ${a.patient.user.lastName}`,
    }));

    const current = enriched.find((a) => a.status === 'IN_PROGRESS') ?? null;
    const next = enriched.find((a) => a.status !== 'IN_PROGRESS') ?? null;

    return {
      doctorId,
      date: start.toISOString().slice(0, 10), // YYYY-MM-DD
      current,
      next,
      queue: enriched,
      queueSize: enriched.length,
      updatedAt: new Date().toISOString(),
    };
  }
}