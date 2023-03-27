import "package:flutter/material.dart";
import 'package:fbla_app_22/classes/absence.dart';

class SingleAbsence extends StatelessWidget {
  final Absence? absence;

  const SingleAbsence({Key? key, required this.absence}) : super(key: key);

  Color getColor(String absenceType) {
    if (absenceType == "absent") {
      return const Color(0xFFE53935);
    }

    return const Color(0xFFFB8C00);
  }

  Color getTintedColor(String absenceType) {
    if (absenceType == "absent") {
      return const Color.fromARGB(255, 251, 221, 221);
    }

    return const Color.fromARGB(255, 255, 230, 200);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${absence!.date}:",
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
            color: getTintedColor(absence!.type),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              absence!.type[0].toUpperCase() + absence!.type.substring(1),
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: getColor(absence!.type),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
