import 'package:flutter/services.dart';
import 'package:tomi_terminal_audit2/models/jobDetailAudit_model.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import '../providers/db_provider.dart';

class JobDetailsNewScreen extends StatefulWidget {
   JobDetailsNewScreen({Key? key,}) : super(key: key);

  @override
  State<JobDetailsNewScreen> createState() => _JobDetailsNewScreenState();
}

class _JobDetailsNewScreenState extends State<JobDetailsNewScreen> {
   late bool existInMasterfile = true;
   late bool existDepartment = false;
   /*late JobDepartment dropdownValue;
   List<JobDepartment> departmentsItemList = [];*/

   var jdetailaudit = jobDetailAudit(customer_Id: g_customerId.toDouble(),
                                     store_Id: g_storeId.toDouble(),
                                     stock_Date: g_stockDate,
                                     job_Details_Id: 0,
                                     tag_Number: g_tagNumber.toDouble(),
                                     tag_Id: 0,
                                     shelf: '',
                                     description: '',
                                     code: '',
                                     sale_Price: 0,
                                     quantity: 0,
                                     captured_date_time: DateTime.now() ,
                                     department_Id: '99999',
                                     nof: 0,
                                     sku: '99999',
                                     terminal: '99999',
                                     emp_Id: '99999',
                                     operation: 0,
                                     audit_Status: 2,
                                     audit_New_Quantity: 0,
                                     audit_Action: 3,
                                     audit_Reason_Code: 0);

   /*Future<List<JobDepartment>> loadDepartments () async{
       final departments = await DBProvider.db.getAllDepartments();
       departmentsItemList = [...departments!];
       //dropdownValue = departmentsItemList.first;
       print('loadDepartments departmentsItemList: $departmentsItemList');
       print('loadDepartments dropdownValue: $dropdownValue');
       print('loadDepartments dropdownValue.depId: ${dropdownValue.depId}');
     return departmentsItemList;
   }*/

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'TagListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddForm(jdetailaudit:jdetailaudit),
            Visibility(
              visible: (existInMasterfile)?false:true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.home_filled),
                    labelText: 'Department ',
                  ),
                  onChanged: (String? value){
                    jdetailaudit.department_Id = value!;
                  },
                ),
                /*FutureBuilder<List<JobDepartment>> (
                    future:  loadDepartments(),
                    builder: (context, snapshot) {
                        return DropdownButtonFormField<JobDepartment>(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.maps_home_work),
                              //hintText: 'What do people call you?',
                              labelText: 'Department',
                            ),
                            //value: dropdownValue,
                            items: departmentsItemList.map((department) => DropdownMenuItem<JobDepartment>(
                                child: Text (department.depId!),
                                value: department,
                              )
                            ).toList(),
                            onChanged: (JobDepartment? value){
                              print ('onChanged:$value');
                              setState(() {
                                dropdownValue = value!;
                              });
                            });
                    }*/
              ),
            ),

            Visibility(
                visible: (existInMasterfile)?false:true,
                child: const SizedBox(height: 10,)
            ),
            Visibility(
                visible: (existInMasterfile)?false:true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.monetization_on_outlined),
                          labelText: 'Sale Price (>0)',
                        ),
                        onChanged: (String? value){
                          try{
                              jdetailaudit.sale_Price = double.parse(value!) ;}
                          catch (e){ jdetailaudit.sale_Price = 0;}
                        },
                  ),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save, size: 40,),
        onPressed: () async {
          if ((jdetailaudit.code == null || jdetailaudit.code.isEmpty ||
              jdetailaudit.quantity == null || jdetailaudit.quantity <= 0 ||
              jdetailaudit.shelf == null || jdetailaudit.shelf.isEmpty ||
              jdetailaudit.audit_Reason_Code == null || jdetailaudit.audit_Reason_Code <=0)
              ||
              (!existInMasterfile && (jdetailaudit.sale_Price == 0 || jdetailaudit.department_Id == '99999' ||
                  jdetailaudit.department_Id.isEmpty))){
                /*print ('department_Id: ${jdetailaudit.department_Id}');
                print ('sale_Price ${jdetailaudit.sale_Price}');
                print ('description ${jdetailaudit.description}');
                print ('department ${jdetailaudit.department_Id}');*/
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
                            Text('All fields are necessary !!'),
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
            existInMasterfile = (await DBProvider.db.existRecordInMasterFile(jdetailaudit))!;
            if (!existInMasterfile && jdetailaudit.sale_Price == 0 && jdetailaudit.department_Id == '99999'){
               setState(() {});
               /*print ('department_Id: ${jdetailaudit.department_Id}');
               print ('sale_Price ${jdetailaudit.sale_Price}');
               print ('description ${jdetailaudit.description}');
               print ('department ${jdetailaudit.department_Id}');
               print ('no existe, pedir valores');*/
            }
            else if(!existInMasterfile && jdetailaudit.sale_Price > 0 && (jdetailaudit.department_Id != '99999')){
              /*print ('department_Id: ${jdetailaudit.department_Id}');
              print ('sale_Price ${jdetailaudit.sale_Price}');
              print ('description ${jdetailaudit.description}');
              print ('department ${jdetailaudit.department_Id}');*/
              //print ('no existe, ya tengo los valores');

              existDepartment = (await DBProvider.db.existDepartment(jdetailaudit))!;
              if (existDepartment){
                DBProvider.db.nuevoJobDetailAudit(jdetailaudit);
                Navigator.pushReplacementNamed(context, 'TagListDetails');
              }
              else{
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
                            Text('Department does not exist, please change value !!'),
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
            }
            else{
                //jdetailaudit.sku = jdetailaudit.code.toUpperCase();
                DBProvider.db.nuevoJobDetailAudit(jdetailaudit);
                Navigator.pushReplacementNamed(context, 'TagListDetails');
            }
          }
        },
      ),
    );
  }
}

