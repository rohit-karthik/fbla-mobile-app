import 'package:fbla_app_22/classes/event.dart';
import 'package:fbla_app_22/components/add_event.dart';
import "package:flutter/material.dart";
import "../components/single_event.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:fbla_app_22/global_vars.dart";

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

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

  String convertTimeToString(TimeOfDay? time) {
    if (time == null) {
      return "";
    }

    String hour = time.hour.toString();
    String minute = time.minute.toString();
    String amPm = "AM";

    if (time.minute < 10) {
      minute = "0$minute";
    }

    if (time.hour > 12) {
      hour = (time.hour - 12).toString();
      amPm = "PM";
    }

    return "$hour:$minute $amPm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Events"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          const Text(
            "Upcoming Events:",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
          ),
          StreamBuilder(
            stream: db.collection("events").snapshots(),
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

              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map(
                  (DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return SingleEvent(
                      event: Event(
                        name: data["name"],
                        date: data["date"],
                        time: data["time"],
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton:
          email == "rohit.karthik@outlook.com" ? AddEvent() : null,
    );
  }
}
