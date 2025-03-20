import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/api/dio_interceptor.dart';

void setApi() {
  final api = MosquitoAlert(
    interceptors: [DioInterceptor()],
    // basePathOverride: baseUrl // TODO: How to pass baseUrl here
  );

  // final guestRegistrationRequest = GuestRegistrationRequest();
  // final ret = api.signupGuest(guestRegistrationRequest: guestRegistrationRequest);
  final guestRegistrationRequest = GuestRegistrationRequest();
  api
      .getAuthApi()
      .signupGuest(guestRegistrationRequest: guestRegistrationRequest);

  final authApi = api.getAuthApi();
  final userApi = api.getUsersApi();

  // If username and password in sharedprefs
  // TODO
  // Else
  //final guestRegistrationRequest = GuestRegistrationRequest();
  final registeredGuest =
      authApi.signupGuest(guestRegistrationRequest: guestRegistrationRequest);
}
