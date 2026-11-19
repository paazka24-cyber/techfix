import 'package:flutter/material.dart';

class ImageGallery extends StatelessWidget {
  final List<String> urls;
  const ImageGallery({super.key, required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const Text('No photos attached.');
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => Dialog(
              child:
                  InteractiveViewer(child: _img(urls[i], fit: BoxFit.contain)),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 110, height: 110, child: _img(urls[i])),
          ),
        ),
      ),
    );
  }

  Widget _img(String url, {BoxFit fit = BoxFit.cover}) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (c, child, p) => p == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)),
    );
  }
}
