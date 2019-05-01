import 'package:news/redux/actions.dart';
import 'package:news/redux/state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

typedef void StoreListener([String error]);

class Store {

  static Store shared = Store();

  int itemPerPage = 20;
  int maxItemCount = 0;
  Map<Filter, int> _cursors;
  Map<Filter, List<Item>> _contents;
  Map<Filter, List<int>> _storiesList;

  List<Function> _listeners = [];

  Store() {
    _cursors = {};
    _contents = {};
    _storiesList = {};
  }

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
        _loadNextPage(filter: filter);
        break;
      }

      case Action.loadStoriesList: {
        _loadStoreisList(filter: filter);
        break;
      }
    }
  }

  List<Item> getItems(Filter filter) {
    return _contents[filter];
  }

  void _notifyListeners([String error]) {
    for (final listener in _listeners) {
      if (error != null) {
        listener(error);
      } else {
        listener();
      }
    }
  }

  void _loadMaxItemCount() async {
    if (maxItemCount != 0) {
      _notifyListeners();
      return;
    }

    try {
      final resp = await http.get('https://hacker-news.firebaseio.com/v0/maxitem.json?print=pretty').timeout(Duration(seconds: 5));
      if (resp.statusCode == 200) {
        maxItemCount = json.decode(resp.body);
        _notifyListeners();
      } else {
        _notifyListeners(resp.toString());
      }
    } catch (exp) {
      maxItemCount = json.decode('19793625');
      _notifyListeners(exp.toString());
    }
  }

  void _loadNextPage({Filter filter}) {
    final currentPage = _cursors[filter] ?? 0;
    final nextPage = currentPage + 1;
    if (filter == Filter.all) {
      final beg = maxItemCount - itemPerPage * currentPage;
      final end = maxItemCount - itemPerPage * nextPage;

      List<int> itemIDs = [];
      for (var i = beg; i > end; --i) {
        itemIDs.add(i);
      }

      _loadItemList(filter: filter, itemIDs: itemIDs);
    } else {
      final storiesList = _storiesList[filter];
      if (storiesList.isEmpty) {
        return;
      }

      final beg = itemPerPage * currentPage;
      final end = min(itemPerPage * nextPage, storiesList.length);

      if (beg >= storiesList.length) {
        return;
      }
        
      final itemIDs = storiesList.sublist(beg, end);
      _loadItemList(filter: filter, itemIDs: itemIDs);
    }
  }

  Future<http.Response> _loadItem(int itemID) async {
    try {
      final future = http.get('https://hacker-news.firebaseio.com/v0/item/$itemID.json?print=pretty').timeout(Duration(seconds: 10));
      return future;
    } catch (exp) {
      return null;
    }
  }

  void _loadItemList({Filter filter, List<int> itemIDs}) async {
    List<Future<http.Response>> pageFutures = [];
    for (final id in itemIDs) {
      final resp = _loadItem(id);
      if (resp != null) {
        pageFutures.add(resp);
      }
    }

    await Future.wait(pageFutures);
    
    var items = <Item>[];
    var hasError = false;
    for (final future in pageFutures) {
      future.then((resp) {
        if (resp.statusCode != 200) {
          hasError = true;
          return;
        }

        final itemJson = json.decode(resp.body);
        final item = Item.fromJson(itemJson);
        items.add(item);
      }, onError: (error){
        hasError = true;
      });

      if (hasError) {
        break;
      }
    }

    if (hasError) {
      _notifyListeners('load page error');
    } else {
      if (_contents[filter] == null) {
        _contents[filter] = items;      
      } else {
        _contents[filter].addAll(items);
      }

      _cursors[filter] += 1;
    }

    _notifyListeners();
  }

  void _loadStoreisList({Filter filter}) async {
    if (_storiesList[filter] != null && _storiesList[filter].isNotEmpty) {
      return;
    }

    var path = "";
    switch (filter) {
      case Filter.news: {
        path = 'newstories';
        break;
      }

      case Filter.ask: {
        path = 'askstories';
        break;
      }

      case Filter.jobs: {
        path = 'jobstories';
        break;
      }

      case Filter.shows: {
        path = 'showstories';
        break;
      }

      case Filter.all: {
        return;
      }
    }

    final resp = await http.get('https://hacker-news.firebaseio.com/v0/$path.json?print=pretty').timeout(Duration(seconds: 5));
    if (resp.statusCode == 200) {
      try {
        final payload = json.decode(resp.body);
        _storiesList[filter] = payload;
        _notifyListeners();
      } catch (exp) {
        _notifyListeners(exp.toString());
      }
    } else {
      _notifyListeners('load top stories timeout');
    }
  }

}