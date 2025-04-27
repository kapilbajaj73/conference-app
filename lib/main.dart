import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:conference_app/screens/login_screen.dart';
import 'package:conference_app/screens/home_screen.dart';
import 'package:conference_app/screens/classroom_screen.dart';
import 'package:conference_app/screens/dashboard_screen.dart';
import 'package:conference_app/services/dynamic_link_service.dart';
import 'package:conference_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _dynamicLinkService.handleDynamicLinks(context);
  }

  @override
  void dispose() {
    _dynamicLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/classroom': (context) => ClassroomScreen(
              classroomId: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/dashboard': (context) => FutureBuilder<bool>(
              future: _authService.isAdmin(_authService.getCurrentUserUid() ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == true) {
                  return DashboardScreen();
                }
                return HomeScreen();
              },
            ),
      },
    );
  }
}