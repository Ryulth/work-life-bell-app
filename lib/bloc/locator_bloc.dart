import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:worklifebellapp/event/locator_event.dart';
import 'package:worklifebellapp/state/locator_state.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  ReceivePort port = ReceivePort();
  static const String _isolateName = 'LocatorIsolate';

  @override
  LocatorState get initialState => LocatorUninitialized();

  @override
  Stream<LocatorState> mapEventToState(LocatorEvent event) async* {
    if (event is LocatorLoggingStart) {
      yield* _mapLocatorLoggingStartToState(event);
    } else if (event is LocatorLoggingStop) {
      yield* _mapLocatorLoggingStopToState(event);
    } else if (event is LocatorLoggingUpdate) {
      yield* _mapLocatorLoggingUpdateToState(event);
    }
  }

  LocatorBloc() {
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
    this.add(LocatorLoggingUpdate(locationDto));
  }


  Stream<LocatorState> _mapLocatorLoggingStartToState(
      LocatorLoggingStart event) async* {
    if (state is! LocatorLoaded) {
      if (await _checkLocationPermission()) {
        _startLocator();
        yield LocatorLoaded();
      }
    }
  }

  Stream<LocatorState> _mapLocatorLoggingStopToState(
      LocatorLoggingStop event) async* {
    BackgroundLocator.unRegisterLocationUpdate();
    yield LocatorUninitialized();

  }

  Stream<LocatorState> _mapLocatorLoggingUpdateToState(
      LocatorLoggingUpdate event) async* {
    if (state is LocatorLoaded) {
      yield LocatorLoaded(locationDto: event.locationDto);
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
          distanceFilter: 10,
          wakeLockTime: 60, //default
          autoStop: false,
          interval: 10),
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
