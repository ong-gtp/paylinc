library view_stash;

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:paylinc/config/routes/app_pages.dart';
import 'package:paylinc/features/user_alerts/views/screens/user_alerts_screen.dart';
import 'package:paylinc/shared_components/header.dart';
import 'package:paylinc/shared_components/models/empty_list_indicator.dart';
import 'package:paylinc/shared_components/models/initializedTransactionB64.dart';
import 'package:paylinc/shared_components/models/response_model.dart';
import 'package:paylinc/shared_components/models/user_alerts_response.dart';
import 'package:paylinc/shared_components/models/stash_logs_response.dart';
import 'package:paylinc/shared_components/responsive_builder.dart';
import 'package:paylinc/constants/app_constants.dart';
import 'package:paylinc/shared_components/selected_project.dart';
import 'package:paylinc/shared_components/sidebar.dart';
import 'package:paylinc/shared_components/today_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:paylinc/config/authentication/controllers/auth_controller.dart';
import 'package:paylinc/utils/helpers/dateTimeDisplay.dart';
import 'package:paylinc/utils/helpers/get_profile.dart';
import 'package:paylinc/utils/helpers/app_helpers.dart';

import 'package:paylinc/shared_components/models/profile.dart';
import 'package:paylinc/shared_components/profile_tile.dart';
import 'package:paylinc/utils/helpers/is_text_an_integer.dart';
import 'package:paylinc/utils/services/local_storage_services.dart';
import 'package:paylinc/utils/services/rest_api_services.dart';
// binding
part '../../bindings/view_stash_binding.dart';

// controller
part '../../controllers/view_stash_controller.dart';

class ViewStashScreen extends GetView<ViewStashController> {
  ViewStashScreen({Key? key}) : super(key: key);
  final kTitleStyle = const TextStyle(
    fontFamily: 'CM Sans Serif',
    fontSize: 26.0,
    height: 1.5,
  );

  kSubtitleStyle(ThemeData themeContext) => TextStyle(
        color: themeContext.textTheme.caption?.color,
        fontSize: 13.0,
        height: 1.2,
      );
  kSubtitleStyle2(ThemeData themeContext) => TextStyle(
        color: themeContext.textTheme.caption?.color,
        fontSize: 18.0,
        height: 1.2,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: (ResponsiveBuilder.isDesktop(context))
          ? null
          : Drawer(
              child: Padding(
                  padding: const EdgeInsets.only(top: kSpacing),
                  child: _sideBar()),
            ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: ResponsiveBuilder(
          mobileBuilder: _initializedTransactionsMobileScreenWidget,
          tabletBuilder: _initializedTransactionsTabletScreenWidget,
          desktopBuilder: _initializedTransactionsDesktopScreenWidget,
        ),
      )),
    );
  }

  Widget _initializedTransactionsDesktopScreenWidget(context, constraints) {
    var maxWidth = 1360;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: (constraints.maxWidth < maxWidth) ? 4 : 3,
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(kBorderRadius),
                bottomRight: Radius.circular(kBorderRadius),
              ),
              child: _sideBar()),
        ),
        Flexible(
          flex: 9,
          child: Column(
            children: [
              const SizedBox(height: kSpacing),
              _buildHeader(),
              const SizedBox(height: kSpacing * 2),
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: Column(
            children: [
              const SizedBox(height: kSpacing / 2),
              _buildProfile(data: getProfile()),
              const Divider(thickness: 1),
              const SizedBox(height: kSpacing),
            ],
          ),
        )
      ],
    );

    // return Container();
  }

  Sidebar _sideBar() {
    return Sidebar(
      data: getSelectedProject(),
      initialSelected: 4,
    );
  }

  Widget _initializedTransactionsTabletScreenWidget(context, constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: (constraints.maxWidth < 950) ? 6 : 9,
          child: Column(
            children: [
              const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
              _buildHeader(onPressedMenu: () => controller.openDrawer()),
              const SizedBox(height: kSpacing * 2),
              const SizedBox(height: kSpacing * 2),
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: Column(
            children: [
              const SizedBox(height: kSpacing * (kIsWeb ? 0.5 : 1.5)),
            ],
          ),
        )
      ],
    );
  }

  Widget _initializedTransactionsMobileScreenWidget(context, constraints) {
    ThemeData themeData = Theme.of(context);
    ViewStashController vwCtrl = Get.find();
    // MediaQueryData mediaQuery = MediaQuery.of(context);
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: kSpacing / 2,
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back,
                        color: themeData.colorScheme.onBackground,
                        size: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () => Get.offAllNamed(Routes.transfer),
                  child: Container(
                    width: 100.0,
                    height: 50.0,
                    child: Card(
                      child: Center(
                        child: Icon(
                          EvaIcons.paperPlane,
                          color: themeData.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(kSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vwCtrl.authController.user.country?.currencyAbr ?? ""} ${vwCtrl.authController.user.stashBalance?.intHumanFormat() ?? ""}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: kTitleStyle,
                ),
                SizedBox(height: 8.0),
                Text(
                  'stash',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: kSubtitleStyle2(themeData),
                ),
                SizedBox(height: 8.0),
                Text(
                  'view recent stash activities.',
                  style: kSubtitleStyle(themeData),
                ),
                SizedBox(height: 15.0),
                Divider(),
                Container(
                  height: 550,
                  child: _StashsTransactions(),
                ),
              ],
            ),
          ),
        ]);
  }

  Widget _buildHeader({Function()? onPressedMenu}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Row(
        children: [
          if (onPressedMenu != null)
            Padding(
              padding: const EdgeInsets.only(right: kSpacing),
              child: IconButton(
                onPressed: onPressedMenu,
                icon: const Icon(EvaIcons.menu),
                tooltip: "menu",
              ),
            ),
          const Expanded(
              child: Header(
            todayText: TodayText(message: "Stash"),
          )),
        ],
      ),
    );
  }

  Widget _buildProfile({required Profile data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: ProfilTile(
        data: data,
        onPressedNotification: () {},
      ),
    );
  }
}

