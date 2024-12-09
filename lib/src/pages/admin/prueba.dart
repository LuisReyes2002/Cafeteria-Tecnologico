import 'package:flutter/material.dart';
import 'package:lince_time/src/pages/admin/notifacion.dart'; // Importa tu clase NotificationService

class PruebaPage extends StatefulWidget {
  @override
  _PruebaPageState createState() => _PruebaPageState();
}

class _PruebaPageState extends State<PruebaPage> {
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    NotificationService
        .init(); // Inicializamos las notificaciones al abrir la página
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prueba de Notificaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Mostrar una notificación inmediata al presionar el botón
                NotificationService.showNotification(
                  id: 1,
                  title: 'Notificación Inmediata',
                  body: 'Esta es una notificación de prueba.',
                );
              },
              child: Text('Mostrar Notificación Inmediata'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Programar una notificación al presionar el botón
                final selectedTime = await _pickDateTime(context);
                if (selectedTime != null) {
                  setState(() {
                    _selectedTime = selectedTime;
                  });
                  NotificationService.scheduleNotification(
                    id: 2,
                    title: 'Notificación Programada',
                    body: 'Esta es una notificación programada.',
                    scheduledTime: selectedTime,
                  );
                }
              },
              child: Text('Programar Notificación'),
            ),
            SizedBox(height: 20),
            if (_selectedTime != null)
              Text(
                'Notificación programada para: ${_selectedTime!.toLocal()}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  /// Selector de fecha y hora
  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
