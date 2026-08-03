class Agent {
  final String name;
  final String phone;
  final String avatarUrl;
  final bool isVerified;
  final String role; // 'Landlord' or 'Verified Agent'

  const Agent({
    required this.name,
    this.phone = "+234 803 123 4567",
    this.avatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
    this.isVerified = true,
    this.role = "Verified Agent",
  });

  factory Agent.fromJson(dynamic json) {
    if (json == null) {
      return const Agent(name: "Verified Agent");
    }
    if (json is String) {
      return Agent(name: json.isNotEmpty ? json : "Verified Agent");
    }
    if (json is Map) {
      final firstName = json['first_name'] ?? json['firstName'] ?? '';
      final lastName = json['last_name'] ?? json['lastName'] ?? '';
      final nameStr = "$firstName $lastName".trim();
      final finalName = nameStr.isNotEmpty ? nameStr : (json['name']?.toString() ?? "Verified Agent");
      return Agent(
        name: finalName,
        phone: json['phone']?.toString() ?? json['mobileNo']?.toString() ?? "+234 803 123 4567",
        avatarUrl: (json['avatar'] != null && json['avatar'].toString().isNotEmpty)
            ? json['avatar'].toString()
            : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
        isVerified: json['verified'] == true || json['is_verified'] == true,
        role: json['type'] == 'landlord' ? "Landlord" : "Verified Agent",
      );
    }
    return const Agent(name: "Verified Agent");
  }
}

class Property {
  final String id;
  final String title;
  final String area;
  final String houseNumber;
  final String streetName;
  final String _city;
  final String _state;
  final String citySlug;
  final double price;
  final String period; // 'year' or 'month'
  final int beds;
  final int baths;
  final int sqft;
  final String type; // 'Flat', 'Apartment', 'Self-contained', 'Hostel', 'Single Room', 'Duplex', 'Mini Flat', 'Bungalow'
  final String status; // 'Verified', 'New', 'Student-friendly', 'Premium', 'Family'
  final Agent agent;
  final String image;
  final List<String> gallery;
  final String description;
  final List<String> amenities;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final bool isFeatured;
  bool isFavorite;
  final DateTime? availableFrom;

  String get city => _city.isNotEmpty ? _city : "Ado Ekiti";
  String get state => _state.isNotEmpty ? _state : "Ekiti";
  DateTime get availableDate => availableFrom ?? DateTime.now();

  Property({
    required this.id,
    required this.title,
    required this.area,
    this.houseNumber = "",
    this.streetName = "",
    String? city,
    String? state,
    required this.citySlug,
    required this.price,
    this.period = "year",
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.type,
    required this.status,
    required this.agent,
    required this.image,
    List<String>? gallery,
    String? description,
    List<String>? amenities,
    this.rating = 4.8,
    this.reviewCount = 12,
    this.latitude = 7.6231,
    this.longitude = 5.2188,
    this.isFeatured = false,
    this.isFavorite = false,
    this.availableFrom,
  })  : _city = city ?? "Ado Ekiti",
        _state = state ?? "Ekiti",
        gallery = gallery ?? [image],
        description = description ??
            "A beautifully presented and spacious property located in a secure, serene environment. Features modern finishes, 24/7 power supply options, consistent running water, and gated security.",
        amenities = amenities ?? const [];

  factory Property.fromJson(Map<String, dynamic> json) {
    if (json['data'] is Map<String, dynamic>) {
      json = json['data'] as Map<String, dynamic>;
    }
    const String defaultImg = "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop";

    // Extract primary image URL safely
    String mainImage = defaultImg;
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final firstImg = (json['images'] as List).first;
      if (firstImg is Map && firstImg['url'] != null && firstImg['url'].toString().isNotEmpty) {
        mainImage = firstImg['url'].toString();
      } else if (firstImg is String && firstImg.isNotEmpty) {
        mainImage = firstImg;
      }
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      mainImage = json['image'].toString();
    }

    if (mainImage.startsWith('/')) {
      mainImage = "https://rentalhub-api-0kuk.onrender.com$mainImage";
    }

