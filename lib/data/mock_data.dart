import '../models/property_model.dart';
import '../models/city_model.dart';
import '../models/booking_model.dart';

class MockData {
  static final List<Property> sampleListings = [
    Property(
      id: "rh-001",
      title: "3-Bedroom Garden Flat",
      area: "Adebayo, Ado-Ekiti",
      citySlug: "ado-ekiti",
      price: 1450000,
      period: "year",
      beds: 3,
      baths: 3,
      sqft: 1280,
      type: "Flat",
      status: "Verified",
      agent: const Agent(
        name: "Tunde Aluko",
        role: "Verified Agent",
        phone: "+234 803 456 7890",
      ),
      image:
          "https://images.unsplash.com/photo-1643297550841-1386b3a10612?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
      gallery: [
        "https://images.unsplash.com/photo-1643297550841-1386b3a10612?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
        "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=800&q=80",
      ],
      description:
          "Contemporary 3-bedroom flat in the serene Adebayo neighborhood. Fully tiled floors, pop ceilings, all bedrooms en-suite, solar invertor prep, standby generator connection, and 24/7 security guard.",
      amenities: [
        "Solar Inverter Setup",
        "24/7 Guarded Estate",
        "All En-Suite",
        "Fitted Kitchen",
        "Water Heater",
        "Balcony",
      ],
      isFeatured: true,
      rating: 4.9,
      reviewCount: 18,
    ),
    Property(
      id: "rh-002",
      title: "Modern 2-Bedroom Apartment",
      area: "Fajuyi, Ado-Ekiti",
      citySlug: "ado-ekiti",
      price: 950000,
      period: "year",
      beds: 2,
      baths: 2,
      sqft: 880,
      type: "Apartment",
      status: "New",
      agent: const Agent(
        name: "Bisi Adeyemi",
        role: "Landlord",
        phone: "+234 802 987 6543",
      ),
      image:
          "https://images.unsplash.com/photo-1628144688607-c373d8e3f31b?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
      gallery: [
        "https://images.unsplash.com/photo-1628144688607-c373d8e3f31b?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
        "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80",
      ],
      description:
          "Brand new 2-bedroom luxury apartment near Fajuyi Park. Ultra-modern finishing, built-in wardrobes, private balcony, secure parking, and clean pressurized borehole water.",
      amenities: [
        "Borehole Water",
        "Gated Security",
        "Modern Cabinets",
        "Private Balcony",
        "Paved Compound",
      ],
      isFeatured: true,
      rating: 4.7,
      reviewCount: 9,
    ),
    Property(
      id: "rh-003",
      title: "Self-Contained Apartment",
      area: "EKSU Road, Iworoko",
      citySlug: "iworoko-ekiti",
      price: 320000,
      period: "year",
      beds: 1,
      baths: 1,
      sqft: 420,
      type: "Self-contained",
      status: "Student-friendly",
      agent: const Agent(
        name: "Femi Olatunji",
        role: "Property Manager",
        phone: "+234 814 555 1234",
      ),
      image:
          "https://images.unsplash.com/photo-1777029017899-b7f30eec36cf?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
      gallery: [
        "https://images.unsplash.com/photo-1777029017899-b7f30eec36cf?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
        "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=800&q=80",
      ],
      description:
          "Ideal student/young professional studio flat located 3 minutes walk from EKSU main gate. Includes dedicated study desk, high speed fiber Wi-Fi access, perimeter electric fence, and prepaid meter.",
      amenities: [
        "High-Speed Wi-Fi",
        "Prepaid Meter",
        "3-min to EKSU",
        "Study Area",
        "CCTV Monitoring",
      ],
      isFeatured: false,
      rating: 4.6,
      reviewCount: 24,
    ),
    Property(
      id: "rh-004",
      title: "Furnished 4-Bedroom Duplex",
      area: "GRA, Ado-Ekiti",
      citySlug: "ado-ekiti",
      price: 3200000,
      period: "year",
      beds: 4,
      baths: 4,
      sqft: 2100,
      type: "Duplex",
      status: "Premium",
      agent: const Agent(
        name: "Yetunde Adekunle",
        role: "Verified Agent",
        phone: "+234 805 111 2233",
      ),
      image:
          "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
      gallery: [
        "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80",
      ],
      description:
          "Exquisite 4-bedroom detached duplex located in exclusive GRA, Ado-Ekiti. Features private swimming pool, boy's quarters (BQ), smart security lock system, solar power backup, and landscaped gardens.",
      amenities: [
        "Private Pool",
        "Boys Quarters",
        "Solar Hybrid System",
        "Smart Lock",
        "Ample Parking",
      ],
      isFeatured: true,
      rating: 5.0,
      reviewCount: 31,
    ),
    Property(
      id: "rh-005",
      title: "Mini Flat — Quiet Street",
      area: "Ajilosun, Ado-Ekiti",
      citySlug: "ado-ekiti",
      price: 480000,
      period: "year",
      beds: 1,
      baths: 1,
      sqft: 540,
      type: "Mini Flat",
      status: "Verified",
      agent: const Agent(
        name: "Kunle Bamidele",
        role: "Landlord",
        phone: "+234 813 999 8877",
      ),
      image:
          "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=800&q=80",
      description:
          "Neat mini flat in a quiet residential off-street in Ajilosun. Sitting room, bedroom, kitchen, and bathroom. Well maintained compound with individual electric meter.",
      amenities: [
        "Prepaid Meter",
        "Spacious Kitchen",
        "Paved Yard",
        "Quiet Street",
      ],
      isFeatured: false,
      rating: 4.5,
      reviewCount: 7,
    ),
    Property(
      id: "rh-006",
      title: "3-Bedroom Bungalow with BQ",
      area: "Ilawe Road, Ado-Ekiti",
      citySlug: "ado-ekiti",
      price: 1850000,
      period: "year",
      beds: 3,
      baths: 3,
      sqft: 1640,
      type: "Bungalow",
      status: "Family",
      agent: const Agent(
        name: "Adaeze Nwosu",
        role: "Verified Agent",
        phone: "+234 701 444 5566",
      ),
      image:
          "https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=800&q=80",
      description:
          "Family-friendly standalone 3-bedroom bungalow with an attached 1-bedroom BQ. Large compound suitable for multiple cars and gardening.",
      amenities: [
        "Standalone Compound",
        "1-Bed BQ",
        "Spacious Garden",
        "Water Treatment",
        "Security Post",
      ],
      isFeatured: true,
      rating: 4.8,
      reviewCount: 15,
    ),
  ];

