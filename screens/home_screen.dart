// lib/screens/home_screen.dart
// COMPLETE HOME SCREEN - NO OVERFLOW ERRORS
// Fixed all UI/UX issues

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    debugPrint('✅ HomeScreen initialized');
  }
  
  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _logoAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    debugPrint('✅ Animations initialized');
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    debugPrint('✅ HomeScreen disposed');
    super.dispose();
  }
  
  void _startQuickGame(String mode) {
    debugPrint('🎮 Starting quick game: $mode');
    HapticFeedback.mediumImpact();
    
    Navigator.pushNamed(
      context,
      '/game',
      arguments: {
        'mode': mode,
        'playerCount': 1,
        'category': 'all',
      },
    );
  }
  
  void _showModeSelection() {
    debugPrint('📋 Opening mode selection');
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModeSelectionSheet(),
    );
  }
  
  Widget _buildModeSelectionSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Choose Your Mode',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Modes List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildModeCard(
                  title: 'Classic Mode',
                  description: 'Traditional 5-second challenge',
                  icon: Icons.timer,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _startQuickGame('classic');
                  },
                ),
                
                _buildModeCard(
                  title: 'AI Satirical Mode',
                  description: 'Witty AI roasts you! Can you handle it? 🔥',
                  icon: Icons.psychology,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _startQuickGame('satirical');
                  },
                ),
                
                _buildModeCard(
                  title: 'Location Mode',
                  description: 'Questions based on your location 🌍',
                  icon: Icons.location_on,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _showLocationModeOptions();
                  },
                ),
                
                _buildModeCard(
                  title: 'Voice Challenge',
                  description: 'Speak your answers! 🎤',
                  icon: Icons.mic,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _startQuickGame('voice');
                  },
                ),
                
                _buildModeCard(
                  title: 'Multiplayer',
                  description: 'Challenge your friends!',
                  icon: Icons.people,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _showMultiplayerSetup();
                  },
                ),
                
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showLocationModeOptions() {
    debugPrint('📍 Opening location mode options');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: const Text('Use My Location'),
              subtitle: const Text('Questions based on where you are'),
              onTap: () {
                Navigator.pop(context);
                _startQuickGame('location-auto');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.green),
              title: const Text('Choose Location'),
              subtitle: const Text('Pick any city or country'),
              onTap: () {
                Navigator.pop(context);
                _showLocationPicker();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLocationPicker() {
    debugPrint('🗺️ Opening location picker');
    final locations = [
      {'name': 'New York', 'country': 'USA', 'emoji': '🗽'},
      {'name': 'London', 'country': 'UK', 'emoji': '🏰'},
      {'name': 'Paris', 'country': 'France', 'emoji': '🗼'},
      {'name': 'Tokyo', 'country': 'Japan', 'emoji': '🗾'},
      {'name': 'Mumbai', 'country': 'India', 'emoji': '🕌'},
      {'name': 'Sydney', 'country': 'Australia', 'emoji': '🦘'},
      {'name': 'Dubai', 'country': 'UAE', 'emoji': '🏜️'},
      {'name': 'Singapore', 'country': 'Singapore', 'emoji': '🦁'},
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Choose a Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return ListTile(
                    leading: Text(
                      location['emoji']!,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(location['name']!),
                    subtitle: Text(location['country']!),
                    onTap: () {
                      debugPrint('📍 Selected: ${location['name']}');
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: {
                          'mode': 'location-manual',
                          'location': location['name'],
                          'country': location['country'],
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showMultiplayerSetup() {
    debugPrint('👥 Opening multiplayer setup');
    Navigator.pushNamed(context, '/multiplayer-setup');
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    debugPrint('🖥️ Screen size: ${screenWidth}x$screenHeight');
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        debugPrint('📋 Menu button pressed');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        debugPrint('⚙️ Settings button pressed');
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 200, // Prevent overflow
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '5',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Title
                        const Text(
                          '5 SECONDS',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const Text(
                          'SHOWDOWN',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            letterSpacing: 4,
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Quick Access Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              // Play Button
                              _buildMainButton(
                                label: 'PLAY NOW',
                                icon: Icons.play_arrow,
                                color: Colors.white,
                                textColor: Colors.blue,
                                onPressed: _showModeSelection,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Quick Access Row 1
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickAccessButton(
                                      label: 'Classic',
                                      icon: Icons.timer,
                                      color: Colors.white.withOpacity(0.2),
                                      onPressed: () => _startQuickGame('classic'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickAccessButton(
                                      label: 'AI Roast',
                                      icon: Icons.psychology,
                                      color: Colors.white.withOpacity(0.2),
                                      onPressed: () => _startQuickGame('satirical'),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Quick Access Row 2
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickAccessButton(
                                      label: 'Location',
                                      icon: Icons.location_on,
                                      color: Colors.white.withOpacity(0.2),
                                      onPressed: _showLocationModeOptions,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickAccessButton(
                                      label: 'Voice',
                                      icon: Icons.mic,
                                      color: Colors.white.withOpacity(0.2),
                                      onPressed: () => _startQuickGame('voice'),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 30), // Extra bottom padding
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Info
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'by @namdosan__',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAccessButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}