# Tracer Study ITK Mobile App - Development Status

> **Last Updated:** 27 November 2025  
> **Branch:** `fetch-API`  
> **Flutter Version:** 3.35.2 / Dart 3.9.0

---

## 📱 Overview

Aplikasi mobile untuk Tracer Study Institut Teknologi Kalimantan dengan multi-role access:
- **Admin** - Manajemen pengguna dan unit
- **Tracer Team** - Manajemen survey dan survey kinds  
- **Major Team** - Manajemen pertanyaan tambahan prodi
- **Head of Unit** - Melihat laporan survey (filtered by unit)
- **Alumni** - Mengisi survey (public access)

---

## 🔐 Authentication & Authorization

### Status: ✅ TERINTEGRASI (Partial)

| Endpoint | Method | Status | Keterangan |
|----------|--------|--------|------------|
| `/auth/login` | POST | ✅ Ready | Sudah terintegrasi dengan API |
| `/auth/logout` | POST | ✅ Ready | Sudah terintegrasi dengan API |
| `/auth/user` | GET | ✅ Ready | Fetch user profile after login |

### Dev Bypass Accounts (Debug Mode Only)
Untuk testing ketika backend tidak tersedia:

| Email | Password | Role | Unit Type | Unit ID |
|-------|----------|------|-----------|---------|
| `tracerteam@itk.ac.id` | password | tracer_team | institutional | - |
| `majorteam@itk.ac.id` | password | major_team | major | - |
| `headunit@itk.ac.id` | password | head_of_unit | institutional | - |
| `headofsetdesigner@itk.ac.id` | password | head_of_unit | major | 5 (Set Designer) |

### RBAC Implementation
```
Role Mapping:
- admin          → /user-management, /unit-management
- tracer_team    → /survey-management, /survey-kinds  
- major_team     → /major-dashboard, /major-survey-management
- head_of_unit   → /survey-report (filtered by unit_type & unit_id)
```

---

## 📊 Feature Status by Role

### 1. Admin Features

| Feature | Screen | API Status | Data Source |
|---------|--------|------------|-------------|
| User Management | `user_management_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| User Detail | `user_detail_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| New Employee | `new_employee_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| Unit Management | `unit_management_screen.dart` | 🔶 Ready to integrate | Dummy Data |

**API Services Ready:**
- `UserService` - CRUD operations implemented
- `FacultyService` - CRUD operations implemented
- `MajorService` - CRUD operations implemented

### 2. Tracer Team Features

| Feature | Screen | API Status | Data Source |
|---------|--------|------------|-------------|
| Survey Management | `survey_management_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| Survey Detail | `survey_detail_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| Survey Form | `survey_form_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| Survey Kinds | `survey_kinds_screen.dart` | 🔶 Ready to integrate | Dummy Data |
| Survey Kind Form | `survey_kind_form_screen.dart` | 🔶 Ready to integrate | Dummy Data |

**API Services Ready:**
- `SurveyService` - CRUD for surveys & survey-kinds implemented

### 3. Major Team Features

| Feature | Screen | API Status | Data Source |
|---------|--------|------------|-------------|
| Dashboard | `major_dashboard_screen.dart` | ❌ Not integrated | Dummy Data |
| Survey Management | `major_survey_management_screen.dart` | ❌ Not integrated | Dummy Data |
| Survey Detail (Questions Tab) | `major_survey_detail_screen.dart` | ❌ Not integrated | Dummy Data |
| Survey Detail (Responses Tab) | `major_survey_detail_screen.dart` | ❌ Not integrated | Dummy Data |
| Response Detail | `major_response_detail_screen.dart` | ❌ Not integrated | Dummy Data |

**Major Team Specific Features:**
- ✅ View tracer team questions (read-only, collapsible)
- ✅ Add/edit additional questions for prodi (without sections)
- ✅ View survey responses from prodi alumni
- ✅ Navigate between respondents with dropdown
- ✅ Section navigation in response detail
- ✅ Delete & Export buttons (placeholder)

### 4. Head of Unit Features