  static final List<City> sampleCities = [
    const City(
      slug: "lagos",
      name: "Lagos",
      state: "Lagos State",
      live: true,
      tagline: "Nigeria's commercial capital and premier real estate market.",
      heroImage:
          "https://images.unsplash.com/photo-1577495508048-b635879837f1?auto=format&fit=crop&w=800&q=80",
      copy:
          "Lagos leads Nigeria's rental market across Victoria Island, Ikoyi, Lekki, Ikeja, and Surulere.",
      listingsCount: 420,
      stats: [
        CityStat(label: "Active listings", value: "420"),
        CityStat(label: "Avg. self-contained", value: "₦850k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦2.5M / yr"),
        CityStat(label: "Median time-to-rent", value: "7 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "Lekki Phase 1",
          vibe: "Upscale",
          copy: "Modern apartments, high security, vibrant nightlife.",
        ),
        Neighborhood(
          name: "Ikeja GRA",
          vibe: "Executive",
          copy: "Serene residential estates close to airport.",
        ),
      ],
    ),
    const City(
      slug: "abuja",
      name: "Abuja",
      state: "Federal Capital Territory",
      live: true,
      tagline: "The Federal Capital Territory with luxury housing & diplomatic zones.",
      heroImage:
          "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80",
      copy:
          "Abuja offers top-tier residential options across Maitama, Asokoro, Wuse II, and Gwarinpa.",
      listingsCount: 310,
      stats: [
        CityStat(label: "Active listings", value: "310"),
        CityStat(label: "Avg. self-contained", value: "₦900k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦3.0M / yr"),
        CityStat(label: "Median time-to-rent", value: "8 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "Wuse II",
          vibe: "Commercial",
          copy: "Bustling city centre with luxury flats.",
        ),
        Neighborhood(
          name: "Gwarinpa",
          vibe: "Family Estate",
          copy: "West Africa's largest housing estate.",
        ),
      ],
    ),
    const City(
      slug: "port-harcourt",
      name: "Port Harcourt",
      state: "Rivers State",
      live: true,
      tagline: "The Garden City & oil industry hub.",
      heroImage:
          "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80",
      copy:
          "High rental demand across GRA Phase 2, Peter Odili Road, and Trans-Amadi.",
      listingsCount: 195,
      stats: [
        CityStat(label: "Active listings", value: "195"),
        CityStat(label: "Avg. self-contained", value: "₦650k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦1.8M / yr"),
        CityStat(label: "Median time-to-rent", value: "10 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "GRA Phase 2",
          vibe: "Luxury",
          copy: "Exclusive residential area with top amenities.",
        ),
      ],
    ),
    const City(
      slug: "ado-ekiti",
      name: "Ado-Ekiti",
      state: "Ekiti State",
      live: true,
      tagline: "The state capital and busiest rental market in Ekiti.",
      heroImage:
          "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80",
      copy:
          "Ado-Ekiti combines government, business, and three major universities into one vibrant city. High demand across Adebayo, Fajuyi, and GRA.",
      listingsCount: 184,
      stats: [
        CityStat(label: "Active listings", value: "184"),
        CityStat(label: "Avg. studio rent", value: "₦380k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦950k / yr"),
        CityStat(label: "Median time-to-rent", value: "11 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "Adebayo",
          vibe: "Family",
          copy: "Quiet residential streets with Shoprite nearby.",
        ),
        Neighborhood(
          name: "Fajuyi",
          vibe: "Young pro",
          copy: "Central, walkable, packed with cafes.",
        ),
        Neighborhood(
          name: "GRA",
          vibe: "Premium",
          copy: "Exclusive gated estates and top-tier properties.",
        ),
        Neighborhood(
          name: "Ajilosun",
          vibe: "Mid-market",
          copy: "Affordable mid-market flats and bungalows.",
        ),
      ],
    ),
    const City(
      slug: "ikere-ekiti",
      name: "Ikere-Ekiti",
      state: "Ekiti State",
      live: true,
      tagline: "Historic town, growing rental scene around Federal Poly.",
      heroImage:
          "https://images.unsplash.com/photo-1572120360610-d971b9d7767c?auto=format&fit=crop&w=800&q=80",
      copy:
          "Ikere is a bustling education hub with steady demand for student housing and young professional apartments.",
      listingsCount: 62,
      stats: [
        CityStat(label: "Active listings", value: "62"),
        CityStat(label: "Avg. studio rent", value: "₦240k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦620k / yr"),
        CityStat(label: "Median time-to-rent", value: "9 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "Odo-Oja",
          vibe: "Town centre",
          copy: "Walking distance to major commercial hubs.",
        ),
        Neighborhood(
          name: "Afao Road",
          vibe: "Student",
          copy:
              "Self-contained apartments and mini-flats for polytechnic students.",
        ),
      ],
    ),
    const City(
      slug: "iworoko-ekiti",
      name: "Iworoko-Ekiti",
      state: "Ekiti State",
      live: true,
      tagline: "Home of EKSU. Where Ekiti's students live.",
      heroImage:
          "https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?auto=format&fit=crop&w=800&q=80",
      copy:
          "Student capital of Ekiti. Self-contained studios and shared apartments dominate with high turnover.",
      listingsCount: 41,
      stats: [
        CityStat(label: "Active listings", value: "41"),
        CityStat(label: "Avg. studio rent", value: "₦300k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦580k / yr"),
        CityStat(label: "Median time-to-rent", value: "5 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "EKSU Gate",
          vibe: "Student",
          copy: "Prime student location with Wi-Fi amenities.",
        ),
      ],
    ),
    const City(
      slug: "ikole-ekiti",
      name: "Ikole-Ekiti",
      state: "Ekiti State",
      live: true,
      tagline: "Agricultural heartland & rising student market.",
      heroImage:
          "https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=800&q=80",
      copy:
          "Lowest median rents in Ekiti with spacious plot sizes and steady growth around FUOYE campus.",
      listingsCount: 23,
      stats: [
        CityStat(label: "Active listings", value: "23"),
        CityStat(label: "Avg. studio rent", value: "₦180k / yr"),
        CityStat(label: "Avg. 2-bed rent", value: "₦420k / yr"),
        CityStat(label: "Median time-to-rent", value: "14 days"),
      ],
      neighborhoods: [
        Neighborhood(
          name: "FUOYE Campus Area",
          vibe: "Student",
          copy: "Newly built studios and shared units.",
        ),
      ],
    ),
    const City(
      slug: "lagos",
      name: "Lagos",
      state: "Lagos State",
      live: false,
      tagline: "Coming Q2 2026. Join the waitlist!",
      heroImage:
          "https://images.unsplash.com/photo-1577190036430-04ea1eaaaa00?auto=format&fit=crop&w=800&q=80",
      copy:
          "Expanding to Lekki, Yaba, Ikeja and Surulere with verified landlords and zero agency markups.",
      listingsCount: 0,
      stats: [CityStat(label: "Status", value: "Coming Q2 2026")],
      neighborhoods: [],
    ),
    const City(
      slug: "abuja",
      name: "Abuja",
      state: "FCT",
      live: false,
      tagline: "Coming Q2 2026. Join the waitlist!",
      heroImage:
          "https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?auto=format&fit=crop&w=800&q=80",
      copy: "Launching across Maitama, Wuse 2, Gwarinpa and Lugbe soon.",
      listingsCount: 0,
      stats: [CityStat(label: "Status", value: "Coming Q2 2026")],
      neighborhoods: [],
    ),
  ];

