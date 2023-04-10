import 'package:calendar_view/calendar_view.dart';
import 'package:fbla_app_22/global_vars.dart';
import 'package:fbla_app_22/pages/absences_page.dart';
import 'package:fbla_app_22/pages/login_screen.dart';
import 'package:fbla_app_22/pages/maps_page.dart';
import 'package:fbla_app_22/pages/news_page.dart';
import 'package:fbla_app_22/pages/students_absences_page.dart';
import 'package:flutter/material.dart';
import "package:fbla_app_22/pages/events_page.dart";
import "package:fbla_app_22/pages/calendar_page.dart";
import "package:fbla_app_22/pages/photos_page.dart";
import "package:fbla_app_22/components/single_page.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            accentColor: Colors.green.shade900,
          ),
          primaryColor: Colors.blue.shade900,
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Image.asset(
            "assets/tstem.jpg",
          ),
          const Padding(padding: EdgeInsets.all(10)),
          Padding(
            padding: const EdgeInsets.all(15),
            child: GridView.count(
              childAspectRatio: 1.25,
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              children: [
                SinglePage(
                  name: "Events",
                  icon: Icons.event_available,
                  builder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventsPage(),
                      ),
                    );
                  },
                ),
                SinglePage(
                  name: "Calendar",
                  icon: Icons.calendar_month,
                  builder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarPage(),
                      ),
                    );
                  },
                ),
                SinglePage(
                  name: "Photos",
                  icon: Icons.photo,
                  builder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhotosPage(),
                      ),
                    );
                  },
                ),
                SinglePage(
                  name: "Absences",
                  icon: Icons.school,
                  builder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => (emailType == "student")
                            ? const StudentAbsencesPage()
                            : const AbsencesPage(),
                      ),
                    );
                  },
                ),
                SinglePage(
                  name: "Bus Routes",
                  icon: Icons.bus_alert,
                  builder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapsPage(),
                      ),
                    );
                  },
                ),
                SinglePage(
                  name: "News",
                  icon: Icons.newspaper,
                  builder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade700,
                      Colors.blue.shade500,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: TextButton(
                  child: const Icon(
                    FontAwesomeIcons.facebook,
                    size: 58,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse(
                        "https://www.facebook.com/LakeWashingtonSchools"));
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.shade600,
                      Colors.orange,
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.purple,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: TextButton(
                  child: const Icon(
                    FontAwesomeIcons.instagram,
                    size: 58,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse(
                        "https://www.instagram.com/lakewashingtonschools/"));
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blue,
                ),
                padding: const EdgeInsets.all(4),
                child: TextButton(
                  child: const Icon(
                    FontAwesomeIcons.twitter,
                    size: 50,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse("https://twitter.com/LakeWashSchools"));
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Container(
                padding:
                    const EdgeInsets.only(left: 2, top: 4, right: 7, bottom: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red.shade600),
                child: TextButton(
                  child: const Icon(
                    FontAwesomeIcons.youtube,
                    size: 50,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    launchUrl(Uri.parse(
                        "https://www.youtube.com/c/LakeWashingtonSchoolDistrict"));
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
