import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklifebellapp/bloc/coordinate_bloc.dart';
import 'package:worklifebellapp/event/coordinate_event.dart';
import 'package:worklifebellapp/state/coordinate_state.dart';

class CoordinatePage extends StatelessWidget {

  CoordinatePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final CoordinateBloc coordinateBloc = BlocProvider.of<CoordinateBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CoordinateBloc, CoordinateState>(
        builder: (context, state) {
          if(state is CoordinateLoaded) {
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
                coordinateBloc.add(CoordinateLoggingStart());
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () {
                coordinateBloc.add(CoordinateLoggingStop());
              },
            ),
          )
        ],
      ),
    );
  }
}