| Feature | Screen | API Status | Data Source |
|---------|--------|------------|-------------|
| Survey Report List | `survey_report_screen.dart` | ❌ Not integrated | Dummy Data |
| Survey Statistics | `survey_statistics_screen.dart` | ❌ Not integrated | Dummy Data |
| Alumni Response Detail | `alumni_response_detail_screen.dart` | ❌ Not integrated | Dummy Data |
| Export Responses | `export_response_screen.dart` | ❌ Not implemented | - |

**Head of Unit Filtering Logic (✅ IMPLEMENTED):**
```dart
// Unit Type: institutional → No filter, sees all data
//   - Shows: Faculty column, Major column
//   - Filters: Faculty dropdown, Major dropdown

// Unit Type: faculty → Filter by facultyId
//   - Hides: Faculty column (semua data dari fakultas yang sama)
//   - Shows: Major column
//   - Filters: Major dropdown only

// Unit Type: major → Filter by majorId  
//   - Hides: Faculty column, Major column (semua data dari prodi yang sama)
//   - Filters: None (no filter button shown)
```

### 5. Alumni/Public Features

| Feature | Screen | API Status | Data Source |
|---------|--------|------------|-------------|
| Available Surveys | `available_surveys_screen.dart` | ❌ Not integrated | Dummy Data |
| Survey Form (Fill) | - | ❌ Not implemented | - |

---

## 🔌 API Integration Status

### Services Layer (`lib/services/`)

| Service | File | Status | Endpoints Implemented |
|---------|------|--------|----------------------|
| API Client | `api_client.dart` | ✅ Ready | Base client with auth interceptor |
| Auth | `auth_service.dart` | ✅ Integrated | login, logout, getCurrentUser |
| User | `user_service.dart` | ✅ Ready | CRUD operations |
| Faculty | `faculty_service.dart` | ✅ Ready | CRUD operations |
| Major | `major_service.dart` | ✅ Ready | CRUD operations |
| Survey | `survey_service.dart` | ✅ Ready | CRUD for surveys & survey-kinds |

### Provider Layer (`lib/providers/`)

| Provider | Status | Data Source | Notes |
|----------|--------|-------------|-------|
| `auth_provider.dart` | ✅ Integrated | API | Login/logout working |
| `user_provider.dart` | 🔶 Dummy | Local | Ready for API switch |
| `faculty_provider.dart` | 🔶 Hybrid | API + Fallback | Falls back to dummy on error |
| `major_provider.dart` | 🔶 Hybrid | API + Fallback | Falls back to dummy on error |
| `unit_provider.dart` | 🔶 Dummy | Local | Ready for API switch |
| `survey_provider.dart` | 🔶 Dummy | Local | Ready for API switch |
| `survey_detail_provider.dart` | 🔶 Dummy | Local | Ready for API switch |
| `survey_kind_provider.dart` | 🔶 Dummy | Local | Ready for API switch |
| `survey_report_provider.dart` | 🔶 Dummy | Local | With user context filtering |
| `survey_response_provider.dart` | 🔶 Dummy | Local | Ready for API switch |

---

## 🚨 API Endpoints Needed from Backend

### High Priority (Core Features)

#### Survey Report & Responses
```
GET  /{panel}/surveys                           - List surveys (with statistics)
GET  /{panel}/surveys/{id}                      - Survey detail with sections/questions
GET  /{panel}/surveys/{id}/statistics           - Survey statistics (progress, completed, etc)
GET  /{panel}/surveys/{id}/responses            - List of respondents who filled survey
GET  /{panel}/surveys/{id}/responses/{userId}   - Detail answers from specific respondent
DELETE /{panel}/surveys/{id}/responses/{userId} - Delete respondent's response
```

#### Major Team Section Management  
```
GET  /{panel}/surveys/{id}/major-sections       - Get major team's additional sections
POST /{panel}/surveys/{id}/major-sections       - Create section with questions
PUT  /{panel}/major-sections/{id}               - Update section
DELETE /{panel}/major-sections/{id}             - Delete section
```

