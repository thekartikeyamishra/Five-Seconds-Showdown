// lib/core/services/multiplayer_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/multiplayer_room.dart';

class MultiplayerService {
  static final MultiplayerService _instance = MultiplayerService._internal();
  factory MultiplayerService() => _instance;
  MultiplayerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'multiplayer_rooms';

  /// Create a new multiplayer room
  Future<MultiplayerRoom> createRoom({
    required String hostId,
    required String hostName,
    required int maxPlayers,
  }) async {
    try {
      final roomId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final room = MultiplayerRoom(
        id: roomId,
        hostId: hostId,
        hostName: hostName,
        maxPlayers: maxPlayers,
        players: [
          {
            'id': hostId,
            'name': hostName,
            'score': 0,
            'ready': false,
          }
        ],
        status: 'waiting',
        currentQuestionIndex: 0,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(_collection).doc(roomId).set(room.toJson());
      return room;
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  /// Join an existing room
  Future<void> joinRoom({
    required String roomId,
    required String playerId,
    required String playerName,
  }) async {
    try {
      final roomRef = _firestore.collection(_collection).doc(roomId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);
        
        if (!snapshot.exists) {
          throw Exception('Room not found');
        }

        final room = MultiplayerRoom.fromJson(snapshot.data()!);
        
        // Check if already in room
        final isAlreadyIn = room.players.any((p) => p['id'] == playerId);
        if (isAlreadyIn) return; // Already joined, just proceed

        if (room.players.length >= room.maxPlayers) {
          throw Exception('Room is full');
        }

        if (room.status != 'waiting') {
          throw Exception('Game already started');
        }

        // Add player
        final newPlayer = {
          'id': playerId,
          'name': playerName,
          'score': 0,
          'ready': false,
        };

        transaction.update(roomRef, {
          'players': FieldValue.arrayUnion([newPlayer]),
        });
      });
    } catch (e) {
      throw Exception('Failed to join room: $e');
    }
  }

  /// Set player status to Ready
  Future<void> setPlayerReady({
    required String roomId,
    required String playerId,
  }) async {
    try {
      final roomRef = _firestore.collection(_collection).doc(roomId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);
        if (!snapshot.exists) throw Exception('Room not found');

        final room = MultiplayerRoom.fromJson(snapshot.data()!);
        
        final updatedPlayers = room.players.map((player) {
          if (player['id'] == playerId) {
            return {...player, 'ready': true};
          }
          return player;
        }).toList();

        transaction.update(roomRef, {'players': updatedPlayers});

        // Check if all players are ready to Auto-Start
        final allReady = updatedPlayers.every((p) => p['ready'] == true);
        if (allReady && updatedPlayers.length >= 2) {
          transaction.update(roomRef, {
            'status': 'playing',
            'currentQuestionIndex': 0,
            'startedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to set ready state: $e');
    }
  }

  /// Start the game manually (Host)
  Future<void> startGame(String roomId) async {
    try {
      await _firestore.collection(_collection).doc(roomId).update({
        'status': 'playing',
        'currentQuestionIndex': 0,
        'startedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to start game: $e');
    }
  }

  /// Submit an answer and update score
  Future<void> submitAnswer({
    required String roomId,
    required String playerId,
    required bool isCorrect,
    required int points,
  }) async {
    // Only update if correct to save writes, or implement penalty logic here
    if (!isCorrect) return;

    try {
      final roomRef = _firestore.collection(_collection).doc(roomId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);
        if (!snapshot.exists) return;

        final room = MultiplayerRoom.fromJson(snapshot.data()!);
        
        final updatedPlayers = room.players.map((player) {
          if (player['id'] == playerId) {
            final currentScore = (player['score'] as int?) ?? 0;
            return {...player, 'score': currentScore + points};
          }
          return player;
        }).toList();

        transaction.update(roomRef, {'players': updatedPlayers});
      });
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  /// Move to the next question
  Future<void> nextQuestion(String roomId) async {
    try {
      await _firestore.collection(_collection).doc(roomId).update({
        'currentQuestionIndex': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to change question: $e');
    }
  }

  /// End the game
  Future<void> endGame(String roomId) async {
    try {
      await _firestore.collection(_collection).doc(roomId).update({
        'status': 'finished',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to end game: $e');
    }
  }

  /// Leave the room
  Future<void> leaveRoom({
    required String roomId,
    required String playerId,
  }) async {
    try {
      final roomRef = _firestore.collection(_collection).doc(roomId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);
        if (!snapshot.exists) return; // Room already deleted

        final room = MultiplayerRoom.fromJson(snapshot.data()!);
        
        // Remove player
        final updatedPlayers = room.players.where((p) => p['id'] != playerId).toList();

        if (updatedPlayers.isEmpty) {
          // Delete room if empty
          transaction.delete(roomRef);
        } else {
          // If host left, assign new host (first player in list)
          final newHostId = room.hostId == playerId ? updatedPlayers.first['id'] : room.hostId;
          final newHostName = room.hostId == playerId ? updatedPlayers.first['name'] : room.hostName;

          transaction.update(roomRef, {
            'players': updatedPlayers,
            'hostId': newHostId,
            'hostName': newHostName,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to leave room: $e');
    }
  }

  /// Listen to room updates
  Stream<MultiplayerRoom> listenToRoom(String roomId) {
    return _firestore
        .collection(_collection)
        .doc(roomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw Exception('Room deleted');
          }
          return MultiplayerRoom.fromJson(doc.data()!);
        });
  }

  /// Get list of waiting rooms
  Future<List<MultiplayerRoom>> getAvailableRooms() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => MultiplayerRoom.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }
}