    // Extract gallery URLs safely
    List<String> galList = [mainImage];
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      final parsedGallery = <String>[];
      for (var img in (json['images'] as List)) {
        String url = "";
        if (img is Map && img['url'] != null) {
          url = img['url'].toString();
        } else if (img is String) {
          url = img;
        }
        if (url.isNotEmpty) {
          if (url.startsWith('/')) url = "https://rentalhub-api-0kuk.onrender.com$url";
          parsedGallery.add(url);
        }
      }
      if (parsedGallery.isNotEmpty) galList = parsedGallery;
    }

    // Extract amenities dynamically from API payload
    List<String> parsedAmenities = [];
    if (json['amenities'] is List) {
      for (var item in (json['amenities'] as List)) {
        if (item is Map && item['name'] != null && item['name'].toString().isNotEmpty) {
          parsedAmenities.add(item['name'].toString());
        } else if (item is String && item.isNotEmpty) {
          parsedAmenities.add(item);
        }
      }
    }

    final rawPrice = json['rent_amount'] ?? json['rentAmount'] ?? json['price'] ?? 0;
    final double parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;

    final String cityVal = (json['city'] ?? json['city_slug'] ?? json['citySlug'] ?? 'Ado Ekiti').toString();
    final String stateVal = (json['state'] ?? 'Ekiti').toString();
    final String streetVal = (json['street_name'] ?? json['streetName'] ?? '').toString();
    final String houseNoVal = (json['house_number'] ?? json['houseNumber'] ?? '').toString();

    String addressVal = (json['address'] != null && json['address'].toString().isNotEmpty)
        ? json['address'].toString()
        : [houseNoVal, streetVal].where((s) => s.isNotEmpty).join(", ");
    if (addressVal.isEmpty) addressVal = "$streetVal, $cityVal".trim();

    final String cityRaw = cityVal.toLowerCase();

    final String typeRaw = (json['type'] ?? json['property_type'] ?? json['propertyType'] ?? "Flat").toString().trim();
    final String parsedType = typeRaw.isNotEmpty
        ? (typeRaw[0].toUpperCase() + typeRaw.substring(1))
        : "Flat";

    // Resolve latitude and longitude coordinates dynamically from house_number, street_name, city & state
    double resolvedLat = double.tryParse(json['latitude']?.toString() ?? "") ?? 0.0;
    double resolvedLng = double.tryParse(json['longitude']?.toString() ?? "") ?? 0.0;

    if (resolvedLat == 0.0 || resolvedLng == 0.0) {
      final locKey = "$cityVal $stateVal".toLowerCase();
      if (locKey.contains("lagos")) {
        resolvedLat = 6.5244; resolvedLng = 3.3792;
      } else if (locKey.contains("abuja") || locKey.contains("fct")) {
        resolvedLat = 9.0765; resolvedLng = 7.3986;
      } else if (locKey.contains("port harcourt") || locKey.contains("rivers")) {
        resolvedLat = 4.8156; resolvedLng = 7.0498;
      } else if (locKey.contains("ibadan") || locKey.contains("oyo")) {
        resolvedLat = 7.3775; resolvedLng = 3.9470;
      } else if (locKey.contains("benin") || locKey.contains("edo")) {
        resolvedLat = 6.3350; resolvedLng = 5.6037;
      } else if (locKey.contains("enugu")) {
        resolvedLat = 6.4584; resolvedLng = 7.5464;
      } else if (locKey.contains("akure") || locKey.contains("ondo")) {
        resolvedLat = 7.2571; resolvedLng = 5.2058;
      } else if (locKey.contains("osogbo") || locKey.contains("osun")) {
        resolvedLat = 7.7827; resolvedLng = 4.5418;
      } else if (locKey.contains("abeokuta") || locKey.contains("ogun")) {
        resolvedLat = 7.1475; resolvedLng = 3.3619;
      } else if (locKey.contains("ikere")) {
        resolvedLat = 7.4984; resolvedLng = 5.2311;
      } else if (locKey.contains("iworoko")) {
        resolvedLat = 7.7123; resolvedLng = 5.2612;
      } else if (locKey.contains("ikole")) {
        resolvedLat = 7.7981; resolvedLng = 5.5142;
      } else {
        resolvedLat = 7.6231; resolvedLng = 5.2188;
      }

      // Add deterministic offset per street name so different streets pin accurately across the city map
      final int strHash = streetVal.hashCode.abs();
      final double offsetLat = ((strHash % 100) - 50) * 0.00015;
      final double offsetLng = (((strHash ~/ 100) % 100) - 50) * 0.00015;
      resolvedLat += offsetLat;
      resolvedLng += offsetLng;
    }

    return Property(
      id: json['id']?.toString() ?? "prop_${DateTime.now().millisecondsSinceEpoch}",
      title: (json['title'] != null && json['title'].toString().isNotEmpty)
          ? json['title'].toString()
          : "Modern Rental Apartment",
      area: addressVal,
      houseNumber: houseNoVal,
      streetName: streetVal,
      city: cityVal,
      state: stateVal,
      citySlug: cityRaw.contains("ikere")
          ? "ikere-ekiti"
          : (cityRaw.contains("iworoko")
              ? "iworoko-ekiti"
              : (cityRaw.contains("ikole") ? "ikole-ekiti" : "ado-ekiti")),
      price: parsedPrice,
      period: (json['rent_period'] ?? json['rentPeriod'] ?? "year").toString().contains("month") ? "month" : "year",
      beds: int.tryParse(json['bedrooms']?.toString() ?? json['beds']?.toString() ?? "2") ?? 2,
      baths: int.tryParse(json['bathrooms']?.toString() ?? json['baths']?.toString() ?? "2") ?? 2,
      sqft: int.tryParse(json['sqft']?.toString() ?? "900") ?? 900,
      type: parsedType,
      status: (json['verified'] == true) ? "Verified" : ((json['is_new'] == true) ? "New" : "Verified"),
      agent: Agent.fromJson(json['user'] ?? json['listed_by'] ?? json['listedBy']),
      image: mainImage,
      gallery: galList,
      description: json['description']?.toString(),
      amenities: parsedAmenities,
      rating: double.tryParse(json['rating']?.toString() ?? "4.8") ?? 4.8,
      latitude: resolvedLat,
      longitude: resolvedLng,
      isFeatured: json['verified'] == true || json['is_featured'] == true || json['isFeatured'] == true,
      isFavorite: json['is_favorite'] == true || json['isFavorite'] == true,
      availableFrom: (json['available_from'] != null || json['availableFrom'] != null)
          ? DateTime.tryParse((json['available_from'] ?? json['availableFrom']).toString())
          : null,
    );
  }
}
