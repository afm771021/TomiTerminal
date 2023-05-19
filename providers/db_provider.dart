
import 'dart:async';
import 'dart:io';
import 'package:tomi_terminal_audit2/models/jobAudit_model.dart';
import 'package:tomi_terminal_audit2/models/jobDetailAudit_model.dart';
import 'package:tomi_terminal_audit2/models/jobGetIndicators_model.dart';
import 'package:tomi_terminal_audit2/models/tag_model.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/jobAlertParameter_model.dart';
import '../models/jobAuditDepartment_model.dart';
import '../models/jobDepartment_model.dart';
import '../models/jobMasterFile_model.dart';
import '../share_preferences/preferences.dart';

class DBProvider{

  static Database? _database;
  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database?>get database async {
    if ( _database != null ) return _database;

    _database = await initDB();

    return _database;
  }

  Future<Database> initDB() async{
   Directory documentsDirectory = await getApplicationDocumentsDirectory();
   final path = join( documentsDirectory.path, 'TomiDB10.db' );
   print ( path );

   return await openDatabase(
     path,
     version: 1,
     onOpen:  (db){},
     onCreate: ( Database db, int version ) async{
      await db.execute('''
                  create table JOB_AUDIT
                  (
                       USERNAME            TEXT,
                       INVENTORYKEY        TEXT,
                       CREATED_AT          DATE,
                       PRIMARY KEY (USERNAME, INVENTORYKEY)
                  );
      ''');
      await db.execute('''
                  create table JOB_DETAILS_AUDIT
                  (
                      CUSTOMER_ID        INTEGER              NOT NULL,
                      STORE_ID           INTEGER              NOT NULL,
                      STOCK_DATE         DATE                 NOT NULL,
                      JOB_DETAILS_ID     INTEGER              NOT NULL,
                      TAG_NUMBER         INTEGER              NOT NULL,
                      TAG_ID             INTEGER,
                      SHELF              TEXT,
                      DESCRIPTION        TEXT,
                      CODE               TEXT,
                      SALE_PRICE         REAL,
                      QUANTITY           REAL,
                      CAPTURED_DATE_TIME DATE,
                      DEPARTMENT_ID      TEXT,
                      NOF                INTEGER,
                      SKU                TEXT,
                      TERMINAL           TEXT,
                      EMP_ID             TEXT,
                      OPERATION          INTEGER DEFAULT 1,
                      AUDIT_STATUS       INTEGER DEFAULT 0,
                      AUDIT_NEW_QUANTITY REAL,
                      AUDIT_ACTION       INTEGER,
                      AUDIT_REASON_CODE  INTEGER,
                      PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, JOB_DETAILS_ID, TAG_NUMBER)
                  );
      ''');

      await db.execute('''
            create table DEPARTMENTS
            (
                InventoryKey         TEXT         NOT NULL,
                depId                TEXT         NOT NULL,
                PRIMARY KEY (InventoryKey, depId)
            );
      ''');

      await db.execute('''
            create table MASTER_FILE
            (
                department       TEXT NOT NULL,
                code             TEXT NOT NULL,
                salePrice        REAL NOT NULL,
                inventoryKey     TEXT NOT NULL,
                description      TEXT NOT NULL,
                PRIMARY KEY (inventoryKey, code)
            );
      ''');

      await db.execute('''
            create table ALERT_PARAMETER
            (
              CUSTOMER_ID        INTEGER              NOT NULL,
              STORE_ID           INTEGER              NOT NULL,
              STOCK_DATE         DATE                 NOT NULL,
              PARAMETER_ID       TEXT                 NOT NULL,
              VALUE              TEXT                 NOT NULL,
              PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, PARAMETER_ID  )
            );
      ''');
     }
   );
  }

  Future<int?> nuevoJobAudit(JobAudit ja) async{
    final db = await database;
    int?  res =  0;

    try{
      res = await db?.insert('JOB_AUDIT', ja.toJson());
      //print (res);
      return res;
    }
    on DatabaseException
    catch( e) {
      //print('JOB_AUDIT already exist.');
    }

  }

