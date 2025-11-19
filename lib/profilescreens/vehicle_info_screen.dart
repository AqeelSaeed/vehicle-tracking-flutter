import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleInfoScreen extends StatefulWidget {
  final String? vehicleId;

  const VehicleInfoScreen({super.key, this.vehicleId});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _vinController;
  late TextEditingController _colorController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _licensePlateController = TextEditingController();
    _vinController = TextEditingController();
    _colorController = TextEditingController();

    if (widget.vehicleId != null) {
      _loadVehicleData();
    }
  }

  Future<void> _loadVehicleData() async {
    try {
      final userId = _auth.currentUser?.uid;
      final doc = await _firestore
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _makeController.text = data['make'] ?? '';
        _modelController.text = data['model'] ?? '';
        _yearController.text = data['year'] ?? '';
        _licensePlateController.text = data['licensePlate'] ?? '';
        _vinController.text = data['vin'] ?? '';
        _colorController.text = data['color'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading vehicle: $e')));
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final vehicleData = {
        'uid': userId,
        'make': _makeController.text.trim(),
        'model': _modelController.text.trim(),
        'year': _yearController.text.trim(),
        'licensePlate': _licensePlateController.text.trim(),
        'vin': _vinController.text.trim(),
        'color': _colorController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.vehicleId != null) {
        await _firestore
            .collection('vehicles')
            .doc(widget.vehicleId)
            .update(vehicleData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully')),
        );
      } else {
        vehicleData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('vehicles').add(vehicleData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving vehicle: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicleId != null ? 'Update Vehicle' : 'Add Vehicle',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'Make'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter vehicle make' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter vehicle model' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter vehicle year' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(labelText: 'License Plate'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter license plate' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(labelText: 'VIN'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter VIN' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter vehicle color' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVehicle,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
