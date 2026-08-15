import { Request, Response, NextFunction } from 'express';
import { BookingService } from '../services/booking.service';
import { ResponseUtil } from '../utils/response.util';
import prisma from '../config/database';

export class BookingController {
  // ═══════════════════════════════════════════════════════════
  // SEARCH DOCTORS
  // ═══════════════════════════════════════════════════════════

  static async searchDoctors(req: Request, res: Response, next: NextFunction) {
    try {
      const { query, specialty, page, limit } = req.query;
      const result = await BookingService.searchDoctors({
        query: query as string,
        specialty: specialty as string,
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

  // ═══════════════════════════════════════════════════════════
  // GET SPECIALTIES
  // ═══════════════════════════════════════════════════════════

  static async getSpecialties(req: Request, res: Response, next: NextFunction) {
    try {
      const specialties = await BookingService.getSpecialties();
      return ResponseUtil.success(res, specialties, 'Specialties retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET DOCTOR DETAILS
  // ═══════════════════════════════════════════════════════════

  static async getDoctorDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const doctor = await BookingService.getDoctorDetails(req.params.id);
      return ResponseUtil.success(res, doctor, 'Doctor details retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET AVAILABLE SLOTS
  // ═══════════════════════════════════════════════════════════

  static async getAvailableSlots(req: Request, res: Response, next: NextFunction) {
    try {
      const { doctorId, date } = req.query;

      if (!doctorId || !date) {
        return ResponseUtil.error(res, 'Doctor ID and date are required', null, 400);
      }

      const slots = await BookingService.getAvailableSlots(
        doctorId as string,
        date as string
      );

      return ResponseUtil.success(res, slots, 'Available slots retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BOOK APPOINTMENT
  // ═══════════════════════════════════════════════════════════

  static async bookAppointment(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const appointment = await BookingService.bookAppointment(patient.id, req.body);
      return ResponseUtil.success(res, appointment, 'Appointment booked successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RESCHEDULE APPOINTMENT
  // ═══════════════════════════════════════════════════════════

  static async rescheduleAppointment(req: Request, res: Response, next: NextFunction) {
    try {
      const patient = await prisma.patient.findUnique({
        where: { userId: req.user!.userId },
      });

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      const appointment = await BookingService.rescheduleAppointment(
        req.params.id,
        patient.id,
        req.body.scheduledAt
      );
      return ResponseUtil.success(res, appointment, 'Appointment rescheduled successfully');
    } catch (error) {
      next(error);
    }
  }
}