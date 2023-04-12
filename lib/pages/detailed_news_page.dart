import 'package:fbla_app_22/data/article_text.dart';
import "package:flutter/material.dart";

class DetailedNews extends StatefulWidget {
  final String title;
  final String image;

  const DetailedNews({Key? key, required this.title, required this.image})
      : super(key: key);

  @override
  State<DetailedNews> createState() => _DetailedNewsState();
}

class _DetailedNewsState extends State<DetailedNews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: ListView(
            children: [
              Image.network(
                widget.image,
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 27.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Text(
                articles[widget.title]!,
                style: const TextStyle(
                  fontSize: 17.5,
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
            ],
          ),
        ),
      ),
    );
  }
}
