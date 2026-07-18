import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String _selectedUserName = 'Selected User Name';

  String get userName => _userName;
  String get selectedUserName => _selectedUserName;

  void setUserName(String name) {
    if (_userName != name) {
      _userName = name;
      notifyListeners();
    }
  }

  void setSelectedUserName(String name) {
    if (_selectedUserName != name) {
      _selectedUserName = name;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedUserName = 'Selected User Name';
    notifyListeners();
  }
}
