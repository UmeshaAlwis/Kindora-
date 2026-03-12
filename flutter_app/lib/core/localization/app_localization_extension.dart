import 'package:flutter/material.dart';
import 'package:kindora/l10n/app_localizations.dart';

extension AppLocalizationExtension on BuildContext {

  AppLocalizations get tr => AppLocalizations.of(this)!;

}