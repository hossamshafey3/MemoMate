// ─────────────────────────────────────────────
//  endpoints.dart  –  Memomate
//  Central place for all API endpoint paths.
//  Keep paths relative (no base URL here).
// ─────────────────────────────────────────────

class ApiEndpoints {
  ApiEndpoints._(); // prevent instantiation

  // ── Base ──────────────────────────────────────────────────────
  // Set your actual base URL in your Dio configuration (DioConsumer).
  static const String baseUrl = 'https://memo-mate-server.vercel.app/api';

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // ── Patient (User) ────────────────────────────────────────────
  static const String patientRegister = '/patient/register';
  static const String patientLogin = '/patient/login';
  static const String patientUpdate = '/patient';
  static const String requestDoctor = '/patient/doctors/{id}'; // POST – request a doctor
  static const String patientDoctors = '/patient/doctors'; // GET – my accepted doctors

  // ── Profile ───────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String getAllDoctors = '/doctor';
  static const String updateProfile = '/profile/update';
  static const String uploadAvatar = '/profile/avatar';

  // ── Doctor ────────────────────────────────────────────────────
  static const String doctorRegister = '/doctor'; // POST – register new doctor
  static const String doctorLogin = '/doctor/login'; // POST – login doctor
  static const String doctorUpdate =
      '/doctor'; // PUT – update authenticated doctor
  static const String doctors = '/doctor';
  static const String doctorDetails = '/doctor/{id}'; // replace {id} at runtime
  static const String assignDoctor = '/doctor/assign';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorRequests = '/doctor/requests';

  // ── Memory Games ──────────────────────────────────────────────
  static const String games = '/games';
  static const String startGame = '/games/start';
  static const String submitGame = '/games/submit';
  static const String gameHistory = '/games/history';
  static const String gameScore = '/games/{id}/score';

  // ── Reminders ─────────────────────────────────────────────────
  static const String reminders = '/reminders';
  static const String createReminder = '/reminders/create';
  static const String updateReminder =
      '/reminders/{id}'; // replace {id} at runtime
  static const String deleteReminder = '/reminders/{id}';
  static const String toggleReminder = '/reminders/{id}/toggle';

  // ── Reports ───────────────────────────────────────────────────
  static const String reports = '/reports';
  static const String generateReport = '/reports/generate';
  static const String reportDetails = '/reports/{id}';

  // ── Helpers ───────────────────────────────────────────────────

  /// Replaces the `{id}` placeholder in a path template.
  /// Example: ApiEndpoints.withId(ApiEndpoints.doctorDetails, '42')
  static String withId(String path, String id) => path.replaceFirst('{id}', id);
}
