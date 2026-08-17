export const NotificationBuilders = {
  appointmentBookedForDoctor: (patientName: string, isoTime: string) => ({
    title: 'New appointment booked',
    body: `${patientName} booked an appointment for ${isoTime}`,
    data: { type: 'appointment_booked' },
  }),

  appointmentBookedForPatient: (doctorName: string, isoTime: string) => ({
    title: 'Appointment booked',
    body: `Your appointment with ${doctorName} is scheduled for ${isoTime}`,
    data: { type: 'appointment_booked' },
  }),

  appointmentCancelledForDoctor: (patientName: string, isoTime: string) => ({
    title: 'Appointment cancelled',
    body: `${patientName} cancelled the appointment at ${isoTime}`,
    data: { type: 'appointment_cancelled' },
  }),

  appointmentCancelledForPatient: (doctorName: string, isoTime: string) => ({
    title: 'Appointment cancelled',
    body: `Your appointment with ${doctorName} at ${isoTime} was cancelled`,
    data: { type: 'appointment_cancelled' },
  }),

  appointmentStartedForPatient: (doctorName: string) => ({
    title: 'Appointment started',
    body: `Your appointment with ${doctorName} is now in progress`,
    data: { type: 'appointment_started' },
  }),

  appointmentCompletedForPatient: (doctorName: string) => ({
    title: 'Appointment completed',
    body: `Your appointment with ${doctorName} has been marked completed`,
    data: { type: 'appointment_completed' },
  }),

  appointmentRescheduledForDoctor: (patientName: string, isoTime: string) => ({
    title: 'Appointment rescheduled',
    body: `${patientName} rescheduled to ${isoTime}`,
    data: { type: 'appointment_rescheduled' },
  }),

  appointmentRescheduledForPatient: (doctorName: string, isoTime: string) => ({
    title: 'Appointment rescheduled',
    body: `Your appointment with ${doctorName} is now at ${isoTime}`,
    data: { type: 'appointment_rescheduled' },
  }),
};