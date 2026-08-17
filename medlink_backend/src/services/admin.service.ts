import prisma from '../config/database';
import { AppError } from '../middlewares/error.middleware';
import bcrypt from 'bcryptjs';
import { UserRole, AppointmentStatus } from '@prisma/client';
import { safeUserSelect } from '../utils/prisma-select.util';

export class AdminService {
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════

  static async getDashboard() {
    const [
      totalDoctors,
      totalPatients,
      totalAppointments,
      todayAppointments,
      activeSessions,
      pendingAppointments,
      completedToday,
    ] = await Promise.all([
      prisma.doctor.count(),
      prisma.patient.count(),
      prisma.appointment.count(),
      prisma.appointment.count({
        where: {
          scheduledAt: {
            gte: new Date(new Date().setHours(0, 0, 0, 0)),
            lt: new Date(new Date().setHours(23, 59, 59, 999)),
          },
        },
      }),
      prisma.user.count({
        where: {
          isActive: true,
        },
      }),
      prisma.appointment.count({
        where: {
          status: { in: ['SCHEDULED', 'CONFIRMED'] },
        },
      }),
      prisma.appointment.count({
        where: {
          status: 'COMPLETED',
          scheduledAt: {
            gte: new Date(new Date().setHours(0, 0, 0, 0)),
          },
        },
      }),
    ]);

    // Get recent activity
    const recentActivity = await this.getRecentActivity();

    return {
      stats: {
        totalDoctors,
        totalPatients,
        totalAppointments,
        todayAppointments,
        activeSessions,
        pendingAppointments,
        completedToday,
      },
      recentActivity,
    };
  }