class AddForm extends StatelessWidget {
  const AddForm({
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
                const SizedBox(height: 10,),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.qr_code),
                    labelText: 'SKU',
                  ),
                  onChanged: (String? value){
                    jdetailaudit.code = value!;
                  },
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.production_quantity_limits),
                    //hintText: 'What do people call you?',
                    labelText: 'Quantity ',
                  ),
                  onChanged: (String? value){
                    try{
                     jdetailaudit.quantity = int.parse(value!) * 1.0;}
                     catch (e){ jdetailaudit.quantity = 0; }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.store),
                    labelText: 'Shelf ',
                  ),
                  onChanged: (String? value){
                    jdetailaudit.shelf = value!;
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
                        //style: TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value == 'Preconteo Tienda erróneo.'){
                      jdetailaudit.audit_Reason_Code = 1.0;
                    }
                    else if (value == 'Conteo Inicial Accurats erróneo'){
                      jdetailaudit.audit_Reason_Code = 2.0;
                    }
                    else if (value == 'Sku no corresponde.'){
                      jdetailaudit.audit_Reason_Code = 3.0;
                    }
                    else if (value == 'Caja en altillo sin SKU (QR)'){
                      jdetailaudit.audit_Reason_Code = 4.0;
                    }
                    else if (value == 'Caja en Altillos sin cantidad o cantidad errónea.'){
                      jdetailaudit.audit_Reason_Code = 5.0;
                    }
                    else if (value == 'Cantidad no corresponde.'){
                      jdetailaudit.audit_Reason_Code = 6.0;
                    }
                    else if (value == 'SKU no existe, se cambió por similar.'){
                      jdetailaudit.audit_Reason_Code = 7.0;
                    }
                    else if (value == 'Error en Unidad de medida.'){
                      jdetailaudit.audit_Reason_Code = 8.0;
                    }
                    else if (value == 'corrección por Tablet, errónea en cantidad'){
                      jdetailaudit.audit_Reason_Code = 9.0;
                    }
                    else if (value == 'corrección por Tablet, errónea en Sku.'){
                      jdetailaudit.audit_Reason_Code = 10.0;
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
