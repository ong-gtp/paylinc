part of "rest_api_services.dart";

class UserApi extends RestApiServices {
  static String errMessage = RestApiServices.errMessage;

  UserApi.withAuthRepository(AuthenticationRepository authenticationRepository)
      : super.withAuthRepository(authenticationRepository);

  @override
  void onInit() {
    super.onInit();
  }

  Future<ResponseModel> login(Map<String, String> data) async {
    try {
      final String url = "auth/login/";
      final response = await post(url, data, headers: this.requestHeader());
      return this.responseHandler(response);
    } on Exception catch (_) {
      return ResponseModel(message: UserApi.errMessage);
    }
  }

  Future<ResponseModel> isPaytagUsable(Map<String, String> data) async {
    try {
      final String url = "auth/validate-paytag/";
      final response = await post(url, data, headers: this.requestHeader());
      return this.responseHandler(response);
    } on Exception catch (_) {
      return ResponseModel(message: UserApi.errMessage);
    }
  }

  signUp(Map<String, String> data) async {
    try {
      final String url = "auth/sign-up/";
      final response = await post(url, data, headers: this.requestHeader());
      return this.responseHandler(response);
    } on Exception catch (_) {
      return ResponseModel(message: UserApi.errMessage);
    }
  }
}