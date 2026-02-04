import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const String baseUrl = 'https://rockpaperscissor-nizp.onrender.com';


  String _userMove = '';
  String _aiMove = '';
  String _result = '';
  int _userScore = 0;
  int _aiScore = 0;
  int _turnsPlayed = 0;
  int _turnsRemaining = 10;
  bool _gameOver = false;
  String _finalResult = '';
  bool _isLoading = false;

  Future<void> _playGame(String move) async {
    if (_gameOver) {
      _showError('Game Over! Click Reset to play again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/play'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': move}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("RESPONSE ===> $data");

        setState(() {
          _userMove = data['user'] ?? '';
          _aiMove = data['ai'] ?? '';
          _result = data['result'] ?? '';
          _userScore = data['score_user'] ?? 0;
          _aiScore = data['score_ai'] ?? 0;
          _turnsPlayed = data['turns_played'] ?? 0;
          _turnsRemaining = data['turns_remaining'] ?? 0;
          _gameOver = data['game_over'] ?? false;
          _finalResult = data['final_result'] ?? '';
        });
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection error: Make sure the server is running');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetGame() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/reset'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("RESET ===> $data");

        setState(() {
          _userMove = '';
          _aiMove = '';
          _result = '';
          _userScore = 0;
          _aiScore = 0;
          _turnsPlayed = 0;
          _turnsRemaining = 10;
          _gameOver = false;
          _finalResult = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game Reset! Ready to play again.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('Failed to reset game');
      }
    } catch (e) {
      _showError('Connection error: Make sure the server is running');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getEmoji(String move) {
    switch (move) {
      case 'Rock':
        return '🪨';
      case 'Paper':
        return '📄';
      case 'Scissor':
        return '✂️';
      default:
        return '❓';
    }
  }

  Color _getResultColor() {
    switch (_result) {
      case 'You Win':
        return Colors.green;
      case 'AI Win':
        return Colors.red;
      case 'Game Over':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          // Reset Button in AppBar
          IconButton(
            onPressed: _isLoading ? null : _resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Turn Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _gameOver ? Colors.red.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _gameOver ? Icons.flag : Icons.sports_esports,
                    color: _gameOver ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _gameOver
                        ? 'Game Over! Played $_turnsPlayed/10 turns'
                        : 'Turn $_turnsPlayed/10 • $_turnsRemaining remaining',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _gameOver ? Colors.red.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Score Board
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreCard('You', _userScore, Colors.blue),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildScoreCard('AI', _aiScore, Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Game Over 
            if (_gameOver && _finalResult.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _finalResult.contains('You Win')
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : _finalResult.contains('AI Wins')
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _finalResult.contains('You Win')
                          ? '🎉 CONGRATULATIONS! 🎉'
                          : _finalResult.contains('AI Wins')
                              ? '🤖 AI WINS! 🤖'
                              : '🤝 IT\'S A TIE! 🤝',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _finalResult,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _resetGame,
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Game Result Display (for individual rounds)
            if (_result.isNotEmpty && !_gameOver) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getResultColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _getResultColor(), width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              _getEmoji(_userMove),
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userMove,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('You'),
                          ],
                        ),
                        const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _getEmoji(_aiMove),
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _aiMove,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('AI'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getResultColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!_gameOver) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Choose your move!',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Best of 10 rounds',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

      
            if (_isLoading)
              const CircularProgressIndicator()
            else if (!_gameOver)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMoveButton('Rock', '🪨'),
                  _buildMoveButton('Paper', '📄'),
                  _buildMoveButton('Scissor', '✂️'),
                ],
              )
            // else
              // Show reset button when game is over
              // ElevatedButton.icon(
              //   onPressed: _resetGame,
              //   icon: const Icon(Icons.replay, size: 30),
              //   label: const Text(
              //     'Reset & Play Again',
              //     style: TextStyle(fontSize: 18),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.deepPurple,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 40,
              //       vertical: 15,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //   ),
              // ),
            // const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoveButton(String move, String emoji) {
    return GestureDetector(
      onTap: _gameOver ? null : () => _playGame(move),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _gameOver
              ? Colors.grey.shade300
              : Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: _gameOver
              ? []
              : [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 50,
                color: _gameOver ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              move,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _gameOver ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}