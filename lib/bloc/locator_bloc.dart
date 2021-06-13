import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:worklifebell_app/event/locator_event.dart';
import 'package:worklifebell_app/state/locator_state.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  LocatorBloc() : super(null) {
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

  ReceivePort port = ReceivePort();
  static const String _isolateName = 'LocatorIsolate';

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
    BackgroundLocator.registerLocationUpdate(callback,
        disposeCallback: notificationCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 10,
            showsBackgroundLocationIndicator: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 0,
            distanceFilter: 10,
            wakeLockTime: 60,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Work Life Bell',
                notificationMsg: 'Tracking Work Distance',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback: notificationCallback)));
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
