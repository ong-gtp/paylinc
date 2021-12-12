import 'package:authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:paylinc/shared_components/form_inputs/text_input.dart';
import 'package:paylinc/shared_components/models/response_model.dart';
part 'user_api.dart';

/// contains all service to get data from Server
class RestApiServices extends GetConnect {
  final String baseUrl = 'https://paylinc.test/api/';
  AuthenticationRepository? authenticationRepository;

  RestApiServices();

  RestApiServices.withAuthRepository(this.authenticationRepository);

  static const errMessage = "We encountered a problem. Please try again later.";

  Map<String, String> requestHeader() => {'Access-Control-Allow-Origin': '*'};

  ResponseModel responseHandler(Response<dynamic> response) {
    ResponseModel responseModel;
    responseModel = ResponseModel(
      data: response.body?['data'],
      message: response.body?['message'],
      status: response.body?['status'],
      statusCode: response.body?['status-code'],
    );
    if (response.status.hasError) {
      if (response.body != null) {
        // handle backend errors
        // 401 -- auth error response
        // 400 -- problem response
        // 500 -- server response

        switch (responseModel.statusCode) {
          case 400:
            break;
          case 401:
            if (responseModel.message == "Account is not yet verified.") {
              this.authenticationRepository?.onboardingReqAcctVerification();
              // } else if (responseModel.message == "Invalid credentials") {
            } else if (responseModel.message == "Expired Session" ||
                responseModel.message == "Invalid Token") {
              this.authenticationRepository?.onboardingReqLogin();
            }
            break;
          case 500:
            break;
          default:
        }
        return responseModel;
      }
    }
    return responseModel;
  }

  @override
  void onInit() {
    httpClient.baseUrl = baseUrl;
    httpClient.defaultContentType = "application/json";
    super.onInit();
  }
}