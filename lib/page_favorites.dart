import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lunch_roulette/models/restaurant.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:http/http.dart' as http;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _AddRowsAsynchronouslyScreenState();
}

class _AddRowsAsynchronouslyScreenState extends State<FavoritesPage> {
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: '아이디',
      field: 'id',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: '이름',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: '득표 수',
      field: 'vote',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '확률',
      field: 'rate',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: '마지막 추첨일',
      field: 'last_draw_date',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: '가격',
      field: 'price',
      type:
          PlutoColumnType.currency(name: "원", symbol: "KRW ", decimalDigits: 0),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.average,
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Average',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' : '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
  ];
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: '가게 정보', fields: [
      'name',
    ]),
    PlutoColumnGroup(title: '상태', fields: ['rate', 'last_draw_date', 'vote']),
  ];
  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    /// Columns must be provided at the beginning of a row synchronously.
    //columns.addAll(DummyData(30, 0).columns);

    fetchRows().then((fetchedRows) {
      /// When there are many rows and the UI freezes when the grid is loaded
      /// Initialize the rows asynchronously through the initializeRowsAsync method
      /// Add rows to stateManager.refRows.
      /// And disable the loading screen.
      PlutoGridStateManager.initializeRowsAsync(
        columns,
        fetchedRows,
      ).then((value) {
        stateManager.refRows.addAll(value);

        /// In this example,
        /// the loading screen is activated in the onLoaded callback when the grid is created.
        /// If the loading screen is not activated
        /// You must update the grid state by calling the stateManager.notifyListeners() method.
        /// Because calling setShowLoading updates the grid state
        /// No need to call stateManager.notifyListeners.
        stateManager.setShowLoading(false);
      });
    });
  }

  Future<List<PlutoRow>> fetchRows() async {
    final List<PlutoRow> rows = [];

    try {
      final response = await http
          .get(Uri.parse('https://lrserver.azurewebsites.net/api/Restaurants'));

      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        List<Restaurant> restaurants =
            list.map((model) => Restaurant.fromJson(model)).toList();

        int sum = 0;
        for (var restaurant in restaurants) {
          sum += restaurant.vote;
        }

        for (var i = 0; i < restaurants.length; i++) {
          rows.add(PlutoRow(cells: {
            'id': PlutoCell(value: i.toString()),
            'name': PlutoCell(value: restaurants[i].name),
            'vote': PlutoCell(value: restaurants[i].vote),
            'rate': PlutoCell(value: '${restaurants[i].vote / sum}%'),
            'last_draw_date': PlutoCell(value: restaurants[i].lastDrawDate),
            'price': PlutoCell(value: restaurants[i].price),
          }));
        }
      }
    } catch (e) {
      debugPrintStack();
      debugPrint(e.toString());
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    //var theme = Theme.of(context);
    //var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setShowLoading(true);
            // appState.stateManager.setShowColumnFilter(true);
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            //print(event);
          },
          onSelected: (event) => {
            //event.row?.setChecked(true)
          },
          configuration: const PlutoGridConfiguration(),
        ),
      ),
    );
  }
}
