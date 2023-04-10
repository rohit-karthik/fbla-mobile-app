import 'package:fbla_app_22/global_vars.dart';
import "package:flutter/material.dart";
import 'package:fbla_app_22/classes/absence.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SingleAbsence extends StatefulWidget {
  final Absence? absence;
  final String student;
  final String studentEmail;
  final bool editable;

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

  Color getColor(String absenceType) {
    return const Color(0xFFE53935);
  }

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
          (int.parse(widget.absence!.date.substring(6)) >=
                      DateTime.now().year &&
                  int.parse(widget.absence!.date.substring(0, 2)) >=
                      DateTime.now().month &&
                  int.parse(widget.absence!.date.substring(3, 5)) >=
                      DateTime.now().day)
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
                            title: const Text('Confirm your Absence'),
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

                                  db
                                      .collection("absences")
                                      .doc(widget.studentEmail)
                                      .update(
                                    {
                                      widget.absence!.date: FieldValue.delete(),
                                    },
                                  );

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
