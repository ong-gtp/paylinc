part of request_money;

class RequestMoneyController extends GetxController {
  Rx<FormzStatus> _status = FormzStatus.pure.obs;
  FormzStatus get status => _status.value;
  AuthController authController = Get.find<AuthController>();

  static final defaultWalletChoice =
      S2Choice<String>(value: '', title: 'Select one');
  var walletOptions = <S2Choice<String>>[defaultWalletChoice].obs;
  String selectedWalletValue = "";

  var sender = ''.obs;
  var amount = ''.obs;
  var transferPin = ''.obs;
  var purpose = ''.obs;
  var senderPaytagUsageMessage = ''.obs;
  var reviewRequest = ReviewRequest().obs;

  @override
  void onInit() async {
    super.onInit();
    walletOptions.value = await fetchOptions;
  }

  updateAmount(String val) {
    amount.value = val;
    preRequestMoneyReview();
  }

  Future<void> preRequestMoneyReview() async {
    try {
      if (amount.value.isEmpty ||
          purpose.value.isEmpty ||
          sender.value.isEmpty ||
          selectedWalletValue.isEmpty) {
        return;
      }
      _status.value = FormzStatus.submissionInProgress;
      SettingsApi walletsApi = SettingsApi.withAuthRepository(
          authController.authenticationRepository);
      var res = await walletsApi.preRequestMoney({
        'paytag': sender.value,
        "country_id": authController.user.country?.countryId.toString() ?? '',
        'wallet_paytag': selectedWalletValue,
        'amount': amount.value,
        'transfer_pin': transferPin.value,
        'purpose': purpose.value,
      });
      if (res.status == true) {
        _status.value = FormzStatus.submissionSuccess;
        var resFormat = {'transaction': res.data!};
        reviewRequest.value = ReviewRequest.fromMap(resFormat['transaction']!);
      } else {
        _status.value = FormzStatus.submissionFailure;
        Snackbar.errSnackBar(
            'Submission Failed', res.message ?? RestApiServices.errMessage);
      }
    } on Exception catch (_) {
      _status.value = FormzStatus.submissionFailure;
    }
  }

  Future<List<S2Choice<String>>> get fetchOptions async {
    List<S2Choice<String>> s2Choices = [];

    var wallets = authController.user.wallets;
    if (wallets?.isNotEmpty ?? false) {
      s2Choices = List<S2Choice<String>>.from(wallets!.map((e) =>
          S2Choice<String>(
              value: e!.walletPaytag ?? '', title: "@${(e.walletPaytag)}")));
    } else {
      s2Choices = [defaultWalletChoice];
    }

    return s2Choices;
  }

  updateSelectedWallet(String? value) {
    selectedWalletValue = value ?? '';
    preRequestMoneyReview();
  }

  void updatePurpose(String mes) {
    purpose.value = mes;
    preRequestMoneyReview();
  }

  void updateOtp(String pin) {
    transferPin.value = pin;
  }

  void updateSenderPaytag(String val) async {
    sender.value = val;

    try {
      senderPaytagUsageMessage.value = "checking ...";
      SettingsApi settingsApi = SettingsApi.withAuthRepository(
          authController.authenticationRepository);
      var res = await settingsApi.isWalletPaytagUsable({'wallet_paytag': val});

      senderPaytagUsageMessage.value =
          res.message?.toLowerCase() == 'available' ? "invalid" : "valid";
    } on Exception catch (_) {
      senderPaytagUsageMessage.value = "network problem";
    }
    preRequestMoneyReview();
  }
}
