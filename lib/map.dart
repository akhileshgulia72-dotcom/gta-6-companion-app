import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: PhotoView(
        imageProvider: const AssetImage(
          'assets/images/map_image.png',
        ),
        backgroundDecoration:
            const BoxDecoration(
          color: Colors.black,
        ),
        initialScale:
            PhotoViewComputedScale.covered,
        minScale:
            PhotoViewComputedScale.contained,
        maxScale:
            PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}