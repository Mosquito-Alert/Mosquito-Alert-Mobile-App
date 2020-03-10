import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

class MyLocalizations {
  MyLocalizations(this.locale);

  Locale locale = Locale(Utils.getLanguage());

  static Map<String, Map<String, String>> _localizedValues = {
    "es": {
      "app_name": "Mosquito Alert",

      //Login - main
      "welcome_app_title": "Bienvenido a Mosquito Alert",
      "login_method_txt": "¿Cómo quieres acceder a la app?",
      "login_btn1": "Acceder con Facebook",
      "login_btn2": "Acceder con Gmail",
      "login_btn3": "Acceder con tu AppleID",
      "login_btn4": "Acceder con mi correo electrónico",
      "terms_and_conditions_txt": "Entrando en Mosquito Alert, aceptas nuestros términos y condiciones y nuestra política de privacidad.",

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
      "what_to_do_txt": "¿Que quieres hacer?"
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
