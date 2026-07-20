import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class SubscriptionProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _isSubscribed = false;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  bool get isSubscribed => _isSubscribed;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;

  static const String _kSubscriptionId = 'com.sozo.tribe';

  SubscriptionProvider(this._authProvider) {
    _init();
  }

  void _init() {
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // handle error
      },
    );
    _initializeStore();
    checkSubscriptionStatus();
  }

  Future<void> _initializeStore() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      const Set<String> _kIds = <String>{_kSubscriptionId};
      final ProductDetailsResponse productDetailResponse = await _inAppPurchase
          .queryProductDetails(_kIds);
      if (productDetailResponse.error == null) {
        _products = productDetailResponse.productDetails;
        notifyListeners();
      }
    }
  }

  Future<void> checkSubscriptionStatus() async {
    final token = _authProvider.token;
    if (token == null) return;

    try {
      final res = await ApiService.getSubscriptionStatus(token);
      _isSubscribed = res['subscription'] != null;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch subscription status: $e");
    }
  }

  Future<void> subscribe(ProductDetails productDetails) async {
    _isLoading = true;
    notifyListeners();
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isLoading = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _isLoading = false;
          notifyListeners();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _verifyPurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final token = _authProvider.token;
    if (token == null) return;

    try {
      await ApiService.verifySubscription(
        token: token,
        platform: Platform.isIOS ? 'apple' : 'google',
        productId: purchaseDetails.productID,
        receiptData: purchaseDetails.verificationData.serverVerificationData,
        originalTxId: purchaseDetails.purchaseID ?? '',
      );
      _isSubscribed = true;
    } catch (e) {
      debugPrint("Failed to verify purchase: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
