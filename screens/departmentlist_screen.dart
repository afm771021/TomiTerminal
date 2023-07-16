import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tomi_terminal_audit2/providers/db_provider.dart';
import 'package:tomi_terminal_audit2/providers/department_list_provider.dart';
import 'package:tomi_terminal_audit2/screens/departmentsearch_screen.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';

import '../widgets/tomiterminal_menu.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {

  /*void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }*/

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {

    final departmentListProvider = Provider.of<DepartmentListProvider>(context, listen: true);
    departmentListProvider.loadDepartments(g_searchDepartment);
    final departmentssections = departmentListProvider.departments;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Departments - Sections'),
          elevation: 10,
          //backgroundColor: Colors.cyan,
        ),
        drawer: const TomiTerminalMenu(),
        body: departmentssections.isNotEmpty ?ListView.builder(
            itemBuilder: (context,index) => Card(
              child:ListTile(
                leading:  const Icon( Icons.sticky_note_2, color: Colors.orange, size: 40,),
                title: Text('Department ${departmentssections[index].departmentId}'),
                subtitle: Text('Section: ${departmentssections[index].sectionId?.round()} - Sku(s): ${departmentssections[index].countSku?.round()}'),
                //textColor: Colors.indigo,
                trailing: const Icon (Icons.download_for_offline,
                  color: Colors.green, size: 40,),
                onTap: () async {
                  final department = departmentssections[index];
                  setState(() {
                    g_departmentNumber = department.departmentId!;
                    final sectionId = department.sectionId;
                    if (sectionId != null) {
                      g_sectionNumber = sectionId.toInt();
                    }
                    print('g_departmentNumber: ${g_departmentNumber}');
                    print('g_sectionNumber:${g_sectionNumber}');
                  });

                  DBProvider.db.downloadDepartmentSectionSkuToAudit();
                  Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails');
                },
              ),
            ),
            itemCount: departmentssections.length)
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
          child: Column(
            children:  [
              const Center(child: Text('No results found',style: TextStyle(fontSize: 24),)),
              ElevatedButton(
                onPressed: (){
                  final route = MaterialPageRoute(builder: (context) => const DepartmentSearchScreen());
                  Navigator.pushReplacement(context, route);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child:  const Text(
                    'Back',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),)
            ],
          ),
        )
    );
  }
}


