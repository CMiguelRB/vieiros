import 'package:flutter/material.dart';
import 'package:vieiros/resources/custom_colors.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosNotification {
  void showNotification(BuildContext context, String tag, NotificationType type) {
    Color backgroundColor = type == NotificationType.info ? CustomColors.info : CustomColors.error;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(I18n.translate(tag), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        margin: MediaQuery.of(context).viewInsets.bottom > 0
            ? EdgeInsets.only(left: 30, right: 30, bottom: MediaQuery.of(context).size.height - 250)
            : const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        backgroundColor: backgroundColor,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder()));
  }

  VieirosNotification._privateConstructor();

  static final VieirosNotification _instance = VieirosNotification._privateConstructor();

  factory VieirosNotification() {
    return _instance;
  }
}

enum NotificationType { info, error }
