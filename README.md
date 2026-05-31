# 🧠 MemoMate

MemoMate is a premium, state-of-the-art Flutter mobile application meticulously crafted to assist Alzheimer's and dementia patients, support their caregivers, and streamline communications with specialist doctors. Built on modern software engineering principles, the application provides an all-in-one ecosystem for cognitive assistance, real-time clinical monitoring, GPS tracking, and secure communications.

---

## 🌟 Key Capabilities & Features

### 👥 1. Multi-Role Ecosystem
*   **Caregivers (Users):** Can register themselves and their loved ones, manage patient profiles, track GPS coordinates, view memory game statistics, and consult accepted doctors.
*   **Specialist Doctors:** Have dedicated profiles, view accepted patient lists, analyze cognitive trend dashboards, and manage connection requests.

### 🛡️ 2. Secure Connection & Patient Privacy Mode
*   **Invitation System:** Caregivers invite doctors via request cards. Doctors can either accept or decline the request.
*   **Restricted Privacy Mode:** To protect patient confidentiality, a doctor looking at a *pending* patient request cannot see sensitive information (AI diagnosis reports, medical history summaries, or contact numbers). Once accepted, full clinical records are unlocked.
*   **Mutual Deletion:** Caregivers can safely remove doctors, and doctors can remove patients. The deletion process cleans up references instantly across databases.

### 💬 3. Optimized Real-Time Chat
*   **Reversed Layout:** Integrates chronologically backward lists so latest messages appear immediately at the bottom, optimized for performance and fluid scrolling.
*   **Glowing Unread Badges:** Visually alerts users to incoming messages in real-time.
*   **Profile Navigation integration:** Tapping the chat header avatar immediately navigates to details screens.
*   **Loop Protection:** Specialized routing flags break navigation cycles (`Chat -> Profile -> Chat`) by popping rather than stacking duplicate routes.
*   **Security Barrier:** Patients can only open chat windows with doctors who have explicitly accepted their connection requests.

### 🎮 4. Memory Stimulation Suite
*   Includes built-in interactive cognitive games designed to stimulate spatial, numerical, and visual memory:
    *   **Memory Card Game:** Matching pairs with progressive difficulty.
    *   **Number Memory:** Auditory and visual sequence recall.
    *   **Path Finder:** Navigation and route planning patterns.
    *   **Multiple Stimuli:** Speed and cognitive processing tests.
    *   **Block Puzzle:** Visual-spatial alignment and logic.

### 📍 5. Real-Time GPS Tracking
*   Caregivers can track the patient's coordinates on interactive, responsive maps. Helps prevent wandering episodes by giving caregivers peace of mind.

### ⚡ 6. Zero-Crash Architecture
*   **Global Error Interceptor:** Employs `FlutterError.onError` to intercept framework UI errors and output clean debug signatures without terminating execution.
*   **Asynchronous Isolate Protection:** Employs `PlatformDispatcher.instance.onError` to catch isolate-level asynchronous exceptions and prevent OS-level app crashes.
*   **Mounted Context Guards:** Strict check-gates (`if (!mounted) return;`) protect context-based actions (like dialogs, alerts, and navigation routes) from occurring after widgets are unmounted.

---

## 🎨 Premium UI/UX Design System
MemoMate utilizes a meticulously designed UI that matches modern top-tier software:
*   ** harmonious Pastel Badges:** Uses glassmorphic container aesthetics (`AppColors.primary` with `0.15` opacity overlays) to display credentials and statuses without visual clutter.
*   **Responsive Multi-Line Scaling:** Uses `flutter_screenutil` to dynamically scale dimensions, fonts, and paddings across all screen sizes.
*   **Blurred Background Frame:** Doctor profile pictures are presented inside a gorgeous dual-layer container featuring a blurred matching backdrop (`BackdropFilter` with `15.0` sigma blur) and a contained, uncropped main image.

---

## 🛠️ Technical Stack & Architecture

*   **Framework:** Flutter (Dart 3.x)
*   **State Management:** BLoC (Business Logic Component) pattern via `flutter_bloc`.
*   **Networking:** `Dio` for optimized, unified HTTP requests with structured repositories.
*   **Local Storage:** `shared_preferences` for JWT tokens, session persistence, and role cache.
*   **Mapping:** `flutter_map` with real-time GPS tracking.
*   **Service Integration:** Socket client for real-time chat sync.

### Project Structure (Clean Architecture)
```text
lib/
├── core/
│   ├── api/             # Centralized endpoints & network settings
│   ├── services/        # Storage, notification, and upload utilities
│   ├── theme/           # App colors and design tokens
│   └── widgets/         # Custom text fields, buttons, and badges
└── features/
    ├── auth/            # Splash, role selection, and welcome screens
    ├── chat/            # Real-time message logic, widgets, and screen
    ├── doctor/          # Doctor registration, login, profile, and lists
    ├── memory_games/    # Interactive cognitive games
    └── user/            # Patient details, edit profiles, caregiver maps
```

---

## 🚀 Getting Started

### Prerequisites
Make sure you have Flutter installed and configured on your machine.
*   Flutter SDK: `>=3.10.4`
*   Dart SDK: `>=3.10.4`

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/hossamshafey3/memomatetest.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd memomatetest
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the application on an emulator or a connected physical device:
    ```bash
    flutter run
    ```
