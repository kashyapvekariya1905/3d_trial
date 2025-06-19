// pubspec.yaml dependencies needed:
/*
dependencies:
  flutter:
    sdk: flutter
  arkit_plugin: ^0.10.0
  permission_handler: ^10.4.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
*/

import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Distance Measuring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
      appBar: AppBar(
        title: Text('AR Distance Measuring'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'AR Distance Measuring App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tap objects to measure distance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _openARCamera();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Open AR Camera',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openARCamera() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    // Navigate to AR screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ARScreen()),
    );
  }
}

class ARScreen extends StatefulWidget {
  @override
  _ARScreenState createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  late ARKitController arkitController;
  String distanceText = "Tap on an object to measure distance";
  
  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
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
          // AR View
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    
    // Add tap gesture recognizer
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      _handleTap(ar);
    };
  }

  void _handleTap(List<ARKitTestResult> results) {
    if (results.isNotEmpty) {
      // Get the first hit test result
      final result = results.first;
      
      // Get the world position where user tapped
      final worldPosition = result.worldTransform.getColumn(3);
      
      // Calculate distance from camera (which is at origin 0,0,0) to the tapped point
      final distance = _calculateDistance(
        vector.Vector3(0, 0, 0), // Camera position (origin)
        vector.Vector3(worldPosition.x, worldPosition.y, worldPosition.z)
      );
      
      // Add a visual marker at the tapped location
      _addMarkerAtPosition(worldPosition);
      
      // Update distance text
      setState(() {
        distanceText = "Distance: ${distance.toStringAsFixed(2)} meters";
      });
      
      print("Hit test result:");
      print("World Position: ${worldPosition.x}, ${worldPosition.y}, ${worldPosition.z}");
      print("Distance: ${distance.toStringAsFixed(2)} meters");
    }
  }

  double _calculateDistance(vector.Vector3 point1, vector.Vector3 point2) {
    return (point2 - point1).length;
  }

  void _addMarkerAtPosition(vector.Vector4 position) {
    // Create a small sphere as a marker
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.red),
    );
    final sphere = ARKitSphere(
      radius: 0.02,
      materials: [material],
    );
    
    final node = ARKitNode(
      geometry: sphere,
      position: vector.Vector3(position.x, position.y, position.z),
    );
    
    arkitController.add(node);
  }
}

/*
EXPLANATION OF KEY CONCEPTS:

1. POSE MATRIX:
   - A 4x4 transformation matrix that describes the position and orientation of objects in 3D space
   - Contains translation (position) and rotation information
   - In ARKit, it represents where the camera is in the real world and how it's oriented
   - The worldTransform property gives us this matrix for hit test results

2. HIT TESTING:
   - A technique to determine what 3D object or surface the user is pointing at
   - When user taps the screen, we cast a ray from the camera through the tap point
   - Hit testing finds where this ray intersects with real-world surfaces
   - ARKit automatically detects planes and surfaces for hit testing

3. DISTANCE CALCULATION:
   - We use the 3D coordinates from hit testing
   - Calculate Euclidean distance using the formula: √[(x₂-x₁)² + (y₂-y₁)² + (z₂-z₁)²]
   - Camera is typically at origin (0,0,0) in ARKit coordinate system
   - Distance is measured in meters

HOW THE CODE WORKS:
1. User taps "Open AR Camera" button
2. App requests camera permission
3. ARKit starts and shows camera feed
4. User taps on screen
5. Hit testing finds the 3D position of the tap
6. We calculate distance from camera to that point
7. A red sphere marker is placed at the tapped location
8. Distance is displayed on screen
*/