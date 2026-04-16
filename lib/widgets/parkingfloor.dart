import 'package:flutter/material.dart';
import 'package:parking/config/parking_repository.dart';
import 'bookingConfirm.dart';

class ParkingFloor extends StatefulWidget {
  final String floorName;
  final String vehicleType;
  final Map<int, bool> parkingState;
  final String userName;
  final String tower;
  const ParkingFloor({
    super.key,
    required this.floorName,
    required this.tower,
    required this.vehicleType,
    required this.parkingState,
    required this.userName,
  });

  @override
  State<ParkingFloor> createState() => _ParkingFloorState();
}

class _ParkingFloorState extends State<ParkingFloor> {
  late Map<int, bool> spots;
  final ParkingRepository _parkingRepository = ParkingRepository();
  @override
  void initState() {
    super.initState();
    spots = widget.parkingState;
  }

  void bookSpot(int spot) async {
    try {
      await _parkingRepository.saveUser(
        name: widget.userName,
        vehicleType: widget.vehicleType,
        slotNumber: spot,
      );
      await _parkingRepository.getOccupiedSpotsToday();
      setState(() {
        spots[spot] = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully booked spot $spot')),
        );
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            userName: widget.userName,
            vehicleType: widget.vehicleType,
            slotNumber: spot,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book spot $spot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: widget.parkingState.keys.map((spot) {
            final isAvailable = widget.parkingState[spot] ?? false;

            return InkWell(
              onTap: isAvailable
                  ? () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Parking Info"),
                          content: Text(
                            "${widget.vehicleType} $spot is available",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                bookSpot(spot);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Book"),
                            ),
                          ],
                        ),
                      );
                    }
                  : null,

              child: Ink(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isAvailable ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: isAvailable
                          ? Colors.green.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isAvailable)
                      Image.asset(
                        widget.vehicleType == "Car"
                            ? "assets/Car-top.png"
                            : "assets/Bike-Top.png",
                        width: 120,
                      ),

                    Text(
                      "$spot",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isAvailable ? "Available" : "Occupied",
                      style: TextStyle(
                        fontSize: 16,
                        color: isAvailable ? Colors.black : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
