import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;

  static Map<String, Map<String, String>> _localizedValues = {
    "es": {
      "app_name": "Mosquito Alert",
      "ok": 'Aceptar',
      "cancel": "Cancelar",
      "yes": "Sí",
      "no": "No",
      "delete": "Eliminar",
      "edit": "Editar",
      "exit": "Salir",
      "reset": "Reset",
      "es": "Español",
      "ca": "Catalán",
      "en": "Inglés",
      "understand_txt": "Entendido",

      //LINKS
      "url_politics": "http://webserver.mosquitoalert.com/es/privacy/",
      "url_legal": "https://www.google.cat",
      "url_point_1": "http://madev.creaf.cat/",
      "url_point_2": "/stats/user_ranking/1/",
      "url_consent_form": "http://webserver.mosquitoalert.com/es/terms/",
      "url_web": "http://www.mosquitoalert.com",
      "url_scoring_1": "http://webserver.mosquitoalert.com/",
      "url_scoring_2": "/scoring/",
      "url_about_us": "http://tigaserver2.ceab.csic.es/en/about_us/",
      "url_about_project": "http://tigaserver2.ceab.csic.es/en/project_about/",

      //Login - main
      "welcome_app_title": "Bienvenido a Mosquito Alert",
      "login_method_txt": "¿Cómo quieres acceder a la app?",
      "login_btn1": "Acceder con Facebook",
      "login_btn2": "Acceder con Gmail",
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
      "invalid_mail_txt": "Correo electrónico no valido. Inténtalo de nuevo.",
      "email_error_txt":
          "Error al revisar el correo electrónico. Inténtalo de nuevo.",

      // Login - password
      "enter_password_title": "Introduce tu contraseña",
      "user_password_txt": "Contraseña de usuario",
      "forgot_password_txt": "¿Has olvidado tu contraseña?",
      "social_login_ko_txt": "Ocurrió un error, inténtalo de nuevo por favor",
      "login_alert_ko_text":
          "Los datos de acceso no son correctos. Por favor, revísalos e inténtalo de nuevo.",

      //Recover password
      "recover_password_title": "Recupera tu contraseña",
      "recover_password_btn": "Recuperar contraseña",
      "recover_password_alert":
          "Si ya tenemos tu e-mail en nuestra base de datos, recibirás un correo para recuperar tu contraseña",

      //Signup
      "signup_user_title": "Registro de usuario",
      "signup_btn": "Darme de alta",
      "first_name_txt": "Nombre",
      "last_name_txt": "Apellidos",
      "password_txt": "Contraseña",

      //Main page
      "welcome_text": "Hola",
      "what_to_do_txt": "¿Qué quieres hacer?",

      "report_biting_txt": "Notificar picadura",
      "bitten_by_mosquito_question_txt": "",
      "report_nest_txt": "Notificar lugar de cría",
      "found_breeding_place_question_txt": "en la vía pública",
      "report_adults_txt": "Notificar mosquito",

      "report_us_adult_mosquitos_txt":
          "creo que es una de las especies buscadas",
      "your_reports_txt": "Mis datos",
      "explore_your_reports_txt": "ver o modificar los datos enviados",
      "help_validating_other_photos_txt":
          "¿Nos ayudas a validar las fotografías de otros usuarios?",
      "we_need_help_txt": "¡Necesitamos tu ayuda! Colabora con Mosquito Alert",

      //Biting - report
      "biting_report_txt": "Notificar picaduras",
      "tap_image_biting_txt": "Señala dónde te han picado",
      "continue_txt": "Continuar",
      "complete_all_txt": "Complete todos los campos para continuar",
      "save_report_ok_txt": "Notificación guardada correctamente",
      "save_report_ko_txt": "Error, inténtalo de nuevo más tarde",
      "send_data": "Enviar datos",
      "bytes_and_place_report_txt":
          "¿Cuántas picaduras tienes y en qué parte del cuerpo?",

      "close_report_no_save_txt":
          "Se perderan los datos introducidos. ¿Estas seguro de salir sin guardar?",
      "add_comments_question": "Quieres añadir un comentario?",
      "comments_txt": "Comentarios",

      //Location - report
      "chose_option_txt": "Elige una opción.",
      "location_not_active_title": "Localización desactivada",
      "location_not_active_txt":
          "Para utilizar esta función, activa la localización del dispositivo",
      "current_location_txt": "Ubicación actual",
      "select_location_txt": "Seleccionar ubicación",
      "not_sure_txt": "No lo tengo claro",
      "gallery": "Galería",
      "camara": "Cámara",
      "ok_next_txt": "De acuerdo, hacer foto!",

      //Moquito type - report
      "could_recognise_txt":
          "Si has visto al mosquito, ¿puedes reconocerlo a continuación?",
      "recognize_it_txt": "¿Lo reconoces?",
      "have_foto_txt": "¿Tienes una foto del mosquito?",
      "click_to_add_txt": "Haz click aquí para añadirla",
      "send_photo_title": "Mándanos una foto",
      "adult_report_title": "Notificar un mosquito",
      "breeding_report_title": "Notificar un lugar de cría",
      "not_a_mosquito": "No es un mosquito",
      "continue_without_photo": "Continuar sin foto",
      "camera_info_adult_txt_01":
          "Añade una foto para que podamos validar la observación del mosquito. Intenta fotografiarlo mosquito de manera que se vea el diseño del tórax así como las patas.",
      "camera_info_adult_txt_02":
          "No compartas información personal, como imágenes de personas reconocibles o datos personales.",
      "camera_info_breeding_txt_01":
          "Añade una foto para que podamos identificar el lugar de cría. Si puedes, haz una foto general del lugar y otra de detalle.",
      "camera_info_breeding_txt_02":
          "No compartas fotografías que puedan contener información personal, como imágenes de personas reconocibles o datos personales. Si tienes dudas, consulta la política de privacidad en los ajustes de la app.",
      "no_show_again": "No volver a mostrar",
      "no_photos_added_txt": "No has añadido fotos al report",
      "more_info_in_txt": "Más información en ",
      "other_type_info_txt":
          "Mosquito Alert no recopila datos de otras especies.",

      //Notifications page
      "notifications_title": "Notificaciones",
      "no_notifications_yet_txt": "No tienes notificaciones",

      //Setings page
      "settings_title": "Ajustes",
      "login_with_your_account_txt": "Accede con tu cuenta de usuario",
      "use_your_acount_details_txt":
          "Si accedes a la app con tus credenciales, podrás guardar y sincronizar tus datos entre distintos dispositivos.",
      "more_info_app_txt": "Sobre nosotros",
      "our_partners_txt": "Sobre el proyecto",
      "logout_txt": "Cerrar sesión",
      "logout_alert_txt": "¿Estás seguro de querer cerrar la sesión?",
      "select_language_txt": "Idioma",
      "info_scores_txt": "Información puntuación",
      "tutorial_txt": "Tutorial",
      "mosquito_gallery_txt": "Guía de mosquitos",
      "privacy_policy_txt": "Política de privacidad",

      "disable_background_tracking": "Deshabilitar background tracking",
      "enable_background_tracking": "Habilitar background tracking",
      "disable_tracking_question_text":
          "Se va a desabilitar el background tracking. ¿Esta seguro?",
      "enable_tracking_question_text":
          "Se va a habilitar el background tracking. ¿Esta seguro?",
      "mosquitos_gallery_txt": "Guía de mosquitos",
      "about_the_project_txt": "Sobre el proyecto",
      "about_us_txt": "Sobre nostros",
      "terms_of_use_txt": "Licencia y términos de uso",
      "gallery_info_01":
          "Buscamos 5 especies de mosquito: el (1) Mosquito tigre (Ae. albopictus), el (2) Mosquito de la fiebre amarilla (Ae. aegypti), el (3) Mosquito del Japón (Ae. japonicus), el (4) Mosquito de Corea (Ae. koreicus) y el (5) Mosquito común (C. pipiens). Con esta guía aprenderás a identificarlos.",
      "gallery_info_02":
          "Para identificar especies de mosquito, necesitas saber que su cuerpo se divide en 3 partes: (A) cabeza, (B) tórax y (C) abdomen. El tórax, que es como la espalda del mosquito, tiene un dibujo que nos permite distinguir varias especies. También el patrón de manchas de las patas, especialmente el del tercer par (3) y, en menor ",
      "gallery_info_03":
          "El mosquito común (Culex pipiens): el que nos pica principalmente de noche. Es de color amarillento/marrón pálido.",
      "gallery_info_04":
          "Los otros 4 mosquitos que buscamos son del género Aedes (Ae.): son oscuros o negros con manchas blancas y acostumbran a picar de día, también al amanecer y atardecer. Dos especies tienen el dibujo del tórax blanco, mientras que las otras dos, dorado. Sigue aprendiendo a separar estas 4 especies.",
      "gallery_info_05":
          "Mosquito tigre (Ae. albopictus): es negro; tiene una sola línea blanca en cabeza y tórax. Mosquito de la fiebre amarilla (Ae. aegypti): es de color marrón oscuro; tiene un dibujo en forma de lira. En ambos casos el dibujo del tórax es blanco.",
      "gallery_info_06":
          "Ae. japonicus y Ae. koreicus tienen el dibujo del tórax dorado y son muy parecidos. Para diferenciarlos tienes que fijarte en sus patas, concretamente en las manchas del tercer par de patas. Ae. koreicus tiene en su parte final un par de manchas blancas que no existen en Ae. japonicus.",
      "gallery_info_07":
          "Los mosquitos tienen un ciclo de vida complejo, con 4 etapas: (1) las hembras de adulto ponen (2) huevos en recipientes con agua estancada; en unos días, nacen (3) las larvas y (4) las pupas, que son acuáticas. Las pupas crecen y hacen la metamorfosis al adulto. Una hembra puede llegar a poner centenares de huevos. Recuerda: sin agua estancada no hay mosquitos.",
      "gallery_info_08":
          "Puesta de huevos de mosquitos del género Aedes. Las hembras ponen los huevos en seco sobre las paredes de recipientes pequeños, cercanos al agua estancada. Los huevos son tan pequeños que son difíciles de ver a simple vista. Abajo, larvas (alargadas) y pupas (redondeadas) de mosquitos Aedes.",
      "gallery_info_09":
          "Las larvas son acuáticas y en poco tiempo se transforman en pupas y luego en mosquitos adultos mediante el proceso que se conoce como metamorfosis. En la fase adulta, los machos y hembras de Aedes pueden diferenciarse por los penachos en la cabeza. Mosquito tigre macho a la izquierda, y hembra a la derecha.",
      "gallery_info_10":
          "En los espacios públicos los mosquitos pueden reproducirse allí donde se acumule agua. En las zonas urbanas los imbornales son un importante lugar de cría para muchos de estos mosquitos. También agujeros de árboles, la base de árboles, estanques o espacios donde se puedan producir charcos.",
      "gallery_info_11":
          "En los espacios privados los Aedes pueden aprovechar cualquier pequeño contenedor con agua para desarrollarse. Eso incluye los platos de las macetas que recogen el exceso de agua, cubos o juguetes en el jardín que se llenen de agua con la lluvia. Para prevenir los mosquitos en casa hay que vigilar los espacios y objetos donde se pueda acumular agua.",

      "tutorial_info_01":
          "Te damos la bienvenida a Mosquito Alert, una plataforma de ciencia ciudadana para investigar y controlar mosquitos transmisores de enfermedades como el dengue, el Zika, la chikungunya o la fiebre del Nilo Occidental. ",
      "tutorial_info_01_1":
          "Antes de empezar a participar, familiarízate con la app y aprende trucos para enviar datos útiles para la ciencia.",
      "tutorial_info_02":
          "Buscamos 5 especies de mosquito: el (1) Mosquito tigre (Ae. albopictus), el (2) Mosquito de la fiebre amarilla (Ae. aegypti), el (3) Mosquito del Japón (Ae. japonicus), el (4) Mosquito de Corea (Ae. koreicus) y el (5) Mosquito común (C. pipiens).",
      "tutorial_info_03":
          "No necesitas experiencia en mosquitos, pero sí saber un par de cosas: el tórax es el segmento que está detrás de la cabeza del mosquito. Es como una espalda. Cada especie tiene su propio dibujo en cabeza y tórax (1) y eso nos permite identificarlas.",
      "tutorial_info_04":
          "Estos mosquitos crían en pequeños recipientes con agua estancada, como imbornales, macetas, bocas de riego, agujeros... Allí ponen sus huevos y crecen sus larvas acuáticas. Recuerda: sin agua no hay mosquitos.",
      "tutorial_title_05": "Para empezar a participar, notifica mosquit",
      "tutorial_info_05":
          "Si crees que has encontrado una de las 5 especies, comparte tu información con el botón amarillo. Intenta fotografiar su tórax y cuerpo entero.",
      "tutorial_title_06": "También puedes notificar picaduras",
      "tutorial_info_06":
          "Si crees que te ha picado alguno de estos mosquitos, puedes compartirlo con el botón rojo. Indica dónde y cuándo te han picado. Puedes hacerlo tantas veces como haga falta. ",
      "tutorial_title_07":
          "También puedes notificar lugares de cría en la vía pública",
      "tutorial_info_07":
          "Utiliza el botón azul. Añade una foto para que lo podamos identificar.",
      "tutorial_title_08": "Consulta y edita tus datos",
      "tutorial_info_08":
          "Podrás ver tu historial de participación, modificar datos enviados y consultar información reciente de otros participantes en tu zona.",
      "tutorial_title_09": "Valida fotos de otras personas.",
      "tutorial_info_09":
          "Anímate a clasificar fotos y a determinar la especie. No te preocupes si tienes dudas, será la opinión de muchas personas juntas la que contará.",
      "tutorial_title_10": "Consigue puntos",
      "tutorial_info_10":
          "Cuantos más y mejores datos envíes, y más fotos de otros valides, más puntos conseguirás. Incluso puedes subir de nivel.",
      "tutorial_title_11": "Mantente informado",
      "tutorial_info_11":
          "Recibirás respuestas de expertos sobre tus observaciones y estarás al día de las últimas noticias.",
      "tutorial_title_12": "Configura Mosquito Alert",
      "tutorial_info_12":
          "En el menú podrás cambiar el idioma y acceder a contenidos extra. Encontrarás también una guía de identificación de especies y el tutorial de la app.",
      "tutorial_title_13": "El esfuerzo de muestreo, esencial para la ciencia",
      "tutorial_info_13":
          "De manera aleatoria, y no más de 5 veces al día, si lo permites, Mosquito Alert recoge tu posición aproximada, en una cuadrícula de 2x2 km aproximadamente (250 campos de fútbol juntos). No sabremos en qué lugar concreto has estado, y así, mantenemos tu privacidad. Además, esta información está desvinculada de los datos de mosquitos que env��es. Obtener esta información es esencial para la ciencia: sin ella, no podemos saber si hay muchos mosquitos o si en realidad lo que hay es mucha participación. Si no deseas que la app recoja tu posición aproximada, desactiva esta opci��n en el menú (ajustes).",
      "tutorial_title_14": "Conserva tus datos y mantén tu anonimato",
      "tutorial_info_14":
          "Tu participación es anónima. Aún así, hemos desarrollado un sistema que te permite, si quieres, iniciar sesión en Mosquito Alert con cuentas externas y conservar tus datos y puntuación. Así, puedes sincronizar varios dispositivos y recuperar datos si tienes que desinstalar la app. Más información en el menú y en la Política de Privacidad de la app.",
      "tutorial_info_15":
          "¡Ya puedes empezar! Tus observaciones contribuirán al estudio de los mosquitos transmisores de enfermedades. Encontrarás información muy detallada y recomendaciones de cómo hacer buenas fotos en: www.mosquitoalert.com.",

      //My reports page
      "map_txt": "Mapa",
      "list_txt": "Lista",
      "report_of_the_day_txt": "Notificación del día ",
      "location_txt": "Ubicación aproximada: ",
      "at_time_txt": "A las: ",
      "registered_location_txt": "Ubicación registrada",
      "exact_time_register_txt": "Hora exacta del registro",
      "reported_images_txt": "Imágenes enviadas",
      "delete_report_title": "¿Seguro que quieres eliminar la notificación?",
      "delete_report_txt": "Esta acción no se puede deshacer.",
      "your_reports_bites_txt": "Tus notificaciones de picaduras",
      "your_reports_breeding_txt": "Tus notificaciones de lugares de cría",
      "your_reports_adults_txt": "Tus notificaciones de adultos",
      "no_reports_yet_txt": "No hay notificaciones registradas",
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
