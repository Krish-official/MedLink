import { Request, Response, NextFunction } from 'express';
import { AdminService } from '../services/admin.service';
import { ResponseUtil } from '../utils/response.util';

export class AdminController {
  // ═══════════════════════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════════════════════

  static async getDashboard(req: Request, res: Response, next: NextFunction) {
    try {
      const dashboard = await AdminService.getDashboard();
      return ResponseUtil.success(res, dashboard, 'Dashboard retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DOCTORS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static async getDoctors(req: Request, res: Response, next: NextFunction) {
    try {
      const { search, specialty, isAvailable, page, limit } = req.query;
      const result = await AdminService.getDoctors({
        search: search as string,
        specialty: specialty as string,
        isAvailable: isAvailable === 'true' ? true : isAvailable === 'false' ? false : undefined,
        page: page ? parseInt(page as string) : undefined,
        limit: limit ? parseInt(limit as string) : undefined,
      });

      return ResponseUtil.paginated(
        res,
        result.doctors,
        result.page,
        result.limit,
        result.total
      );
    } catch (error) {
      next(error);
    }
  }

  static async getDoctorDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await AdminService.getDoctorDetail(req.params.id);
      return ResponseUtil.success(res, doctor, 'Doctor details retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async createDoctor(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await AdminService.createDoctor(req.body);
      return ResponseUtil.success(res, doctor, 'Doctor created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  static async updateDoctor(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await AdminService.updateDoctor(req.params.id, req.body);
      return ResponseUtil.success(res, doctor, 'Doctor updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async deleteDoctor(req: Request, res: Response, next: NextFunction) {
    try {
      await AdminService.deleteDoctor(req.params.id);
      return ResponseUtil.success(res, null, 'Doctor deactivated successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PATIENTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static async getPatients(req: Request, res: Response, next: NextFunction) {
    try {
      const { search, page, limit } = req.query;
      const result = await AdminService.getPatients({
        search: search as string,
        page: page ? parseInt(page as string) : undefined,
        limit: limit ? parseInt(limit as string) : undefined,
      });

      return ResponseUtil.paginated(
        res,
        result.patients,
        result.page,
        result.limit,
        result.total
      );
    } catch (error) {
      next(error);
    }
  }

  static async getPatientDetail(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await AdminService.getPatientDetail(req.params.id);
      return ResponseUtil.success(res, patient, 'Patient details retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async updatePatientStatus(req: Request, res: Response, next: NextFunction) {
    try {
      await AdminService.updatePatientStatus(req.params.id, req.body.isActive);
      return ResponseUtil.success(res, null, 'Patient status updated successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPOINTMENTS MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  static async getAppointments(req: Request, res: Response, next: NextFunction) {
    try {
      const { status, doctorId, patientId, startDate, endDate, page, limit } = req.query;
      const result = await AdminService.getAppointments({
        status: status as any,
        doctorId: doctorId as string,
        patientId: patientId as string,
        startDate: startDate as string,
        endDate: endDate as string,
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

  static async updateAppointmentStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const appointment = await AdminService.updateAppointmentStatus(
        req.params.id,
        req.body.status
      );
      return ResponseUtil.success(res, appointment, 'Appointment status updated successfully');
    } catch (error) {
      next(error);
    }
  }

  static async deleteAppointment(req: Request, res: Response, next: NextFunction) {
    try {
      await AdminService.deleteAppointment(req.params.id);
      return ResponseUtil.success(res, null, 'Appointment deleted successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SYSTEM STATS & SETTINGS
  // ═══════════════════════════════════════════════════════════

  static async getSystemStats(req: Request, res: Response, next: NextFunction) {
    try {
      const stats = await AdminService.getSystemStats();
      return ResponseUtil.success(res, stats, 'System stats retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  static async getSettings(req: Request, res: Response, next: NextFunction) {
    try {
      const settings = await AdminService.getSettings();
      return ResponseUtil.success(res, settings, 'Settings retrieved successfully');
    } catch (error) {
      next(error);
    }
  }
}