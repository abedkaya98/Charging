import 'package:flutter/material.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'dart:async';

void main() {
  runApp(const CoolingApp());
}

class CoolingApp extends StatelessWidget {
  const CoolingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مبرد الهاتف',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BatteryMonitorScreen(),
    );
  }
}

class BatteryMonitorScreen extends StatefulWidget {
  const BatteryMonitorScreen({super.key});

  @override
  State<BatteryMonitorScreen> createState() => _BatteryMonitorScreenState();
}

class _BatteryMonitorScreenState extends State<BatteryMonitorScreen> {
  int _temperature = 0;
  String _chargingStatus = "غير معروف";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _getBatteryInfo();
    });
    _getBatteryInfo();
  }

  Future<void> _getBatteryInfo() async {
    AndroidBatteryInfo? batteryInfo = await BatteryInfoPlugin().androidBatteryInfo;
    if (batteryInfo != null) {
      setState(() {
        _temperature = batteryInfo.temperature ?? 0;
        _chargingStatus = batteryInfo.chargingStatus.toString().split('.').last;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getTemperatureColor() {
    if (_temperature < 35) return Colors.green; 
    if (_temperature >= 35 && _temperature < 40) return Colors.orange; 
    return Colors.red; 
  }

  @override
  Widget build(BuildContext context) {
    bool isCharging = _chargingStatus.toLowerCase() == 'charging';
    Color statusColor = _getTemperatureColor();

    return Scaffold(
      backgroundColor: statusColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('مراقب حرارة الشحن', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCharging ? Icons.battery_charging_full : Icons.battery_std,
              size: 100,
              color: statusColor,
            ),
            const SizedBox(height: 20),
            Text(
              '${_temperature}°C',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isCharging ? 'جارٍ الشحن الآن' : 'غير متصل بالشاحن',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            if (_temperature >= 40)
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  'تحذير: حرارة الهاتف مرتفعة جداً! يرجى فصل الشاحن أو تفعيل وضع التبريد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
