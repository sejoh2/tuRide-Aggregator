import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  // App and web links for all platforms
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

  static Uri _getWebUri(
    String platform,
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
  ) {
    switch (platform.toLowerCase()) {
      case 'uber':
        return Uri.parse(
          'https://m.uber.com/ul/?action=setPickup&pickup[latitude]=$pickupLat&pickup[longitude]=$pickupLng&dropoff[latitude]=$dropoffLat&dropoff[longitude]=$dropoffLng',
        );
      case 'bolt':
        return Uri.parse(
          'https://bolt.eu/en/ride/?pickup_latitude=$pickupLat&pickup_longitude=$pickupLng&destination_latitude=$dropoffLat&destination_longitude=$dropoffLng',
        );
      case 'yego':
        return Uri.parse(
          'https://yego.co.ke/ride?pickup_lat=$pickupLat&pickup_lng=$pickupLng&dropoff_lat=$dropoffLat&dropoff_lng=$dropoffLng',
        );
      case 'little':
        return Uri.parse(
          'https://little.africa/ride?pickup_lat=$pickupLat&pickup_lng=$pickupLng&dropoff_lat=$dropoffLat&dropoff_lng=$dropoffLng',
        );
      default:
        return Uri.parse('https://www.example.com');
    }
  }

  /// Open the ride app if installed, otherwise open the website
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
    final webUri = _getWebUri(
      platform,
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    );

    // Only try to launch app on mobile platforms
    if ((defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        await canLaunchUrl(appUri) &&
        appUri.toString().isNotEmpty) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to website
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Get App Store / Play Store links if the app is not installed
  static Map<String, String>? getAppStoreLinks(String platform) {
    switch (platform.toLowerCase()) {
      case 'uber':
        return {
          'android':
              'https://play.google.com/store/apps/details?id=com.ubercab',
          'ios': 'https://apps.apple.com/app/uber/id368677368',
        };
      case 'bolt':
        return {
          'android':
              'https://play.google.com/store/apps/details?id=ee.mtakso.client',
          'ios': 'https://apps.apple.com/app/bolt/id675033630',
        };
      case 'yego':
        return {
          'android':
              'https://play.google.com/store/apps/details?id=com.yego.app',
          'ios': 'https://apps.apple.com/app/yego/id1234567890',
        };
      case 'little':
        return {
          'android':
              'https://play.google.com/store/apps/details?id=africa.little.app',
          'ios': 'https://apps.apple.com/app/little/id1234567890',
        };
      default:
        return null;
    }
  }
}
