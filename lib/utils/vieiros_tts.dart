import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:vieiros/resources/i18n.dart';

class VieirosTts {

  void speakDistance(int distance, DateTime dateTime) async {
    FlutterTts _flutterTts = FlutterTts();
    final String lang = Platform.localeName.replaceAll("_", "-");
    await _flutterTts.setLanguage(lang);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    DateTime start = dateTime;
    int secs = DateTime.now().difference(start).abs().inSeconds;
    String hText = secs >= 7200 ?  I18n.translate('map_voice_notification_h') : I18n.translate('map_voice_notification_h').substring(0, I18n.translate('map_voice_notification_h').length-1);
    String mnText = secs > 120 ? I18n.translate('map_voice_notification_m') : I18n.translate('map_voice_notification_m').substring(0, I18n.translate('map_voice_notification_m').length-1);
    String hours = '';
    String minutes = '';
    String seconds = '';
    if (secs > 3600) {
      int h = secs ~/ 3600;
      hours = h.toString();
      secs -= h * 3600;
    }
    if (secs > 60) {
      int m = secs ~/ 60;
      minutes = m.toString();
      secs -= m * 60;
    }
    seconds = secs.toString();
    String km = (distance ~/ 1000).toString();
    await _flutterTts.speak(I18n.translate('map_voice_notification_pace'));
    String kText = distance >= 2000 ? km.toString() : I18n.translate('map_voice_notification_km_first');
    String kmText = distance >= 2000 ? I18n.translate('map_voice_notification_km') : I18n.translate('map_voice_notification_km').substring(0, I18n.translate('map_voice_notification_km').length-1);
    await _flutterTts.speak(
        kText +
        kmText +
        I18n.translate('map_voice_notification_in') +
            hours +
        (hours != '' ? hText : '') +
            minutes +
        (minutes != '' ? mnText : '') +
        seconds +
        I18n.translate('map_voice_notification_s'));
  }

  VieirosTts._privateConstructor();

  static final VieirosTts _instance = VieirosTts._privateConstructor();

  factory VieirosTts() {
    return _instance;
  }
}
