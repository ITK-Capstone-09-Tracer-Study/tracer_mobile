# Tracer Study ITK Mobile App

Aplikasi mobile untuk Tracer Study Institut Teknologi Kalimantan.

## Fitur

### ✅ Sudah Diimplementasikan
- **User Management**
  - Daftar user dengan tabel scrollable horizontal
  - Search user berdasarkan nama, email, role, unit, NIK/NIP
  - Group by Unit atau Role
  - Detail user dengan form edit
  - Auto-save dengan validasi
  - Dummy data untuk testing

- **Navigation & UI**
  - Sidebar dengan user profile
  - Dropdown menu untuk User Directory (Unit Management & Employee Directory)
  - GoRouter dengan nested routes
  - Material Design 3
  - Responsive design

### 🚧 Coming Soon
- Unit Management
- Add New Employee
- Delete User
- API Integration
- Authentication
- Dashboard

## Struktur Project

```
lib/
├── constants/          # Konstanta aplikasi
│   ├── app_constants.dart
│   └── colors.dart
├── models/            # Model data
│   └── user_model.dart
├── providers/         # State management dengan Provider
│   └── user_provider.dart
├── routes/           # Routing dengan GoRouter
│   └── app_router.dart
├── screens/          # Halaman-halaman aplikasi
│   ├── home_screen.dart
│   ├── user_management/
│   │   ├── user_management_screen.dart
│   │   └── user_detail_screen.dart
│   └── unit_management/
│       └── unit_management_screen.dart
├── theme/            # Theme Material Design 3
│   └── app_theme.dart
├── widgets/          # Reusable widgets
│   └── app_drawer.dart
└── main.dart         # Entry point
```

## Dependencies

- **flutter_svg**: ^2.0.10+1 - Untuk menampilkan logo SVG
- **go_router**: ^14.6.2 - Routing dengan nested routes
- **provider**: ^6.1.2 - State management
- **http**: ^1.2.2 - HTTP client untuk future API integration

## Cara Menjalankan

1. Install dependencies:
```bash
flutter pub get
```

2. Jalankan aplikasi:
```bash
flutter run
```

## Fitur User Management

### Halaman User Management
- **Search**: Cari user berdasarkan nama, email, role, unit, atau NIK/NIP
- **New Employee**: Tombol untuk menambah employee baru (coming soon)
- **Group By**: Dropdown untuk grouping berdasarkan Unit atau Role (coming soon)
- **Table**: Tabel dengan scroll horizontal menampilkan:
  - Name
  - Email
  - Role
  - Unit
- **Row Click**: Klik row untuk membuka detail user

### Halaman User Detail
- **Personal Information**:
  - Full Name (required)
  - Email (required, validated)
  - NIK/NIP
  - Phone Number
  
- **Work Information**:
  - Role (dropdown, required)
  - Unit (dropdown, required)
  - Position

- **Auto Save**: Tombol save muncul otomatis saat ada perubahan
- **Validation**: Form validation sebelum save
- **Discard Warning**: Dialog konfirmasi jika kembali tanpa save

## Design System

### Material Design 3
Aplikasi menggunakan Material Design 3 dengan komponen-komponen:
- Elevated Buttons
- Text Buttons
- Outlined Buttons
- Text Fields dengan validation
- Dropdown menus
- Cards
- AppBar
- Drawer/Sidebar

### Color Scheme
- **Primary**: #1976D2 (Blue)
- **Secondary**: #2196F3 (Light Blue)
- **Background**: #F5F5F5
- **Surface**: #FFFFFF
- **Error**: #D32F2F
- **Success**: #388E3C

### Responsiveness
- Layout responsive untuk berbagai ukuran layar
- Table dengan horizontal scroll
- Padding dan spacing konsisten
- Typography yang scalable

## Routing Structure

```
/ (Home)
├── /user-management (User Management)
│   └── /user-management/detail/:userId (User Detail - Nested)
└── /unit-management (Unit Management)
```

## Data Flow

1. **UserProvider** mengelola state user dengan Provider pattern
2. **Dummy data** tersedia untuk testing (7 user contoh)
3. **CRUD operations** sudah diimplementasi di provider:
   - Read: `getUserById()`, `filteredUsers`
   - Update: `updateUser()`
   - Search: `searchUsers()`
   - Group: `getUsersByUnit()`, `getUsersByRole()`

## Future Development

1. **API Integration**
   - Connect ke backend API
   - Authentication & Authorization
   - Real-time data sync

2. **Enhanced Features**
   - Add/Delete user functionality
   - Bulk operations
   - Export data
   - Advanced filtering
   - User permissions

3. **Unit Management**
   - CRUD unit
   - Assign users to units
   - Unit hierarchy

4. **Dashboard**
   - Statistics
   - Charts & graphs
   - Quick actions

## Notes

- Logo ITK tersimpan di `assets/Frame 1686.svg`
- Dummy data user ada di `UserProvider` untuk testing
- Nested routing menggunakan GoRouter untuk User Detail
- Form validation menggunakan Flutter Form & TextFormField
- State management menggunakan Provider pattern

---

Dibuat untuk Capstone Project - Tracer Study ITK
