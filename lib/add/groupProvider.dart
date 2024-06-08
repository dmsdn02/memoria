import 'package:flutter/material.dart';

/// Provides and manages group-related data.
class GroupProvider with ChangeNotifier {
  String _selectedGroupId = '';
  String _selectedGroupName = '';

  String get selectedGroupId => _selectedGroupId;
  String get selectedGroupName => _selectedGroupName;

  set selectedGroupId(String groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  set selectedGroupName(String groupName) {
    _selectedGroupName = groupName;
    notifyListeners();
  }

  /// Selects a group with the given [groupId] and [groupName].
  void selectGroup(String groupId, String groupName) {
    selectedGroupId = groupId;
    selectedGroupName = groupName;
  }
}
