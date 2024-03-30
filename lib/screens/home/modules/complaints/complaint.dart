import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:housingsociety/screens/home/modules/complaints/addcomplaint.dart';
import 'package:housingsociety/screens/home/modules/complaints/piechart.dart';
import 'package:housingsociety/screens/home/modules/complaints/realtimecomplaintupdate.dart';
import 'package:housingsociety/shared/constants.dart';
// import 'package:rake/rake.dart';

class Complaint extends StatefulWidget {
  static const String id = 'complaint';

  @override
  _ComplaintState createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> with TickerProviderStateMixin {
  Map<String, double> keywords = {};
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        actions: [
          TextButton(
            onPressed: () async {
              // Reset keywords
              keywords = {};

              // Get complaints from Firestore
              QuerySnapshot<Map<String, dynamic>> querySnapshot =
                  await FirebaseFirestore.instance
                      .collection('module_complaint')
                      .get();

              // Extract keywords from each complaint
              querySnapshot.docs.forEach((document) {
                List<String> documentKeywords =
                    extractKeywords(document.data()['description']);
                for (String keyword in documentKeywords) {
                  // Exclude certain keywords
                  if (!shouldExcludeKeyword(keyword)) {
                    keywords[keyword] = (keywords[keyword] ?? 0) + 1;
                  }
                }
              });

              // Check if there are complaints to analyze
              if (keywords.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: Text(
                        'There should be at least one complaint to analyze'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Ok'),
                      )
                    ],
                  ),
                );
              } else {
                // Navigate to the page to display the analysis
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PieChartComplaints(
                      dataMap: keywords,
                    ),
                  ),
                );
              }
              print(keywords);
            },
            child: Text(
              'Analyze',
              style: TextStyle(color: kAmaranth),
            ),
          ),

          /// todo: old logic of ranking the word
          // TextButton(
          //   onPressed: () async {
          //     keywords = {};
          //     final rake = Rake();
          //     await FirebaseFirestore.instance
          //         .collection('module_complaint')
          //         .get()
          //         .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
          //       querySnapshot.docs.forEach((document) {
          //         List documentKeywords =
          //             rake.rank(document.data()['description']);
          //         for (String keyword in documentKeywords) {
          //           if (keyword.endsWith('ing') ||
          //               keyword == 'wing' ||
          //               keyword.endsWith('ly'))
          //             continue;
          //           else {
          //             if (keywords.containsKey(keyword)) {
          //               keywords[keyword] += 1;
          //             } else {
          //               keywords[keyword] = 1;
          //             }
          //           }
          //         }
          //       });
          //     });
          //     keywords.isEmpty
          //         ? showDialog(
          //             context: context,
          //             builder: (BuildContext context) => AlertDialog(
          //               content: Text(
          //                   'There should be atleast one complaint to analyse'),
          //               actions: [
          //                 TextButton(
          //                   onPressed: () {
          //                     Navigator.pop(context);
          //                   },
          //                   child: Text('Ok'),
          //                 )
          //               ],
          //             ),
          //           )
          //         : Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => PieChartComplaints(
          //                 dataMap: keywords,
          //               ),
          //             ),
          //           );
          //     print(keywords);
          //   },
          //   child: Text(
          //     'Analyze',
          //     style: TextStyle(color: kAmaranth),
          //   ),
          // ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Open',
            ),
            Tab(
              text: 'On Hold',
            ),
            Tab(
              text: 'Closed',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddComplaint.id);
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RealTimeComplaintUpdate(
            complaintStatus: 'open',
          ),
          RealTimeComplaintUpdate(
            complaintStatus: 'on hold',
          ),
          RealTimeComplaintUpdate(
            complaintStatus: 'closed',
          ),
        ],
      ),
    );
  }
}

/// Custom extract words logic
List<String> extractKeywords(String description) {
  // Split the description into words
  List<String> words = description.toLowerCase().split(RegExp(r'\W+'));

  // Return unique words as keywords
  return words.toSet().toList();
}

bool shouldExcludeKeyword(String keyword) {
  // Define keywords to exclude
  List<String> excludedKeywords = ['ing', 'wing', 'ly'];

  // Check if the keyword should be excluded
  return excludedKeywords.contains(keyword) ||
      keyword.isEmpty; // Exclude empty strings
}
