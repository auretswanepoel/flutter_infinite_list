import 'dart:convert';

import 'package:flutter_infinite_list/post/models/post.dart';
import 'package:http/http.dart' as http;

class HttpPostDataProvider extends IPostDataProvider {
  final String url = 'jsonplaceholder.typicode.com';
  final http.Client httpClient;

  HttpPostDataProvider(this.httpClient) : assert(httpClient != null);

  Future<List<Post>> readData(int startIndex, int total) async {
    final Uri uri =
        Uri.https(url, '/posts', {'_start': '$startIndex', '_limit': '$total'});
    final response = await httpClient.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
            id: rawPost['id'], title: rawPost['title'], body: rawPost['body']);
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }
}

abstract class IPostDataProvider {
  Future<List<Post>> readData(int startIndex, int total);
}
