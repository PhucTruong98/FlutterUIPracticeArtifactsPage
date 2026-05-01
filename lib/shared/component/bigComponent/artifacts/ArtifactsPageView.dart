import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/model/Artifacts.dart';

class ArtifactsPageView extends StatefulWidget {
  final List<Artifact> artifacts;
  final String countryName;

  const ArtifactsPageView({
    super.key,
    required this.artifacts,
    required this.countryName,
  });

  @override
  State<ArtifactsPageView> createState() => _ArtifactsPageViewState();
}

class _ArtifactsPageViewState extends State<ArtifactsPageView> {
  int totalArtCount = 0;
  int ownedArtCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    totalArtCount = widget.artifacts.length;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: buildHeader()),
          buildArtifactsGrid()




        ],
      ),
    );
  }

  Widget buildHeader() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 7,

                child: Container(
                  margin: EdgeInsets.all(10),
                  height: 60,
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    wrapWords: false,
                    maxLines: 2,
                    minFontSize: 12, // prevents unreadable text
                    maxFontSize: 60,
                    overflow: TextOverflow.ellipsis, // fallback safety
                  
                    this.widget.countryName,
                    style: GoogleFonts.aboreto(
                      fontSize: 40, // max size
                      fontWeight: FontWeight.w700,
                      color: const Color.fromARGB(255, 255, 98, 98),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 219, 255, 220),
                      borderRadius: BorderRadius.circular(30)
                      
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                  ),

                ))
            ],
          ),

          //       //progress bar
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color.fromARGB(255, 211, 251, 190),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: 3 / 5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color.fromARGB(255, 123, 255, 83),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF58CC02).withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Center(child: Text("3/5")),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 5,

                        child: Container(color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget buildArtifactsGrid() {

      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8, // image + text balance), 
        

        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final artifact = widget.artifacts[index];
          return buildArtifactCard(artifact);
        },
        childCount: widget.artifacts.length
        
        
        ));
 }


Widget buildArtifactCard(Artifact artifact) {
  // final isOwned = artifact.obtained;
    final isOwned = true;

  final rarity = artifact.rarity;

  BoxDecoration decoration;

  switch (rarity) {
    case ArtifactRarity.legendary:
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Colors.purple,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.red,
          ],
        ),
      );
      break;

    case ArtifactRarity.rare:
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      );
      break;

    default:
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      );
  }

  return Container(
    decoration: decoration,
    child: Container(
      margin: const EdgeInsets.all(3), // creates glow border effect
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: isOwned
                  ? 
                  Image.asset(
                      "assets/souvenirsImages/sushiBoat.png",
                      fit: BoxFit.contain,
                    )

                 
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              isOwned ? artifact.name : "???",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
