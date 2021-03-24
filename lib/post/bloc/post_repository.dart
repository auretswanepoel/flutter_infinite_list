import 'package:flutter_infinite_list/post/bloc/cache_data_provider.dart';
import 'package:flutter_infinite_list/post/bloc/http_data_provider.dart';
import 'package:flutter_infinite_list/post/models/post.dart';

class PostRepository extends IPostRepository {
  final IPostDataProvider dataProvider;
  final CacheDataProvider cacheProvider;

  PostRepository(this.dataProvider, this.cacheProvider)
      : super(dataProvider, cacheProvider);

  Future<List<Post>> getAllPosts(int startIndex, int total) async {
    // Do something with the cache provider here
    final results = await dataProvider.readData(startIndex, total);
    await cacheProvider.cacheEntries(results);
    return results;
  }
}

abstract class IPostRepository {
  IPostDataProvider dataProvider;
  CacheDataProvider cacheProvider;

  IPostRepository(
    this.dataProvider,
    this.cacheProvider,
  ) : assert(dataProvider != null);

  Future<List<Post>> getAllPosts(int startIndex, int total);
}
