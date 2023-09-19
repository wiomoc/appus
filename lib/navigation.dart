import 'package:campus_flutter/courseComponent/views/courses_page.dart';
import 'package:campus_flutter/homeComponent/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:campus_flutter/settingsComponent/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'calendarComponent/views/calendars_page.dart';
import 'placesComponent/views/places_page.dart';
import 'searchComponent/views/search_body_view.dart';
import 'updatesComponent/views/update_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;
  double _searchAreaHeight = 0.0;
  bool _isSearching = false;
  bool showContent = false;

  void _toggleSearch() {
    setState(() {
      //ref.read(searchViewModel).clear();
      showContent = false;
      _isSearching = !_isSearching;
      _searchAreaHeight = _isSearching ? MediaQuery.sizeOf(context).height : 0.0;
    });
  }

  void _closeSearch() {
    setState(() {
      showContent = false;
      _isSearching = false;
      _searchAreaHeight = 0.0;
    });
  }

  @override
  void initState() {
    //ref.read(profileViewModel).fetch(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      final isLandScape = orientation == Orientation.landscape;
      return Scaffold(
          extendBody: true,
          appBar: AppBar(
            centerTitle: true,
            leadingWidth: (kIsWeb && isLandScape) ? 80 : null,
            leading: (kIsWeb && isLandScape)
                ? Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset('assets/images/logos/tum-logo-blue.png', fit: BoxFit.scaleDown))
                : IconButton(
                    onPressed: () => _toggleSearch(),
                    icon: _isSearching ? const Icon(Icons.arrow_back) : const Icon(Icons.search)),
            title: (() {
              switch (currentPageIndex) {
                case 0:
                  if (kIsWeb && isLandScape) {
                    return Text("Home", style: Theme.of(context).textTheme.titleLarge);
                  } else {
                    return Image.asset('assets/images/logos/tum-logo-blue.png', fit: BoxFit.cover, height: 20);
                  }
                case 1:
                  return Text("Updates", style: Theme.of(context).textTheme.titleLarge);
                case 2:
                  return Text(AppLocalizations.of(context)!.courses, style: Theme.of(context).textTheme.titleLarge);
                case 3:
                  return Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).textTheme.titleLarge);
                case 4:
                  return Text(AppLocalizations.of(context)!.places, style: Theme.of(context).textTheme.titleLarge);
                default:
                  return Image.asset('assets/images/logos/tum-logo-blue.png', fit: BoxFit.contain, height: 20);
              }
            }()),
            actions: <Widget>[
              if (kIsWeb && isLandScape) IconButton(onPressed: () => _toggleSearch(), icon: const Icon(Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsView()));
                  },
                  icon: const Icon(Icons.settings)),
            ],
          ), //: null,
          bottomNavigationBar: (kIsWeb && isLandScape) ? null : _bottomNavigationBar(),
          body: Stack(
            children: [
              SafeArea(child: (kIsWeb && isLandScape) ? _webNavigationRail() : _navigationBody()),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _searchAreaHeight,
                child: SafeArea(
                    child: Container(
                  color: Theme.of(context).canvasColor,
                  child: showContent
                      ? SearchView(index: currentPageIndex) //)
                      : Container(),
                )),
                onEnd: () {
                  setState(() {
                    showContent = !showContent;
                  });
                },
              ),
            ],
          ));
    });
  }

  Widget _navigationBody() {
    switch (currentPageIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const UpdatesPage();
      case 2:
        return const CoursesPage();
      case 3:
        return const CalendarsPage();
      case 4:
        return const PlacesPage();
      default:
        return const UpdatesPage();
    }
  }

  Widget _bottomNavigationBar() {
    return DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
            color: CupertinoDynamicColor.withBrightness(
              color: Color(0x4C000000),
              darkColor: Color(0x29000000),
            ),
            width: 0.0,
          )),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            _closeSearch();
            setState(() {
              currentPageIndex = index;
            });
          },

          /// Platform is not supported on web
          height: !kIsWeb
              ? Platform.isIOS
                  ? 49
                  : null
              : null,
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            const NavigationDestination(
              icon: Icon(Icons.house_outlined),
              selectedIcon: Icon(Icons.house),
              label: 'Home',
            ),
            const NavigationDestination(icon: Icon(Icons.feed_outlined), selectedIcon: Icon(Icons.feed), label: 'Updates'),
            NavigationDestination(
              icon: const Icon(Icons.class_outlined),
              selectedIcon: const Icon(Icons.class_),
              label: AppLocalizations.of(context)!.courses,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: AppLocalizations.of(context)!.calendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.place_outlined),
              selectedIcon: const Icon(Icons.place),
              label: AppLocalizations.of(context)!.places,
            ),
          ],
        ));
  }

  Widget _webNavigationRail() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        NavigationRail(
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            _closeSearch();
            setState(() {
              currentPageIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: <NavigationRailDestination>[
            const NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.feed_outlined),
              selectedIcon: Icon(Icons.feed),
              label: Text('Updates'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.class_outlined),
              selectedIcon: const Icon(Icons.class_),
              label: Text(AppLocalizations.of(context)!.courses)
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: Text(AppLocalizations.of(context)!.calendar),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.place_outlined),
              selectedIcon: const Icon(Icons.place),
              label: Text(AppLocalizations.of(context)!.places),
            ),
          ],
        ),
        //const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _navigationBody()),
      ],
    );
  }
}
