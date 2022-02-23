library app_helpers;

import 'dart:convert';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paylinc/shared_components/models/response_model.dart';
import 'package:paylinc/config/authentication/controllers/auth_controller.dart';
import 'package:paylinc/utils/helpers/is_text_an_integer.dart';
import 'package:paylinc/utils/services/local_storage_services.dart';
import 'package:user_repository/user_repository.dart';

part 'string_helper.dart';
part 'type.dart';
part 'snackbar.dart';
part 'on_authenticated.dart';
part 'b64_encoder.dart';

extension IntHumanFormat on int {
  String intHumanFormat() {
    return _humanFormat(this.toStringAsFixed(2));
  }
}

extension ToShortHumanFormat on String {
  String toShortHumanFormat({String? currency}) {
    return canBeInteger(this.toString()) || canBeDouble(this.toString())
        ? _shortHumanFormat(val: this.toString(), currency: currency)
        : '';
  }
}

extension ToHumanFormat on String {
  String toHumanFormat({String? currency}) {
    return canBeInteger(this.toString()) || canBeDouble(this.toString())
        ? "${currency ?? ""} ${_humanFormat(this.toString())}"
        : '';
  }
}

extension DoubleHumanFormat on double {
  String doubleHumanFormat() {
    return _humanFormat(this.toStringAsFixed(2));
  }
}

String _humanFormat(String val) {
  return val.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}

String _shortHumanFormat({dynamic val, String? currency}) {
  return NumberFormat.compactCurrency(
    decimalDigits: 2,
    symbol: "${currency ?? ''}",
  ).format(double.parse(val));
}

Widget appVersion(ThemeData td) {
  String year = DateFormat('yyyy').format(DateTime.now());
  return Column(children: [
    Center(
      child: Text(
        "Paylinc V4.0.0",
        style: TextStyle(
          fontSize: 14,
          color: td.textTheme.caption?.color,
        ),
      ),
    ),
    Center(
      child: Text(
        " © $year Omept Technology Ltd",
        style: TextStyle(
          fontSize: 14,
          color: td.textTheme.caption?.color,
        ),
      ),
    )
  ]);
}
