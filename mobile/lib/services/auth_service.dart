import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userKey = 'user_data';

  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final user = User.fromJson(userDoc.data()!);
          await _saveUser(user);
          return user;
        } else {
          throw Exception('Usuário não encontrado');
        }
      } else {
        throw Exception('Falha no login');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userType,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          userType: userType,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());

        await _saveUser(user);
        return user;
      } else {
        throw Exception('Falha no registro');
      }
    } catch (e) {
      throw Exception('Erro ao registrar: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final user = User.fromJson(userDoc.data()!);
          await _saveUser(user);
          return user;
        }
      }

      // Tentar recuperar do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }

      return null;
    } catch (e) {
      throw Exception('Erro ao obter usuário atual: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
} 