import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/jobAuditSkuVariationDept_model.dart';
import '../providers/db_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../share_preferences/preferences.dart';
import '../util/globalvariables.dart';

class DepartmentSectionEditScreen extends StatefulWidget {
  const DepartmentSectionEditScreen
      ({
    Key? key, required  this.jAuditSkuVariationDept,
  }) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

  @override
  State<DepartmentSectionEditScreen> createState() => _DepartmentSectionEditScreenState();
}

class _DepartmentSectionEditScreenState extends State<DepartmentSectionEditScreen> {

   /*void initState() {
     super.initState();
     SystemChrome.setPreferredOrientations([
       DeviceOrientation.landscapeLeft,
       DeviceOrientation.landscapeRight,
     ]);
   }*/

  // @override
  // dispose() {
  //   SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ]);
  //   super.dispose();
  // }

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
        title: const Text('Edit Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EditForm(jAuditSkuVariationDept: widget.jAuditSkuVariationDept,),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save, size: 40,),
        onPressed: () async{
          if (widget.jAuditSkuVariationDept.audit_New_Quantity == null || widget.jAuditSkuVariationDept.audit_New_Quantity <= 0
              || widget.jAuditSkuVariationDept.audit_Reason_Code == null || widget.jAuditSkuVariationDept.audit_Reason_Code <=0){
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
                        Text('New quantity and Reason Change are necessary !!'),
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
          else{
            widget.jAuditSkuVariationDept.audit_Action = 2;
            widget.jAuditSkuVariationDept.audit_Status = 2;

            int? amount = await DBProvider.db.alert_Higher_Amount();
            //print('Alerta monto: ${amount}');
            //print('Precio: ${widget.jAuditSkuVariationDept.sale_Price}');
            //print('Cantidad: ${widget.jAuditSkuVariationDept.pzas}');
            //print('Nueva Cantidad: ${widget.jAuditSkuVariationDept.audit_New_Quantity}');
            print('Costo: ${widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.pzas}');
            print('Nuevo Costo: ${widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.audit_New_Quantity}');

            if(((widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.pzas)-(widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.audit_New_Quantity)).abs() > amount! ){
              print('Diferencia Costo: ${((widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.pzas)-(widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.audit_New_Quantity)).abs()}');
              widget.jAuditSkuVariationDept.audit_Action = 5;
            }

            // aqui se envia el registro a tOMI
            var tipoerror = await sendEditJobDetail(widget.jAuditSkuVariationDept);

            /*if (tipoerror == 0){
              widget.jAuditSkuVariationDept.sent = 1;
            }*/
            //print('jAuditSkuVariationDept.sent: ${widget.jAuditSkuVariationDept.sent}');
            DBProvider.db.updateJobSkuVariationDeptAudit(widget.jAuditSkuVariationDept);

            writeToLog('Edit Record: ${widget.jAuditSkuVariationDept.code} value: ${widget.jAuditSkuVariationDept.pzas} - new value: ${widget.jAuditSkuVariationDept.audit_New_Quantity} Diferencia Costo: ${((widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.pzas)-(widget.jAuditSkuVariationDept.sale_Price * widget.jAuditSkuVariationDept.audit_New_Quantity)).abs()} - sent error: $tipoerror');

            Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails');

          }
        },
      ),
    );
  }

  Future<int> sendEditJobDetail(jobAuditSkuVariationDept jAuditSkuVariationDetailsRecord) async {

    //Enviar a la base de TOMI los registros con los cambios auditados
    List<jobAuditSkuVariationDept> jAuditSkuVariationDetails = [];
    var i = 0;
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/GetSkuVariationDetailsAuditAsync'); // IOS

    final auditorSkuVariationDept = await DBProvider.db.getAuditorSkuVariationDeptAuditedandPendingtosend();
    jAuditSkuVariationDetails = [...?auditorSkuVariationDept];

    jAuditSkuVariationDetails.add(jAuditSkuVariationDetailsRecord);
    //writeToLog('Count Records to send: ${jAuditSkuVariationDetails.length}');
    print('sendEditJobDetail Count Records to send: ${jAuditSkuVariationDetails.length}');

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

class EditForm extends StatefulWidget {
  const EditForm({
    Key? key, required this.jAuditSkuVariationDept,
  }) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Container(
        //width: double.infinity,
        // height: 200,
          decoration: _buildBoxDecoration(),
          child: Form(
            child: Column(
              children: [
                _ProductDetails(numrec: widget.jAuditSkuVariationDept.rec.round(),
                    sku: widget.jAuditSkuVariationDept.code.toString(),
                    qty: widget.jAuditSkuVariationDept.pzas.round(),
                    price: widget.jAuditSkuVariationDept.sale_Price),
                const SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                    labelText: 'New Quantity ',
                  ),
                  onChanged: (String? value){
                    widget.jAuditSkuVariationDept.audit_New_Quantity = int.parse(value!) * 1.0;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: ( value ){
                    //print('validator');
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                    if (value != null && int.parse(value) > 0) return null;
                    return 'Quantity value must be grather than zero';

                  },
                ),
                const SizedBox(height: 10,),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.swipe_up),
                    labelText: 'Reason Change',
                  ),

                  items: <String>['Error preparación tienda',
                    'Error conteo proveedor'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {

                    if (value == 'Error preparación tienda'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 1;
                    }
                    else if (value == 'Error conteo proveedor'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 2;
                    }

                    print('jAuditSkuVariationDept.audit_Reason_Code: ${value} ${widget.jAuditSkuVariationDept.audit_Reason_Code}');

                    /*if (value == 'Preconteo Tienda erróneo.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 1;
                    }
                    else if (value == 'Conteo Inicial Accurats erróneo'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 2;
                    }
                    else if (value == 'Sku no corresponde.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 3;
                    }
                    else if (value == 'Caja en altillo sin SKU (QR)'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 4;
                    }
                    else if (value == 'Caja en Altillos sin cantidad o cantidad errónea.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 5;
                    }
                    else if (value == 'Cantidad no corresponde.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 6;
                    }
                    else if (value == 'SKU no existe, se cambió por similar.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 7;
                    }
                    else if (value == 'Error en Unidad de medida.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 8;
                    }
                    else if (value == 'corrección por Tablet, errónea en cantidad'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 9;
                    }
                    else if (value == 'corrección por Tablet, errónea en Sku.'){
                      widget.jAuditSkuVariationDept.audit_Reason_Code = 10;
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
  const _ProductDetails({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: 100,
        decoration: _buildBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('# REC: $numrec',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('SKU: $sku',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('QTY: $qty PRICE: \$$price',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
      color: Colors.amber[300],
      borderRadius: const BorderRadius.only( topLeft: Radius.circular(25),topRight: Radius.circular(25), bottomRight: Radius.circular(25), bottomLeft:Radius.circular(25) )
  );
}
