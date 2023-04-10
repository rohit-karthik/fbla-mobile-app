import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "single_event.dart";
import "../classes/event.dart";
import "package:intl/intl.dart";

class PastAndFutureEvents extends StatefulWidget {
  final bool isFuture;

  const PastAndFutureEvents({
    Key? key,
    required this.isFuture,
  }) : super(key: key);

  @override
  State<PastAndFutureEvents> createState() => _PastAndFutureEventsState();
}

class _PastAndFutureEventsState extends State<PastAndFutureEvents> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          db.collection("events").orderBy("date", descending: true).snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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

        return Column(
          children: snapshot.data!.docs.map(
            (DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              if (widget.isFuture &&
                  DateFormat.yMd()
                      .parse(data["date"])
                      .isAfter(DateTime.now())) {
                return SingleEvent(
                  event: Event(
                    name: data["name"],
                    date: data["date"],
                    time: data["time"],
                    desc: data["desc"],
                  ),
                );
              } else if (!widget.isFuture &&
                  DateFormat.yMd()
                      .parse(data["date"])
                      .isBefore(DateTime.now())) {
                return SingleEvent(
                  event: Event(
                    name: data["name"],
                    date: data["date"],
                    time: data["time"],
                    desc: data["desc"],
                  ),
                );
              } else {
                return Container();
              }
            },
          ).toList(),
        );
      },
    );
  }
}
