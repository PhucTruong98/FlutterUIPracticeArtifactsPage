import 'package:flutter/material.dart';
import 'package:practice1/shared/component/bigComponent/artifacts/model/Artifacts.dart';

class ArtifactWidget extends StatefulWidget {

  final Artifact artifact;


  const ArtifactWidget({super.key, required this.artifact});

  @override
  State<ArtifactWidget> createState() => _ArtifactWidgetState();
}

class _ArtifactWidgetState extends State<ArtifactWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}