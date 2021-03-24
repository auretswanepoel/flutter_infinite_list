import 'package:equatable/equatable.dart';

import 'network_state.dart';

abstract class NetworkEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ListenConnection extends NetworkEvent {}

class ConnectionChanged extends NetworkEvent {
  final NetworkState connection;
  ConnectionChanged(this.connection);
}
