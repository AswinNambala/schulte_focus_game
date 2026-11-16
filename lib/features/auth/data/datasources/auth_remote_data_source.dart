import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String displayName);
  Future<UserModel> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchOrCreateUserDoc(firebaseUser);
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchOrCreateUserDoc(firebaseUser);
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('User credentials could not be verified.');
      }
      return await _fetchOrCreateUserDoc(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication error');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Could not create account.');
      }

      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: displayName.trim().isEmpty ? 'Player' : displayName.trim(),
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

      // Save user profile in Firestore
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign-up failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled by user.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Google sign-in failed.');
      }

      return await _fetchOrCreateUserDoc(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Could not send reset email');
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserModel> _fetchOrCreateUserDoc(User user) async {
    try {
      final docRef = firestore.collection(AppConstants.usersCollection).doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, user.uid);
      } else {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Player',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await docRef.set(newUser.toMap(), SetOptions(merge: true));
        return newUser;
      }
    } catch (e) {
      // Fallback to basic user representation if network is intermittent
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Player',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
    }
  }
}
