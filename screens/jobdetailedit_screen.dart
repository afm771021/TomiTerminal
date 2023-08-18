import 'package:flutter/services.dart';
import 'package:tomi_terminal_audit2/models/jobDetailAudit_model.dart';
import 'package:flutter/material.dart';

import '../models/jobErrorTypology_model.dart';
import '../providers/db_provider.dart';

class JobDetailsEditScreen extends StatelessWidget {
  const JobDetailsEditScreen
      ({
        Key? key, required this.jdetailaudit,
      }) : super(key: key);

  final jobDetailAudit jdetailaudit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EditForm(jdetailaudit: jdetailaudit),
            const SizedBox(height: 100),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save, size: 40,),
        onPressed: () async{
          if (jdetailaudit.audit_New_Quantity == null || jdetailaudit.audit_New_Quantity <= 0
              || jdetailaudit.audit_Reason_Code == null || jdetailaudit.audit_Reason_Code <=0){
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(10)),
                    title: const Text('Alert'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
            jdetailaudit.audit_Action = 2;
            jdetailaudit.audit_Status = 2;
            int? quantity = await DBProvider.db.alert_Higher_Quantity();
            int? amount = await DBProvider.db.alert_Higher_Amount();

            switch(await determine_alert(jdetailaudit, quantity!, amount!)){
              case 0:{
                DBProvider.db.updateJobDetailAudit(jdetailaudit);
                Navigator.pushReplacementNamed(context, 'TagListDetails');
              }
              break;
              case 1:{
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
                            Text('The quantity and the amount of the correction exceeds the maximum parameter.(Qty: $quantity, Amount: \$$amount)'),
                            const SizedBox(height: 10),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: (){
                            DBProvider.db.updateJobDetailAudit(jdetailaudit);
                            Navigator.pushReplacementNamed(context, 'TagListDetails');
                          }, child: const Text('Continue')),
                          TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
                              child: const Text('Cancel')),
                        ],
                      );
                    });
              }
              break;
              case 2:{
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
                          children:  [
                            Text('The amount of the correction exceeds the maximum parameter.(Amount: \$$amount)'),
                            const SizedBox(height: 10),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: (){
                            DBProvider.db.updateJobDetailAudit(jdetailaudit);
                            Navigator.pushReplacementNamed(context, 'TagListDetails');
                          }, child: const Text('Continue')),
                          TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
                              child: const Text('Cancel')),
                        ],
                      );
                    });
              }
              break;
              case 3:{
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
                          children:  [
                            Text('The quantity of the correction exceeds the maximum parameter.(Qty: $quantity)'),
                            const SizedBox(height: 10),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: (){
                            DBProvider.db.updateJobDetailAudit(jdetailaudit);
                            Navigator.pushReplacementNamed(context, 'TagListDetails');
                          }, child: const Text('Continue')),
                          TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
                              child: const Text('Cancel')),
                        ],
                      );
                    });
              }
              break;
            }
          }
        },
    ),
    );
  }



  Future<int> determine_alert(jobDetailAudit jdetailaudit, int quantity, int amount) async {
    bool diferencequantity = false;
    bool diferenceamount = false;

    if (quantity > 0) {
      if ((jdetailaudit.quantity - jdetailaudit.audit_New_Quantity).abs() > quantity)
        diferencequantity = true;
      print('cantidad: $quantity');
    }

    if (amount > 0){
      if (((jdetailaudit.quantity * jdetailaudit.sale_Price) - (jdetailaudit.audit_New_Quantity * jdetailaudit.sale_Price)).abs() > amount)
        diferenceamount = true;
      print('monto: $amount');
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

class EditForm extends StatefulWidget {
  const EditForm({
    Key? key, required this.jdetailaudit,
  }) : super(key: key);

  final jobDetailAudit jdetailaudit;

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
              _ProductDetails(numrec: widget.jdetailaudit.job_Details_Id.round(),
                              sku: widget.jdetailaudit.code.toString(),
                              qty: widget.jdetailaudit.quantity.round(),
                              price: widget.jdetailaudit.sale_Price),
              const SizedBox(height: 10,),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.numbers),
                  labelText: 'New Quantity ',
                ),
                onChanged: (String? value){
                  widget.jdetailaudit.audit_New_Quantity = int.parse(value!) * 1.0;
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
              /*DropdownButtonFormField(
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
                    widget.jdetailaudit.audit_Reason_Code = 1;
                  }
                  else if (value == 'Error conteo proveedor'){
                    widget.jdetailaudit.audit_Reason_Code = 2;
                  }
                },
              ),*/
              FutureBuilder<List<Map<String, dynamic>>?>(
                future: DBProvider.db.getErrorTypologies(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<Map<String, dynamic>> opciones = snapshot.data!;

                    List<DropdownMenuItem<int>> dropdownItems = opciones.map((opcion) {
                      int? valor = opcion['ERROR_ID'] as int?;
                      String descripcion = opcion['DESCRIPTION'] as String;

                      return DropdownMenuItem<int>(
                        value: valor,
                        child: Text(descripcion),
                      );
                    }).toList();

                    return DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.swipe_up),
                        labelText: 'Reason Change',
                      ),
                      items: dropdownItems,
                      onChanged: (selectedValue) {
                        widget.jdetailaudit.audit_Reason_Code = selectedValue!.toDouble();
                        print(widget.jdetailaudit.audit_Reason_Code);
                      },

                    );
                  } else {
                    return Text('No hay datos disponibles');
                  }
                },
              )
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
