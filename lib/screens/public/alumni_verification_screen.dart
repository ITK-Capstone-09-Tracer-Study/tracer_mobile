import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_constants.dart';
import '../../constants/colors.dart';
import '../../widgets/public_drawer.dart';
import '../../widgets/app_footer.dart';

/// Alumni Verification Screen - Form untuk verifikasi identitas alumni
/// Sesuai dengan UI Web: Nama, NIM, Jurusan, Tanggal Lahir, Email, Telepon, NIK, NPWP
class AlumniVerificationScreen extends StatefulWidget {
  const AlumniVerificationScreen({super.key});

  @override
  State<AlumniVerificationScreen> createState() => _AlumniVerificationScreenState();
}

class _AlumniVerificationScreenState extends State<AlumniVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _majorController = TextEditingController();
  final _ijazahController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nikController = TextEditingController();
  final _npwpController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedMajor;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _majorController.dispose();
    _ijazahController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nikController.dispose();
    _npwpController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _verifyAlumni() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Call API untuk verifikasi alumni (dartdoc)
    // Endpoint akan ditentukan berdasarkan api.json
    
    await Future.delayed(const Duration(seconds: 2)); // Simulasi API call
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      // Navigate ke halaman employment question
      Navigator.pushNamed(context, '/alumni-employment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: SvgPicture.asset(
          AppConstants.logoPath,
          height: 35,
        ),
        elevation: 1,
      ),
      drawer: const PublicDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Selamat Datang Alumni!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan isi data untuk memverifikasi identitas Anda sebelum melanjutkan.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Lengkap
                        _buildLabel('Nama Lengkap (Sesuai Ijazah)', isRequired: true),
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration('Contoh: Amiena Putri'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama lengkap wajib diisi';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // NIM
                        _buildLabel('NIM (Nomor Induk Mahasiswa)', isRequired: true),
                        TextFormField(
                          controller: _nimController,
                          decoration: _buildInputDecoration('Contoh: 11221006'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIM wajib diisi';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Jurusan
                        _buildLabel('Jurusan', isRequired: true),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMajor,
                          decoration: _buildInputDecoration('-- Pilih Jurusan --'),
                          items: const [
                            DropdownMenuItem(value: 'TI', child: Text('Teknik Informatika')),
                            DropdownMenuItem(value: 'TE', child: Text('Teknik Elektro')),
                            DropdownMenuItem(value: 'TK', child: Text('Teknik Kimia')),
                            DropdownMenuItem(value: 'TM', child: Text('Teknik Mesin')),
                            DropdownMenuItem(value: 'TS', child: Text('Teknik Sipil')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMajor = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Jurusan wajib dipilih';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Nomor Ijazah / Kelulusan
                        _buildLabel('Nomor Ijazah / Kelulusan', isRequired: true),
                        TextFormField(
                          controller: _ijazahController,
                          decoration: _buildInputDecoration('Contoh: 123/SK/IX/2024'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor Ijazah wajib diisi';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Tanggal Lahir
                        _buildLabel('Tanggal Lahir', isRequired: true),
                        TextFormField(
                          controller: _birthDateController,
                          decoration: _buildInputDecoration('Pilih tanggal...').copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal lahir wajib diisi';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Email Aktif
                        _buildLabel('Email Aktif', isRequired: true),
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration('Contoh: budi@email.com'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!value.contains('@')) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // Nomor Telepon (WhatsApp)
                        _buildLabel('Nomor Telepon (WhatsApp)', isRequired: true),
                        TextFormField(
                          controller: _phoneController,
                          decoration: _buildInputDecoration('Contoh: 08123456789'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor telepon wajib diisi';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // NIK (Nomor KTP)
                        _buildLabel('NIK (Nomor KTP)', isRequired: true),
                        TextFormField(
                          controller: _nikController,
                          decoration: _buildInputDecoration('Contoh: 3201... (16 digit)'),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIK wajib diisi';
                            }
                            if (value.length != 16) {
                              return 'NIK harus 16 digit';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppConstants.paddingMedium),
                        
                        // NPWP (Jika Ada)
                        _buildLabel('NPWP (Jika Ada)', isRequired: false),
                        TextFormField(
                          controller: _npwpController,
                          decoration: _buildInputDecoration('Contoh: 99.888.777.6-543.000'),
                          keyboardType: TextInputType.number,
                        ),
                        
                        const SizedBox(height: AppConstants.paddingLarge),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyAlumni,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Verifikasi'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }
}
