import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/resources/CustomColors.dart';

class Settings extends StatelessWidget {
  final prefs;

  Settings(this.prefs);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Text('')
              ],),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset('assets/app_logo.png', scale: 4),
              Text('Vieiros v1.0.0',
                  style: TextStyle(color: CustomColors.faintedText)),
              Container(
                margin: EdgeInsets.only(bottom: 10),
              )
            ],
          )
        ]));
  }
}
