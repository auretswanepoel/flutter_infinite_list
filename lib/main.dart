import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/network/bloc/network_event.dart';
import 'package:flutter_infinite_list/post/bloc/cache_data_provider.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:flutter_infinite_list/post/post.dart';
import 'package:flutter_infinite_list/widgets/widgets.dart';

import 'network/bloc/network_bloc.dart';
import 'network/bloc/network_state.dart';
import 'shared/shared.dart';

const String CACHED_POSTS_KEY = 'CACHED_POSTS';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory directory =
      await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox(CACHED_POSTS_KEY);

  Bloc.observer = SimpleBlocObserver();

  final HttpPostDataProvider httpDataProvider =
      HttpPostDataProvider(http.Client());
  runApp(MultiRepositoryProvider(providers: [
    RepositoryProvider(create: (context) {
      return PostRepository(
          httpDataProvider, CacheDataProvider<Post>(CACHED_POSTS_KEY));
    })
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Infinite Scroll',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text('Post'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.warning,
                    color: Colors.deepOrange[900],
                    size: 30.0,
                  ),
                ),
              ],
            ),
            body: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => NetworkBloc()..add(ListenConnection()),
                ),
                BlocProvider(
                  create: (context) => PostBloc(
                    RepositoryProvider.of<PostRepository>(context),
                  )..add(PostFetched()),
                ),
              ],
              child: HomePage(),
            )));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = context.read<PostBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      builder: (context, state) {
        return BlocBuilder<PostBloc, PostState>(
            builder: (context, currentState) {
          if (currentState is PostInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState is PostFailure) {
            return Center(
              child: Text('Failed to fetch Posts'),
            );
          }
          if (currentState is PostSuccess) {
            if (currentState.posts.isEmpty) {
              return Center(
                child: Text('no Posts'),
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return index >= currentState.posts.length
                    ? BottomLoader()
                    : PostWidget(post: currentState.posts[index]);
              },
              controller: _scrollController,
              itemCount: currentState.hasReachedMax
                  ? currentState.posts.length
                  : currentState.posts.length - 1,
            );
          }
          return Container();
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(PostFetched());
    }
  }
}
