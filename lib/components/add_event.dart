import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
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
    return FloatingActionButton(
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
                        await db.collection("events").add({
                          "name": textFieldController.text,
                          "date": convertDateToString(date),
                          "time": convertTimeToString(time),
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
    );
  }
}
