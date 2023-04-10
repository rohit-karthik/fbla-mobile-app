import "package:flutter/material.dart";

class NewsCard extends StatefulWidget {
  const NewsCard({Key? key}) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  @override
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
                  "https://www.fbla-pbl.org/media/2022/05/FBLA_VerticalLogo-1024x792.png",
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
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
                "FBLA Announces New Logo and Font Design",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
