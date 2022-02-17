import 'dart:convert';
import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:get/get.dart';
import 'package:paylinc/shared_components/models/response_model.dart';
import 'package:paylinc/utils/controllers/auth_controller.dart';
import 'package:paylinc/utils/helpers/app_helpers.dart';
import 'package:http/http.dart' as http;
part 'user_api.dart';
part 'settings_api.dart';
part 'wallets_api.dart';
part 'alerts_api.dart';
part 'initialized_transactions_api.dart';

/// contains all service to get data from Server
class RestApiServices {
  String apiBaseUrl = 'https://paylinc.test/api/';
  AuthenticationRepository? authenticationRepository;
  AuthController authCtrlr = Get.find();

  RestApiServices();

  RestApiServices.withAuthRepository(this.authenticationRepository);

  static const errMessage = "We encountered a problem. Please try again later.";

  Map<String, String> requestHeader() {
    Map<String, String> headers = {'Access-Control-Allow-Origin': '*'};
    String token = authCtrlr.token;
    if (token.isNotEmpty || token.length > 0) {
      headers['AUTHORIZATION'] = 'Bearer ' + token;
      headers['HTTP-AUTHORIZATION'] = 'Bearer ' + token;
    }

    return headers;
  }

  ResponseModel responseHandler(http.Response response) {
    ResponseModel responseModel = ResponseModel();

    if (response.statusCode != 200) {
      // handle backend errors
      // 401 -- auth error response
      // 400 -- problem response
      // 500 -- server response

      responseModel.message = '';
      responseModel.status = false;

      switch (response.statusCode) {
        case 400:
          responseModel.message = "Bad request.";
          break;
        case 401:
          if (responseModel.message == "Account is not yet verified.") {
            this.authenticationRepository?.onboardingReqAcctVerification();
            // } else if (responseModel.message == "Invalid credentials") {
          } else if (responseModel.message == "Expired Session" ||
              responseModel.message == "Token has expired" ||
              responseModel.message == "Invalid Token") {
            Snackbar.infoSnackBar(
                responseModel.message ?? RestApiServices.errMessage);
            authCtrlr.logout();
          }
          break;
        case 500:
          responseModel.message = "Could not connect";
          break;
        default:
      }

      return responseModel;
    } else {
      try {
        responseModel.status = true;
        if (response.body.trim() != '') {
          var jsonRes = json.decode(response.body);
          log("dsdsd");
          responseModel = ResponseModel.fromJson(json.encode(jsonRes['data']));
          log("jsonRes");
        }
      } on Exception catch (e) {
        print(e);
        responseModel.status = false;
      }
      return responseModel;
    }
  }

  Future<ResponseModel> makePost(
      {required String url,
      Map<String, dynamic>? data,
      String? defaultMessage}) async {
    try {
      return await post(url, data);
    } on Exception catch (_) {
      return ResponseModel(
          message: Runes(defaultMessage ?? "").length > 0
              ? defaultMessage
              : errMessage);
    }
  }

  Future<ResponseModel> post(String url, Map<String, dynamic>? data) async {
    var headers = this.requestHeader();
    var uri = Uri.parse('$apiBaseUrl$url/');
    var response = await http.post(uri, body: data, headers: headers);

    return responseHandler(response);
  }

  Future<ResponseModel> makeGet(
      {Map<String, dynamic>? data,
      required String url,
      String? defaultMessage}) async {
    try {
      var response = await get(url);
      return this.responseHandler(response);
    } on Exception catch (_) {
      return ResponseModel(
          message: defaultMessage != "" ? defaultMessage : errMessage);
    }
  }

  Future<dynamic> get(String url) async {
    var headers = this.requestHeader();
    var uri = Uri.parse('$apiBaseUrl/$url');
    var response = await http.get(uri, headers: headers);
    return responseHandler(response);
  }
}
