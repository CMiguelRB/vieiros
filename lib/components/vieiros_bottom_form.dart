import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosBottomForm {
  simpleForm(BuildContext context, String titleTag, Map<String, Function> actions, {Form? form}) {
    Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        color: CustomColors.background,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(
                I18n.translate(titleTag),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: form ?? Container(),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: _dialogActions(actions),
            )
          ],
        ),
      );
    });
  }

  List<Widget> _dialogActions(actions) {
    List<Widget> dialogActions = [];

    actions.forEach((tag, function) {
      dialogActions.add(Container(
          margin: const EdgeInsets.only(right: 5),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder(), elevation: 0),
            onPressed: () => function(),
            child: Text(I18n.translate(tag)),
          )));
    });

    return dialogActions;
  }

  VieirosBottomForm._privateConstructor();

  static final VieirosBottomForm _instance = VieirosBottomForm._privateConstructor();

  factory VieirosBottomForm() {
    return _instance;
  }
}
