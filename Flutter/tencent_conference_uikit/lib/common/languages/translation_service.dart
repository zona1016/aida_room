import 'dart:ui';

import 'package:get/get.dart';

import 'en_us.dart';
import 'zh_cn.dart';
import 'de.dart';
import 'es.dart';
import 'fr.dart';
import 'hi.dart';
import 'it.dart';
import 'ja.dart';
import 'ko.dart';
import 'mk.dart';
import 'pt.dart';
import 'sr.dart';
import 'vi.dart';

class RoomContentsTranslations {
  static const Map<String, Map<String, String>> translations = {
    'en': roomContentsEnUS,
    'zh': roomContentsZhCN,
    'de': roomContentsDeDE,
    'es': roomContentsEsES,
    'fr': roomContentsFrFR,
    'hi': roomContentsHiIN,
    'it': roomContentsItIT,
    'ja': roomContentsJaJP,
    'ko': roomContentsKoKR,
    'mk': roomContentsMkMK,
    'pt': roomContentsPtPT,
    'sr': roomContentsSr,
    'vi': roomContentsVi,
  };

  static const String fallbackLocale = 'en';

  static String translate(String key) {
    final deviceLocale = Get.deviceLocale;
    final languageCode = deviceLocale?.languageCode;

    switch (languageCode) {
      case 'zh':
      case 'en':
      case 'de':
      case 'es':
      case 'fr':
      case 'hi':
      case 'it':
      case 'ja':
      case 'ko':
      case 'mk':
      case 'pt':
      case 'sr':
      case 'vi':
        Get.locale ??= deviceLocale;
        break;
      default:
        Get.locale = const Locale(fallbackLocale);
    }

    final language = Get.locale?.languageCode ?? fallbackLocale;
    return translations[language]?[key] ?? key;
  }
}
