import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:notes_placer/collected_notes_tab.dart';
import 'package:notes_placer/login_tab.dart';

import 'add_note_tab.dart';
import 'map_tab.dart';

class NotesPlacerApp extends StatelessWidget {
  static const maximalDistance = 0.001;

  const NotesPlacerApp({super.key});

  @override
  Widget build(context) {
    // Either Material or Cupertino widgets work in either Material or Cupertino
    // Apps.
    return MaterialApp(
      title: "Notes Placer",
      theme: ThemeData(
        // Use the green theme for Material widgets.
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData.dark(),
      home: const HomePage(title: "Notes Map"),
      supportedLocales: const [
        Locale("en"),
      ],
      localizationsDelegates: const [
        FormBuilderLocalizations.delegate,
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  bool authTabsVisible = true;
  bool logoutVisible = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
        authTabsVisible = user == null;
        logoutVisible = user != null;
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapTab(
      androidDrawer: _AndroidDrawer(user: user, authTabsVisible: authTabsVisible, logoutVisible: logoutVisible),
      maximalDistance: NotesPlacerApp.maximalDistance,
    );
  }
}

class _AndroidDrawer extends StatelessWidget {
  const _AndroidDrawer({required this.user, required this.authTabsVisible, required this.logoutVisible});

  final User? user;
  final bool authTabsVisible;
  final bool logoutVisible;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.search,
                color: Colors.green.shade800,
                size: 96,
              ),
            ),
          ),
          ListTile(
            leading: MapTab.icon,
            title: const Text(MapTab.title),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: AddNoteTab.icon,
            title: const Text(AddNoteTab.title),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(context, MaterialPageRoute(builder: (context) =>
                const AddNoteTab(maximalDistance: NotesPlacerApp.maximalDistance)));
            },
          ),
          Visibility(
            visible: authTabsVisible,
            child: ListTile(
              leading: LoginTab.icon,
              title: const Text(LoginTab.title),
              onTap: () {
                Navigator.pop(context);
                Navigator.push<void>(context, MaterialPageRoute(builder: (context) => const LoginTab()));
              },
            ),
          ),
          Visibility(
            visible: logoutVisible,
            child: ListTile(
              leading: CollectedNotesTab.icon,
              title: const Text(CollectedNotesTab.title),
              onTap: () {
                Navigator.pop(context);
                Navigator.push<void>(context, MaterialPageRoute(builder: (context) => CollectedNotesTab(user: user)));
              },
            ),
          ),
          Visibility(
            visible: logoutVisible,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Divider(),
            ),
          ),
          Visibility(
            visible: logoutVisible,
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Logout"),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              }
            ),
          )
          // Long drawer contents are often segmented.
          // const Padding(
          //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //   child: Divider(),
          // ),
          // ListTile(
          //   leading: MapTab.icon,
          //   title: const Text("Notes map DEBUG"),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push<void>(context, MaterialPageRoute(builder: (context) => const MapTab(maximalDistance: 50)));
          //   },
          // ),
        ],
      ),
    );
  }
}