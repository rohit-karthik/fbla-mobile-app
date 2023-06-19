import 'package:fbla_app_22/pages/detailed_news_page.dart';
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class NewsCard extends StatefulWidget {
  final String title;
  final String image;
  final String docName;

  const NewsCard({
    Key? key,
    required this.title,
    required this.image,
    required this.docName,
  }) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  int views = 0;
  // Retrieve views
  void getViews() async {
    var doc = await db.collection("news").doc(widget.docName).get();
    setState(() {
      views = doc.data()!["views"];
    });
  }

  @override
  void initState() {
    getViews();
    super.initState();
  }

  @override
  // This function builds a container that contains an image, a title, and a button.
  // The container has a white background color, with a shadow effect, and rounded corners.
  // The image is constrained to a maximum height and maximum width.
  // The button has an overlay color that changes its transparency when clicked.
  // When the button is clicked, it navigates to another screen passing an image and a title as arguments.
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.2,
                  maxWidth: double.infinity,
                ),
                child: Image.network(
                  widget.image,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            TextButton(
              onPressed: () {
                db.collection("news").doc(widget.docName).update({
                  "views": views + 1,
                });
                setState(() {
                  views++;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedNews(
                      image: widget.image,
                      title: widget.title,
                      views: views,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all(
                  const EdgeInsets.all(0),
                ),
                overlayColor: MaterialStateProperty.all(
                  Colors.blue[900]?.withOpacity(
                    0.2,
                  ),
                ),
              ),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Text(
              "Views: $views",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
