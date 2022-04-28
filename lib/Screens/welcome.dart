import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Welcome extends StatefulWidget {
  Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

   late EmployeeDataSource employeeDataSource;
  late List<GridColumn> _columns;

  Future<Object>? generateEmployeeList() async {
    // Give your PHP URL. It may be online URL o local host URL.
    // Follow the steps provided in the below KB to configure the mysql using
    // XAMPP and get the local host php link,
    ///
    var url = Uri.parse('http://10.0.2.2:8000/api/auth/show');
    final response = await http.get(url);
    var list = json.decode(response.body);

    // Convert the JSON to List collection.
    List<Employee> _employees =
        await list.map<Employee>((json) => Employee.fromJson(json)).toList();
    employeeDataSource = EmployeeDataSource(_employees);
    return _employees;
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridColumn(
          columnName: 'ID',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'ID',
              ))),
      GridColumn(
          columnName: 'Name',
          width: 80,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('Nom'))),
      GridColumn(
          columnName: 'Email',
          width: 120,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Email',
                overflow: TextOverflow.ellipsis,
              ))),
    ];
  }

   @override
  void initState() {
    super.initState();
    _columns = getColumns();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black54,
          centerTitle: true,
          elevation: 0,
          title: Text('Liste des utilisateurs'),
        ),
        body: FutureBuilder<Object>(
            future: generateEmployeeList(),
            builder: (context, data) {
              return data.hasData
                  ? SfDataGrid(
                      source: employeeDataSource,
                      columns: _columns,
                      columnWidthMode: ColumnWidthMode.fill)
                  : Center(
                      child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: 0.8,
                    ));
            }));
  }
}

class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource(this.employees) {
    buildDataGridRow();
  }

  void buildDataGridRow() {
    _employeeDataGridRows = employees
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'ID', value: e.id),
              DataGridCell<String>(columnName: 'Name', value: e.name),
              DataGridCell<String>(columnName: 'Email', value: e.email),
            ]))
        .toList();
  }

  List<Employee> employees = [];

  List<DataGridRow> _employeeDataGridRows = [];

  @override
  List<DataGridRow> get rows => _employeeDataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  void updateDataGrid() {
    notifyListeners();
  }
}

class Employee {
  int id;
  String name;
  String email;

  Employee({required this.id, required this.name, required this.email});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,);
  }
}