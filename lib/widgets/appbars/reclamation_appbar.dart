import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:sav_app/constants/urls.dart';
import 'package:sav_app/screens/reclamation_page/add_reclamation_page.dart';
import 'package:sav_app/utils/routers.dart';
import 'package:sav_app/widgets/dialog_filtred_opportunities.dart';

class ReclamationsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReclamationsAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white, // Set icon color to white
      ),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        IconButton(
            onPressed: () {
              PageNavigator(ctx: context).nextPage(page: AddReclamationPage());
            },
            icon: Icon(
              Icons.add,
              color: Colors.white,
            )),
        IconButton(
            onPressed: () {
              //_showDatePicker(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FiltredOpportunitiesDialog();
                },
              );
            },
            icon: Icon(
              Icons.sort,
              color: Colors.white,
            ))
      ],
      title: Container(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réclamations',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Du : ${DateFormat('yyyy-MM-dd').format(AppUrl.filtredOpporunity.date)}, de : ${AppUrl.filtredOpporunity.collaborateur!.userName}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
            ),
            Text(
              'Au : ${DateFormat('yyyy-MM-dd').format(AppUrl.filtredOpporunity.dateEnd)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
            ),
            Text(
              'Pipeline : SAV', // ${AppUrl.filtredOpporunity.pipeline!.name}
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ],
        ),
      ),
      // bottom: PreferredSize(
      //   preferredSize: Size.fromHeight(20.0), // Adjust this as needed
      //   child: Container(
      //     color: Colors.white,
      //     child: TabBar(
      //         isScrollable: true,
      //         labelStyle: TextStyle(
      //             fontWeight: FontWeight.bold,
      //             fontSize: 16,
      //             color: Theme.of(context).primaryColor),
      //         labelColor: Theme.of(context).primaryColor,
      //         unselectedLabelColor: Colors.grey,
      //         indicatorColor: Theme.of(context).primaryColor,
      //         indicator: BoxDecoration(
      //             border: Border(
      //                 bottom: BorderSide(
      //           width: 2.5,
      //           color: Theme.of(context).primaryColor,
      //         ))),
      //         tabs: [
      //           Tab(
      //             text: 'Réclamations',
      //           ),
      //           // Tab(
      //           //   text: 'Interventions',
      //           // ),
      //           Tab(//Attachments
      //             text: 'Documents joints',
      //           ),
      //           Tab(
      //             text: 'Procès-verbaux',
      //           ),
      //         ]),
      //   ),
      // ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime selectedDate = AppUrl.selectedDate;
    DateTime? pickedMonth = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedMonth != null && pickedMonth != selectedDate) {
      // A month was selected
      AppUrl.selectedDate = pickedMonth;
      print('Selected Month: ${DateFormat.yMMMM().format(pickedMonth)}');
      print(
          'Selected Week of the Month: ${_getWeekOfMonth(pickedMonth)}'); // Assaire / Tounée
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  int _getWeekOfMonth(DateTime date) {
    return (date.day + DateTime(date.year, date.month, 1).weekday - 2) ~/ 7 + 1;
  }

  Future<void> _showPickerDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select an Option'),
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Select Month'),
              onTap: () {
                Navigator.pop(context);
                _showDatePicker(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text('Select Week'),
              onTap: () {
                Navigator.pop(context);
                _showDatePicker(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(50);
}
