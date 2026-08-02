class Neighborhood {
  final String name;
  final String vibe;
  final String copy;

  const Neighborhood({
    required this.name,
    required this.vibe,
    required this.copy,
  });
}

class CityStat {
  final String label;
  final String value;

  const CityStat({required this.label, required this.value});
}

class City {
  final String slug;
  final String name;
  final String state;
  final bool live;
  final String tagline;
  final String heroImage;
  final String copy;
  final int listingsCount;
  final List<CityStat> stats;
  final List<Neighborhood> neighborhoods;

  const City({
    required this.slug,
    required this.name,
    required this.state,
    required this.live,
    required this.tagline,
    required this.heroImage,
    required this.copy,
    required this.listingsCount,
    required this.stats,
    required this.neighborhoods,
  });

  factory City.fromApiStat(Map<String, dynamic> json) {
    final rawCity = json['city'] ?? json['name'] ?? "Ado-Ekiti";
    final rawState = json['state'] ?? "Ekiti";
    final cityName = rawCity.toString().trim();
    final stateName = rawState.toString().trim();
    final count = int.tryParse((json['count'] ?? json['listings_count'] ?? "0").toString()) ?? 0;
    
    final cleanCity = cityName.isNotEmpty ? cityName : "Ado-Ekiti";
    final cleanState = stateName.isNotEmpty ? stateName : "Ekiti";
    final slug = cleanCity.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'(^-|-$)'), '');

    return City(
      slug: slug.isNotEmpty ? slug : "ado-ekiti",
      name: cleanCity,
      state: cleanState.endsWith("State") ? cleanState : "$cleanState State",
      live: count > 0,
      tagline: "Active market with verified listings",
      heroImage: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80",
      copy: "Discover verified rental properties directly from verified landlords in $cleanCity.",
      listingsCount: count,
      stats: [
        CityStat(label: "Active Listings", value: "$count"),
        const CityStat(label: "Avg. Rent / yr", value: "₦850k"),
        const CityStat(label: "Verified Hosts", value: "100%"),
      ],
      neighborhoods: const [],
    );
  }
}