### Medium Priority

#### User Profile Endpoint
```
GET  /auth/user                                 - Get current authenticated user profile
     Response should include: unit_type, unit_id for head_of_unit role
```

#### Data Filtering Endpoints
```
GET  /{panel}/majors?faculty_id={id}            - Get majors by faculty
GET  /{panel}/surveys/{id}/responses?major_id={id} - Filter responses by major
GET  /{panel}/surveys/{id}/responses?faculty_id={id} - Filter responses by faculty
```

### Currently Available (From api.json)

| Resource | Endpoints | Status |
|----------|-----------|--------|
| Departments | CRUD | ✅ Documented |
| Faculties | CRUD | ✅ Documented |
| Majors | CRUD | ✅ Documented |
| Users | CRUD | ✅ Documented |
| Surveys | CRUD | ✅ Documented |
| SurveyKinds | CRUD | ✅ Documented |
| MajorSections | CRUD | ✅ Documented |
| Auth | login, logout | ✅ Documented |

---

## 📁 Project Structure

```
lib/
├── constants/
│   ├── app_constants.dart      # Padding, spacing, etc
│   ├── colors.dart             # AppColors
│   └── roles.dart              # Role constants
├── models/
│   ├── user_model.dart
│   ├── faculty_model.dart
│   ├── major_model.dart
│   ├── department_model.dart
│   ├── unit_model.dart
│   ├── survey_model.dart
│   ├── survey_kind_model.dart
│   ├── section_model.dart
│   ├── question_model.dart
│   ├── question_option_model.dart
│   ├── survey_report_model.dart
│   └── survey_response_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── faculty_provider.dart
│   ├── major_provider.dart
│   ├── unit_provider.dart
│   ├── survey_provider.dart
│   ├── survey_detail_provider.dart
│   ├── survey_kind_provider.dart
│   ├── survey_report_provider.dart
│   └── survey_response_provider.dart
├── routes/
│   └── app_router.dart         # GoRouter configuration
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home_screen.dart
│   ├── major_team/
│   │   ├── major_dashboard_screen.dart
│   │   ├── major_survey_management_screen.dart
│   │   ├── major_survey_detail_screen.dart
│   │   └── major_response_detail_screen.dart
│   ├── public/
│   │   └── available_surveys_screen.dart
│   ├── survey_kinds/
│   │   ├── survey_kinds_screen.dart
│   │   └── survey_kind_form_screen.dart
│   ├── survey_management/
│   │   ├── survey_management_screen.dart
│   │   ├── survey_detail_screen.dart
│   │   └── survey_form_screen.dart
│   ├── survey_report/
│   │   ├── survey_report_screen.dart
│   │   ├── survey_statistics_screen.dart
│   │   ├── alumni_response_detail_screen.dart
│   │   └── export_response_screen.dart
│   ├── unit_management/
│   │   └── unit_management_screen.dart
│   └── user_management/
│       ├── user_management_screen.dart
│       ├── user_detail_screen.dart
│       └── new_employee_screen.dart
├── services/
│   ├── api_client.dart         # Dio client with interceptors
│   ├── api_response.dart       # Standard response wrapper
│   ├── auth_service.dart       # Auth endpoints
│   ├── faculty_service.dart    # Faculty CRUD
│   ├── major_service.dart      # Major CRUD
│   ├── survey_service.dart     # Survey & SurveyKind CRUD
│   └── user_service.dart       # User CRUD
├── theme/
│   └── app_theme.dart
├── widgets/
│   ├── app_drawer.dart         # Sidebar with role-based menu
│   ├── custom_app_bar.dart
│   ├── add_unit_dialog.dart
│   └── edit_unit_dialog.dart
└── main.dart
```

---

## 🧪 Testing Notes

### How to Test Head of Unit Filtering

1. Login with `headofsetdesigner@itk.ac.id` / `password`
2. Navigate to Survey Report → Select any survey → View Statistics
3. **Expected Behavior:**
   - Only alumni from "Set Designer" major should appear (1 alumni: Miss Jayda Howell MD)
   - No Faculty and Program Studi columns in table
   - No filter button (since filtering is automatic)
   - Statistics should reflect filtered data only

