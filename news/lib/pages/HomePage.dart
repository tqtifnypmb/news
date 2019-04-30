import 'package:flutter/material.dart';
import 'ItemPage.dart';
import 'package:news/redux/state.dart';

class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  TabController _tabController;

  final itemPages = [
    ItemPage(filter: Filter.all,),
        
    ItemPage(filter: Filter.news),

    ItemPage(filter: Filter.ask),

    ItemPage(filter: Filter.show),

    ItemPage(filter: Filter.jobs)
  ];

  @override
  void initState() {
    _tabController = TabController(length: itemPages.length, vsync: this);

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News'),
        bottom: _buildTabbar(),
      ),
      body: _buildTabView(),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: itemPages,
    );
  }

  Widget _buildTabbar() {
    return TabBar(
      controller: _tabController,
      tabs: <Widget>[
        Tab(
          text: "All",
        ),

        Tab(
          text: "News",
        ),

        Tab(
          text: "Ask",
        ),

        Tab(
          text: "Show",
        ),

        Tab(
          text: "Jobs",
        )
      ],
    );
  }
}