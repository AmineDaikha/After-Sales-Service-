import 'client.dart';
import 'collaborator.dart';
import 'file_note.dart';

class Note {
  static final String TEXT = 'txt';

  Client? client;
  String type;
  String? title;
  String? text;
  List<FileNote> files = [];
  String? collaboratorsTxt = '';
  List<Collaborator> collaborators = [];

  Note({
    required this.type,
    this.title,
    this.text,
    this.collaboratorsTxt,
    this.client
  });
}
