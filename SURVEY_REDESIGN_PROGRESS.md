# Survey Management Redesign - Progress Report

## ✅ COMPLETED

### 1. Models Layer (100% Done)
- ✅ **SectionModel** - Complete dengan QuestionModel & QuestionOption
- ✅ **SurveyModel** - Updated ke structure baru sesuai API
  - Fields: id, kindId, graduationNumber, title, description, startedAt, endedAt, sections[]
  - Support relationship dengan SurveyKindModel
  - Helper methods: kindName, formattedStartDate, formattedEndDate

### 2. Service Layer (Ready to Use)
- ✅ **SurveyService** already supports:
  - `getSurveys()` dengan include='kind' relationship
  - `createSurvey()` untuk POST dengan sections
  - `updateSurvey()` untuk PUT
  - `deleteSurvey()` untuk DELETE

## 🚧 IN PROGRESS / TODO

### 3. Provider Layer (Perlu Update)
File: `lib/providers/survey_provider.dart`

**Current State:**
- Masih menggunakan old structure (periode-based)
- Method: initialize(), addPeriode(), deletePeriode()

**Need to Update:**
```dart
class SurveyProvider extends ChangeNotifier {
  List<SurveyModel> _surveys = [];
  
  // Remove old periode-based structure
  // Add new methods:
  Future<void> initialize()  // Fetch dari API
  Future<bool> createSurvey(data)
  Future<bool> updateSurvey(id, data)
  Future<bool> deleteSurvey(id)
}
```

### 4. UI Layer - Survey Management Screen (Perlu Rombak Total)
File: `lib/screens/survey_management/survey_management_screen.dart`

**Current State:**
- Grid-based layout dengan periode cards
- Tidak sesuai dengan requirement baru

**New Requirements:**
```dart
// TABLE dengan kolom:
- Checkbox (untuk bulk actions - optional)
- Kind (nama survey kind)
- Graduation Number (tahun angkatan)
- Title (judul survey)
- Started at (format: DD/MM/YYYY HH:mm)
- Ended at (format: DD/MM/YYYY HH:mm)
- Actions (Edit icon - atau row click langsung ke edit)

// FEATURES:
- Search bar (filter by title/kind)
- "New Survey" button → navigate ke form
- Row click → navigate ke edit form
- Horizontal scroll untuk tabel
- Responsive
```

**Reference:**
Lihat `user_management_screen.dart` untuk style tabel yang sama.

### 5. UI Layer - Survey Form Screen (Perlu Buat Baru)
File: `lib/screens/survey_management/survey_form_screen.dart` (NEW)

**Structure:**
```dart
// HEADER SECTION
- Title field
- Description field (multiline)
- Kind dropdown (dari SurveyKindProvider)
- Graduation Number (number input)
- Started At (DateTime picker dengan kalender)
- Ended At (DateTime picker dengan kalender)

// SECTIONS BUILDER
- List of SectionCard widgets
- "Add Section" button
- Each section dapat reorder (drag handle)
- Each section dapat delete

// SECTION CARD
- Section title
- Section description
- List of QuestionCard widgets
- "Add Question" button
- Questions dapat reorder
- Questions dapat delete/duplicate

// QUESTION CARD
- Question ID field
- Type dropdown (short_answer, paragraph, multiple_choice, checkboxes, linear_scale)
- Question text (multiline)
- Required checkbox
- Has condition checkbox

// TYPE-SPECIFIC FIELDS:
Multiple Choice / Checkboxes:
  - Options list
  - Each option: label, value, condition (optional)
  - Add/remove option buttons

Linear Scale:
  - From value & label
  - To value & label

// ACTIONS
- Save button
- Cancel button
```

**Complexity Note:**
Ini adalah form builder yang sangat kompleks (seperti Google Forms). 
Akan memerlukan banyak widget components dan state management.

## 📋 IMPLEMENTATION PLAN

### Phase 1: Provider Update (30 menit)
1. Update SurveyProvider untuk remove old structure
2. Add methods: initialize, create, update, delete
3. Remove periode-based logic

### Phase 2: Table View (1-2 jam)
1. Rombak survey_management_screen.dart
2. Implementasi table seperti user_management
3. Add search functionality
4. Add navigation ke form

### Phase 3: Form Builder - Basic (2-3 jam)
1. Create survey_form_screen.dart
2. Header fields (title, description, kind, graduation, dates)
3. DateTime picker dengan kalender
4. Save/cancel logic

### Phase 4: Form Builder - Sections (3-4 jam)
1. Create section_card.dart widget
2. Add section list
3. Reordering functionality
4. Delete functionality

### Phase 5: Form Builder - Questions (4-5 jam)
1. Create question_card.dart widget
2. Question type dropdown
3. Type-specific fields
4. Options builder for multiple_choice/checkboxes
5. Linear scale inputs
6. Reordering & duplication

### Phase 6: Integration & Testing (2-3 jam)
1. Test API integration
2. Validation
3. Error handling
4. Edge cases

**TOTAL ESTIMATED TIME: 12-18 jam development**

## 🎯 QUICK START - Minimal MVP

Untuk demo/testing cepat, bisa mulai dengan:

### MVP Version 1 (3-4 jam):
1. ✅ Models done
2. ✅ Service done
3. Update Provider (simple version)
4. Table view dengan basic columns
5. Form dengan header fields only (no sections yet)
6. Basic create/edit functionality

### MVP Version 2 (tambah 3-4 jam):
7. Add sections support
8. Simple question builder
9. Support 2-3 question types (short_answer, paragraph, multiple_choice)

### MVP Version 3 (Full Feature - tambah 6-8 jam):
10. All question types
11. Reordering
12. Advanced features (conditions, etc)

## 🚀 NEXT STEPS

**RECOMMENDATION:**
Karena ini sangat kompleks, lebih baik lakukan iteratif:

1. **Sekarang:** Implementasi MVP Version 1
   - Update provider
   - Buat table view
   - Form basic (tanpa sections)

2. **Selanjutnya:** Add sections & questions secara bertahap
   - Test setiap fitur
   - Ensure API integration works

**Apakah ingin saya lanjutkan dengan MVP Version 1 sekarang?**
- Table view baru
- Provider update
- Form basic (header fields only)

Atau fokus ke bagian tertentu dulu?
