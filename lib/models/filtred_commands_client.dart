

import 'package:sav_app/models/collaborator.dart';
import 'package:sav_app/models/team.dart';

import 'client.dart';
import 'pipeline.dart';
import 'step_pip.dart';

class FiltredCommandsClient {
  DateTime date;
  DateTime dateEnd;
  Team? team;
  Collaborator? collaborateur;
  Pipeline? pipeline;
  StepPip? stepPip;
  Client? client;
  List<Client> clients = [];
  bool allCollaborators = true;

  FiltredCommandsClient(
      {required this.date,
      required this.dateEnd,
      this.team,
      this.collaborateur,
      this.pipeline,
      this.stepPip});
}