  Future<int?> updateJobDetailAudit(jobDetailAudit jda) async {
    final db = await database;
    //print(jda.toJson());

    final res = await db?.update('JOB_DETAILS_AUDIT',
                                jda.toJson(),
                                where : 'CUSTOMER_ID = ? and STORE_ID = ? and STOCK_DATE = ? and JOB_DETAILS_ID = ? and TAG_NUMBER = ?',
                                whereArgs: [jda.customer_Id, jda.store_Id, jda.stock_Date.toString().substring(0,10), jda.job_Details_Id, jda.tag_Number]);
    return res;
  }

  Future<int?> deleteJobDetailAudit(jobDetailAudit jda) async {
    final db = await database;
    //print(jda.toJson());

    final res = await db?.delete('JOB_DETAILS_AUDIT',
        where : 'CUSTOMER_ID = ? and STORE_ID = ? and STOCK_DATE = ? and JOB_DETAILS_ID = ? and TAG_NUMBER = ?',
        whereArgs: [jda.customer_Id, jda.store_Id, jda.stock_Date.toString().substring(0,10), jda.job_Details_Id, jda.tag_Number]);
    return res;
  }

  Future<int?> deleteAllMasterFileAudit() async{
    final db = await database;
    final res = await db?.delete('MASTER_FILE');
    return res;
  }

  Future<int?> deleteAllDepartmentAudit() async{
    final db = await database;
    final res = await db?.delete('DEPARTMENTS');
    return res;
  }

  Future<int?> deleteAllAlertAudit() async{
    final db = await database;
    final res = await db?.delete('ALERT_PARAMETER');
    return res;
  }

  Future<int?> deleteAllJobDetailAudit() async {
    final db = await database;
    final res = await db?.delete('JOB_DETAILS_AUDIT');
    return res;
  }

  Future<int?> deleteAllJobAudit() async {
    final db = await database;
    final res = await db?.delete('JOB_AUDIT');
    return res;
  }

  Future<bool?> existRecordInMasterFile (jobDetailAudit jda) async{
    final db = await database;

    final existInMF = await db?.query(
        'MASTER_FILE', where: 'InventoryKey = ? and code = ?',
        whereArgs: [g_inventorykey, jda.code]);

    if(existInMF != null && existInMF.isNotEmpty)
      {
        JobMasterFile jMF = JobMasterFile.fromJson(existInMF.first);
        jda.department_Id = jMF.department;
        jda.sale_Price = jMF.salePrice;
        jda.description = jMF.description;
        jda.sku = jMF.code;
        return true;
      }

     return false;
  }


  Future<bool?> existDepartment (jobDetailAudit jda) async{
    final db = await database;

    final existInDepartments = await db?.query(
        'DEPARTMENTS', where: 'InventoryKey = ? and depId = ?',
        whereArgs: [g_inventorykey, jda.department_Id]);

    return (existInDepartments != null && existInDepartments.isNotEmpty)?true:false;
  }

  Future<int?> countMastedFileRecordsRaw() async {
    final db = await database;

    final maxRec = await db?.rawQuery('''
            select count(*) from MASTER_FILE where inventoryKey = '${g_inventorykey}'
            ''');
    //print ('maxRecMF: $maxRec');
    return maxRec![0]['count(*)'] as int?;
  }

  Future<int?> countDepartmentsRecordsRaw() async {
    final db = await database;

    final maxRec = await db?.rawQuery('''
            select count(*) from DEPARTMENTS where InventoryKey = '${g_inventorykey}'
            ''');
    return maxRec![0]['count(*)'] as int?;
  }

  Future<int?> countAlertRecordsRaw() async {
    final db = await database;

    final maxRec = await db?.rawQuery('''
            select count(*) from ALERT_PARAMETER where CUSTOMER_ID = '${g_customerId}'
                                                and STORE_ID = '${g_storeId}'
                                                and STOCK_DATE = '${g_stockDate.toString().substring(0,10)}'
            ''');
    return maxRec![0]['count(*)'] as int?;
  }

