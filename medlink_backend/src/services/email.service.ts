import nodemailer from 'nodemailer';

export class EmailService {
  private static transporter() {
    return nodemailer.createTransport({
      host: process.env.EMAIL_HOST,
      port: Number(process.env.EMAIL_PORT || 587),
      secure: false,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD,
      },
    });
  }

  static async sendPasswordResetEmail(to: string, resetLink: string) {
    const from = process.env.EMAIL_FROM || 'MedCare <noreply@medcare.com>';

    const subject = 'Reset your MedCare password';
    const html = `
      <div style="font-family: Arial, sans-serif; line-height:1.5">
        <h2>Reset your password</h2>
        <p>Click the button below to reset your password. This link expires soon.</p>
        <p>
          <a href="${resetLink}"
             style="display:inline-block;padding:12px 18px;background:#0066FF;color:#fff;text-decoration:none;border-radius:8px">
            Reset Password
          </a>
        </p>
        <p>If you didn’t request this, you can ignore this email.</p>
      </div>
    `;

    await this.transporter().sendMail({
      from,
      to,
      subject,
      html,
    });
  }
}