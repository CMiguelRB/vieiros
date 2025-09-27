import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/tabs/info.dart';
import 'package:vieiros/tabs/settings.dart';
import 'package:vieiros/tabs/map.dart';
import 'package:vieiros/tabs/tracks.dart';
import 'package:vieiros/utils/preferences.dart';

class Home extends StatefulWidget {
  final LoadedTrack loadedTrack;

  const Home({super.key, required this.loadedTrack});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _tabIndex = 0;
  final bool _canPop = false;

  late List<Widget> _tabs;
  late TabController _tabController;
  late final CurrentTrack _currentTrack = CurrentTrack();

  final _mapKey = GlobalKey<MapState>();
  final _trackKey = GlobalKey<TracksState>();
  final _infoKey = GlobalKey<InfoState>();
  final _settingsKey = GlobalKey<SettingsState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTracksFolder();
    _tabs = <Widget>[
      Tracks(
          key: _trackKey,
          toTabIndex: _onTabItemTapped,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack,
          clearTrack: _clearTrack),
      Map(
          key: _mapKey,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack),
      Info(
          key: _infoKey,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack),
      Settings(key: _settingsKey)
    ];
    _tabController = TabController(
        vsync: this, length: _tabs.length, initialIndex: _tabIndex);
  }

  Future<void> _initTracksFolder() async {
    Directory appFolder = await getApplicationDocumentsDirectory();
    Directory tracksFolder = Directory('${appFolder.path}/tracks');
    if (!tracksFolder.existsSync()) {
      tracksFolder.createSync();
      List<FileSystemEntity> files = appFolder.listSync();
      for (int i = 0; i < files.length; i++) {
        if (FileSystemEntity.isFileSync(files[i].path) &&
            files[i].path.endsWith('.gpx')) {
          files[i].rename(
              '${appFolder.path}/tracks/${files[i].path.split('/')[files[i].path.split('/').length - 1]}');
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabItemTapped(int index) async {
    if (_settingsKey.currentState != null &&
        _settingsKey.currentState!.tpOpen) {
      _settingsKey.currentState!.closeThirdParties();
    }
    if (index == 1) {
      widget.loadedTrack.clear();
      if (_mapKey.currentState != null) {
        String? path = Preferences().get('currentTrack');
        if (path != null && widget.loadedTrack.path != path) {
          _mapKey.currentState!.loadTrack(path);
          if (_infoKey.currentState != null) {
            _infoKey.currentState!.clearScreen();
          }
        }
        if (path != null && widget.loadedTrack.path == path) {
          _mapKey.currentState!.navigateCurrentTrack();
        }
        if (_currentTrack.isRecording) {
          _mapKey.currentState!.centerMapView();
          if (mounted) {
            setState(() {
              _tabIndex = index;
              _tabController.animateTo(index);
            });
          }
          return;
        }
      } else {
        String? path = Preferences().get('currentTrack');
        if (path != null && widget.loadedTrack.path != path) {
          await widget.loadedTrack.loadTrack(path);
        }
      }
    } else if (index == 2) {
      if (_infoKey.currentState != null) {
        String? path = Preferences().get('currentTrack');
        if (path != null && _infoKey.currentState!.currentPath != path) {
          widget.loadedTrack.clear();
          _infoKey.currentState!.loadTrack(path);
        }
      }
    }
    if (mounted) {
      setState(() {
        _tabIndex = index;
        _tabController.animateTo(index);
      });
    }
  }

  void _clearTrack() {
    if (_mapKey.currentState != null) {
      _mapKey.currentState!.clearTrack();
    }
    if (_infoKey.currentState != null) {
      _infoKey.currentState!.clearLoaded();
    }
  }

  void _onWillPop(bool didPop, Object? result, BuildContext context) async {
    if (_currentTrack.isRecording) {
      bool? exitResult = await VieirosDialog().infoDialog(
          context,
          'app_close_warning_title',
          {
            'common_ok': () => Navigator.of(context).pop(true),
            'common_cancel': () => Navigator.of(context).pop(false),
          },
          bodyTag: 'app_close_warning');
      if (exitResult ?? false) {
        SystemNavigator.pop();
      }
    } else if (_trackKey.currentState != null) {
      if (await _trackKey.currentState!.navigateUp()) {
        SystemNavigator.pop();
      }
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _canPop,
        onPopInvokedWithResult: (didPop, result) =>
            _onWillPop(didPop, result, context),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _tabs),
            bottomNavigationBar: NavigationBar(
                selectedIndex: _tabIndex,
                onDestinationSelected: _onTabItemTapped,
                destinations: <Widget>[
                  NavigationDestination(
                      icon: const Icon(Icons.timeline_outlined),
                      label: I18n.translate('appbar_tab_tracks')),
                  NavigationDestination(
                      icon: const Icon(Icons.terrain_outlined),
                      selectedIcon: const Icon(Icons.terrain),
                      label: I18n.translate('appbar_tab_map')),
                  NavigationDestination(
                      icon: const Icon(Icons.insert_chart_outlined),
                      selectedIcon: const Icon(Icons.insert_chart),
                      label: I18n.translate('appbar_tab_info')),
                  NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: I18n.translate('appbar_tab_settings'))
                ])));
  }
}
