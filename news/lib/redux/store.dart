import 'package:news/redux/actions.dart';
import 'package:news/redux/state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef void StoreListener();

class Store {

  static Store shared = Store();

  int itemPerPage = 20;
  int maxItemCount = 0;

  List<Function> _listeners = [];

  void register({listener: StoreListener}) {
    // final exist = _listeners.firstWhere( (func){
    //   return func == listener;
    // });

    // if (exist != null) {
    //   return;
    // }

    _listeners.add(listener);
  }

  void unregister({listener: StoreListener}) {
    _listeners.removeWhere( (func) {
      return func == listener;
    });
  }

  void dispatch(Action act, { Filter filter }) {
    switch (act) {
      case Action.loadMaxItem: {
        _loadMaxItemCount();
        break;
      }
      
      case Action.loadNextPage: {
        break;
      }
    }
  }

  List<Item> getItems(Filter filter) {
    return [];
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void _loadMaxItemCount() async {
    if (maxItemCount != 0) {
      _notifyListeners();
      return;
    }

    final resp = await http.get('https://hacker-news.firebaseio.com/v0/maxitem.json');
    if (resp.statusCode == 200) {
      print(json.decode(resp.body));
    } else {

    }
  }
}