import 'package:formz/formz.dart';
import 'package:get/get.dart';

class RequestMoneyController extends GetxController {
  FormzStatus _status = FormzStatus.pure;

  FormzStatus get status => _status;
}
