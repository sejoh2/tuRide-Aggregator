import 'package:url_launcher/url_launcher.dart';

class ScheduleDeepLink {
  // Deep link patterns for different platforms
  static const Map<String, DeepLinkConfig> _platformDeepLinks = {
    'Uber': DeepLinkConfig(
      appScheme: 'uber://',
      appStoreUrl: 'https://apps.apple.com/app/uber/id368677368',
      playStoreUrl: 'https://play.google.com/store/apps/details?id=com.ubercab',
      webUrl: 'https://m.uber.com',
    ),
    'Bolt': DeepLinkConfig(
      appScheme: 'bolt://',
      appStoreUrl: 'https://apps.apple.com/app/bolt/id675033630',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=ee.mtakso.client',
      webUrl: 'https://bolt.eu',
    ),
    'Little': DeepLinkConfig(
      appScheme: 'little://',
      appStoreUrl: 'https://apps.apple.com/app/little-cab/id1105390314',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.littlecab',
      webUrl: 'https://little.bz',
    ),
    'Faras': DeepLinkConfig(
      appScheme: 'faras://',
      appStoreUrl: 'https://apps.apple.com/app/faras-ride/id6479096967',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.faras.ride',
      webUrl: 'https://faras.app',
    ),
    'Yego': DeepLinkConfig(
      appScheme: 'yego://',
      appStoreUrl: 'https://apps.apple.com/app/yego-moto/id1566862161',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.yego.moto',
      webUrl: 'https://yego.rw',
    ),
  };

  /// Launch the ride-hailing app with pre-filled ride details
  static Future<void> launchRideApp({
    required String platform,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
  }) async {
    final config = _platformDeepLinks[platform];
    if (config == null) {
      throw Exception('Deep link not configured for platform: $platform');
    }

    // Try to open the app first
    final bool appLaunched = await _launchAppDeepLink(
      platform: platform,
      config: config,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupAddress: pickupAddress,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      destinationAddress: destinationAddress,
    );

    // If app not installed, open app store
    if (!appLaunched) {
      await _launchAppStore(platform, config);
    }
  }

  /// Try to launch the app with deep link
  static Future<bool> _launchAppDeepLink({
    required String platform,
    required DeepLinkConfig config,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double destinationLat,
    required double destinationLng,
    required String destinationAddress,
  }) async {
    try {
      String deepLinkUrl = '';

      // Platform-specific deep link formats
      switch (platform) {
        case 'Uber':
          deepLinkUrl =
              '${config.appScheme}'
              '?action=setPickup'
              '&pickup[latitude]=$pickupLat'
              '&pickup[longitude]=$pickupLng'
              '&pickup[nickname]=${Uri.encodeComponent(pickupAddress)}'
              '&dropoff[latitude]=$destinationLat'
              '&dropoff[longitude]=$destinationLng'
              '&dropoff[nickname]=${Uri.encodeComponent(destinationAddress)}'
              '&product_id=uberX';
          break;

        case 'Bolt':
          deepLinkUrl =
              '${config.appScheme}'
              'ride'
              '?pickup_lat=$pickupLat'
              '&pickup_lng=$pickupLng'
              '&pickup_name=${Uri.encodeComponent(pickupAddress)}'
              '&destination_lat=$destinationLat'
              '&destination_lng=$destinationLng'
              '&destination_name=${Uri.encodeComponent(destinationAddress)}';
          break;

        case 'Little':
          deepLinkUrl =
              '${config.appScheme}'
              'book'
              '?pickup_lat=$pickupLat'
              '&pickup_lng=$pickupLng'
              '&pickup_address=${Uri.encodeComponent(pickupAddress)}'
              '&dest_lat=$destinationLat'
              '&dest_lng=$destinationLng'
              '&dest_address=${Uri.encodeComponent(destinationAddress)}';
          break;

        case 'Faras':
          deepLinkUrl =
              '${config.appScheme}'
              'book-ride'
              '?pickup_lat=$pickupLat'
              '&pickup_lon=$pickupLng'
              '&pickup_name=${Uri.encodeComponent(pickupAddress)}'
              '&dest_lat=$destinationLat'
              '&dest_lon=$destinationLng'
              '&dest_name=${Uri.encodeComponent(destinationAddress)}';
          break;

        case 'Yego':
          deepLinkUrl =
              '${config.appScheme}'
              'order'
              '?pickup_latitude=$pickupLat'
              '&pickup_longitude=$pickupLng'
              '&pickup_location=${Uri.encodeComponent(pickupAddress)}'
              '&destination_latitude=$destinationLat'
              '&destination_longitude=$destinationLng'
              '&destination_location=${Uri.encodeComponent(destinationAddress)}';
          break;

        default:
          deepLinkUrl = config.appScheme;
      }

      final uri = Uri.parse(deepLinkUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      print('Error launching app deep link: $e');
      return false;
    }
  }

  /// Launch app store if app is not installed
  static Future<void> _launchAppStore(
    String platform,
    DeepLinkConfig config,
  ) async {
    try {
      // Determine if Android or iOS and use appropriate store URL
      String storeUrl = config.playStoreUrl; // Default to Play Store

      // You can add platform detection here if needed
      // For now, we'll use Play Store as default

      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web URL
        final webUri = Uri.parse(config.webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Error launching app store: $e');
      // Final fallback - open web URL
      try {
        final webUri = Uri.parse(config.webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Error launching web URL: $e');
      }
    }
  }

  /// Check if a specific ride platform app is installed
  static Future<bool> isAppInstalled(String platform) async {
    final config = _platformDeepLinks[platform];
    if (config == null) return false;

    try {
      final uri = Uri.parse(config.appScheme);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Get all supported platforms with deep linking
  static List<String> getSupportedPlatforms() {
    return _platformDeepLinks.keys.toList();
  }
}

class DeepLinkConfig {
  final String appScheme;
  final String appStoreUrl;
  final String playStoreUrl;
  final String webUrl;

  const DeepLinkConfig({
    required this.appScheme,
    required this.appStoreUrl,
    required this.playStoreUrl,
    required this.webUrl,
  });
}
