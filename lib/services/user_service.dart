import 'package:cloud_functions/cloud_functions.dart';

class UserService {
  final _functions = FirebaseFunctions.instance;

  Future<void> createUserViaCloudFunction({
    required String email,
    required String password,
    required String role,
  }) async {
    final callable = _functions.httpsCallable('createUserWithRole');

    final result = await callable.call({
      'email': email,
      'password': password,
      'role': role,
    });

    if (result.data['success'] != true) {
      throw Exception(result.data['message'] ?? 'Unknown error occurred');
    }
  }
}
