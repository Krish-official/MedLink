class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // Patient
  static const String patientProfile = '/patient/profile';
  static const String patientAppointments = '/patient/appointments';
  static const String patientMedicalRecords = '/patient/medical-records';
  static const String patientPrescriptions = '/patient/prescriptions';

  // Doctor
  static const String doctorProfile = '/doctor/profile';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorAvailability = '/doctor/availability';
  static const String doctorPatients = '/doctor/patients';
  static String doctorPatientDetail(String patientId) => '/doctor/patients/$patientId';

  // Appointments
  static const String appointments = '/appointments';
  static String appointmentDetail(String id) => '/appointments/$id';
  static const String appointmentSlots = '/appointments/slots';
  static const String bookAppointment = '/appointments/book';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  static String rescheduleAppointment(String id) => '/appointments/$id/reschedule';

  // Doctors Directory
  static const String doctors = '/doctors';
  static String doctorDetail(String id) => '/doctors/$id';
  static const String doctorSearch = '/doctors/search';
  static const String specialties = '/specialties';

  // Prescriptions
  static const String prescriptions = '/prescriptions';
  static String prescriptionDetail(String id) => '/prescriptions/$id';
  static const String createPrescription = '/prescriptions';
  static const String uploadPrescription = '/prescriptions/upload';

  // Medical Records
  static const String medicalRecords = '/medical-records';
  static const String uploadMedicalRecord = '/medical-records/upload';

  // Notifications
  static const String notifications = '/notifications';
  static const String fcmToken = '/notifications/fcm-token';

  // Admin
  static const String adminDoctors = '/admin/doctors';
  static const String adminPatients = '/admin/patients';
  static const String adminAppointments = '/admin/appointments';
  static const String adminSettings = '/admin/settings';
}