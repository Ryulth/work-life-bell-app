import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklifebellapp/bloc/locator_bloc.dart';
import 'package:worklifebellapp/event/locator_event.dart';
import 'package:worklifebellapp/state/locator_state.dart';

class LocatorPage extends StatelessWidget {

  LocatorPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final LocatorBloc locatorBloc = BlocProvider.of<LocatorBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<LocatorBloc, LocatorState>(
        builder: (context, state) {
          if(state is LocatorLoaded) {
            return Center(
              child: Text(
                '${state.locationDto.toString()}',
                style: TextStyle(fontSize: 24.0),
              ),
            );
          } else {
            return Center(
              child: Text(
                '0',
                style: TextStyle(fontSize: 24.0),
              ),
            );
          }

        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.star),
              onPressed: () {
                locatorBloc.add(LocatorLoggingStart());
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () {
                locatorBloc.add(LocatorLoggingStop());
              },
            ),
          )
        ],
      ),
    );
  }
}
