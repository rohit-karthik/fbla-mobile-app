import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_app_22/global_vars.dart';
import "package:flutter/material.dart";
import "package:calendar_view/calendar_view.dart";

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    void addEvents() {
      db.collection("calendar").get().then(
            (value) => {
              for (var doc in value.docs)
                {
                  if (doc["email"] == email)
                    {
                      CalendarControllerProvider.of(context).controller.add(
                            CalendarEventData(
                              date: DateTime(
                                doc["year"],
                                doc["month"],
                                doc["day"],
                              ),
                              startTime: DateTime(
                                doc["year"],
                                doc["month"],
                                doc["day"],
                                doc["start"],
                                doc["startMin"],
                              ),
                              endTime: DateTime(
                                doc["year"],
                                doc["month"],
                                doc["day"],
                                doc["end"],
                                doc["endMin"],
                              ),
                              title: doc["title"] + "<personal>",
                            ),
                          ),
                    }
                },
            },
          );
    }

    addEvents();

    void addMainEvents() {
      db.collection("events").get().then(
            (value) => {
              for (var doc in value.docs)
                {
                  CalendarControllerProvider.of(context).controller.add(
                        CalendarEventData(
                          date: DateTime(
                            int.parse(doc["date"].split("/")[2]),
                            int.parse(doc["date"].split("/")[0]),
                            int.parse(doc["date"].split("/")[1]),
                          ),
                          startTime: DateTime(
                            int.parse(doc["date"].split("/")[2]),
                            int.parse(doc["date"].split("/")[0]),
                            int.parse(doc["date"].split("/")[1]),
                            doc["time"].split(":")[1].split(" ")[1] == "AM"
                                ? int.parse(doc["time"].split(":")[0]) == 12
                                    ? 0
                                    : int.parse(doc["time"].split(":")[0])
                                : int.parse(doc["time"].split(":")[0]) + 12,
                            int.parse(doc["time"].split(":")[1].split(" ")[0]),
                          ),
                          endTime: DateTime(
                            int.parse(doc["date"].split("/")[2]),
                            int.parse(doc["date"].split("/")[0]),
                            int.parse(doc["date"].split("/")[1]),
                            doc["time"].split(":")[1].split(" ")[1] == "AM"
                                ? int.parse(doc["time"].split(":")[0]) == 12
                                    ? 1
                                    : int.parse(doc["time"].split(":")[0]) + 1
                                : int.parse(doc["time"].split(":")[0]) + 13,
                            int.parse(doc["time"].split(":")[1].split(" ")[0]),
                          ),
                          title: doc["name"] + "<<global>>",
                        ),
                      ),
                },
            },
          );
    }

    addMainEvents();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Calendar"),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                "School Calendar:",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: WeekView(
              heightPerMinute: 1,
              eventTileBuilder: (date, events, boundry, start, end) {
                // Return your widget to display as event tile.
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(events[0]
                              .title
                              .substring(0, events[0].title.length - 10)),
                          content: Text(
                            "${events[0].title.substring(events[0].title.length - 10) == '<personal>' ? "You" : "We"} "
                            "have ${"eaiouEAIOU".contains(events[0].title.toLowerCase()[0]) ? "an" : "a"} "
                            "${events[0].title.substring(0, events[0].title.length - 10).toLowerCase()} "
                            "on ${events[0].date.month}/${events[0].date.day}/${events[0].date.year}.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                              ),
                              child: const Text("CLOSE"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.event_available,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 1),
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

          TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: child!,
                );
              });
          if (time == null) return;

          TimeOfDay? time2 = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: child!,
                );
              });
          if (time2 == null) return;

          TextEditingController textFieldController = TextEditingController();
          String errorText = "Please enter a name for the event.";
          bool error = false;

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
                  title: const Text('Enter an Event Name'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: textFieldController,
                        decoration:
                            const InputDecoration(hintText: "Event Name: "),
                      ),
                      if (error)
                        Text(
                          errorText,
                          style: const TextStyle(color: Colors.red),
                        )
                    ],
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
                        if (textFieldController.text.isEmpty) {
                          setState(() {
                            error = true;
                          });
                        } else {
                          setState(() {
                            error = false;
                          });

                          await db.collection("calendar").add({
                            "title": textFieldController.text,
                            "year": date.year,
                            "month": date.month,
                            "day": date.day,
                            "start": time.hour,
                            "startMin": time.minute,
                            "end": time2.hour,
                            "endMin": time2.minute,
                            "email": email,
                          });

                          if (!mounted) return;
                          Navigator.pop(context);
                        }
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
