import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';

class VieirosDialog {
  infoDialog(
      BuildContext context, String titleTag, Map<String, Function> actions,
      {String? bodyTag}) async {
    Color _bodyTextColor =
        Provider.of<ThemeProvider>(context, listen: false).isLightMode
            ? CustomColors.subText
            : CustomColors.subTextDark;
    return showDialog(
        context: context,
        barrierColor: CustomColors.dimming,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, top: 20, right: 20, bottom: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        I18n.translate(titleTag),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    bodyTag != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              I18n.translate(bodyTag),
                              style: TextStyle(color: _bodyTextColor),
                            ))
                        : Container(),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.only(
                    left: 20, top: 20, right: 20, bottom: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () => Navigator.pop(context, ''),
                            icon: const Icon(Icons.close))),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 10),
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
    List<Widget> _dialogActions = [];

    actions.forEach((tag, function) {
      _dialogActions.add(Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
                (states) => CustomColors.subTextDark),
          ),
          onPressed: () => function(),
          child: Text(I18n.translate(tag),
              style: const TextStyle(color: CustomColors.accent, fontSize: 15)),
        ),
      ));
    });

    return _dialogActions;
  }

  VieirosDialog._privateConstructor();

  static final VieirosDialog _instance = VieirosDialog._privateConstructor();

  factory VieirosDialog() {
    return _instance;
  }
}
