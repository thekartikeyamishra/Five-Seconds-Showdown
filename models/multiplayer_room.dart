// lib/models/multiplayer_room.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MultiplayerRoom {
  final String id;
  final String hostId;
  final String hostName;
  final int maxPlayers;
  final List<Map<String, dynamic>> players;
  final String status; // waiting, playing, finished
  final int currentQuestionIndex;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  MultiplayerRoom({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.maxPlayers,
    required this.players,
    required this.status,
    required this.currentQuestionIndex,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  /// Create a copy of this room with updated fields (Immutable update)
  MultiplayerRoom copyWith({
    String? id,
    String? hostId,
    String? hostName,
    int? maxPlayers,
    List<Map<String, dynamic>>? players,
    String? status,
    int? currentQuestionIndex,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return MultiplayerRoom(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      players: players ?? this.players,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  // From JSON (Firestore Data)
  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    return MultiplayerRoom(
      id: json['id'] ?? '',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      // Safe casting: handle potential double/int mismatch from Firestore
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 4,
      players: List<Map<String, dynamic>>.from(json['players'] ?? []),
      status: json['status'] ?? 'waiting',
      currentQuestionIndex: (json['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (json['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (json['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  // To JSON (Firestore Data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'hostName': hostName,
      'maxPlayers': maxPlayers,
      'players': players,
      'status': status,
      'currentQuestionIndex': currentQuestionIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }

  // Get player by ID
  Map<String, dynamic>? getPlayer(String playerId) {
    try {
      return players.firstWhere((p) => p['id'] == playerId);
    } catch (e) {
      return null;
    }
  }

  // Get winner (Highest Score)
  Map<String, dynamic>? getWinner() {
    if (players.isEmpty) return null;
    
    return players.reduce((a, b) {
      final scoreA = (a['score'] as num?)?.toInt() ?? 0;
      final scoreB = (b['score'] as num?)?.toInt() ?? 0;
      return scoreA > scoreB ? a : b;
    });
  }

  // Get sorted players by score (Highest first)
  List<Map<String, dynamic>> getSortedPlayers() {
    final sorted = List<Map<String, dynamic>>.from(players);
    sorted.sort((a, b) {
      final scoreA = (a['score'] as num?)?.toInt() ?? 0;
      final scoreB = (b['score'] as num?)?.toInt() ?? 0;
      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }

  // Check if all players are ready
  bool get allPlayersReady {
    if (players.isEmpty) return false;
    return players.every((p) => p['ready'] == true);
  }

  // Check if room is full
  bool get isFull => players.length >= maxPlayers;

  // Check if game is active
  bool get isActive => status == 'playing';

  // Check if game is finished
  bool get isFinished => status == 'finished';

  @override
  String toString() {
    return 'MultiplayerRoom(id: $id, players: ${players.length}/$maxPlayers, status: $status)';
  }
}