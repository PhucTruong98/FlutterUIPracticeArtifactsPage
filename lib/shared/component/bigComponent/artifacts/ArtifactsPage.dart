import 'package:flutter/material.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/ArtifactsPageView.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/model/Artifacts.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/services/artifact_service.dart';

class ArtifactsPage extends StatefulWidget {
  const ArtifactsPage({super.key});

  @override
  State<ArtifactsPage> createState() => _ArtifactsPageState();
}

class _ArtifactsPageState extends State<ArtifactsPage> {

  late PageController _pageController;
  List<List<Artifact>> artifacts = [];
  bool isLoading = true;

  int _currentCountryIndex = 0;


  Future<void> _loadArtifacts() async {
    // Load artifacts from the JSON file
    final loadedArtifacts = await ArtifactService.loadArtifactSortedByName();

    setState(() {
      artifacts = loadedArtifacts;
      isLoading = false;
    });
  }

@override
  void initState() {
    // TODO: implement initState
        super.initState();

    _pageController = PageController(initialPage: 1);
    _loadArtifacts();
  }

  void _onPageChanged(int index) {
        setState(() {
      _currentCountryIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(

        children: [

          PageView.builder(
            controller: _pageController,
            itemCount: artifacts.length,
            onPageChanged: _onPageChanged,

            itemBuilder: (context, index)  {
              return ArtifactsPageView(
                artifacts: artifacts[index], 
                countryName: artifacts[index][0].country);
              // return Text("Artifacts Page");
            },
          ),

          Positioned(child: Container(

          ))
        ],
      ),
    );
  }
}