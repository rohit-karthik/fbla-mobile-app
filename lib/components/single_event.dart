import "package:flutter/material.dart";
import "../classes/event.dart";

const Map<int, String> intToMonth = {
  1: "Jan",
  2: "Feb",
  3: "Mar",
  4: "Apr",
  5: "May",
  6: "Jun",
  7: "Jul",
  8: "Aug",
  9: "Sep",
  10: "Oct",
  11: "Nov",
  12: "Dec",
};

class SingleEvent extends StatelessWidget {
  final Event? event;

  const SingleEvent({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  // This code snippet shows the definition of a function named "build" which takes a single parameter of the type "BuildContext".
  // This function returns a widget to be displayed on the screen.
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    intToMonth[int.parse(event!.date.split("/")[0])]!
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    int.parse(event!.date.split("/")[1]).toString(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // The `Padding` function applies padding around its child widget to create spacing between the child and its parent widget. The amount and direction of the padding can be specified using the various parameters of the `Padding` function.
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Theme(
                                data: ThemeData(
                                  colorScheme: ColorScheme.light(
                                    primary:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                child: AlertDialog(
                                  title: Text(event!.name),
                                  content: event!.desc != null &&
                                          event!.desc != ""
                                      ? Text(event!.desc!)
                                      : const Text("No description available."),
                                  actions: [
                                    TextButton(
                                      child: const Text(
                                        "CLOSE",
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Text(
                        event!.name,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // The `Padding` function adds specified padding around a widget.
                const Padding(
                  padding: EdgeInsets.all(2.5),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color.fromRGBO(117, 117, 117, 1),
                    ),
                    const Padding(padding: EdgeInsets.all(2.5)),
                    Text(
                      event!.time,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.all(10),
        )
      ],
    );
  }
}
