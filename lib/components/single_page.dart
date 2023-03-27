import "package:flutter/material.dart";

class SinglePage extends StatelessWidget {
  final String name;
  final IconData? icon;
  final void Function() builder;

  const SinglePage({
    Key? key,
    required this.name,
    required this.icon,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: builder,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).primaryColor,
            ),
            minimumSize: MaterialStateProperty.all(
              const Size(140, 100),
            ),
            shape: MaterialStateProperty.all(
              const StadiumBorder(),
            ),
          ),
          child: SizedBox(
            child: Icon(icon, size: 35),
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        Text(name),
      ],
    );
  }
}
