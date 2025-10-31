import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unit_provider.dart';
import '../../models/unit_model.dart';
import '../../constants/colors.dart';
import '../../constants/app_constants.dart';

class AddUnitDialog extends StatefulWidget {
  final String unitType; // 'fakultas', 'jurusan', 'program_studi'

  const AddUnitDialog({
    super.key,
    required this.unitType,
  });

  @override
  State<AddUnitDialog> createState() => _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedParentId;
  List<UnitModel> _parentOptions = [];

  @override
  void initState() {
    super.initState();
    _loadParentOptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadParentOptions() {
    final unitProvider = context.read<UnitProvider>();
    
    if (widget.unitType == 'jurusan') {
      _parentOptions = unitProvider.getFakultasList();
    } else if (widget.unitType == 'program_studi') {
      _parentOptions = unitProvider.getUnitsByType('jurusan');
    }
  }

  String _getTitle() {
    switch (widget.unitType) {
      case 'fakultas':
        return 'Fakultas';
      case 'jurusan':
        return 'Jurusan';
      case 'program_studi':
        return 'Program Studi';
      default:
        return 'Unit';
    }
  }

  String _getParentLabel() {
    if (widget.unitType == 'jurusan') {
      return 'Pilih Fakultas';
    } else if (widget.unitType == 'program_studi') {
      return 'Pilih Jurusan';
    }
    return '';
  }

  String _getNameLabel() {
    switch (widget.unitType) {
      case 'fakultas':
        return 'Nama Fakultas';
      case 'jurusan':
        return 'Nama Jurusan';
      case 'program_studi':
        return 'Nama Program Studi';
      default:
        return 'Nama';
    }
  }

  void _createUnit() {
    if (_formKey.currentState!.validate()) {
      // Validate parent selection for jurusan and program_studi
      if (widget.unitType != 'fakultas' && _selectedParentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select ${_getParentLabel()}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      String? parentName;
      if (_selectedParentId != null) {
        final parent = context.read<UnitProvider>().getUnitById(_selectedParentId!);
        parentName = parent?.name;
      }

      final newUnit = UnitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: widget.unitType,
        parentId: _selectedParentId,
        parentName: parentName,
        createdAt: DateTime.now(),
      );

      context.read<UnitProvider>().addUnit(newUnit);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTitle()} created successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Parent Selection (for Jurusan and Program Studi)
                  if (widget.unitType != 'fakultas') ...[
                    RichText(
                      text: TextSpan(
                        text: _getParentLabel(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedParentId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select position',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: _parentOptions.map((unit) {
                        return DropdownMenuItem(
                          value: unit.id,
                          child: Text(
                            unit.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedParentId = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                  ],

                  // Name Field
                  RichText(
                    text: TextSpan(
                      text: _getNameLabel(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: '',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ${_getNameLabel().toLowerCase()}';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _createUnit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Create'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
