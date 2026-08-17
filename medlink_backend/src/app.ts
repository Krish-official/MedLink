import dotenv from 'dotenv';
// Load environment variables FIRST, before any other module (routes/services/config)
// is imported — several of them read process.env at module-load time (e.g. JWT
// secrets, Prisma client, Firebase config), so this must run before those requires.
dotenv.config();

import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import path from 'path';
import { errorHandler } from './middlewares/error.middleware';
// Import routes
import authRoutes from './routes/auth.routes';
import patientRoutes from './routes/patient.routes';
// Public doctor directory / search endpoints (GET /doctors, /doctors/:id, ...)
import publicDoctorRoutes from './routes/booking.routes';
import doctorRoutes from './routes/doctor.routes';
import adminRoutes from './routes/admin.routes';
import uploadRoutes from './routes/upload.routes';
import appointmentsRoutes from './routes/appointments.routes';
import queueRoutes from './routes/queue.routes';
import notificationRoutes from './routes/notification.routes';

const app: Application = express();
const API_PREFIX = '/api/v1';

// ═══════════════════════════════════════════════════════════
// MIDDLEWARES
// ═══════════════════════════════════════════════════════════

app.use(helmet());
app.use(
  cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true,
  })
);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(compression());

if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Serve uploaded files (LOCAL driver)
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

// ═══════════════════════════════════════════════════════════
// ROUTES
// ═══════════════════════════════════════════════════════════

app.get('/', (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'MedCare API - Healthcare Management System',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    documentation: 'https://github.com/Krish-official/MedLink',
    endpoints: {
      auth: '/api/v1/auth',
      patient: '/api/v1/patient',
      doctor: '/api/v1/doctor',
      admin: '/api/v1/admin',
      doctors: '/api/v1/doctors (public)',
      appointments: '/api/v1/appointments',
    },
  });
});

app.get('/health', (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'Server is healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use(`${API_PREFIX}/auth`, authRoutes);
app.use(`${API_PREFIX}/patient`, patientRoutes);
app.use(`${API_PREFIX}/doctor`, doctorRoutes);
app.use(`${API_PREFIX}/admin`, adminRoutes);
app.use(`${API_PREFIX}/doctors`, publicDoctorRoutes);
app.use(`${API_PREFIX}/appointments`, appointmentsRoutes);
app.use(`${API_PREFIX}/uploads`, uploadRoutes);
app.use(`${API_PREFIX}/queue`, queueRoutes);
app.use(`${API_PREFIX}/notifications`, notificationRoutes);

// ═══════════════════════════════════════════════════════════
// ERROR HANDLING
// ═══════════════════════════════════════════════════════════

app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.path,
  });
});

app.use(errorHandler);

export default app;