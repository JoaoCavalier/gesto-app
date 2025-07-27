import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/movimentacoes.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final ImagePicker _picker = ImagePicker();

  String? userName;
  File? _image; // Imagem do perfil
  File? _coverImage; // Imagem de capa
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadImages();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      _nameController.text = userName ?? '';
    });
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final profileImagePath = '${directory.path}/profile_image.png';
    final coverImagePath = '${directory.path}/cover_image.png';

    if (await File(profileImagePath).exists()) {
      setState(() {
        _image = File(profileImagePath);
      });
    }

    if (await File(coverImagePath).exists()) {
      setState(() {
        _coverImage = File(coverImagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _saveImage(_image!, 'profile_image.png');
    }
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
      await _saveImage(_coverImage!, 'cover_image.png');
    }
  }

  Future<void> _saveImage(File image, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    await image.copy(path);
  }

  Future<void> _updateUser(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    setState(() {
      userName = name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? userName =
        Provider.of<SharedPreferences>(context).getString('userName');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Usuário",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green, // Fundo verde
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Usuário"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UsuarioScreen()));
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Usuário"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const UsuarioScreen()));
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Home"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.attach_money_sharp, color: Colors.green),
              title: const Text("Movimentações"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MovimentacoesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.green),
              title: const Text("Cartão"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CartaoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.green),
              title: const Text("Gráficos"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GraficoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text("Objetivos"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ObjetivoScreen()));
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              iconColor: Colors.red,
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                AuthenticationService().logout();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mensagem de boas-vindas no canto superior esquerdo
            if (userName != null && userName.isNotEmpty)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                  child: Text(
                    "💵 Olá, $userName!",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        image: _coverImage != null
                            ? DecorationImage(
                                image: FileImage(_coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: _coverImage == null
                          ? const Center(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome",
                        labelStyle: TextStyle(color: Colors.green),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      onSubmitted: _updateUser,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {
                          _updateUser(_nameController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        "Salvar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ObjetivoScreem {
}