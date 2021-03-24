import 'package:equatable/equatable.dart';

abstract class NetworkState extends Equatable {
  @override
  List<Object> get props => [];
}

class ConnectionInitial extends NetworkState {}

class ConnectionSuccess extends NetworkState {}

class ConnectionFailure extends NetworkState {}
