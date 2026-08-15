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
  static const String patientEmergency = '/patient/emergency';

  // Doctor
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorPatients = '/doctor/patients';
  static String doctorPatientProfile(String id) => '/doctor/patients/$id';
  static const String doctorPrescriptions = '/doctor/prescriptions';
  static const String doctorReports = '/doctor/reports';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminDoctors = '/admin/doctors';
  static const String adminPatients = '/admin/patients';
  static const String adminAppointments = '/admin/appointments';
  static const String adminSettings = '/admin/settings';

  // Public
  static const String landing = '/';
  static const String doctorDirectory = '/doctors';
}