import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ManageBeveragesScreen extends StatefulWidget {
  const ManageBeveragesScreen({super.key});

  @override
  _ManageBeveragesScreenState createState() => _ManageBeveragesScreenState();
}

class _ManageBeveragesScreenState extends State<ManageBeveragesScreen> {
  final TextEditingController beverageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _image;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = path.basename(image.path);
      Reference storageRef =
          FirebaseStorage.instance.ref().child('beverages/images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  void _addBeverage() async {
    if (beverageController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        _image != null) {
      double price = double.parse(priceController.text);

      String? imageUrl = await _uploadImage(_image!);

      if (imageUrl != null) {
        Map<String, dynamic> data = {
          'title': beverageController.text,
          'price': price,
          'imageUrl': imageUrl,
        };

        // Agregar bebida a Firestore
        await FirebaseFirestore.instance.collection('beverages').add(data);

        // Limpiar campos
        beverageController.clear();
        priceController.clear();
        _image = null;
        setState(() {}); // Actualiza la pantalla
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Por favor, completa todos los campos y selecciona una imagen.")),
      );
    }
  }

  void _deleteBeverage(String id) async {
    await FirebaseFirestore.instance.collection('beverages').doc(id).delete();
    setState(() {}); // Actualiza la pantalla después de eliminar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Bebidas"),
        backgroundColor: Colors.tealAccent,
      ),
      body: Column(
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
                    controller: beverageController,
                    decoration: InputDecoration(
                      labelText: "Nombre de la Bebida",
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
                labelText: "Precio de la Bebida",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.file(
                _image!,
                height: 150,
              ),
            ),
          ElevatedButton(
            onPressed: _addBeverage,
            child: const Text("Agregar Bebida"),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('beverages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final beverageList = snapshot.data!.docs;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dos tarjetas por fila
                    childAspectRatio: 0.75, // Ajuste de la relación de aspecto
                  ),
                  itemCount: beverageList.length,
                  itemBuilder: (context, index) {
                    final beverage = beverageList[index];

                    // Verificar la existencia de los campos antes de usarlos
                    final title = beverage['title'] ?? 'Sin nombre';
                    final price = beverage['price'] ?? 0.0;
                    final imageUrl = beverage['imageUrl'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.local_drink,
                                    size:
                                        50), // Icono por defecto si no hay imagen
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("\$${price.toStringAsFixed(2)}"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteBeverage(beverage.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
