import 'package:flutter/material.dart';
import 'package:parking/widgets/bookingConfirm.dart';
import '../config/parking_repository.dart';
import 'BookPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserForm extends StatefulWidget {
  const UserForm({Key? key}) : super(key: key);

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final List<String> _vehicleTypes = ['Car', 'Bike'];
  String? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _vehicleTypes[0];
    _checkSavedUser();
  }

  Future<void> _checkSavedUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final userEmail = user.email ?? '';
    final parkingRepository = ParkingRepository();
    final userSlot = await parkingRepository.hasUserBookedToday(name: userEmail);

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userSlot != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationPage(
              slotNumber: userSlot,
              vehicleType: _selectedVehicle!,
              userName: userEmail,
            ),
          ),
          (route) => false,
        );
      }
    });
  }

  Future<void> submitForm() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final userEmail = user.email ?? '';

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyBookPage(
              tower: "a",
              selectedVehicle: _selectedVehicle!,
              userName: userEmail,
              floors: const ["1st Floor", "2nd Floor", "3rd Floor"],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Book Parking Slot",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedVehicle,
                      items: _vehicleTypes.map((vehicle) {
                        return DropdownMenuItem(
                          value: vehicle,
                          child: Text(vehicle),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicle = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Book",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
