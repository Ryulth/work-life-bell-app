import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:worklifebellapp/event/coordinate_event.dart';
import 'package:worklifebellapp/state/coordinate_state.dart';

class CoordinateBloc extends Bloc<CoordinateEvent, CoordinateState> {
  ReceivePort port = ReceivePort();
  static const String _isolateName = 'LocatorIsolate';

  @override
  CoordinateState get initialState => CoordinateUninitialized();

  @override
  Stream<CoordinateState> mapEventToState(CoordinateEvent event) async* {
    if (event is CoordinateLoggingStart) {
      yield* _mapCoordinateLoggingStartToState(event);
    } else if (event is CoordinateLoggingStop) {
      yield* _mapCoordinateLoggingStopToState(event);
    } else if (event is CoordinateLoggingUpdate) {
      yield* _mapCoordinateLoggingUpdateToState(event);
    }
  }

  CoordinateBloc() {
    if (IsolateNameServer.lookupPortByName(_isolateName) != null) {
      IsolateNameServer.removePortNameMapping(_isolateName);
    }

    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    BackgroundLocator.initialize();

    port.listen(
          (dynamic data) async {
        await updateState(data);
      },
    );
  }

  Future<void> updateState(LocationDto locationDto) async {
    this.add(CoordinateLoggingUpdate(locationDto));
  }


  Stream<CoordinateState> _mapCoordinateLoggingStartToState(
      CoordinateLoggingStart event) async* {
    if (state is! CoordinateLoaded) {
      if (await _checkLocationPermission()) {
        _startLocator();
        yield CoordinateLoaded();
      }
    }
  }

  Stream<CoordinateState> _mapCoordinateLoggingStopToState(
      CoordinateLoggingStop event) async* {
    BackgroundLocator.unRegisterLocationUpdate();
    yield CoordinateUninitialized();

  }

  Stream<CoordinateState> _mapCoordinateLoggingUpdateToState(
      CoordinateLoggingUpdate event) async* {
    if (state is CoordinateLoaded) {
      yield CoordinateLoaded(locationDto: event.locationDto);
    }
  }

  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
    }
    return false;
  }

  void _startLocator() {
    print("start Locator");
    BackgroundLocator.registerLocationUpdate(
      callback,
      androidNotificationCallback: notificationCallback,
      settings: LocationSettings(
          notificationTitle: "Work Life Bell",
          notificationMsg: "Tracking Work Distance",
          wakeLockTime: 20,
          autoStop: false,
          interval: 5),
    );
  }

  static void callback(LocationDto locationDto) async {
    print('location in dart: ${locationDto.toString()}');
    final SendPort send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto);
  }

  static void notificationCallback() {
    print('notificationCallback');
  }
}
