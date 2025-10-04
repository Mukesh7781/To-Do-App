# task_manager_app

A minimal, fast task manager built with Flutter featuring filtering (All/Completed/Pending), due dates, and a clean Material 3 UI.

## Getting Started

This project is a starting point for a Flutter application.

## Clone and Run

# 1) Clone
git clone https://github.com/<your-username>/task_manager_app.git
cd task_manager_app
# 2) Fetch packages
flutter pub get
# 3) Run on a device/emulator
flutter run
# (Optional) Specify a platform
flutter run -d chrome
flutter run -d android
flutter run -d ios

## Project Structure
lib/
  main.dart
  models/
    task.dart
  providers/
    task_provider.dart
  screens/
    task_list_screen.dart
    add_edit_task_screen.dart
    task_detail_screen.dart
  services/
    task_service.dart
  widgets/
    dialogs.dart

## Architecture and state management
This app uses Provider for simple, testable state management.

Data model: Task holds id, title, description, dueDate, isCompleted, priority.
Source of truth: TaskProvider extends ChangeNotifier and manages:
tasks: List<Task>
currentFilter: TaskFilter { all, completed, pending }
derived getters: filteredTasks based on currentFilter
actions: addTask, updateTask, deleteTask, toggleCompletion, setFilter
UI: Stateless/Stateful screens subscribe to TaskProvider using Consumer/Provider.of with fine-grained rebuilds. This keeps business logic out of widgets and makes it easy to mock the provider in tests.

# Why Provider?
Minimal boilerplate, great for small-to-medium apps.
Explicit dependencies via context, simple lifecycles.
Easy unit testing by mocking the provider and verifying notifications.

# Alternative (MVC) note:
If scaling to complex domains or multiple features, introduce a repository layer and split provider(s) per feature. For navigation and side-effects, consider Riverpod/BLoC; for now Provider remains lean and sufficient.


    
# (Optional) Specify a platform
 A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
