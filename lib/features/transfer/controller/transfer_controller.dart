part of transfer;

enum TransferOrigin { stash, wallet }

class TransferController extends GetxController {
  final Rx<FormzStatus> _status = FormzStatus.pure.obs;
  FormzStatus get status => _status.value;
  AuthController authController = Get.find<AuthController>();

  var transferOrigins = <S2Choice<TransferOrigin>>[
    S2Choice<TransferOrigin>(value: TransferOrigin.stash, title: "Stash"),
    S2Choice<TransferOrigin>(value: TransferOrigin.wallet, title: "Wallet")
  ].obs;

  var walletOptions = <S2Choice<Wallet>>[].obs;

  var purpose = "".obs;
  var amount = 0.obs;
  var transferPin = "".obs;
  var acctNumber = "".obs;
  var sUBank = UserBank().obs; // selected user bank
  RxList<UserBank?> uBanksList = <UserBank?>[].obs;

  Rx<Wallet?> defaultWallet = Wallet().obs; // default wallet to load
  Rx<Wallet?> selectedWallet = Wallet().obs; // selected wallet to transfer from
  Rx<TransferOrigin?> selectedTransferOrgn =
      TransferOrigin.stash.obs; // selected transfer origin
  Rx<UserBank?> selectedUBank =
      UserBank().obs; // specific user bank to transfer from

  List<Wallet?>? wallets;
  Map<String, int> paytagBals = {};

  @override
  void onInit() async {
    super.onInit();
    wallets = authController.user.value.wallets;
    uBanksList.value = defaultBankList();
    walletOptions.value = await fetchWalltOptns;

    if (wallets != null && wallets?.isNotEmpty == true) {
      for (var w in wallets!) {
        paytagBals["${w?.walletPaytag}"] = (w?.balance ?? 0).round();
      }
      defaultWallet.value = wallets?.first;
    } else {
      transferOrigins.removeAt(1);
    }
  }

  int getWalletPaytagMax(String selectedWllt) => paytagBals[selectedWllt] ?? 0;

  int getStashMax() => authController.user.value.stashBalance ?? 0;

  Future<List<S2Choice<Wallet>>> get fetchWalltOptns async {
    List<S2Choice<Wallet>> s2Choices = [];

    if (wallets?.isNotEmpty ?? false) {
      s2Choices = List<S2Choice<Wallet>>.from(wallets!.map((e) =>
          S2Choice<Wallet>(
              value: e ?? Wallet(), title: "@${(e?.walletPaytag)}")));
    } else {
      s2Choices = [];
    }

    return s2Choices;
  }

  void updatePurpose(String mes) => purpose.value = mes;

  void updateAmount(String _amount) => amount.value = _amount.toInt();

  void updateOtp(String pin) => transferPin.value = pin;

  void submitTransferMoney() => print("transfer money");

  List<UserBank?> defaultBankList() {
    return authController.user.value.userBanks ?? [];
  }

  void updateAcountNumber(String acctNum) {
    if (acctNum.isEmpty) {
      uBanksList.value = defaultBankList();
      return;
    }
    // reset selected user bank
    sUBank.value = UserBank();
    acctNumber.value = acctNum;
    var bList = defaultBankList();
    uBanksList.value = bList
        .where((b) => b?.accountNumber?.contains(acctNum) ?? false)
        .toList();
  }

  void selectUBank(UserBank _uBank) {
    sUBank.value = _uBank;
    acctNumber.value = _uBank.accountNumber ?? "";
  }

  void maxAmount() {
    if (selectedTransferOrgn.value == TransferOrigin.wallet) {
      // print(paytagBals);
      // print(selectedWallet.value);
      amount.value =
          getWalletPaytagMax(selectedWallet.value?.walletPaytag ?? "");
    } else {
      amount.value = getStashMax();
    }
  }

  setTransferOrigin(S2SingleSelected<TransferOrigin> state) {
    selectedTransferOrgn.value = state.value;
    if (state.value == TransferOrigin.wallet) {
      selectedWallet.value = defaultWallet.value;
    }
  }
}
