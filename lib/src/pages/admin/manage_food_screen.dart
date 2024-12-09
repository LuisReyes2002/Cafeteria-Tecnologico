import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lince_time/src/pages/admin/visibility_service.dart';
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
  final VisibilityService _visibilityService = VisibilityService();
  List<String> guisosList = [];
  File? _image;
  final picker = ImagePicker();

  bool? hasGuiso;
  bool isFoodExpanded = false;
  bool isLoading = false;
  bool showGuisosList = false;

  // Función para editar el platillo
  void _editFood(String foodId, String currentTitle, double currentPrice) {
    // Controladores para el diálogo de edición
    final TextEditingController titleController =
        TextEditingController(text: currentTitle);
    final TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Platillo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Nombre del Platillo",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Precio del Platillo",
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
                // Obtener los valores editados
                final newTitle = titleController.text;
                final newPrice =
                    double.tryParse(priceController.text) ?? currentPrice;

                // Actualizar Firestore
                await FirebaseFirestore.instance
                    .collection('foods')
                    .doc(foodId)
                    .update({
                  'title': newTitle,
                  'price': newPrice,
                });

                Navigator.of(context).pop(); // Cerrar diálogo

                // Mostrar un mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Platillo actualizado exitosamente."),
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
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        print("Archivo seleccionado: ${pickedFile.path}");
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        print("No se seleccionó ningún archivo.");
      }
    } catch (e) {
      print("Error seleccionando archivo: $e");
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = path.basename(image.path);
      print("Subiendo archivo: $fileName");

      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("URL de la imagen subida: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  void _toggleFoodVisibility(String foodId, bool currentVisibility) async {
    bool newVisibility = !currentVisibility;

    await FirebaseFirestore.instance.collection('foods').doc(foodId).update({
      'isHidden': newVisibility,
    });

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newVisibility ? "Platillo visible" : "Platillo oculto"),
        duration: const Duration(seconds: 1),
      ),
    );
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
        'isHidden': false, // Default value is not hidden
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
        SnackBar(
          content: Text("Por favor, selecciona una imagen."),
          duration: const Duration(seconds: 1),
        ),
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

  void _removeGuisoFromFood(String guiso) {
    setState(() {
      guisosList.remove(guiso);
    });
  }

  void _deleteFood(String id) async {
    await FirebaseFirestore.instance.collection('foods').doc(id).delete();
    setState(() {});
  }

  void _hideFoodForUser(String foodId) async {
    await FirebaseFirestore.instance
        .collection('foods')
        .doc(foodId)
        .update({'isHidden': true});
    setState(() {});
  }

  void _deleteGuiso(String guisoName) async {
    final foods = await FirebaseFirestore.instance
        .collection('foods')
        .where('guisos_adicionales', arrayContains: guisoName)
        .get();

    for (var food in foods.docs) {
      await FirebaseFirestore.instance.collection('foods').doc(food.id).update({
        'guisos_adicionales': FieldValue.arrayRemove([guisoName]),
      });
      if ((food.data()['guisos_adicionales'] as List).isEmpty) {
        await FirebaseFirestore.instance
            .collection('foods')
            .doc(food.id)
            .update({'isHidden': true});
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Platillos"),
        backgroundColor: const Color.fromARGB(255, 53, 200, 220),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
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
                Row(
                  children: [
                    Checkbox(
                      value: showGuisosList,
                      onChanged: (bool? value) {
                        setState(() {
                          showGuisosList = value ?? false;
                        });
                      },
                    ),
                    const Text("Mostrar lista de guisos"),
                  ],
                ),
                if (showGuisosList)
                  Column(
                    children: guisosList
                        .map((guiso) => ListTile(
                              title: Text(guiso),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  _removeGuisoFromFood(guiso);
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ElevatedButton(
                  onPressed: _addGuiso,
                  child: const Text("Agregar Guiso"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (guisoController.text.isNotEmpty) {
                      _deleteGuiso(guisoController.text);
                      guisoController.clear();
                    }
                  },
                  child: const Text("Eliminar Guiso"),
                ),
              ],
            ),
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
                        icon: const Icon(Icons.image),
                        onPressed: _pickImage,
                      ),
                      if (_image != null)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          width: 50,
                          height: 50,
                          child: Image.file(_image!),
                        ),
                      Expanded(
                        child: TextField(
                          controller: foodController,
                          decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
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
                        });
                      },
                    ),
                    const Text("No"),
                  ],
                ),
                ElevatedButton(
                  onPressed: _addFood,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Agregar Platillo"),
                ),
              ],
            ),
            // Mostrar los platillos en un GridView
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('foods').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No hay platillos disponibles"));
                }

                final foodDocs = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: foodDocs.length,
                  itemBuilder: (context, index) {
                    var food = foodDocs[index];
                    final title = food['title'] ?? 'Sin nombre';
                    final price = food['price'] ?? 0.0;
                    final imageUrl = food['imageUrl'] ?? '';

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
                                : Icon(Icons.local_dining, size: 50),
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
                                  food['isHidden']
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  _toggleFoodVisibility(
                                      food.id, food['isHidden']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteFood(food.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editFood(
                                      food.id, food['title'], food['price']);
                                },
                              ),
                            ],
                          ),
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
