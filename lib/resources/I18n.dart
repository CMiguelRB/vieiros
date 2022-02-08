import 'dart:io';

class I18n {

  static final _localizations = {
    "en": {
      "common_ok": "OK",
      "common_cancel": "Cancel",
      "common_discard": "Discard",
      "common_delete": "Delete",
      "common_confirm": "Are you sure?",
      "common_edit": "Edit",
      "common_empty_name": "Empty name",
      "common_save": "Save",
      "common_name": "Name",

      "appbar_tab_tracks": "Tracks",
      "appbar_tab_map": "Map",
      "appbar_tab_info": "Info",
      "appbar_tab_settings": "Settings",

      "app_close_warning_title": "Warning",
      "app_close_warning": "Do you really want to close the app?",

      "tracks_background_tip": "Press + to load a gpx track file",
      "tracks_file_validation_error": "Not a valid gpx file",
      "tracks_unloaded": "Track cleared from the map",
      "tracks_delete_route": "Delete route",

      "map_waypoint": "Waypoint name",
      "map_notification_title": "Recording track...",
      "map_notification_desc": "Vieiros is tracking your position",
      "map_start_recording_message": "Starting a new track!",
      "map_voice_notification_km_first": "one",
      "map_voice_notification_km": "kilometers",
      "map_voice_notification_h": "hours",
      "map_voice_notification_m": "minutes",
      "map_voice_notification_s": "seconds",
      "map_voice_notification_pace": "Pace: ",
      "map_voice_notification_in": "in",
      "map_stop_save": "Stop recording and save your track?",
      "map_track_name": "Track name",
      "map_permissions_request": "This app needs all times location permissions for tracking your position even while working on the background.",
      "map_grant_permissions": "Grant permissions",
      "map_finish_tracking": "Finish tracking",
      "map_track_pin_start": "Start",
      "map_track_pin_finish": "Finish",

      "info_current_track": "Current track",
      "info_loaded_track": "Loaded track",
      "info_total_time": "Total time",
      "info_total_distance": "Distance",
      "info_daytime": "Daytime",
      "info_daytime_left": "Hours left",
      "info_daytime_sunset": "Sunset",
      "info_pace": "Avg pace",
      "info_altitude": "Altitude",
      "info_altitude_current": "Current",
      "info_altitude_top": "Top",
      "info_altitude_gain": "Gain",
      "info_chart_altitude": "Altitude",
      "info_chart_distance": "Distance",

      "settings_appearance": "Appearance",
      "settings_dark_mode": "Theme",
      "settings_alerts": "Alerts",
      "settings_voice_alerts": "Voice alerts",
      "settings_voice_alerts_desc": "Turns on voice alerts for every kilometer",
      "settings_donate": "Donate",
      "settings_dark_mode_item_system": "System",
      "settings_dark_mode_item_light": "Light",
      "settings_dark_mode_item_dark": "Dark"
    },
    "es":{
      "common_ok": "Aceptar",
      "common_cancel": "Cancelar",
      "common_discard": "Descartar",
      "common_delete": "Eliminar",
      "common_confirm": "¿Estás seguro?",
      "common_edit": "Modificar",
      "common_empty_name": "Introduce un nombre",
      "common_save": "Guardar",
      "common_name": "Nombre",

      "appbar_tab_tracks": "Rutas",
      "appbar_tab_map": "Mapa",
      "appbar_tab_info": "Info",
      "appbar_tab_settings": "Configuración",

      "app_close_warning_title": "Aviso",
      "app_close_warning": "¿Quieres cerrar la apliación?",

      "tracks_background_tip": "Presiona + para cargar archivo de ruta gpx",
      "tracks_file_validation_error": "Archivo gpx no válido",
      "tracks_unloaded": "Ruta limpiada del mapa",
      "tracks_delete_route": "Eliminar ruta",

      "map_waypoint": "Nombre punto de ruta",
      "map_notification_title": "Grabando ruta...",
      "map_notification_desc": "Vieiros está obteniendo tu ubicación",
      "map_start_recording_message": "Empezando la ruta!",
      "map_voice_notification_km_first": "un",
      "map_voice_notification_km": "kilómetros",
      "map_voice_notification_h": "horas",
      "map_voice_notification_m": "minutos",
      "map_voice_notification_s": "segundos",
      "map_voice_notification_in": " en ",
      "map_voice_notification_pace": "Ritmo: ",
      "map_stop_save": "¿Terminar de grabar y guardar la ruta?",
      "map_track_name": "Nombre de la ruta",
      "map_permissions_request": "Esta app requiere permisos de ubicación en todo momento para obtener tu ubicación incluso cuando la tengas en segundo plano.",
      "map_grant_permissions": "Conceder permisos",
      "map_finish_tracking": "Terminar grabación",
      "map_track_pin_start": "Comienzo",
      "map_track_pin_finish": "Fin",

      "info_current_track": "Ruta actual",
      "info_loaded_track": "Ruta cargada",
      "info_total_time": "Tiempo total",
      "info_total_distance": "Distancia",
      "info_daytime": "Horas de luz",
      "info_daytime_left": "Horas restantes",
      "info_daytime_sunset": "Ocaso",
      "info_pace": "Ritmo medio",
      "info_altitude": "Altitud",
      "info_altitude_current": "Actual",
      "info_altitude_top": "Top",
      "info_altitude_gain": "Desnivel acumulado",
      "info_chart_altitude": "Altitud",
      "info_chart_distance": "Distancia",

      "settings_appearance": "Aspecto",
      "settings_dark_mode": "Tema",
      "settings_voice_alerts": "Alertas de voz",
      "settings_alerts": "Alertas",
      "settings_voice_alerts_desc": "Activa alertas de voz por cada kilómetro",
      "settings_donate": "Donar",
      "settings_dark_mode_item_system": "Sistema",
      "settings_dark_mode_item_light": "Tema claro",
      "settings_dark_mode_item_dark": "Tema oscuro"
    },
    "gl":{
      "common_ok": "Aceptar",
      "common_cancel": "Cancelar",
      "common_discard": "Descartar",
      "common_delete": "Eliminar",
      "common_confirm": "¿Estás seguro?",
      "common_edit": "Modificar",
      "common_empty_name": "Introduce un nome",
      "common_save": "Gardar",
      "common_name": "Nome",


      "appbar_tab_tracks": "Rutas",
      "appbar_tab_map": "Mapa",
      "appbar_tab_info": "Info",
      "appbar_tab_settings": "Configuración",

      "app_close_warning_title": "Aviso",
      "app_close_warning": "¿Queres pechar a apliación?",

      "tracks_background_tip": "Presiona + para cargares un arquivo de ruta gpx",
      "tracks_file_validation_error": "Arquivo gpx non válido.",
      "tracks_unloaded": "Ruta limpada do mapa",
      "tracks_delete_route": "Eliminar ruta",

      "map_waypoint": "Nome punto de ruta",
      "map_notification_title": "Gravando ruta...",
      "map_notification_desc": "Vieiros está obtendo a túa ubicación",
      "map_start_recording_message": "Comenzado a ruta!",
      "map_voice_notification_km_first": "un",
      "map_voice_notification_km": "quilómetros",
      "map_voice_notification_h": "horas",
      "map_voice_notification_m": "minutos",
      "map_voice_notification_s": "segundos",
      "map_voice_notification_in": " en ",
      "map_voice_notification_pace": "Ritmo: ",
      "map_stop_save": "¿Rematar de gravar e gardar a ruta?",
      "map_track_name": "Nome da ruta",
      "map_permissions_request": "Esta app require permisos de ubicación en todo momento para obter a túa ubicación incluso cando a teñas en segundo plano.",
      "map_grant_permissions": "Conceder permisos",
      "map_finish_tracking": "Rematar gravación",
      "map_track_pin_start": "Comezo",
      "map_track_pin_finish": "Fin",

      "info_total_current_track": "Ruta actual",
      "info_total_loaded_track": "Ruta cargada",
      "info_total_time": "Tempo total",
      "info_total_distance": "Distancia",
      "info_total_daytime": "Horas de luz",
      "info_total_daytime_left": "Horas restantes",
      "info_total_daytime_sunset": "Ocaso",
      "info_total_pace": "Ritmo medio",
      "info_altitude": "Altitude",
      "info_altitude_current": "Actual",
      "info_altitude_top": "Top",
      "info_altitude_gain": "Desnivel acumulado",
      "info_chart_altitude": "Altitude",
      "info_chart_distance": "Distancia",

      "settings_appearance": "Aspecto",
      "settings_dark_mode": "Tema",
      "settings_voice_alerts": "Alertas de voz",
      "settings_alerts": "Alertas",
      "settings_voice_alerts_desc": "Activa alertas de voz por cada quilómetro",
      "settings_donate": "Doar",
      "settings_dark_mode_item_system": "Sistema",
      "settings_dark_mode_item_light": "Tema claro",
      "settings_dark_mode_item_dark": "Tema escuro"
    }
  };

  static String translate(String tag){
    String systemLocale = Platform.localeName.split('_')[0];
    return _localizations[systemLocale] != null ? _localizations[systemLocale]![tag] ?? tag : _localizations['en']![tag] ?? tag;
  }
}