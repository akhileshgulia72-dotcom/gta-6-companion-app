import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'premium_state.dart';

class AdManager {
  /// Returns the correct Interstitial Ad Unit ID for the current platform.
  ///
  /// Android:
  /// ca-app-pub-7694497723149363/3436835638
  ///
  /// iOS:
  /// ca-app-pub-7694497723149363/7755943262
  static String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-7694497723149363/7755943262';
    }

    return 'ca-app-pub-7694497723149363/3436835638';
  }

  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static bool _isShowingInterstitial = false;
  static Timer? _retryTimer;
  static int _loadFailureCount = 0;

  static bool get isInterstitialReady => _interstitialAd != null;

  static bool get isInterstitialLoading =>
      _isLoadingInterstitial;

  static void preloadInterstitial() {
    if (premiumState.isPremium) {
      _clearCachedAd();
      return;
    }

    if (_interstitialAd != null ||
        _isLoadingInterstitial ||
        _isShowingInterstitial ||
        (_retryTimer?.isActive ?? false)) {
      return;
    }

    _isLoadingInterstitial = true;

    debugPrint(
      'AdManager: requesting interstitial...',
    );

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _isLoadingInterstitial = false;
          _loadFailureCount = 0;

          _interstitialAd?.dispose();
          _interstitialAd = ad;

          debugPrint(
            'AdManager: interstitial LOADED and READY',
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
          _loadFailureCount++;

          debugPrint(
            'AdManager: interstitial FAILED TO LOAD: $error',
          );

          _scheduleRetry();
        },
      ),
    );
  }

  static Future<void> showInterstitial({
    required VoidCallback onFinished,
    Duration maxWait = const Duration(seconds: 2),
  }) async {
    if (premiumState.isPremium) {
      _clearCachedAd();
      onFinished();
      return;
    }

    if (_isShowingInterstitial) {
      debugPrint(
        'AdManager: another interstitial is already showing.',
      );

      onFinished();
      return;
    }

    if (_interstitialAd == null &&
        !_isLoadingInterstitial) {
      preloadInterstitial();
    }

    final DateTime deadline =
        DateTime.now().add(maxWait);

    while (_interstitialAd == null &&
        _isLoadingInterstitial &&
        DateTime.now().isBefore(deadline)) {
      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      if (premiumState.isPremium) {
        _clearCachedAd();
        onFinished();
        return;
      }
    }

    if (_isShowingInterstitial) {
      onFinished();
      return;
    }

    final InterstitialAd? ad = _interstitialAd;

    if (ad == null) {
      debugPrint(
        'AdManager: interstitial not ready after wait; continuing.',
      );

      preloadInterstitial();
      onFinished();
      return;
    }

    // Remove from cache immediately.
    // An interstitial can only be shown once.
    _interstitialAd = null;
    _isShowingInterstitial = true;

    bool finished = false;

    void finishNavigation() {
      if (finished) return;

      finished = true;
      onFinished();
    }

    debugPrint(
      'AdManager: showing interstitial...',
    );

    ad.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent:
          (InterstitialAd ad) {
        debugPrint(
          'AdManager: interstitial SHOWED',
        );
      },
      onAdImpression:
          (InterstitialAd ad) {
        debugPrint(
          'AdManager: interstitial IMPRESSION',
        );
      },
      onAdClicked:
          (InterstitialAd ad) {
        debugPrint(
          'AdManager: interstitial CLICKED',
        );
      },
      onAdDismissedFullScreenContent:
          (InterstitialAd ad) {
        debugPrint(
          'AdManager: interstitial DISMISSED',
        );

        _isShowingInterstitial = false;

        ad.dispose();

        // Prepare the next interstitial.
        preloadInterstitial();

        finishNavigation();
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd ad, AdError error) {
        debugPrint(
          'AdManager: interstitial FAILED TO SHOW: $error',
        );

        _isShowingInterstitial = false;

        ad.dispose();

        // Recover automatically.
        preloadInterstitial();

        finishNavigation();
      },
    );

    ad.show();
  }

  static void _scheduleRetry() {
    if (premiumState.isPremium ||
        (_retryTimer?.isActive ?? false)) {
      return;
    }

    final int delaySeconds;

    if (_loadFailureCount <= 1) {
      delaySeconds = 5;
    } else if (_loadFailureCount == 2) {
      delaySeconds = 10;
    } else if (_loadFailureCount == 3) {
      delaySeconds = 20;
    } else {
      delaySeconds = 30;
    }

    debugPrint(
      'AdManager: retrying interstitial in '
      '${delaySeconds}s...',
    );

    _retryTimer = Timer(
      Duration(seconds: delaySeconds),
      () {
        _retryTimer = null;

        if (!premiumState.isPremium) {
          preloadInterstitial();
        }
      },
    );
  }

  static void _clearCachedAd() {
    _retryTimer?.cancel();
    _retryTimer = null;

    _interstitialAd?.dispose();
    _interstitialAd = null;

    _isLoadingInterstitial = false;
  }

  static void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;

    _interstitialAd?.dispose();
    _interstitialAd = null;

    _isLoadingInterstitial = false;
    _isShowingInterstitial = false;
    _loadFailureCount = 0;
  }
}