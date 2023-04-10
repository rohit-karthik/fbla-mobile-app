import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_app_22/classes/absence.dart';
import "package:flutter/material.dart";
import "package:fbla_app_22/components/single_absence.dart";
import "package:fbla_app_22/global_vars.dart";

const List<String> students = <String>["John", "Mary"];

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({Key? key}) : super(key: key);

  @override
  State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
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
          Row(
            children: [
              Text("Student: ", style: Theme.of(context).textTheme.titleLarge),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                items: students.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ],
          ),
          Text(
            "$dropdownValue's Absences:",
            style: const TextStyle(
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

                    bool containsPerson = false;
                    String studentEmail = "";
                    for (Map<String, dynamic> j in sortedMap[i]) {
                      if (j.values.contains(dropdownValue)) {
                        containsPerson = true;
                        studentEmail = j.keys.first;
                        break;
                      }
                    }
                    if (containsPerson) {
                      String person = dropdownValue;
                      String date = i;
                      return Column(
                        children: [
                          SingleAbsence(
                            absence: Absence(
                              type: person,
                              date: date,
                            ),
                            student: dropdownValue,
                            studentEmail: studentEmail,
                            editable: true,
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
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: AlertDialog(
                  title: const Text('Confirm your Absence'),
                  content: Text("Are you sure you want to mark this "
                      "date as an absence for $dropdownValue?"),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('CONFIRM'),
                      onPressed: () async {
                        await db.collection("absences").doc(email).set({
                          convertDateToString(date): FieldValue.arrayUnion([
                            {
                              "${dropdownValue.toLowerCase()}@teslastem.com":
                                  dropdownValue
                            }
                          ]),
                        }, SetOptions(merge: true));

                        await db
                            .collection("absences")
                            .doc("${dropdownValue.toLowerCase()}@teslastem.com")
                            .set({convertDateToString(date): "absent"},
                                SetOptions(merge: true));

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
