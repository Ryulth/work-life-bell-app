import 'package:background_locator/location_dto.dart';
import 'package:equatable/equatable.dart';

abstract class LocatorState extends Equatable {
  const LocatorState();

  @override
  List<Object> get props => [];
}

class LocatorUninitialized extends LocatorState {}

class LocatorError extends LocatorState {}

class LocatorLoaded extends LocatorState {
  final LocationDto locationDto;

  const LocatorLoaded({
    this.locationDto,
  });

  LocatorLoaded copyWith({
    LocationDto locationDto,
  }) {
    return LocatorLoaded(
      locationDto: locationDto ?? this.locationDto,
    );
  }

  @override
  List<Object> get props => [locationDto, locationDto];

  @override
  String toString() =>
      'LocatorLoaded { locationDto: $locationDto }';
}