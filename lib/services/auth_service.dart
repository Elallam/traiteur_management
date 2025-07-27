import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/mock_usercredential.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return await getUserData(result.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Initialize a secondary Firebase app to avoid affecting the admin's session
  Future<FirebaseApp> getSecondaryFirebaseApp() async {
    try {
      // Check if 'Secondary' app is already initialized
      return Firebase.app('Secondary');
    } catch (e) {
      print('Initializing secondary Firebase app');
      FirebaseApp defaultApp = Firebase.app();
      return await Firebase.initializeApp(
        name: 'Secondary',
        options: defaultApp.options,
      );
    }
  }
  /// Use the secondary app to create a user (admin action)
  Future<UserCredential> createUser(String email, String password) async {
    try {
      final secondaryApp = await getSecondaryFirebaseApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential;
      // Attempt to create user normally
      try {
        userCredential = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await secondaryAuth.signOut();
        return userCredential;
      }
      // Handle type casting error specifically
      catch (e) {
        if (e is TypeError) {
          print('Handling type cast exception during user creation');

          // Get the current user directly
          final user = secondaryAuth.currentUser;
          if (user != null) {
            // Create a UserCredential manually using the private constructor
            return MockUserCredential(
                  auth: secondaryAuth,
                  credential: null,
                  additionalUserInfo: null,
                  user: user,
            );
          }
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('Unexpected error in createUser: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }
  /// Admin creates a user account
  Future<UserModel?> createUserAccount({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String role,
  }) async {
    try {
      UserCredential result = await createUser(email, password);

      print("The user is created : ${result.user}");

      if (result.user != null) {
        UserModel newUser = UserModel(
          id: result.user!.uid,
          fullName: fullName,
          email: email,
          phone: phone,
          address: address,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _firestore
              .collection('users')
              .doc(result.user!.uid)
              .set(newUser.toMap());
        } catch (e) {
          print('Firestore error: $e');
          throw Exception('Failed to write user to Firestore.');
        }

        // Sign out from secondary to clean up
        await FirebaseAuth.instanceFor(app: Firebase.app('Secondary')).signOut();

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print("The exception is : ${e}");
      throw Exception('Failed to create user account. Please try again. ${e}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data.';
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Failed to update user data.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email.';
    }
  }

  // Delete user account
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Note: To delete the auth user, you need admin SDK or the user must be signed in
      // For now, we'll just mark as inactive
      // This requires admin privileges to fully delete auth account
    } catch (e) {
      throw 'Failed to delete user account.';
    }
  }

  // Get all users (Admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch users.';
    }
  }

  // Get employees only
  Future<List<UserModel>> getEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'employee')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'Failed to fetch employees.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}