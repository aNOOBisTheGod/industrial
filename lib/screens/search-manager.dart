// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:industrial/extensions.dart';
// import 'package:industrial/screens/search-people.dart';

// class SearchManager extends StatefulWidget {
//   const SearchManager({super.key});

//   @override
//   State<SearchManager> createState() => _SearchManagerState();
// }

// class _SearchManagerState extends State<SearchManager> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: SingleChildScrollView(
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             SizedBox(
//               height: 60,
//             ),
//             Center(
//               child: Text(
//                 "Search for".tr,
//                 style: context.largeTextTheme().apply(fontSizeDelta: 20),
//               ),
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Get.to(SearchPeoplePage(), transition: Transition.fadeIn);
//                   },
//                   child: SizedBox(
//                       width: context.getWidth() * .5 - 21,
//                       height: context.getHeight() * .3,
//                       child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Stack(
//                             children: [
//                               Image.asset(
//                                 'assets/images/search/people.jpg',
//                                 height: double.infinity,
//                                 fit: BoxFit.fitHeight,
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment(0.8, 1),
//                                   colors: <Color>[
//                                     Colors.transparent,
//                                     Colors.deepPurple
//                                   ],
//                                   tileMode: TileMode.mirror,
//                                 )),
//                               ),
//                               Positioned.fill(
//                                 child: Align(
//                                   alignment: Alignment.bottomLeft,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       "People".tr,
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 20),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ))),
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 SizedBox(
//                     width: context.getWidth() * .5 - 21,
//                     height: context.getHeight() * .3,
//                     child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Stack(
//                           children: [
//                             Image.asset(
//                               'assets/images/search/community.jpg',
//                               height: double.infinity,
//                               fit: BoxFit.fitHeight,
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment(0.8, 1),
//                                 colors: <Color>[
//                                   Colors.transparent,
//                                   Colors.deepOrange
//                                 ],
//                                 tileMode: TileMode.mirror,
//                               )),
//                             ),
//                             Positioned.fill(
//                               child: Align(
//                                 alignment: Alignment.bottomLeft,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     "Community".tr,
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 20),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ))),
//               ],
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Row(
//               children: [
//                 SizedBox(
//                     width: context.getWidth() * .5 - 21,
//                     height: context.getHeight() * .3,
//                     child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Stack(
//                           children: [
//                             Image.asset(
//                               'assets/images/search/post.jpg',
//                               height: double.infinity,
//                               fit: BoxFit.fitHeight,
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment(0.8, 1),
//                                 colors: <Color>[Colors.transparent, Colors.red],
//                                 tileMode: TileMode.mirror,
//                               )),
//                             ),
//                             Positioned.fill(
//                               child: Align(
//                                 alignment: Alignment.bottomLeft,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     "Post".tr,
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 20),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ))),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 SizedBox(
//                     width: context.getWidth() * .5 - 21,
//                     height: context.getHeight() * .3,
//                     child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Stack(
//                           children: [
//                             Image.asset(
//                               'assets/images/search/job.jpg',
//                               height: double.infinity,
//                               fit: BoxFit.fitHeight,
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment(0.8, 1),
//                                 colors: <Color>[
//                                   Colors.transparent,
//                                   const Color.fromARGB(255, 216, 185, 44)
//                                 ], // Gradient from https://learnui.design/tools/gradient-generator.html
//                                 tileMode: TileMode.mirror,
//                               )),
//                             ),
//                             Positioned.fill(
//                               child: Align(
//                                 alignment: Alignment.bottomLeft,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     "Job".tr,
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 20),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ))),
//               ],
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Center(
//               child: SizedBox(
//                 width: context.getWidth() * .5,
//                 child: Text(
//                   "Or search for our new applications in stores!",
//                   style: TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               ),
//             )
//           ]),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:industrial/extensions.dart';
import 'package:industrial/screens/search-job.dart';
import 'package:industrial/screens/search-people.dart';
import 'package:industrial/screens/search-post.dart';

class SearchManager extends StatelessWidget {
  const SearchManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          height: 40,
        ),
        Center(
          child: Text(
            "Search for".tr,
            style: context.largeTextTheme().apply(fontSizeDelta: 20),
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Get.to(SearchPeoplePage(), transition: Transition.fadeIn);
            },
            child: SizedBox(
              width: context.getWidth() * .5,
              height: 50,
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(
                    width: 10,
                  ),
                  Text("People".tr)
                ],
              ),
            )),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              Get.to(SearchPostPage(), transition: Transition.fadeIn);
            },
            child: SizedBox(
              width: context.getWidth() * .5,
              height: 50,
              child: Row(
                children: [
                  Icon(Icons.photo),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Post".tr)
                ],
              ),
            )),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              Get.to(SearchJobPage(), transition: Transition.fadeIn);
            },
            child: SizedBox(
              width: context.getWidth() * .5,
              height: 50,
              child: Row(
                children: [
                  Icon(Icons.work),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Job".tr)
                ],
              ),
            ))
      ]),
    );
  }
}
