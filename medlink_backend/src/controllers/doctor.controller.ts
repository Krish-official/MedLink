import { Request, Response, NextFunction } from 'express';
import { DoctorService } from '../services/doctor.service';
import { ResponseUtil } from '../utils/response.util';
import prisma from '../config/database';

export class DoctorController {
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════

  static async getDashboard(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const dashboard = await DoctorService.getDashboard(doctor.id);
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
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const profile = await DoctorService.getProfile(doctor.id);
      return ResponseUtil.success(res, profile, 'Profile retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const profile = await DoctorService.updateProfile(doctor.id, req.body);
      return ResponseUtil.success(res, profile, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SCHEDULE & AVAILABILITY
  // ═══════════════════════════════════════════════════════════

  static async getAvailability(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const availability = await DoctorService.getAvailability(doctor.id);
      return ResponseUtil.success(res, availability, 'Availability retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async createAvailability(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const slot = await DoctorService.createAvailability(doctor.id, req.body);
      return ResponseUtil.success(res, slot, 'Availability created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async updateAvailability(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const slot = await DoctorService.updateAvailability(
        req.params.id,
        doctor.id,
        req.body
      );
      return ResponseUtil.success(res, slot, 'Availability updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async deleteAvailability(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      await DoctorService.deleteAvailability(req.params.id, doctor.id);
      return ResponseUtil.success(res, null, 'Availability deleted successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS
  // ═══════════════════════════════════════════════════════════

  static async getHolidays(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const holidays = await DoctorService.getHolidays(doctor.id);
      return ResponseUtil.success(res, holidays, 'Holidays retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async createHoliday(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const holiday = await DoctorService.createHoliday(doctor.id, req.body);
      return ResponseUtil.success(res, holiday, 'Holiday created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async deleteHoliday(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      await DoctorService.deleteHoliday(req.params.id, doctor.id);
      return ResponseUtil.success(res, null, 'Holiday deleted successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════════════════

  static async getAppointments(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const { status, date, page, limit } = req.query;
      const result = await DoctorService.getAppointments(doctor.id, {
        status: status as any,
        date: date as string,
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
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const appointment = await DoctorService.getAppointmentDetail(
        req.params.id,
        doctor.id
      );
      return ResponseUtil.success(res, appointment, 'Appointment retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async startAppointment(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const appointment = await DoctorService.startAppointment(req.params.id, doctor.id);
      return ResponseUtil.success(res, appointment, 'Appointment started successfully');
    } catch (error) {
      next(error);
    }
  }

  static async completeAppointment(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const appointment = await DoctorService.completeAppointment(
        req.params.id,
        doctor.id
      );
      return ResponseUtil.success(res, appointment, 'Appointment completed successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PATIENTS
  // ═══════════════════════════════════════════════════════════

  static async getPatients(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const { q } = req.query;
      const patients = await DoctorService.getPatients(doctor.id, q as string);
      return ResponseUtil.success(res, patients, 'Patients retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getPatientDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const patient = await DoctorService.getPatientDetail(req.params.id, doctor.id);
      return ResponseUtil.success(res, patient, 'Patient details retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRESCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  static async getPrescriptions(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const { patientId, page, limit } = req.query;
      const result = await DoctorService.getPrescriptions(doctor.id, {
        patientId: patientId as string,
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

  static async createPrescription(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const prescription = await DoctorService.createPrescription(doctor.id, req.body);
      return ResponseUtil.success(
        res,
        prescription,
        'Prescription created successfully',
        201
      );
    } catch (error) {
      next(error);
    }
  }

  static async getPrescriptionDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const prescription = await DoctorService.getPrescriptionDetail(
        req.params.id,
        doctor.id
      );
      return ResponseUtil.success(res, prescription, 'Prescription retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REPORTS & ANALYTICS
  // ═══════════════════════════════════════════════════════════

  static async getReports(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const reports = await DoctorService.getReports(doctor.id);
      return ResponseUtil.success(res, reports, 'Reports retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getDemographics(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const demographics = await DoctorService.getDemographics(doctor.id);
      return ResponseUtil.success(res, demographics, 'Demographics retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getTopConditions(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const conditions = await DoctorService.getTopConditions(doctor.id);
      return ResponseUtil.success(res, conditions, 'Top conditions retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // OFFLINE BOOKING
  // ═══════════════════════════════════════════════════════════

  static async createOfflineBooking(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await prisma.doctor.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!doctor) {
        throw new Error('Doctor profile not found');
      }

      const appointment = await DoctorService.createOfflineBooking(doctor.id, req.body);
      return ResponseUtil.success(
        res,
        appointment,
        'Walk-in appointment created successfully',
        201
      );
    } catch (error) {
      next(error);
    }
  }
}