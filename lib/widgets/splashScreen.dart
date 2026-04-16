import 'package:flutter/material.dart';
import 'package:parking/widgets/AvailScreen.dart';
import 'package:parking/widgets/LoginScreen.dart';
import 'package:parking/widgets/bookingConfirm.dart';
import '../config/parking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;
    print(session);
    
    if (user == null) {
      _navigateToLogin();
      return;
    }

    final userEmail = user.email ?? '';
    final parkingRepository = ParkingRepository();
    final userSlot = await parkingRepository.hasUserBookedToday(
      name: userEmail,
    );
    print("userslot" + userSlot.toString());
    print(userEmail);

    if (!mounted) return;

    if (userSlot != null) {
      _navigateToBooking(userSlot, userEmail);
      return;
    }

    _navigateToAvailability(userEmail);
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Loginscreen()),
        );
      }
    });
  }

  void _navigateToBooking(int slotNumber, String userEmail) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationPage(
              slotNumber: slotNumber,
              vehicleType: 'Car',
              userName: userEmail,
            ),
          ),
        );
      }
    });
  }

  void _navigateToAvailability(String userEmail) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AvailabilityScreen(userName: userEmail),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
