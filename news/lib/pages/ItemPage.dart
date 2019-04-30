import 'package:flutter/material.dart';
import 'package:news/redux/store.dart';
import 'package:news/redux/actions.dart';

import 'package:news/redux/state.dart';

class ItemPage extends StatefulWidget {

  final Filter filter;

  ItemPage({Key key, this.filter}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemPageState(this.filter);
  }
}

class _ItemPageState extends State<ItemPage> {
  
  final Filter filter;
  List<Item> _items = [];

  _ItemPageState(this.filter) {
    Store.shared.register(listener: this._onStateChanged);
    Store.shared.dispatch(Action.loadMaxItem);
  }

  @override
  void initState() {
    super.initState();
  }

  void _onStateChanged() {
    // network error
    if (Store.shared.maxItemCount == 0) {
      Store.shared.dispatch(Action.loadMaxItem);
    } else if (_items.isEmpty) {
      Store.shared.dispatch(Action.loadNextPage, filter: this.filter);
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {
        return Center(
          child: Text("data"),
        );
      },
    );
  }
  
}
