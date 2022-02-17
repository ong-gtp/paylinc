part of "rest_api_services.dart";

class WalletsApi extends RestApiServices {
  static String errMessage = RestApiServices.errMessage;
  WalletsApi();
  WalletsApi.withAuthRepository(
      AuthenticationRepository authenticationRepository)
      : super.withAuthRepository(authenticationRepository);

  Future<ResponseModel> preSendMoney(Map<String, String> data) async {
    return await makePost(data: data, url: "transactions/pre-send-money");
  }

  Future<ResponseModel> preRequestMoney(Map<String, String> data) async {
    return await makePost(data: data, url: "transactions/pre-request-money");
  }

  Future<ResponseModel> isWalletPaytagUsable(Map<String, String> data) async {
    return await makePost(data: data, url: "wallet/validate-wallet-paytag");
  }

  Future<ResponseModel> checkWalletPaytagExistance(
      Map<String, String> data) async {
    return await makePost(
        data: data, url: "wallet/check-wallet-paytag-existance");
  }

  Future<ResponseModel> createWallet(Map<String, String> data) async {
    return await makePost(data: data, url: "wallet/create");
  }

  Future<ResponseModel> requestMoney(Map<String, String> data) async {
    return await makePost(data: data, url: "transactions/request-money");
  }

  Future<ResponseModel> sendMoney(Map<String, String> data) async {
    return await makePost(data: data, url: "transactions/send-money");
  }
}
