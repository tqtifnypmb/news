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

  void _onStateChanged([String error]) {
    // if (Store.shared.maxItemCount == 0) {
    //   Store.shared.dispatch(Action.loadMaxItem);
    // }

    if (error != null) {
      debugPrint('Store Error: $error');
    } else {
      if (_items.isEmpty) {
        Store.shared.dispatch(Action.loadNextPage, filter: this.filter);
      } else {
        final newItems = Store.shared.getItems(this.filter);
        if (newItems.length != _items.length) {
          setState(() {
            _items = newItems;
          });
        }
      }
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