### Dummy Data Mapping

| Entity | ID Range | Notes |
|--------|----------|-------|
| Faculties | 1-4 | Fakultas Consequuntur, Iure, Qui, Cupiditate |
| Majors | 1-8 | Surveyor, Environmental, Oil Service, Production Worker, Set Designer, Electrical, Criminal, Hand Presser |
| Users/Alumni | 1-8 | Dr. Porter, Stefanie, Prof. Henri, Janis, Miss Jayda (Set Designer), Jerome, Myrtice, Tina |
| Surveys | 1-10 | nostrum sequi adipisci, neque in et, enim, etc |

---

## 🔧 Configuration

### API Base URL
```dart
// lib/services/api_client.dart
static const String baseUrl = 'http://localhost:8000/api';
```

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

---

## 📝 Notes for Backend Team

### 1. User Profile Response
When implementing `/auth/user`, please ensure response includes:
```json
{
  "id": 1,
  "name": "Kepala Prodi",
  "email": "kaprodi@itk.ac.id",
  "role": "head_of_unit",
  "unit_type": "major",      // REQUIRED: institutional | faculty | major
  "unit_id": 5,              // REQUIRED: ID of the unit (faculty or major)
  "nik_nip": "123456789",
  "phone_number": "081234567890"
}
```

### 2. Survey Responses Filtering
For `/{panel}/surveys/{id}/responses` endpoint, support query params:
- `?faculty_id={id}` - Filter by faculty
- `?major_id={id}` - Filter by major
- `?search={query}` - Search by name/email/nim

### 3. Survey Statistics Response
Expected format for `/{panel}/surveys/{id}/statistics`:
```json
{
  "survey_id": 1,
  "total_target": 31,
  "completed": 8,
  "not_completed": 23
}
```

### 4. Alumni Response Model
Expected format for survey response list:
```json
{
  "id": 1,
  "name": "Alumni Name",
  "email": "alumni@email.com",
  "nim": "12345678",
  "faculty_id": 1,
  "faculty_name": "Fakultas A",
  "major_id": 5,
  "major_name": "Program Studi B",
  "completed_at": "2025-11-17T17:49:22Z"  // null if not completed
}
```

### 5. Survey Response Detail (Individual Answers)
Expected format for `/{panel}/surveys/{id}/responses/{userId}`:
```json
{
  "id": 1,
  "survey_id": 1,
  "respondent_id": 5,
  "respondent_name": "Miss Jayda Howell MD",
  "respondent_email": "jayda@example.com",
  "respondent_nim": "85610187",
  "submitted_at": "2025-11-17T17:49:22Z",
  "sections": [
    {
      "id": 1,
      "title": "Section 1",
      "description": "Section description",
      "questions": [
        {
          "id": 1,
          "text": "Question text?",
          "type": "multiple_choice",  // short_answer, paragraph, multiple_choice, checkboxes, linear_scale
          "answer": "Selected option",
          "options": ["Option A", "Option B", "Option C"]
        }
      ]
    }
  ]
}
```

---

## 🚀 Next Development Steps

1. **API Integration Priority:**
   - [ ] Survey Report endpoints (statistics, responses)
   - [ ] Major Team section management
   - [ ] Alumni survey submission

2. **Features to Complete:**
   - [ ] Export responses to PDF/Excel
   - [ ] Real-time survey progress
   - [ ] Push notifications
   - [ ] Offline mode support

3. **UI/UX Improvements:**
   - [ ] Loading skeletons
   - [ ] Error handling UI
   - [ ] Empty state illustrations
   - [ ] Pull-to-refresh

---

## 📞 Contact

For questions about mobile app development:
- Repository: `ITK-Capstone-09-Tracer-Study/tracer_mobile`
- Branch: `fetch-API`

---

*Dokumentasi ini di-update secara berkala sesuai progress development.*
