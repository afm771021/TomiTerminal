
import 'package:tomi_terminal_audit2/providers/db_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/tag_model.dart';

class TagListProvider extends ChangeNotifier{

   List<TagModel> tags = [];

   loadTags (String searchTag) async{
     final tags = await DBProvider.db.getTagsToAudit(searchTag);
     this.tags = [...tags];
     //print('TagListProvider');
     notifyListeners();
   }
}
