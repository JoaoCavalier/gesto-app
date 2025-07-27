import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> entrarUsuario({
    required String email, 
    required String senha
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: senha
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "O e-mail não está cadastrado.";
        case "wrong-password":
          return "Senha incorreta.";
        case "too-many-requests":
          return "Muitas tentativas. Tente novamente mais tarde.";
        default:
          return "Erro ao entrar: ${e.message}";
      }
    } catch (e) {
      return "Erro desconhecido: $e";
    }
  }

  Future<String?> cadastrarUsuario({
    required String nome,
    required String senha,
    required String email,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await userCredential.user!.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O e-mail já está cadastrado";
      }
      return "Erro ao cadastrar: ${e.message}";
    } catch (e) {
      return "Erro desconhecido: $e";
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "E-mail não cadastrado.";
      }
      return "Erro ao redefinir senha: ${e.message}";
    } catch (e) {
      return "Erro desconhecido: $e";
    }
  }
}