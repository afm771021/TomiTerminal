import 'package:flutter/material.dart';

import '../widgets/background.dart';
import '../widgets/card_table.dart';
import '../widgets/tomiterminal_menu.dart';

class JobDashboardScreen extends StatelessWidget {
  const JobDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const TomiTerminalMenu(),
      body: Stack(
        children: [
           const Background(),
          _DashboardBody(),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          CardTable(),
        ],
      )
    );
  }
}

