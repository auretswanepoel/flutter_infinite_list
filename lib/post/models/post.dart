import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/post/models/models.dart';

class Post implements IAppModel<Post> {
  final int id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  List<Object> get props => [id, title, body];

  @override
  String toString() {
    return 'Post {id : $id}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      body: map['body'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  @override
  bool get stringify => true;
}

abstract class IAppModel<T> extends Equatable {
  Map<String, dynamic> toMap();
  String toJson();
  factory IAppModel.fromMap(String source) =>
      IAppModel.fromMap(json.decode(source));
}
