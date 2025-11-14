# API User Profile Issue - Workaround Documentation

## Problem
Backend API tidak menyediakan endpoint untuk mendapatkan current user profile setelah login.

### Current API Behavior:
- **Login Response**: `{ success: true, message: "...", token: "..." }` - **NO USER DATA**
- **No `/auth/user` or `/auth/me` endpoint** available
- User data hanya bisa diambil via `/admin/users/{id}` tapi kita tidak tahu user ID

### Expected Behavior (Ideal):
Login response should include user data:
```json
{
  "success": true,
  "message": "Login success.",
  "token": "1|...",
  "user": {
    "id": 1,
    "name": "Tracer Study ITK",
    "email": "tracerstudy@itk.ac.id",
    "role": "admin",
    ...
  }
}
```

## Temporary Workaround

Karena backend belum menyediakan user profile endpoint, aplikasi mobile menggunakan fallback:

### Implementation:
1. **Try to fetch from `/auth/user`** (will fail with 404)
2. **Fallback**: Create minimal user data from login email

### Minimal User Data:
```dart
UserModel(
  id: 0, // Temporary ID
  name: "TRACERSTUDY", // Extracted from email
  email: "tracerstudy@itk.ac.id",
  role: "admin", // Inferred from email pattern
  unitType: "institutional",
  nikNip: "",
  phoneNumber: "",
)
```

### Role Inference Logic:
- Email contains `tracerstudy` → `admin`
- Email contains `tracer` → `tracer_team`
- Email contains `prodi` or `major` → `major_team`
- Default → `admin`

## Code Changes

### `lib/providers/auth_provider.dart`:
```dart
// Store login email
String? _loginEmail;

// After login, if fetchCurrentUser() fails:
_createMinimalUserFromEmail(email);

void _createMinimalUserFromEmail(String email) {
  // Infer role from email pattern
  String role = 'admin';
  if (email.contains('tracerstudy')) {
    role = 'admin';
  } else if (email.contains('tracer')) {
    role = 'tracer_team';
  } else if (email.contains('prodi') || email.contains('major')) {
    role = 'major_team';
  }
  
  // Create minimal user
  _currentUser = UserModel(...);
}
```

## Testing

### Test Account:
- Email: `tracerstudy@itk.ac.id`
- Password: `password`

### Expected Result:
- ✅ Login berhasil
- ✅ Token saved
- ✅ User profile: Name = "TRACERSTUDY", Role = "admin"
- ✅ Menu tampil sesuai role (Admin → User Directory)
- ✅ Drawer menampilkan nama dan role

### Console Logs:
```
🔐 Attempting login for: tracerstudy@itk.ac.id
✅ Login response: 201
⚠️ No user data in login response, will fetch separately
🔄 Fetching user profile after login...
🔍 Fetching current user profile...
❌ Failed to fetch user profile: [error message]
📝 Creating minimal user from email: tracerstudy@itk.ac.id
✅ Created minimal user: TRACERSTUDY (admin)
```

## Limitations

### Current Workaround Limitations:
1. **No real user ID** - Uses ID = 0
2. **Incomplete user data** - Missing NIK/NIP, phone number, etc.
3. **Role inference may be inaccurate** - Based on email pattern only
4. **Cannot edit user profile** - No real user ID to update
5. **No unit information** - unitId is null

### Features Not Available:
- ❌ User profile editing
- ❌ Display real NIK/NIP
- ❌ Display phone number
- ❌ Display unit/faculty/department info
- ❌ Accurate role based on database

## Recommended Backend Fix

### Option 1: Update Login Response (RECOMMENDED)
Modify `/auth/login` to include user data:

```php
// Laravel Controller
public function login(LoginRequest $request)
{
    // ... authentication logic ...
    
    $token = $user->createToken('auth_token')->plainTextToken;
    
    return response()->json([
        'success' => true,
        'message' => 'Login success.',
        'token' => $token,
        'user' => new UserTransformer($user), // ADD THIS
    ], 201);
}
```

### Option 2: Add `/auth/user` Endpoint
Create new endpoint to get current authenticated user:

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/user', [AuthController::class, 'user']);
});

// AuthController.php
public function user(Request $request)
{
    return response()->json([
        'success' => true,
        'data' => new UserTransformer($request->user()),
    ]);
}
```

### Option 3: Add `/auth/me` Endpoint
Similar to Option 2, but more RESTful naming:

```php
Route::middleware('auth:sanctum')->get('/auth/me', function (Request $request) {
    return response()->json([
        'data' => new UserTransformer($request->user()),
    ]);
});
```

## Update OpenAPI Spec

After implementing backend fix, update `api.json`:

```json
{
  "/auth/login": {
    "post": {
      "responses": {
        "201": {
          "content": {
            "application/json": {
              "schema": {
                "properties": {
                  "success": { "type": "boolean" },
                  "message": { "type": "string" },
                  "token": { "type": "string" },
                  "user": { "$ref": "#/components/schemas/UserTransformer" }
                }
              }
            }
          }
        }
      }
    }
  },
  "/auth/user": {
    "get": {
      "security": [{ "http": [] }],
      "responses": {
        "200": {
          "content": {
            "application/json": {
              "schema": {
                "properties": {
                  "data": { "$ref": "#/components/schemas/UserTransformer" }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

## Migration Plan

When backend is fixed:

1. **Remove workaround code**:
   - Remove `_createMinimalUserFromEmail()` method
   - Remove email-based role inference
   - Remove fallback logic

2. **Update `AuthProvider`**:
   ```dart
   // After login, parse user from response
   if (response.data!.containsKey('user')) {
     _currentUser = UserModel.fromJson(response.data!['user']);
   }
   
   // OR fetch from new endpoint
   final response = await _authService.getCurrentUser();
   _currentUser = UserModel.fromJson(response.data!);
   ```

3. **Test thoroughly**:
   - Login with all role types
   - Verify all user data populated correctly
   - Verify menus display correctly
   - Verify profile shows all information

## Conclusion

**Current Status**:
- ✅ Workaround implemented
- ✅ Login works with minimal user data
- ✅ Role-based menus work
- ✅ Drawer displays user info
- ⚠️ Limited user data (ID=0, no NIK/NIP, etc.)

**Action Required**:
- 🔴 **Backend**: Implement Option 1 (Update login response) - PRIORITY
- 🟡 **Frontend**: Remove workaround after backend fixed
- 🟡 **Testing**: Test with real user data

**Impact**:
- 🟢 Low - App is functional with workaround
- 🟡 Medium - Some features limited (profile editing, etc.)
- 🔴 High - Production should use real user data from backend
