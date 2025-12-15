# ⚡ 5 Seconds Showdown

> **Think Fast, Answer Faster\!**

[](https://flutter.dev)
[](https://dart.dev)
[](https://firebase.google.com)
[](https://deepmind.google/technologies/gemini/)
[](https://www.google.com/search?q=LICENSE)

**5 Seconds Showdown** is a fast-paced trivia game where players have just 5 seconds to name 3 things in a specific category. Built with **Flutter**, it features cutting-edge integrations like **Google Gemini AI** for dynamic question generation and roasting, **Voice Recognition** for hands-free play, and **Real-time Multiplayer**.

-----

## 🚀 Key Features

  * **⚡ Classic Mode**: Race against the clock to answer standard trivia questions.
  * **🤖 AI Satirical Mode**: Powered by **Google Gemini Pro**. The AI generates unique questions and hilariously "roasts" you based on your performance.
  * **🎤 Voice Challenge**: Speak your answers\! Uses speech-to-text to validate your responses automatically.
  * **🌍 Location Mode**: Dynamic questions based on your real-time GPS location (e.g., "Name 3 restaurants in Mumbai").
  * **⚔️ Multiplayer**: Challenge friends in real-time rooms managed via Cloud Firestore.
  * **♿ Accessibility First**: Includes Screen Reader support (TTS) and Visual Haptics for Deaf/Hard-of-Hearing users.
  * **💰 Gamification & Economy**: Earn coins, maintain daily streaks, and unlock achievements. Includes Rewarded Ads to save your streak.

-----

## 🛠️ Tech Stack

  * **Frontend**: Flutter (Dart)
  * **Backend**: Firebase (Firestore, Cloud Functions, Analytics, Messaging)
  * **AI Engine**: Google Generative AI SDK (Gemini Pro)
  * **Ads & Monetization**: Google Mobile Ads (AdMob) & RevenueCat (IAP)
  * **State Management**: GetX & Provider
  * **Local Storage**: Hive & Shared Preferences

-----

## ⚙️ Prerequisites

Before running the project, ensure you have the following:

  * [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
  * A **Firebase Project** set up.
  * **Google AI Studio Key** for Gemini.
  * **AdMob App ID** (for ads).

-----

## 📦 Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/thekartikeyamishra/five-seconds-showdown.git
    cd five-seconds-showdown
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Environment Configuration:**
    Create a `.env` file in the root directory. **Do not commit this file.**

    ```properties
    # .env
    APP_NAME="5 Seconds Showdown"
    ENVIRONMENT="development"

    # Keys
    GEMINI_API_KEY="your_gemini_key"

    # Firebase
    FIREBASE_API_KEY="your_firebase_web_api_key"
    FIREBASE_PROJECT_ID="your_project_id"
    FIREBASE_MESSAGING_SENDER_ID="your_sender_id"
    FIREBASE_ANDROID_APP_ID="your_android_app_id"
    FIREBASE_IOS_APP_ID="your_ios_app_id"

    # AdMob (Use Test IDs for dev)
    ANDROID_ADMOB_APP_ID="ca-app-pub-3940256099942544~3347511713"
    IOS_ADMOB_APP_ID="ca-app-pub-3940256099942544~1458002511"

    # Feature Flags
    ENABLE_VOICE=true
    ENABLE_AI=true
    ENABLE_MULTIPLAYER=true
    ```

    *(See `lib/core/config/env_config.dart` for all required keys)*

4.  **Run the app:**

    ```bash
    flutter run
    ```

-----

## 📂 Project Structure

```
lib/
├── controllers/      # Logic controllers (e.g., MultiplayerController)
├── core/
│   ├── config/       # EnvConfig, Flavor settings
│   ├── constants/    # AppConstants (Strings, URLs)
│   ├── services/     # Core services (AdMob, Firebase, Analytics)
│   └── theme/        # AppTheme, AppColors
├── models/           # Data models (Question, Room, User)
├── screens/          # UI Screens (Home, Game, Result)
├── services/         # Feature services (Gemini, Voice, Location)
├── utils/            # Helpers (SoundManager)
├── widgets/          # Reusable widgets (Timer, Buttons)
└── main.dart         # Entry point
```

-----

## 🤝 Contributing

Contributions are welcome\! Please follow these steps:

1.  Fork the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

-----

## 📞 Contact & Socials

  * **Developer**: Kartikeya Mishra
  * **GitHub**: [github.com/thekartikeyamishra](https://github.com/thekartikeyamishra)
  * **LinkedIn**: [linkedin.com/in/thekartikeyamishra](https://www.linkedin.com/in/thekartikeyamishra/)

-----

> Built with ❤️ By Kartikeya Mishra.


