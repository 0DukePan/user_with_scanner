import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hungerz/Components/bottom_bar.dart';
import 'package:hungerz/Config/app_config.dart';
import 'package:hungerz/Locale/locales.dart';
import 'package:hungerz/Routes/routes.dart';
import 'package:hungerz/Themes/colors.dart';
import 'package:hungerz/language_cubit.dart';
import 'package:hungerz/theme_cubit.dart';

class ThemeList {
  final String? title;
  final String? subtitle;

  ThemeList({this.title, this.subtitle});
}

class LanguageList {
  final String? title;

  LanguageList({this.title});
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool sliderValue = false;
  late LanguageCubit _languageCubit;
  late ThemeCubit _themeCubit;
  String? selectedLocal;
  String? selectedTheme;

  @override
  void initState() {
    _languageCubit = BlocProvider.of<LanguageCubit>(context);
    _themeCubit = BlocProvider.of<ThemeCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    final List<ThemeList> themes = <ThemeList>[
      ThemeList(
        title: AppLocalizations.of(context)!.darkMode,
        subtitle: AppLocalizations.of(context)!.darkText,
      ),
      ThemeList(
        title: AppLocalizations.of(context)!.lightMode,
        subtitle: AppLocalizations.of(context)!.lightText,
      ),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context)!.settings!,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.bold)),
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadedSlideAnimation(
        beginOffset: Offset(0.0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: Stack(
          children: [
            ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Container(
                  height: 57.7,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  //color: kCardBackgroundColor,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.display!,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: kTextColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.08,
                          fontSize: 17),
                    ),
                  ),
                ),
                BlocBuilder<ThemeCubit, ThemeData>(builder: (_, theme) {
                  sliderValue = _themeCubit.isDark;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: ListTile(
                      title: Text(
                        locale.darkMode!,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 18.3,
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        themes[1].subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.blueGrey),
                      ),
                      trailing: Switch(
                        value: sliderValue,
                        onChanged: (value) => _themeCubit.setTheme(value),
                      ),
                    ),
                  );
                }),
                Container(
                  height: 58.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.selectLanguage!,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: kTextColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.08,
                          fontSize: 17),
                    ),
                  ),
                ),
                BlocBuilder<LanguageCubit, Locale>(
                  builder: (context, currentLocale) {
                    selectedLocal ??= currentLocale.languageCode;
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: AppConfig.languagesSupported.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => RadioListTile(
                        value:
                            AppConfig.languagesSupported.keys.elementAt(index),
                        groupValue: selectedLocal,
                        title: Text(
                          AppConfig
                              .languagesSupported[AppConfig
                                  .languagesSupported.keys
                                  .elementAt(index)]!
                              .name,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onChanged: (langCode) =>
                            setState(() => selectedLocal = langCode as String),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomBar(
                  text: AppLocalizations.of(context)!.submit,
                  onTap: () {
                    _languageCubit.setCurrentLanguage(selectedLocal!, true);
                    Navigator.pushNamed(context, PageRoutes.loginNavigator);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
