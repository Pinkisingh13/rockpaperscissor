# 🎮 Rock Paper Scissors AI Game

A full-stack Rock Paper Scissors game where you play against an AI powered by **Groq's Llama 3.1** model. Built with **Flutter** (frontend) and **FastAPI** (backend).
⭐ Star this repo if you found it helpful!

## 🌐 Live Demo

🎮 **Play Now:** [https://rockpaperscissor-with-groq.netlify.app](https://rockpaperscissor-with-groq.netlify.app)

## 🎬 Demo

![Rock Paper Scissors Demo](app_video.gif)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Groq](https://img.shields.io/badge/Groq_AI-FF6B6B?style=for-the-badge&logo=openai&logoColor=white)
![Render](https://img.shields.io/badge/Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)
![Netlify](https://img.shields.io/badge/Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)

## ✨ Features

- 🤖 **AI-Powered Opponent** - Play against Llama 3.1 AI via Groq API
- 🎯 **10-Round Games** - Best of 10 rounds with final winner announcement
- 📊 **Live Score Tracking** - Real-time score updates
- 🔄 **Reset Functionality** - Start a new game anytime
- 🌐 **Cross-Platform** - Works on Web, iOS, Android, Desktop
- ⚡ **Fast Response** - Groq provides ultra-fast AI inference

## 🛠️ Tech Stack

| Component | Technology | Deployment |
|-----------|------------|------------|
| Frontend | Flutter (Dart) | **Netlify** |
| Backend | FastAPI (Python) | **Render** |
| AI Model | Llama 3.1 via Groq API | - |

## 🚀 Deployment

| Service | Platform | URL |
|---------|----------|-----|
| Frontend | Netlify | [rockpaperscissor-with-groq.netlify.app](https://rockpaperscissor-with-groq.netlify.app) |
| Backend | Render | [rockpaperscissor-nizp.onrender.com](https://rockpaperscissor-nizp.onrender.com) |

## 📁 Project Structure

```
rockpaperscissor/
├── backend/
│   ├── server.py          # FastAPI server with Groq integration
│   ├── requirements.txt   # Python dependencies
│   ├── .env              # Environment variables (not in git)
│   └── .env.example      # Environment template
├── frontend/
│   ├── lib/
│   │   └── main.dart     # Flutter app
│   ├── pubspec.yaml      # Flutter dependencies
│   └── web/              # Web build output
├── render.yaml           # Render deployment config
└── README.md
```

## 🚀 Getting Started (Local Development)

### Prerequisites

- Python 3.11+
- Flutter SDK
- Groq API Key (free at https://console.groq.com)

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Create virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create `.env` file:
   ```bash
   cp .env.example .env
   ```

5. Add your Groq API key to `.env`:
   ```
   GROQ_API_KEY=your_api_key_here
   ```

6. Run the server:
   ```bash
   uvicorn server:app --reload --port 8001
   ```

### Frontend Setup

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run on web:
   ```bash
   flutter run -d chrome
   ```

   Or run on other platforms:
   ```bash
   flutter run -d macos    # macOS
   flutter run -d ios      # iOS Simulator
   flutter run -d android  # Android Emulator
   ```

## 🌐 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/play` | Make a move (Rock/Paper/Scissor) |
| GET | `/reset` | Reset game scores |
| GET | `/status` | Get current game status |
| GET | `/health` | Health check |

### Example Request

```bash
curl -X POST https://rockpaperscissor-nizp.onrender.com/play \
  -H "Content-Type: application/json" \
  -d '{"text": "Rock"}'
```

### Example Response

```json
{
  "user": "Rock",
  "ai": "Paper",
  "result": "AI Win",
  "score_user": 0,
  "score_ai": 1,
  "turns_played": 1,
  "turns_remaining": 9,
  "game_over": false,
  "final_result": "",
  "message": ""
}
```

## 🎮 How to Play

1. Choose your move: 🪨 Rock, 📄 Paper, or ✂️ Scissor
2. AI will make its move using Llama 3.1
3. Winner is determined:
   - Rock beats Scissor
   - Paper beats Rock
   - Scissor beats Paper
4. Play 10 rounds to determine the final winner
5. Click Reset to play again!

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GROQ_API_KEY` | Your Groq API key | Yes |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
