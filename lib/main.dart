/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:catcher/catcher.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/themes.dart';
import 'package:privacyidea_authenticator/widgets/custom_page_report_mode.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
            channelKey: NOTIFICATION_CHANNEL_ANDROID,
            channelName: 'Push Challenges',
            channelDescription: 'Notifications are shown for incoming push challenges.',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white
        )
      ]
  );


  CatcherOptions debugOptions = CatcherOptions(SilentReportMode(), [
    ConsoleHandler(
        enableApplicationParameters: false,
        enableDeviceParameters: false,
        enableCustomParameters: false,
        enableStackTrace: true)
  ]);

  CatcherOptions releaseOptions = CatcherOptions(CustomPageReportMode(), [
    EmailManualHandler([defaultCrashReportRecipient],
        enableCustomParameters: false)
  ]);

  Catcher(
    rootWidget: PrivacyIDEAAuthenticator(
        preferences: await StreamingSharedPreferences.instance),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class PrivacyIDEAAuthenticator extends StatelessWidget {
  final StreamingSharedPreferences _preferences;

  const PrivacyIDEAAuthenticator(
      {required StreamingSharedPreferences preferences})
      : this._preferences = preferences;

  @override
  Widget build(BuildContext context) {
    return EasyDynamicThemeWidget(
      child: AppSettings(
        preferences: this._preferences,
        child: Builder(
          builder: (context) {
            var crashReportRecipients =
                AppSettings.of(context).crashReportRecipients;

            // Override release config to use custom e-mail recipients
            Catcher.getInstance().updateConfig(
              releaseConfig: CatcherOptions(CustomPageReportMode(), [
                EmailManualHandler(crashReportRecipients,
                    enableCustomParameters: false)
              ]),
            );

            return StreamBuilder<bool>(
              stream: AppSettings.of(context).streamUseSystemLocale(),
              builder: (context, snapshot) {
                bool useSystemLocale = true;
                if (snapshot.hasData) {
                  useSystemLocale = snapshot.data!;
                }

                return StreamBuilder<Locale>(
                  stream: AppSettings.of(context).streamLocalePreference(),
                  builder: (context, snapshot) {
                    Locale? locale;
                    if (!useSystemLocale && snapshot.hasData) {
                      locale = snapshot.data!;
                    }

                    return MaterialApp(
                      navigatorKey: Catcher.navigatorKey,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: locale,
                      title: applicationName,
                      theme: lightThemeData,
                      darkTheme: darkThemeData,
                      themeMode: EasyDynamicTheme.of(context).themeMode,
                      home: MainScreen(title: applicationName),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
