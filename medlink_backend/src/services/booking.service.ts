import prisma from '../config/database';
import { AppError } from '../middlewares/error.middleware';
import { AppointmentType } from '@prisma/client';

export class BookingService {
  // ═══════════════════════════════════════════════════════════
  // SEARCH DOCTORS
  // ═══════════════════════════════════════════════════════════

  static async searchDoctors(filters: {
    query?: string;
    specialty?: string;
    page?: number;
    limit?: number;
  }) {
    const { query, specialty, page = 1, limit = 10 } = filters;

    const where: any = { isAvailable: true };

    if (specialty) {
      where.specialty = { contains: specialty, mode: 'insensitive' };
    }

    if (query) {
      where.OR = [
        {
          user: {
            firstName: { contains: query, mode: 'insensitive' },
          },
        },
        {
          user: {
            lastName: { contains: query, mode: 'insensitive' },
          },
        },
        {
          specialty: { contains: query, mode: 'insensitive' },
        },
      ];
    }

    const [doctors, total] = await Promise.all([
      prisma.doctor.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              phone: true,
              avatar: true,
            },
          },
        },
        orderBy: [{ rating: 'desc' }, { reviewCount: 'desc' }],
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.doctor.count({ where }),
    ]);

    return { doctors, total, page, limit };
  }

  // ═══════════════════════════════════════════════════════════
  // GET SPECIALTIES
  // ═══════════════════════════════════════════════════════════

  static async getSpecialties() {
    const specialties = await prisma.doctor.findMany({
      select: { specialty: true },
      distinct: ['specialty'],
      where: { isAvailable: true },
    });

    return specialties.map((s) => s.specialty);
  }

  // ═══════════════════════════════════════════════════════════
  // GET DOCTOR DETAILS
  // ═══════════════════════════════════════════════════════════

  static async getDoctorDetails(doctorId: string) {
    const doctor = await prisma.doctor.findUnique({
      where: { id: doctorId },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
            phone: true,
            avatar: true,
          },
        },
      },
    });

    if (!doctor) {
      throw new AppError('Doctor not found', 404);
    }

    return doctor;
  }

  // ═══════════════════════════════════════════════════════════
  // GET AVAILABLE SLOTS
  // ═══════════════════════════════════════════════════════════

  static async getAvailableSlots(doctorId: string, date: string) {
    const targetDate = new Date(date);
    const dayOfWeek = [
      'SUNDAY',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
    ][targetDate.getDay()];

    // Get doctor's availability for this day
    const availabilitySlots = await prisma.availabilitySlot.findMany({
      where: {
        doctorId,
        dayOfWeek: dayOfWeek as any,
        isActive: true,
      },
    });

    if (availabilitySlots.length === 0) {
      return [];
    }

    // Check for holidays
    const isHoliday = await prisma.holiday.findFirst({
      where: {
        doctorId,
        date: targetDate,
      },
    });

    if (isHoliday) {
      return [];
    }

    // Generate time slots for the day
    const slots = [];
    for (const availability of availabilitySlots) {
      const [startHour, startMinute] = availability.startTime.split(':').map(Number);
      const [endHour, endMinute] = availability.endTime.split(':').map(Number);

      let currentTime = new Date(targetDate);
      currentTime.setHours(startHour, startMinute, 0, 0);

      const endTime = new Date(targetDate);
      endTime.setHours(endHour, endMinute, 0, 0);

      while (currentTime < endTime) {
        const slotEndTime = new Date(currentTime.getTime() + availability.slotDuration * 60000);

        // Check existing appointments for this slot
        const existingAppointments = await prisma.appointment.count({
          where: {
            doctorId,
            scheduledAt: currentTime,
            status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
          },
        });

        slots.push({
          id: `${availability.id}-${currentTime.getTime()}`,
          doctorId,
          startTime: currentTime.toISOString(),
          endTime: slotEndTime.toISOString(),
          isAvailable: existingAppointments < availability.maxPatientsPerSlot,
          currentQueue: existingAppointments,
          maxQueue: availability.maxPatientsPerSlot,
        });

        currentTime = new Date(currentTime.getTime() + availability.slotDuration * 60000);
      }
    }

    return slots;
  }

  // ═══════════════════════════════════════════════════════════
  // BOOK APPOINTMENT
  // ═══════════════════════════════════════════════════════════

  static async bookAppointment(patientId: string, data: {
    doctorId: string;
    scheduledAt: string;
    type: AppointmentType;
    symptoms?: string;
    notes?: string;
  }) {
    const scheduledAt = new Date(data.scheduledAt);

    // Validate doctor exists
    const doctor = await prisma.doctor.findUnique({
      where: { id: data.doctorId },
    });

    if (!doctor) {
      throw new AppError('Doctor not found', 404);
    }

    if (!doctor.isAvailable) {
      throw new AppError('Doctor is not available', 400);
    }

    // Check if slot is available
    const existingAppointments = await prisma.appointment.count({
      where: {
        doctorId: data.doctorId,
        scheduledAt,
        status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
      },
    });

    // Get max queue size for this time (simplified - in production check availability slot)
    const maxQueue = 5; // This should come from availability slot

    if (existingAppointments >= maxQueue) {
      throw new AppError('This time slot is fully booked', 400);
    }

    // Generate token number (simplified)
    const tokenNumber = existingAppointments + 1;

    // Create appointment
    const appointment = await prisma.appointment.create({
      data: {
        patientId,
        doctorId: data.doctorId,
        scheduledAt,
        type: data.type,
        symptoms: data.symptoms,
        notes: data.notes,
        status: 'SCHEDULED',
        tokenNumber,
        queuePosition: tokenNumber,
      },
      include: {
        doctor: {
          include: { user: true },
        },
      },
    });

    // TODO: Send confirmation notification
    // await NotificationService.sendAppointmentConfirmation(patientId, appointment);

    return appointment;
  }

  // ═══════════════════════════════════════════════════════════
  // RESCHEDULE APPOINTMENT
  // ═══════════════════════════════════════════════════════════

  static async rescheduleAppointment(
    appointmentId: string,
    patientId: string,
    newScheduledAt: string
  ) {
    const appointment = await prisma.appointment.findFirst({
      where: {
        id: appointmentId,
        patientId,
      },
    });

    if (!appointment) {
      throw new AppError('Appointment not found', 404);
    }

    if (!['SCHEDULED', 'CONFIRMED'].includes(appointment.status)) {
      throw new AppError('Cannot reschedule this appointment', 400);
    }

    const scheduledAt = new Date(newScheduledAt);

    // Check if new slot is available
    const existingAppointments = await prisma.appointment.count({
      where: {
        doctorId: appointment.doctorId,
        scheduledAt,
        status: { in: ['SCHEDULED', 'CONFIRMED', 'IN_PROGRESS'] },
        id: { not: appointmentId }, // Exclude current appointment
      },
    });

    const maxQueue = 5;

    if (existingAppointments >= maxQueue) {
      throw new AppError('This time slot is fully booked', 400);
    }

    const updatedAppointment = await prisma.appointment.update({
      where: { id: appointmentId },
      data: {
        scheduledAt,
        tokenNumber: existingAppointments + 1,
        queuePosition: existingAppointments + 1,
      },
      include: {
        doctor: {
          include: { user: true },
        },
      },
    });

    return updatedAppointment;
  }
}