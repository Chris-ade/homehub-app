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
  final String streetName;
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

  Property({
    required this.id,
    required this.title,
    required this.area,
    this.streetName = "",
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
  })  : gallery = gallery ?? [image],
        description = description ??
            "A beautifully presented and spacious property located in a secure, serene environment. Features modern finishes, 24/7 power supply options, consistent running water, and gated security.",
        amenities = amenities ??
            [
              "24/7 Security",
              "Solar Backup Power",
              "Fitted Kitchen",
              "Car Parking",
              "Constant Water Supply",
              "High-Speed Wi-Fi",
              "Gated Compound",
              "Private Balcony"
            ];

  factory Property.fromJson(Map<String, dynamic> json) {
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

    final rawPrice = json['rent_amount'] ?? json['rentAmount'] ?? json['price'] ?? 0;
    final double parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;

    final cityRaw = (json['city'] ?? json['city_slug'] ?? json['citySlug'] ?? 'ado-ekiti').toString().toLowerCase();

    final String typeRaw = (json['type'] ?? json['property_type'] ?? json['propertyType'] ?? "Flat").toString().trim();
    final String parsedType = typeRaw.isNotEmpty
        ? (typeRaw[0].toUpperCase() + typeRaw.substring(1))
        : "Flat";

    return Property(
      id: json['id']?.toString() ?? "prop_${DateTime.now().millisecondsSinceEpoch}",
      title: (json['title'] != null && json['title'].toString().isNotEmpty)
          ? json['title'].toString()
          : "Modern Rental Apartment",
      area: (json['address'] != null && json['address'].toString().isNotEmpty)
          ? json['address'].toString()
          : (json['area']?.toString() ?? "Adebayo, Ado-Ekiti"),
      streetName: json['street_name']?.toString() ?? json['streetName']?.toString() ?? "",
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
      rating: double.tryParse(json['rating']?.toString() ?? "4.8") ?? 4.8,
      isFeatured: json['verified'] == true || json['is_featured'] == true || json['isFeatured'] == true,
      isFavorite: json['is_favorite'] == true || json['isFavorite'] == true,
    );
  }
}
