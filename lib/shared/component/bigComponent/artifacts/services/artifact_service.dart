import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/model/Artifacts.dart';

class ArtifactService {
  /// Load artifacts from a JSON file in assets
  static Future<List<Artifact>> loadArtifactsFromJson(String jsonPath) async {
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString(jsonPath);

      // Parse the JSON
      final List<dynamic> data = json.decode(response);

      // Convert each JSON object to an Artifact
      final List<Artifact> artifacts = data
          .map((json) => Artifact.fromJson(json as Map<String, dynamic>))
          .toList();

      return artifacts;
    } catch (e) {
      print('Error loading artifacts from JSON: $e');
      return [];
    }
  }
static Future<List<List<Artifact>>> loadArtifactSortedByName() async {
  try {
    final allArtifacts = await loadArtifactsFromJson("assets/artifacts.json");

    final Map<String, List<Artifact>> grouped = {};

    for (final artifact in allArtifacts) {
      grouped.putIfAbsent(artifact.country, () => []).add(artifact);
    }

    return grouped.values.toList();
  } catch (e) {
    print('Error loading artifacts from JSON: $e');
    return [];
  }
}

  /// Load default artifacts (from assets/artifacts.json)
  static Future<List<Artifact>> loadDefaultArtifacts() async {
    return loadArtifactsFromJson('assets/artifacts.json');
  }
}
