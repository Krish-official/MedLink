import prisma from '../config/database';
import { AppError } from '../middlewares/error.middleware';
import { AppointmentStatus, AppointmentType, RecordType } from '@prisma/client';

export class PatientService {
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════

  static async getDashboard(patientId: string) {
    // Get upcoming appointment
    const upcomingAppointment = await prisma.appointment.findFirst({
      where: {
        patientId,
        scheduledAt: { gte: new Date() },
        status: { in: ['SCHEDULED', 'CONFIRMED'] },
      },
      include: {
        doctor: {
          include: { user: true },
        },
      },
      orderBy: { scheduledAt: 'asc' },
    });

    // Get appointment stats
    const [totalAppointments, completedAppointments, cancelledAppointments] =
      await Promise.all([
        prisma.appointment.count({ where: { patientId } }),
        prisma.appointment.count({
          where: { patientId, status: 'COMPLETED' },
        }),
        prisma.appointment.count({
          where: { patientId, status: 'CANCELLED' },
        }),
      ]);

    return {
      upcomingAppointment,
      totalAppointments,
      completedAppointments,
      cancelledAppointments,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════

  static async getProfile(patientId: string) {
    const patient = await prisma.patient.findUnique({
      where: { id: patientId },
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
            isVerified: true,
            createdAt: true,
            updatedAt: true,
          },
        },
      },
    });

    if (!patient) {
      throw new AppError('Patient not found', 404);
    }

