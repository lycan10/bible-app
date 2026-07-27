import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class EconomyProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  int _coinBalance = 0;
  String _verificationBadge = 'NONE';
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  EconomyProvider(this.authProvider) {
    if (authProvider.isAuthenticated) {
      fetchBalance();
    }
    _initIAP();
  }

  int get coinBalance => _coinBalance;
  String get verificationBadge => _verificationBadge;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  // These should match the product IDs configured in Apple App Store Connect / Google Play Console
  static const Set<String> _kIds = <String>{
    'com.quest.coins.100',
    'com.quest.coins.500',
    'com.quest.coins.1000'
  };

  void _initIAP() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
    
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      _errorMessage = 'Store not available';
      notifyListeners();
      return;
    }
    ProductDetailsResponse productDetailResponse =
        await _iap.queryProductDetails(_kIds);
    if (productDetailResponse.error != null) {
      _errorMessage = productDetailResponse.error!.message;
      notifyListeners();
      return;
    }

    _products = productDetailResponse.productDetails;
    notifyListeners();
  }

  Future<void> fetchBalance() async {
    if (authProvider.token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.fetchEconomyBalance(authProvider.token!);
      if (res['error'] != null) {
        _errorMessage = res['error'];
      } else {
        _coinBalance = res['coinBalance'] ?? 0;
        _verificationBadge = res['verificationBadge'] ?? 'NONE';
        
        // Also update the main user object so it reflects globally
        authProvider.updateUserLocally({
          'coinBalance': _coinBalance,
          'verificationBadge': _verificationBadge,
        });
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateCoinBalance(int newBalance) {
    _coinBalance = newBalance;
    authProvider.updateUserLocally({'coinBalance': newBalance});
    notifyListeners();
  }

  void buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isLoading = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _errorMessage = purchaseDetails.error?.message;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (authProvider.token == null) return;
    
    try {
      // In a real app, you would send purchaseDetails.verificationData to your backend.
      // Here, we just hit our webhook for the purchased package.
      final res = await ApiService.recordCoinPurchase(authProvider.token!, purchaseDetails.productID);
      if (res['error'] == null) {
        // Refresh balance after successful purchase
        await fetchBalance();
      } else {
        _errorMessage = res['error'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