class _StashsTransactions extends StatelessWidget {
  const _StashsTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ViewStashController vWC = Get.find();
    return SingleChildScrollView(child: Obx(() {
      if (vWC.walletTransactionsList.isEmpty) {
        return emptyListIndicator();
      }

      final List fixedList =
          Iterable<int>.generate(vWC.walletTransactionsList.length).toList();

      final List<Widget> walletTiles = fixedList.map((idx) {
        return _StashTransactionListItem(
          selectedIndex: idx,
          transactionAmount: "${vWC.walletTransactionsList[idx]?.amount}",
          transactionAction: "${vWC.walletTransactionsList[idx]?.action}",
          transactionCurrency:
              "${vWC.authController.user.country?.currencyAbr ?? ""}",
          createdAt:
              dateTimeDisplay('${vWC.walletTransactionsList[idx]?.createdAt}'),
        );
      }).toList();

      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: walletTiles.length > 0 ? walletTiles : <Widget>[],
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 5.0),
      );
    }));
  }
}

class _StashTransactionDescription extends StatelessWidget {
  final alrtAmountStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    // color: themeContext.textTheme.caption?.color,
  );

  _StashTransactionDescription({
    Key? key,
    required this.transactionAmount,
    required this.transactionCurrency,
    required this.transactionAction,
    required this.createdAt,
  }) : super(key: key);

  final String transactionAmount;
  final String transactionAction;
  final String transactionCurrency;
  final String createdAt;

  @override
  Widget build(BuildContext context) {
    ThemeData themeCtx = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(bottom: 2.0)),
            canBeInteger(transactionAmount) || canBeDouble(transactionAmount)
                ? Text(
                    transactionAmount.toShortHumanFormat(
                        currency: "$transactionCurrency "),
                    style: alrtAmountStyle)
                : Container(),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "$transactionAction",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: themeCtx.textTheme.caption?.color,
                  fontSize: 12.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$createdAt',
                    style: TextStyle(
                      color: themeCtx.textTheme.caption?.color,
                      fontSize: 12.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      EvaIcons.activityOutline,
                      size: 12.0,
                      color: themeCtx.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StashTransactionListItem extends StatelessWidget {
  _StashTransactionListItem({
    Key? key,
    required this.selectedIndex,
    required this.transactionAmount,
    required this.transactionAction,
    required this.transactionCurrency,
    required this.createdAt,
  }) : super(key: key);

  final int selectedIndex;
  final String transactionAmount;
  final String transactionAction;
  final String transactionCurrency;
  final String createdAt;
  final ViewStashController vWC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        elevation: 1.0,
        margin: const EdgeInsets.all(0),
        child: InkWell(
          onTap: () {
            vWC.viewInititalizedTransaction(
                selectedIndex: selectedIndex,
                selectedType: AlertTagType.WALLETS,
                initializedTransactionId: vWC
                    .walletTransactionsList[selectedIndex]
                    ?.initializedTransactionId);
          },
          child: SizedBox(
            height: 82.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 8.0, 2.0, 2.0),
                    child: _StashTransactionDescription(
                      transactionAmount: transactionAmount,
                      transactionAction: transactionAction,
                      transactionCurrency: transactionCurrency,
                      createdAt: createdAt,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
