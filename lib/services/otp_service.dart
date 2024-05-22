

class OtpService {

  static const String baseUrl = 'https://qosambassadors.herokuapp.com';

  static String get otpEndpoint => '$baseUrl/apimanagement/verifyOTP/';
}
