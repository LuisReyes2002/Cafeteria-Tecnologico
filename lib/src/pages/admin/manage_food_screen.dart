import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ManageFoodScreen extends StatefulWidget {
  const ManageFoodScreen({super.key});

  @override
  _ManageFoodScreenState createState() => _ManageFoodScreenState();
}

class _ManageFoodScreenState extends State<ManageFoodScreen> {
  final TextEditingController foodController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController guisoController = TextEditingController();

  List<String> guisosList = []; // Lista para almacenar guisos adicionales
  File? _image;
  final picker = ImagePicker();

  bool? hasGuiso;
  bool isFoodExpanded = false;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = path.basename(image.path);
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  void _addFood() async {
    if (foodController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        _image != null) {
      setState(() {
        isLoading = true;
      });

      double price = double.parse(priceController.text);
      String? imageUrl = await _uploadImage(_image!);

      Map<String, dynamic> data = {
        'title': foodController.text,
        'price': price,
        'imageUrl': imageUrl,
        'guisos_adicionales': guisosList.isEmpty ? [""] : guisosList,
      };

      await FirebaseFirestore.instance.collection('foods').add(data);

      foodController.clear();
      priceController.clear();
      guisoController.clear();
      _image = null;
      guisosList.clear();
      hasGuiso = null;

      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una imagen.")),
      );
    }
  }

  void _addGuiso() {
    if (guisoController.text.isNotEmpty) {
      setState(() {
        guisosList.add(guisoController.text);
        guisoController.clear();
      });
    }
  }

  void _deleteFood(String id) async {
    await FirebaseFirestore.instance.collection('foods').doc(id).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Platillos"),
        backgroundColor: Colors.tealAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, '/login'); // Redirigir al login
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Panel para agregar Guiso
            ExpansionTile(
              title: const Text("Agregar Guiso"),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: guisoController,
                    decoration: InputDecoration(
                      labelText: "Nombre del Guiso Adicional",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addGuiso,
                  child: const Text("Agregar Guiso"),
                ),
                if (guisosList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: guisosList.map((guiso) => Text(guiso)).toList(),
                    ),
                  ),
              ],
            ),
            // Panel para agregar Platillo
            ExpansionTile(
              title: const Text("Agregar Platillo"),
              onExpansionChanged: (value) {
                setState(() {
                  isFoodExpanded = value;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: foodController,
                          decoration: InputDecoration(
                            labelText: "Nombre del Platillo",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: "Precio del Platillo",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Text("¿Este platillo lleva guiso?"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: hasGuiso,
                      onChanged: (value) {
                        setState(() {
                          hasGuiso = value;
                        });
                      },
                    ),
                    const Text("Sí"),
                    Radio<bool>(
                      value: false,
                      groupValue: hasGuiso,
                      onChanged: (value) {
                        setState(() {
                          hasGuiso = value;
                          guisosList.clear();
                        });
                      },
                    ),
                    const Text("No"),
                  ],
                ),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.file(
                      _image!,
                      height: 150,
                    ),
                  ),
                if (isFoodExpanded)
                  ElevatedButton(
                    onPressed: _addFood,
                    child: const Text("Agregar Platillo"),
                  ),
              ],
            ),
            // Listado de platillos
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.63,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('foods').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final foodList = snapshot.data!.docs;
                  if (foodList.isEmpty) {
                    return Center(child: Text("No se ha agregado comida"));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: foodList.length,
                    itemBuilder: (context, index) {
                      final food = foodList[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                food['imageUrl'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                food['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "\$${food['price'].toString()}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteFood(food.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (isLoading) ...[
              LinearProgressIndicator(),
              SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
