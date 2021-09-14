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

      "appbar_tab_tracks": "Tracks",
      "appbar_tab_map": "Map",
      "appbar_tab_info": "Info",
      "appbar_tab_settings": "Settings",

      "tracks_background_tip": "Press + to load a gpx track file",
      "tracks_file_validation_error": "Not a valid gpx file",
      "tracks_unloaded": "Track cleared from the map",

      "map_waypoint": "Waypoint name",
      "map_notification_title": "Recording track...",
      "map_notification_desc": "Vieiros is tracking your position",
      "map_start_recording_message": "Starting a new track!",
      "map_voice_notification_km": "kilometers in",
      "map_voice_notification_h": "hours",
      "map_voice_notification_m": "minutes",
      "map_voice_notification_s": "seconds",
      "map_stop_save": "Stop recording and save your track?",
      "map_track_name": "Track name",

      "info_current_track": "Current track",
      "info_loaded_track": "Loaded track",
      "info_total_time": "Total time",
      "info_total_distance": "Distance",
      "info_daytime": "Daytime",
      "info_daytime_left": "Hours left",
      "info_daytime_sunset": "Sunset",
      "info_pace": "Avg pace",
      "info_elevation": "Elevation",
      "info_elevation_current": "Current",
      "info_elevation_top": "Top",
      "info_elevation_gain": "Gain",
      "info_chart_elevation": "Elevation",
      "info_chart_distance": "Distance",

      "settings_dark_mode": "Dark mode",
      "settings_voice_alerts": "Voice alerts",
      "settings_donate": "Donate"
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

      "appbar_tab_tracks": "Rutas",
      "appbar_tab_map": "Mapa",
      "appbar_tab_info": "Info",
      "appbar_tab_settings": "Configuración",

      "tracks_background_tip": "Presiona + para cargar archivo de ruta gpx",
      "tracks_file_validation_error": "Archivo gpx no válido",
      "tracks_unloaded": "Ruta limpiada del mapa",

      "map_waypoint": "Nombre punto de ruta",
      "map_notification_title": "Grabando ruta...",
      "map_notification_desc": "Vieiros está obteniendo tu ubicación",
      "map_start_recording_message": "Empezando la ruta!",
      "map_voice_notification_km": "kilómetros en",
      "map_voice_notification_h": "horas",
      "map_voice_notification_m": "minutos",
      "map_voice_notification_s": "segundos",
      "map_stop_save": "¿Terminar de grabar y guardar la ruta?",
      "map_track_name": "Nombre de la ruta",

      "info_current_track": "Ruta actual",
      "info_loaded_track": "Ruta cargada",
      "info_total_time": "Tiempo total",
      "info_total_distance": "Distancia",
      "info_daytime": "Horas de luz",
      "info_daytime_left": "Horas restantes",
      "info_daytime_sunset": "Ocaso",
      "info_pace": "Ritmo medio",
      "info_elevation": "Altitud",
      "info_elevation_current": "Actual",
      "info_elevation_top": "Top",
      "info_elevation_gain": "Desnivel acumulado",
      "info_chart_elevation": "Altitud",
      "info_chart_distance": "Distancia",

      "settings_dark_mode": "Modo oscuro",
      "settings_voice_alerts": "Alertas de voz",
      "settings_donate": "Donar"
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

      "appbar_tab_tracks": "Rutas",
      "appbar_tab_map": "Mapa",
      "appbar_tab_info": "Info",
      "appbar_tab_settings": "Configuración",

      "tracks_background_tip": "Presiona + para cargares un arquivo de ruta gpx",
      "tracks_file_validation_error": "Arquivo gpx non válido.",
      "tracks_unloaded": "Ruta limpada do mapa",

      "map_waypoint": "Nome punto de ruta",
      "map_notification_title": "Gravando ruta...",
      "map_notification_desc": "Vieiros está obtendo a túa ubicación",
      "map_start_recording_message": "Comenzado a ruta!",
      "map_voice_notification_km": "quilómetros en",
      "map_voice_notification_h": "horas",
      "map_voice_notification_m": "minutos",
      "map_voice_notification_s": "segundos",
      "map_stop_save": "¿Rematar de gravar e garda-la ruta?",
      "map_track_name": "Nome da ruta",

      "info_total_current_track": "Ruta actual",
      "info_total_loaded_track": "Ruta cargada",
      "info_total_time": "Tempo total",
      "info_total_distance": "Distancia",
      "info_total_daytime": "Horas de luz",
      "info_total_daytime_left": "Horas restantes",
      "info_total_daytime_sunset": "Ocaso",
      "info_total_pace": "Ritmo medio",
      "info_elevation": "Altitude",
      "info_elevation_current": "Actual",
      "info_elevation_top": "Top",
      "info_elevation_gain": "Desnivel acumulado",
      "info_chart_elevation": "Altitude",
      "info_chart_distance": "Distancia",

      "settings_dark_mode": "Modo escuro",
      "settings_voice_alerts": "Alertas de voz",
      "settings_donate": "Doar"
    }
  };

  static String translate(String tag){
    String systemLocale = Platform.localeName.split('_')[0];
    return _localizations[systemLocale] != null ? _localizations[systemLocale]![tag] ?? tag : _localizations['en']![tag] ?? tag;
  }
}