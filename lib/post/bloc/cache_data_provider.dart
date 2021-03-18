import 'dart:convert';

import 'package:flutter_infinite_list/post/models/post.dart';
import 'package:hive/hive.dart';

class CacheDataProvider<T extends IAppModel> {
  Box box;
  final String cacheKey;
  CacheDataProvider(this.cacheKey) : assert(cacheKey != null) {
    box = Hive.box(cacheKey);
  }

  Future<void> cacheEntries(List<T> entries) async {
    return await box.put(
        cacheKey, json.encode(entries.map((e) => e.toJson()).toList()));
  }

  List<T> getCachedEntries() {
    final postEntries = box.get(cacheKey);
    if (postEntries == null) {
      throw Exception('Cache not init');
    }
    return json.decode(postEntries).map<T>((e) => e.fromJson(e)).toList();
  }
}
