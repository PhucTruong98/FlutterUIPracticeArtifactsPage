import 'package:flutter/material.dart';

class Artifact {

  final String id;
  final Icon icon;
  final bool obtained;
  final ArtifactRarity rarity;
  final String description;
  final ArtifactCategory category;
  final List<String> detailFacts;
  final String name;
  final String country;


  



  Artifact({
    required this.id,
    required this.icon,
    required this.obtained,
    required this.rarity,
    required this.description,
    required this.category,
    required this.detailFacts, required this.name, required this.country,


    });

  // Factory constructor to create an Artifact from JSON
  factory Artifact.fromJson(Map<String, dynamic> json) {
    return Artifact(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,

      icon: Icon(
        IconData(
          json['iconCodePoint'] as int,
          fontFamily: 'MaterialIcons',
        ),
      ),
      obtained: json['obtained'] as bool,
      rarity: ArtifactRarity.values.firstWhere(
        (e) => e.toString().split('.').last == json['rarity'],
      ),
      description: json['description'] as String,
      category: ArtifactCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      detailFacts: List<String>.from(json['detailFacts'] as List)
    );
  }

  // Convert Artifact to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'iconCodePoint': icon.icon?.codePoint,
      'obtained': obtained,
      'rarity': rarity.toString().split('.').last,
      'description': description,
      'category': category.toString().split('.').last,
      'detailFacts': detailFacts,
    };
  }


}


enum ArtifactRarity {
  common,
  rare,
  epic,
  legendary,
}

enum ArtifactCategory {
  cuisine,
  landmark,
  culture,
  clothing,
  animal,
  plant
}