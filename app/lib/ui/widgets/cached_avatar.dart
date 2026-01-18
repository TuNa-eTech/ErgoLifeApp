import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Cached network image widget with loading and error states
class CachedAvatar extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }
}

/// Cached network image provider for use with DecorationImage
CachedNetworkImageProvider cachedNetworkImageProvider(String imageUrl) {
  return CachedNetworkImageProvider(imageUrl);
}
