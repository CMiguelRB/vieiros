import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/components/vieiros_dialog.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/resources/themes.dart';
import 'package:vieiros/tabs/info.dart';
import 'package:vieiros/tabs/settings.dart';
import '../tabs/map.dart';
import 'package:vieiros/tabs/tracks.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  final LoadedTrack loadedTrack;

  const Home({Key? key, required this.prefs, required this.loadedTrack})
      : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home>
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

  void _onTabItemTapped(int index) async {
    if (index == 1) {
      widget.loadedTrack.clear();
      if (_mapKey.currentState != null) {
        String? path = widget.prefs.getString('currentTrack');
        if (path != null && widget.loadedTrack.path != path) {
          widget.loadedTrack.clear();
          _mapKey.currentState!.loadTrack(path);
          if (_infoKey.currentState != null) {
            _infoKey.currentState!.clearScreen();
          }
        }
        if (path != null && widget.loadedTrack.path == path) {
          _mapKey.currentState!.navigateTrack(path);
        }
        if (_currentTrack.isRecording) {
          _fabIcon = const Icon(Icons.stop);
          if (mounted) {
            setState(() {
              _tabIndex = index;
              _tabController.animateTo(index);
            });
          }
          return;
        }
      } else {
        String? path = widget.prefs.getString('currentTrack');
        if (path != null && widget.loadedTrack.path != path) {
          await widget.loadedTrack.loadTrack(path);
        }
      }
      _fabIcon = const Icon(Icons.play_arrow);
    } else if (index == 2) {
      if (_infoKey.currentState != null) {
        String? path = widget.prefs.getString('currentTrack');
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
    WidgetsBinding.instance!.addObserver(this);
    getOpenedFile();
    _tabs = <Widget>[
      Tracks(
          key: _trackKey,
          prefs: widget.prefs,
          toTabIndex: _onTabItemTapped,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack,
          clearTrack: _clearTrack),
      Map(
          key: _mapKey,
          prefs: widget.prefs,
          setPlayIcon: _setPlayFabIcon,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack),
      Info(
          key: _infoKey,
          currentTrack: _currentTrack,
          prefs: widget.prefs,
          loadedTrack: widget.loadedTrack),
      Settings(prefs: widget.prefs)
    ];
    _tabController = TabController(
        vsync: this, length: _tabs.length, initialIndex: _tabIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
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

  List<BottomNavigationBarItem> _bottomNavigationBarItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.timeline),
        label: I18n.translate('appbar_tab_tracks'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.terrain),
        label: I18n.translate('appbar_tab_map'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.insert_chart_rounded),
        label: I18n.translate('appbar_tab_info'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: I18n.translate('appbar_tab_settings'),
      )
    ];
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (_currentTrack.isRecording) {
      bool? exitResult = await VieirosDialog().infoDialog(
          context,
          'app_close_warning_title',
          {
            'common_cancel': () => Navigator.of(context).pop(false),
            'common_ok': () => Navigator.of(context).pop(true)
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
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _tabs),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _tabIndex <= 1
                ? FloatingActionButton(
                    heroTag: null,
                    child: _fabIcon,
                    onPressed: () => _onFabPressed(_tabIndex, lightMode),
                  )
                : null,
            bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 4.0,
                clipBehavior: Clip.antiAlias,
                child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    items: _bottomNavigationBarItems(),
                    currentIndex: _tabIndex,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    showUnselectedLabels: true,
                    onTap: _onTabItemTapped))));
  }
}