  Future<int?> nuevoJobDetailAudit(jobDetailAudit jda) async{
    var res = 0;
    int? jobDetailsId  = 0;
    final db = await database;

    if (jda.job_Details_Id == 0){
      final maxId = await db?.query('JOB_DETAILS_AUDIT', columns: ['MAX(JOB_DETAILS_ID)'], where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and tag_number = ? and operation = ?',
          whereArgs: [jda.customer_Id, jda.store_Id, jda.stock_Date.toString().substring(0,10), jda.tag_Number, 1]);

      jobDetailsId = maxId![0]['MAX(JOB_DETAILS_ID)'] as int?;
      jobDetailsId= (jobDetailsId! + 1)!;

      //print (job_details_id);
      jda.job_Details_Id = jobDetailsId.toDouble();
      jda.operation = 1;
    }

    //print('nuevoJobDetailAudit: ${jda.code}');

    try {
       res = (await db?.insert('JOB_DETAILS_AUDIT', jda.toJson()))!;
    } on DatabaseException
    catch(e) {
      //log(e.toString());
      //print('JOB_DETAILS_AUDIT already exist.');
    }

    return res;
  }

  Future<int?> alert_Higher_Quantity () async{
    final db = await database;
    int? result = 0;
    String? value = '0';
    try {
      final res = await db?.query('ALERT_PARAMETER', columns: ['VALUE'],
          where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and parameter_id = ?',
          whereArgs: [
            g_customerId,
            g_storeId,
            g_stockDate.toString().substring(0, 10),
            'ADJ_HIGHER_QUANTITY'
          ]);

      value = res![0]['VALUE'] as String?;
    }
    catch(e){
      //log(e.toString());
    }

    result = int.parse(value!);
    return result;
  }

  Future<int?> alert_Higher_Amount () async{
    final db = await database;
    int? result = 0;
    String? value = '0';
    try {
      final res = await db?.query('ALERT_PARAMETER', columns: ['VALUE'],
          where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and parameter_id = ?',
          whereArgs: [
            g_customerId,
            g_storeId,
            g_stockDate.toString().substring(0, 10),
            'ADJ_HIGHER_AMOUNT'
          ]);

      value = res![0]['VALUE'] as String?;
    }
    catch(e){
      //log(e.toString());
    }

    result = int.parse(value!);
    return result;
  }

  Future<int?> nuevoJobAuditRaw(JobAudit ja) async{
    final db= await database;

    final userName = ja.userName;
    final inventoryKey = ja.inventoryKey;
    final res = await db?.rawInsert('''
          Insert into JOB_AUDIT(
                                USERNAME, 
                                INVENTORYKEY, 
                                CREATED_AT)
          values(               '$userName',
                                '$inventoryKey',
                                DATE())
        ''');

    return res;
  }

  Future<List<TagModel>> getTagsToAudit(String searchTag) async {

      var uri = '${Preferences.servicesURL}/api/Audit/GetTagsToAuditAsync/1/${g_customerId}/${g_storeId}/${g_stockDate}/0/${g_user}/${searchTag}';
      var url = Uri.parse(uri);
      print ('uri: ${uri}');
      var response = await http.get(url);
      final List parsedList = json.decode(response.body);
      List<TagModel> list = parsedList.map((val) => TagModel.fromJson(val)).toList();

      return list;
  }

  Future<List<AuditDepartmentModel>> getDepartmentsToAudit(String searchDepartment) async {
    var uri = '${Preferences.servicesURL}/api/Audit/GetDepartmentsToAuditAsync/${g_customerId}/${g_storeId}/${g_stockDate}/0/${g_user}/${searchDepartment}';
    var url = Uri.parse(uri);
    print ('uri: ${uri}');
    var response = await http.get(url);
    final List parsedList = json.decode(response.body);
    //print ('response.body: ${response.body}');
    List<AuditDepartmentModel> list = parsedList.map((val) => AuditDepartmentModel.fromJson(val)).toList();

    return list;
  }

  Future<JobGetIndicators> getIndicators() async {
    var uri = '${Preferences.servicesURL}/api/Job/GetIndicators/${g_customerId}/${g_storeId}/${g_stockDate}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print ('getIndicators: ${response.body}');
    final jobGetIndicators = jobGetIndicatorsFromJson(response.body);

    return jobGetIndicators;
  }

