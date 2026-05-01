import 'package:flutter/material.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/ArtifactsPageView.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/model/Artifacts.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/services/artifact_service.dart';

/// Example of how to use ArtifactService to load artifacts from JSON
/// and display them in ArtifactsPageView

class ExampleArtifactsPage extends StatefulWidget {
  const ExampleArtifactsPage({super.key});

  @override
  State<ExampleArtifactsPage> createState() => _ExampleArtifactsPageState();
}

class _ExampleArtifactsPageState extends State<ExampleArtifactsPage> {
  List<Artifact> artifacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtifacts();
  }

  Future<void> _loadArtifacts() async {
    // Load artifacts from the JSON file
    final loadedArtifacts = await ArtifactService.loadDefaultArtifacts();

    setState(() {
      artifacts = loadedArtifacts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ArtifactsPageView(
      artifacts: artifacts,
      countryName: 'France',
    );
  }
}

/// Alternative: Load artifacts in a FutureBuilder
class ExampleArtifactsPageWithFutureBuilder extends StatelessWidget {
  const ExampleArtifactsPageWithFutureBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Artifact>>(
      future: ArtifactService.loadDefaultArtifacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading artifacts: ${snapshot.error}'),
            ),
          );
        }

        final artifacts = snapshot.data ?? [];

        return ArtifactsPageView(
          artifacts: artifacts,
          countryName: 'France',
        );
      },
    );
  }
}
