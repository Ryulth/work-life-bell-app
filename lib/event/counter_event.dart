import 'package:equatable/equatable.dart';

abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class CounterIncrement extends CounterEvent {
  final int num;

  const CounterIncrement(this.num);

  @override
  List<Object> get props => [num];

  @override
  String toString() => 'Increment { num: $num }';
}

class CounterDecrement extends CounterEvent {
  final int num;

  const CounterDecrement(this.num);

  @override
  List<Object> get props => [num];

  @override
  String toString() => 'Decrement { num: $num }';
}

class CounterClear extends CounterEvent {}

