/// Constants untuk User Roles dan Permissions
library;

/// User Roles sesuai dengan API
class UserRole {
  static const String admin = 'admin';
  static const String tracerTeam = 'tracer_team';
  static const String majorTeam = 'major_team';
  static const String headOfUnit = 'head_of_unit';
  static const String alumniSupervisor = 'alumni_supervisor';
}

/// Menu/Feature permissions berdasarkan role
class RolePermissions {
  /// Admin permissions
  /// - Mengelola akses user
  /// - Melihat unit kerja
  /// - Melihat pejabat unit kerja
  static const List<String> adminMenus = [
    'user_management', // Mengelola User
    'unit_management', // Melihat Unit (Faculty, Department, Major)
  ];

  /// Tracer Team permissions
  /// - Melihat daftar kuisioner
  /// - Menambahkan kuisioner
  /// - Menubah kuisioner
  /// - Menghapus kuisioner
  /// - Menduplikat/kloning daftar kuisioner
  /// - Melakukan pratinjau terhadap kuesioner
  /// - Mengexport handout kuisioner
  /// - Mengexport handout kuisioner ke dalam format BAN PT
  /// - Mengexport handout kuisioner ke dalam format Kementerian
  /// - Mengimport handout kuisioner
  /// - Mengatur aktivasi kuesioner
  /// - Memantau progress pengisian kuesioner
  /// - Melakukan filter data pengisian kuesioner
  /// - Melihat halaman suatu kuesioner
  /// - Menambah halaman suatu kuesioner
  /// - Mengubah halaman suatu kuesioner
  /// - Menghapus halaman suatu kuesioner
  /// - Mengubah urutan halaman suatu kuesioner
  /// - Melihat detail section suatu kuesioner
  /// - Menambah section suatu kuesioner
  /// - Mengubah section suatu kuesioner
  /// - Menghapus section suatu kuesioner
  /// - Mengubah urutan section suatu kuesioner
  /// - Mengelola logic yang menampilkan section dengan kondisi tertentu
  /// - Melihat detail pertanyaan suatu kuesioner
  /// - Menambah pertanyaan suatu kuesioner
  /// - Mengubah pertanyaan suatu kuesioner
  /// - Menghapus pertanyaan suatu kuesioner
  /// - Mengubah urutan pertanyaan suatu kuesioner
  /// - Mengelola logic yang menampilkan pertanyaan dengan kondisi tertentu
  /// - Melihat hasil pengisian responden
  /// - Mengekspor hasil pengisian responden
  /// - Menambahkan jenis kuisioner
  /// - Mengubah jenis kuisioner
  /// - Menghapus jenis kuisioner
  /// - Mengelola representasi pertanyaan dan jawaban kedalam format BAN PT dan Kementerian
  /// - Mengirim kembali smtp ke email supervisor secara manual
  /// - Implementasi machine learning untuk pelaporan kuisioner (Tracer Study, Exit Survey, SKP)
  static const List<String> tracerTeamMenus = [
    'survey_management', // Questionnaire/Survey management
  ];

  /// Major Team permissions
  /// - Melihat detail pertanyaan tambahan suatu kuesioner sesuai dengan prodi yang login
  /// - Menambah pertanyaan tambahan suatu kuesioner sesuai dengan prodi yang login
  /// - Mengubah pertanyaan tambahan suatu kuesioner sesuai dengan prodi yang login
  /// - Menghapus pertanyaan tambahan suatu kuesioner sesuai dengan prodi yang login
  /// - Mengubah urutan pertanyaan tambahan suatu kuesioner sesuai dengan prodi yang login
  /// - Mengelola logic yang menampilkan pertanyaan tambahan dengan kondisi tertentu sesuai dengan prodi yang login
  /// - Bisa mengimport hasil responden berdasarkan handouts kuisioner yang diexport melalui excel/csv keedalam sistem
  /// - Mengimport responden kuisioner
  /// - Menyediakan dashboard untuk membantu pengisian laporan BAN PT
  /// - Mengexport hasil responden kuisioner ke dalam format Kementerian
  static const List<String> majorTeamMenus = [
    'major_survey_sections', // Survey Pertanyaan Tambahan (Major-specific)
  ];

  /// Alumni Supervisor permissions
  /// - Dapat mengisi kuisioner
  static const List<String> alumniSupervisorMenus = [
    'fill_survey', // Mengisi kuisioner
  ];

  /// Head of Unit permissions
  /// - Dapat melihat laporan pengisian kuisioner
  static const List<String> headOfUnitMenus = [
    'unit_reports', // Laporan Unit
  ];

  /// Pimpinan Unit (Head of Unit) permissions
  /// - Dapat melihat laporan pengisian kuisioner
  static const List<String> leaderMenus = [
    'unit_reports', // Laporan Unit
  ];

  /// Check if user has permission to access a menu
  static bool hasMenuAccess(String role, String menu) {
    switch (role) {
      case UserRole.admin:
        return adminMenus.contains(menu);
      case UserRole.tracerTeam:
        return tracerTeamMenus.contains(menu);
      case UserRole.majorTeam:
        return majorTeamMenus.contains(menu);
      case UserRole.alumniSupervisor:
        return alumniSupervisorMenus.contains(menu);
      case UserRole.headOfUnit:
        return headOfUnitMenus.contains(menu);
      default:
        return false;
    }
  }

  /// Get all menus accessible by a role
  static List<String> getAccessibleMenus(String role) {
    switch (role) {
      case UserRole.admin:
        return adminMenus;
      case UserRole.tracerTeam:
        return tracerTeamMenus;
      case UserRole.majorTeam:
        return majorTeamMenus;
      case UserRole.alumniSupervisor:
        return alumniSupervisorMenus;
      case UserRole.headOfUnit:
        return headOfUnitMenus;
      default:
        return [];
    }
  }

  /// Get display name for role
  static String getRoleDisplayName(String role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.tracerTeam:
        return 'Tim Tracer';
      case UserRole.majorTeam:
        return 'Tim Prodi';
      case UserRole.alumniSupervisor:
        return 'Supervisor';
      case UserRole.headOfUnit:
        return 'Pimpinan Unit';
      default:
        return 'Unknown';
    }
  }
}
