import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../constants/colors.dart';

/// App Footer dengan informasi kontak dan alamat ITK
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo dan Deskripsi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracer Study',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Institut Teknologi Kalimantan',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Direktorat Kemahasiswaan ITK\nKementerian Pendidikan Tinggi, Sains, dan Teknologi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          const Divider(),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Alamat
          _buildInfoSection(
            context,
            title: 'ALAMAT',
            icon: Icons.location_on_outlined,
            content: 'Jl. Soekarno Hatta No.KM 15, Karang Joang\n'
                'Kec. Balikpapan Utara, Kota Balikpapan,\n'
                'Kalimantan Timur 76127',
          ),
          
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Kontak
          _buildInfoSection(
            context,
            title: 'KONTAK',
            icon: Icons.phone_outlined,
            content: '08115390801 | 0542-8530800',
          ),
          
          const SizedBox(height: 8),
          
          _buildInfoItem(
            context,
            icon: Icons.email_outlined,
            content: 'humas@itk.ac.id',
          ),
          
          const SizedBox(height: AppConstants.paddingLarge),
          const Divider(),
          const SizedBox(height: AppConstants.paddingMedium),
          
          // Copyright
          Center(
            child: Text(
              'Institut Teknologi Kalimantan © 2025. All Right Reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoItem(context, icon: icon, content: content),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
