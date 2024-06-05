import 'package:flutter/material.dart';

class GroupProvider with ChangeNotifier {
  String _selectedGroupId = '';
  String _selectedGroupName = '';

  String get selectedGroupId => _selectedGroupId;
  String get selectedGroupName => _selectedGroupName;

  void selectGroup(String groupId, String groupName) {
    _selectedGroupId = groupId;
    _selectedGroupName = groupName;
    notifyListeners();
  }
}
