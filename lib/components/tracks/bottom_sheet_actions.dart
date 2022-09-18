import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class BottomSheetActions extends StatelessWidget {
  final Map<String, Map<String, dynamic>> actions;
  final bool lightMode;
  final bool? loading;

  const BottomSheetActions({Key? key, required this.actions, required this.lightMode, this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> actionWidgets = [];
    actions.forEach((key, value) {
      Function? action;
      Icon? icon;
      bool? disabled;

      value.forEach((key, value) {
        switch(key){
          case 'action':
            action = value;
            break;
          case 'icon':
            icon = Icon(value);
            break;
          case 'disabled':
            disabled = value;
        }
      });

      Color color = disabled != null && disabled == true ? (lightMode ? CustomColors.faintedText : CustomColors.subText) :(lightMode ? CustomColors.subText : CustomColors.subTextDark);

      actionWidgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width/actions.length,
          child: Column(children: [
            IconButton(
              icon: icon!,
              disabledColor: Colors.black26,
              color: color,
              onPressed: loading == null || loading == false ? () => action!() : null,
              enableFeedback: disabled != null && disabled == true,
              style: IconButton.styleFrom(
                side: BorderSide(color: color),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 8),
                child: Text(I18n.translate(key), style: TextStyle(color: color, fontSize: 12)))
          ])));
    });
    return Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: actionWidgets));
  }
}
