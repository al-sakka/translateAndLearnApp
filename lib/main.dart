import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_and_learn_app/cubit/cubit/dictionary_cubit.dart';
import 'package:translate_and_learn_app/cubit/cubit/image_to_text_cubit.dart';
import 'package:translate_and_learn_app/cubit/cubit/quiz_cubit.dart';
import 'package:translate_and_learn_app/cubit/gemini_api_cubit.dart';
import 'package:translate_and_learn_app/views/language_selection_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const apiKey = 'AIzaSyD2WmRS8KtpHKYi3DvMj_r1C_0-MBXmlPc';

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final imageModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final dictionaryModel =
      GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final bool hasSeenWelcome = await checkWelcomeScreenSeen();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('nativeLanguageCode');
  Locale? initialLocale;
  if (languageCode != null) {
    initialLocale = Locale(languageCode);
  }

  runApp(TranslateAndLearnApp(
    model: model,
    imageModel: imageModel,
    hasSeenWelcome: hasSeenWelcome,
    initialLocale: initialLocale,
    dictionaryModel: dictionaryModel,
  ));
}

Future<bool> checkWelcomeScreenSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenWelcome') ?? false;
}

class TranslateAndLearnApp extends StatelessWidget {
  const TranslateAndLearnApp({
    super.key,
    required this.model,
    required this.imageModel,
    required this.hasSeenWelcome,
    this.initialLocale,
    required this.dictionaryModel,
  });

  final GenerativeModel model;
  final GenerativeModel imageModel;
  final GenerativeModel dictionaryModel;
  final bool hasSeenWelcome;
  final Locale? initialLocale;
  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];

    return ScreenUtilInit(
        designSize: Size(375, 812), // Adjust the design size as needed
        minTextAdapt: true,
        builder: (context, child) => MultiProvider(
              providers: [
                Provider<GenerativeModel>.value(value: model),
                BlocProvider(
                  create: (context) => GeminiApiCubit(model),
                ),
                Provider<GenerativeModel>.value(value: imageModel),
                BlocProvider(
                  create: (context) => ImageToTextCubit(imageModel),
                ),
                Provider<GenerativeModel>.value(value: dictionaryModel),
                BlocProvider(
                  create: (context) => DictionaryCubit(dictionaryModel),
                ),
              ],
              child: MaterialApp(
                localizationsDelegates: [
                  // delegate from flutter_localization
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,

                  // delegate from localization package.
                  //json-file
                  LocalJsonLocalization.delegate,
                  //or map
                  MapLocalization.delegate,
                ],
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('es', 'ES'),
                  Locale('fr', 'FR'),
                  Locale('de', 'DE'),
                  Locale('it', 'IT'),
                  Locale('pt', 'BR'),
                  Locale('zh', 'CN'),
                  Locale('ja', 'JP'),
                  Locale('pl', 'PL'),
                  Locale('tr', 'TR'),
                  Locale('ru', 'RU'),
                  Locale('nl', 'NL'),
                  Locale('ko', 'KR'),
                ],
                locale: initialLocale,
                home: const LanguageSelectionPage(),
              ),
            ));
  }
}
//