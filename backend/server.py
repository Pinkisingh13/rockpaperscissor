import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random

# Game state
user_score = 0
ai_score = 0
current_turn = 0
MAX_TURNS = 10

# Ollama configuration
OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "llama3.2"

app = FastAPI()

# CORS middleware for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Move(BaseModel):
    text: str


async def get_ollama_ai_move():
    prompt = """Choose one move for Rock Paper Scissors game.
Reply with exactly one word: Rock, Paper, or Scissor

Move:"""
    try:
        response = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 1.5,
                    "num_predict": 10
                }
            }
        )
        if response.status_code == 200:
            result = response.json()
            ai_response = result.get("response", "").strip()
            print(f"AI Response: {ai_response}")
            ai_response_lower = ai_response.lower()
            if "rock" in ai_response_lower:
                return "Rock"
            elif "paper" in ai_response_lower:
                return "Paper"
            elif "scissor" in ai_response_lower:
                return "Scissor"
            else:
                return random.choice(["Rock", "Paper", "Scissor"])
        else:
            print(f"Ollama error: {response.status_code}")
            return random.choice(["Rock", "Paper", "Scissor"])
    except Exception as e:
        print(f"An error occurred: {e}")
        return random.choice(["Rock", "Paper", "Scissor"])


@app.post("/play")
async def play_game(user_input: Move):
    global user_score, ai_score, current_turn

  
    if current_turn >= MAX_TURNS:
        if user_score > ai_score:
            final_result = f"You Win the Game! ({user_score}-{ai_score})"
        elif ai_score > user_score:
            final_result = f"AI Wins the Game! ({ai_score}-{user_score})"
        else:
            final_result = f"It's a Tie! ({user_score}-{ai_score})"

        return {
            "user": "",
            "ai": "",
            "result": "Game Over",
            "score_user": user_score,
            "score_ai": ai_score,
            "turns_played": current_turn,
            "turns_remaining": 0,
            "game_over": True,
            "final_result": final_result,
            "message": "Click Reset to play again!"
        }

    current_turn += 1

    u_move = user_input.text
    a_move = await get_ollama_ai_move()

    result = "Draw"

    if u_move == a_move:
        result = "Draw"
    elif (u_move == "Rock" and a_move == "Scissor") or \
         (u_move == "Paper" and a_move == "Rock") or \
         (u_move == "Scissor" and a_move == "Paper"):
        result = "You Win"
        user_score += 1
    else:
        result = "AI Win"
        ai_score += 1

    game_over = current_turn >= MAX_TURNS
    final_result = ""
    if game_over:
        if user_score > ai_score:
            final_result = f"You Win the Game! ({user_score}-{ai_score})"
        elif ai_score > user_score:
            final_result = f"AI Wins the Game! ({ai_score}-{user_score})"
        else:
            final_result = f"It's a Tie! ({user_score}-{ai_score})"

    return {
        "user": u_move,
        "ai": a_move,
        "result": result,
        "score_user": user_score,
        "score_ai": ai_score,
        "turns_played": current_turn,
        "turns_remaining": MAX_TURNS - current_turn,
        "game_over": game_over,
        "final_result": final_result,
        "message": "Click Reset to play again!" if game_over else ""
    }


@app.get("/reset")
async def reset_game():
    """Reset the game scores and turn counter"""
    global user_score, ai_score, current_turn
    user_score = 0
    ai_score = 0
    current_turn = 0
    return {
        "message": "Game reset successfully",
        "score_user": 0,
        "score_ai": 0,
        "turns_played": 0,
        "turns_remaining": MAX_TURNS,
        "game_over": False
    }


@app.get("/status")
async def game_status():
    """Get current game status"""
    global user_score, ai_score, current_turn
    game_over = current_turn >= MAX_TURNS
    
    final_result = ""
    if game_over:
        if user_score > ai_score:
            final_result = f"You Win the Game! ({user_score}-{ai_score})"
        elif ai_score > user_score:
            final_result = f"AI Wins the Game! ({ai_score}-{user_score})"
        else:
            final_result = f"It's a Tie! ({user_score}-{ai_score})"
    
    return {
        "score_user": user_score,
        "score_ai": ai_score,
        "turns_played": current_turn,
        "turns_remaining": MAX_TURNS - current_turn,
        "game_over": game_over,
        "final_result": final_result
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)