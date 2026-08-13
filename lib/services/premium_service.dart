import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumService extends ChangeNotifier {
  static const String productId = 'gta6_premium';

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? premiumProduct;

  bool isPremium = false;
  bool isLoading = false;
  bool storeAvailable = false;

  String? errorMessage;

  Future<void> initialize() async {
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('Purchase stream error: $error');

        errorMessage = 'Purchase system error.';
        isLoading = false;
        notifyListeners();
      },
    );

    storeAvailable = await _iap.isAvailable();

    if (!storeAvailable) {
      errorMessage = 'Google Play Billing is unavailable.';
      notifyListeners();
      return;
    }

    await loadProduct();
  }

  Future<void> loadProduct() async {
    try {
      final response = await _iap.queryProductDetails(
        {productId},
      );

      if (response.error != null) {
        errorMessage = response.error!.message;
        notifyListeners();
        return;
      }

      if (response.notFoundIDs.contains(productId)) {
        errorMessage = 'GTA 6 Pro is not available yet.';
        notifyListeners();
        return;
      }

      if (response.productDetails.isNotEmpty) {
        premiumProduct = response.productDetails.first;
        errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Product loading error: $e');
      errorMessage = 'Unable to load Premium.';
      notifyListeners();
    }
  }

  Future<void> buyPremium() async {
    if (premiumProduct == null) {
      await loadProduct();
    }

    if (premiumProduct == null) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final purchaseParam = PurchaseParam(
      productDetails: premiumProduct!,
    );

    await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }

  void _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) {
    for (final purchase in purchases) {
      if (purchase.productID != productId) {
        continue;
      }

      debugPrint(
        'Purchase status: ${purchase.status}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          isLoading = true;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _unlockPremium();
          break;

        case PurchaseStatus.error:
          isLoading = false;

          errorMessage =
              purchase.error?.message ??
              'Purchase failed.';

          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          isLoading = false;
          notifyListeners();
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _unlockPremium() {
    isPremium = true;
    isLoading = false;
    errorMessage = null;

    debugPrint('GTA 6 PRO unlocked');

    notifyListeners();
  }
  void enableTestPremium() {
  isPremium = true;
  errorMessage = null;
  notifyListeners();

  debugPrint('TEST MODE: GTA 6 PRO ENABLED');
}

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}