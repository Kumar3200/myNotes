import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        loginRoute: (context) {
          return const LoginView();
        },
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const MynotesView(),
      }));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const MynotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

enum MenuItems { logout }

class MynotesView extends StatefulWidget {
  const MynotesView({super.key});

  @override
  State<MynotesView> createState() => _MynotesViewState();
}

class _MynotesViewState extends State<MynotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Ui'),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case MenuItems.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuItems>(
                  value: MenuItems.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('SignOut'),
        content: const Text('Are you sure do you want to Sign out?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            child: const Text('Sign Out'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
