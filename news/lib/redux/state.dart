
enum ItemType {
  job,
  story,
  comment,
  poll,
  pollopt,
}

enum Filter {
  all,
  news,
  ask,
  shows,
  jobs
}

class Item {
  final int id;
  final String author;
  final String title;
  final String url;

  final int timestamp;
  final String text;
  final int commentCount;  
  int score;
  final ItemType type;

  final Item parent;

  Item({this.id, this.author, this.title, this.url, this.timestamp, this.text, this.commentCount, this.score, this.type, this.parent});

  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json["type"];
    ItemType itemType = ItemType.story;
    switch (type) {
      case "job":
        itemType = ItemType.job;
        break;

      case "story":
        itemType = ItemType.story;
        break;

      case "comment":
        itemType = ItemType.comment;
        break;

      case "poll":
        itemType = ItemType.poll;
        break;

      case "pollopt":
        itemType = ItemType.pollopt;
        break;
    }

    var commentCount = 0;
    if (itemType == ItemType.story || itemType == ItemType.poll) {
      commentCount = json["descendants"];
    }

    return Item(
      id: json["id"],
      author: json["by"],
      title: json["title"],
      url: json["url"],
      timestamp: json["time"],
      text: json["text"],
      commentCount: commentCount,
      score: json["score"],
      type: itemType,
      parent: null
    );
  }
}