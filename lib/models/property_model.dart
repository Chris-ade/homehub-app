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
}

class Property {
  final String id;
  final String title;
  final String area;
  final String citySlug;
  final double price;
  final String period; // 'year' or 'month'
  final int beds;
  final int baths;
  final int sqft;
  final String type; // 'Flat', 'Apartment', 'Studio', 'Duplex', 'Mini Flat', 'Bungalow'
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
}
