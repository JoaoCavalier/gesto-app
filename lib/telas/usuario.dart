import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
      _nameController.text =
          userName ?? ''; // Atualiza o controlador com o nome do usuário
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
    _nameController
        .dispose(); // Libera o controlador quando não for mais necessário
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? userName =
        Provider.of<SharedPreferences>(context).getString('userName');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuário"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (userName != null && userName.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 213, 231, 214),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "💰 Bem-vindo, ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    const Text(
                      " 💵!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onTap: _pickCoverImage, // Seleciona a imagem de capa
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _coverImage == null
                        ? const Center(
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 30))
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 25, // Ajusta a posição da foto do perfil
                  child: GestureDetector(
                    onTap: _pickImage, // Seleciona a imagem do perfil
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
                  _nameController, // Usa o controlador para gerenciar o texto
              decoration: InputDecoration(labelText: "Nome"),
              onSubmitted: _updateUser,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _updateUser(_nameController.text);
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