  static async getRecentActivity() {
    // Get recent registrations
    const recentUsers = await prisma.user.findMany({
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        role: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });

    // Get recent appointments
    const recentAppointments = await prisma.appointment.findMany({
      select: {
        id: true,
        scheduledAt: true,
        status: true,
        createdAt: true,
        patient: {
          include: { user: { select: safeUserSelect } },
        },
        doctor: {
          include: { user: { select: safeUserSelect } },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });

    // Get recent emergency alerts
    const recentAlerts = await prisma.emergencyAlert.findMany({
      where: { isActive: true },
      include: {
        patient: {
          include: { user: { select: safeUserSelect } },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    return {
      recentUsers,
      recentAppointments,
      recentAlerts,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // DOCTORS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static async getDoctors(filters: {
    search?: string;
    specialty?: string;
    isAvailable?: boolean;
    page?: number;
    limit?: number;
  }) {
    const { search, specialty, isAvailable, page = 1, limit = 20 } = filters;

    const where: any = {};

    if (search) {
      where.user = {
        OR: [
          { firstName: { contains: search, mode: 'insensitive' } },
          { lastName: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      };
    }

    if (specialty) {
      where.specialty = { contains: specialty, mode: 'insensitive' };
    }

    if (isAvailable !== undefined) {
      where.isAvailable = isAvailable;
    }

    const [doctors, total] = await Promise.all([
      prisma.doctor.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              email: true,
              firstName: true,
              lastName: true,
              phone: true,
              avatar: true,
              isActive: true,
              isVerified: true,
              createdAt: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.doctor.count({ where }),
    ]);

    // Get appointment counts for each doctor
    const doctorsWithStats = await Promise.all(
      doctors.map(async (doctor) => {
        const appointmentCount = await prisma.appointment.count({
          where: { doctorId: doctor.id },
        });

        return {
          ...doctor,
          appointmentCount,
        };
      })
    );

    return { doctors: doctorsWithStats, total, page, limit };
  }

  static async getDoctorDetail(doctorId: string) {
    const doctor = await prisma.doctor.findUnique({
      where: { id: doctorId },
      include: {
        user: true,
        appointments: {
          take: 10,
          orderBy: { scheduledAt: 'desc' },
          include: {
            patient: {
              include: { user: { select: safeUserSelect } },
            },
          },
        },
        availabilitySlots: true,
        holidays: true,
      },
    });

    if (!doctor) {
      throw new AppError('Doctor not found', 404);
    }

    // Get stats
    const [totalAppointments, completedAppointments, totalPatients] =
      await Promise.all([
        prisma.appointment.count({ where: { doctorId } }),
        prisma.appointment.count({
          where: { doctorId, status: 'COMPLETED' },
        }),
        prisma.appointment.findMany({
          where: { doctorId },
          select: { patientId: true },
          distinct: ['patientId'],
        }),
      ]);

    return {
      ...doctor,
      stats: {
        totalAppointments,
        completedAppointments,
        totalPatients: totalPatients.length,
      },
    };
  }

  static async createDoctor(data: any) {
    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingUser) {
      throw new AppError('Email already registered', 409);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(data.password, 12);

    // Create user and doctor
    const user = await prisma.user.create({
      data: {
        email: data.email,
        password: hashedPassword,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
        role: 'DOCTOR',
        isVerified: true, // Admin-created doctors are auto-verified
        doctor: {
          create: {
            specialty: data.specialty,
            qualifications: data.qualifications || '',
            experienceYears: data.experienceYears || 0,
            consultationFee: data.consultationFee || 500,
            bio: data.bio,
            clinicAddress: data.clinicAddress,
          },
        },
      },
      include: {
        doctor: true,
      },
    });

    return user;
  }

  static async updateDoctor(doctorId: string, data: any) {
    const doctor = await prisma.doctor.findUnique({
      where: { id: doctorId },
    });

    if (!doctor) {
      throw new AppError('Doctor not found', 404);
    }

    // Update doctor
    const updated = await prisma.doctor.update({
      where: { id: doctorId },
      data: {
        specialty: data.specialty,
        qualifications: data.qualifications,
        experienceYears: data.experienceYears,
        consultationFee: data.consultationFee,
        bio: data.bio,
        clinicAddress: data.clinicAddress,
        isAvailable: data.isAvailable,
      },
      include: {
        user: true,
      },
    });

    // Update user if needed
    if (data.phone || data.isActive !== undefined) {
      await prisma.user.update({
        where: { id: doctor.userId },
        data: {
          phone: data.phone,
          isActive: data.isActive,
        },
      });
    }

    return updated;
  }

  static async deleteDoctor(doctorId: string) {
    const doctor = await prisma.doctor.findUnique({
      where: { id: doctorId },
    });

    if (!doctor) {
      throw new AppError('Doctor not found', 404);
    }

    // Soft delete - deactivate user instead
    await prisma.user.update({
      where: { id: doctor.userId },
      data: { isActive: false },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // PATIENTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static async getPatients(filters: {
    search?: string;
    page?: number;
    limit?: number;
  }) {
    const { search, page = 1, limit = 20 } = filters;

    const where: any = {};

    if (search) {
      where.user = {
        OR: [
          { firstName: { contains: search, mode: 'insensitive' } },
          { lastName: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      };
    }

    const [patients, total] = await Promise.all([
      prisma.patient.findMany({
        where,
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
              isActive: true,
              isVerified: true,
              createdAt: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.patient.count({ where }),
    ]);

    // Get appointment counts
    const patientsWithStats = await Promise.all(
      patients.map(async (patient) => {
        const appointmentCount = await prisma.appointment.count({
          where: { patientId: patient.id },
        });

        const lastAppointment = await prisma.appointment.findFirst({
          where: { patientId: patient.id, status: 'COMPLETED' },
          orderBy: { completedAt: 'desc' },
          select: { completedAt: true },
        });

        return {
          ...patient,
          appointmentCount,
          lastAppointment: lastAppointment?.completedAt,
        };
      })
    );

    return { patients: patientsWithStats, total, page, limit };
  }

  static async getPatientDetail(patientId: string) {
    const patient = await prisma.patient.findUnique({
      where: { id: patientId },
      include: {
        user: true,
        appointments: {
          take: 20,
          orderBy: { scheduledAt: 'desc' },
          include: {
            doctor: {
              include: { user: { select: safeUserSelect } },
            },
          },
        },
        medicalRecords: {
          take: 10,
          orderBy: { createdAt: 'desc' },
        },
        prescriptions: {
          take: 10,
          orderBy: { prescribedAt: 'desc' },
          include: {
            medications: true,
            doctor: {
              include: { user: { select: safeUserSelect } },
            },
          },
        },
        vitals: {
          take: 10,
          orderBy: { recordedAt: 'desc' },
        },
      },
    });

    if (!patient) {
      throw new AppError('Patient not found', 404);
    }

    return patient;
  }

  static async updatePatientStatus(patientId: string, isActive: boolean) {
    const patient = await prisma.patient.findUnique({
      where: { id: patientId },
    });

    if (!patient) {
      throw new AppError('Patient not found', 404);
    }

    await prisma.user.update({
      where: { id: patient.userId },
      data: { isActive },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static async getAppointments(filters: {
    status?: AppointmentStatus;
    doctorId?: string;
    patientId?: string;
    startDate?: string;
    endDate?: string;
    page?: number;
    limit?: number;
  }) {
    const {
      status,
      doctorId,
      patientId,
      startDate,
      endDate,
      page = 1,
      limit = 20,
    } = filters;

    const where: any = {};

    if (status) {
      where.status = status;
    }

    if (doctorId) {
      where.doctorId = doctorId;
    }

    if (patientId) {
      where.patientId = patientId;
    }

    if (startDate || endDate) {
      where.scheduledAt = {};
      if (startDate) {
        where.scheduledAt.gte = new Date(startDate);
      }
      if (endDate) {
        where.scheduledAt.lte = new Date(endDate);
      }
    }

    const [appointments, total] = await Promise.all([
      prisma.appointment.findMany({
        where,
        include: {
          patient: {
            include: { user: { select: safeUserSelect } },
          },
          doctor: {
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

  static async updateAppointmentStatus(
    appointmentId: string,
    status: AppointmentStatus
  ) {
    const appointment = await prisma.appointment.findUnique({
      where: { id: appointmentId },
    });

    if (!appointment) {
      throw new AppError('Appointment not found', 404);
    }

    const updated = await prisma.appointment.update({
      where: { id: appointmentId },
      data: {
        status,
        ...(status === 'COMPLETED' && { completedAt: new Date() }),
        ...(status === 'CANCELLED' && { cancelledAt: new Date() }),
      },
      include: {
        patient: { include: { user: { select: safeUserSelect } } },
        doctor: { include: { user: { select: safeUserSelect } } },
      },
    });

    return updated;
  }

  static async deleteAppointment(appointmentId: string) {
    const appointment = await prisma.appointment.findUnique({
      where: { id: appointmentId },
    });

    if (!appointment) {
      throw new AppError('Appointment not found', 404);
    }

    await prisma.appointment.delete({
      where: { id: appointmentId },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SYSTEM STATS
  // ═══════════════════════════════════════════════════════════

  static async getSystemStats() {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);

    // Current month stats
    const [
      usersThisMonth,
      appointmentsThisMonth,
      revenueThisMonth,
      usersLastMonth,
      appointmentsLastMonth,
    ] = await Promise.all([
      prisma.user.count({
        where: { createdAt: { gte: startOfMonth } },
      }),
      prisma.appointment.count({
        where: { createdAt: { gte: startOfMonth } },
      }),
      prisma.appointment.count({
        where: {
          createdAt: { gte: startOfMonth },
          status: 'COMPLETED',
        },
      }),
      prisma.user.count({
        where: {
          createdAt: {
            gte: startOfLastMonth,
            lt: startOfMonth,
          },
        },
      }),
      prisma.appointment.count({
        where: {
          createdAt: {
            gte: startOfLastMonth,
            lt: startOfMonth,
          },
        },
      }),
    ]);

    // Calculate growth percentages
    const userGrowth =
      usersLastMonth > 0
        ? ((usersThisMonth - usersLastMonth) / usersLastMonth) * 100
        : 0;

    const appointmentGrowth =
      appointmentsLastMonth > 0
        ? ((appointmentsThisMonth - appointmentsLastMonth) /
            appointmentsLastMonth) *
          100
        : 0;

    // Get appointment status distribution
    const statusDistribution = await prisma.appointment.groupBy({
      by: ['status'],
      _count: true,
    });

    // Get specialty distribution
    const specialtyDistribution = await prisma.doctor.groupBy({
      by: ['specialty'],
      _count: true,
    });

    return {
      currentMonth: {
        users: usersThisMonth,
        appointments: appointmentsThisMonth,
        revenue: revenueThisMonth, // This would be actual revenue calculation
      },
      growth: {
        users: userGrowth,
        appointments: appointmentGrowth,
      },
      statusDistribution,
      specialtyDistribution,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // SYSTEM SETTINGS (basic)
  // ═══════════════════════════════════════════════════════════

  static async getSettings() {
    // In a real app, these would come from a settings table
    return {
      app: {
        name: 'MedCare',
        version: '1.0.0',
        maintenanceMode: false,
      },
      appointments: {
        defaultSlotDuration: 30,
        maxSlotsPerDay: 20,
        allowCancellation: true,
        cancellationDeadlineHours: 24,
      },
      notifications: {
        emailEnabled: true,
        smsEnabled: false,
        pushEnabled: true,
        appointmentReminders: true,
        reminderHoursBefore: 24,
      },
    };
  }
}