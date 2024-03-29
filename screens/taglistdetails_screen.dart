import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:tomi_terminal_audit2/providers/job_details_list_provider.dart';
import 'package:tomi_terminal_audit2/screens/screens.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/jobDetailAudit_model.dart';
import '../providers/db_provider.dart';
import '../share_preferences/preferences.dart';
import '../widgets/tomiterminal_menu.dart';


class TagListDetailsScreen extends StatefulWidget {
  const TagListDetailsScreen({Key? key}) : super(key: key);

  @override
  State<TagListDetailsScreen> createState() => _TagListDetailsScreenState();
}

class _TagListDetailsScreenState extends State<TagListDetailsScreen> {
  var currencyFormatter = NumberFormat('#,##0.00', 'es_MX');
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final jobDetailsListProvider = Provider.of<JobDetailsListProvider>(
        context, listen: true);

    jobDetailsListProvider.getJobDetails(
        g_customerId, g_storeId, g_stockDate, g_tagNumber, g_operation);
    final jobDetails = jobDetailsListProvider.jobDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text('Audit Tag $g_tagNumber'),
        actions: [
          IconButton(
            iconSize: 40,
            onPressed: !isLoading ? () async {
              validaJobDetail(context, jobDetails);
            }:null,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      drawer: const TomiTerminalMenu(),
      body: Container(
          color: Colors.white,
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 3,),
                    _ProductDetails(jobda: jobDetails),
                    const SizedBox(height: 3,),
                    SingleChildScrollView(
                      child:
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jobDetails.length,
                          itemBuilder: (context, index) //=> ProductCard()
                          {
                            int res = determine_alert(jobDetails[index], g_alertQuantity, g_alertAmount);

                            return Card(
                              color:
                              (res > 0) ? Colors.purple[200]:
                              (jobDetails[index].audit_Action == null || jobDetails[index].audit_Action == 0) ? Colors.grey[200] :
                              (jobDetails[index].audit_Action == 1) ? Colors.green[200] :
                              (jobDetails[index].audit_Action == 2) ? Colors.amber[200] :
                              (jobDetails[index].audit_Action == 3) ? Colors.blue[200] :
                              Colors.red[200],
                              child: ListTile(
                                onTap: () {

                                },
                                onLongPress: (){
                                  if (jobDetails[index].audit_Action != 3) {
                                    jobDetails[index].audit_New_Quantity = 0.0;
                                    jobDetails[index].audit_Action = 0;
                                    jobDetails[index].audit_Status = 2;
                                    jobDetails[index].audit_Reason_Code = 0;
                                    DBProvider.db.updateJobDetailAudit(
                                        jobDetails[index]);
                                  }
                                  else{
                                    DBProvider.db.deleteJobDetailAudit(jobDetails[index]);
                                  }
                                },
                                //leading: const Icon(Icons.person),
                                title: Text(
                                    'SKU: ${jobDetails[index].sku} Code: ${jobDetails[index].code} Qty: ${jobDetails[index].quantity
                                        .toString()} QtyUp: ${jobDetails[index].audit_New_Quantity
                                        .toString()}'),
                                subtitle: Text('Desc.: ${jobDetails[index].description} Shelf: ${jobDetails[index].shelf
                                    .toString()}    Price:\$ ${currencyFormatter.format(jobDetails[index].sale_Price
                                )}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible: (jobDetails[index].audit_Action == 0)?true:false,
                                      child:
                                      IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                            final route = MaterialPageRoute(builder: (context) =>
                                                JobDetailsEditScreen(
                                                    jdetailaudit: jobDetails[index]));
                                            Navigator.pushReplacement(context, route);
                                          },
                                          icon:  Icon(
                                            Icons.edit,
                                            color: Colors.orange[200],
                                          )),
                                    ),
                                    Visibility(
                                      visible: (jobDetails[index].audit_Action == 0)?true:false,
                                      child:IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                            final route = MaterialPageRoute(builder: (context) =>
                                                JobDetailsDeleteScreen(
                                                    jdetailaudit: jobDetails[index]));
                                            Navigator.pushReplacement(context, route);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )
                                      ),
                                    ),
                                    Visibility(
                                        visible: (jobDetails[index].audit_Action == 0)?true:false,
                                        child:IconButton(
                                            iconSize: 40,
                                            onPressed: () {
                                              jobDetails[index].audit_New_Quantity = 0.0;
                                              jobDetails[index].audit_Action = 1;
                                              jobDetails[index].audit_Status = 2;
                                              jobDetails[index].audit_Reason_Code = 0;
                                              DBProvider.db.updateJobDetailAudit(jobDetails[index]);
                                              //print('ok');
                                            },
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                            ))
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                    const SizedBox(width: 200,
                      height: 50,
                      child: Center(
                        child: Text(
                          '',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
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
        /* */

      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        child: const Icon(Icons.add, size: 40,),
        onPressed: () {
          final route = MaterialPageRoute(
              builder: (context) => JobDetailsNewScreen());
          Navigator.pushReplacement(context, route);
        },
      ),
    );
  }

  Future<void> validaJobDetail(BuildContext context,
      List<jobDetailAudit> jobDetails) async {
    var i = 0;
    var noprocesados = 0;

    for (i = 0; i < jobDetails.length; i++) {
      if (jobDetails[i].audit_Action == 0) {
        noprocesados += 1;
      }
    }

    if (noprocesados > 0) {
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
                children: [
                  Text('$noprocesados record(s) missing to process !!'),
                  const SizedBox(height: 10),
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
      var tipoerror = await sendJobDetail(context, jobDetails);

      if (tipoerror == 0){
        final route = MaterialPageRoute(
            builder: (context) => const TagSearchScreen());
            Navigator.pushReplacement(context, route);
      }
      else if (tipoerror == 1){
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
                    Text('Tomi services not available !!'),
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
        } // else if
      else if (tipoerror == 2){
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
                    Text('Tag was restarted by tomi admin.!!'),
                    SizedBox(height: 10),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final route = MaterialPageRoute(
                            builder: (context) => const TagSearchScreen());
                         Navigator.pushReplacement(context, route);
                      },
                      child: const Text('OK')),
                ],
              );
            });
      }
    }
  }

  Future<int> sendJobDetail(BuildContext context,
      List<jobDetailAudit> jobDetails) async {

    if( isLoading ) return -1;
    isLoading = true;
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    //Enviar a la base de TOMI los registros con los cambios auditados
    var i = 0;
    var tipoerror = 0;
    var url = Uri.parse('${Preferences.servicesURL}/api/Audit/GetJobDetailsAuditAsync'); // IOS

      for (i = 0; i < jobDetails.length; i++) {
        jobDetails[i].audit_Status = (jobDetails[i].audit_Action == 1)?jobDetails[i].audit_Status = 4:jobDetails[i].audit_Status = 3;
        //print(jobDetails[i].toJson());
      }

      try {
        List jsonTags = jobDetails.map((jobDetail) => jobDetail.toJson()).toList();
        var params = {
          'customerId':g_customerId,
          'storeId': g_storeId,
          'stockDate' : g_stockDate.toString(),
          'tagNumber' : g_tagNumber,
          'supervisorId' : g_user,
          'jobDetailAuditModel' : jobDetails
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
        }
      } on SocketException catch (e) {
        //print(' Error en servicio .${e.toString()}');
        tipoerror = 1;
      }
      catch(e){
        //print(' JOB_DETAILS_AUDIT already exist in TOMI .${e.toString()}');
        tipoerror = 2;
      }
      isLoading = false;
      setState(() {});

    /*for (i = 0; i < jobDetails.length; i++) {
      jobDetails[i].audit_Status = 3;

      if (jobDetails[i].audit_Action == 1) {
        jobDetails[i].audit_Status = 4;
      }
      jobDetails[i].customer_Id;
      print(url.toString());
      print(jobDetails[i].toJson());
      try {
        var response = await http.post(
            url,
            headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
            body: jsonEncode(jobDetails[i].toJson())
        );

      } on SocketException catch (e) {
        //print(' Error en servicio .${e.toString()}');
        tipoerror = 1;
      }
      catch(e){
        //print(' JOB_DETAILS_AUDIT already exist in TOMI .${e.toString()}');
        tipoerror = 2;
      }
      isLoading = false;
      setState(() {});
    } //for

    // actualizar el tag en tomi a estatus AuditToProcess (2)
     url = Uri.parse(
        '${Preferences.servicesURL}/api/Audit/UpdateAuditTagAsync/${g_customerId}/${g_storeId}/${g_stockDate
            .toString().substring(0, 10)}/${g_tagNumber}/1');
    //print(url.toString());
    try{
      var response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (!data["success"]){
          return 2;
        }
      }
      //String error = data["error"];
    }
    on SocketException catch(e){
      //print (e.toString());
      tipoerror = 1;
    }*/

    return tipoerror;
  }

  int determine_alert(jobDetailAudit jdetailaudit, int quantity, int amount) {
    bool diferencequantity = false;
    bool diferenceamount = false;

    if (quantity > 0) {
      if ((jdetailaudit.audit_Action == 3 || jdetailaudit.audit_Action == 4)  && jdetailaudit.quantity > quantity)
        diferencequantity = true;
      else if ((jdetailaudit.quantity - jdetailaudit.audit_New_Quantity).abs() > quantity)
        diferencequantity = true;
     // print('cantidad: $quantity');
    }

    if (amount > 0){
      if ((jdetailaudit.audit_Action == 3 || jdetailaudit.audit_Action == 4)  && jdetailaudit.quantity * jdetailaudit.sale_Price > amount)
        diferenceamount = true;
      else if (((jdetailaudit.quantity * jdetailaudit.sale_Price) - (jdetailaudit.audit_New_Quantity * jdetailaudit.sale_Price)).abs() > amount)
        diferenceamount = true;
     // print('monto: $amount');
    }

    if (!diferenceamount && !diferencequantity)
      return 0;
    if (diferenceamount && diferencequantity)
      return 1;
    if (diferenceamount && !diferencequantity)
      return 2;
    if (!diferenceamount && diferencequantity)
      return 3;
    return -1;
  }

}

class _ProductDetails extends StatelessWidget {
  _ProductDetails({
    Key? key,
    required this.jobda
  }) : super(key: key){

    var i=0;
    for (i = 0; i < jobda.length; i++) {
      cantidad += jobda[i].quantity;
      valor +=  jobda[i].quantity * jobda[i].sale_Price;
    }
    currencyFormatter = NumberFormat('#,##0.00', 'es_MX');
    lineas = i;

  }

  final List<jobDetailAudit> jobda;

  int lineas = 0;
  double cantidad = 0.0;
  double valor = 0.0;
  var currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: size.height * 0.12,
        decoration: _buildBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lines: $lineas',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Quantity: $cantidad',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Value: \$: ${currencyFormatter.format(valor)}',
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => const BoxDecoration(
      gradient: LinearGradient(
          colors: [
            Color.fromRGBO(63, 63, 156, 1),
            Color.fromRGBO(90,70, 178, 1)
          ]
      ),
      //color: Colors.indigo,
      borderRadius: BorderRadius.only( topLeft: Radius.circular(25),topRight: Radius.circular(25), bottomRight: Radius.circular(25), bottomLeft:Radius.circular(25) )
  );
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


