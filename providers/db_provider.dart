
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
import '../models/jobAuditSkuVariationDept_model.dart';
import '../models/jobDepartment_model.dart';
import '../models/jobErrorTypology_model.dart';
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
   final path = join( documentsDirectory.path, 'TomiDB21.db' );
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
                  create table IM_AUDIT
                  (
                       USERID              INTEGER,
                       PASSWORD            TEXT,
                       INVENTORYKEY        TEXT,
                       CREATED_AT          DATE,
                       PRIMARY KEY (USERID)
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
                      SENT               INTEGER DEFAULT 0,
                      SOURCE_ACTION      INTEGER DEFAULT 0,
                      PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, JOB_DETAILS_ID, TAG_NUMBER)
                  );
      ''');
      await db.execute('''
            create table DEPARTMENTS
            (
                InventoryKey          TEXT         NOT NULL,
                depId                 TEXT         NOT NULL,
                Start_Audit_Date_Time TEXT,
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
      await db.execute('''
                  create table ERROR_TYPOLOGY
                  (
                    CUSTOMER_ID        INTEGER              NOT NULL,
                    STORE_ID           INTEGER              NOT NULL,
                    STOCK_DATE         DATE                 NOT NULL,
                    ERROR_ID           INTEGER              NOT NULL,
                    DESCRIPTION        TEXT,
                    IS_PROCESS_ERROR   INTEGER,
                    IS_ELIGIBLE        INTEGER,
                    PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, ERROR_ID)
                  );
      ''');
      await db.execute('''
            create table SKU_VARIATION_DEPT_AUDIT
            (
                CUSTOMER_ID        INTEGER              NOT NULL,
                STORE_ID           INTEGER              NOT NULL,
                STOCK_DATE         DATE                 NOT NULL,
                DEPARTMENT_ID      TEXT                 NOT NULL,
                SECTION_ID         INTEGER              NOT NULL,
                VALDEP             INTEGER,
                DEPARTMENT         TEXT,
                SKU                TEXT,
                DESCRIPTION        TEXT,
                TEORICO            INTEGER,
                CONTADO            INTEGER,
                DIF                INTEGER,
                SALE_PRICE         REAL,
                CODE               TEXT,
                TAG                TEXT,
                PZAS               INTEGER,
                VALUACION          REAL,
                REC                INTEGER,
                AUDIT_USER         TEXT,
                AUDIT_STATUS       INTEGER DEFAULT 0,
                AUDIT_NEW_QUANTITY REAL,
                AUDIT_ACTION       INTEGER,
                AUDIT_REASON_CODE  INTEGER,
                SENT               INTEGER DEFAULT 0,
                CAPTURED_DATE_TIME TEXT,
                TERMINAL           TEXT,
                PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, DEPARTMENT_ID, SECTION_ID, REC, CODE, CAPTURED_DATE_TIME)
            );
      ''');
     }
   );
  }
   // PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, DEPARTMENT_ID, SECTION_ID, REC, CODE)

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

  Future<int?> updateJobSkuVariationDeptAudit(jobAuditSkuVariationDept jds) async {
    final db = await database;
    //print('updateJobSkuVariationDeptAudit: ${jds.toJson()}');
  //CUSTOMER_ID, STORE_ID, STOCK_DATE, DEPARTMENT_ID, SECTION_ID, REC, CODE
    final res = await db?.update('SKU_VARIATION_DEPT_AUDIT',
        jds.toJson(),
        where : 'CUSTOMER_ID = ? and STORE_ID = ? and STOCK_DATE = ? and DEPARTMENT_ID = ? and SECTION_ID = ? and REC = ? and CODE = ? and CAPTURED_DATE_TIME = ?',
        whereArgs: [jds.customer_Id, jds.store_Id, jds.stock_Date.toString().substring(0,10), jds.department_Id, jds.section_Id, jds.rec, jds.code, jds.captured_Date_Time]);
    return res;
  }

  Future<int?> deleteJobSkuVariationDeptAudit(jobAuditSkuVariationDept jds) async {
    final db = await database;
    //print(jda.toJson());

    final res = await db?.delete('SKU_VARIATION_DEPT_AUDIT',
        where : 'CUSTOMER_ID = ? and STORE_ID = ? and STOCK_DATE = ? and DEPARTMENT_ID = ? and SECTION_ID = ? and REC = ? and CODE = ? and CAPTURED_DATE_TIME = ?',
        whereArgs: [jds.customer_Id, jds.store_Id, jds.stock_Date.toString().substring(0,10), jds.department_Id, jds.section_Id, jds.rec, jds.code, jds.captured_Date_Time]);
    return res;
  }

  Future<int?> updateJobDetailAudit(jobDetailAudit jda) async {
    final db = await database;
    int? res = 0;
    //print('updateJobDetailAudit:');
    //print(jda.toJson());
    try {
      res = await db?.update('JOB_DETAILS_AUDIT',
          jda.toJson(),
          where : 'CUSTOMER_ID = ? and STORE_ID = ? and STOCK_DATE = ? and JOB_DETAILS_ID = ? and TAG_NUMBER = ?',
          whereArgs: [jda.customer_Id, jda.store_Id, jda.stock_Date.toString().substring(0,10), jda.job_Details_Id, jda.tag_Number]);

    } on DatabaseException
    catch(e) {
      //print(e);
    }

    return res;
  }

  Future<int?> deleteJobDetailAudit(jobDetailAudit jda) async {
    final db = await database;
    ////print(jda.toJson());

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

  Future<int?> deleteAllDepartmentSectionSku() async {
    final db = await database;
    final res = await db?.delete('SKU_VARIATION_DEPT_AUDIT');
    //print('SKU_VARIATION_DEPT_AUDIT: $res');
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

  Future<int?> countErrorTypologyRaw() async {
    final db = await database;

    final maxRec = await db?.rawQuery('''
            select count(*) from ERROR_TYPOLOGY where CUSTOMER_ID = '${g_customerId}'
                                                and STORE_ID = '${g_storeId}'
                                                and STOCK_DATE = '${g_stockDate.toString().substring(0,10)}'
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

  Future<int?> nuevoJobAuditSkuVariationDept(jobAuditSkuVariationDept jda) async{
    var res = 0;
    int? jobSkuVariationRec  = 0;
    final db = await database;

    /*if (jda.rec == 0){
      final maxId = await db?.query('SKU_VARIATION_DEPT_AUDIT', columns: ['MAX(rec)'], where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and department_Id = ? and section_Id = ?',
          whereArgs: [jda.customer_Id, jda.store_Id, jda.stock_Date.toString().substring(0,10), jda.department_Id, jda.section_Id]);

      jobSkuVariationRec = maxId![0]['MAX(rec)'] as int?;
      jobSkuVariationRec= (jobSkuVariationRec! + 1)!;

      print ('maxId: ${jobSkuVariationRec}');
      jda.rec = jobSkuVariationRec.toDouble();
    }*/

    try {
      res = (await db?.insert('SKU_VARIATION_DEPT_AUDIT', jda.toJson()))!;
      //print('nuevoJobAuditSkuVariationDept: REC: ${jda.rec} sent:${jda.sent}');

    } on DatabaseException
    catch(e) {
      //print('updateJobSkuVariationDeptAudit: REC: ${jda.rec} sent:${jda.sent}');
      if (jda.sent == 1) {
        //print('SKU_VARIATION_DEPT_AUDIT update exist: ${jda.rec}');
        updateJobSkuVariationDeptAudit(jda);
      }
    }

    return res;
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
      if (g_auditType == 2) {
        updateJobDetailAudit(jda);
      }
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

  /* Obtiene los tags de tomi, para ser procesados */
  Future<List<TagModel>> getTagsToAudit(String searchTag) async {

      var uri = '${Preferences.servicesURL}/api/Audit/GetTagsToAuditAsync/1/${g_customerId}/${g_storeId}/${g_stockDate}/0/${g_user}/${searchTag}';
      var url = Uri.parse(uri);
      //print ('uri: ${uri}');
      var response = await http.get(url);
      final List parsedList = json.decode(response.body);
      List<TagModel> list = parsedList.map((val) => TagModel.fromJson(val)).toList();

      return list;
  }

  Future<List<AuditDepartmentModel>> getDepartmentsToAudit(String searchDepartment) async {
    var uri = '${Preferences.servicesURL}/api/Audit/GetDepartmentsToAuditAsync/${g_customerId}/${g_storeId}/${g_stockDate}/0/${g_user}/${searchDepartment}';
    var url = Uri.parse(uri);
    //print ('uri: ${uri}');
    var response = await http.get(url);
    final List parsedList = json.decode(response.body);
    //print ('response.body: ${response.body}');
    List<AuditDepartmentModel> list = parsedList.map((val) => AuditDepartmentModel.fromJson(val)).toList();

    return list;
  }


  Future<List<jobAuditSkuVariationDept>?> getAuditorSkuVariationDeptAuditedandPendingtosend() async{
    final db = await database;
    final orderBy = 'ABS(VALUACION) DESC, SKU, TAG, REC';
    final res = await db?.query('SKU_VARIATION_DEPT_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and department_id = ? and section_id = ? and audit_action > ? and sent = ? and audit_action != ?',
      whereArgs: [g_customerId, g_storeId, g_stockDate.toString().substring(0,10),g_departmentNumber,g_sectionNumber,0,0,3],
      orderBy: orderBy,
    );
    ////print('getAuditorSkuVariationDeptAuditedandPendingtosend:${res}');
    return res?.map((s) => jobAuditSkuVariationDept.fromJson(s)).toList();
  }

  Future<List<jobAuditSkuVariationDept>?> getAuditorSkuVariationDeptAuditedandNewPendingtosend() async{
    final db = await database;
    final orderBy = 'ABS(VALUACION) DESC, SKU, TAG, REC';
    final res = await db?.query('SKU_VARIATION_DEPT_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and department_id = ? and section_id = ? and audit_action = ? and sent = ?',
      whereArgs: [g_customerId, g_storeId, g_stockDate.toString().substring(0,10),g_departmentNumber,g_sectionNumber,3,0],
      orderBy: orderBy,
    );
    //print('getAuditorSkuVariationDeptAuditedandNewPendingtosend:${res}');
    return res?.map((s) => jobAuditSkuVariationDept.fromJson(s)).toList();
  }

  Future<List<jobAuditSkuVariationDept>?> getAuditorSkuVariationDeptToAudit(int customerId, int storeId, DateTime stockDate) async{
    final db = await database;
    final orderBy = 'ABS(VALUACION) DESC, SKU, TAG, REC';
    final res = await db?.query('SKU_VARIATION_DEPT_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and department_id = ? and section_id = ?',
      whereArgs: [customerId, storeId, stockDate.toString().substring(0,10)],
      orderBy: orderBy,
    );
     //print('getJobAuditSkuVariationDeptToAudit:${res}');
    return res?.map((s) => jobAuditSkuVariationDept.fromJson(s)).toList();
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

  Future<List<jobDetailAudit>?> getAuditorJobDetailsAudit(int customerId, int storeId, DateTime stockDate) async{
    final db = await database;
    final res = await db?.query('JOB_DETAILS_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ?', // and  Audit_action < 7
        whereArgs: [customerId, storeId, stockDate.toString().substring(0,10)]);
    //print(res);
    return res?.map((s) => jobDetailAudit.fromJson(s)).toList();
  }

  Future<List<jobAuditSkuVariationDept>?> getJobAuditSkuVariationDeptToAudit(int customerId, int storeId, DateTime stockDate, String department_id, int section_id) async{
    final db = await database;
    final orderBy = 'ABS(VALUACION) DESC, SKU, TAG, REC';
    final res = await db?.query('SKU_VARIATION_DEPT_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and department_id = ? and section_id = ?',
        whereArgs: [customerId, storeId, stockDate.toString().substring(0,10), department_id, section_id],
        orderBy: orderBy,
      );
    //print('getJobAuditSkuVariationDeptToAudit:${res}');
    return res?.map((s) => jobAuditSkuVariationDept.fromJson(s)).toList();
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

  Future<void> downloadOneDepartmentSectionSkuToAudit(double rec) async {
    //GetAuditDepartmentSectionSkuListAsync(int sectionId, string departmentId, int customerId,
    //             int storeId, DateTime stockDate, string user)
    var uri = '${Preferences.servicesURL}/api/Audit/GetOneAuditDepartmentSectionSkuList/${g_sectionNumber}/${g_departmentNumber}/${g_customerId}/${g_storeId}/${g_stockDate}/${rec.round()}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print ('downloadOneDepartmentSectionSkuToAudit: ${json.decode(response.body)}');
    final List parsedList = json.decode(response.body);
    List<jobAuditSkuVariationDept> list = parsedList.map((e) => jobAuditSkuVariationDept.fromTOMIDBJson(e)).toList();

    for(var i=0;i<list.length;i++){
      nuevoJobAuditSkuVariationDept(list[i]);
      //print('Lista: ${i}');
      //print('Lista: $list[i]');
    }
  }

  Future<double?> downloadOneDepartmentSectionSkuToAudit_CancelAuditor(double rec) async {
    //GetAuditDepartmentSectionSkuListAsync(int sectionId, string departmentId, int customerId,
    //             int storeId, DateTime stockDate, string user)
    var uri = '${Preferences.servicesURL}/api/Audit/GetOneAuditDepartmentSectionSkuList/${g_sectionNumber}/${g_departmentNumber}/${g_customerId}/${g_storeId}/${g_stockDate}/${rec.round()}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print ('downloadOneDepartmentSectionSkuToAudit_CancelAuditor: ${json.decode(response.body)}');
    final List parsedList = json.decode(response.body);
    List<jobAuditSkuVariationDept> list = parsedList.map((e) => jobAuditSkuVariationDept.fromTOMIDBJson(e)).toList();

    for(var i=0;i<list.length;i++){
      UpdateJobAuditSkuVariationDept_CancelAuditor(list[i]);
      return list[i].audit_Status;
    }

    return 0.0;
  }

  Future<int?> UpdateJobAuditSkuVariationDept_CancelAuditor(jobAuditSkuVariationDept jda) async{
    var res = 0;
    final db = await database;

    //print('UpdateJobAuditSkuVariationDept_CancelAuditor: REC: ${jda.rec}');

    try {
        updateJobSkuVariationDeptAudit(jda);
    } on DatabaseException
    catch(e) {
      //log(e.toString());
    }

    return res;
  }

  Future<String> downloadDepartmentSectionSkuToAudit() async {

    var uri = '${Preferences.servicesURL}/api/Audit/GetAuditDepartmentSectionSkuList/${g_sectionNumber}/${g_departmentNumber}/${g_customerId}/${g_storeId}/${g_stockDate}/${g_user}';
    var url = Uri.parse(uri);
    var i = 0;
    //print ('url: ${url}');
    var response = await http.get(url);
    //print (json.decode(response.body));
    final List parsedList = json.decode(response.body);
    List<jobAuditSkuVariationDept> list = parsedList.map((e) => jobAuditSkuVariationDept.fromTOMIDBJson(e)).toList();

    for(i=0;i<list.length;i++){
      nuevoJobAuditSkuVariationDept(list[i]);
    }

    // Consultar si existe la hora de inicio de la auditoría del departamento - sección
    // late bool existDepartment = false;
    var departmentStartDate = (await DBProvider.db.DepartmentStartDate())!;
    //print ('existDepartment: ${departmentStartDate}');
    if (departmentStartDate == "") // Si no hay fecha de StartDate ir a tomi para consultarla y guardarla en la BD local
      {
        uri = '${Preferences.servicesURL}/api/Audit/GetAuditDepartmentSectionSkuStartDate/${g_departmentNumber}/${g_customerId}/${g_storeId}/${g_stockDate}';
        url = Uri.parse(uri);
        response = await http.get(url);
        print(json.decode(response.body));
        var update = (await DBProvider.db.UpdateDepartmentStartDate(json.decode(response.body)))!;
        g_depatmentStartDate = departmentStartDate = json.decode(response.body);
        //print('if: ${g_depatmentStartDate}');
      }
    else{
      g_depatmentStartDate = departmentStartDate;
      //print('else: ${g_depatmentStartDate}');
    }

    return departmentStartDate;
  }

  Future<int?> UpdateDepartmentStartDate(String startDate) async {
    final db = await database;
    int? res = 0;
    try {
      res = await db?.rawUpdate('''
          UPDATE DEPARTMENTS SET Start_Audit_Date_Time = ? WHERE InventoryKey = ? and depId = ?''',
          ['${startDate}','${g_inventorykey}','${g_departmentNumber}']
          );
    } on DatabaseException
    catch(e) {
      print(e);
    }
    return res;
  }

  Future<String?> DepartmentStartDate () async{
    final db = await database;

    final start_Audit_Date_Time = await db?.rawQuery('''
            select Start_Audit_Date_Time, depId from DEPARTMENTS where InventoryKey = '${g_inventorykey}' and depId = '${g_departmentNumber}'
            ''');

    //print(start_Audit_Date_Time);
    //print(start_Audit_Date_Time![0]['Start_Audit_Date_Time']);
    if (start_Audit_Date_Time![0]['Start_Audit_Date_Time'] != null)
      return start_Audit_Date_Time![0]['Start_Audit_Date_Time'].toString();

    return "";
  }

  /* Descarga en la tablet todos los registros por validar por el Auditor para SORIANA*/
  Future<void> downloadAuditorDepartmentSectionSkuToAudit() async {

    //GetAuditTagToProcessAsync/{operation:int}/{customerId:int}/{storeId:int}/{stockDate:DateTime}
    var uri = '${Preferences.servicesURL}/api/Audit/GetAuditTagToProcessTabletAsync/1/${g_customerId}/${g_storeId}/${g_stockDate}';
    var url = Uri.parse(uri);
    //print (uri);
    var response = await http.get(url);
    //print (response.body);
    final List parsedList = json.decode(response.body);
    //print('downloadAuditorDepartmentSectionSkuToAudit: ${parsedList}');
    //List<jobAuditSkuVariationDept> list = parsedList.map((e) => jobAuditSkuVariationDept.fromTOMIDBJson(e)).toList();
    List<jobDetailAudit> list = parsedList.map((e) => jobDetailAudit.fromTomiDBJson(e)).toList();

    if (g_auditType == 1 && g_user_rol == 'AUDITOR') {
      deleteAllJobDetailAudit();
      print ('Eliminar todos los registros de job detail audit');
    }

    for(var i=0;i<list.length;i++){
      //print(list[i]);
      nuevoJobDetailAudit(list[i]);
    }
  }

  /* Descarga los registros del tag selecionado para auditar y los guarda en la base de datos local*/
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

  Future<int?> downloadInventoryManager() async{
    final db = await database;
    await db?.delete('IM_AUDIT');

    int? i = 0;
    var uri = '${Preferences.servicesURL}/api/User/GetInventoryManager/${g_inventorykey}';
    var url = Uri.parse(uri);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var loginResponseBody = (jsonDecode(response.body));
       // print('downloadInventoryManager: ${response.body}');
      if (loginResponseBody['success']) {
        g_im_password = loginResponseBody['password'];
        //print('contraseña IM: ${g_im_password}');
        i = await nuevoInventoryManager(double.parse(loginResponseBody['userId'].toString()).round(), loginResponseBody['password']);
      }
    }
    return i;
  }

  Future<int?> nuevoInventoryManager(int userid, String password) async{
    int? res = 0;
    final db = await database;
    //print('nuevoInventoryManager: ${userid} ${password}');
    try {
      res = await db?.rawInsert('''
        Insert into IM_AUDIT (
                              USERID,
                              PASSWORD,
                              INVENTORYKEY,
                              CREATED_AT)
                     values(  '$userid',
                              '$password',
                              '$g_inventorykey',
                              DATE())
                              ''');
      res = 1;
    } on DatabaseException
    catch(e) {
      res = -1;
    }
    return res;
  }

  Future<List<Map<String, dynamic>>?> getErrorTypologies() async {
      final db = await database;

      final List<Map<String, dynamic?>>? maps = await db?.query('ERROR_TYPOLOGY',
          columns:['ERROR_ID','DESCRIPTION'] ,
          where:'CUSTOMER_ID = ? and STORE_ID = ? and STOCK_DATE = ? and IS_ELIGIBLE = ?',
          whereArgs: [g_customerId, g_storeId, g_stockDate.toString().substring(0,10),1]);
      /*

      final res = await db?.query('SKU_VARIATION_DEPT_AUDIT', where: 'customer_Id = ? and store_Id = ? and stock_Date = ? and department_id = ? and section_id = ?',
        whereArgs: [customerId, storeId, stockDate.toString().substring(0,10), department_id, section_id],
        orderBy: orderBy,
      );

      create table ERROR_TYPOLOGY
                  (
                    CUSTOMER_ID        INTEGER              NOT NULL,
                    STORE_ID           INTEGER              NOT NULL,
                    STOCK_DATE         DATE                 NOT NULL,
                    ERROR_ID           INTEGER              NOT NULL,
                    DESCRIPTION        TEXT,
                    IS_PROCESS_ERROR   INTEGER,
                    IS_ELIGIBLE        INTEGER,
                    PRIMARY KEY (CUSTOMER_ID, STORE_ID, STOCK_DATE, ERROR_ID)
                  );
       */

      return maps;

  }

  Future<int> downloadErrorTypology() async{
    //GetErrorTypology
    final db = await database;
    await db?.delete('ERROR_TYPOLOGY');

    var i = 0;
    var uri = '${Preferences.servicesURL}/api/ProgramTerminal/GetErrorTypology/${g_customerId}/${g_storeId}/${g_stockDate}';
    var url = Uri.parse(uri);
    var response = await http.get(url);

    //print('Get ErrorTypology: ${json.decode(response.body)}');
    final List parsedList = json.decode(response.body);
    List<JobErrorTypology> list = parsedList.map((e) => JobErrorTypology.fromJson(e)).toList();

    for(i=0;i<list.length;i++){
      //print(list[i].description);
      nuevoErrorTypology(list[i]);
    }
    return i;
  }

  Future<int?> nuevoErrorTypology(JobErrorTypology jda) async{
    int? res = 0;
    final db = await database;
    try {
      res = await db?.insert('ERROR_TYPOLOGY', jda.toJson());
    } on DatabaseException
    catch(e) {
      //log('ALERT_PARAMETER already exist.${e.toString()}');
    }
    return res;
  }

    Future<int> downloadAlerts() async{
    final db = await database;
    await db?.delete('ALERT_PARAMETER');

    var i = 0;
    var uri = '${Preferences.servicesURL}/api/ProgramTerminal/GetAlerts/${g_inventorykey}';
    var url = Uri.parse(uri);
    var response = await http.get(url);
    //print('Get Alerts: ${json.decode(response.body)}');
    final List parsedList = json.decode(response.body);
    List<JobAlertParameter> list = parsedList.map((e) => JobAlertParameter.fromJson(e)).toList();

    for(i=0;i<list.length;i++){
      nuevoAlert(list[i]);
    }

    g_alertQuantity = (await DBProvider.db.alert_Higher_Quantity())!;
    g_alertAmount = (await DBProvider.db.alert_Higher_Amount())!;

    return i;
  }

  Future<int> AuditProcesOneChange(jobDetailAudit jobDetails, int action, int sourceAction) async{

    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/AuditMassChange'); // IOS

    List<double> jobDetailsAudit = [];
    jobDetailsAudit.add(jobDetails.job_Details_Id);

    try {
      var params = {
        'customerId':g_customerId,
        'storeId': g_storeId,
        'stockDate' : g_stockDate.toString(),
        'operation' : 1,
        'action': action,
        'sourceAction' : sourceAction,
        'jobDetailsIds' : jobDetailsAudit,
        'auditorId' : g_user
      };
      //print(' params:${json.encode(params)}');
      //print(' jobDetailAuditModel:${json.encode(jobDetails)}');
      var response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
          body: json.encode(params)
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        //print(' data .${data}');
        if (!data["success"]){
          tipoerror = 2;
        }
        else{
          jobDetails.sent = 1;
          DBProvider.db.updateJobDetailAudit(jobDetails);
        }
      }
    } on SocketException catch (e) {
      //print(' Error en servicio .${e.toString()}');
      tipoerror = 1;
    }
    catch(e){
      tipoerror = 2;
    }

    return tipoerror;
  }

  /*
  create table IM_AUDIT
                  (
                       USERID              INTEGER,
                       PASSWORD            TEXT,
                       INVENTORYKEY        TEXT,
                       CREATED_AT          DATE,
                       PRIMARY KEY (USERID)
                  );
   */

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


}
