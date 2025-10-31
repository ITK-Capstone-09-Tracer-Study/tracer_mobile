class AppConstants {
  // App Info
  static const String appName = 'Tracer Study ITK';
  static const String appVersion = '1.0.0';
  static const String institutionName = 'Institut Teknologi Kalimantan';
  
  // Assets
  static const String logoPath = 'assets/Frame 1686.svg';
  
  // API Endpoints (untuk future implementation)
  static const String baseUrl = 'https://api.tracerstudy.itk.ac.id';
  
  // Routes
  static const String homeRoute = '/';
  static const String userManagementRoute = '/user-management';
  static const String userDetailRoute = '/user-management/detail';
  static const String unitManagementRoute = '/unit-management';
  
  // Table settings
  static const double tableRowHeight = 56.0;
  static const double tableHeaderHeight = 56.0;
  static const double tableColumnMinWidth = 150.0;
  
  // Sidebar settings
  static const double sidebarWidth = 280.0;
  static const double collapsedSidebarWidth = 72.0;
  
  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  // User Roles
  static const List<String> userRoles = [
    'Admin',
    'Staff',
    'Dosen',
    'Alumni',
    'Mahasiswa',
  ];
  
  // Units (contoh data)
  static const List<String> units = [
    'Teknik Informatika',
    'Teknik Elektro',
    'Teknik Mesin',
    'Teknik Sipil',
    'Teknik Kimia',
    'Administrasi',
  ];
}
