import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_news_app/pages/details.dart';
import 'package:demo_news_app/utils/api_key.dart';
import 'package:demo_news_app/utils/news.dart';
import 'package:demo_news_app/utils/news_source.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final List<NewsSource> _sources = [
    NewsSource('techcrunch', 'TechCrunch'),
    NewsSource('wired', 'Wired'),
    NewsSource('recode', 'Recode'),
    NewsSource('the-hindu', 'The Hindu'),
    NewsSource('cnn', 'CNN'),
    NewsSource('bbc-news', 'BBC News'),
    NewsSource('espn', 'ESPN'),
    NewsSource('polygon', 'Polygon'),
    NewsSource('ign', 'IGN'),
    NewsSource('national-geographic', 'National Geographic')
  ];

  final _months = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  TabController _tabController;

  String _formattedDateTime(DateTime dateTime) {
    return dateTime.day.toString() +
        ' ' +
        _months[dateTime.month] +
        ' ' +
        dateTime.year.toString() +
        ' at ' +
        dateTime.hour.toString().padLeft(2, '0') +
        ':' +
        dateTime.minute.toString().padLeft(2, '0');
  }

  Future<List<News>> _getData(String sourceId) async {
    List<News> _news;
    try {
      var data = await http
          .get(
              'https://newsapi.org/v2/top-headlines?sources=$sourceId&apiKey=$apiKey')
          .timeout(const Duration(seconds: 60));
      var jsonData = await json.decode(data.body);
      _news = List<News>.generate(jsonData['articles'].length,
          (index) => News(jsonData['articles'][index]));
      return _news;
    } on TimeoutException catch (_) {
      print(_);
      return null;
    }
  }

  Widget _newsTile(News news) {
    const _borderRadius = 8.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => Details(news.url, news.title))),
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Column(
            children: [
              ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: news.imageUrl,
                    placeholder: (context, url) => SizedBox(
                        height: 200.0,
                        child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) => SizedBox(
                        height: 200.0,
                        child:
                            Center(child: Text('Error loading image: $error'))),
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_borderRadius),
                      topRight: Radius.circular(_borderRadius))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(news.title,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 22.0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(news.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Text(_formattedDateTime(news.publishedAt),
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 12.0, color: Colors.black54))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsTab(int index) {
    return FutureBuilder(
        future: _getData(_sources[index].id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.data == null) {
                return Center(
                    child: Text('Error Loading Data',
                        style: TextStyle(color: Colors.white)));
              }
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) =>
                    _newsTile(snapshot.data[index]),
              );
            default:
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white)));
          }
        });
  }

  @override
  void initState() {
    _getData(_sources[0].id);
    _tabController = TabController(length: 10, vsync: this, initialIndex: 0);
    _tabController
        .addListener(() => _getData(_sources[_tabController.index].id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 10,
      child: Scaffold(
          backgroundColor: Colors.lightBlue,
          appBar: AppBar(
            title: Text('News App Demo', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.lightBlue,
            bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                    borderSide:
                        const BorderSide(width: 2.0, color: Colors.white),
                    insets: const EdgeInsets.symmetric(horizontal: 4.0)),
                controller: _tabController,
                isScrollable: true,
                onTap: (int index) {
                  _getData(_sources[index].id);
                },
                tabs: List<Tab>.generate(
                    _sources.length,
                    (index) => Tab(
                        child: Text(_sources[index].name,
                            style: TextStyle(color: Colors.white))))),
          ),
          body: TabBarView(
            controller: _tabController,
            children: List<Widget>.generate(
                _sources.length, (index) => _newsTab(index)),
          )),
    );
  }
}
