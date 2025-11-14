# API Integration Guide

## ✅ Status: READY FOR INTEGRATION

Sistem mobile sudah siap untuk integrasi dengan API Laravel backend.

---

## 📦 Installed Packages

```yaml
dependencies:
  dio: ^5.7.0                    # HTTP client
  shared_preferences: ^2.3.3     # Local storage untuk token
  flutter_spinkit: ^5.2.1        # Loading indicators
```

---

## 🏗️ Architecture

```
lib/
├── services/
│   ├── api_client.dart         # Singleton Dio client dengan interceptors
│   ├── api_response.dart       # Response wrapper & paginated response
│   ├── auth_service.dart       # Login/logout API calls
│   ├── user_service.dart       # User CRUD API calls
│   └── faculty_service.dart    # Faculty CRUD API calls
├── providers/
│   ├── auth_provider.dart      # Authentication state management
│   ├── user_provider.dart      # User state (dummy data untuk development)
│   └── ...
└── models/
    ├── user_model.dart         # ✅ Ready (int id, required fields)
    ├── faculty_model.dart      # ✅ Ready
    ├── department_model.dart   # ✅ Ready
    └── major_model.dart        # ✅ Ready
```

---

## 🚀 Quick Start

### 1. Configure Base URL

Edit `lib/services/api_client.dart`:

```dart
// Change this to your actual API URL
static const String baseUrl = 'http://127.0.0.1:8000/api';

// For production:
// static const String baseUrl = 'https://api.tracer.itk.ac.id/api';
```

### 2. Test Authentication

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// In your login screen
final authProvider = context.read<AuthProvider>();
final success = await authProvider.login(
  email: emailController.text,
  password: passwordController.text,
);

if (success) {
  // Navigate to home
  context.go('/home');
} else {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
  );
}
```

### 3. Fetch Users from API

```dart
import '../services/user_service.dart';
import '../services/api_response.dart';

final userService = UserService();

// Get paginated users
final response = await userService.getUsers(
  page: 1,
  perPage: 10,
  filters: {'role': 'admin'},
  sort: 'name',
);

if (response.success && response.data != null) {
  final users = response.data!.data; // List<UserModel>
  final total = response.data!.total;
  final hasMore = response.data!.hasMorePages;
  
  // Update UI
  setState(() {
    _users = users;
  });
} else {
  // Handle error
  print('Error: ${response.message}');
}
```

---

## 🔐 Authentication Flow

### Login Process

```dart
// 1. User enters credentials
final email = 'admin@itk.ac.id';
final password = 'password123';

// 2. Call AuthService
final authService = AuthService();
final response = await authService.login(
  email: email,
  password: password,
);

// 3. Check response
if (response.success) {
  // Token automatically saved to SharedPreferences
  final token = response.data!['token'];
  final user = UserModel.fromJson(response.data!['user']);
  
  // Token automatically added to all subsequent requests
  print('Logged in as: ${user.name}');
} else {
  print('Login failed: ${response.message}');
}
```

### Logout Process

```dart
final authService = AuthService();
await authService.logout();

// Token automatically removed from SharedPreferences
// Navigate to login screen
context.go('/login');
```

### Check Authentication Status

```dart
final authService = AuthService();
final isAuth = await authService.isAuthenticated();

if (isAuth) {
  // User is logged in
  final token = await authService.getAuthToken();
  print('Token: $token');
} else {
  // User is not logged in
  context.go('/login');
}
```

---

## 📝 API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login with email & password |
| POST | `/auth/logout` | Logout current user |

### User Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/users` | Get paginated users list |
| GET | `/admin/users/{id}` | Get single user |
| POST | `/admin/users` | Create new user |
| PUT | `/admin/users/{id}` | Update user |
| DELETE | `/admin/users/{id}` | Delete user |

### Faculty Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/faculties` | Get paginated faculties |
| GET | `/admin/faculties/{id}` | Get single faculty |
| POST | `/admin/faculties` | Create new faculty |
| PUT | `/admin/faculties/{id}` | Update faculty |
| DELETE | `/admin/faculties/{id}` | Delete faculty |

