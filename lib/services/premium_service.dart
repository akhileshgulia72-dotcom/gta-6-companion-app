import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumService extends ChangeNotifier {


  static const String productId = 'gta6_pro';

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? premiumProduct;

  bool isPremium = false;
  bool isLoading = false;
  bool storeAvailable = false;

  String? errorMessage;

  // ===============================================================
  // INITIALIZE
  // ===============================================================

  Future<void> initialize() async {
    // Prevent multiple listeners if initialize() is called again.
    await _purchaseSubscription?.cancel();

    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('Purchase stream error: $error');

        errorMessage = 'Purchase system error.';
        isLoading = false;

        notifyListeners();
      },
    );

    // Check Google Play Billing availability.
    storeAvailable = await _iap.isAvailable();

    debugPrint(
      'Google Play Billing available: $storeAvailable',
    );

    if (!storeAvailable) {
      errorMessage =
          'Google Play Billing is unavailable.';

      notifyListeners();
      return;
    }

    await loadProduct();

    // Restore any previous purchase.
    //
    // This allows a user who already bought GTA 6 PRO
    // to regain premium access after reinstalling the app
    // or changing devices with the same Google account.
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint(
        'Initial restore error: $e',
      );
    }
  }

  // ===============================================================
  // LOAD PRODUCT
  // ===============================================================

  Future<void> loadProduct() async {
    try {
      errorMessage = null;

      debugPrint(
        'Searching Google Play product: $productId',
      );

      final response = await _iap.queryProductDetails(
        {productId},
      );

      // -----------------------------------------------------------
      // QUERY ERROR
      // -----------------------------------------------------------

      if (response.error != null) {
        debugPrint(
          'Product query error: '
          '${response.error!.message}',
        );

        errorMessage =
            response.error!.message;

        notifyListeners();
        return;
      }

      // -----------------------------------------------------------
      // PRODUCT NOT FOUND
      // -----------------------------------------------------------

      if (response.notFoundIDs.contains(productId)) {
        debugPrint(
          'Product not found: $productId',
        );

        errorMessage =
            'GTA 6 PRO is not available yet.';

        notifyListeners();
        return;
      }

      // -----------------------------------------------------------
      // PRODUCT FOUND
      // -----------------------------------------------------------

      if (response.productDetails.isNotEmpty) {
        premiumProduct =
            response.productDetails.first;

        debugPrint(
          'GTA 6 PRO product loaded successfully.',
        );

        debugPrint(
          'Product ID: ${premiumProduct!.id}',
        );

        debugPrint(
          'Product title: ${premiumProduct!.title}',
        );

        debugPrint(
          'Product price: ${premiumProduct!.price}',
        );

        errorMessage = null;

        notifyListeners();

        return;
      }

      // -----------------------------------------------------------
      // EMPTY RESPONSE
      // -----------------------------------------------------------

      debugPrint(
        'Google Play returned no product details.',
      );

      errorMessage =
          'GTA 6 PRO is not available yet.';

      notifyListeners();

    } catch (e) {
      debugPrint(
        'Product loading exception: $e',
      );

      errorMessage =
          'Unable to load GTA 6 PRO.';

      notifyListeners();
    }
  }

  // ===============================================================
  // BUY PREMIUM
  // ===============================================================

  Future<void> buyPremium() async {
    // Make sure the product is loaded.
    if (premiumProduct == null) {
      await loadProduct();
    }

    // Product still unavailable.
    if (premiumProduct == null) {
      return;
    }

    // Prevent accidental duplicate purchase requests.
    if (isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(
        productDetails: premiumProduct!,
      );

      debugPrint(
        'Starting GTA 6 PRO purchase...',
      );

      await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

    } catch (e) {
      debugPrint(
        'Purchase launch error: $e',
      );

      isLoading = false;

      errorMessage =
          'Unable to start the purchase.';

      notifyListeners();
    }
  }

  // ===============================================================
  // RESTORE PURCHASE
  // ===============================================================

  Future<void> restorePurchases() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      debugPrint(
        'Restoring GTA 6 PRO purchase...',
      );

      await _iap.restorePurchases();

    } catch (e) {
      debugPrint(
        'Restore error: $e',
      );

      isLoading = false;

      errorMessage =
          'Unable to restore your purchase.';

      notifyListeners();
    }
  }

  // ===============================================================
  // PURCHASE UPDATES
  // ===============================================================

  void _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) {
    for (final purchase in purchases) {

      // Ignore products that aren't GTA 6 PRO.
      if (purchase.productID != productId) {
        continue;
      }

      debugPrint(
        'GTA 6 PRO purchase status: '
        '${purchase.status}',
      );

      switch (purchase.status) {

        // ---------------------------------------------------------
        // PENDING
        // ---------------------------------------------------------

        case PurchaseStatus.pending:
          isLoading = true;

          notifyListeners();
          break;

        // ---------------------------------------------------------
        // PURCHASED
        // ---------------------------------------------------------

        case PurchaseStatus.purchased:
          debugPrint(
            'GTA 6 PRO purchased successfully.',
          );

          _unlockPremium();
          break;

        // ---------------------------------------------------------
        // RESTORED
        // ---------------------------------------------------------

        case PurchaseStatus.restored:
          debugPrint(
            'GTA 6 PRO purchase restored.',
          );

          _unlockPremium();
          break;

        // ---------------------------------------------------------
        // ERROR
        // ---------------------------------------------------------

        case PurchaseStatus.error:
          debugPrint(
            'GTA 6 PRO purchase error: '
            '${purchase.error?.message}',
          );

          isLoading = false;

          errorMessage =
              purchase.error?.message ??
              'Purchase failed.';

          notifyListeners();
          break;

        // ---------------------------------------------------------
        // CANCELED
        // ---------------------------------------------------------

        case PurchaseStatus.canceled:
          debugPrint(
            'GTA 6 PRO purchase canceled.',
          );

          isLoading = false;

          errorMessage = null;

          notifyListeners();
          break;

        default:
          break;
      }

      // -----------------------------------------------------------
      // COMPLETE PURCHASE
      // -----------------------------------------------------------

      if (purchase.pendingCompletePurchase) {
        _completePurchase(purchase);
      }
    }
  }

  // ===============================================================
  // COMPLETE PURCHASE
  // ===============================================================

  Future<void> _completePurchase(
    PurchaseDetails purchase,
  ) async {
    try {
      await _iap.completePurchase(
        purchase,
      );

      debugPrint(
        'GTA 6 PRO purchase completed.',
      );

    } catch (e) {
      debugPrint(
        'Complete purchase error: $e',
      );
    }
  }

  // ===============================================================
  // UNLOCK PREMIUM
  // ===============================================================

  void _unlockPremium() {
    isPremium = true;

    isLoading = false;

    errorMessage = null;

    debugPrint(
      '================================',
    );

    debugPrint(
      'GTA 6 PRO UNLOCKED',
    );

    debugPrint(
      '================================',
    );

    notifyListeners();
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    _purchaseSubscription?.cancel();

    super.dispose();
  }
}