import 'package:flutter/material.dart';
import '../models/jobDetailAudit_model.dart';
import '../providers/db_provider.dart';

class JobDetailsDeleteScreen extends StatelessWidget {
  const JobDetailsDeleteScreen({Key? key, required this.jdetailaudit}) : super(key: key);

  final jobDetailAudit jdetailaudit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DeleteForm(jdetailaudit: jdetailaudit),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete, size: 40,),
        onPressed: (){
          if (jdetailaudit.audit_Reason_Code == null || jdetailaudit.audit_Reason_Code <=0){
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
                          onPressed: (){
                            jdetailaudit.audit_New_Quantity = 0.0;
                            jdetailaudit.audit_Action = 4;
                            jdetailaudit.audit_Status = 2;
                            DBProvider.db.updateJobDetailAudit(jdetailaudit);
                            Navigator.pushReplacementNamed(context, 'TagListDetails');
                          },
                          child: const Text('OK')),
                      TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
                          child: const Text('Cancel'))
                    ],
                  );
                });
          }
        },
      ),
    );
  }
}

class DeleteForm extends StatelessWidget {
  const DeleteForm({
    Key? key, required this.jdetailaudit,
  }) : super(key: key);

  final jobDetailAudit jdetailaudit;

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
                _ProductDetails(numrec:jdetailaudit.job_Details_Id.round(),
                                sku: jdetailaudit.code,
                                qty: jdetailaudit.quantity.round()),
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

                  items: <String>['Preconteo Tienda err??neo.',
                    'Conteo Inicial Accurats err??neo',
                    'Sku no corresponde.',
                    'Caja en altillo sin SKU (QR)',
                    'Caja en Altillos sin cantidad o cantidad err??nea.',
                    'Cantidad no corresponde.',
                    'SKU no existe, se cambi?? por similar.',
                    'Error en Unidad de medida.',
                    'correcci??n por Tablet, err??nea en cantidad',
                    'correcci??n por Tablet, err??nea en Sku.'
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
                    if (value == 'Preconteo Tienda err??neo.'){
                      jdetailaudit.audit_Reason_Code = 1;
                    }
                    else if (value == 'Conteo Inicial Accurats err??neo'){
                      jdetailaudit.audit_Reason_Code = 2;
                    }
                    else if (value == 'Sku no corresponde.'){
                      jdetailaudit.audit_Reason_Code = 3;
                    }
                    else if (value == 'Caja en altillo sin SKU (QR)'){
                      jdetailaudit.audit_Reason_Code = 4;
                    }
                    else if (value == 'Caja en Altillos sin cantidad o cantidad err??nea.'){
                      jdetailaudit.audit_Reason_Code = 5;
                    }
                    else if (value == 'Cantidad no corresponde.'){
                      jdetailaudit.audit_Reason_Code = 6;
                    }
                    else if (value == 'SKU no existe, se cambi?? por similar.'){
                      jdetailaudit.audit_Reason_Code = 7;
                    }
                    else if (value == 'Error en Unidad de medida.'){
                      jdetailaudit.audit_Reason_Code = 8;
                    }
                    else if (value == 'correcci??n por Tablet, err??nea en cantidad'){
                      jdetailaudit.audit_Reason_Code = 9;
                    }
                    else if (value == 'correcci??n por Tablet, err??nea en Sku.'){
                      jdetailaudit.audit_Reason_Code = 10;
                    }
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
    Key? key, required this.numrec, required this.sku, required this.qty,
  }) : super(key: key);

  final int numrec;
  final String sku;
  final int qty;

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
            Text('QTY: $qty',
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
