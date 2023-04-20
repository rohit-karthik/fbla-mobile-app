import 'package:fbla_app_22/components/news_card.dart';
import "package:flutter/material.dart";

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  // This function builds a screen that displays Club News using a Scaffold widget for the overall structure.
  // It has an AppBar with a title "Club News".
  // The body of the screen is a ListView with three NewsCard widgets containing news titles and images.
  // The text and images are hardcoded into the widget.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Club News"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: const [
            Text(
              "Club News",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(padding: EdgeInsets.all(5)),
            NewsCard(
              image:
                  "https://www.fbla-pbl.org/media/2022/05/FBLA_VerticalLogo-1024x792.png",
              title: "FBLA Relocates Headquarters to Reston, Virginia",
            ),
            Padding(padding: EdgeInsets.all(5)),
            NewsCard(
              image:
                  "https://s3-us-west-2.amazonaws.com/sportshub2-uploads-prod/files/sites/2837/2020/11/20160555/marysvillegetchell_logo_outline.png",
              title:
                  "March Washington FBLA Chapter of the Month - Marysville-Getchell HS",
            ),
            Padding(padding: EdgeInsets.all(5)),
            NewsCard(
              image:
                  "https://www.travelandleisure.com/thmb/3NRm4q9Qg2bdUqXvenPBVeIloV4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/atlanta-skyline-TODOATL0122-195afa04632e43f5be27ef2dcc94ca3b.jpg",
              title: "Start Planning Your Trip to FBLA NLC in Atlanta!",
            ),
            Padding(padding: EdgeInsets.all(5)),
          ],
        ),
      ),
    );
  }
}
