import 'package:flutter/services.dart';
import 'package:tomi_terminal_audit2/models/jobDetailAudit_model.dart';
import 'package:flutter/material.dart';

import '../models/jobAuditSkuVariationDept_model.dart';
import '../providers/db_provider.dart';

class DepartmentSectionEditScreen extends StatelessWidget {
  const DepartmentSectionEditScreen
      ({
    Key? key, required  this.jAuditSkuVariationDept,
  }) : super(key: key);

  final jobAuditSkuVariationDept jAuditSkuVariationDept;

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
            EditForm(jAuditSkuVariationDept: jAuditSkuVariationDept,),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save, size: 40,),
        onPressed: () async{
          if (jAuditSkuVariationDept.audit_New_Quantity == null || jAuditSkuVariationDept.audit_New_Quantity <= 0
              || jAuditSkuVariationDept.audit_Reason_Code == null || jAuditSkuVariationDept.audit_Reason_Code <=0){
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
            jAuditSkuVariationDept.audit_Action = 2;
            jAuditSkuVariationDept.audit_Status = 2;
            DBProvider.db.updateJobSkuVariationDeptAudit(jAuditSkuVariationDept);
            Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails');
          }
        },
      ),
    );
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
                    qty: widget.jAuditSkuVariationDept.contado.round(),
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
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value == 'Preconteo Tienda erróneo.'){
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
