import 'package:flutter/foundation.dart';

class BaseProvider extends ChangeNotifier {
  bool _isMainLoading = false;
  bool _isSmallLoading1 = false;
  bool _isSmallLoading2 = false;
  String? _errorMessage;

  // Getters
  bool get isMainLoading => _isMainLoading;
  bool get isSmallLoading1 => _isSmallLoading1;
  bool get isSmallLoading2 => _isSmallLoading2;
  String? get errorMessage => _errorMessage;

  // Setters for loading states
  void setMainLoading(bool isLoading) {
    _isMainLoading = isLoading;
    notifyListeners();
  }

  void setSmallLoading1(bool isLoading) {
    _isSmallLoading1 = isLoading;
    notifyListeners();
  }

  void setSmallLoading2(bool isLoading) {
    _isSmallLoading2 = isLoading;
    notifyListeners();
  }

  // Error handling
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
