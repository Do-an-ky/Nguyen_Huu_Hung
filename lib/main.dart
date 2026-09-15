import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const DoAnKyApp());
}

class DoAnKyApp extends StatelessWidget {
  const DoAnKyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ Án Kỳ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const FallDetectionScreen(),
    );
  }
}

class FallDetectionScreen extends StatefulWidget {
  const FallDetectionScreen({super.key});

  @override
  State<FallDetectionScreen> createState() => _FallDetectionScreenState();
}

class _FallDetectionScreenState extends State<FallDetectionScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('status');

  String currentState = "IDLE";
  double accTotal = 1.00;
  double gyroTotal = 0.0;
  double tiltAngle = 0.0;
  bool hasReceivedData = false;

  @override
  void initState() {
    super.initState();
    _dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          currentState = data['state']?.toString() ?? currentState;
          accTotal = (data['accTotal'] as num?)?.toDouble() ?? accTotal;
          gyroTotal = (data['gyroTotal'] as num?)?.toDouble() ?? gyroTotal;
          tiltAngle = (data['tiltAngle'] as num?)?.toDouble() ?? tiltAngle;
          hasReceivedData = true;
        });
      }
    }, onError: (error) {
      debugPrint("Lỗi đọc Firebase: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAlarm = currentState == "ALARM";
    bool isChecking = currentState == "CHECKING";

    Color statusColor = isAlarm
        ? Colors.red
        : (isChecking ? Colors.orange : Colors.green);

    String statusText = isAlarm
        ? "CẢNH BÁO: TÉ NGÃ THẬT!"
        : (isChecking ? "ĐANG PHÁT HIỆN TÍN HIỆU TÉ NGÃ..." : "TRẠNG THÁI: AN TOÀN");

    IconData statusIcon = isAlarm
        ? Icons.warning_amber_rounded
        : (isChecking ? Icons.sync : Icons.check_circle_outline);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Đồ Án Kỳ - Phát Hiện Té Ngã', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasReceivedData)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Chưa nhận được dữ liệu từ thiết bị. Kiểm tra ESP32 đã kết nối WiFi chưa.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(statusIcon, color: Colors.white, size: 70),
                  const SizedBox(height: 15),
                  Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAlarm) ...[
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        _dbRef.update({"state": "IDLE"}).catchError((e) {
                          debugPrint("Lỗi cập nhật Firebase: $e");
                        });
                      },
                      icon: const Icon(Icons.notifications_off, color: Colors.red),
                      label: const Text('XÁC NHẬN ĐÃ XEM (ẨN CẢNH BÁO)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    )
                  ]
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "Dữ liệu cảm biến MPU6050",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.15,
              children: [
                _buildSensorCard('Gia tốc tổng', '${accTotal.toStringAsFixed(2)} g', Icons.speed, Colors.blue),
                _buildSensorCard('Tốc độ xoay', '${gyroTotal.toStringAsFixed(1)} °/s', Icons.screen_rotation, Colors.purple),
                _buildSensorCard('Góc nghiêng', '${tiltAngle.toStringAsFixed(1)}°', Icons.navigation, Colors.teal),
                _buildSensorCard('Cảm biến', 'MPU6050', Icons.developer_board, Colors.indigo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}