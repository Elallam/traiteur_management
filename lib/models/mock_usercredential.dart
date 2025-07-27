import 'package:firebase_auth/firebase_auth.dart';

class MockUserCredential implements UserCredential {
  @override
  final FirebaseAuth auth;
  @override
  final AuthCredential? credential;
  @override
  final AdditionalUserInfo? additionalUserInfo;
  @override
  final User user;

  MockUserCredential({
    required this.auth,
    this.credential,
    this.additionalUserInfo,
    required this.user,
  });
}

