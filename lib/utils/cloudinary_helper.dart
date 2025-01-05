import '../config/cloudinary_config.dart';

class CloudinaryHelper {
  static String optimizeUrl(String originalUrl) {
    // Extract public ID from the original URL
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;
    final publicId = pathSegments.last.split('.').first;

    return 'https://res.cloudinary.com/${CloudinaryConfig.cloudName}/image/upload/'
        'f_auto,q_auto,w_500,h_500,c_fill,g_face/'
        '$publicId';
  }
} 