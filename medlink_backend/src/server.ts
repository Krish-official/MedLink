import http from 'http';
import { Server as SocketIOServer } from 'socket.io';
import app from './app';
import prisma from './config/database';
import { SocketService } from './services/socket.service';

const PORT = process.env.PORT || 3000;

const httpServer = http.createServer(app);

const io = new SocketIOServer(httpServer, {
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true,
  },
});

SocketService.init(io);

httpServer.listen(PORT, async () => {
  console.log(`\n🚀 Server running on port ${PORT}`);
  console.log(`🔗 API URL: http://localhost:${PORT}\n`);

  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully\n');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  await prisma.$disconnect();
  httpServer.close(() => process.exit(0));
});