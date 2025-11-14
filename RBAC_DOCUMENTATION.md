# Role-Based Access Control (RBAC) Documentation

## Overview
Sistem RBAC (Role-Based Access Control) untuk mengatur akses menu berdasarkan role user dalam aplikasi Tracer Mobile ITK.

## User Roles

### 1. Admin
**Role Code**: `admin`
**Deskripsi**: Administrator sistem yang mengelola user dan unit

**Menu Access**:
- ✅ User Directory
  - Unit Directory (`/unit-management`)
  - Employee Directory (`/user-management`)

**API Endpoints**:
- `/api/admin/users` - User management
- `/api/tracer-team/faculties` - Faculty management
- `/api/tracer-team/departments` - Department management
- `/api/tracer-team/majors` - Major management

**Fungsi**:
- Mengelola akses user
- Melihat unit kerja
- Melihat pejabat unit kerja

---

### 2. Tracer Team (Tim Tracer)
**Role Code**: `tracer_team`
**Deskripsi**: Tim yang mengelola kuisioner/survey tracer study

**Menu Access**:
- ✅ Questionnaire
  - Survey Management (`/survey-management`)

**API Endpoints**:
- `/api/tracer-team/surveys` - Survey/Questionnaire management

**Fungsi**:
- Melihat daftar kuisioner
- Menambahkan kuisioner
- Mengubah kuisioner
- Menghapus kuisioner
- Menduplikat/kloning daftar kuisioner
- Melakukan pratinjau terhadap kuesioner
- Mengexport handout kuisioner
- Mengexport handout kuisioner ke dalam format BAN PT
- Mengexport handout kuisioner ke dalam format Kementerian
- Mengimport handout kuisioner
- Mengatur aktivasi kuesioner
- Memantau progress pengisian kuesioner
- Melakukan filter data pengisian kuesioner
- Mengelola halaman kuisioner (CRUD + urutan)
- Mengelola section kuisioner (CRUD + urutan + logic)
- Mengelola pertanyaan kuisioner (CRUD + urutan + logic)
- Melihat hasil pengisian responden
- Mengekspor hasil pengisian responden
- Mengelola jenis kuisioner (CRUD)
- Mengelola representasi pertanyaan dan jawaban (BAN PT & Kementerian)
- Mengirim kembali SMTP ke email supervisor secara manual
- Implementasi machine learning untuk pelaporan

---

### 3. Major Team (Tim Prodi)
**Role Code**: `major_team`
**Deskripsi**: Tim prodi yang mengelola pertanyaan tambahan survey khusus prodi mereka

**Menu Access**:
- ✅ Survey Pertanyaan Tambahan (`/major-survey-sections`)

**API Endpoints**:
- `/api/major-team/major-sections` - Major-specific survey sections

**Fungsi**:
- Melihat detail pertanyaan tambahan suatu kuesioner (sesuai prodi)
- Menambah pertanyaan tambahan suatu kuesioner (sesuai prodi)
- Mengubah pertanyaan tambahan suatu kuesioner (sesuai prodi)
- Menghapus pertanyaan tambahan suatu kuesioner (sesuai prodi)
- Mengubah urutan pertanyaan tambahan (sesuai prodi)
- Mengelola logic pertanyaan tambahan dengan kondisi tertentu (sesuai prodi)
- Mengimport hasil responden berdasarkan handouts (excel/csv)
- Mengimport responden kuisioner
- Dashboard untuk pengisian laporan BAN PT
- Mengexport hasil responden ke format Kementerian

---

### 4. Alumni Supervisor
**Role Code**: `alumni_supervisor`
**Deskripsi**: Supervisor yang bisa mengisi kuisioner

**Menu Access**:
- ✅ Fill Survey (belum diimplementasikan dalam mobile app)

**Fungsi**:
- Dapat mengisi kuisioner

---

### 5. Head of Unit (Pimpinan Unit)
**Role Code**: `head_of_unit`
**Deskripsi**: Pimpinan unit yang dapat melihat laporan

**Menu Access**:
- ✅ Unit Reports (belum diimplementasikan dalam mobile app)

**Fungsi**:
- Dapat melihat laporan pengisian kuisioner

---

## Implementation

### File Structure

```
lib/
├── constants/
│   └── roles.dart              # Role constants & permissions
├── providers/
│   └── auth_provider.dart      # Authentication state with user role
├── widgets/
│   └── app_drawer.dart         # Role-based menu rendering
└── models/
    └── user_model.dart         # User model with role field
```

### Key Files

#### 1. `lib/constants/roles.dart`
Berisi:
- `UserRole` class dengan constants untuk semua roles
- `RolePermissions` class dengan logic permission checking
- Method `hasMenuAccess(role, menu)` untuk check access
- Method `getAccessibleMenus(role)` untuk get all accessible menus
- Method `getRoleDisplayName(role)` untuk display name

#### 2. `lib/widgets/app_drawer.dart`
Berisi:
- Dynamic menu rendering based on user role
- Method `_buildMenuItems()` yang membuild menu sesuai role
- User profile display dengan role badge
- Logout integration dengan AuthProvider

### Permission Checking Flow

```
User Login
    ↓
UserModel with role field
    ↓
AuthProvider stores currentUser
    ↓
AppDrawer reads user role
    ↓
RolePermissions.hasMenuAccess(role, menu)
    ↓
Only allowed menus are rendered
```

### Code Example

#### Check if user has access to a menu:
```dart
final userRole = authProvider.currentUser?.role ?? '';

if (RolePermissions.hasMenuAccess(userRole, 'user_management')) {
  // Show user management menu
}

if (RolePermissions.hasMenuAccess(userRole, 'survey_management')) {
  // Show survey management menu
}
```

