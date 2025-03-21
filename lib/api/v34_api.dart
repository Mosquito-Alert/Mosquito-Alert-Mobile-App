import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/api/dio_interceptor.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';

class ApiInterface {}

void setApi() async {
  final api = MosquitoAlert(
    interceptors: [DioInterceptor()],
    // basePathOverride: baseUrl // TODO: How to pass baseUrl here
  );

  final authApi = api.getAuthApi();

  final apiUser = await UserManager.getApiUser();
  final apiPassword = await UserManager.getApiPassword();
  if (apiUser != null && apiPassword != null) {
    /*
    If username and password in sharedprefs:
      Login JWT: /auth/token
        request:
          Username: uuid
          Password: *******   <random string 16 characters>
          (opt) Device_id: getId()    // ver device_info_plus
    */
    loginJwt(authApi, apiUser, apiPassword);
  } else {
    /*
    Else:
      Register: /auth/guest
        Request:
          Password: ******   <generate(): random string 16 characters>
        Response:
          Username: <UUID>
      Login JWT:
    */
    final guestPassword = 'test1234';
    final guestRegistrationRequest =
        GuestRegistrationRequest((b) => b..password = guestPassword);
    final registeredGuest = await authApi.signupGuest(
        guestRegistrationRequest: guestRegistrationRequest);
    final apiUser = registeredGuest.data!.username;
    UserManager.setUser(apiUser, guestPassword);
    loginJwt(authApi, apiUser, guestPassword);
  }
}

void loginJwt(AuthApi authApi, String user, String password) async {
  AppUserTokenObtainPairRequest appUserTokenObtainPairRequest =
      AppUserTokenObtainPairRequest((b) => b
        ..username = 'test'
        ..password = 'test1234');

  final obtainToken = await authApi.obtainToken(
      appUserTokenObtainPairRequest: appUserTokenObtainPairRequest);

  print(obtainToken);
}
