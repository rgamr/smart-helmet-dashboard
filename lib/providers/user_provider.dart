import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();
  factory UserProvider() => _instance;
  UserProvider._internal() {
    _listenToAuth();
  }

  User? _user;
  UserRole _role = UserRole.worker;
  bool _isLoading = true;
  String? _errorMessage;

  // Worker-specific fields — populated when role == worker
  String? _workerId;   // e.g. "W-101" — links to workers/{id} in Firebase
  String? _workerName; // e.g. "Ahmed Hassan"

  final ApiService _apiService = ApiService();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<Map<String, dynamic>?>? _userDataSub;

  User? get user => _user;
  UserRole get role => _role;
  bool get isAdmin => _role == UserRole.admin;
  bool get isWorker => _role == UserRole.worker;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get workerId => _workerId;
  String? get workerName => _workerName;

  void _listenToAuth() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        _user = user;
        if (user != null) {
          // Fetch initial role + worker link from RTDB
          final userData = await _apiService.getUserData(user.uid);
          final roleStr = userData?['role'] as String?;
          _role = UserRoleExtension.fromString(roleStr);
          _workerId = userData?['workerId'] as String?;
          _workerName = userData?['workerName'] as String?;

          // Upsert user record so role management screen can list all users
          await _apiService.upsertUserRecord(
            user.uid,
            user.email ?? '',
            _role.label.toLowerCase(),
          );

          // Setup real-time listener for role/workerId changes
          _userDataSub?.cancel();
          _userDataSub = _apiService.getUserDataStream(user.uid).listen((data) {
            if (data != null) {
              final newRole = UserRoleExtension.fromString(data['role'] as String?);
              final newWorkerId = data['workerId'] as String?;
              final newWorkerName = data['workerName'] as String?;
              
              if (_role != newRole || _workerId != newWorkerId || _workerName != newWorkerName) {
                _role = newRole;
                _workerId = newWorkerId;
                _workerName = newWorkerName;
                notifyListeners();
              }
            }
          });

        } else {
          _role = UserRole.worker;
          _workerId = null;
          _workerName = null;
          _userDataSub?.cancel();
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDataSub?.cancel();
    super.dispose();
  }
}
