import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Maps an amenity name to a relevant Lucide icon.
IconData getAmenityIcon(String amenity) {
  final a = amenity.toLowerCase();
  if (a.contains('wifi') || a.contains('internet') || a.contains('broadband')) {
    return LucideIcons.wifi;
  }
  if (a.contains('generator') ||
      a.contains('nepa') ||
      a.contains('electricity') ||
      a.contains('prepaid')) {
    return LucideIcons.zap;
  }
  if (a.contains('water') ||
      a.contains('borehole') ||
      a.contains('running water')) {
    return LucideIcons.droplets;
  }
  if (a.contains('parking') || a.contains('garage') || a.contains('car')) {
    return LucideIcons.car_front;
  }
  if (a.contains('security') || a.contains('gateman') || a.contains('guard')) {
    return LucideIcons.shield_check;
  }
  if (a.contains('cctv') || a.contains('camera')) return LucideIcons.cctv;
  if (a.contains('air condition') || a.contains('ac') || a.contains('a/c')) {
    return LucideIcons.air_vent;
  }
  if (a.contains('fan') || a.contains('ceiling fan')) return LucideIcons.fan;
  if (a.contains('kitchen') ||
      a.contains('cooking') ||
      a.contains('cooker') ||
      a.contains('gas')) {
    return LucideIcons.utensils;
  }
  if (a.contains('fridge') ||
      a.contains('refrigerator') ||
      a.contains('freezer')) {
    return LucideIcons.refrigerator;
  }
  if (a.contains('microwave')) return LucideIcons.microwave;
  if (a.contains('tv') ||
      a.contains('television') ||
      a.contains('dstv') ||
      a.contains('cable')) {
    return LucideIcons.tv;
  }
  if (a.contains('wardrobe') || a.contains('closet')) {
    return LucideIcons.shirt;
  }
  if (a.contains('pop') ||
      a.contains('ceiling') ||
      a.contains('tiled') ||
      a.contains('floor')) {
    return LucideIcons.layers;
  }
  if (a.contains('bathroom') || a.contains('toilet') || a.contains('shower')) {
    return LucideIcons.shower_head;
  }
  if (a.contains('washing') || a.contains('laundry') || a.contains('washer')) {
    return LucideIcons.washing_machine;
  }
  if (a.contains('pet') || a.contains('animal')) return LucideIcons.paw_print;
  if (a.contains('balcony') ||
      a.contains('terrace') ||
      a.contains('garden') ||
      a.contains('compound')) {
    return LucideIcons.tree_pine;
  }
  if (a.contains('fence') || a.contains('gate')) return LucideIcons.fence;
  if (a.contains('gym') || a.contains('pool') || a.contains('swimming')) {
    return LucideIcons.dumbbell;
  }
  if (a.contains('elevator') || a.contains('lift')) {
    return LucideIcons.arrow_up_down;
  }
  if (a.contains('workspace') || a.contains('office') || a.contains('study')) {
    return LucideIcons.briefcase;
  }
  if (a.contains('furnish') || a.contains('furniture')) {
    return LucideIcons.sofa;
  }
  if (a.contains('smoke') || a.contains('alarm') || a.contains('fire')) {
    return LucideIcons.flame;
  }
  if (a.contains('solar') || a.contains('inverter')) {
    return LucideIcons.solar_panel;
  }
  if (a.contains('waste') || a.contains('garbage') || a.contains('trash')) {
    return LucideIcons.trash;
  }
  if (a.contains('cleaning')) {
    return LucideIcons.sparkles;
  }
  return LucideIcons.circle_check; // Generic fallback
}

/// Auto-categorises an amenity name into a display group heading.
String getAmenityCategory(String amenity) {
  final a = amenity.toLowerCase();
  if (a.contains('wifi') ||
      a.contains('internet') ||
      a.contains('broadband') ||
      a.contains('tv') ||
      a.contains('dstv') ||
      a.contains('cable') ||
      a.contains('television')) {
    return 'Internet & Entertainment';
  }
  if (a.contains('power') ||
      a.contains('generator') ||
      a.contains('nepa') ||
      a.contains('electricity') ||
      a.contains('prepaid') ||
      a.contains('meter')) {
    return 'Power Supply';
  }
  if (a.contains('water') ||
      a.contains('borehole') ||
      a.contains('running water')) {
    return 'Water Supply';
  }
  if (a.contains('security') ||
      a.contains('gateman') ||
      a.contains('guard') ||
      a.contains('cctv') ||
      a.contains('camera') ||
      a.contains('fence') ||
      a.contains('alarm')) {
    return 'Safety & Security';
  }
  if (a.contains('parking') ||
      a.contains('garage') ||
      a.contains('car space')) {
    return 'Parking';
  }
  if (a.contains('air condition') ||
      a.contains('ac') ||
      a.contains('a/c') ||
      a.contains('fan') ||
      a.contains('ceiling fan') ||
      a.contains('heating')) {
    return 'Heating & Cooling';
  }
  if (a.contains('kitchen') ||
      a.contains('cooking') ||
      a.contains('cooker') ||
      a.contains('fridge') ||
      a.contains('refrigerator') ||
      a.contains('freezer') ||
      a.contains('microwave') ||
      a.contains('gas') ||
      a.contains('oven')) {
    return 'Kitchen & Dining';
  }
  if (a.contains('bathroom') ||
      a.contains('toilet') ||
      a.contains('shower') ||
      a.contains('bathtub') ||
      a.contains('restroom')) {
    return 'Bathroom';
  }
  if (a.contains('wardrobe') ||
      a.contains('closet') ||
      a.contains('washing') ||
      a.contains('laundry') ||
      a.contains('washer')) {
    return 'Bedroom & Laundry';
  }
  if (a.contains('gym') ||
      a.contains('pool') ||
      a.contains('swimming') ||
      a.contains('sport') ||
      a.contains('recreation')) {
    return 'Recreation';
  }
  if (a.contains('balcony') ||
      a.contains('terrace') ||
      a.contains('garden') ||
      a.contains('compound') ||
      a.contains('outdoor')) {
    return 'Outdoor Spaces';
  }
  return 'Other Features';
}
