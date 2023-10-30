import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vieiros/components/vieiros_text_input.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class SearchTrackBar extends StatelessWidget {
  final bool lightMode;
  final bool selectionMode;
  final double backButtonWidth;
  final String? rootPath;
  final String sortDirection;
  final Directory? currentDirectory;
  final Function navigateUp;
  final Function onSearchChanged;
  final Function setSortDirection;
  final Function clearValue;
  final TextEditingController controller;
  final FocusNode? searchFocusNode;

  const SearchTrackBar(
      {super.key,
      required this.lightMode,
      required this.selectionMode,
      required this.sortDirection,
      required this.backButtonWidth,
      required this.currentDirectory,
      required this.rootPath,
      required this.navigateUp,
      required this.onSearchChanged,
      required this.setSortDirection,
      required this.clearValue,
      required this.controller,
      required this.searchFocusNode});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        width: !selectionMode ? MediaQuery.of(context).size.width - 24 : 0,
        child: !selectionMode
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: backButtonWidth,
                      curve: Curves.fastOutSlowIn,
                      child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          enableFeedback: currentDirectory != null && currentDirectory!.parent.path != rootPath,
                          onPressed: () => navigateUp()),
                    ),
                    Expanded(
                        child: VieirosTextInput(
                            lightMode: lightMode,
                            hintText: I18n.translate('tracks_search_hint'),
                            onChanged: (text) => onSearchChanged(text),
                            controller: controller,
                            focusNode: searchFocusNode,
                            suffix: IconButton(
                                icon: Icon(controller.value.text == '' ? Icons.search : Icons.clear,
                                    color: lightMode ? CustomColors.subText : CustomColors.subTextDark),
                                onPressed: controller.value.text == '' ? null : () => clearValue()))),
                    IconButton(
                        icon: const Icon(Icons.sort), onPressed: () => setSortDirection(sortDirection: sortDirection == 'asc' ? 'desc' : 'asc'))
                  ])
            : const SizedBox());
  }
}