  Future<List<jobDetailAudit>?> getJobDetailsToAudit(int customerId, int storeId, DateTime stockDate, int tagNumber, int operation) async{
    final db = await database;
    final res = await db?.query('JOB_DETAILS_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and tag_number = ? and operation = ?',
                                                      whereArgs: [customerId, storeId, stockDate.toString().substring(0,10), tagNumber, operation]);
    //print(res);
    return res?.map((s) => jobDetailAudit.fromJson(s)).toList();
  }

  Future <List<JobDepartment>?> getAllDepartments() async{
    final db = await database;
    final res = await db?.query('DEPARTMENTS', where: 'InventoryKey = ?',
                                whereArgs: [g_inventorykey]);

    return res?.map((e) => JobDepartment.fromJson(e)).toList();
  }
/*
DEPARTMENTS
            (
                InventoryKey         TEXT         NOT NULL,
                depId
 */
  Future<void> downloadTagsDetailToAudit() async {
    var uri = '${Preferences.servicesURL}/api/Audit/GetAuditTagList/1/${g_tagNumber}/${g_customerId}/${g_storeId}/${g_stockDate}/${g_user}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print (json.decode(response.body));
    final List parsedList = json.decode(response.body);
    List<jobDetailAudit> list = parsedList.map((e) => jobDetailAudit.fromTomiDBJson(e)).toList();

    for(var i=0;i<list.length;i++){
      nuevoJobDetailAudit(list[i]);
    }
  }

