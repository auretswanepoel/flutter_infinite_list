import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/post/models/post.dart';

enum PostStatus { initial, success, failure }

abstract class PostState extends Equatable {
  final PostStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  const PostState(
      {this.status = PostStatus.initial,
      this.posts = const <Post>[],
      this.hasReachedMax = false});

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostFailure extends PostState {}

class PostSuccess extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  const PostSuccess({this.posts, this.hasReachedMax});

  PostSuccess copyWith({List<Post> posts, bool hasReachedMax}) {
    return PostSuccess(
        posts: posts ?? this.posts,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax);
  }

  @override
  List<Object> get props => [status, posts, hasReachedMax];

  @override
  String toString() =>
      'PostSuccess { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
