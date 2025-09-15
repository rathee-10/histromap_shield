import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

/// Service for managing historical maps and related operations
class MapsService {
  static MapsService? _instance;
  static MapsService get instance => _instance ??= MapsService._();

  MapsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get all active historical maps with pagination
  Future<List<Map<String, dynamic>>> getAllMaps({
    int limit = 20,
    int offset = 0,
    String? era,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('historical_maps').select('''
            id, title, description, era, year_start, year_end, 
            location_name, latitude, longitude, map_image_url, 
            thumbnail_url, view_count, created_at,
            user_profiles!creator_id(full_name, avatar_url)
          ''').eq('status', 'active');

      if (era != null) {
        query = query.eq('era', era);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,location_name.ilike.%$searchQuery%');
      }

      final response = await query
          .order('view_count', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to fetch maps: $error');
    }
  }

  /// Get maps near a specific location
  Future<List<Map<String, dynamic>>> getMapsNearLocation(
    double latitude,
    double longitude, {
    double radiusKm = 50.0,
    int limit = 10,
  }) async {
    try {
      // Using a simple bounding box for demonstration
      // In production, you might want to use PostGIS for more accurate distance calculations
      const double kmToDegrees = 0.009; // Rough conversion
      final double latRange = radiusKm * kmToDegrees;
      final double lonRange = radiusKm * kmToDegrees;

      final response = await _client
          .from('historical_maps')
          .select('''
            id, title, description, era, year_start, year_end,
            location_name, latitude, longitude, thumbnail_url,
            view_count, created_at
          ''')
          .eq('status', 'active')
          .gte('latitude', latitude - latRange)
          .lte('latitude', latitude + latRange)
          .gte('longitude', longitude - lonRange)
          .lte('longitude', longitude + lonRange)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to fetch nearby maps: $error');
    }
  }

  /// Get a specific map with annotations
  Future<Map<String, dynamic>?> getMapWithAnnotations(String mapId) async {
    try {
      final mapResponse = await _client.from('historical_maps').select('''
            id, title, description, era, year_start, year_end,
            location_name, latitude, longitude, map_image_url,
            thumbnail_url, view_count, created_at,
            user_profiles!creator_id(full_name, avatar_url, role)
          ''').eq('id', mapId).single();

      final annotationsResponse =
          await _client.from('map_annotations').select('''
            id, type, title, content, latitude, longitude, color,
            created_at,
            user_profiles!user_id(full_name, avatar_url)
          ''').eq('map_id', mapId).order('created_at', ascending: true);

      // Log the view activity
      await _logActivity('map_view', 'historical_map', mapId);

      // Increment view count
      await _client.from('historical_maps').update(
          {'view_count': (mapResponse['view_count'] ?? 0) + 1}).eq('id', mapId);

      return {
        ...mapResponse,
        'annotations': annotationsResponse,
      };
    } catch (error) {
      throw Exception('Failed to fetch map details: $error');
    }
  }

  /// Create a new map annotation
  Future<Map<String, dynamic>> createAnnotation({
    required String mapId,
    required String type,
    required String title,
    String? content,
    required double latitude,
    required double longitude,
    String color = '#3B82F6',
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      final response = await _client.from('map_annotations').insert({
        'map_id': mapId,
        'user_id': user.id,
        'type': type,
        'title': title,
        'content': content,
        'latitude': latitude,
        'longitude': longitude,
        'color': color,
      }).select('''
            id, type, title, content, latitude, longitude, color,
            created_at,
            user_profiles!user_id(full_name, avatar_url)
          ''').single();

      // Log the annotation creation activity
      await _logActivity('annotation_create', 'map_annotation', response['id']);

      return response;
    } catch (error) {
      throw Exception('Failed to create annotation: $error');
    }
  }

  /// Get maps by era with statistics
  Future<List<Map<String, dynamic>>> getMapsByEra() async {
    try {
      final response = await _client
          .from('historical_maps')
          .select('era')
          .eq('status', 'active');

      // Group by era and count
      final Map<String, int> eraCounts = {};
      for (final map in response) {
        final era = map['era'] as String;
        eraCounts[era] = (eraCounts[era] ?? 0) + 1;
      }

      return eraCounts.entries
          .map((entry) => {
                'era': entry.key,
                'count': entry.value,
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch era statistics: $error');
    }
  }

  /// Subscribe to real-time map updates
  RealtimeChannel subscribeToMapUpdates({
    required Function(Map<String, dynamic>) onMapInsert,
    required Function(Map<String, dynamic>) onMapUpdate,
    required Function(Map<String, dynamic>) onMapDelete,
  }) {
    return _client
        .channel('public:historical_maps')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'historical_maps',
          callback: (payload) => onMapInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'historical_maps',
          callback: (payload) => onMapUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'historical_maps',
          callback: (payload) => onMapDelete(payload.oldRecord),
        )
        .subscribe();
  }

  /// Subscribe to real-time annotation updates for a specific map
  RealtimeChannel subscribeToAnnotationUpdates(
    String mapId, {
    required Function(Map<String, dynamic>) onAnnotationInsert,
    required Function(Map<String, dynamic>) onAnnotationUpdate,
    required Function(Map<String, dynamic>) onAnnotationDelete,
  }) {
    return _client
        .channel('public:map_annotations:map_id=eq.$mapId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'map_annotations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'map_id',
            value: mapId,
          ),
          callback: (payload) => onAnnotationInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'map_annotations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'map_id',
            value: mapId,
          ),
          callback: (payload) => onAnnotationUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'map_annotations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'map_id',
            value: mapId,
          ),
          callback: (payload) => onAnnotationDelete(payload.oldRecord),
        )
        .subscribe();
  }

  /// Log user activity for analytics
  Future<void> _logActivity(
      String activityType, String resourceType, String resourceId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      await _client.from('user_activities').insert({
        'user_id': user.id,
        'activity_type': activityType,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'metadata': {
          'timestamp': DateTime.now().toIso8601String(),
          'user_agent': 'Flutter App',
        },
      });
    } catch (error) {
      // Silently fail activity logging to not disrupt main functionality
      print('Activity logging failed: $error');
    }
  }
}