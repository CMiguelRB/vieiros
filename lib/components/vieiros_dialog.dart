import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';

class VieirosDialog {
  infoDialog(
      BuildContext context, String titleTag, Map<String, Function> actions,
      {String? bodyTag}) async {
    Color bodyTextColor =
        Provider.of<ThemeProvider>(context, listen: false).isLightMode
            ? CustomColors.subText
            : CustomColors.subTextDark;
    return showDialog(
        context: context,
        barrierColor: CustomColors.dimming,
        builder: (BuildContext context) => Dialog(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        I18n.translate(titleTag),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    bodyTag != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              I18n.translate(bodyTag),
                              style: TextStyle(color: bodyTextColor),
                            ))
                        : Container(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _dialogActions(actions),
                    )
                  ],
                ),
              ),
            ));
  }

  inputDialog(
      BuildContext context, String titleTag, Map<String, Function> actions,
      {Form? form}) {
    showDialog(
        context: context,
        barrierColor: CustomColors.dimming,
        builder: (BuildContext context) => Dialog(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        alignment: Alignment.topCenter,
                        child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(I18n.translate(titleTag), style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerRight,
                            onPressed: () => Navigator.pop(context, ''),
                            icon: const Icon(Icons.close))])),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: form ?? Container(),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _dialogActions(actions),
                    )
                  ],
                ),
              ),
            ));
  }

  List<Widget> _dialogActions(actions) {
    List<Widget> dialogActions = [];

    actions.forEach((tag, function) {
      dialogActions.add(TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => CustomColors.subTextDark),
        ),
        onPressed: () => function(),
        child: Text(I18n.translate(tag),
            style: const TextStyle(color: CustomColors.accent, fontSize: 15)),
      ));
    });

    return dialogActions;
  }

  VieirosDialog._privateConstructor();

  static final VieirosDialog _instance = VieirosDialog._privateConstructor();

  factory VieirosDialog() {
    return _instance;
  }
}
