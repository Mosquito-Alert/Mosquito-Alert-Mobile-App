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
      "unknoun": "Desconocido",
      "ok": 'Aceptar',
      "delete": "Eliminar",
      "edit": "Editar",
      "exit": "Salir",
      "yes": "Si",
      "no": "No",
      "delete": "Eliminar",
      "cancel": "Cancelar",

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
      "register_txt": "Darse de alta",

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

      //Biting - report
      "biting_report_txt": "Reportar una picadura",
      "need_more_information_txt": 'Nesecitamos un poco más de información.',
      "lets_go_txt": "¡Vamos a por ello!",
      "tap_image_biting_txt":
          "Haz click encima de la imagen para reportar una nueva picada.",
      "continue_txt": "Continuar",
      "complete_all_txt": "Complete todos los campos para continuar",

      //Location - report
      "location_bited_txt": "¿En qué ubicación te ha picado?",
      "chose_option_txt": "Escoge una opción.",
      "location_not_active_title": "Localización desactivada",
      "location_not_active_txt":
          "Para utilizar esta función, activa la localización del dispositivo",
      "current_location_txt": "Ubicación actual",
      "select_location_txt": "Seleccionar...",
      "not_sure_txt": "No lo tengo claro",

      //Moquito type - report
      "could_see_txt": "¿Has podido ver el mosquito?",
      "could_recognise_txt":
          "Si has visto al mosquito, ¿puedes reconocerlo a continuación?",
      "recognize_it_txt": "¿Lo reconoces?",
      "have_foto_txt": "¿Tienes una foto del mosquito?",
      "click_to_add_txt": "Haz click aquí para añadirla",
      "send_photo_title": "Mándanos una foto",
      "adult_report_title": "Reportar un adulto",
      "breeding_report_title": "Reportar un nido",

      //Notifications page
      "notifications_title": "Notificaciones",

      //Setings page
      "settings_title": "Ajustes",
      "login_with_your_account_txt": "Accede con tu cuenta de usuario",
      "use_your_acount_details_txt":
          "Si accedes a la app con tus credenciales, podrás guardar y sincronizar tus datos entre distintos dispositivos.",
      "share_app_txt": "Comparte esta app",
      "open_web_txt": "Abrir página web...",
      "more_info_app_txt": "Más información acerca de Mosquito Alert",
      "our_partners_txt": "Nuestros partners y colaboradores",

      //My reports page
      "your_reports_txt": "Tus reportes",
      "map_txt": "Mapa",
      "list_txt": "Lista",
      "report_of_the_day_txt": "Reporte del día ",
      "location_txt": "Ubicación aproximada: ",
      "at_time_txt": "A las: ",
      "report_of_the_day_txt": "Reporte del día ",
      "registered_location_txt": "Ubicación registrada",
      "exact_time_register_txt": "Hora exacta del regitro",
      "reported_images_txt": "Imagenes reportadas",
      "reported_species_txt": "Especie reportada",
      "when_biting_txt": "¿Cuando te ha picado?",
      "which_situation_txt": "¿En qué situación?",
      "delete_report_title": "¿Seguro que quieres eliminar el reporte?",
      "delete_report_txt": "Esta acción no se puede deshacer."
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

// class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
//   const MyLocalizationsDelegate();

//   @override
//   bool isSupported(Locale locale) => [
//         'es',
//         'en'
//       ].contains(locale.languageCode);

//   @override
//   Future<MyLocalizations> load(Locale locale) {
//     return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
//   }

//   @override
//   bool shouldReload(MyLocalizationsDelegate old) => false;
// }
