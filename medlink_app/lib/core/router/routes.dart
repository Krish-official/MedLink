class Routes {
  Routes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Patient
  static const String patientDashboard = '/patient/dashboard';
  static const String patientBookAppointment = '/patient/book-appointment';
  static const String patientAppointments = '/patient/appointments';
  static const String patientMedicalRecords = '/patient/medical-records';
  static const String patientPrescriptions = '/patient/prescriptions';
  static const String patientProfile = '/patient/profile';

  // Doctor
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorPrescriptions = '/doctor/prescriptions';
  static const String doctorReports = '/doctor/reports';

  // Admin
  static const String adminDashboard = '/admin/dashboard';

  // Public
  static const String landing = '/';
  static const String doctorDirectory = '/doctors';
}