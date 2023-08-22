import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tomi_terminal_audit2/util/globalvariables.dart';
import '../models/jobGetIndicators_model.dart';
import '../providers/job_indicators_provider.dart';

class CardTable extends StatefulWidget {
  const CardTable({Key? key}) : super(key: key);

  @override
  State<CardTable> createState() => _CardTableState();
}

class _CardTableState extends State<CardTable> {
  var currencyFormatter = NumberFormat('#,##0.00', 'es_MX');

  @override
  Widget build(BuildContext context) {

    final indicatorsProvider = Provider.of<JobIndicatorsProvider>(context, listen: true);
    indicatorsProvider.loadIndicators();
    final jobIndicators = indicatorsProvider.jobGetIndicators;

    return Column(
      children: [
        Table(
          children:  [
            if (g_customerId == 1)
              TableRow(
                  children: [
                    _SingleCard(color:Colors.teal,
                      icon: Icons.bar_chart,
                      text: 'Total Departments',
                      text2: jobIndicators.totalDepartments.round().toString(),
                      text3: '',),
                    _SingleCard(color:Colors.lightBlueAccent,
                      icon: Icons.checklist,
                      text: 'Released Departments',
                      text2:  jobIndicators.releasedDepartments.round().toString(),
                      text3: '',),
                  ]
              ),
            if (g_customerId == 1)
              TableRow(
                  children: [
                    _SingleCard(color:Colors.purple,
                      icon: Icons.bar_chart,
                      text: 'In Progress Departments',
                      text2: jobIndicators.inProgressDepartments.round().toString(),
                      text3: '',),
                    _SingleCard(color:Colors.black38,
                      icon: Icons.checklist,
                      text: 'Completed Departments',
                      text2:  jobIndicators.completedDepartments.round().toString(),
                      text3: '',),
                  ]
              ),
              TableRow(
                children: [
                  _SingleCard(color:Colors.orangeAccent,
                              icon: Icons.bar_chart,
                              text: 'Total Tags',
                              text2: jobIndicators.totalTags.round().toString(),
                              text3: '',),
                  _SingleCard(color:Colors.pinkAccent,
                              icon: Icons.checklist,
                              text: 'Counted Tags',
                              text2:  jobIndicators.countedTags.round().toString(),
                              text3: 'Progress: ${(jobIndicators.countedTags * 100 / jobIndicators.totalTags ).toStringAsFixed(1)}%',),
                ]
              ),
            TableRow(
                children: [
                  _SingleCard(color:Colors.green,
                    icon: Icons.attach_money,
                    text: 'Counted amount',
                    text2: '\$ ${currencyFormatter.format(jobIndicators.totalAmount)}',
                    text3: 'Progress in pieces: ${jobIndicators.totalQuantity.round()}',
                  ),
                  _SingleCard(color:Colors.lightBlueAccent,
                    icon: Icons.rule,
                    text: 'Pending Tags',
                    text2: jobIndicators.missingTags.round().toString(),
                    text3: '',),
                ]
            ),
            if (g_customerId == 6)
              TableRow(
                  children: [
                    _SingleCard(color:Colors.purple,
                      icon: Icons.checklist,
                      text: 'Audited Tags',
                      text2: jobIndicators.totalAuditedTags.round().toString(),
                      text3: '',),
                    _SingleCard(color:Colors.black38,
                      icon: Icons.punch_clock_outlined,
                      text: 'Audit tags in progress',
                      text2: jobIndicators.auditInProgressTags.round().toString(),
                      text3: '',),
                  ]
              ),
            TableRow(
                children: [
                  _SingleCard(color:Colors.orangeAccent,
                    icon: Icons.bar_chart,
                    text: 'Total pieces',
                    text2: jobIndicators.totalQuantity.round().toString(),
                    text3: '',),
                  _SingleCard(color:Colors.orangeAccent,
                    icon: Icons.punch_clock_outlined,
                    text: 'Pieces per hour',
                    text2: (jobIndicators != null)
                        ?( jobIndicators.totalHours > 0 )
                          ? ( jobIndicators.totalQuantity / jobIndicators.totalHours ).round().toString()
                          :'0'
                        :'0',
                    text3: 'Total hours: ${jobIndicators.totalHours.toStringAsFixed(1)}',
                  ),
                ]
            ),
          ],
        ),
        Table(
          children:   [
            TableRow(
              children : [
                _SingleCardDepartmants(
                  color:Colors.green,
                  icon: Icons.bar_chart,
                  text: 'Advance of departments',
                  indicators: jobIndicators,
                ),
              ]
            )
          ],
        ),

      ],
    );
  }
}

class _SingleCardDepartmants extends StatelessWidget {
  const _SingleCardDepartmants({Key? key, required this.icon, required this.color, required this.text, required this.indicators}) : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final JobGetIndicators indicators;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(62, 66, 107, 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          CircleAvatar(
            backgroundColor: color,
            radius: 30,
            child: Icon (icon, size: 40, color: Colors.white,),
          ),
          const SizedBox(height: 10,),
          Text (text ,style: const TextStyle(color: Colors.white, fontSize: 12),),
          const Divider(),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (indicators != null)
                  ?indicators.departments.length
                  :0,
              itemBuilder: (context, index) =>
                     ListTile(
                    title:
                          Table(
                            children:   [
                              TableRow(
                                  children : [
                                    Center(
                                      child: Text((indicators != null)
                                          ?'${indicators.departments[index].departmentId} '
                                          :'',style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                    ),
                                    Text((indicators != null)
                                        ?'${indicators.departments[index].departmentName} '
                                        :'',style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    Center(
                                      child: Text((indicators != null)
                                          ?'${indicators.departments[index].advance.toStringAsFixed(1)}%'
                                          :'',style: const TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    )
                                  ],
                              ),
                            ],
                          ),

                     ),
                         /*subtitle: Text((indicators != null)
                             ? '${indicators.departments[index].advance.toStringAsFixed(1)}%'
                             :'' ,style: const TextStyle(color: Colors.white, fontSize: 14),
                         )*/
                     )
        ],
      ),
    );
  }
}

class _SingleCard extends StatelessWidget {
  const _SingleCard({Key? key, required this.icon, required this.color, required this.text, required this.text2, required this.text3}) : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final String text2;
  final String text3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(62, 66, 107, 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          CircleAvatar(
            backgroundColor: color,
            radius: 30,
            child: Icon (icon, size: 40, color: Colors.white,),
          ),
          const SizedBox(height: 10,),
          Text (text ,style: const TextStyle(color: Colors.white, fontSize: 12),),
          Text (text2 ,style: const TextStyle(color: Colors.white, fontSize: 18),),
          const Divider(),
          Text (text3 ,style: const TextStyle(color: Colors.white, fontSize: 12),)
        ],
      ),
    );
  }
}
