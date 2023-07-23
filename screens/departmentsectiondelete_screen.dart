
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/jobAuditSkuVariationDept_model.dart';
import '../providers/db_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../share_preferences/preferences.dart';
import '../util/globalvariables.dart';

class DepartmentSectionDeleteScreen extends StatefulWidget {
  const DepartmentSectionDeleteScreen({Key? key, required this.jAuditSkuVariationDept}) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

  @override
  State<DepartmentSectionDeleteScreen> createState() => _DepartmentSectionDeleteScreenState();
}

class _DepartmentSectionDeleteScreenState extends State<DepartmentSectionDeleteScreen> {

  /*void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }*/

  Future<void> writeToLog(String log) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log${ DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}.txt');

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final logWithTimestamp = '[$timestamp] $log\n';
    print('${directory.path}/log.txt');
    await file.writeAsString(logWithTimestamp, mode: FileMode.append);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DeleteForm(jAuditSkuVariationDept: widget.jAuditSkuVariationDept),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete, size: 40,),
        onPressed: (){
          if (widget.jAuditSkuVariationDept.audit_Reason_Code == null || widget.jAuditSkuVariationDept.audit_Reason_Code <=0){
            showDialog(
                barrierDismissible: true,
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
                        Text('Reason Change is necessary !!'),
                        SizedBox(height: 10),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK')),
                    ],
                  );
                });
          }
          else {
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
                        Text('Are you sure you want to delete the record ?'),
                        SizedBox(height: 10),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            widget.jAuditSkuVariationDept.audit_New_Quantity = 0.0;
                            widget.jAuditSkuVariationDept.audit_Action = 4;
                            widget.jAuditSkuVariationDept.audit_Status = 2;

                            var tipoerror = await sendDeleteJobDetail(widget.jAuditSkuVariationDept);

                            /*if (tipoerror == 0){
                              widget.jAuditSkuVariationDept.sent = 1;
                            }*/
                            writeToLog('Delete Record: ${widget.jAuditSkuVariationDept.code}');
                            DBProvider.db.updateJobSkuVariationDeptAudit(widget.jAuditSkuVariationDept);
                            Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails');
                          },
                          child: const Text('OK')),
                      TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails'),
                          child: const Text('Cancel'))
                    ],
                  );
                });
          }
        },
      ),
    );
  }

  Future<int> sendDeleteJobDetail(jobAuditSkuVariationDept jAuditSkuVariationDetailsRecord) async {

    //Enviar a la base de TOMI los registros con los cambios auditados

    List<jobAuditSkuVariationDept> jAuditSkuVariationDetails = [];
    var i = 0;
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/GetSkuVariationDetailsAuditAsync'); // IOS

    final auditorSkuVariationDept = await DBProvider.db.getAuditorSkuVariationDeptAuditedandPendingtosend();
    jAuditSkuVariationDetails = [...?auditorSkuVariationDept];

    jAuditSkuVariationDetails.add(jAuditSkuVariationDetailsRecord);
   // writeToLog('Count Records to send: ${jAuditSkuVariationDetails.length}');
    print('Count Records to send: ${jAuditSkuVariationDetails.length}');

    for (i = 0; i < jAuditSkuVariationDetails.length; i++) {
      jAuditSkuVariationDetails[i].audit_Status = (jAuditSkuVariationDetails[i].audit_Action == 1)?jAuditSkuVariationDetails[i].audit_Status = 4:jAuditSkuVariationDetails[i].audit_Status = 3;
      print(jAuditSkuVariationDetails[i].toJson());
      //writeToLog('record: i - Json: ${jAuditSkuVariationDetails[i].toJson().toString()}');
    }

    try {
      List jsonTags = jAuditSkuVariationDetails.map((jAuditSkuVariationDetails) => jAuditSkuVariationDetails.toJson()).toList();
      var params = {
        'customerId':g_customerId,
        'storeId': g_storeId,
        'stockDate' : g_stockDate.toString(),
        'departmentId' : g_departmentNumber,
        'sectionId': g_sectionNumber,
        'closeSection' : 0,
        'skuVariationAuditModel' : jAuditSkuVariationDetails
      };
      print(' url: ${url}');
      print(' params:${json.encode(params)}');
      print(' jAuditSkuVariationDetails:${json.encode(jAuditSkuVariationDetails)}');
      var response = await http.post(
          url,
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
          body: json.encode(params)
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(' data .${data}');
        if (!data["success"]){
          tipoerror = 2;
        }
        else {
          for (i = 0; i < jAuditSkuVariationDetails.length; i++) {
            jAuditSkuVariationDetails[i].sent = 1;
            DBProvider.db.updateJobSkuVariationDeptAudit(
                jAuditSkuVariationDetails[i]);
          }
        }
      }
    } on SocketException catch (e) {
      //print(' Error en servicio .${e.toString()}');
      tipoerror = 1;
    }
    catch(e){
      //print(' jAuditSkuVariationDetails already exist in TOMI .${e.toString()}');
      writeToLog('SendJobDetail: ${e.toString()}');
      tipoerror = 2;
    }

    return tipoerror;
  }


}

