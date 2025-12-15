// lib/controllers/multiplayer_controller.dart
import 'dart:async';
import '../models/multiplayer_room.dart';
import '../core/services/multiplayer_service.dart';

class MultiplayerController {
  final MultiplayerService _service = MultiplayerService();
  StreamSubscription<MultiplayerRoom>? _roomSubscription;
  
  // Callbacks for UI interaction
  final Function(MultiplayerRoom) onRoomUpdate;
  final Function(String) onError;
  
  // Optional callbacks for specific game events
  final Function()? onGameStarted;
  final Function()? onGameEnded;

  MultiplayerController({
    required this.onRoomUpdate,
    required this.onError,
    this.onGameStarted,
    this.onGameEnded,
  });

  /// Subscribe to room updates via Firestore Stream
  void subscribeToRoom(String roomId) {
    // Cancel any existing subscription to avoid memory leaks or duplicate listeners
    _roomSubscription?.cancel();

    try {
      _roomSubscription = _service.listenToRoom(roomId).listen(
        (room) {
          // 1. Notify UI of generic update
          onRoomUpdate(room);

          // 2. Check for State Transitions
          _handleStateTransitions(room);
        },
        onError: (e) {
          onError('Connection error: ${e.toString()}');
        },
      );
    } catch (e) {
      onError('Failed to subscribe to room: $e');
    }
  }

  /// Handle specific game state changes (Waiting -> Playing -> Finished)
  void _handleStateTransitions(MultiplayerRoom room) {
    if (room.status == 'playing' && room.currentQuestionIndex == 0) {
      // Trigger only if we are just starting
      // Note: A more robust impl might use a local boolean flag '_hasGameStarted' to prevent duplicate calls
      onGameStarted?.call();
    } else if (room.status == 'finished') {
      onGameEnded?.call();
    }
  }

  /// Toggle player ready state
  Future<void> setReady(String roomId, String playerId) async {
    try {
      await _service.setPlayerReady(
        roomId: roomId,
        playerId: playerId,
      );
    } catch (e) {
      onError('Failed to set ready status: $e');
    }
  }

  /// Start the game (Host Only)
  Future<void> startGame(String roomId) async {
    try {
      await _service.startGame(roomId);
    } catch (e) {
      onError('Failed to start game: $e');
    }
  }

  /// Submit answer for the current question
  Future<void> submitAnswer({
    required String roomId,
    required String playerId,
    required bool isCorrect,
    int points = 100,
  }) async {
    try {
      // Logic: You might want to calculate points based on time remaining here
      // For now, we use the passed value
      await _service.submitAnswer(
        roomId: roomId,
        playerId: playerId,
        isCorrect: isCorrect,
        points: points,
      );
    } catch (e) {
      onError('Failed to submit answer: $e');
    }
  }

  /// Move to next question (Host Only)
  Future<void> nextQuestion(String roomId) async {
    try {
      await _service.nextQuestion(roomId);
    } catch (e) {
      onError('Failed to load next question: $e');
    }
  }

  /// End the game manually (Host Only or Timeout)
  Future<void> endGame(String roomId) async {
    try {
      await _service.endGame(roomId);
    } catch (e) {
      onError('Failed to end game: $e');
    }
  }

  /// Leave room and clean up subscription
  Future<void> leaveRoom(String roomId, String playerId) async {
    try {
      await _service.leaveRoom(roomId: roomId, playerId: playerId);
      dispose(); // Clean up stream when leaving
    } catch (e) {
      onError('Failed to leave room: $e');
    }
  }

  /// Dispose resources to prevent memory leaks
  void dispose() {
    _roomSubscription?.cancel();
    _roomSubscription = null;
  }
}