#### Get all accessible menus for a role:
```dart
final accessibleMenus = RolePermissions.getAccessibleMenus('admin');
// Returns: ['user_management', 'unit_management']
```

#### Get role display name:
```dart
final displayName = RolePermissions.getRoleDisplayName('tracer_team');
// Returns: "Tim Tracer"
```

## Menu Mapping

| Role | Menu Code | Menu Title | Route |
|------|-----------|------------|-------|
| Admin | `user_management` | Employee Directory | `/user-management` |
| Admin | `unit_management` | Unit Directory | `/unit-management` |
| Tracer Team | `survey_management` | Survey Management | `/survey-management` |
| Major Team | `major_survey_sections` | Survey Pertanyaan Tambahan | `/major-survey-sections` |
| Alumni Supervisor | `fill_survey` | Fill Survey | TBD |
| Head of Unit | `unit_reports` | Unit Reports | TBD |

## Testing

### Test Account Credentials

**Admin Account**:
- Email: `tracerstudy@itk.ac.id`
- Password: `password`
- Expected Menus:
  - ✅ User Directory → Unit Directory
  - ✅ User Directory → Employee Directory
  - ❌ Questionnaire (should NOT be visible)

**Tracer Team Account** (jika ada):
- Expected Menus:
  - ✅ Questionnaire → Survey Management
  - ❌ User Directory (should NOT be visible)

**Major Team Account** (jika ada):
- Expected Menus:
  - ✅ Survey Pertanyaan Tambahan
  - ❌ User Directory (should NOT be visible)
  - ❌ Questionnaire (should NOT be visible)

### Test Scenarios

#### Scenario 1: Admin Login
```
1. Login dengan tracerstudy@itk.ac.id
2. Open drawer
3. Verify:
   - Profile shows "Admin" as role
   - User Directory menu visible
   - Unit Directory submenu visible
   - Employee Directory submenu visible
   - Questionnaire menu NOT visible
```

#### Scenario 2: Tracer Team Login
```
1. Login dengan tracer team account
2. Open drawer
3. Verify:
   - Profile shows "Tim Tracer" as role
   - Questionnaire menu visible
   - Survey Management submenu visible
   - User Directory menu NOT visible
```

#### Scenario 3: Major Team Login
```
1. Login dengan major team account
2. Open drawer
3. Verify:
   - Profile shows "Tim Prodi" as role
   - Survey Pertanyaan Tambahan menu visible
   - User Directory menu NOT visible
   - Questionnaire menu NOT visible
```

#### Scenario 4: Unauthorized Access
```
1. Login dengan admin account
2. Try to navigate to /survey-management (manual URL)
3. Expected: Should show "No access" or redirect to home
   (Route guard needs to be implemented)
```

## Future Enhancements

### Short Term:
- ✅ Role-based menu rendering (COMPLETED)
- ⏳ Route guards to prevent unauthorized navigation
- ⏳ Permission checking in API calls
- ⏳ Error handling for insufficient permissions

### Medium Term:
- ⏳ Implement missing menus (Fill Survey, Unit Reports)
- ⏳ Add breadcrumb navigation with role context
- ⏳ Role-based feature flags
- ⏳ Audit logging for permission changes

### Long Term:
- ⏳ Dynamic permission system (from backend)
- ⏳ Permission inheritance (role hierarchy)
- ⏳ Temporary permission grants
- ⏳ Multi-role support (user with multiple roles)

## Security Notes

### Important:
1. **Frontend permission checks are for UX only**
   - Menu hiding doesn't prevent API access
   - Backend must validate permissions on every request
   - Never trust client-side permission checks

2. **Always validate on backend**
   - Check user role before processing request
   - Return 403 Forbidden for unauthorized access
   - Log unauthorized access attempts

3. **Token-based authentication**
   - Role is embedded in user data (from API)
   - Token should be validated on every request
   - Expired tokens should force re-authentication

### Backend Validation Example:
```php
// Laravel backend example
public function index(Request $request)
{
    // Check if user has permission
    if (!$request->user()->hasRole('admin')) {
        return response()->json([
            'message' => 'Unauthorized access'
        ], 403);
    }
    
    // Process request...
}
```

## Troubleshooting

### Menu tidak muncul setelah login
1. Check console logs untuk user role
2. Verify role field dalam UserModel
3. Check RolePermissions constants match API roles
4. Verify hasMenuAccess() logic

### Role tidak sesuai
1. Check API response dari `/auth/user`
2. Verify UserModel.fromJson() parsing role correctly
3. Check database role values

### Logout tidak bekerja
1. Check AuthProvider.logout() is called
2. Verify token is removed from SharedPreferences
3. Check navigation to login screen works

## API Response Format

### Login Response (after fetching user):
```json
{
  "id": 1,
  "name": "Tracer Study ITK",
  "email": "tracerstudy@itk.ac.id",
  "role": "admin",
  "unit_type": "institutional",
  "unit_id": null,
  "nik_nip": "123456789",
  "phone_number": "081234567890"
}
```

### Role Field Values:
- `"admin"` - Administrator
- `"tracer_team"` - Tim Tracer
- `"major_team"` - Tim Prodi
- `"head_of_unit"` - Pimpinan Unit
- `"alumni_supervisor"` - Supervisor Alumni

## Conclusion

Role-Based Access Control sekarang sudah terimplementasi dengan:
- ✅ Role constants dan permissions defined
- ✅ Dynamic menu rendering berdasarkan role
- ✅ User profile dengan role badge
- ✅ Proper logout flow dengan AuthProvider
- ✅ Extensible permission system

Admin sekarang hanya bisa melihat menu User Directory (Unit & Employee), tidak bisa lagi melihat menu Questionnaire.