  static final List<Map<String, String>> testimonials = [
    {
      "name": "Damilola O.",
      "role": "Tenant, Ado-Ekiti",
      "quote":
          "I found a verified 2-bedroom flat in four days. The agent details were already confirmed — no wasted trips, no agent fees surprise.",
      "image":
          "https://images.unsplash.com/photo-1623244736886-1108836855e9?crop=entropy&cs=srgb&fm=jpg&w=200&q=80",
    },
    {
      "name": "Engr. Bolanle A.",
      "role": "Landlord, Ikere-Ekiti",
      "quote":
          "HomeHub filled two of my vacant units in under three weeks. Tenant screening is solid — I get to choose, not chance it.",
      "image":
          "https://images.unsplash.com/photo-1623244727304-54995b233b1c?crop=entropy&cs=srgb&fm=jpg&w=200&q=80",
    },
    {
      "name": "Tobi & Nkechi",
      "role": "Newly married, Fajuyi",
      "quote":
          "First home together. The virtual tours saved us hours commuting between viewings. We signed without ever feeling rushed.",
      "image":
          "https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=200&q=80",
    },
  ];

  static final List<Map<String, String>> faqs = [
    {
      "q": "Is HomeHub currently available outside Ekiti State?",
      "a":
          "We're focused on Ekiti State first — Ado-Ekiti, Ikere, Iworoko and Ikole. Lagos and Abuja roll out in 2026 as we onboard verified landlords.",
    },
    {
      "q": "Are listings on HomeHub verified?",
      "a":
          "Yes. Every landlord and agent goes through ID verification. Property ownership or management rights are confirmed before a listing goes live.",
    },
    {
      "q": "Does HomeHub charge tenants any agent fees?",
      "a":
          "Browsing, contacting landlords, and booking inspections is 100% free for tenants with zero hidden Cuts.",
    },
    {
      "q": "How does HomeHub Escrow payment work?",
      "a":
          "Rent payments are safely held in escrow and released to the landlord only after physical move-in inspection and key handover.",
    },
  ];

