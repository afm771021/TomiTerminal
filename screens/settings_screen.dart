
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tomi_terminal_audit2/share_preferences/preferences.dart';
import 'package:tomi_terminal_audit2/widgets/tomiterminal_menu.dart';
import '../providers/db_provider.dart';
import '../util/globalvariables.dart';

class SettingsScreen extends StatefulWidget {

  static const String routerName = 'Settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = false;
  late int maxMFR = 0;
  late int maxDER = 0;
  late int maxALR = 0;
  late int maxERR = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    countMasterFileRecords();
  }

  Future <int?> countMasterFileRecords () async{
    maxMFR = (await DBProvider.db.countMastedFileRecordsRaw())!;
    maxDER = (await DBProvider.db.countDepartmentsRecordsRaw())!;
    maxALR = (await DBProvider.db.countAlertRecordsRaw())!;
    maxERR = (await DBProvider.db.countErrorTypologyRaw())!;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  Scaffold(
      appBar: AppBar (
        title: const Text('Settings'),
      ),
      drawer: const TomiTerminalMenu(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                const Divider(),
                const Text ('Tomi Audit app settings', style: TextStyle(fontSize: 24),),
                Visibility(
                  visible: (g_login)?true:false,
                  child:
                const Divider()),
            Visibility(
              visible: (!g_login)?true:false,
              child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    onChanged: (value){
                      Preferences.servicesURL = value;
                      setState(() {});
                    },
                    autocorrect: false,
                    initialValue: Preferences.servicesURL,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      helperText: 'Tomi services url'
                    ),
                  ),
                )
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                      onPressed:(!isLoading)? (){
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusDirectional.circular(10)),
                                title: const Text('Alert'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Are you sure you want to Clean Database ?'),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      if( isLoading ) return;
                                      isLoading = true;
                                      setState(() {});
                                      await Future.delayed(const Duration(seconds: 1));
                                      DBProvider.db.deleteAllJobDetailAudit();
                                      DBProvider.db.deleteAllJobAudit();
                                      DBProvider.db.deleteAllDepartmentSectionSku();
                                      //DBProvider.db.deleteAllMasterFileAudit();
                                      //DBProvider.db.deleteAllDepartmentAudit();
                                      //DBProvider.db.deleteAllAlertAudit();
                                      isLoading = false;
                                      setState(() {});
                                    },
                                    child: const Text('OK')),
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'))
                              ],
                              );
                            });
                      }:null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          'Clean local database',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      )
                    ),
                ),/*
                Visibility(
                visible: (g_login)?true:false,
                child:const Divider()),
                Visibility(
                  visible: (g_login)?true:false,
                  child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: (!isLoading)?(){
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadiusDirectional.circular(10)),
                                    title: const Text('Alert'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text('Are you sure you want to load an update Masterfile records ?'),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            if( isLoading ) return;
                                            isLoading = true;
                                            setState(() {});
                                            await Future.delayed(const Duration(seconds: 2));
                                            DBProvider.db.downloadMasterFile();
                                            isLoading = false;
                                            setState(() {});
                                          },
                                          child: const Text('OK')),
                                      TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'))
                                    ],
                                  );
                                });
                          }:null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Text(
                              'Load Master File',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )
                      ),
                      const SizedBox(width: 10,),
                       Text('Num. Records: ${maxMFR.toString()}'),
                    ],
                  ),
                )
                ),*/
                const Divider(),
                Visibility(
                    visible: (g_login)?true:false,
                    child:Row(
                      children: [
                        /*Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                              onPressed: (!isLoading)?(){
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadiusDirectional.circular(10)),
                                        title: const Text('Alert'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text('Are you sure you want to load or update Departments ?'),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                if( isLoading ) return;
                                                isLoading = true;
                                                setState(() {});
                                                DBProvider.db.deleteAllDepartmentAudit();
                                                await Future.delayed(const Duration(seconds: 4));
                                                DBProvider.db.downloadDepartments();

                                                isLoading = false;
                                                setState(() {});
                                              },
                                              child: const Text('OK')),
                                          TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'))
                                        ],
                                      );
                                    });
                              }:null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                  'Update Departments',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              )
                          ),
                        ),*/
                        const SizedBox(width: 10,),
                        Text('Departments Records: ${maxDER.toString()}'),
                      ],
                    )
                ),
                const Divider(),
                Visibility(
                    visible: (g_login)?true:false,
                    child:Row(
                      children: [
                        /*Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                              onPressed: (!isLoading)?(){
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadiusDirectional.circular(10)),
                                        title: const Text('Alert'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text('Are you sure you want to load or update Alerts ?'),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                if( isLoading ) return;
                                                isLoading = true;
                                                setState(() {});
                                                DBProvider.db.deleteAllAlertAudit();
                                                await Future.delayed(const Duration(seconds: 4));
                                                DBProvider.db.downloadAlerts();
                                                isLoading = false;
                                                setState(() {});
                                              },
                                              child: const Text('OK')),
                                          TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'))
                                        ],
                                      );
                                    });
                              }:null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Text(
                                  'Update Alerts',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              )
                          ),
                        ),*/
                        const SizedBox(width: 10,),
                        Text('Alerts Records: ${maxALR.toString()}'),
                      ],
                    )
                ),
                const Divider(),
                Visibility(
                    visible: (g_login)?true:false,
                    child:Row(
                      children: [
                        const SizedBox(width: 10,),
                        Text('Error Typologies Records: ${maxERR.toString()}'),
                      ],
                    )
                ),
                // const Divider(),
                // Visibility(
                //     visible: (g_login)?true:false,
                //     child:Row(
                //       children: [
                //         const SizedBox(width: 10,),
                //         Text('LogPath: ${g_logpath}'),
                //       ],
                //     )
                // ),
              ],
            ),
            if ( isLoading )
            Positioned(
                bottom: 40,
                left: size.width * 0.5 - 40,
                child: const _LoadingIcon()
            )
          ],
        ),
      )
    );
  }

}

class _LoadingIcon extends StatelessWidget {
  const _LoadingIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle
      ),
      child: const CircularProgressIndicator(),
    );
  }
}


