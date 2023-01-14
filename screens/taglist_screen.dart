import 'package:tomi_terminal_audit2/providers/db_provider.dart';
import 'package:tomi_terminal_audit2/providers/tag_list_provider.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/tomiterminal_menu.dart';
import 'screens.dart';

class TagListScreen extends StatefulWidget {
  const TagListScreen ({Key? key}) : super(key: key);

  @override
  State<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends State<TagListScreen> {
  @override
  Widget build(BuildContext context) {

    final tagsListProvider = Provider.of<TagListProvider>(context, listen: true);
    tagsListProvider.loadTags(g_searchTag);
    final tags = tagsListProvider.tags;
    // VALIDAR SI TAGS ES VACIO MOSTRAR ERROR

    return  Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        elevation: 10,
        //backgroundColor: Colors.cyan,
      ),
      drawer: const TomiTerminalMenu(),
      body: tags.isNotEmpty ?ListView.builder(
          itemBuilder: (context,index) => Card(
            child:ListTile(
              leading:  const Icon( Icons.sticky_note_2, color: Colors.orange, size: 40,),
              title: Text('Tag ${tags[index].tag_number.round()}'),
              subtitle: Text('range: ${tags[index].range['tagFrom'].round().toString()} - ${tags[index].range['tagTo'].round().toString()}'),
              //textColor: Colors.indigo,
              trailing: const Icon (Icons.download_for_offline,
                  color: Colors.green, size: 40,),
              onTap: () async {
                final tag = tags[index];
                setState(() {
                  g_tagNumber = tag.tag_number.round();
                });
                DBProvider.db.downloadTagsDetailToAudit();
                Navigator.pushReplacementNamed(context, 'TagListDetails');
              },
            ),
          ),
          itemCount: tags.length)
        : Padding(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
          child: Column(
            children:  [
              const Center(child: Text('No results found',style: TextStyle(fontSize: 24),)),
              ElevatedButton(
                onPressed: (){
                  final route = MaterialPageRoute(builder: (context) => const TagSearchScreen());
                  Navigator.pushReplacement(context, route);
                },
                child: Container(
                padding: const EdgeInsets.all(8),
                child:  const Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),)
            ],
          ),
        )
    );
  }
}

