import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class BottomSheetActions extends StatelessWidget {
  final Map<String, Map<String, dynamic>> actions;
  final bool lightMode;

  const BottomSheetActions({Key? key, required this.actions, required this.lightMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> actionWidgets = [];
    actions.forEach((key, value) {
      Function? action;
      Icon? icon;

      value.forEach((key, value) {
        if (key == 'action') {
          action = value;
        } else {
          icon = Icon(
            value
          );
        }
      });

      actionWidgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child:
          Column(children: [
            Ink(
              decoration: const ShapeDecoration(
                shape: CircleBorder(side: BorderSide(color: Colors.black26, width: 1)),
              ),
              child: IconButton(
                icon: icon!,
                color: key.contains('delete') ? CustomColors.error : (lightMode ? CustomColors.subText : CustomColors.subTextDark),
                onPressed: () => action!(),
              ),
            ),
            Container(margin: const EdgeInsets.only(top: 8), child: Text(I18n.translate(key), style: const TextStyle(color: Colors.black, fontSize: 12)))]))
        );
    });
    return Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: actionWidgets));
  }
}
