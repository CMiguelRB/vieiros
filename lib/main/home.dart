import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/tabs/info.dart';
import 'package:vieiros/tabs/settings.dart';
import 'package:vieiros/tabs/map.dart';
import 'package:vieiros/tabs/tracks.dart';
import 'package:vieiros/utils/preferences.dart';

class Home extends StatefulWidget {
  final LoadedTrack loadedTrack;

  const Home({Key? key, required this.loadedTrack}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const platform = MethodChannel('com.rabocorp.vieiros/opened_file');

  void getOpenedFile() async {
    String? gpxStringFile = await platform.invokeMethod("getOpenedFile");
    if (gpxStringFile == null) return;
    _trackKey.currentState!.openFileFromIntent(gpxStringFile);
  }

  int _tabIndex = 0;
  Icon _fabIcon = const Icon(Icons.add);

  late List<Widget> _tabs;
  late TabController _tabController;
  late final CurrentTrack _currentTrack = CurrentTrack();

  final _mapKey = GlobalKey<MapState>();
  final _trackKey = GlobalKey<TracksState>();
  final _infoKey = GlobalKey<InfoState>();
  final _settingsKey = GlobalKey<SettingsState>();

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
          _fabIcon = const Icon(Icons.stop);
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
      _fabIcon = const Icon(Icons.play_arrow);
    } else if (index == 2) {
      if (_infoKey.currentState != null) {
        String? path = Preferences().get('currentTrack');
        if (path != null && _infoKey.currentState!.currentPath != path) {
          widget.loadedTrack.clear();
          _infoKey.currentState!.loadTrack(path);
        }
      }
    } else {
      _fabIcon = const Icon(Icons.add);
    }
    if (mounted) {
      setState(() {
        _tabIndex = index;
        _tabController.animateTo(index);
      });
    }
  }

  void _setPlayFabIcon() {
    setState(() {
      _fabIcon = const Icon(Icons.play_arrow);
    });
  }

  void _clearTrack() {
    if (_mapKey.currentState != null) {
      _mapKey.currentState!.clearTrack();
    }
    if (_infoKey.currentState != null) {
      _infoKey.currentState!.clearLoaded();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getOpenedFile();
    _tabs = <Widget>[
      Tracks(
          key: _trackKey,
          toTabIndex: _onTabItemTapped,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack,
          clearTrack: _clearTrack),
      Map(
          key: _mapKey,
          setPlayIcon: _setPlayFabIcon,
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  _onFabPressed(index, lightMode) {
    if (index == 0 && _trackKey.currentState != null) {
      _trackKey.currentState!.openFile();
    }
    if (index == 1 && _mapKey.currentState != null) {
      if (!_currentTrack.isRecording) {
        _mapKey.currentState!.startRecording();
        if (mounted) {
          setState(() {
            _fabIcon = const Icon(Icons.stop);
          });
        }
      } else {
        _mapKey.currentState!.stopRecording(lightMode);
      }
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (_currentTrack.isRecording) {
      bool? exitResult = await VieirosDialog().infoDialog(
          context,
          'app_close_warning_title',
          {
            'common_ok': () => Navigator.of(context).pop(true),
            'common_cancel': () => Navigator.of(context).pop(false),
          },
          bodyTag: 'app_close_warning');
      return exitResult ?? false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool lightMode = Provider.of<ThemeProvider>(context).isLightMode;
    return WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _tabs),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: _tabIndex <= 1
                ? FloatingActionButton(
                    heroTag: null,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    onPressed: () => _onFabPressed(_tabIndex, lightMode),
                    child: _fabIcon,
                  )
                : null,
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
