import 'package:background_locator/location_dto.dart';
import 'package:equatable/equatable.dart';

abstract class CoordinateEvent extends Equatable {
  const CoordinateEvent();

  @override
  List<Object> get props => [];
}

class CoordinateLoggingStart extends CoordinateEvent {}

class CoordinateLoggingUpdate extends CoordinateEvent {
  final LocationDto locationDto;

  const CoordinateLoggingUpdate(this.locationDto);

  @override
  List<Object> get props => [locationDto];

  @override
  String toString() => 'CoordinateLoggingUpdate { locationDto: $locationDto }';
}

class CoordinateLoggingStop extends CoordinateEvent {}


