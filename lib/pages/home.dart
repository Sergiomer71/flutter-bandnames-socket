import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Waiting', votes: 0),
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 1),
    // Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    // Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _andleActiveBands);

    super.initState();
  }

  _andleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    // color: Colors.blue[300],
                    color: Colors.green[300],
                  )
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => _bandTile(bands[i])),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), elevation: 1, onPressed: addNewBand),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      // print('direction: $direction');
      // print('id: ${band.id}');

      //emitir: delete-band
      // { 'id': band.id }

      background: Container(
          padding: EdgeInsets.only(left: 8.0), //(left: 22.0)
          color: Colors.red.shade100, //Colors.red.shade100,
          child: Align(
              alignment: Alignment.centerLeft,
              // child: Text('Delete Band', style: TextStyle(color: Colors.white)),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  SizedBox(width: 20),
                  Text('Delete Band', style: TextStyle(color: Colors.red))
                ],
              ))),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
        // print(band.id);
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      // Android
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name:'),
                content: TextField(
                  controller: textController,
                ),
                actions: <Widget>[
                  MaterialButton(
                      child: Text('Add'),
                      elevation: 5,
                      textColor: Colors.blue,
                      onPressed: () => addBandToList(textController.text))
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band name:'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () => addBandToList(textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context))
              ],
            ));
  }

  void addBandToList(String name) {
    // print(name);

    if (name.length > 1) {
      // Podemos agregar
      // this
      //     .bands
      //     .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      // setState(() {});

      //TAREA
      // emitir: add-band
      // { name: name }
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  // Mostrar Gráfica
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      // Colors.blue[50],
      // Colors.blue[200],
      // Colors.pink[50],
      // Colors.pink[200],
      // Colors.yellow[50],
      // Colors.yellow[200],

      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.pinkAccent,
      Colors.black45,
    ];

    return Container(
        padding: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2.6,
          showChartValuesInPercentage: true,
          showChartValues: true,
          showChartValuesOutside: false,
          chartValueBackgroundColor: Colors.grey[200],
          colorList: colorList,
          showLegends: true,
          decimalPlaces: 0,
          chartType: ChartType.ring,
        ));
  }
}
//
//
//
//-------------------------------------------------------------------
// Widget _showGraph() {
//   Map<String, double> dataMap = Map();
//   List<Color> colorList = [
//     Colors.red,
//     Colors.green,
//     Colors.blue,
//     Colors.yellow,
//   ];

//   dataMap.putIfAbsent("Flutter", () => 5);
//   dataMap.putIfAbsent("React", () => 3);
//   dataMap.putIfAbsent("Xamarin", () => 2);
//   dataMap.putIfAbsent("Ionic", () => 2);

//   return Container(
//       padding: EdgeInsets.only(top: 10),
//       width: double.infinity,
//       height: 200,
//       child: PieChart(
//         dataMap: dataMap,
//         animationDuration: Duration(milliseconds: 800),
//         showChartValuesInPercentage: true,
//         showChartValues: true,
//         showChartValuesOutside: false,
//         chartValueBackgroundColor: Colors.grey[200],
//         colorList: colorList,
//         showLegends: true,
//         decimalPlaces: 0,
//         chartType: ChartType.ring,
//       ));
// }
