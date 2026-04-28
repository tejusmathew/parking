import 'package:flutter/material.dart';
import 'package:parking/widgets/AvailScreen.dart';
import 'package:parking/widgets/LoginScreen.dart';
import 'package:parking/widgets/bookingConfirm.dart';
import '../config/parking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'package:app_links/app_links.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AppLinks _appLinks;
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
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

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // App opened from closed state
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.host != 'book') return;
  
    final slot = int.tryParse(uri.queryParameters['slot'] ?? '');
    if (slot == null) return;
  
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
  
    final name = user.email!;
  
    final repo = ParkingRepository();
  
    // Prevent double booking
    
    final existing = await repo.hasUserBookedToday(name: name);
    if (existing != null) return;
  
    await repo.saveUser(
      name: name,
      vehicleType: "Car",
      slotNumber: slot,
    );
  
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmationPage(
          slotNumber: slot,
          vehicleType: "Car",
          userName: name,
        ),
      ),
    );
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
