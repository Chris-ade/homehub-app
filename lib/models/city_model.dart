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
}
