import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ManageBeverageScreen extends StatefulWidget {
  const ManageBeverageScreen({super.key});

  @override
  _ManageBeverageScreenState createState() => _ManageBeverageScreenState();
}

class _ManageBeverageScreenState extends State<ManageBeverageScreen> {
  final TextEditingController beverageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  bool isLoading = false;

  // Función para editar la bebida
  void _editBeverage(
      String beverageId, String currentTitle, double currentPrice) {
    final TextEditingController titleController =
        TextEditingController(text: currentTitle);
    final TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Bebida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Nombre de la Bebida",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Precio de la Bebida",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text;
                final newPrice =
                    double.tryParse(priceController.text) ?? currentPrice;

                await FirebaseFirestore.instance
                    .collection('beverages')
                    .doc(beverageId)
                    .update({
                  'title': newTitle,
                  'price': newPrice,
                });

                Navigator.of(context).pop(); // Cerrar diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Bebida actualizada exitosamente."),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

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
          FirebaseStorage.instance.ref().child('beverages/$fileName');
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
      setState(() {
        isLoading = true;
      });

      double price = double.parse(priceController.text);
      String? imageUrl = await _uploadImage(_image!);

      Map<String, dynamic> data = {
        'title': beverageController.text,
        'price': price,
        'imageUrl': imageUrl,
        'isHidden': false, // Default value is not hidden
      };

      await FirebaseFirestore.instance.collection('beverages').add(data);

      beverageController.clear();
      priceController.clear();
      _image = null;

      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una imagen.")),
      );
    }
  }

  void _toggleBeverageVisibility(
      String beverageId, bool currentVisibility) async {
    bool newVisibility = !currentVisibility;

    await FirebaseFirestore.instance
        .collection('beverages')
        .doc(beverageId)
        .update({
      'isHidden': newVisibility,
    });

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newVisibility ? "Bebida visible" : "Bebida oculta"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteBeverage(String id) async {
    await FirebaseFirestore.instance.collection('beverages').doc(id).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Bebidas"),
        backgroundColor: const Color.fromARGB(255, 53, 200, 220),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Panel para agregar Bebida
            ExpansionTile(
              title: const Text("Agregar Bebida"),
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
                ElevatedButton(
                  onPressed: _addBeverage,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text("Agregar Bebida"),
                ),
              ],
            ),
            // Mostrar las bebidas en un GridView
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('beverages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No hay bebidas disponibles"));
                }

                final beverageDocs = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: beverageDocs.length,
                  itemBuilder: (context, index) {
                    var beverage = beverageDocs[index];
                    final title = beverage['title'] ?? 'Sin nombre';
                    final price = beverage['price'] ?? 0.0;
                    final imageUrl = beverage['imageUrl'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.local_drink, size: 50),
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
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "\$${price.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          OverflowBar(
                            alignment: MainAxisAlignment.center,
                            overflowAlignment: OverflowBarAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  beverage['isHidden']
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  _toggleBeverageVisibility(
                                      beverage.id, beverage['isHidden']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteBeverage(beverage.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editBeverage(beverage.id, title, price);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