class DeleteForm extends StatelessWidget {
  const DeleteForm({
    Key? key, required this.jAuditSkuVariationDept,
  }) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        //width: double.infinity,
        // height: 200,
          decoration: _buildBoxDecoration(),
          child: Form(
            child: Column(
              children: [
                _ProductDetails(numrec:jAuditSkuVariationDept.rec.round(),
                    sku: jAuditSkuVariationDept.code,
                    qty: jAuditSkuVariationDept.pzas.round(),
                    price: jAuditSkuVariationDept.sale_Price),
                SizedBox(height: 10,),
                /*Text('# REC : ${jdetailaudit.job_Details_Id.round()}'),
                SizedBox(height: 10,),
                Text('# SKU : ${jdetailaudit.code}'),
                SizedBox(height: 10,),
                Text('# QTY : ${jdetailaudit.quantity.round()}'),
                SizedBox(height: 10,),*/
                /*TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                    labelText: 'New Quantity ',
                  ),
                  onChanged: (String? value){
                    jdetailaudit.audit_New_Quantity = int.parse(value!) * 1.0;
                  },
                ),
                SizedBox(height: 10,),*/
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.swipe_up),
                    //hintText: 'What do people call you?',
                    labelText: 'Reason Delete',
                  ),

                  items: <String>['Error preparación tienda',
                    'Error conteo proveedor'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value == 'Error preparación tienda'){
                      jAuditSkuVariationDept.audit_Reason_Code = 1.0;
                    }
                    else if (value == 'Error conteo proveedor'){
                      jAuditSkuVariationDept.audit_Reason_Code = 2.0;
                    }

                    /*if (value == 'Preconteo Tienda erróneo.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 1;
                    }
                    else if (value == 'Conteo Inicial Accurats erróneo'){
                      jAuditSkuVariationDept.audit_Reason_Code = 2;
                    }
                    else if (value == 'Sku no corresponde.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 3;
                    }
                    else if (value == 'Caja en altillo sin SKU (QR)'){
                      jAuditSkuVariationDept.audit_Reason_Code = 4;
                    }
                    else if (value == 'Caja en Altillos sin cantidad o cantidad errónea.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 5;
                    }
                    else if (value == 'Cantidad no corresponde.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 6;
                    }
                    else if (value == 'SKU no existe, se cambió por similar.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 7;
                    }
                    else if (value == 'Error en Unidad de medida.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 8;
                    }
                    else if (value == 'corrección por Tablet, errónea en cantidad'){
                      jAuditSkuVariationDept.audit_Reason_Code = 9;
                    }
                    else if (value == 'corrección por Tablet, errónea en Sku.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 10;
                    }*/
                  },
                ),
              ],
            ),
          )
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => const BoxDecoration(
    color:Colors.white,
    borderRadius: BorderRadius.only(bottomRight: Radius.circular(25),
        bottomLeft: Radius.circular(25)),
  );
}


class _ProductDetails extends StatelessWidget {
  _ProductDetails({
    Key? key, required this.numrec, required this.sku, required this.qty, required this.price,
  }) : super(key: key);

  final int numrec;
  final String sku;
  final int qty;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: 100,
        decoration: _buildBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('# REC: $numrec',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('SKU: $sku',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('QTY: $qty PRICE: \$$price',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
      color: Colors.red[200],
      borderRadius: BorderRadius.only( topLeft: Radius.circular(25),topRight: Radius.circular(25), bottomRight: Radius.circular(25), bottomLeft:Radius.circular(25) )
  );
}
