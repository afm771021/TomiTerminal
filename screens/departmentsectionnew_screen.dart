import 'package:flutter/services.dart';
import 'package:tomi_terminal_audit2/models/jobDetailAudit_model.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import '../models/jobAuditSkuVariationDept_model.dart';
import '../providers/db_provider.dart';

class DepartmentSectionNewScreen extends StatefulWidget {
  DepartmentSectionNewScreen({Key? key,}) : super(key: key);

  @override
  State<DepartmentSectionNewScreen> createState() => _DepartmentSectionNewScreenState();
}

class _DepartmentSectionNewScreenState extends State<DepartmentSectionNewScreen> {
  late bool existInMasterfile = false;
  late bool existDepartment = false;
  /*late JobDepartment dropdownValue;
   List<JobDepartment> departmentsItemList = [];*/

  var jAuditSkuVariationDept = jobAuditSkuVariationDept(
      customer_Id: g_customerId.toDouble(),
      store_Id: g_storeId.toDouble(),
      stock_Date: g_stockDate,
      valdep: 0,
      department: '',
      department_Id: g_departmentNumber,
      section_Id: g_sectionNumber.toDouble(),
      sku: '',
      description: '',
      teorico: 0,
      contado: 0,
      dif: 0,
      sale_Price: 0 ,
      code: '',
      tag: '',
      pzas: 0,
      valuacion: 0,
      rec: 0,
      audit_User: '',
      audit_Status: 2,
      audit_New_Quantity: 0,
      audit_Action: 3,
      audit_Reason_Code: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Record'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.backspace_outlined),
          onPressed: () => Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddForm(jAuditSkuVariationDept: jAuditSkuVariationDept ,),
            Visibility(
              visible: (existInMasterfile)?false:true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.home_filled),
                    labelText: 'Tag ',
                  ),
                  onChanged: (String? value){
                    jAuditSkuVariationDept.tag = value!;
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
                      jAuditSkuVariationDept.sale_Price = double.parse(value!) ;}
                    catch (e){ jAuditSkuVariationDept.sale_Price = 0;}
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
          if ((jAuditSkuVariationDept.code == null || jAuditSkuVariationDept.code.isEmpty ||
              jAuditSkuVariationDept.sku == null || jAuditSkuVariationDept.sku.isEmpty ||
              jAuditSkuVariationDept.contado == null || jAuditSkuVariationDept.contado <= 0 ||
              jAuditSkuVariationDept.audit_Reason_Code == null || jAuditSkuVariationDept.audit_Reason_Code <=0)
             ){
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
            DBProvider.db.nuevoJobAuditSkuVariationDept(jAuditSkuVariationDept);
            Navigator.pushReplacementNamed(context, 'DepartmentSectionListDetails');
            //print(jAuditSkuVariationDept);
          }
        },
      ),
    );
  }
}

class AddForm extends StatelessWidget {
  const AddForm({
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
                const SizedBox(height: 10,),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.qr_code),
                    labelText: 'SKU',
                  ),
                  onChanged: (String? value){
                    jAuditSkuVariationDept.sku = value!;
                  },
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.qr_code),
                    labelText: 'UPC',
                  ),
                  onChanged: (String? value){
                    jAuditSkuVariationDept.code = value!;
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
                      jAuditSkuVariationDept.contado = int.parse(value!) * 1.0;}
                    catch (e){ jAuditSkuVariationDept.contado = 0; }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
                // const SizedBox(height: 10,),
                // TextFormField(
                //   decoration: const InputDecoration(
                //     icon: Icon(Icons.store),
                //     labelText: 'Shelf ',
                //   ),
                //   onChanged: (String? value){
                //     //jdetailaudit.shelf = value!;
                //   },
                // ),
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
                      jAuditSkuVariationDept.audit_Reason_Code = 1.0;
                    }
                    else if (value == 'Conteo Inicial Accurats erróneo'){
                      jAuditSkuVariationDept.audit_Reason_Code = 2.0;
                    }
                    else if (value == 'Sku no corresponde.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 3.0;
                    }
                    else if (value == 'Caja en altillo sin SKU (QR)'){
                      jAuditSkuVariationDept.audit_Reason_Code = 4.0;
                    }
                    else if (value == 'Caja en Altillos sin cantidad o cantidad errónea.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 5.0;
                    }
                    else if (value == 'Cantidad no corresponde.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 6.0;
                    }
                    else if (value == 'SKU no existe, se cambió por similar.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 7.0;
                    }
                    else if (value == 'Error en Unidad de medida.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 8.0;
                    }
                    else if (value == 'corrección por Tablet, errónea en cantidad'){
                      jAuditSkuVariationDept.audit_Reason_Code = 9.0;
                    }
                    else if (value == 'corrección por Tablet, errónea en Sku.'){
                      jAuditSkuVariationDept.audit_Reason_Code = 10.0;
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
