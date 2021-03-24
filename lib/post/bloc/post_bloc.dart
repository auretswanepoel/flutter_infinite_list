import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/network/bloc/network_bloc.dart';
import 'package:flutter_infinite_list/network/bloc/network_state.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_infinite_list/post/bloc/bloc.dart';
import 'package:flutter_infinite_list/post/models/post.dart';

import 'post_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final IPostRepository postRepository;
  bool isOffline = false;
  StreamSubscription networkSubscription;

  PostBloc(this.postRepository) : super(PostInitial()) {
    networkSubscription = NetworkBloc().listen((state) {
      print(state);
      print('Connection State');
      isOffline = state is ConnectionSuccess ? true : false;
    });
  }

  @override
  Stream<Transition<PostEvent, PostState>> transformEvents(
      Stream<PostEvent> events,
      TransitionFunction<PostEvent, PostState> transitionFn) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    final currentState = state;
    if (event is PostFetched && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostInitial) {
          final posts = await _fetchPosts(0, 20);
          yield PostSuccess(posts: posts, hasReachedMax: false);
          return;
        }
        if (currentState is PostSuccess) {
          final posts = await _fetchPosts(currentState.posts.length, 20);
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostSuccess(
                  posts: currentState.posts + posts, hasReachedMax: false);
        }
      } catch (_) {
        yield PostFailure();
      }
    }
  }

  bool _hasReachedMax(PostState currentState) =>
      currentState is PostSuccess && currentState.hasReachedMax;

  Future<List<Post>> _fetchPosts(int startIndex, int total) async {
    return await postRepository.getAllPosts(startIndex, total);
  }

  @override
  Future<void> close() {
    networkSubscription.cancel();
    return super.close();
  }
}
