// lib/services/location_question_service.dart
// COMPLETE LOCATION-BASED QUESTIONS SERVICE
// Supports GPS auto-detection and manual location selection

import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationQuestionService {
  static final LocationQuestionService _instance = LocationQuestionService._internal();
  factory LocationQuestionService() => _instance;
  LocationQuestionService._internal();

  String? _currentCity;
  String? _currentCountry;
  Position? _currentPosition;
  bool _isInitialized = false;
  
  // Question database by location
  final Map<String, List<String>> _locationQuestions = {};
  
  /// Initialize location service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions denied');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions permanently denied');
        return false;
      }
      
      _isInitialized = true;
      _initializeQuestionDatabase();
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }
  
  /// Get current GPS location
  Future<Map<String, String>?> getCurrentLocation() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentCity = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
        _currentCountry = place.country ?? 'Unknown Country';
        
        print('Current location: $_currentCity, $_currentCountry');
        
        return {
          'city': _currentCity!,
          'country': _currentCountry!,
          'latitude': _currentPosition!.latitude.toString(),
          'longitude': _currentPosition!.longitude.toString(),
        };
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
    
    return null;
  }
  
  /// Set manual location
  void setManualLocation(String city, String country) {
    _currentCity = city;
    _currentCountry = country;
    print('Manual location set: $city, $country');
  }
  
  /// Get location-specific questions
  List<String> getLocationQuestions({
    String? city,
    String? country,
    int count = 10,
  }) {
    final targetCity = city ?? _currentCity;
    final targetCountry = country ?? _currentCountry;
    
    if (targetCity == null && targetCountry == null) {
      return _getGenericQuestions(count);
    }
    
    List<String> questions = [];
    
    // City-specific questions
    if (targetCity != null) {
      questions.addAll(_getCityQuestions(targetCity));
    }
    
    // Country-specific questions
    if (targetCountry != null) {
      questions.addAll(_getCountryQuestions(targetCountry));
    }
    
    // Add regional questions
    questions.addAll(_getRegionalQuestions(targetCountry));
    
    // Shuffle and return requested count
    questions.shuffle();
    return questions.take(count).toList();
  }
  
  /// Initialize question database
  void _initializeQuestionDatabase() {
    // This will be populated with questions for different locations
    _locationQuestions.clear();
    
    // We'll add questions dynamically based on location
    print('Question database initialized');
  }
  
  /// Generate city-specific questions
  List<String> _getCityQuestions(String city) {
    final questions = <String>[];
    
    // City-specific landmarks/attractions
    final cityQuestions = {
      'New York': [
        'Name 3 famous landmarks in New York City',
        'Name 3 New York City boroughs',
        'Name 3 things New York is famous for',
        'Name 3 famous streets in NYC',
        'Name 3 NYC museums',
      ],
      'London': [
        'Name 3 famous London landmarks',
        'Name 3 things London is famous for',
        'Name 3 London tube lines',
        'Name 3 royal palaces in London',
        'Name 3 London bridges',
      ],
      'Paris': [
        'Name 3 famous Paris landmarks',
        'Name 3 French foods',
        'Name 3 Paris museums',
        'Name 3 things Paris is famous for',
        'Name 3 Paris arrondissements',
      ],
      'Tokyo': [
        'Name 3 Tokyo neighborhoods',
        'Name 3 things Tokyo is famous for',
        'Name 3 Tokyo landmarks',
        'Name 3 Japanese foods',
        'Name 3 Tokyo train lines',
      ],
      'Mumbai': [
        'Name 3 famous Mumbai landmarks',
        'Name 3 Mumbai beaches',
        'Name 3 things Mumbai is famous for',
        'Name 3 Mumbai neighborhoods',
        'Name 3 Mumbai street foods',
      ],
      'Dubai': [
        'Name 3 Dubai landmarks',
        'Name 3 things Dubai is famous for',
        'Name 3 Dubai malls',
        'Name 3 Dubai attractions',
        'Name 3 things to do in Dubai',
      ],
      'Sydney': [
        'Name 3 Sydney landmarks',
        'Name 3 Sydney beaches',
        'Name 3 things Sydney is famous for',
        'Name 3 Sydney suburbs',
        'Name 3 activities in Sydney',
      ],
      'Singapore': [
        'Name 3 Singapore landmarks',
        'Name 3 Singapore foods',
        'Name 3 things Singapore is famous for',
        'Name 3 Singapore attractions',
        'Name 3 Singapore neighborhoods',
      ],
    };
    
    // Check for exact match
    if (cityQuestions.containsKey(city)) {
      questions.addAll(cityQuestions[city]!);
    }
    
    // Add generic city questions with city name
    questions.addAll([
      'Name 3 restaurants you know in $city',
      'Name 3 things people do in $city',
      'Name 3 types of transportation in $city',
      'Name 3 famous people from $city',
      'Name 3 reasons to visit $city',
    ]);
    
    return questions;
  }
  
  /// Generate country-specific questions
  List<String> _getCountryQuestions(String country) {
    final questions = <String>[];
    
    final countryQuestions = {
      'USA': [
        'Name 3 US states',
        'Name 3 American foods',
        'Name 3 US presidents',
        'Name 3 American sports',
        'Name 3 things America is famous for',
      ],
      'United Kingdom': [
        'Name 3 British cities',
        'Name 3 British foods',
        'Name 3 British monarchs',
        'Name 3 things UK is famous for',
        'Name 3 British TV shows',
      ],
      'India': [
        'Name 3 Indian states',
        'Name 3 Indian dishes',
        'Name 3 Indian festivals',
        'Name 3 things India is famous for',
        'Name 3 Indian languages',
      ],
      'Japan': [
        'Name 3 Japanese cities',
        'Name 3 Japanese foods',
        'Name 3 things Japan is famous for',
        'Name 3 Japanese anime',
        'Name 3 Japanese car brands',
      ],
      'France': [
        'Name 3 French cities',
        'Name 3 French foods',
        'Name 3 things France is famous for',
        'Name 3 French words',
        'Name 3 French fashion brands',
      ],
      'Australia': [
        'Name 3 Australian cities',
        'Name 3 Australian animals',
        'Name 3 things Australia is famous for',
        'Name 3 Australian slang words',
        'Name 3 Australian foods',
      ],
      'UAE': [
        'Name 3 cities in UAE',
        'Name 3 things UAE is famous for',
        'Name 3 Dubai landmarks',
        'Name 3 activities in Dubai',
        'Name 3 UAE attractions',
      ],
    };
    
    if (countryQuestions.containsKey(country)) {
      questions.addAll(countryQuestions[country]!);
    }
    
    // Generic country questions
    questions.addAll([
      'Name 3 cities in $country',
      'Name 3 famous people from $country',
      'Name 3 things $country is famous for',
      'Name 3 foods from $country',
      'Name 3 tourist attractions in $country',
    ]);
    
    return questions;
  }
  
  /// Generate regional questions
  List<String> _getRegionalQuestions(String? country) {
    final questions = <String>[];
    
    // Determine region
    String? region;
    
    if (country != null) {
      final asianCountries = ['India', 'Japan', 'China', 'Singapore', 'Thailand'];
      final europeanCountries = ['UK', 'United Kingdom', 'France', 'Germany', 'Italy'];
      final americanCountries = ['USA', 'United States', 'Canada', 'Mexico'];
      
      if (asianCountries.contains(country)) {
        region = 'Asia';
      } else if (europeanCountries.contains(country)) {
        region = 'Europe';
      } else if (americanCountries.contains(country)) {
        region = 'Americas';
      }
    }
    
    if (region == 'Asia') {
      questions.addAll([
        'Name 3 Asian countries',
        'Name 3 Asian foods',
        'Name 3 Asian capitals',
        'Name 3 things Asia is famous for',
        'Name 3 Asian languages',
      ]);
    } else if (region == 'Europe') {
      questions.addAll([
        'Name 3 European countries',
        'Name 3 European capitals',
        'Name 3 European foods',
        'Name 3 European landmarks',
        'Name 3 European languages',
      ]);
    } else if (region == 'Americas') {
      questions.addAll([
        'Name 3 North American countries',
        'Name 3 American foods',
        'Name 3 things Americas are famous for',
        'Name 3 American cities',
        'Name 3 American sports',
      ]);
    }
    
    return questions;
  }
  
  /// Get generic questions (fallback)
  List<String> _getGenericQuestions(int count) {
    final questions = [
      'Name 3 world capitals',
      'Name 3 famous world landmarks',
      'Name 3 international foods',
      'Name 3 world languages',
      'Name 3 continents',
      'Name 3 oceans',
      'Name 3 famous cities',
      'Name 3 world religions',
      'Name 3 currencies',
      'Name 3 international airports',
    ];
    
    questions.shuffle();
    return questions.take(count).toList();
  }
  
  /// Get distance to a specific location (in KM)
  double? getDistanceToLocation(double lat, double lon) {
    if (_currentPosition == null) return null;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lon,
    ) / 1000; // Convert to kilometers
  }
  
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
  
  // Getters
  String? get currentCity => _currentCity;
  String? get currentCountry => _currentCountry;
  Position? get currentPosition => _currentPosition;
  bool get isInitialized => _isInitialized;
  
  /// Get a formatted location string
  String getLocationString() {
    if (_currentCity != null && _currentCountry != null) {
      return '$_currentCity, $_currentCountry';
    } else if (_currentCity != null) {
      return _currentCity!;
    } else if (_currentCountry != null) {
      return _currentCountry!;
    }
    return 'Unknown Location';
  }
}