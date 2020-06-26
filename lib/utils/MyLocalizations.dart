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
      "cancel": "Cancelar",
      "yes": "Si",
      "no": "No",
      "delete": "Eliminar",
      "edit": "Editar",
      "exit": "Salir",
      "url_politics": "https://www.google.cat",
      "url_legal": "https://www.google.cat",
      "reset": "Reset",
      'close': "Cerrar",

      //Login - main
      "welcome_app_title": "Bienvenido a Mosquito Alert",
      "login_method_txt": "¿Cómo quieres acceder a la app?",
      "login_btn1": "Acceder con Facebook",
      "login_btn2": "Acceder con Gmail",
      "login_btn3": "Acceder con tu AppleID",
      "login_btn4": "Acceder con mi correo electrónico",
      "login_btn5": "Acceder con Twitter",
      "terms_and_conditions_txt1":
          "Entrando en Mosquito Alert, aceptas nuestros",
      "terms_and_conditions_txt2": "términos y condiciones",
      "terms_and_conditions_txt3": "y nuestra",
      "terms_and_conditions_txt4": "política de privacidad",

      //Login - email
      "enter_email_title": " Introduce tu correo electrónico",
      "email_txt": "Correo electrónico",
      "access_txt": "Acceder",
      "register_txt": "Darse de alta",
      "invalid_mail_txt": "Correo electrónico no valido. Intentalo de nuevo.",
      "email_error_txt":
          "Error al revisar el correo electrónico. Intentalo de nuevo.",

      // Login - password
      "enter_password_title": "Introduce tu contraseña",
      "user_password_txt": "Contrseña de usuario",
      "forgot_password_txt": "¿Has olvidado tu contrseña?",
      "social_login_ko_txt": "Ocurrió un error, intentalo de nuevo por favor.",
      "login_alert_ko_text":
          "Los datos de acceso no son correctos. Por favor, revísalos e inténtalo de nuevo.",

      //Recover password
      "recover_password_title": "Recupera tu contraseña",
      "recover_password_btn": "Recuperar contraseña",
      "recover_password_alert":
          "Si ya tenemos tu e-mail en nuestra base de datos, recibirás un correo para recuperar tu contraseña.",

      //Signup
      "signup_user_title": "Registro de usuario",
      "signup_btn": "Darme de alta",
      "first_name_txt": "Nombre",
      "last_name_txt": "Apellidos",
      "password_txt": "Contraseña",

      //Main page
      "welcome_text": "Bienvenido de nuevo",
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
      "save_report_ok_txt": "Reporte guardado correctamente",
      "save_report_ko_txt": "Error, intentalo de nuevo más tarde",
      "send_data": "Enviar datos",

      //Location - report
      "location_bited_txt": "¿En qué ubicación te ha picado?",
      "chose_option_txt": "Escoge una opción.",
      "location_not_active_title": "Localización desactivada",
      "location_not_active_txt":
          "Para utilizar esta función, activa la localización del dispositivo",
      "current_location_txt": "Ubicación actual",
      "select_location_txt": "Seleccionar...",
      "not_sure_txt": "No lo tengo claro",
      "gallery": "Galería",
      "camara": "Cámara",
      "add_image_txt": "Añadir foto",
      "add_image_from_where_txt": "¿De dónde quieres subir la imagen?",
      "ok_next_txt": "De acuerdo, hacer foto!",

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
      "not_a_mosquito": "No es un mosquito",

      //Notifications page
      "notifications_title": "Notificaciones",
      "no_notifications_yet_txt": "No tienes notificaciones",

      //Setings page
      "settings_title": "Ajustes",
      "login_with_your_account_txt": "Accede con tu cuenta de usuario",
      "use_your_acount_details_txt":
          "Si accedes a la app con tus credenciales, podrás guardar y sincronizar tus datos entre distintos dispositivos.",
      "share_app_txt": "Comparte esta app",
      "open_web_txt": "Abrir página web...",
      "more_info_app_txt": "Más información acerca de Mosquito Alert",
      "our_partners_txt": "Nuestros partners y colaboradores",
      "logout_txt": "Cerrar sesión",
      "logout_alert_txt": "¿Estás segurx que quieres cerrar sesión?",
      "select_language_txt": "Selecciona el idioma",
      "info_scores_txt": "Infromación scoring",
      "consent_form_txt": "Consent form",
      "tutorial_txt": "Tutorial",
      "mosquito_gallery_txt": "Galería de mosquitos (cómo identificar especies)", 
      "privacy_policy_txt": "Política de privacidad",

      //My reports page
      "map_txt": "Mapa",
      "list_txt": "Lista",
      "report_of_the_day_txt": "Reporte del día ",
      "location_txt": "Ubicación aproximada: ",
      "at_time_txt": "A las: ",
      "registered_location_txt": "Ubicación registrada",
      "exact_time_register_txt": "Hora exacta del registro",
      "reported_images_txt": "Imagenes reportadas",
      "reported_species_txt": "Especie reportada",
      "when_biting_txt": "¿Cuando te ha picado?",
      "which_situation_txt": "¿En qué situación?",
      "delete_report_title": "¿Seguro que quieres eliminar el reporte?",
      "delete_report_txt": "Esta acción no se puede deshacer.",
      "your_reports_bites_txt": "Tus reportes de picadas",
      "your_reports_breeding_txt": "Tus reportes de lugares de cría",
      "your_reports_adults_txt": "Tus reportes de adultos",
      "other_reports_bites_txt": "Reportes de picadas",
      "other_reports_breeding_txt": "Reportes de lugares de cría",
      "other_reports_adults_txt": "Reportes de adultos",
      "other_reports_txt": "Otros reportes",
      "no_reports_yet_txt": "No hay reportes registrados",
      "near_from_txt": "Cerca de",
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
