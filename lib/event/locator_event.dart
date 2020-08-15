import 'package:background_locator/location_dto.dart';
import 'package:equatable/equatable.dart';

abstract class LocatorEvent extends Equatable {
  const LocatorEvent();

  @override
  List<Object> get props => [];
}

class LocatorLoggingStart extends LocatorEvent {}

class LocatorLoggingUpdate extends LocatorEvent {
  final LocationDto locationDto;

  const LocatorLoggingUpdate(this.locationDto);

  @override
  List<Object> get props => [locationDto];

  @override
  String toString() => 'LocatorLoggingUpdate { locationDto: $locationDto }';
}

class LocatorLoggingStop extends LocatorEvent {}


