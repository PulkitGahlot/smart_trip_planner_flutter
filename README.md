# Itinera AI ✈️

A smart, AI-powered trip planner built with Flutter that generates detailed, day-by-day travel itineraries based on natural language prompts.

---

## 📋 Table of Contents

- [About The Project](#-about-the-project)
- [✨ Key Features](#-key-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [🏗️ Project Architecture](#️-project-architecture)
- [🚀 Getting Started](#-getting-started)
- [🧠 How the AI Agent Works](#-how-the-ai-agent-works)
- [📸 Screenshots](#-screenshots)

---

## 📖 About The Project

Itinera AI is a mobile application designed to simplify travel planning. Users can describe their desired trip in a single sentence, and the app leverages the power of the Google Gemini API to generate a complete itinerary. This plan can then be refined through a conversational chat interface and saved for offline access.

This project was built as a comprehensive demonstration of modern Flutter development practices, including clean architecture, state management with Riverpod, and integration with powerful external APIs.

---

## ✨ Key Features

* **AI-Powered Itinerary Generation:** Get a complete travel plan from a simple text prompt.
* **Conversational Refinement:** Modify your itinerary by chatting with the AI.
* **Offline Storage:** Save your generated plans using a local Hive database for access without an internet connection.
* **Data Persistence:** User accounts and saved itineraries are securely stored and separated for each user.
* **Interactive Maps:** Open pinned locations directly in your native maps application.
* **Voice Input:** Use Speech-to-Text to dictate your travel plans.
* **Swipe to Delete:** Easily manage your saved itineraries from the home screen.

---

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** [Dart](https://dart.dev/)
* **AI:** [Google Gemini API](https://ai.google.dev/)
* **State Management:** [Riverpod](https://pub.dev/packages/flutter_riverpod)
* **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
* **Local Database:** [Hive](https://pub.dev/packages/hive_flutter)
* **API Key Management:** [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

## 🏗️ Project Architecture

This project follows the principles of **Clean Architecture** to ensure a separation of concerns, making the codebase scalable, testable, and maintainable.

The architecture is divided into three main layers:

* **Presentation Layer:** Contains all UI-related components (Screens, Widgets) and state management logic (Riverpod Providers). It is responsible for displaying data and handling user input.
* **Domain Layer:** The core of the application. It contains the business logic and defines the contracts for the data layer through abstract repository interfaces and entities (data models).
* **Data Layer:** Responsible for all data operations. It includes repository implementations that fetch data from local sources (Hive) and remote sources (Gemini API).

  ```
    Itinera AI
    │
    ├── Presentation (UI + State Management)
    │   └── Screens (Home, Chat, Profile, etc.)
    │   └── Providers (Riverpod Notifiers)
    │
    ├── Domain (Business Logic + Entities)
    │   └── Entities (SavedConversation, etc.)
    │   └── Repositories (Abstract contracts)
    │
    └── Data (Data Sources)
    └── Repositories (Implementations)
    └── Services (Gemini API, Hive DB)
  ```

  
---

## 🚀 Getting Started

Follow these instructions to get a local copy up and running.

### Prerequisites

* Flutter SDK (version 3.x or higher)
* An IDE like VS Code or Android Studio
* A Google Gemini API Key

### Installation

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/PulkitGahlot/smart_trip_planner_flutter.git
    ```

2.  **Navigate to the project directory:**
   
    ```sh
    cd itinera_ai
    ```

3.  **Install dependencies:**  

    ```sh
    flutter pub get
    ```

4.  **Set up your API Key:**
  
    * Create a file named `.env` in the root directory of the project.
    * Add your Gemini API key to this file:
        ```
        GEMINI_API_KEY=your_actual_api_key_here
        ```
    * The `.env` file is included in `.gitignore` to keep your key private.

5.  **Run the Build Runner:**
  
    This command generates the necessary adapter files for Hive to work with your custom data models.

    ```sh
    flutter packages pub run build_runner build --delete-conflicting-outputs
    ```

6.  **Run the App:**

    ```sh
    flutter run
    ```

---

## 🧠 How the AI Agent Works

The core intelligence of the app is managed by prompt engineering.

1.  **Initial Itinerary Generation:**
    * The user's simple prompt (e.g., "5 days in Tokyo") is embedded into a much larger, more detailed prompt.
    * This master prompt instructs the Gemini model to act as a travel expert and, most importantly, to format its entire response as a single, valid **JSON object**.
    * The app code then parses this JSON string to build the rich UI for the itinerary.

2.  **Follow-up Chat:**
    * For the conversational refinement, a different prompt is used.
    * The entire chat history is sent back to the Gemini API with instructions to continue the conversation in a helpful, non-JSON format. This allows for more natural-sounding follow-up messages.

---

## 📸 Screenshots

Home Screen
                             
<img width="365" height="793" alt="home_screen" src="https://github.com/user-attachments/assets/90658496-2cf5-46dc-89e8-4c3eb86067ae" />

Itinerary Created  

<img width="369" height="801" alt="itinerary_created_screen" src="https://github.com/user-attachments/assets/0dddf0d6-e245-4d07-a68e-9d3d899145da" />

---

## Download the app here

- [Itinera Ai](https://clikn.in/0gTOUpr)


<img width="300" height="300" alt="itinera_ai" src="https://github.com/user-attachments/assets/5e016bc5-7695-4cd5-8fbb-06f35645f968" />

---

## Aurthor

**Pulkit Gahlot**

- [Linkedin](https://linkedin.com/in/pulkit-gahlot)
- [Github](https://github.com/PulkitGahlot)
- [Email](mailto:pulkitgahlot85@gmail.com)
- [X (Formerly Twitter)](https://x.com/Pulkit_Gahlot_)

Thank you for visiting my repository.

Any suggestion is welcome.
