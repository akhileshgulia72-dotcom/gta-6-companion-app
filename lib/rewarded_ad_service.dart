import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  static RewardedAd? _rewardedAd;

  static bool _isLoading = false;
  static bool _isShowing = false;

  /// Returns the correct Rewarded Ad Unit ID for the current platform.
  ///
  /// Android:
  /// ca-app-pub-7694497723149363/4829954140
  ///
  /// iOS:
  /// ca-app-pub-7694497723149363/9069024935
  static String get adUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-7694497723149363/9069024935';
    }

    return 'ca-app-pub-7694497723149363/4829954140';
  }

  /// Requests exactly one rewarded ad.
  ///
  /// The loaded ad stays cached until the user explicitly chooses
  /// to watch it.
  static void preloadRewardedAd() {
    if (_rewardedAd != null || _isLoading || _isShowing) {
      return;
    }

    _isLoading = true;

    debugPrint(
      'RewardedAdService: REQUESTED',
    );

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isLoading = false;

          _rewardedAd?.dispose();
          _rewardedAd = ad;

          debugPrint(
            'RewardedAdService: LOADED',
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          _rewardedAd = null;

          debugPrint(
            'RewardedAdService: LOAD FAILED: $error',
          );
        },
      ),
    );
  }

  static bool get isReady => _rewardedAd != null;

  static bool get isLoading => _isLoading;

  static bool get isShowing => _isShowing;

  /// Shows the cached rewarded ad.
  ///
  /// If it is still loading, waits for that same request instead
  /// of starting duplicate requests.
  static Future<void> showRewardedAd({
    required VoidCallback onReward,
    VoidCallback? onAdPreparing,
    VoidCallback? onAdNotReady,
  }) async {
    if (_isShowing) {
      debugPrint(
        'RewardedAdService: already showing.',
      );
      return;
    }

    if (_rewardedAd == null && !_isLoading) {
      preloadRewardedAd();
    }

    if (_rewardedAd == null) {
      onAdPreparing?.call();

      const int maxWaitMs = 15000;
      const int pollMs = 100;

      int waitedMs = 0;

      while (_isLoading && waitedMs < maxWaitMs) {
        await Future<void>.delayed(
          const Duration(milliseconds: pollMs),
        );

        waitedMs += pollMs;
      }
    }

    final RewardedAd? ad = _rewardedAd;

    if (ad == null) {
      debugPrint(
        'RewardedAdService: NOT READY',
      );

      onAdNotReady?.call();
      return;
    }

    _showLoadedAd(
      ad,
      onReward,
    );
  }

  static void _showLoadedAd(
    RewardedAd ad,
    VoidCallback onReward,
  ) {
    if (_isShowing) {
      return;
    }

    // Remove it from the cache immediately.
    // A rewarded ad can only be shown once.
    _rewardedAd = null;
    _isShowing = true;

    bool rewardGiven = false;

    ad.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint(
          'RewardedAdService: SHOWED',
        );
      },
      onAdImpression: (ad) {
        debugPrint(
          'RewardedAdService: IMPRESSION',
        );
      },
      onAdClicked: (ad) {
        debugPrint(
          'RewardedAdService: CLICKED',
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint(
          'RewardedAdService: DISMISSED',
        );

        _isShowing = false;
        ad.dispose();

        // Immediately prepare the next rewarded ad.
        // This makes the next Watch & Earn tap much faster.
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent:
          (ad, error) {
        debugPrint(
          'RewardedAdService: SHOW FAILED: $error',
        );

        _isShowing = false;
        ad.dispose();

        // Recover automatically for the next attempt.
        preloadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward:
          (AdWithoutView ad, RewardItem reward) {
        if (rewardGiven) {
          return;
        }

        rewardGiven = true;

        debugPrint(
          'RewardedAdService: REWARD EARNED '
          '${reward.amount} ${reward.type}',
        );

        onReward();
      },
    );
  }

  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;

    _isLoading = false;
    _isShowing = false;
  }
}