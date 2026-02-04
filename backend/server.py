import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import os
from dotenv import load_dotenv


load_dotenv()


GROQ_API_KEY = os.environ.get("GROQ_API_KEY")

user_score = 0
ai_score = 0
current_turn = 0
MAX_TURNS = 10
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "llama-3.1-8b-instant"

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


async def get_groq_ai_move():
    
    if not GROQ_API_KEY:
        print("GROQ_API_KEY not set, using random move")
        return random.choice(["Rock", "Paper", "Scissor"])
    
    prompt = "You are playing Rock Paper Scissors. Choose one move. Reply with ONLY one word: Rock, Paper, or Scissor. Nothing else."
    
    try:
        response = requests.post(
            GROQ_API_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": GROQ_MODEL,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": 1.2,
                "max_tokens": 10
            },
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            ai_response = result["choices"][0]["message"]["content"].strip()
            print(f"Groq AI Response: {ai_response}")
            
          
            ai_response_lower = ai_response.lower()
            if "rock" in ai_response_lower:
                return "Rock"
            elif "paper" in ai_response_lower:
                return "Paper"
            elif "scissor" in ai_response_lower:
                return "Scissor"
            else:
                print(f"Invalid AI response: {ai_response}, using random")
                return random.choice(["Rock", "Paper", "Scissor"])
        else:
            print(f"Groq API error: {response.status_code} - {response.text}")
            return random.choice(["Rock", "Paper", "Scissor"])
            
    except Exception as e:
        print(f"Error calling Groq API: {e}")
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
    a_move = await get_groq_ai_move()

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

@app.get("/health")
async def health_check():
    """Health check endpoint for Render"""
    return {"status": "healthy", "groq_configured": bool(GROQ_API_KEY)}
