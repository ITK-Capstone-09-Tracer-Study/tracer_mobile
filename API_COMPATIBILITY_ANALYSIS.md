# Analisis Kesesuaian Model dengan API

## Status: ✅ SUDAH SESUAI

Dokumentasi ini menjelaskan kesesuaian antara model Flutter dengan API Laravel Backend untuk **User Management** dan **Department Management** (Faculty, Department, Major).

---

## 1. USER MANAGEMENT

### API Endpoint: `/{panel}/users`

### Model: `UserModel` ✅

**Kesesuaian dengan `UserTransformer` dari API:**

| Field API | Type API | Model Field | Type Model | Status |
|-----------|----------|-------------|------------|--------|
| `id` | integer | `id` | int | ✅ Match |
| `email` | string | `email` | String | ✅ Match |
| `email_verified_at` | string/null (datetime) | `emailVerifiedAt` | DateTime? | ✅ Match |
| `role` | Role enum | `role` | String | ✅ Match |
| `unit_type` | Unit enum | `unitType` | String | ✅ Match |
| `unit_id` | integer/null | `unitId` | int? | ✅ Match |
| `nik_nip` | string | `nikNip` | String | ✅ Match |
| `name` | string | `name` | String | ✅ Match |
| `phone_number` | string | `phoneNumber` | String | ✅ Match |
| `created_at` | string/null (datetime) | `createdAt` | DateTime? | ✅ Match |
| `updated_at` | string/null (datetime) | `updatedAt` | DateTime? | ✅ Match |

**Enum Values:**

**Role** (sesuai API):
- ✅ `admin`
- ✅ `tracer_team`
- ✅ `major_team`
- ✅ `head_of_unit`

**Unit Type** (sesuai API):
- ✅ `institutional`
- ✅ `faculty`
- ✅ `major`

**Methods:**
- ✅ `fromJson()` - Parse dari API response
- ✅ `toJson()` - Convert untuk API
- ✅ `toRequestJson()` - Khusus untuk Create/Update request
- ✅ `copyWith()` - Update data lokal

**Field Tambahan (Display Only):**
- `unitName` - Nama unit untuk display
- `departmentName` - Nama department (untuk major_team)
- `facultyName` - Nama faculty (untuk display)

> **Note:** Field display tidak dikirim ke API, hanya untuk keperluan UI.

---

## 2. DEPARTMENT MANAGEMENT

### A. Faculty (Fakultas)

#### API Endpoint: `/{panel}/faculties`

#### Model: `FacultyModel` ✅

**Kesesuaian dengan `FacultyTransformer` dari API:**

| Field API | Type API | Model Field | Type Model | Status |
|-----------|----------|-------------|------------|--------|
| `id` | integer | `id` | int | ✅ Match |
| `name` | string | `name` | String | ✅ Match |
| `created_at` | string/null (datetime) | `createdAt` | DateTime? | ✅ Match |
| `updated_at` | string/null (datetime) | `updatedAt` | DateTime? | ✅ Match |

**Methods:**
- ✅ `fromJson()` - Parse dari API response
- ✅ `toJson()` - Convert untuk API
- ✅ `toRequestJson()` - Khusus untuk Create/Update request (hanya `name`)
- ✅ `copyWith()` - Update data lokal

**Create/Update Request:**
```json
{
  "name": "string" // required
}
```

---

### B. Department (Jurusan)

#### API Endpoint: `/{panel}/departments`

#### Model: `DepartmentModel` ✅

**Kesesuaian dengan `DepartmentTransformer` dari API:**

| Field API | Type API | Model Field | Type Model | Status |
|-----------|----------|-------------|------------|--------|
| `id` | integer | `id` | int | ✅ Match |
| `faculty_id` | integer | `facultyId` | int | ✅ Match |
| `name` | string | `name` | String | ✅ Match |
| `created_at` | string/null (datetime) | `createdAt` | DateTime? | ✅ Match |
| `updated_at` | string/null (datetime) | `updatedAt` | DateTime? | ✅ Match |

**Field Tambahan:**
- `facultyName` - Dari include `faculty.name` (optional)

**Methods:**
- ✅ `fromJson()` - Parse dari API response (support included relations)
- ✅ `toJson()` - Convert untuk API
- ✅ `toRequestJson()` - Khusus untuk Create/Update request
- ✅ `copyWith()` - Update data lokal

**Create/Update Request:**
```json
{
  "name": "string",       // required
  "faculty_id": integer   // required
}
```

**API Include Support:**
- `?include=faculty` - Akan populate `facultyName`

---

### C. Major (Program Studi)

#### API Endpoint: `/{panel}/majors`

#### Model: `MajorModel` ✅

**Kesesuaian dengan `MajorTransformer` dari API:**

| Field API | Type API | Model Field | Type Model | Status |
|-----------|----------|-------------|------------|--------|
| `id` | integer | `id` | int | ✅ Match |
| `department_id` | integer | `departmentId` | int | ✅ Match |
| `code` | string | `code` | String | ✅ Match |
| `name` | string | `name` | String | ✅ Match |
| `created_at` | string/null (datetime) | `createdAt` | DateTime? | ✅ Match |
| `updated_at` | string/null (datetime) | `updatedAt` | DateTime? | ✅ Match |

**Field Tambahan:**
- `departmentName` - Dari include `department.name` (optional)
- `facultyName` - Dari include nested `department.faculty.name` (optional)

**Methods:**
- ✅ `fromJson()` - Parse dari API response (support included relations & nested)
- ✅ `toJson()` - Convert untuk API
- ✅ `toRequestJson()` - Khusus untuk Create/Update request
- ✅ `copyWith()` - Update data lokal

