import 'client.dart';
import 'collaborator.dart';
import 'file_note.dart';

class Document {
  Client? client;
  String type;
  String? path;
  String? name;
  DateTime dateCreate;
  var res = null;

  Document(
      {required this.type,
      this.path,
      this.name,
      required this.dateCreate,
      this.client});
}
