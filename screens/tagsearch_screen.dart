import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../util/globalvariables.dart';
import '../widgets/tomiterminal_menu.dart';
import 'screens.dart';

class TagSearchScreen extends StatefulWidget {
  const TagSearchScreen({Key? key}) : super(key: key);

  @override
  State<TagSearchScreen> createState() => _TagSearchScreenState();
}

class _TagSearchScreenState extends State<TagSearchScreen> {
  String _scanBarcode = ' ';
  var searchtxt = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      if (_scanBarcode == '-1') {
        searchtxt.text = ' ';
      }
      else{
        searchtxt.text = _scanBarcode;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    g_searchTag = " ";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tags'),
        elevation: 10,
        actions: [
          IconButton(
              iconSize: 40,
              onPressed: (){
                  scanBarcodeNormal();
              },
              icon: const Icon(Icons.qr_code))
        ],
        //backgroundColor: Colors.cyan,
      ),
      drawer: const TomiTerminalMenu(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40,30,40,0),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchtxt,
                keyboardType: TextInputType.number,
                onChanged: (value)
                {
                  g_searchTag = value;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: const InputDecoration(
                    labelText: 'Search Tag'),
              ),
            ),
            const SizedBox(height: 20,),
            ElevatedButton.icon(
                icon: const Icon(Icons.search),
                onPressed: (){

                    if (g_searchTag == " " && _scanBarcode == '-1') {
                      g_searchTag = " ";
                    } else if (_scanBarcode != '-1' && _scanBarcode != ' '){
                      g_searchTag = _scanBarcode;
                    }

                    final route = MaterialPageRoute(builder: (context) => const TagListScreen());
                    Navigator.pushReplacement(context, route);
                },
                label: const Text ('Search')
            ),
          ],
        ),
      ),
    );
  }
}
