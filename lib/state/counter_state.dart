import 'package:equatable/equatable.dart';

abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object> get props => [];
}

class CounterUninitialized extends CounterState {}

class CounterError extends CounterState {}

class CounterLoaded extends CounterState {
  final int count;


  const CounterLoaded({
    this.count
  });

  @override
  List<Object> get props => [count];

  @override
  String toString() =>
      'CounterLoaded { count: $count }';
}
