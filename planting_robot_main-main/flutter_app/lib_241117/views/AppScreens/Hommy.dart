import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Column(
        children: [
          // Top half-circle container with an icon inside a small circle
          Stack(
            alignment: Alignment.center,
            children: [
              // Custom painter for the semi-circle background
              SizedBox(
                height: 170,
                width: double.infinity,
                child: CustomPaint(
                  painter: HalfCirclePainter(),
                ),
              ),
              // Small circle avatar in the center of the semi-circle
              Positioned(
                top: 75, // Adjust position to center it in the semi-circle
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(
                    Icons.science,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: const [
                TestResultCard(
                  testName: 'Blood Count',
                  result: 'Very good',
                  color: Colors.green,
                  icon: Icons.bloodtype,
                ),
                TestResultCard(
                  testName: 'Enzyme Test',
                  result: 'Medium',
                  color: Colors.orange,
                  icon: Icons.science,
                ),
                TestResultCard(
                  testName: 'Cholesterol Test',
                  result: 'Very good',
                  color: Colors.green,
                  icon: Icons.healing,
                ),
                TestResultCard(
                  testName: 'X-ray',
                  result: 'Medium',
                  color: Colors.orange,
                  icon: Icons.radio,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Custom painter class to draw the half-circle
class HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[200]!
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width / 2, size.height - 200, size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TestResultCard extends StatelessWidget {
  final String testName;
  final String result;
  final Color color;
  final IconData icon;

  const TestResultCard({super.key, 
    required this.testName,
    required this.result,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(testName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          result,
          style: TextStyle(color: color, fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () {
            // Add download functionality here
          },
        ),
      ),
    );
  }
}
