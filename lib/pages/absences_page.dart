import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_app_22/classes/absence.dart';
import "package:flutter/material.dart";
import "package:fbla_app_22/components/single_absence.dart";
import "package:fbla_app_22/global_vars.dart";
import 'package:fbla_app_22/classes/absence_or_tardy.dart';

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({Key? key}) : super(key: key);

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  String convertChoiceToString(AbsenceChoice choice) {
    if (choice == AbsenceChoice.absence) {
      return "absent";
    }
    return "tardy";
  }

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

    return "$filler1$month/$filler2$day/$year";
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
            "Your Students' Absences:",
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

              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.data()!.keys.map(
                  (String i) {
                    if (i != "password") {
                      String type = snapshot.data!.data()![i];
                      String date = i;
                      return Column(
                        children: [
                          SingleAbsence(
                            absence: Absence(
                              type: type,
                              date: date,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(7),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: getNextWeekday(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 1),
            selectableDayPredicate: (DateTime date) {
              if (date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday) {
                return false;
              }
              return true;
            },
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date == null) return;

          showDialog(
            context: context,
            builder: (context) {
              AbsenceChoice? choice = AbsenceChoice.absence;
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: AlertDialog(
                  title: const Text('Enter an Event Name'),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Absent'),
                            leading: Radio<AbsenceChoice>(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green[900]!),
                              focusColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green[900]!),
                              value: AbsenceChoice.absence,
                              groupValue: choice,
                              onChanged: (AbsenceChoice? value) {
                                setState(() {
                                  choice = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Tardy'),
                            leading: Radio<AbsenceChoice>(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green[900]!),
                              focusColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.green[900]!),
                              value: AbsenceChoice.tardy,
                              groupValue: choice,
                              onChanged: (AbsenceChoice? value) {
                                setState(() {
                                  choice = value;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () async {
                        await db.collection("absences").doc(email).set({
                          convertDateToString(date):
                              convertChoiceToString(choice!),
                        }, SetOptions(merge: true));

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