    return patient;
  }

  static async updateProfile(patientId: string, data: any) {
    const { bloodGroup, allergies, chronicDiseases, emergencyContact, address } =
      data;

    const patient = await prisma.patient.update({
      where: { id: patientId },
      data: {
        bloodGroup,
        allergies,
        chronicDiseases,
        emergencyContact,
        address,
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
            dateOfBirth: true,
            gender: true,
          },
        },
      },
    });

    return patient;
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════════════════

  static async getAppointments(
    patientId: string,
    filters: {
      status?: AppointmentStatus;
      upcoming?: boolean;
      page?: number;
      limit?: number;
    }
  ) {
    const { status, upcoming, page = 1, limit = 10 } = filters;

    const where: any = { patientId };

    if (status) {
      where.status = status;
    }

    if (upcoming !== undefined) {
      where.scheduledAt = upcoming
        ? { gte: new Date() }
        : { lt: new Date() };
    }

    const [appointments, total] = await Promise.all([
      prisma.appointment.findMany({
        where,
        include: {
          doctor: {
            include: { user: true },
          },
          prescription: {
            include: { medications: true },
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

  static async getAppointmentDetail(appointmentId: string, patientId: string) {
    const appointment = await prisma.appointment.findFirst({
      where: {
        id: appointmentId,
        patientId,
      },
      include: {
        doctor: {
          include: { user: true },
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

  static async cancelAppointment(
    appointmentId: string,
    patientId: string,
    reason?: string
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
      throw new AppError('Cannot cancel this appointment', 400);
    }

    const updatedAppointment = await prisma.appointment.update({
      where: { id: appointmentId },
      data: {
        status: 'CANCELLED',
        cancelledAt: new Date(),
        cancellationReason: reason,
      },
      include: {
        doctor: {
          include: { user: true },
        },
      },
    });

    return updatedAppointment;
  }

  // ═══════════════════════════════════════════════════════════
  // MEDICAL RECORDS
  // ═══════════════════════════════════════════════════════════

  static async getMedicalRecords(
    patientId: string,
    filters: {
      type?: RecordType;
      page?: number;
      limit?: number;
    }
  ) {
    const { type, page = 1, limit = 10 } = filters;

    const where: any = { patientId };
    if (type) {
      where.type = type;
    }

    const [records, total] = await Promise.all([
      prisma.medicalRecord.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.medicalRecord.count({ where }),
    ]);

    return { records, total, page, limit };
  }

  static async uploadMedicalRecord(patientId: string, data: any) {
    const record = await prisma.medicalRecord.create({
      data: {
        patientId,
        title: data.title,
        type: data.type,
        description: data.description,
        fileUrl: data.fileUrl,
        fileType: data.fileType,
        fileSize: data.fileSize,
        recordDate: data.recordDate ? new Date(data.recordDate) : undefined,
        uploadedBy: patientId,
      },
    });

    return record;
  }

  static async deleteMedicalRecord(recordId: string, patientId: string) {
    const record = await prisma.medicalRecord.findFirst({
      where: {
        id: recordId,
        patientId,
      },
    });

    if (!record) {
      throw new AppError('Medical record not found', 404);
    }

    await prisma.medicalRecord.delete({
      where: { id: recordId },
    });

    // TODO: Delete file from storage
    // await StorageService.deleteFile(record.fileUrl);
  }

  // ═══════════════════════════════════════════════════════════
  // PRESCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  static async getPrescriptions(
    patientId: string,
    filters: {
      page?: number;
      limit?: number;
    }
  ) {
    const { page = 1, limit = 10 } = filters;

    const [prescriptions, total] = await Promise.all([
      prisma.prescription.findMany({
        where: { patientId },
        include: {
          doctor: {
            include: { user: true },
          },
          medications: true,
        },
        orderBy: { prescribedAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.prescription.count({ where: { patientId } }),
    ]);

    return { prescriptions, total, page, limit };
  }

  static async getPrescriptionDetail(prescriptionId: string, patientId: string) {
    const prescription = await prisma.prescription.findFirst({
      where: {
        id: prescriptionId,
        patientId,
      },
      include: {
        doctor: {
          include: { user: true },
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
  // VITALS
  // ═══════════════════════════════════════════════════════════

  static async getVitals(
    patientId: string,
    filters: {
      startDate?: string;
      endDate?: string;
      limit?: number;
    }
  ) {
    const { startDate, endDate, limit = 50 } = filters;

    const where: any = { patientId };

    if (startDate || endDate) {
      where.recordedAt = {};
      if (startDate) {
        where.recordedAt.gte = new Date(startDate);
      }
      if (endDate) {
        where.recordedAt.lte = new Date(endDate);
      }
    }

    const vitals = await prisma.vitalRecord.findMany({
      where,
      orderBy: { recordedAt: 'desc' },
      take: limit,
    });

    return vitals;
  }

  static async addVital(patientId: string, data: any) {
    const vital = await prisma.vitalRecord.create({
      data: {
        patientId,
        bloodPressureSystolic: data.bloodPressureSystolic,
        bloodPressureDiastolic: data.bloodPressureDiastolic,
        heartRate: data.heartRate,
        temperature: data.temperature,
        oxygenSaturation: data.oxygenSaturation,
        weight: data.weight,
        height: data.height,
        bmi: data.bmi,
        notes: data.notes,
        recordedBy: patientId,
      },
    });

    return vital;
  }

  // ═══════════════════════════════════════════════════════════
  // EMERGENCY
  // ═══════════════════════════════════════════════════════════

  static async createEmergencyAlert(patientId: string, data: any) {
    const alert = await prisma.emergencyAlert.create({
      data: {
        patientId,
        location: data.location,
        message: data.message,
      },
    });

    // TODO: Send notifications to emergency contacts
    // TODO: Alert nearby hospitals
    // await NotificationService.sendEmergencyAlert(patientId, alert);

    return alert;
  }

  static async getEmergencyAlerts(patientId: string) {
    const alerts = await prisma.emergencyAlert.findMany({
      where: { patientId },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });

    return alerts;
  }

  static async resolveEmergencyAlert(alertId: string, patientId: string) {
    const alert = await prisma.emergencyAlert.findFirst({
      where: {
        id: alertId,
        patientId,
      },
    });

    if (!alert) {
      throw new AppError('Emergency alert not found', 404);
    }

    const updatedAlert = await prisma.emergencyAlert.update({
      where: { id: alertId },
      data: {
        isActive: false,
        resolvedAt: new Date(),
      },
    });

    return updatedAlert;
  }
}