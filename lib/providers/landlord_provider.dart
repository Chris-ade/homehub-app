import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/landlord_stats.dart';
import '../models/property_model.dart';
import '../services/api_client.dart';

/// Owns the landlord dashboard's data: the authenticated agent's own listings
/// and their aggregate stats, plus create/update/delete + image upload.
///
/// All calls route through the shared [ApiClient] with `auth: true`, so an
/// expired access token is transparently refreshed and the request retried.
/// Agent-gated endpoints (POST /listings, /listings/landlord/...) return 403
/// for non-agent accounts — the UI only exposes this provider to users whose
/// `UserProvider.isLandlord` is true.
class LandlordProvider extends ChangeNotifier {
  LandlordProvider(this._api);

  final ApiClient _api;

  final List<Property> _myProperties = [];
  LandlordStats _stats = const LandlordStats();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _apiError;

  // Getters
  List<Property> get myProperties => _myProperties;
  LandlordStats get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get apiError => _apiError;

  /// Fetch the agent's own listings from GET /listings/landlord.
  Future<void> fetchMyProperties() async {
    _isLoading = true;
    _apiError = null;
    notifyListeners();

    try {
      final res = await _api.get('/listings/landlord', auth: true);
      if (res.ok) {
        final data = res.data;
        List<dynamic>? list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        }

        final fetched = <Property>[];
        if (list != null) {
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              try {
                fetched.add(Property.fromJson(item));
              } catch (_) {}
            }
          }
        }
        _myProperties
          ..clear()
          ..addAll(fetched);
      }
    } catch (_) {
      _apiError = "Could not load your properties.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch aggregate stats from GET /listings/landlord/stats.
  Future<void> fetchStats() async {
    try {
      final res = await _api.get('/listings/landlord/stats', auth: true);
      if (res.ok) {
        final data = res.data;
        _stats = LandlordStats.fromJson(
          data is Map ? (data['data'] ?? data) : null,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Convenience: fetch both listings and stats.
  Future<void> refresh() async {
    await Future.wait([fetchMyProperties(), fetchStats()]);
  }

  /// Create a listing via POST /listings. Returns the created property or null.
  Future<Property?> createListing(Map<String, dynamic> body) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final res = await _api.post('/listings', auth: true, body: body);
      if (res.isSuccess) {
        final data = res.data;
        final propMap = data is Map ? (data['data'] ?? data) : null;
        if (propMap is Map<String, dynamic>) {
          final created = Property.fromJson(propMap);
          _myProperties.insert(0, created);
          notifyListeners();
          return created;
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Update a listing via PUT /listings/:id. Returns the updated property or null.
  Future<Property?> updateListing(String id, Map<String, dynamic> body) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final res = await _api.put('/listings/$id', auth: true, body: body);
      if (res.isSuccess) {
        final data = res.data;
        final propMap = data is Map ? (data['data'] ?? data) : null;
        if (propMap is Map<String, dynamic>) {
          final updated = Property.fromJson(propMap);
          final i = _myProperties.indexWhere((p) => p.id == id);
          if (i != -1) {
            _myProperties[i] = updated;
          } else {
            _myProperties.insert(0, updated);
          }
          notifyListeners();
          return updated;
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Delete a listing via DELETE /listings/:id. Returns true on success.
  Future<bool> deleteListing(String id) async {
    try {
      final res = await _api.delete('/listings/$id', auth: true);
      if (res.isSuccess || res.ok) {
        _myProperties.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Upload local image files to Cloudinary via POST /listings/upload-images
  /// (multipart, one request per file, field `images`). Returns the Cloudinary
  /// URLs. Reuses [ApiClient.uploadFile] so auth + 401-retry are handled.
  Future<List<String>> uploadPropertyImages(List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        final res = await _api.uploadFile(
          '/listings/upload-images',
          field: 'images',
          bytes: bytes,
          filename: file.name.isNotEmpty ? file.name : 'property.jpg',
        );
        if (res.ok) {
          final data = res.data;
          final urlList =
              data is Map && data['data'] is Map && data['data']['urls'] is List
                  ? data['data']['urls'] as List
                  : null;
          if (urlList != null && urlList.isNotEmpty) {
            urls.addAll(urlList.map((u) => u.toString()));
          }
        }
      } catch (_) {}
    }
    return urls;
  }
}
