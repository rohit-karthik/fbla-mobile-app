import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_app_22/classes/absence.dart';
import "package:flutter/material.dart";
import "package:fbla_app_22/components/single_absence.dart";
import "package:fbla_app_22/global_vars.dart";

const List<String> students = <String>["John", "Mary"];

class StudentAbsencesPage extends StatefulWidget {
  const StudentAbsencesPage({Key? key}) : super(key: key);

  @override
  State<StudentAbsencesPage> createState() => _StudentAbsencesPageState();
}

class _StudentAbsencesPageState extends State<StudentAbsencesPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  String dropdownValue = students.first;

  String convertDateToString(DateTime? date) {
    if (date == null) {
      return "";
    }

    String filler1 = "";
    String filler2 = "";

    String month = date.month.toString();
    String day = date.day.toString();
    String year = date.year.toString();

    if (month.length == 1) {
      filler1 = "0";
    }

    if (day.length == 1) {
      filler2 = "0";
    }

    return "$filler1$month-$filler2$day-$year";
  }

  DateTime getNextWeekday() {
    if (DateTime.now().weekday == DateTime.saturday) {
      return DateTime.now().add(const Duration(days: 2));
    } else if (DateTime.now().weekday == DateTime.sunday) {
      return DateTime.now().add(const Duration(days: 1));
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Absences"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          const Text(
            "Your Absences:",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
          ),
          StreamBuilder(
            stream: db.collection("absences").doc(email).snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text(
                  "Loading",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                );
              }

              Map<String, dynamic> sortedMap = {};

              sortedMap = Map.fromEntries(
                  snapshot.data!.data()!.entries.toList()
                    ..sort((e1, e2) => e1.key.compareTo(e2.key) * -1));

              return ListView(
                shrinkWrap: true,
                children: sortedMap.keys.map(
                  (String i) {
                    if (i == "password" || i == "accountType") {
                      return const SizedBox();
                    }

                    return Column(
                      children: [
                        SingleAbsence(
                          absence: Absence(
                            type: "null",
                            date: i,
                          ),
                          student: dropdownValue,
                          studentEmail: email,
                          editable: false,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(7),
                        ),
                      ],
                    );
                  },
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
