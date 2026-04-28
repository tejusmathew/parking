import 'package:supabase_flutter/supabase_flutter.dart';
import 'parking_state.dart';

class ParkingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  getallSlots() {}

  final BikeSpacesTower1 = [320, 355, 358, 362, 363, 364, 365, 366, 377];

  final BikeSpacesTower2 = [
    100,
    355,
    358,
    362,
    363,
    364,
    365,
    166,
    177,
    200,
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    209,
    210,
  ];
  final CarSpaces = [120, 125, 130, 135, 140, 145, 150, 155, 160, 702, 701];
  Future<void> saveUser({
    required String name,
    required String vehicleType,
    required int slotNumber,
  }) async {
    await _client.from('parking_records').insert({
      'name': name,
      'vehicle_type': vehicleType,
      'slot_number': slotNumber,
    });
  }

  Future<int?> hasUserBookedToday({required String name}) async {
    final today = DateTime.now();
    final dateOnly = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String().split('T').first;

    final response = await _client
        .from('parking_records')
        .select('slot_number')
        .eq('name', name)
        .eq('date', dateOnly)
        .limit(1);
    print(response);
    if (response.isEmpty) {
      return null; //
    }

    return response.first['slot_number'] as int;
  }

  Future<ParkingState> getOccupiedSpotsToday() async {
    final todaysDate = DateTime.now();
    final response = await _client
        .from('parking_records')
        .select('slot_number, vehicle_type')
        .eq('date', todaysDate.toIso8601String().split('T').first);

    final Set<int> occupiedBikeSlotsTower1 = response
        .where((row) => row['vehicle_type'] == 'Bike')
        .map<int>((row) => row['slot_number'] as int)
        .toSet();
    final Set<int> occupiedBikeSlotsTower2 = response
        .where((row) => row['vehicle_type'] == 'Bike')
        .map<int>((row) => row['slot_number'] as int)
        .toSet();

    final Set<int> occupiedCarSlots = response
        .where((row) => row['vehicle_type'] == 'Car')
        .map<int>((row) => row['slot_number'] as int)
        .toSet();

    final Map<int, bool> bikeParkingStateTower1 = {
      for (var slot in BikeSpacesTower1)
        slot: !occupiedBikeSlotsTower1.contains(slot),
    };

    final Map<int, bool> bikeParkingStateTower2 = {
      for (var slot in BikeSpacesTower2)
        slot: !occupiedBikeSlotsTower2.contains(slot),
    };

    final Map<int, bool> carParkingState = {
      for (var slot in CarSpaces) slot: !occupiedCarSlots.contains(slot),
    };
    print('Occupied Bike Slots Today: $bikeParkingStateTower1');
    print('Occupied Bike Slots Today: $bikeParkingStateTower2');
    print('Occupied Car Slots Today: $carParkingState');

    return ParkingState(
      bikeSlotsTower1: bikeParkingStateTower1,
      bikeSlotsTower2: bikeParkingStateTower2,
      carSlots: carParkingState,
    );
  }
}