---

## 🔧 API Client Features

### Automatic Token Management

```dart
// Token automatically added to all requests
// No need to manually add Authorization header

// Example:
final response = await ApiClient().dio.get('/admin/users');
// Request includes: Authorization: Bearer <token>
```

### Request/Response Logging

```dart
// Console output:
// 🌐 REQUEST: GET /admin/users
// ✅ RESPONSE: 200 /admin/users

// Or on error:
// ❌ ERROR: 401 /admin/users
//    Message: Unauthenticated
```

### Error Handling

```dart
try {
  final response = await userService.getUsers();
  
  if (response.success) {
    // Handle success
  } else {
    // Handle API error
    print('Error: ${response.message}');
    if (response.statusCode == 401) {
      // Redirect to login
    } else if (response.statusCode == 422) {
      // Show validation errors
      print('Validation errors: ${response.errors}');
    }
  }
} catch (e) {
  // Handle unexpected error
  print('Unexpected error: $e');
}
```

---

## 📊 Paginated Response

### Structure

```dart
class PaginatedResponse<T> {
  final List<T> data;           // List of items
  final int currentPage;        // Current page number
  final int lastPage;           // Total pages
  final int perPage;            // Items per page
  final int total;              // Total items
  final int from;               // Starting item number
  final int to;                 // Ending item number
  
  bool get hasMorePages;        // Has next page?
  bool get isFirstPage;         // Is first page?
  bool get isLastPage;          // Is last page?
}
```

### Usage with ListView

```dart
class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final userService = UserService();
  List<UserModel> users = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    if (isLoading || !hasMore) return;
    
    setState(() => isLoading = true);
    
    final response = await userService.getUsers(
      page: currentPage,
      perPage: 20,
    );
    
    if (response.success && response.data != null) {
      setState(() {
        users.addAll(response.data!.data);
        hasMore = response.data!.hasMorePages;
        currentPage++;
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == users.length) {
          _loadUsers();
          return Center(child: CircularProgressIndicator());
        }
        return ListTile(
          title: Text(users[index].name),
          subtitle: Text(users[index].email),
        );
      },
    );
  }
}
```

---

## 🎯 Next Steps

### Immediate Tasks:

1. **Update LoginScreen**
   - Replace dummy login with AuthProvider
   - Handle loading state
   - Show error messages

2. **Update UserProvider**
   - Replace dummy data with UserService API calls
   - Implement CRUD operations
   - Handle loading & error states

3. **Create Department Providers**
   - FacultyProvider with FacultyService
   - DepartmentProvider with DepartmentService
   - MajorProvider with MajorService

4. **Update UI Screens**
   - Show loading indicators
   - Handle API errors gracefully
   - Implement pull-to-refresh
   - Implement infinite scroll for lists

5. **Testing**
   - Test with actual backend API
   - Handle edge cases (network errors, timeouts)
   - Test authentication flow
   - Test CRUD operations

---

## 🐛 Debugging Tips

### Check API Connection

```dart
// Test API connectivity
final dio = ApiClient().dio;
try {
  final response = await dio.get('/auth/login');
  print('API is reachable');
} catch (e) {
  print('API connection error: $e');
}
```

### Check Token

```dart
final token = await ApiClient().getAuthToken();
print('Current token: $token');
```

### Enable Verbose Logging

Edit `api_client.dart`:

```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));
```

---

## ⚠️ Important Notes

1. **Base URL**: Change `http://127.0.0.1:8000/api` to your actual API URL
2. **CORS**: Ensure backend allows requests from mobile app
3. **SSL**: For production, use HTTPS
4. **Token Expiry**: Implement token refresh mechanism
5. **Offline Mode**: Consider caching data locally
6. **Error Handling**: Always handle network errors gracefully

---

## 📚 Example: Complete Login Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                if (authProvider.isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.errorMessage ?? 
                                           'Login failed'),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Login'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

**Last Updated**: November 15, 2025  
**Status**: ✅ Ready for Integration  
**Branch**: fetch-API
