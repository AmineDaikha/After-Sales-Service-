import 'package:flutter/material.dart';
import 'package:sav_app/models/notif.dart';

class NotifProvider extends ChangeNotifier {
  List<Notif> notifList = [];

  int countNotif = 0;
}
