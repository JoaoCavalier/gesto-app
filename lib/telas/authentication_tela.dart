import 'package:flutter/material.dart';
import 'package:projeto_flutter/_common/my_colors.dart';
import 'package:projeto_flutter/_common/my_snackbar.dart';
import 'package:projeto_flutter/components/decoration_field_authentication.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AthenticationTela extends StatefulWidget {
  const AthenticationTela({super.key});

  @override
  State<AthenticationTela> createState() => _AthenticationTelaState();
}

class _AthenticationTelaState extends State<AthenticationTela> {
  bool queroEntrar = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final AuthenticationService authenService = AuthenticationService();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _nomeController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MyColors.blackTopGradient,
                  MyColors.greenBottomGradient
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/gesto_app.png',
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: getAuthenticationInputDecoration("E-mail"),
                            keyboardType: TextInputType.emailAddress,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "O E-mail não pode ser vazio";
                              }
                              if (value.length < 5) {
                                return "O E-mail é muito curto";
                              }
                              if (!value.contains("@")) {
                                return "O E-mail não é válido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "A senha deve ter pelo menos 6 caracteres";
                              }
                              return null;
                            },
                            decoration: getAuthenticationInputDecoration('Senha'),
                          ),
                          if (queroEntrar) ...[
                            TextButton(
                              onPressed: isLoading ? null : esqueciMinhaSenhaClicado,
                              child: const Text(
                                "Esqueci minha senha.",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (!queroEntrar) ...[
                            TextFormField(
                              controller: _confirmController,
                              obscureText: true,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Confirme sua senha";
                                }
                                if (value != _senhaController.text) {
                                  return "As senhas não coincidem";
                                }
                                return null;
                              },
                              decoration: getAuthenticationInputDecoration('Confirme a Senha'),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _nomeController,
                              decoration: getAuthenticationInputDecoration('Nome'),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "O nome não pode ser vazio";
                                }
                                if (value.length < 3) {
                                  return "O nome é muito curto";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: isLoading ? null : mainButtonClick,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    queroEntrar ? 'Login' : 'Cadastrar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          if (queroEntrar) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  "ou",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : _handleGoogleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Logar com o Google",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      queroEntrar = !queroEntrar;
                                      _formKey.currentState?.reset();
                                    });
                                  },
                            child: Text(
                              queroEntrar
                                  ? 'Ainda não tem uma conta? Cadastre-se!'
                                  : 'Já tem uma conta? Entre',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final UserCredential? user = await signInWithGoogle();
      if (user != null && mounted) {
        showSnackBar(
          context: context,
          text: "Login com Google realizado com sucesso",
          isErro: false,
        );
      }
    } catch (error) {
      if (mounted) {
        showSnackBar(
          context: context,
          text: "Erro ao fazer login com Google: $error",
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Forçar logout para garantir seleção de conta
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      debugPrint("Erro no login com Google: $error");
      rethrow;
    }
  }

  void mainButtonClick() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      if (queroEntrar) {
        await _entrarUsuario(
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
        );
      } else {
        await _criarUsuario(
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
          nome: _nomeController.text.trim(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _entrarUsuario({
    required String email,
    required String senha,
  }) async {
    final String? erro = await authenService.entrarUsuario(
      email: email,
      senha: senha,
    );

    if (!mounted) return;

    if (erro == null) {
      showSnackBar(
        context: context,
        text: "Login realizado com sucesso",
        isErro: false,
      );
    } else {
      showSnackBar(context: context, text: erro);
    }
  }

  Future<void> _criarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    final String? erro = await authenService.cadastrarUsuario(
      email: email,
      senha: senha,
      nome: nome,
    );

    if (!mounted) return;

    if (erro == null) {
      showSnackBar(
        context: context,
        text: "Cadastro realizado com sucesso!",
        isErro: false,
      );
      setState(() => queroEntrar = true);
    } else {
      showSnackBar(context: context, text: erro);
    }
  }

  Future<void> esqueciMinhaSenhaClicado() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty || !email.contains("@")) {
      showSnackBar(
        context: context,
        text: "Insira um e-mail válido para redefinição",
      );
      return;
    }

    final TextEditingController resetController = 
        TextEditingController(text: email);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Redefinir senha"),
        content: TextFormField(
          controller: resetController,
          decoration: const InputDecoration(
            labelText: "E-mail",
            hintText: "Digite seu e-mail cadastrado",
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              
              final String? erro = await authenService.resetPassword(
                email: resetController.text.trim(),
              );

              if (!mounted) return;

              setState(() => isLoading = false);
              
              if (erro == null) {
                showSnackBar(
                  context: context,
                  text: "E-mail de redefinição enviado!",
                  isErro: false,
                );
              } else {
                showSnackBar(context: context, text: erro);
              }
            },
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }
}