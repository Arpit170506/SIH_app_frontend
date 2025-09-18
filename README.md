# AMU Tracker App


*AMU Tracker* is a Flutter-based mobile application for monitoring and recording antimicrobial usage (AMU) in livestock farms. It allows farmers to submit records, vets to review them, and government authorities to monitor overall trends.

This README is tailored for developers new to Flutter, helping them navigate the frontend and integrate a backend.



# Project Structure

lib/

main.dart → Entry point of the app.

screen/ → All screens/dashboards:

farmer_dashboard.dart

vet_dashboard.dart

government_dashboard.dart

login_screen.dart

amu_details_form.dart → Form for submitting AMU records.

helpers.dart → Utility functions (logout, placeholder dialogs).

data_store.dart → In-memory storage for AMU records.

amu_record.dart → AMU record model class.

pubspec.yaml → Flutter dependencies.



# Key Notes for Frontend Developers:

screen/ contains the UI for different roles.

amu_details_form.dart is the main form used to submit AMU data.

helpers.dart contains utility functions used across screens.

data_store.dart simulates a backend; you will later replace it with API calls.



# How to Run the App

Install Flutter following the official guide: Flutter Installation

Clone the repository:

git clone https://github.com/USERNAME/amu_tracker_app.git
cd amu_tracker_app


Install dependencies:

flutter pub get


Run the app on an emulator or connected device:

flutter run



# Integrating Backend (for Non-Flutter Developers)

Currently, the app uses DataStore for in-memory storage. To integrate a real backend:

1. Replace DataStore with API Calls

In data_store.dart, remove the static records list.

Use HTTP requests to your backend using the http package
.

Example for fetching records:

final response = await http.get(Uri.parse('https://your-backend.com/records'));


Example for submitting a record:

await http.post(Uri.parse('https://your-backend.com/records'), body: record.toJson());

2. Update AMUDetailsForm Submission

Replace DataStore.records.add(...) with a call to your backend API.

3. Update Dashboards

Replace DataStore.records with backend fetch calls.

You may need to convert StatelessWidget dashboards to StatefulWidget to fetch data asynchronously.



# Helpful Tips

Flutter widgets are structured hierarchically: Scaffold → AppBar + Body.

ElevatedButton, ListView, Container are used heavily in the app.

Utility functions like logout() and showPlaceholderDialog() are in helpers.dart – use them as-is.



# Tech Stack

*Flutter (Dart)* – Frontend

*Backend* – Replace DataStore with Node.js, FastAPI, Firebase, or any REST API

*Material Design* – UI



# Future Improvements

Persistent backend integration.

Full Vet & Government dashboard functionality.

Video consultation feature.

Analytics & detailed reporting.

