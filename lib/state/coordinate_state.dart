import 'package:background_locator/location_dto.dart';
import 'package:equatable/equatable.dart';

abstract class CoordinateState extends Equatable {
  const CoordinateState();

  @override
  List<Object> get props => [];
}

class CoordinateUninitialized extends CoordinateState {}

class CoordinateError extends CoordinateState {}

class CoordinateLoaded extends CoordinateState {
  final LocationDto locationDto;

  const CoordinateLoaded({
    this.locationDto,
  });

  CoordinateLoaded copyWith({
    LocationDto locationDto,
  }) {
    return CoordinateLoaded(
      locationDto: locationDto ?? this.locationDto,
    );
  }

  @override
  List<Object> get props => [locationDto, locationDto];

  @override
  String toString() =>
      'CoordinateLoaded { locationDto: $locationDto }';
}