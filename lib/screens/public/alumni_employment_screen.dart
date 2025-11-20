import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_constants.dart';
import '../../constants/colors.dart';
import '../../widgets/app_footer.dart';

/// Alumni Employment Screen - Pertanyaan apakah alumni sudah bekerja
class AlumniEmploymentScreen extends StatefulWidget {
  const AlumniEmploymentScreen({super.key});

  @override
  State<AlumniEmploymentScreen> createState() => _AlumniEmploymentScreenState();
}

class _AlumniEmploymentScreenState extends State<AlumniEmploymentScreen> {
  String? _isEmployed;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_isEmployed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih salah satu jawaban'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Save response to API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      // Navigate ke daftar kuesioner
      Navigator.pushReplacementNamed(context, '/available-surveys');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          children: [
            SvgPicture.asset(
              AppConstants.logoPath,
              height: 35,
            ),
            const SizedBox(width: 12),
            const Text('Status Pekerjaan'),
          ],
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  Row(
                    children: [
                      _buildProgressStep(1, 'Verifikasi', true),
                      Expanded(child: _buildProgressLine(true)),
                      _buildProgressStep(2, 'Status', true),
                      Expanded(child: _buildProgressLine(false)),
                      _buildProgressStep(3, 'Kuesioner', false),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Question Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Apakah Anda sudah bekerja?',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pilih salah satu jawaban di bawah ini',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Radio Options
                        _buildRadioOption(
                          value: 'yes',
                          title: 'YA',
                          description: 'Saya sudah bekerja',
                          icon: Icons.check_circle_outline,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildRadioOption(
                          value: 'no',
                          title: 'TIDAK',
                          description: 'Saya belum bekerja',
                          icon: Icons.cancel_outlined,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Navigation Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
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
                              : const Text('Lanjutkan'),
                        ),
                      ),
                    ],
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

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? AppColors.primary : AppColors.divider,
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _isEmployed == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _isEmployed = value;
        });
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.05) 
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _isEmployed,
              onChanged: (val) {
                setState(() {
                  _isEmployed = val;
                });
              },
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
