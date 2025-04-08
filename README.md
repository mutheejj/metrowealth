# MetroWealth 💰

Your Pocket-Sized Partner for Financial Growth and Management.

MetroWealth is a comprehensive Flutter application designed to help users manage their finances, focusing on loans and savings goals. It leverages Firebase for backend services and includes an admin panel for management and communication.

## ✨ Key Features

*   👤 **User Authentication:** Secure sign-up and login using Firebase Authentication.
*   💸 **Loan Management:** Apply for loans, view loan details, track status, and receive email statements/reminders.
*   🏦 **Savings Goals:** Create and track savings goals with progress visualization. Receive email statements for savings.
*   🔔 **Notifications:** In-app and email notifications for loan approvals, reminders, and statements.
*   🔒 **Secure Backend:** Utilizes Firebase Firestore for data storage and Firebase Rules for security.
*   ⚙️ **Admin Panel:**
    *   View and manage user loan applications.
    *   Approve/Reject loans.
    *   Send bulk email communications to users.
    *   Send loan/savings statements via email.

## 🛠️ Tech Stack

*   **Frontend:** Flutter
*   **Backend:** Firebase (Authentication, Firestore)
*   **Email Service:** SMTP via `mailer` package (Configured for MailerSend, adaptable to others)
*   **Environment Variables:** `flutter_dotenv`

## 🚀 Getting Started

Follow these steps to get the MetroWealth project running on your local machine.

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   [Git](https://git-scm.com/downloads) installed.
*   A Firebase project set up.

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/mutheejj/metrowealth
    cd metrowealth
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    *   Set up a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
    *   Enable **Authentication** (Email/Password sign-in method).
    *   Enable **Firestore Database**.
    *   Configure your Flutter app for Firebase according to the [official FlutterFire documentation](https://firebase.google.com/docs/flutter/setup). This typically involves adding configuration files like `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) to your project, and running `flutterfire configure`.
    *   Apply the Firestore security rules found in `firestore.rules`. You can deploy them using the Firebase CLI: `firebase deploy --only firestore:rules`

4.  **Environment Variables:**
    *   Create a file named `.env` in the root directory of the project.
    *   Add the following environment variables, replacing the placeholder values with your actual SMTP credentials (e.g., from MailerSend):

    ```dotenv
    # .env file
    SMTP_HOST=smtp.mailersend.net
    SMTP_PORT=587
    SMTP_USERNAME=your_mailersend_smtp_username
    SMTP_PASSWORD=your_mailersend_smtp_password
    SMTP_FROM_NAME=MetroWealth App
    ```

    *   _Ensure the `.env` file is listed in your `.gitignore` file to prevent committing sensitive credentials._

## 🏃 Running the App

1.  Ensure you have a connected device (emulator or physical device).
2.  Run the following command from the project root:
    ```bash
    flutter run
    ```

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

```text
MIT License

Copyright (c) 2025] john muthee maina

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

_(Note: Remember to create a `LICENSE` file in your repository root and update the copyright holder information above if you choose to use the MIT license)._

## ⭐ Feedback & Issues

We appreciate your feedback! If you encounter any bugs, have feature suggestions, or want to contribute, please feel free to:

*   **Leave a Review:** If you find MetroWealth helpful, consider giving the repository a star ⭐!
*   **Raise an Issue:** Report bugs or suggest features by opening an issue on the [GitHub Issues page](https://github.com/mutheejj/metrowealth/issues).
*   **Contribute:** Pull requests are welcome. Please open an issue first to discuss what you would like to change.


