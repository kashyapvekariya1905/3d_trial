// import 'package:flutter/material.dart';
// import 'package:arkit_plugin/arkit_plugin.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AR Distance Measuring App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('AR Distance Measuring'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.camera_alt,
//               size: 100,
//               color: Colors.blue,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'AR Distance Measuring App',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Tap objects to measure distance',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 _openARCamera();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(width: 10),
//                   Text(
//                     'Open AR Camera',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openARCamera() async {
//     // Check camera permission
//     var status = await Permission.camera.status;
//     if (!status.isGranted) {
//       await Permission.camera.request();
//     }

//     // Navigate to AR screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ARScreen()),
//     );
//   }
// }

// class ARScreen extends StatefulWidget {
//   @override
//   _ARScreenState createState() => _ARScreenState();
// }

// class _ARScreenState extends State<ARScreen> {
//   late ARKitController arkitController;
//   String distanceText = "Tap on an object to measure distance";

//   @override
//   void dispose() {
//     arkitController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('AR Distance Measuring'),
//         backgroundColor: Colors.black87,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           ARKitSceneView(
//             onARKitViewCreated: onARKitViewCreated,
//             enableTapRecognizer: true,
//           ),
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 distanceText,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 50,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 'Tap anywhere on the screen to measure distance to that point',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void onARKitViewCreated(ARKitController arkitController) {
//     this.arkitController = arkitController;

//     // Add tap gesture recognizer
//     this.arkitController.onARTap = (List<ARKitTestResult> ar) {
//       _handleTap(ar);
//     };
//   }

//   void _handleTap(List<ARKitTestResult> results) {
//     if (results.isNotEmpty) {
//       // Get the first hit test result
//       final result = results.first;

//       // Get the world position where user tapped
//       final worldPosition = result.worldTransform.getColumn(3);

//       // Calculate distance from camera (which is at origin 0,0,0) to the tapped point
//       final distance = _calculateDistance(
//         vector.Vector3(0, 0, 0), // Camera position (origin)
//         vector.Vector3(worldPosition.x, worldPosition.y, worldPosition.z)
//       );

//       // Add a visual marker at the tapped location
//       _addMarkerAtPosition(worldPosition);

//       // Update distance text
//       setState(() {
//         distanceText = "Distance: ${distance.toStringAsFixed(2)} meters";
//       });

//       print("Hit test result:");
//       print("World Position: ${worldPosition.x}, ${worldPosition.y}, ${worldPosition.z}");
//       print("Distance: ${distance.toStringAsFixed(2)} meters");
//     }
//   }

//   double _calculateDistance(vector.Vector3 point1, vector.Vector3 point2) {
//     return (point2 - point1).length;
//   }

//   void _addMarkerAtPosition(vector.Vector4 position) {
//     // Create a small sphere as a marker
//     final material = ARKitMaterial(
//       diffuse: ARKitMaterialProperty.color(Colors.red),
//     );
//     final sphere = ARKitSphere(
//       radius: 0.02,
//       materials: [material],
//     );

//     final node = ARKitNode(
//       geometry: sphere,
//       position: vector.Vector3(position.x, position.y, position.z),
//     );

//     arkitController.add(node);
//   }
// }













import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:path_provider/path_provider.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR Distance Measuring App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR Distance Measuring')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('AR Distance Measuring App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Tap objects to measure distance', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _openARCamera,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vrpano, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Open AR Camera', style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openARCamera() async {
    if (!await Permission.camera.isGranted) {
      await Permission.camera.request();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ARScreen()));
  }
}

class ARScreen extends StatefulWidget {
  @override
  _ARScreenState createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  late ARKitController arkitController;
  String distanceText = "Tap to measure distance";
  File? logFile;

  @override
  void initState() {
    super.initState();
    _initializeLogFile();
  }

  Future<void> _initializeLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/logs.txt';
    logFile = File(path);
    if (!(await logFile!.exists())) {
      await logFile!.create(recursive: true);
    }
    await logFile!.writeAsString("Starting to save logs\n", mode: FileMode.append);
    print("Log file created at: ${logFile!.path}");
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController.onARTap = (List<ARKitTestResult> results) {
      _handleTap(results);
    };
  }

//   void _handleTap(List<ARKitTestResult> results) async {
//     if (results.isNotEmpty && logFile != null) {
//       final result = results.first;
//       final transform = result.worldTransform;
//       final worldPosition = transform.getColumn(3);

//       final distance = _calculateDistance(
//         vector.Vector3(0, 0, 0),
//         vector.Vector3(worldPosition.x, worldPosition.y, worldPosition.z),
//       );

//       _addMarkerAtPosition(worldPosition);

//       setState(() {
//         distanceText = "Distance: ${distance.toStringAsFixed(2)} meters";
//       });

//       final log = '''
// -----Tap-----
// World Position: (${worldPosition.x.toStringAsFixed(3)}, ${worldPosition.y.toStringAsFixed(3)}, ${worldPosition.z.toStringAsFixed(3)})
// Distance: ${distance.toStringAsFixed(3)} meters
// Transform:
// [${transform.getRow(0)}]
// [${transform.getRow(1)}]
// [${transform.getRow(2)}]
// [${transform.getRow(3)}]
// -------------------------
// ''';

//       await logFile!.writeAsString(log, mode: FileMode.append);
//       print("Log saved to: ${logFile!.path}");
//     }
//   }


void _handleTap(List<ARKitTestResult> results) async {
  if (results.isNotEmpty && logFile != null) {
    final result = results.first;
    final transform = result.worldTransform;
    final worldPosition = transform.getColumn(3);

    final dx = worldPosition.x;
    final dy = worldPosition.y;
    final dz = worldPosition.z;
    final distance = sqrt(dx * dx + dy * dy + dz * dz);

    _addMarkerAtPosition(worldPosition);

    setState(() {
      distanceText = "Distance: ${distance.toStringAsFixed(2)} meters";
    });

    final log = '''
-----Tap-----
World Position: (${dx.toStringAsFixed(3)}, ${dy.toStringAsFixed(3)}, ${dz.toStringAsFixed(3)})
Distance: ${distance.toStringAsFixed(3)} meters
Transform:
[${transform.getRow(0)}]
[${transform.getRow(1)}]
[${transform.getRow(2)}]
[${transform.getRow(3)}]
-------------------------
''';

    await logFile!.writeAsString(log, mode: FileMode.append);
    print("Log written.");
  }
}


  // double _calculateDistance(vector.Vector3 a, vector.Vector3 b) {
  //   return (b - a).length;
  // }

  void _addMarkerAtPosition(vector.Vector4 position) {
    final material = ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.red));
    final sphere = ARKitSphere(radius: 0.02, materials: [material]);
    final node = ARKitNode(
      geometry: sphere,
      position: vector.Vector3(position.x, position.y, position.z),
    );
    arkitController.add(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Distance Measuring'),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ARKitSceneView(
            onARKitViewCreated: onARKitViewCreated,
            enableTapRecognizer: true,
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                distanceText,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Tap anywhere on the screen to measure distance to that point',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
