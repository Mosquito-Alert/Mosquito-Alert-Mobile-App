import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

class MyLocalizations {
  MyLocalizations(this.locale);

  Locale locale = Locale(Utils.getLanguage());

  static Map<String, Map<String, String>> _localizedValues = {
    "es": {
      "app_name": "Mosquito Alert",
      "next": "Siguiente",
      "finish": "Finalizar",

      //Login - main
      "welcome_app_title": "Bienvenido a Mosquito Alert",
      "login_method_txt": "¿Cómo quieres acceder a la app?",
      "login_btn1": "Acceder con Facebook",
      "login_btn2": "Acceder con Gmail",
      "login_btn3": "Acceder con tu AppleID",
      "login_btn4": "Acceder con mi correo electrónico",
      "terms_and_conditions_txt":
          "Entrando en Mosquito Alert, aceptas nuestros términos y condiciones y nuestra política de privacidad.",

      //Login - email
      "enter_email_title": " Introduce tu correo electrónico",
      "email_txt": "Correo electrónico",
      "access_txt": "Acceder",

      // Login - password
      "enter_password_title": "Introduce tu contraseña",
      "user_password_txt": "Contrseña de usuario",
      "forgot_password_txt": "¿Has olvidado tu contrseña?",

      //Recover password
      "recover_password_title": "Recupera tu contraseña",
      "recover_password_btn": "Recuperar contraseña",

      //Signup
      "signup_user_title": "Registro de usuario",
      "signup_btn": "Darme de alta",
      "first_name_txt": "Nombre",
      "last_name_txt": "Apellidos",
      "password_txt": "Contraseña",

      //Main page

      "welcome_text": "Bienvenido de nuevo, ",
      "what_to_do_txt": "¿Que quieres hacer?",
      "more_info_points_txt":
          "Haz click aquí para conocer más acerca esta puntuación.",
      "report_biting_txt": "Reportar picada",
      "bitten_by_mosquito_question_txt": "¿Te ha picado un mosquito?",
      "report_nest_txt": "Reportar nido",
      "found_breeding_place_question_txt": "¿Has encontrado un lugar de cría?",
      "report_adults_txt": "Reportar adultos",
      "report_us_adult_mosquitos_txt":
          "Repórtanos los mosquitos adultos que veas.",
      "your_reports_txt": "Tus reportes",
      "explore_your_reports_txt": "Explora los reportes que has realizado.",
      "help_validating_other_photos_txt":
          "¿Nos ayudas a validar las fotografias de otros usuarios?",
      "we_need_help_txt": "¡Necesitamos tu ayuda! Colabora con Mosquito Alert",

      //Biting report
      "biting_report_txt": "Reportar una picadura",
      "need_more_information_txt": 'Nesecitamos un poco más de información.',
      "lets_go_txt": "¡Vamos a por ello!", 

      //Location report 
      "location_bited_txt": "¿En qué ubicación te ha picado?",
      "chose_option_txt": "Escoge una opción.",

      //Moquito type - report
      "could_see_txt": "¿Has podido ver el mosquito?", 
      "could_recognise_txt": "Si has visto al mosquito, ¿puedes reconocerlo a continuación?",
      "recognize_it_txt": "¿Lo reconoces?",
      "have_foto_txt": "¿Tienes una foto del mosquito?",
      "click_to_add_txt": "Haz click aquí para añadirla",

    },
  };
  String translate(key) {
    return _localizedValues[locale.languageCode][key];
  }

  static String of(BuildContext context, String key) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations)
        .translate(key);
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'es',
      ].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
