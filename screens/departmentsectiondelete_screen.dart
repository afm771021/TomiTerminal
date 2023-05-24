

import 'package:flutter/material.dart';
import '../models/jobAuditSkuVariationDept_model.dart';
import '../models/jobDetailAudit_model.dart';
import '../providers/db_provider.dart';

class DepartmentSectionDeleteScreen extends StatelessWidget {
  const DepartmentSectionDeleteScreen({Key? key, required this.jAuditSkuVariationDept}) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

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
            DeleteForm(jAuditSkuVariationDept: jAuditSkuVariationDept),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete, size: 40,),
        onPressed: (){
          if (jAuditSkuVariationDept.audit_Reason_Code == null || jAuditSkuVariationDept.audit_Reason_Code <=0){
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
                            jAuditSkuVariationDept.audit_New_Quantity = 0.0;
                            jAuditSkuVariationDept.audit_Action = 4;
                            jAuditSkuVariationDept.audit_Status = 2;
                            DBProvider.db.updateJobSkuVariationDeptAudit(jAuditSkuVariationDept);
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
                    qty: jAuditSkuVariationDept.contado.round()),
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

                  items: <String>['Preconteo Tienda erróneo.',
                    'Conteo Inicial Accurats erróneo',
                    'Sku no corresponde.',
                    'Caja en altillo sin SKU (QR)',
                    'Caja en Altillos sin cantidad o cantidad errónea.',
                    'Cantidad no corresponde.',
                    'SKU no existe, se cambió por similar.',
                    'Error en Unidad de medida.',
                    'corrección por Tablet, errónea en cantidad',
                    'corrección por Tablet, errónea en Sku.'
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
                    if (value == 'Preconteo Tienda erróneo.'){
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
