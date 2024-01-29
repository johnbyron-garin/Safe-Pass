import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_pass/providers/account_provider.dart';
import 'package:safe_pass/providers/admin_addToQuarantine_provider.dart';
import 'package:safe_pass/providers/admin_clear_status_provider.dart';
import 'package:safe_pass/providers/auth_provider.dart';
import 'package:safe_pass/providers/building_log_provider.dart';
import 'package:safe_pass/providers/entry_provider.dart';
import 'package:safe_pass/providers/entry_request_provider.dart';
import 'package:safe_pass/providers/time_provider.dart';

import 'package:safe_pass/screens/access/signup_student.dart';
import 'package:safe_pass/screens/access/welcome.dart';

import 'package:safe_pass/screens/entrance_monitor/scan_screen.dart';
import 'package:safe_pass/screens/entrance_monitor/search_student_log.dart';

import 'package:safe_pass/screens/user/add_entry.dart';
import 'package:safe_pass/screens/user/generate_buildingpass.dart';
import 'package:safe_pass/screens/user/home.dart';
import 'package:safe_pass/screens/user/main_profile_screen.dart';
import 'package:safe_pass/screens/user/student_entryHistory.dart';
import 'package:safe_pass/screens/user/todays_entry.dart';

import 'package:safe_pass/screens/admin/admin_dashboard.dart';
import 'package:safe_pass/screens/admin/admin_cleared_students.dart';
import 'package:safe_pass/screens/admin/admin_pending_requests.dart';
import 'package:safe_pass/screens/admin/admin_student_list.dart';
import 'package:safe_pass/screens/admin/admin_under_quarantine.dart';
import 'package:safe_pass/screens/admin/admin_under_monitoring.dart';

import 'package:safe_pass/styles/color_schemes.g.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ((context) => AuthProvider())),
        ChangeNotifierProvider(create: ((context) => AccountProvider())),
        ChangeNotifierProvider(create: ((context) => EntryProvider())),
        ChangeNotifierProvider(create: ((context) => TimeProvider())),
        ChangeNotifierProvider(create: ((context) => EntryRequestProvider())),
        ChangeNotifierProvider(create: ((context) => BuildingLogProvider())),
        ChangeNotifierProvider(create: ((context) => AddToQuarantineProvider())),
        ChangeNotifierProvider(create: ((context) => ClearStatusProvider())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Project',
      initialRoute: '/', // change this
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          fontFamily: 'Lexend'),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: 'Lexend'),
      routes: {
        '/': (context) => const WelcomePage(),
        '/home': (context) => const Home(),
        '/signup': (context) => const SignupStudent(),
        '/mainprofile': (context) => const MainProfile(),
        '/todays-entry': (context) => const TodaysEntry(),
        '/entry-history': (context) => EntryHistory(),
        '/search-student-log': (context) => SearchStudentLog(),
        '/scan-screen': (context) => ScanScreen(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/student-list': (context) => const StudentList(),
        '/cleared-student-list': (context) => const ClearedStudentList(),
        '/under-monitoring': (context) => UnderMonitoring(),
        '/under-quarantine': (context) => UnderQuarantine(),
        '/pending-requests': (context) => PendingRequests(),
      },
    );
  }
}
