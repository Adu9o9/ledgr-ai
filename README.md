# Ledgr.ai 💳

A privacy-first, offline-first AI budgeting mobile application engineered for high performance and tactile user experiences.

**[🔗 View Live Vercel Demo](https://ledgr-ai-pi.vercel.app/)** | **[▶️ Watch Architecture & Demo Video](https://drive.google.com/file/d/1qvTXxbxKzmUekglTLKS0G8ary0gSazLE/view?usp=sharing)**

## 🏗️ System Architecture
Ledgr.ai is designed to prioritize data privacy and seamless state management without relying on heavy cloud databases for core functionality. 

*   **Frontend Framework:** Flutter (Dart)
*   **UI/UX Component System:** CRED NeoPOP (Neumorphic tactile interfaces)
*   **State Management:** Riverpod (Compile-safe dependency injection)
*   **Local Persistence:** Hive NoSQL (Offline-first, encrypted binary storage)
*   **AI Engine Integration:** Gemini 3.6 Flash REST API (JSON structured prompt engineering)

## 🚀 Core Features
1. **Zero-Latency Logging:** Utilizing Hive's key-value store paired with Riverpod state notifiers, expense logging operates entirely on the device without network bottlenecks.
2. **Privacy-First Data Aggregation:** Raw transaction data never leaves the device. Data is aggregated and anonymized locally before being transmitted for analysis.
3. **Actionable AI Insights:** Integrates with Gemini 3.6 Flash via direct HTTP requests to parse localized spending habits and return strict, JSON-formatted financial advice.

## 🛠️ Build Instructions
To run this project locally:
```bash
git clone [https://github.com/Adu9o9/ledgr-ai.git](https://github.com/Adu9o9/ledgr-ai.git)
cd ledgr-ai
flutter pub get
flutter run -d chrome