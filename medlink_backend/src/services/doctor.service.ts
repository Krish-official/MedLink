import prisma from '../config/database';
import { AppError } from '../middlewares/error.middleware';
import { AppointmentStatus, DayOfWeek } from '@prisma/client';
import { safeUserSelect } from '../utils/prisma-select.util';

export class DoctorService {
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════

  static async getDashboard(doctorId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Get today's appointments
    const todayAppointments = await prisma.appointment.findMany({
      where: {
        doctorId,
        scheduledAt: {
          gte: today,
          lt: tomorrow,
        },
      },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
      orderBy: { scheduledAt: 'asc' },
    });

    // Get current appointment (in progress)
    const currentAppointment = await prisma.appointment.findFirst({
      where: {
        doctorId,
        status: 'IN_PROGRESS',
      },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
    });

    // Get next appointment
    const nextAppointment = await prisma.appointment.findFirst({
      where: {
        doctorId,
        scheduledAt: { gte: new Date() },
        status: { in: ['SCHEDULED', 'CONFIRMED'] },
      },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
      orderBy: { scheduledAt: 'asc' },
    });

    // Get stats
    const [totalPatientsToday, completedToday, pendingToday] = await Promise.all([
      prisma.appointment.count({
        where: {
          doctorId,
          scheduledAt: { gte: today, lt: tomorrow },
        },
      }),
      prisma.appointment.count({
        where: {
          doctorId,
          scheduledAt: { gte: today, lt: tomorrow },
          status: 'COMPLETED',
        },
      }),
      prisma.appointment.count({
        where: {
          doctorId,
          scheduledAt: { gte: today, lt: tomorrow },
          status: { in: ['SCHEDULED', 'CONFIRMED'] },
        },
      }),
    ]);

    return {
      todayAppointments,
      currentAppointment,
      nextAppointment,
      totalPatientsToday,
      completedToday,
      pendingToday,
      currentQueueSize: todayAppointments.filter(
        (a) => a.status !== 'COMPLETED' && a.status !== 'CANCELLED'
      ).length,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════

  static async getProfile(doctorId: string) {
    const doctor = await prisma.doctor.findUnique({
      where: { id: doctorId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            phone: true,
            avatar: true,
            dateOfBirth: true,
            gender: true,
            createdAt: true,
            updatedAt: true,
          },
        },
      },
    });

    if (!doctor) {
      throw new AppError('Doctor not found', 404);
    }

    return doctor;
  }