  Future<int> downloadMasterFile() async {
    int pages = 0;
    int totalMasterFileRecords = 0;
    g_countMasterfile = 0;

    try {
      var url = Uri.parse('${Preferences.servicesURL}/api/ProgramTerminal/GetMFAudit');
      var respuesta = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'operation': '1',
            'inventoryKey': g_inventorykey,
            'page': '-1',
            'limit': '0'
          }));

      if (respuesta.statusCode == 200) {
        var loginResponseBody = (jsonDecode(respuesta.body));
          //print(loginResponseBody['pagination']['total']);
          if(double.parse(loginResponseBody['pagination']['total'].toString()) > 0) {
            if (double.parse(loginResponseBody['pagination']['total'].toString()) >= 2000) {
              pages = (double.parse(loginResponseBody['pagination']['total'].toString()).round() / 2000).ceil();
              //print('pages: $pages');
              for(var i=0;i<pages;i++){
                respuesta = await http.post(
                    url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'operation': '1',
                      'inventoryKey': g_inventorykey,
                      'page': i.toString(),
                      'limit': '2000'
                    }));

                if (respuesta.statusCode == 200) {
                  var responseBody = (jsonDecode(respuesta.body));
                  final List parsedList = responseBody['auditsmf'];
                  List<JobMasterFile> list = parsedList.map((e) => JobMasterFile.fromJson(e)).toList();
                  var j = 0;
                  for(j=0;j<list.length;j++){
                   //nuevoMasterFile(list[j]);
                   totalMasterFileRecords += 1;
                   g_countMasterfile += 1;
                  }
                  //print('list.length: ${list.length}');
                }
              } // for pages
            }
            else
              {
                respuesta = await http.post(
                    url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'operation': '1',
                      'inventoryKey': g_inventorykey,
                      'page': '0',
                      'limit': '${(double.parse(loginResponseBody['pagination']['total'].toString()).round().toString())}'
                    }));

                if (respuesta.statusCode == 200) {
                  var ResponseBody = (jsonDecode(respuesta.body));
                  final List parsedList = ResponseBody['auditsmf'];
                  //print ('Lista: ${parsedList}');
                  List<JobMasterFile> list = parsedList.map((e) => JobMasterFile.fromJson(e)).toList();
                  var j = 0;

                  for(j=0;j<list.length;j++){
                    nuevoMasterFile(list[j]);
                    //nuevoMasterFileTransaction(list[j]);
                  }
                }
              }
          }
      }
    }
    on SocketException catch (e) {
      //log(e.toString(), name: 'SocketException');
    } on TimeoutException catch (e) {
      //log(e.toString(), name: 'TimeoutException');
    } on HttpException catch (e) {
      //log(e.toString(), name: 'HttpException');
    } on Exception catch (e) {
      //log(e.toString(), name: 'Exception');
    } catch (e) {
      //print(e.toString());
    }

    return totalMasterFileRecords;
  }

  Future<int> downloadDepartments() async{
    final db = await database;
    await db?.delete('DEPARTMENTS');

    var i = 0;
    var uri = '${Preferences.servicesURL}/api/ProgramTerminal/GetDepartments/${g_inventorykey}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print(json.decode(response.body));
    final List parsedList = json.decode(response.body);
    List<JobDepartment> list = parsedList.map((e) => JobDepartment.fromJson(e)).toList();

    for(i=0;i<list.length;i++){
      nuevoDepartment(list[i]);
    }
    return i;
  }

    Future<int> downloadAlerts() async{
    final db = await database;
    await db?.delete('ALERT_PARAMETER');

    var i = 0;
    var uri = '${Preferences.servicesURL}/api/ProgramTerminal/GetAlerts/${g_inventorykey}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    print(json.decode(response.body));
    final List parsedList = json.decode(response.body);
    List<JobAlertParameter> list = parsedList.map((e) => JobAlertParameter.fromJson(e)).toList();

    for(i=0;i<list.length;i++){
      nuevoAlert(list[i]);
    }
    return i;
  }

  Future<int?> nuevoAlert(JobAlertParameter jda) async{
    int? res = 0;
    final db = await database;
    try {
      res = await db?.insert('ALERT_PARAMETER', jda.toJson());
    } on DatabaseException
    catch(e) {
      //log('ALERT_PARAMETER already exist.${e.toString()}');
    }
    return res;
  }

  Future<int?> nuevoDepartment(JobDepartment jda) async{
    int? res = 0;
    final db = await database;
    try {
      res = await db?.insert('DEPARTMENTS', jda.toJson());
    } on DatabaseException
    catch(e) {
     // log('DEPARTMENTS already exist.${e.toString()}');
    }
    return res;
  }

  Future<int?> nuevoMasterFileTransaction(JobMasterFile jmf) async{
    int? res = 0;
    final db = await database;
    try {
        await db?.transaction((txn) async {
        var batch = txn.batch();
        batch.insert('MASTER_FILE', jmf.toJson());
        await batch.commit();
      });
    }
    catch(e) {
      //print('MasterFile already exist.${e.toString()}');
    }
    return res;
  }

  Future<int?> nuevoMasterFile(JobMasterFile jmf) async{
    int? res = 0;
    final db = await database;
    try {
      res = await db?.insert('MASTER_FILE', jmf.toJson());
    } on DatabaseException
    catch(e) {
      //print('MasterFile already exist.${e.toString()}');
    }
    return res;
  }

/*
  Future<List<JobDepartment>> testFutureBuilderDepartments() async{

    var uri = '${Preferences.servicesURL}/api/ProgramTerminal/GetDepartments/${g_inventorykey}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print(json.decode(response.body));
    final List parsedList = json.decode(response.body);
    List<JobDepartment> list = parsedList.map((e) => JobDepartment.fromJson(e)).toList();

    return list;
  }

  Future<List<JobMasterFile>> testFutureBuilderMasterFile() async {
       List<JobMasterFile> list = [];
      var url = Uri.parse('${Preferences.servicesURL}/api/ProgramTerminal/GetMFAudit');
      var respuesta = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'operation': '1',
            'inventoryKey': g_inventorykey,
            'page': '0',
            'limit': '20000'
          }));

      if (respuesta.statusCode == 200) {
        var responseBody = (jsonDecode(respuesta.body));
        final List parsedList = responseBody['auditsmf'];
        list = parsedList.map((e) => JobMasterFile.fromJson(e)).toList();
        print (list.length);
        g_countMasterfile = list.length;
        return list;
      }
       return list;
  }
*/

}
