// lib/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Current location data
  Position? _currentPosition;
  String? _city;
  String? _country;
  String? _state;
  String? _postalCode;
  bool _isLocationEnabled = false;
  DateTime? _lastLocationUpdate;

  // Cache settings
  static const String _keyCachedCity = 'cached_city';
  static const String _keyCachedCountry = 'cached_country';
  static const String _keyCachedState = 'cached_state';
  static const String _keyLastUpdate = 'location_last_update';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  // Request location permission
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Check location permission status
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> checkLocationServices() async {
    try {
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      return _isLocationEnabled;
    } catch (e) {
      print('Error checking location services: $e');
      return false;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
    }
  }

  // Get current location with caching
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // Check cache first (if not forcing refresh)
      if (!forceRefresh && _isCacheValid()) {
        await _loadCachedLocation();
        if (_currentPosition != null) {
          return _currentPosition;
        }
      }

      // Check if services are enabled
      final serviceEnabled = await checkLocationServices();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check permission
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          print('Location permission denied');
          return null;
        }
      }

      // Get position with timeout
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      // Get city and country
      if (_currentPosition != null) {
        await _getCityFromCoordinates(_currentPosition!);
        await _cacheLocation();
      }

      return _currentPosition;
    } on TimeoutException {
      print('Location request timeout');
      await _loadCachedLocation();
      return _currentPosition;
    } catch (e) {
      print('Error getting location: $e');
      await _loadCachedLocation();
      return _currentPosition;
    }
  }

  // Get city name from coordinates
  Future<void> _getCityFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
        _country = place.country;
        _state = place.administrativeArea;
        _postalCode = place.postalCode;
        _lastLocationUpdate = DateTime.now();
      }
    } catch (e) {
      print('Error getting city from coordinates: $e');
      _city = 'Unknown City';
      _country = 'Unknown Country';
    }
  }

  // Get location info as map
  Future<Map<String, String>?> getLocationInfo({bool forceRefresh = false}) async {
    final position = await getCurrentLocation(forceRefresh: forceRefresh);
    
    if (position != null && _city != null && _country != null) {
      return {
        'city': _city!,
        'country': _country!,
        'state': _state ?? '',
        'postalCode': _postalCode ?? '',
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'accuracy': position.accuracy.toString(),
      };
    }

    return null;
  }

  // Calculate distance between two points (in meters)
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Calculate distance to a location
  Future<double?> calculateDistanceTo({
    required double targetLat,
    required double targetLon,
  }) async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    return calculateDistance(
      lat1: position.latitude,
      lon1: position.longitude,
      lat2: targetLat,
      lon2: targetLon,
    );
  }

  // Get nearby cities (mock data - in production use Google Places API)
  Future<List<String>> getNearbyCities() async {
    // Ensure we have location data
    await getCurrentLocation();
    
    if (_country == null) {
      return ['City 1', 'City 2', 'City 3'];
    }

    // Mock data based on country
    final nearbyByCountry = {
      'United States': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
      'United Kingdom': ['London', 'Manchester', 'Birmingham', 'Leeds', 'Glasgow'],
      'India': ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'],
      'Canada': ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa'],
      'Australia': ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide'],
      'Germany': ['Berlin', 'Munich', 'Hamburg', 'Frankfurt', 'Cologne'],
      'France': ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice'],
      'Japan': ['Tokyo', 'Osaka', 'Kyoto', 'Nagoya', 'Yokohama'],
      'China': ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Chengdu'],
      'Brazil': ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador', 'Fortaleza'],
    };

    return nearbyByCountry[_country] ?? ['City 1', 'City 2', 'City 3'];
  }

  // Get local landmarks (mock data - in production use Google Places API)
  Future<List<String>> getLocalLandmarks() async {
    await getCurrentLocation();
    
    if (_city == null) {
      return ['Landmark 1', 'Landmark 2', 'Landmark 3'];
    }

    // Mock data based on city
    final landmarksByCity = {
      // USA
      'New York': ['Statue of Liberty', 'Empire State Building', 'Central Park'],
      'Los Angeles': ['Hollywood Sign', 'Venice Beach', 'Griffith Observatory'],
      'San Francisco': ['Golden Gate Bridge', 'Alcatraz Island', 'Fishermans Wharf'],
      'Chicago': ['Willis Tower', 'Navy Pier', 'Millennium Park'],
      
      // UK
      'London': ['Big Ben', 'Tower Bridge', 'Buckingham Palace'],
      'Manchester': ['Old Trafford', 'Manchester Cathedral', 'Science and Industry Museum'],
      
      // France
      'Paris': ['Eiffel Tower', 'Louvre Museum', 'Notre-Dame'],
      'Marseille': ['Old Port', 'Notre-Dame de la Garde', 'Calanques'],
      
      // India
      'Mumbai': ['Gateway of India', 'Marine Drive', 'Haji Ali Dargah'],
      'Delhi': ['Red Fort', 'India Gate', 'Qutub Minar'],
      'Bangalore': ['Lalbagh Garden', 'Bangalore Palace', 'Vidhana Soudha'],
      
      // Japan
      'Tokyo': ['Tokyo Tower', 'Senso-ji Temple', 'Meiji Shrine'],
      'Kyoto': ['Fushimi Inari Shrine', 'Kinkaku-ji Temple', 'Arashiyama Bamboo Grove'],
      
      // Australia
      'Sydney': ['Sydney Opera House', 'Harbour Bridge', 'Bondi Beach'],
      'Melbourne': ['Federation Square', 'Royal Botanic Gardens', 'Eureka Tower'],
    };

    return landmarksByCity[_city] ?? ['Landmark 1', 'Landmark 2', 'Landmark 3'];
  }

  // Get local foods (mock data)
  Future<List<String>> getLocalFoods() async {
    await getCurrentLocation();
    
    if (_country == null) {
      return ['Food 1', 'Food 2', 'Food 3'];
    }

    final foodsByCountry = {
      'United States': ['Hamburger', 'Hot Dog', 'Apple Pie'],
      'United Kingdom': ['Fish and Chips', 'Roast Beef', 'Yorkshire Pudding'],
      'India': ['Biryani', 'Butter Chicken', 'Samosa'],
      'Italy': ['Pizza', 'Pasta', 'Gelato'],
      'Japan': ['Sushi', 'Ramen', 'Tempura'],
      'France': ['Croissant', 'Baguette', 'Crêpe'],
      'Mexico': ['Tacos', 'Enchiladas', 'Guacamole'],
      'China': ['Dim Sum', 'Peking Duck', 'Fried Rice'],
    };

    return foodsByCountry[_country] ?? ['Food 1', 'Food 2', 'Food 3'];
  }

  // Get distance in human-readable format
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Check if user is in a specific country
  Future<bool> isInCountry(String countryName) async {
    await getCurrentLocation();
    return _country?.toLowerCase() == countryName.toLowerCase();
  }

  // Check if user is in a specific city
  Future<bool> isInCity(String cityName) async {
    await getCurrentLocation();
    return _city?.toLowerCase() == cityName.toLowerCase();
  }

  // Get location accuracy level
  String getAccuracyLevel() {
    if (_currentPosition == null) return 'Unknown';
    
    final accuracy = _currentPosition!.accuracy;
    if (accuracy < 10) return 'Excellent';
    if (accuracy < 50) return 'Good';
    if (accuracy < 100) return 'Fair';
    return 'Poor';
  }

  // Cache management
  bool _isCacheValid() {
    if (_lastLocationUpdate == null) return false;
    return DateTime.now().difference(_lastLocationUpdate!) < _cacheValidDuration;
  }

  Future<void> _cacheLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_city != null) await prefs.setString(_keyCachedCity, _city!);
      if (_country != null) await prefs.setString(_keyCachedCountry, _country!);
      if (_state != null) await prefs.setString(_keyCachedState, _state!);
      await prefs.setString(
        _keyLastUpdate,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching location: $e');
    }
  }

  Future<void> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _city = prefs.getString(_keyCachedCity);
      _country = prefs.getString(_keyCachedCountry);
      _state = prefs.getString(_keyCachedState);
      
      final lastUpdateStr = prefs.getString(_keyLastUpdate);
      if (lastUpdateStr != null) {
        _lastLocationUpdate = DateTime.parse(lastUpdateStr);
      }
    } catch (e) {
      print('Error loading cached location: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedCity);
      await prefs.remove(_keyCachedCountry);
      await prefs.remove(_keyCachedState);
      await prefs.remove(_keyLastUpdate);
      _lastLocationUpdate = null;
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get location stream for real-time updates
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100, // Update every 100 meters
      ),
    );
  }

  // Getters
  String? get city => _city;
  String? get country => _country;
  String? get state => _state;
  String? get postalCode => _postalCode;
  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasLocation => _currentPosition != null;
  DateTime? get lastUpdate => _lastLocationUpdate;
  bool get isCacheValid => _isCacheValid();

  // Get coordinate string
  String? get coordinatesString {
    if (_currentPosition == null) return null;
    return '${_currentPosition!.latitude.toStringAsFixed(6)}, '
           '${_currentPosition!.longitude.toStringAsFixed(6)}';
  }

  // Reset location data
  void reset() {
    _currentPosition = null;
    _city = null;
    _country = null;
    _state = null;
    _postalCode = null;
    _lastLocationUpdate = null;
  }

  // Format location for display
  String formatLocation() {
    if (_city != null && _country != null) {
      if (_state != null) {
        return '$_city, $_state, $_country';
      }
      return '$_city, $_country';
    } else if (_country != null) {
      return _country!;
    }
    return 'Unknown Location';
  }
}