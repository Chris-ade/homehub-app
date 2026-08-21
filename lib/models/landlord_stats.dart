/// Statistics for a landlord's dashboard, parsed from the Go backend's
/// `GET /listings/landlord/stats` response.
///
/// The API also returns `totalViews` and `occupancyRate`, but those are
/// hardcoded to 0 on the backend (lead tracking isn't aggregated yet), so they
/// are intentionally omitted here — the dashboard doesn't show them.
class LandlordStats {
  final int totalProperties;
  final double monthlyRevenue;
  final int newListings;
  final int verifiedProperties;

  const LandlordStats({
    this.totalProperties = 0,
    this.monthlyRevenue = 0,
    this.newListings = 0,
    this.verifiedProperties = 0,
  });

  factory LandlordStats.fromJson(dynamic json) {
    if (json == null) return const LandlordStats();
    final m = json is Map ? json : <String, dynamic>{};

    double rev = 0;
    final rawRev = m['monthlyRevenue'] ?? m['monthly_revenue'];
    if (rawRev != null) rev = double.tryParse(rawRev.toString()) ?? 0;

    return LandlordStats(
      totalProperties: int.tryParse((m['totalProperties'] ?? 0).toString()) ?? 0,
      monthlyRevenue: rev,
      newListings: int.tryParse((m['newListings'] ?? 0).toString()) ?? 0,
      verifiedProperties:
          int.tryParse((m['verifiedProperties'] ?? 0).toString()) ?? 0,
    );
  }
}
