import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final AuthenticationService authenService = AuthenticationService();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
                            decoration:
                                getAuthenticationInputDecoration("E-mail"),
                            validator: (String? value) {
                              if (value == null) {
                                return "O E-mail não pode ser vazio";
                              }
                              if (value.length < 5) {
                                return "O E-mail é muito curto";
                              }
                              if (!value.contains("@")) {
                                return "O E-mail não é Valido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _senhaController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 4) {
                                return "Insira uma senha válida.";
                              }
                              return null;
                            },
                            decoration:
                                getAuthenticationInputDecoration('Senha'),
                          ),
                          Visibility(
                            visible: queroEntrar,
                            child: TextButton(
                              onPressed: () {
                                esqueciMinhaSenhaClicado();
                              },
                              child: const Text(
                                "Esqueci minha senha.",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Visibility(
                            visible: !queroEntrar,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: true,
                                  validator: (String? value) {
                                    if (value == null || value.length < 4) {
                                      return "Insira uma confirmação de senha válida.";
                                    }
                                    if (value != _senhaController.text) {
                                      return "As senhas devem ser iguais.";
                                    }
                                    return null;
                                  },
                                  decoration: getAuthenticationInputDecoration(
                                      'Confirme a Senha'),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _nomeController,
                                  decoration:
                                      getAuthenticationInputDecoration('Nome'),
                                  validator: (String? value) {
                                    if (value == null) {
                                      return "O Nome não pode ser vazio";
                                    }
                                    if (value.length < 5) {
                                      return "O Nome é muito curto";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              mainButtonClick();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              (queroEntrar) ? 'Login' : 'Cadastrar',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: queroEntrar,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "ou",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: queroEntrar,
                            child: ElevatedButton(
                              onPressed: () {
                                signInWithGoogle().then((UserCredential user) {
                                  print(user);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 25,
                                    height: 25,
                                    child: Image.network(
                                      'http://pngimg.com/uploads/google/google_PNG19635.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  const Text(
                                    "Logar com o Google",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                queroEntrar = !queroEntrar;
                              });
                            },
                            child: Text(
                              (queroEntrar)
                                  ? 'Ainda não tem uma conta? Cadastre-se!'
                                  : 'Já tem uma conta? Entre',
                              style: const TextStyle(color: Colors.green, fontSize: 13),
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

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  mainButtonClick() {
    String email = _emailController.text;
    String senha = _senhaController.text;
    String nome = _nomeController.text;

    if (_formKey.currentState!.validate()) {
      if (queroEntrar) {
        _entrarUsuario(email: email, senha: senha);
      } else {
        _criarUsuario(email: email, senha: senha, nome: nome);
      }
    }
  }

  _entrarUsuario({required String email, required String senha}) {
    authenService
        .entrarUsuario(email: email, senha: senha)
        .then((String? erro) {
      if (erro == null) {
        showSnackBar(
          context: context,
          text: "Conta logada com sucesso",
          isErro: false,
        );
      } else {
        showSnackBar(context: context, text: erro);
      }
    });
  }

  _criarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) {
    authenService.cadastrarUsuario(email: email, senha: senha, nome: nome).then(
      (String? erro) {
        if (erro != null) {
          showSnackBar(context: context, text: erro);
        }
      },
    );
  }

  esqueciMinhaSenhaClicado() {
    String email = _emailController.text;
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController resetPasswordSenhaController =
            TextEditingController(text: email);
        return AlertDialog(
          title: const Text("Confirme o e-mail para redefinição de senha"),
          content: TextFormField(
            controller: resetPasswordSenhaController,
            decoration: const InputDecoration(label: Text("Confirme o e-mail")),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32))),
          actions: [
            TextButton(
              onPressed: () {
                authenService
                    .resetPassword(email: resetPasswordSenhaController.text)
                    .then((String? erro) {
                  if (erro == null) {
                    showSnackBar(
                      context: context,
                      text: "E-mail de redefinição enviado!",
                      isErro: false,
                    );
                  } else {
                    showSnackBar(context: context, text: erro);
                  }

                  Navigator.pop(context);
                });
              },
              child: const Text("Redefinir senha"),
            ),
          ],
        );
      },
    );
  }
}
