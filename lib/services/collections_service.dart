import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

/// Service for managing collections and their associated maps
class CollectionsService {
  static CollectionsService? _instance;
  static CollectionsService get instance =>
      _instance ??= CollectionsService._();

  CollectionsService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get all collections (public + user's own collections if authenticated)
  Future<List<Map<String, dynamic>>> getAllCollections({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      var query = _client.from('collections').select('''
            id, name, description, is_public, cover_image_url, created_at,
            user_profiles!owner_id(full_name, avatar_url)
          ''');

      final user = AuthService.instance.currentUser;
      if (user != null) {
        // Show public collections + user's own collections
        query = query.or('is_public.eq.true,owner_id.eq.${user.id}');
      } else {
        // Show only public collections for unauthenticated users
        query = query.eq('is_public', true);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to fetch collections: $error');
    }
  }

  /// Get user's own collections
  Future<List<Map<String, dynamic>>> getUserCollections() async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      final response = await _client.from('collections').select('''
            id, name, description, is_public, cover_image_url, created_at
          ''').eq('owner_id', user.id).order('created_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (error) {
      throw Exception('Failed to fetch user collections: $error');
    }
  }

  /// Get a specific collection with its maps
  Future<Map<String, dynamic>?> getCollectionWithMaps(
      String collectionId) async {
    try {
      final collectionResponse = await _client.from('collections').select('''
            id, name, description, is_public, cover_image_url, created_at,
            user_profiles!owner_id(full_name, avatar_url, role)
          ''').eq('id', collectionId).single();

      final mapsResponse = await _client
          .from('collection_maps')
          .select('''
            added_at,
            historical_maps!map_id(
              id, title, description, era, year_start, year_end,
              location_name, latitude, longitude, thumbnail_url,
              view_count, created_at
            )
          ''')
          .eq('collection_id', collectionId)
          .order('added_at', ascending: false);

      // Log the collection view activity
      await _logActivity('collection_view', 'collection', collectionId);

      return {
        ...collectionResponse,
        'maps': mapsResponse
            .map((item) => {
                  ...item['historical_maps'],
                  'added_at': item['added_at'],
                })
            .toList(),
      };
    } catch (error) {
      throw Exception('Failed to fetch collection details: $error');
    }
  }

  /// Create a new collection
  Future<Map<String, dynamic>> createCollection({
    required String name,
    String? description,
    bool isPublic = false,
    String? coverImageUrl,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      final response = await _client
          .from('collections')
          .insert({
            'name': name,
            'description': description,
            'owner_id': user.id,
            'is_public': isPublic,
            'cover_image_url': coverImageUrl,
          })
          .select()
          .single();

      // Log the collection creation activity
      await _logActivity('collection_create', 'collection', response['id']);

      return response;
    } catch (error) {
      throw Exception('Failed to create collection: $error');
    }
  }

  /// Update an existing collection
  Future<Map<String, dynamic>> updateCollection(
    String collectionId, {
    String? name,
    String? description,
    bool? isPublic,
    String? coverImageUrl,
  }) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (isPublic != null) updates['is_public'] = isPublic;
      if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;

      final response = await _client
          .from('collections')
          .update(updates)
          .eq('id', collectionId)
          .eq('owner_id', user.id)
          .select()
          .single();

      // Log the collection update activity
      await _logActivity('collection_update', 'collection', collectionId);

      return response;
    } catch (error) {
      throw Exception('Failed to update collection: $error');
    }
  }

  /// Delete a collection
  Future<void> deleteCollection(String collectionId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      await _client
          .from('collections')
          .delete()
          .eq('id', collectionId)
          .eq('owner_id', user.id);

      // Log the collection deletion activity
      await _logActivity('collection_delete', 'collection', collectionId);
    } catch (error) {
      throw Exception('Failed to delete collection: $error');
    }
  }

  /// Add a map to a collection
  Future<void> addMapToCollection(String collectionId, String mapId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      // Verify the user owns the collection
      final collection = await _client
          .from('collections')
          .select('owner_id')
          .eq('id', collectionId)
          .eq('owner_id', user.id)
          .single();

      await _client.from('collection_maps').insert({
        'collection_id': collectionId,
        'map_id': mapId,
      });

      // Log the activity
      await _logActivity(
          'map_add_to_collection', 'collection_map', '$collectionId:$mapId');
    } catch (error) {
      if (error.toString().contains('duplicate key')) {
        throw Exception('Map already exists in this collection');
      }
      throw Exception('Failed to add map to collection: $error');
    }
  }

  /// Remove a map from a collection
  Future<void> removeMapFromCollection(
      String collectionId, String mapId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('Authentication required');

    try {
      // Verify the user owns the collection
      final collection = await _client
          .from('collections')
          .select('owner_id')
          .eq('id', collectionId)
          .eq('owner_id', user.id)
          .single();

      await _client
          .from('collection_maps')
          .delete()
          .eq('collection_id', collectionId)
          .eq('map_id', mapId);

      // Log the activity
      await _logActivity('map_remove_from_collection', 'collection_map',
          '$collectionId:$mapId');
    } catch (error) {
      throw Exception('Failed to remove map from collection: $error');
    }
  }

  /// Subscribe to real-time collection updates
  RealtimeChannel subscribeToCollectionUpdates({
    required Function(Map<String, dynamic>) onCollectionInsert,
    required Function(Map<String, dynamic>) onCollectionUpdate,
    required Function(Map<String, dynamic>) onCollectionDelete,
  }) {
    return _client
        .channel('public:collections')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'collections',
          callback: (payload) => onCollectionInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'collections',
          callback: (payload) => onCollectionUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'collections',
          callback: (payload) => onCollectionDelete(payload.oldRecord),
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
