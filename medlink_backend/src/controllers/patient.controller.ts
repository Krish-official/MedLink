import { Request, Response, NextFunction } from 'express';
import { PatientService } from '../services/patient.service';
import { ResponseUtil } from '../utils/response.util';
import prisma from '../config/database';

export class PatientController {
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════

  static async getDashboard(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const dashboard = await PatientService.getDashboard(patient.id);
      return ResponseUtil.success(res, dashboard, 'Dashboard retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════

  static async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const profile = await PatientService.getProfile(patient.id);
      return ResponseUtil.success(res, profile, 'Profile retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const updatedProfile = await PatientService.updateProfile(patient.id, req.body);
      return ResponseUtil.success(res, updatedProfile, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════════════════

  static async getAppointments(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const { status, upcoming, page, limit } = req.query;
      const result = await PatientService.getAppointments(patient.id, {
        status: status as any,
        upcoming: upcoming === 'true' ? true : upcoming === 'false' ? false : undefined,
        page: page ? parseInt(page as string) : undefined,
        limit: limit ? parseInt(limit as string) : undefined,
      });

      return ResponseUtil.paginated(
        res,
        result.appointments,
        result.page,
        result.limit,
        result.total
      );
    } catch (error) {
      next(error);
    }
  }

  static async getAppointmentDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const appointment = await PatientService.getAppointmentDetail(
        req.params.id,
        patient.id
      );
      return ResponseUtil.success(res, appointment, 'Appointment retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async cancelAppointment(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const appointment = await PatientService.cancelAppointment(
        req.params.id,
        patient.id,
        req.body.reason
      );
      return ResponseUtil.success(res, appointment, 'Appointment cancelled successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MEDICAL RECORDS
  // ═══════════════════════════════════════════════════════════

  static async getMedicalRecords(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const { type, page, limit } = req.query;
      const result = await PatientService.getMedicalRecords(patient.id, {
        type: type as any,
        page: page ? parseInt(page as string) : undefined,
        limit: limit ? parseInt(limit as string) : undefined,
      });

      return ResponseUtil.paginated(
        res,
        result.records,
        result.page,
        result.limit,
        result.total
      );
    } catch (error) {
      next(error);
    }
  }

  static async uploadMedicalRecord(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      // File upload will be handled by multer middleware
      // For now, assume fileUrl is provided in body
      const record = await PatientService.uploadMedicalRecord(patient.id, req.body);
      return ResponseUtil.success(res, record, 'Medical record uploaded successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async deleteMedicalRecord(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      await PatientService.deleteMedicalRecord(req.params.id, patient.id);
      return ResponseUtil.success(res, null, 'Medical record deleted successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRESCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  static async getPrescriptions(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const { page, limit } = req.query;
      const result = await PatientService.getPrescriptions(patient.id, {
        page: page ? parseInt(page as string) : undefined,
        limit: limit ? parseInt(limit as string) : undefined,
      });

      return ResponseUtil.paginated(
        res,
        result.prescriptions,
        result.page,
        result.limit,
        result.total
      );
    } catch (error) {
      next(error);
    }
  }

  static async getPrescriptionDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const prescription = await PatientService.getPrescriptionDetail(
        req.params.id,
        patient.id
      );
      return ResponseUtil.success(res, prescription, 'Prescription retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // VITALS
  // ═══════════════════════════════════════════════════════════

  static async getVitals(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const { startDate, endDate, limit } = req.query;
      const vitals = await PatientService.getVitals(patient.id, {
        startDate: startDate as string,
        endDate: endDate as string,
        limit: limit ? parseInt(limit as string) : undefined,
      });

      return ResponseUtil.success(res, vitals, 'Vitals retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async addVital(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const vital = await PatientService.addVital(patient.id, req.body);
      return ResponseUtil.success(res, vital, 'Vital added successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // EMERGENCY
  // ═══════════════════════════════════════════════════════════

  static async createEmergencyAlert(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const alert = await PatientService.createEmergencyAlert(patient.id, req.body);
      return ResponseUtil.success(res, alert, 'Emergency alert created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async getEmergencyAlerts(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const alerts = await PatientService.getEmergencyAlerts(patient.id);
      return ResponseUtil.success(res, alerts, 'Emergency alerts retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async resolveEmergencyAlert(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const alert = await PatientService.resolveEmergencyAlert(req.params.id, patient.id);
      return ResponseUtil.success(res, alert, 'Emergency alert resolved successfully');
    } catch (error) {
      next(error);
    }
  }
}