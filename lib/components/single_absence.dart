import 'package:fbla_app_22/global_vars.dart';
import "package:flutter/material.dart";
import 'package:fbla_app_22/classes/absence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SingleAbsence extends StatefulWidget {
  final Absence? absence;
  final String student;
  final String studentEmail;
  final bool editable;

  // This code defines a widget named "SingleAbsence".
  // It takes in some required parameters like "absence", "student", "studentEmail", and "editable"
  // and a key parameter.
  // The widget extends a base class and overrides its createState method returning an instance of
  // "_SingleAbsenceState".
  const SingleAbsence(
      {Key? key,
      required this.absence,
      required this.student,
      required this.studentEmail,
      required this.editable})
      : super(key: key);

  @override
  State<SingleAbsence> createState() => _SingleAbsenceState();
}

class _SingleAbsenceState extends State<SingleAbsence> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // This function returns a Color object with a specific value of red (0xFFE53935)
  // based on the absenceType parameter passed to it.
  Color getColor(String absenceType) {
    return const Color(0xFFE53935);
  }

  // This function returns a custom tinted color object of type `Color`.
  // The returned color object has a fixed RGBA value of (255, 251, 221, 221),
  // which results in a light pink color.
  Color getTintedColor(String absenceType) {
    return const Color.fromARGB(255, 251, 221, 221);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${widget.absence!.date}:",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
        ),
        Container(
          width: 75,
          height: 30,
          decoration: BoxDecoration(
            color: getTintedColor(widget.absence!.type),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Absent",
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: getColor(widget.absence!.type),
              ),
            ),
          ),
        ),
        if (widget.editable)
          (DateFormat("MM/dd/yyyy")
                  .parse(widget.absence!.date.replaceAll("-", "/"))
                  .isAfter(DateTime.now()))
              ? IconButton(
                  onPressed: () {
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
                            title: const Text('Confirm your Absence Revoke'),
                            content: const Text(
                                "Are you sure you want to revoke this absence?"),
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
                                  // This code will update the absence's date
                                  // to remove this particular student
                                  db.collection("absences").doc(email).update(
                                    {
                                      widget.absence!.date:
                                          FieldValue.arrayRemove(
                                        [
                                          {widget.studentEmail: widget.student}
                                        ],
                                      )
                                    },
                                  );

                                  // Remove the absence for the student from the database
                                  // as well
                                  db
                                      .collection("absences")
                                      .doc(widget.studentEmail)
                                      .update(
                                    {
                                      widget.absence!.date: FieldValue.delete(),
                                    },
                                  );

                                  // Exit the dialog
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
                  icon: const Icon(
                    Icons.cancel,
                  ),
                  color: getColor(widget.absence!.type),
                )
              : const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.cancel,
                  ),
                )
      ],
    );
  }
}
