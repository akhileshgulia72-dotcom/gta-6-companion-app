import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;


  static const String adUnitId =
      "ca-app-pub-7694497723149363/4829954140";

  /// Load Rewarded Ad
  static void loadRewardedAd() {
    if (_isLoading) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isLoading = false;

          debugPrint("Rewarded Ad Loaded");

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              _rewardedAd = null;

              // Preload the next ad
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (
              RewardedAd ad,
              AdError error,
            ) {
              ad.dispose();
              _rewardedAd = null;

              loadRewardedAd();
            },
          );
        },

        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isLoading = false;

          debugPrint("Rewarded Ad Failed: $error");
        },
      ),
    );
  }

  /// Show Rewarded Ad
  static Future<void> showRewardedAd({
    required VoidCallback onReward,
  }) async {
    if (_rewardedAd == null) {
      debugPrint("Rewarded ad not ready.");

      loadRewardedAd();

      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (
        AdWithoutView ad,
        RewardItem reward,
      ) {
        onReward();
      },
    );
  }
}