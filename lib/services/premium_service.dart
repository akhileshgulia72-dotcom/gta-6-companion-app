import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumService extends ChangeNotifier {
  // ===============================================================
  // CONFIGURATION
  // ===============================================================

  static const String productId = 'gta6_proo';

  String get _storeName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'App Store' : 'Google Play';

  // NEVER enable this in production.
  static const bool testPremiumMode = false;

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? premiumProduct;

  // ===============================================================
  // STATE
  // ===============================================================

  bool isPremium = false;
  bool isLoading = false;
  bool storeAvailable = false;

  String? errorMessage;

  bool _initialized = false;

  // Prevent duplicate initialize() calls.
  Future<void>? _initializeFuture;

  // Prevent duplicate queryProductDetails() calls.
  Future<void>? _loadProductFuture;

  // Prevent duplicate restorePurchases() calls.
  Future<void>? _restoreFuture;

  // Prevent duplicate purchase requests.
  bool _purchaseInProgress = false;

  // ===============================================================
  // INITIALIZE
  // ===============================================================

  Future<void> initialize() {
    debugPrint('GTA 6 PRO: initialize requested.');

    if (_initialized) {
      debugPrint('GTA 6 PRO: already initialized.');
      return Future.value();
    }

    // CRITICAL:
    // Multiple screens can call initialize() simultaneously.
    // They must all share ONE Future.
    if (_initializeFuture != null) {
      debugPrint('GTA 6 PRO: initialization already running.');
      return _initializeFuture!;
    }

    final future = _initializeInternal();

    _initializeFuture = future;

    return future;
  }

  Future<void> _initializeInternal() async {
    bool completedSuccessfully = false;

    try {
      debugPrint('================================');
      debugPrint('GTA 6 PRO PREMIUM INITIALIZATION');
      debugPrint('================================');

      // -------------------------------------------------------------
      // TEST MODE
      // -------------------------------------------------------------

      if (testPremiumMode) {
        isPremium = true;
        storeAvailable = true;
        errorMessage = null;
        _initialized = true;

        completedSuccessfully = true;

        notifyListeners();

        debugPrint('GTA 6 PRO TEST MODE ENABLED.');

        return;
      }

      // -------------------------------------------------------------
      // PURCHASE STREAM
      // -------------------------------------------------------------

      // Subscribe exactly once.
      if (_purchaseSubscription == null) {
        debugPrint('Creating purchase stream listener.');

        _purchaseSubscription = _iap.purchaseStream.listen(
          _handlePurchaseUpdates,
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('Purchase stream error: $error');
            debugPrintStack(stackTrace: stackTrace);

            errorMessage = 'Purchase system error.';
            isLoading = false;
            _purchaseInProgress = false;

            notifyListeners();
          },
        );
      }

      // -------------------------------------------------------------
      // GOOGLE PLAY AVAILABILITY
      // -------------------------------------------------------------

      try {
        storeAvailable = await _iap.isAvailable();
      } catch (e, stackTrace) {
        debugPrint('Billing availability error: $e');
        debugPrintStack(stackTrace: stackTrace);

        storeAvailable = false;
        errorMessage = '$_storeName purchases are unavailable.';

        notifyListeners();

        return;
      }

      debugPrint(
        '$_storeName purchases available: $storeAvailable',
      );

      if (!storeAvailable) {
        errorMessage = '$_storeName purchases are unavailable.';

        notifyListeners();

        return;
      }

      // -------------------------------------------------------------
      // PRODUCT
      // -------------------------------------------------------------

      await loadProduct();

      // -------------------------------------------------------------
      // RESTORE
      // -------------------------------------------------------------

      // Restore only through our protected method.
      await restorePurchases();

      // -------------------------------------------------------------
      // COMPLETE
      // -------------------------------------------------------------

      _initialized = true;
      completedSuccessfully = true;

      errorMessage = null;

      notifyListeners();

      debugPrint('GTA 6 PRO initialization completed.');
    } catch (e, stackTrace) {
      debugPrint('Premium initialization exception: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage = 'Premium system initialization failed.';

      notifyListeners();
    } finally {
      // VERY IMPORTANT:
      //
      // If initialization failed, don't leave a permanently
      // completed Future in memory.
      //
      // This allows a later screen/open attempt to retry.
      if (!completedSuccessfully) {
        _initializeFuture = null;
      }
    }
  }

  // ===============================================================
  // LOAD PRODUCT
  // ===============================================================

  Future<void> loadProduct() {
    // Product already loaded.
    if (premiumProduct != null) {
      return Future.value();
    }

    // CRITICAL:
    //
    // If HomeScreen, PremiumScreen, popup, etc. all call
    // loadProduct() at the same time, ONLY ONE
    // queryProductDetails() request is sent to Android.
    //
    // This directly protects against:
    //
    // Reply already submitted
    //
    // platform-channel errors.
    if (_loadProductFuture != null) {
      debugPrint(
        'GTA 6 PRO: product query already running.',
      );

      return _loadProductFuture!;
    }

    final future = _loadProductInternal();

    _loadProductFuture = future;

    // Always release the lock after the request finishes.
    //
    // This is important because your old implementation could
    // leave the Future permanently stored after an error.
    future.whenComplete(() {
      if (identical(_loadProductFuture, future)) {
        _loadProductFuture = null;
      }
    });

    return future;
  }

  Future<void> _loadProductInternal() async {
    try {
      errorMessage = null;

      // -------------------------------------------------------------
      // CHECK BILLING
      // -------------------------------------------------------------

      if (!storeAvailable) {
        try {
          storeAvailable = await _iap.isAvailable();
        } catch (e, stackTrace) {
          debugPrint(
            'Billing availability retry error: $e',
          );

          debugPrintStack(stackTrace: stackTrace);

          storeAvailable = false;
        }
      }

      if (!storeAvailable) {
        errorMessage = '$_storeName purchases are unavailable.';

        notifyListeners();

        return;
      }

      debugPrint('================================');
      debugPrint('QUERYING GTA 6 PRO PRODUCT');
      debugPrint('Product ID: $productId');
      debugPrint('================================');

      // -------------------------------------------------------------
      // ONLY ONE queryProductDetails() CAN RUN
      // -------------------------------------------------------------

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(
        <String>{productId},
      );

      // -------------------------------------------------------------
      // ERROR
      // -------------------------------------------------------------

      if (response.error != null) {
        debugPrint(
          'Product query error: ${response.error}',
        );

        errorMessage = response.error!.message;

        notifyListeners();

        return;
      }

      // -------------------------------------------------------------
      // PRODUCT NOT FOUND
      // -------------------------------------------------------------

      if (response.notFoundIDs.contains(productId)) {
        debugPrint(
          'GTA 6 PRO product not found: $productId',
        );

        errorMessage =
            'GTA 6 PRO is not available yet.';

        notifyListeners();

        return;
      }

      // -------------------------------------------------------------
      // PRODUCT FOUND
      // -------------------------------------------------------------

      if (response.productDetails.isEmpty) {
        debugPrint(
          '$_storeName returned zero product details.',
        );

        errorMessage =
            'GTA 6 PRO is not available yet.';

        notifyListeners();

        return;
      }

      // Use exact matching product instead of blindly taking
      // the first product returned.
      ProductDetails? foundProduct;

      for (final ProductDetails product
          in response.productDetails) {
        if (product.id == productId) {
          foundProduct = product;
          break;
        }
      }

      if (foundProduct == null) {
        debugPrint(
          'Requested product was not present in response.',
        );

        errorMessage =
            'GTA 6 PRO is not available yet.';

        notifyListeners();

        return;
      }

      premiumProduct = foundProduct;

      errorMessage = null;

      debugPrint('================================');
      debugPrint('GTA 6 PRO PRODUCT LOADED');
      debugPrint('ID: ${premiumProduct!.id}');
      debugPrint('Title: ${premiumProduct!.title}');
      debugPrint('Price: ${premiumProduct!.price}');
      debugPrint('================================');

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint(
        'Product loading exception: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
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
    // -------------------------------------------------------------
    // TEST MODE
    // -------------------------------------------------------------

    if (testPremiumMode) {
      isPremium = true;
      isLoading = false;
      errorMessage = null;

      notifyListeners();

      return;
    }

    // -------------------------------------------------------------
    // DUPLICATE PURCHASE PROTECTION
    // -------------------------------------------------------------

    if (_purchaseInProgress || isLoading) {
      debugPrint(
        'GTA 6 PRO: purchase already running.',
      );

      return;
    }

    _purchaseInProgress = true;
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      // -----------------------------------------------------------
      // INITIALIZE
      // -----------------------------------------------------------

      await initialize();

      if (!storeAvailable) {
        errorMessage = '$_storeName purchases are unavailable.';

        return;
      }

      // -----------------------------------------------------------
      // PRODUCT
      // -----------------------------------------------------------

      if (premiumProduct == null) {
        await loadProduct();
      }

      if (premiumProduct == null) {
        errorMessage =
            'GTA 6 PRO could not be loaded.';

        return;
      }

      // -----------------------------------------------------------
      // PURCHASE
      // -----------------------------------------------------------

      final PurchaseParam purchaseParam =
          PurchaseParam(
        productDetails: premiumProduct!,
      );

      debugPrint(
        'Starting GTA 6 PRO purchase.',
      );

      await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      debugPrint(
        '$_storeName purchase request sent.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Purchase launch error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      errorMessage =
          'Unable to start the purchase.';
    } finally {
      //
      // IMPORTANT:
      //
      // Don't keep the button permanently locked.
      //
      // The purchase stream will handle the actual
      // purchased/pending/error state.
      //
      _purchaseInProgress = false;
      isLoading = false;

      notifyListeners();
    }
  }

  // ===============================================================
  // RESTORE PURCHASES
  // ===============================================================

  Future<void> restorePurchases() {
    if (testPremiumMode) {
      isPremium = true;
      isLoading = false;
      errorMessage = null;

      notifyListeners();

      return Future.value();
    }

    // Prevent simultaneous restore calls.
    if (_restoreFuture != null) {
      debugPrint(
        'GTA 6 PRO: restore already running.',
      );

      return _restoreFuture!;
    }

    final future = _restorePurchasesInternal();

    _restoreFuture = future;

    future.whenComplete(() {
      if (identical(_restoreFuture, future)) {
        _restoreFuture = null;
      }
    });

    return future;
  }

  Future<void> _restorePurchasesInternal() async {
    try {
      if (!storeAvailable) {
        storeAvailable = await _iap.isAvailable();
      }

      if (!storeAvailable) {
        errorMessage = '$_storeName purchases are unavailable.';

        notifyListeners();

        return;
      }

      debugPrint(
        'Restoring GTA 6 PRO purchases...',
      );

      await _iap.restorePurchases();

      debugPrint(
        'GTA 6 PRO restore request completed.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Restore error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

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
    for (final PurchaseDetails purchase
        in purchases) {
      // -----------------------------------------------------------
      // IGNORE OTHER PRODUCTS
      // -----------------------------------------------------------

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
          _purchaseInProgress = false;

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
          _purchaseInProgress = false;
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
        unawaited(
          _completePurchase(purchase),
        );
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
    } catch (e, stackTrace) {
      debugPrint(
        'Complete purchase error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // ===============================================================
  // UNLOCK PREMIUM
  // ===============================================================

  void _unlockPremium() {
    isPremium = true;

    isLoading = false;
    _purchaseInProgress = false;

    errorMessage = null;

    debugPrint('================================');
    debugPrint('GTA 6 PRO UNLOCKED');
    debugPrint('================================');

    notifyListeners();
  }

  // ===============================================================
  // MANUAL PREMIUM CONTROL
  // ===============================================================

  void setPremium(bool value) {
    isPremium = value;

    if (value) {
      errorMessage = null;
    }

    notifyListeners();
  }

  // ===============================================================
  // DISPOSE
  // ===============================================================

  @override
  void dispose() {
    debugPrint(
      'GTA 6 PRO: disposing PremiumService.',
    );

    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;

    _initializeFuture = null;
    _loadProductFuture = null;
    _restoreFuture = null;

    super.dispose();
  }
}