**Create/Update Request:**
```json
{
  "department_id": integer,  // required
  "code": "string",          // required, max 50 chars
  "name": "string"           // required, max 255 chars
}
```

**API Include Support:**
- `?include=department` - Akan populate `departmentName`
- `?include=department.faculty` - Akan populate `departmentName` dan `facultyName`

---

## 3. PERBEDAAN DENGAN UnitModel LAMA

### ⚠️ `UnitModel` (Old) - TIDAK SESUAI API

File: `lib/models/unit_model.dart`

**Masalah:**
1. ❌ Field `type` menggunakan nilai `'fakultas'`, `'jurusan'`, `'program_studi'` - **TIDAK ADA DI API**
2. ❌ Structure tidak match dengan API (Faculty, Department, Major terpisah di API)
3. ❌ Field names tidak sesuai dengan snake_case API
4. ❌ Type ID menggunakan String, seharusnya int

**Rekomendasi:**
- 🔄 Ganti `UnitModel` dengan `FacultyModel`, `DepartmentModel`, `MajorModel`
- 🔄 Update `UnitProvider` menjadi provider terpisah atau gabungan
- 🔄 Update UI yang menggunakan `UnitModel` lama

---

## 4. LANGKAH SELANJUTNYA

### ✅ Sudah Dikerjakan:
1. ✅ Model `UserModel` sudah update sesuai API
2. ✅ Model `FacultyModel` dibuat baru
3. ✅ Model `DepartmentModel` dibuat baru
4. ✅ Model `MajorModel` dibuat baru

### 🔲 Perlu Dikerjakan:

#### A. Update Provider
- [ ] Buat `FacultyProvider` atau update `UnitProvider`
- [ ] Buat `DepartmentProvider`
- [ ] Buat `MajorProvider`
- [ ] Update `UserProvider` untuk menggunakan model baru

#### B. Buat Service Layer
- [ ] `AuthService` - Handle login/logout
- [ ] `UserService` - CRUD users
- [ ] `FacultyService` - CRUD faculties
- [ ] `DepartmentService` - CRUD departments
- [ ] `MajorService` - CRUD majors

#### C. Update UI Screens
- [ ] Update `UserManagementScreen` untuk field baru (nik_nip, phone_number required)
- [ ] Update `UserDetailScreen` sesuai field baru
- [ ] Update `NewEmployeeScreen` untuk validasi field required
- [ ] Update `UnitManagementScreen` untuk pisah Faculty/Department/Major
- [ ] Update `EditUnitDialog` sesuai model baru

#### D. Setup HTTP Client
- [ ] Install package `dio` atau `http`
- [ ] Setup base URL dan interceptor
- [ ] Setup authentication token handling
- [ ] Setup error handling

---

## 5. CONTOH PENGGUNAAN

### A. Fetch Users dari API

```dart
// Service
Future<List<UserModel>> fetchUsers() async {
  final response = await dio.get('/admin/users');
  final data = response.data['data'] as List;
  return data.map((json) => UserModel.fromJson(json)).toList();
}

// Provider
class UserProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  
  Future<void> loadUsers() async {
    _users = await userService.fetchUsers();
    notifyListeners();
  }
}
```

### B. Create User

```dart
Future<UserModel> createUser(UserModel user, String password) async {
  final response = await dio.post(
    '/admin/users',
    data: user.toRequestJson(password: password),
  );
  return UserModel.fromJson(response.data['data']);
}
```

### C. Fetch Faculty dengan Include

```dart
Future<List<FacultyModel>> fetchFaculties() async {
  final response = await dio.get(
    '/admin/faculties',
    queryParameters: {'include': 'departments'},
  );
  final data = response.data['data'] as List;
  return data.map((json) => FacultyModel.fromJson(json)).toList();
}
```

### D. Fetch Major dengan Nested Include

```dart
Future<List<MajorModel>> fetchMajors() async {
  final response = await dio.get(
    '/admin/majors',
    queryParameters: {
      'include': 'department,department.faculty',
      'fields': 'id,code,name,department.name,department.faculty.name'
    },
  );
  final data = response.data['data'] as List;
  return data.map((json) => MajorModel.fromJson(json)).toList();
}
```

---

## 6. VALIDASI API FIELDS

### Required Fields untuk Create User:
```dart
{
  "email": "user@example.com",       // required, email format
  "password": "password123",          // required
  "role": "admin",                    // required (enum)
  "unit_type": "institutional",       // required (enum)
  "unit_id": null,                    // optional untuk institutional
  "nik_nip": "1234567890123456",     // required, max 18 chars
  "name": "John Doe",                 // required, max 255 chars
  "phone_number": "081234567890"     // required
}
```

### Required Fields untuk Create Department:
```dart
{
  "name": "Jurusan Teknik Informatika",  // required, max 255 chars
  "faculty_id": 1                         // required, integer
}
```

### Required Fields untuk Create Major:
```dart
{
  "department_id": 1,              // required, integer
  "code": "TIF",                   // required, max 50 chars
  "name": "Teknik Informatika"    // required, max 255 chars
}
```

---

## KESIMPULAN

✅ **User Management**: Model sudah 100% sesuai dengan API
✅ **Faculty Management**: Model baru sudah dibuat dan sesuai API
✅ **Department Management**: Model baru sudah dibuat dan sesuai API
✅ **Major Management**: Model baru sudah dibuat dan sesuai API

⚠️ **Action Required**: 
1. Migrate dari `UnitModel` lama ke model baru (Faculty/Department/Major)
2. Buat service layer untuk HTTP calls
3. Update provider untuk fetch dari API
4. Update UI untuk menggunakan model baru

---

**Generated**: November 15, 2025
**Branch**: fetch-API
**Status**: Models Ready for API Integration ✅