  static final List<InspectionBooking> initialBookings = [
    InspectionBooking(
      id: "bk-101",
      propertyId: "rh-001",
      propertyTitle: "3-Bedroom Garden Flat",
      propertyImage:
          "https://images.unsplash.com/photo-1643297550841-1386b3a10612?crop=entropy&cs=srgb&fm=jpg&w=800&q=80",
      area: "Adebayo, Ado-Ekiti",
      agentName: "Tunde Aluko",
      agentPhone: "+234 803 456 7890",
      date: DateTime.now().add(const Duration(days: 2)),
      timeSlot: "10:00 AM",
      inspectionType: "In-Person Viewing",
      status: InspectionStatus.confirmed,
    ),
  ];

  static final List<LeaseAgreement> initialLeases = [
    LeaseAgreement(
      id: "ls-501",
      propertyId: "rh-002",
      propertyTitle: "Modern 2-Bedroom Apartment",
      area: "Fajuyi, Ado-Ekiti",
      annualRent: 950000,
      securityDeposit: 100000,
      serviceCharge: 0,
      startDate: DateTime.now().add(const Duration(days: 7)),
      isSigned: true,
      signatureText: "Chris Dev",
      signedAt: DateTime.now().subtract(const Duration(days: 1)),
      escrowStatus: EscrowStatus.inEscrow,
    ),
  ];
}
