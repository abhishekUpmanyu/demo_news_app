import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Details extends StatefulWidget {
  final String url;
  final String title;

  const Details(this.url, this.title, {Key key}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  String _title = 'Loading...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title, style: TextStyle(color: Colors.white)),
            Text(widget.url, style: TextStyle(color: Colors.white, fontSize: 12.0),)
          ],
        ),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (string) => setState(() {
          _title = widget.title;
        }),
      ),
    );
  }
}
