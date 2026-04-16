import 'package:flutter/material.dart';
import 'package:parking/config/parking_repository.dart';
import 'BookPage.dart';
import '../config/parking_state.dart';

class AvailabilityScreen extends StatefulWidget {
  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
  AvailabilityScreen({super.key, required this.userName});
  final String userName;
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final ParkingRepository _parkingRepository = ParkingRepository();
  final firstTowerBikeSlots = Map<int, bool>();
  final secondTowerBikeSlots = Map<int, bool>();
  final firstTowerCarSlots = Map<int, bool>();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    ParkingState AvailabilityToday = await _parkingRepository
        .getOccupiedSpotsToday();
    setState(() {
      isLoading = false;
      firstTowerBikeSlots.addAll(AvailabilityToday.bikeSlotsTower1);
      secondTowerBikeSlots.addAll(AvailabilityToday.bikeSlotsTower2);
      firstTowerCarSlots.addAll(AvailabilityToday.carSlots);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Available Slots", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7EFB99), Color(0xFFEFFBF1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),

              child: PageView(
                children: [
                  _buildTowerScreen(
                    context,
                    "Bike",
                    "Tower-2",
                    secondTowerBikeSlots.values.where((value) => value).length,
                  ),
                  _buildTowerScreen(
                    context,
                    "Car",
                    "Tower-2",
                    firstTowerCarSlots.values.where((value) => value).length,
                  ),
                  _buildTowerScreen(
                    context,
                    "Bike",
                    "Tower-1",
                    firstTowerBikeSlots.values.where((value) => value).length,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTowerScreen(
    BuildContext context,
    String vehicle,
    String tower,
    int count,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyBookPage(
              tower: tower,
              selectedVehicle: vehicle,
              userName: widget.userName,
              floors: (vehicle == "Bike"
                  ? ["1st Floor"]
                  : ["1st Floor", "7th Floor"]),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/$vehicle-$tower.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tower,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "$vehicle Parking",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),

                const SizedBox(height: 10),

                Text(
                  "$count Available",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
