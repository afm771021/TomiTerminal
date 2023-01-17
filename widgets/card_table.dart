import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
            TableRow(
              children: [
                _SingleCard(color:Colors.orangeAccent,
                            icon: Icons.bar_chart,
                            text: 'Total Tags',
                            text2: (jobIndicators != null)
                                    ? jobIndicators.totalTags.round().toString()
                                    : '0',
                            text3: '',),
                _SingleCard(color:Colors.pinkAccent,
                            icon: Icons.checklist,
                            text: 'Counted Tags',
                            text2: (jobIndicators != null)
                                    ? jobIndicators.countedTags.round().toString()
                                    : '0',
                            text3: 'Progress: ${(jobIndicators != null)
                                                ? jobIndicators.totalTags == 0
                                                    ?'0'
                                                    :(jobIndicators.countedTags * 100 / jobIndicators.totalTags ).toStringAsFixed(1)
                                                :'0'}%',),
              ]
            ),
            TableRow(
                children: [
                  _SingleCard(color:Colors.green,
                    icon: Icons.attach_money,
                    text: 'Counted amount',
                    text2: '\$ ${(jobIndicators != null)
                                ? currencyFormatter.format(jobIndicators.totalAmount)
                                : '0'}',
                    text3: 'Progress in pieces: ${(jobIndicators != null)
                                                    ?jobIndicators.totalQuantity.round()
                                                    :'0'}',),
                  _SingleCard(color:Colors.lightBlueAccent,
                    icon: Icons.rule,
                    text: 'Pending Tags',
                    text2: (jobIndicators != null)
                            ?jobIndicators.missingTags.round().toString()
                            :'0',
                    text3: '',),
                ]
            ),
            TableRow(
                children: [
                  _SingleCard(color:Colors.purple,
                    icon: Icons.checklist,
                    text: 'Audited Tags',
                    text2: (jobIndicators != null)
                            ?jobIndicators.totalAuditedTags.round().toString()
                            :'0',
                    text3: '',),
                  _SingleCard(color:Colors.black38,
                    icon: Icons.punch_clock_outlined,
                    text: 'Audit tags in progress',
                    text2: (jobIndicators != null)
                            ?jobIndicators.auditInProgressTags.round().toString()
                            :'0',
                    text3: '',),
                ]
            ),
            TableRow(
                children: [
                  _SingleCard(color:Colors.orangeAccent,
                    icon: Icons.bar_chart,
                    text: 'Total pieces',
                    text2: (jobIndicators != null)
                            ?jobIndicators.totalQuantity.round().toString()
                            :'0',
                    text3: '',),
                  _SingleCard(color:Colors.orangeAccent,
                    icon: Icons.punch_clock_outlined,
                    text: 'Pieces per hour',
                    text2: (jobIndicators != null)
                            ?( jobIndicators.totalHours > 0 )
                                ? ( jobIndicators.totalQuantity / jobIndicators.totalHours ).round().toString()
                                :'0'
                            :'0',
                    text3: 'Total hours: ${(jobIndicators != null)
                                          ?jobIndicators.totalHours.toStringAsFixed(1)
                                          :'0'}',),
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
