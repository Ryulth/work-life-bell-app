import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklifebellapp/event/counter_event.dart';
import 'package:worklifebellapp/state/counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  @override
  CounterState get initialState => CounterUninitialized();

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    if (event is CounterIncrement) {
      yield* _mapCounterIncrementToState(event);
    } else if (event is CounterDecrement) {
      yield* _mapCounterDecrementToState(event);
    } else {
      yield CounterUninitialized();
    }
  }

  Stream<CounterState> _mapCounterIncrementToState(
      CounterIncrement event) async* {
    if (state is CounterLoaded) {
      final count = (state as CounterLoaded).count;
      final sum = count + event.num;
      yield CounterLoaded(count: sum);
    } else {
      yield CounterLoaded(count: event.num);
    }
  }

  Stream<CounterState> _mapCounterDecrementToState(
      CounterDecrement event) async* {
    if (state is CounterLoaded) {
      final count = (state as CounterLoaded).count;
      final sum = count - event.num;
      yield CounterLoaded(count: sum);
    } else {
      yield CounterLoaded(count: -event.num);
    }
  }
}
