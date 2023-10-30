import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';

class FileManagerBar extends StatelessWidget {
  final bool lightMode;
  final bool selectionMode;
  final Function cancelSelectionMode;
  final Function moveSelection;
  final Function showDeleteDialog;

  const FileManagerBar(
      {super.key,
      required this.lightMode,
      required this.selectionMode,
      required this.cancelSelectionMode,
      required this.moveSelection,
      required this.showDeleteDialog});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: selectionMode ? MediaQuery.of(context).size.width - 24 : 0,
        child: selectionMode
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => cancelSelectionMode(),
                  ),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    icon: Icon(Icons.drive_file_move_outline, color: lightMode ? CustomColors.subText : CustomColors.subTextDark),
                    onPressed: () => moveSelection(lightMode),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: lightMode ? CustomColors.subText : CustomColors.subTextDark),
                    onPressed: () => showDeleteDialog(),
                  ),
                ],
              )
            : const SizedBox());
  }
}
