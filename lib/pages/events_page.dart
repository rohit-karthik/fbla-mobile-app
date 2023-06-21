import 'package:fbla_app_22/components/add_event.dart';
import 'package:fbla_app_22/components/past_and_future_events.dart';
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:fbla_app_22/global_vars.dart";

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // This function takes a nullable DateTime object as input and returns an empty string if the input is null,
  // indicating that no date value was provided.
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

  // This function takes in a nullable `TimeOfDay` object as an argument, checks if the passed `time` is
  // `null`, and if so, returns an empty string.
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
  // This is a widget function that builds a page containing a list of events.
  // It includes an app bar with a title, a body section with a list of upcoming and past events,
  // and an optional floating action button (depending on the value of emailType) that allows adding new events.
  // The style and formatting of the events list are defined by a child widget called PastAndFutureEvents.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Events"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        shrinkWrap: true,
        children: const <Widget>[
          Text(
            "Upcoming Events:",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          PastAndFutureEvents(isFuture: true),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Text(
            "Past Events:",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          PastAndFutureEvents(isFuture: false)
        ],
      ),
      floatingActionButton: emailType == "admin" ? const AddEvent() : null,
    );
  }
}