  static async updateProfile(doctorId: string, data: any) {
    const {
      specialty,
      qualifications,
      experienceYears,
      consultationFee,
      clinicAddress,
      bio,
    } = data;

    const doctor = await prisma.doctor.update({
      where: { id: doctorId },
      data: {
        specialty,
        qualifications,
        experienceYears,
        consultationFee,
        clinicAddress,
        bio,
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            phone: true,
            avatar: true,
          },
        },
      },
    });

    return doctor;
  }

  // ═══════════════════════════════════════════════════════════
  // SCHEDULE & AVAILABILITY
  // ═══════════════════════════════════════════════════════════

  static async getAvailability(doctorId: string) {
    const slots = await prisma.availabilitySlot.findMany({
      where: { doctorId },
      orderBy: [{ dayOfWeek: 'asc' }],
    });

    return slots;
  }

  static async createAvailability(doctorId: string, data: any) {
    const slot = await prisma.availabilitySlot.create({
      data: {
        doctorId,
        dayOfWeek: data.dayOfWeek,
        startTime: data.startTime,
        endTime: data.endTime,
        slotDuration: data.slotDuration || 30,
        maxPatientsPerSlot: data.maxPatientsPerSlot || 5,
      },
    });

    return slot;
  }

  static async updateAvailability(slotId: string, doctorId: string, data: any) {
    // Verify ownership
    const slot = await prisma.availabilitySlot.findFirst({
      where: { id: slotId, doctorId },
    });

    if (!slot) {
      throw new AppError('Availability slot not found', 404);
    }

    const updated = await prisma.availabilitySlot.update({
      where: { id: slotId },
      data: {
        dayOfWeek: data.dayOfWeek,
        startTime: data.startTime,
        endTime: data.endTime,
        slotDuration: data.slotDuration,
        maxPatientsPerSlot: data.maxPatientsPerSlot,
        isActive: data.isActive,
      },
    });

    return updated;
  }

  static async deleteAvailability(slotId: string, doctorId: string) {
    const slot = await prisma.availabilitySlot.findFirst({
      where: { id: slotId, doctorId },
    });

    if (!slot) {
      throw new AppError('Availability slot not found', 404);
    }

    await prisma.availabilitySlot.delete({
      where: { id: slotId },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS
  // ═══════════════════════════════════════════════════════════

  static async getHolidays(doctorId: string) {
    const holidays = await prisma.holiday.findMany({
      where: { doctorId },
      orderBy: { date: 'asc' },
    });

    return holidays;
  }

  static async createHoliday(doctorId: string, data: any) {
    const holiday = await prisma.holiday.create({
      data: {
        doctorId,
        date: new Date(data.date),
        reason: data.reason,
        isFullDay: data.isFullDay !== undefined ? data.isFullDay : true,
        startTime: data.startTime,
        endTime: data.endTime,
      },
    });

    return holiday;
  }

  static async deleteHoliday(holidayId: string, doctorId: string) {
    const holiday = await prisma.holiday.findFirst({
      where: { id: holidayId, doctorId },
    });

    if (!holiday) {
      throw new AppError('Holiday not found', 404);
    }

    await prisma.holiday.delete({
      where: { id: holidayId },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════════════════

  static async getAppointments(
    doctorId: string,
    filters: {
      status?: AppointmentStatus;
      date?: string;
      page?: number;
      limit?: number;
    }
  ) {
    const { status, date, page = 1, limit = 20 } = filters;

    const where: any = { doctorId };

    if (status) {
      where.status = status;
    }

    if (date) {
      const targetDate = new Date(date);
      const nextDay = new Date(targetDate);
      nextDay.setDate(nextDay.getDate() + 1);

      where.scheduledAt = {
        gte: targetDate,
        lt: nextDay,
      };
    }

    const [appointments, total] = await Promise.all([
      prisma.appointment.findMany({
        where,
        include: {
          patient: {
            include: { user: { select: safeUserSelect } },
          },
        },
        orderBy: { scheduledAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.appointment.count({ where }),
    ]);

    return { appointments, total, page, limit };
  }

  static async getAppointmentDetail(appointmentId: string, doctorId: string) {
    const appointment = await prisma.appointment.findFirst({
      where: {
        id: appointmentId,
        doctorId,
      },
      include: {
        patient: {
          include: {
            user: true,
            vitals: {
              orderBy: { recordedAt: 'desc' },
              take: 5,
            },
          },
        },
        prescription: {
          include: { medications: true },
        },
      },
    });

    if (!appointment) {
      throw new AppError('Appointment not found', 404);
    }

    return appointment;
  }

  static async startAppointment(appointmentId: string, doctorId: string) {
    const appointment = await prisma.appointment.findFirst({
      where: {
        id: appointmentId,
        doctorId,
      },
    });

    if (!appointment) {
      throw new AppError('Appointment not found', 404);
    }

    if (!['SCHEDULED', 'CONFIRMED'].includes(appointment.status)) {
      throw new AppError('Cannot start this appointment', 400);
    }

    const updated = await prisma.appointment.update({
      where: { id: appointmentId },
      data: { status: 'IN_PROGRESS' },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
    });

    return updated;
  }

  static async completeAppointment(appointmentId: string, doctorId: string) {
    const appointment = await prisma.appointment.findFirst({
      where: {
        id: appointmentId,
        doctorId,
      },
    });

    if (!appointment) {
      throw new AppError('Appointment not found', 404);
    }

    if (appointment.status !== 'IN_PROGRESS') {
      throw new AppError('Appointment must be in progress to complete', 400);
    }

    const updated = await prisma.appointment.update({
      where: { id: appointmentId },
      data: {
        status: 'COMPLETED',
        completedAt: new Date(),
      },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
    });

    return updated;
  }

  // ═══════════════════════════════════════════════════════════
  // PATIENTS
  // ═══════════════════════════════════════════════════════════

  static async getPatients(doctorId: string, query?: string) {
    // Get unique patients who have appointments with this doctor
    const appointments = await prisma.appointment.findMany({
      where: {
        doctorId,
        ...(query && {
          patient: {
            user: {
              OR: [
                { firstName: { contains: query, mode: 'insensitive' } },
                { lastName: { contains: query, mode: 'insensitive' } },
                { email: { contains: query, mode: 'insensitive' } },
              ],
            },
          },
        }),
      },
      select: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
                phone: true,
                avatar: true,
                dateOfBirth: true,
                gender: true,
              },
            },
          },
        },
      },
      distinct: ['patientId'],
    });

    // Get patient stats
    const patientsWithStats = await Promise.all(
      appointments.map(async (apt) => {
        const totalVisits = await prisma.appointment.count({
          where: {
            doctorId,
            patientId: apt.patient.id,
          },
        });

        const lastVisit = await prisma.appointment.findFirst({
          where: {
            doctorId,
            patientId: apt.patient.id,
            status: 'COMPLETED',
          },
          orderBy: { completedAt: 'desc' },
          select: { completedAt: true },
        });

        const nextAppointment = await prisma.appointment.findFirst({
          where: {
            doctorId,
            patientId: apt.patient.id,
            scheduledAt: { gte: new Date() },
            status: { in: ['SCHEDULED', 'CONFIRMED'] },
          },
          orderBy: { scheduledAt: 'asc' },
          select: { scheduledAt: true },
        });

        return {
          ...apt.patient,
          totalVisits,
          lastVisit: lastVisit?.completedAt,
          nextAppointment: nextAppointment?.scheduledAt,
        };
      })
    );

    return patientsWithStats;
  }

  static async getPatientDetail(patientId: string, doctorId: string) {
    const patient = await prisma.patient.findUnique({
      where: { id: patientId },
      include: {
        user: true,
        appointments: {
          where: { doctorId },
          orderBy: { scheduledAt: 'desc' },
          take: 10,
        },
        vitals: {
          orderBy: { recordedAt: 'desc' },
          take: 10,
        },
        prescriptions: {
          where: { doctorId },
          orderBy: { prescribedAt: 'desc' },
          take: 5,
          include: { medications: true },
        },
        medicalRecords: {
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
      },
    });

    if (!patient) {
      throw new AppError('Patient not found', 404);
    }

    return patient;
  }

  // ═══════════════════════════════════════════════════════════
  // PRESCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  static async getPrescriptions(
    doctorId: string,
    filters: {
      patientId?: string;
      page?: number;
      limit?: number;
    }
  ) {
    const { patientId, page = 1, limit = 10 } = filters;

    const where: any = { doctorId };
    if (patientId) {
      where.patientId = patientId;
    }

    const [prescriptions, total] = await Promise.all([
      prisma.prescription.findMany({
        where,
        include: {
          patient: {
            include: { user: { select: safeUserSelect } },
          },
          medications: true,
        },
        orderBy: { prescribedAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.prescription.count({ where }),
    ]);

    return { prescriptions, total, page, limit };
  }

  static async createPrescription(doctorId: string, data: any) {
    const { patientId, diagnosis, notes, followUpDate, medications } = data;

    // Verify patient exists
    const patient = await prisma.patient.findUnique({
      where: { id: patientId },
    });

    if (!patient) {
      throw new AppError('Patient not found', 404);
    }

    const prescription = await prisma.prescription.create({
      data: {
        patientId,
        doctorId,
        diagnosis,
        notes,
        followUpDate,
        medications: {
          create: medications,
        },
      },
      include: {
        medications: true,
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
    });

    return prescription;
  }

  static async getPrescriptionDetail(prescriptionId: string, doctorId: string) {
    const prescription = await prisma.prescription.findFirst({
      where: {
        id: prescriptionId,
        doctorId,
      },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
        medications: true,
      },
    });

    if (!prescription) {
      throw new AppError('Prescription not found', 404);
    }

    return prescription;
  }

  // ═══════════════════════════════════════════════════════════
  // REPORTS & ANALYTICS
  // ═══════════════════════════════════════════════════════════

  static async getReports(doctorId: string) {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfYear = new Date(now.getFullYear(), 0, 1);

    // Total appointments
    const [total, completed, cancelled, noShow] = await Promise.all([
      prisma.appointment.count({ where: { doctorId } }),
      prisma.appointment.count({ where: { doctorId, status: 'COMPLETED' } }),
      prisma.appointment.count({ where: { doctorId, status: 'CANCELLED' } }),
      prisma.appointment.count({ where: { doctorId, status: 'NO_SHOW' } }),
    ]);

    // Appointments by month (last 4 months)
    const byMonth: Record<string, number> = {};
    for (let i = 3; i >= 0; i--) {
      const month = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const nextMonth = new Date(now.getFullYear(), now.getMonth() - i + 1, 1);
      const count = await prisma.appointment.count({
        where: {
          doctorId,
          scheduledAt: {
            gte: month,
            lt: nextMonth,
          },
        },
      });
      byMonth[month.toLocaleDateString('en-US', { month: 'short' })] = count;
    }

    // Appointments by day of week
    const appointmentsRaw = await prisma.appointment.findMany({
      where: {
        doctorId,
        scheduledAt: { gte: startOfYear },
      },
      select: { scheduledAt: true },
    });

    const byDayOfWeek: Record<string, number> = {
      Mon: 0,
      Tue: 0,
      Wed: 0,
      Thu: 0,
      Fri: 0,
      Sat: 0,
      Sun: 0,
    };

    appointmentsRaw.forEach((apt) => {
      const day = apt.scheduledAt.toLocaleDateString('en-US', { weekday: 'short' });
      byDayOfWeek[day] = (byDayOfWeek[day] || 0) + 1;
    });

    // Appointments by time slot
    const byTimeSlot: Record<string, number> = {};
    appointmentsRaw.forEach((apt) => {
      const hour = apt.scheduledAt.getHours();
      const timeSlot = `${hour.toString().padStart(2, '0')}:00`;
      byTimeSlot[timeSlot] = (byTimeSlot[timeSlot] || 0) + 1;
    });

    return {
      appointmentStats: {
        total,
        completed,
        cancelled,
        noShow,
        byMonth,
        byDayOfWeek,
        byTimeSlot,
      },
    };
  }

  static async getDemographics(doctorId: string) {
    // Get all patients
    const appointments = await prisma.appointment.findMany({
      where: { doctorId },
      select: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
      distinct: ['patientId'],
    });

    // Age groups
    const ageGroups: Record<string, number> = {
      '0-18': 0,
      '19-35': 0,
      '36-50': 0,
      '51-65': 0,
      '65+': 0,
    };

    // Gender distribution
    const genderDistribution: Record<string, number> = {
      MALE: 0,
      FEMALE: 0,
      OTHER: 0,
    };

    appointments.forEach((apt) => {
      // Age calculation
      if (apt.patient.user.dateOfBirth) {
        const age = Math.floor(
          (Date.now() - apt.patient.user.dateOfBirth.getTime()) /
            (365.25 * 24 * 60 * 60 * 1000)
        );

        if (age <= 18) ageGroups['0-18']++;
        else if (age <= 35) ageGroups['19-35']++;
        else if (age <= 50) ageGroups['36-50']++;
        else if (age <= 65) ageGroups['51-65']++;
        else ageGroups['65+']++;
      }

      // Gender
      if (apt.patient.user.gender) {
        genderDistribution[apt.patient.user.gender] =
          (genderDistribution[apt.patient.user.gender] || 0) + 1;
      }
    });

    const totalPatients = appointments.length;
    const newPatientsThisMonth = await prisma.appointment.count({
      where: {
        doctorId,
        createdAt: {
          gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
        },
      },
      distinct: ['patientId'],
    });

    return {
      ageGroups,
      genderDistribution,
      totalPatients,
      newPatientsThisMonth,
    };
  }

  static async getTopConditions(doctorId: string) {
    // Get all prescriptions with diagnosis
    const prescriptions = await prisma.prescription.findMany({
      where: { doctorId },
      select: { diagnosis: true },
    });

    // Count diagnoses
    const diagnosisCount: Record<string, number> = {};
    prescriptions.forEach((p) => {
      if (p.diagnosis) {
        diagnosisCount[p.diagnosis] = (diagnosisCount[p.diagnosis] || 0) + 1;
      }
    });

    // Convert to array and sort
    const conditions = Object.entries(diagnosisCount)
      .map(([name, count]) => ({
        name,
        count,
        percentage: (count / prescriptions.length) * 100,
      }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    return conditions;
  }

  // ═══════════════════════════════════════════════════════════
  // OFFLINE BOOKING (Walk-in patients)
  // ═══════════════════════════════════════════════════════════

  static async createOfflineBooking(doctorId: string, data: any) {
    // First create patient if doesn't exist
    let patient = await prisma.patient.findFirst({
      where: {
        user: {
          email: data.email,
        },
      },
    });

    if (!patient) {
      // Create new user and patient
      const bcrypt = require('bcryptjs');
      const tempPassword = Math.random().toString(36).slice(-8);

      const user = await prisma.user.create({
        data: {
          email: data.email,
          password: await bcrypt.hash(tempPassword, 12),
          firstName: data.firstName,
          lastName: data.lastName,
          phone: data.phone,
          role: 'PATIENT',
          patient: {
            create: {},
          },
        },
        include: { patient: true },
      });

      patient = user.patient!;
    }

    // Create appointment
    const appointment = await prisma.appointment.create({
      data: {
        patientId: patient.id,
        doctorId,
        scheduledAt: new Date(data.scheduledAt),
        type: data.type || 'CONSULTATION',
        symptoms: data.symptoms,
        notes: data.notes,
        status: 'SCHEDULED',
      },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
    });

    return appointment;
  }
}