import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  // App deep links
  static Uri _getAppUri(
    String platform,
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
  ) {
    switch (platform.toLowerCase()) {
      case 'uber':
        return Uri.parse(
          'uber://?action=setPickup&pickup[latitude]=$pickupLat&pickup[longitude]=$pickupLng&dropoff[latitude]=$dropoffLat&dropoff[longitude]=$dropoffLng',
        );

      case 'bolt':
        return Uri.parse(
          'bolt://ridepicker?pickup=$pickupLat,$pickupLng&destination=$dropoffLat,$dropoffLng',
        );

      case 'yego':
        return Uri.parse(
          'yego://ride?pickup=$pickupLat,$pickupLng&destination=$dropoffLat,$dropoffLng',
        );

      case 'little':
        return Uri.parse(
          'little://ride?pickup=$pickupLat,$pickupLng&destination=$dropoffLat,$dropoffLng',
        );

      default:
        return Uri.parse('');
    }
  }

  // Play Store links
  static String _getPlayStoreLink(String platform) {
    switch (platform.toLowerCase()) {
      case 'uber':
        return 'https://play.google.com/store/apps/details?id=com.ubercab';

      case 'bolt':
        return 'https://play.google.com/store/apps/details?id=ee.mtakso.client';

      case 'yego':
        return 'https://play.google.com/store/apps/details?id=com.yego.app';

      case 'little':
        return 'https://play.google.com/store/apps/details?id=africa.little.app';

      default:
        return 'https://play.google.com/store/';
    }
  }

  /// OPEN APP → IF NOT INSTALLED → GO TO PLAY STORE
  static Future<void> openRideApp(
    String platform,
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
  ) async {
    final appUri = _getAppUri(
      platform,
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    );

    final playStoreUrl = _getPlayStoreLink(platform);

    try {
      // 🔥 Try to launch app directly
      final bool launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // ❌ Failed → open Play Store
        await launchUrl(
          Uri.parse(playStoreUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // ❌ Deep link failed → open Play Store
      await launchUrl(
        Uri.parse(playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
