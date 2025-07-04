import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class Flashcard {
  String question;
  String answer;
  Flashcard({required this.question, required this.answer});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FlashcardHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlashcardHomePage extends StatefulWidget {
  const FlashcardHomePage({super.key});

  @override
  State<FlashcardHomePage> createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage>
    with SingleTickerProviderStateMixin {
  List<Flashcard> flashcards = [
    Flashcard(question: 'What is the capital of France?', answer: 'Paris'),
    Flashcard(question: 'What is 2 + 2?', answer: '4'),
    Flashcard(question: 'What is the largest planet?', answer: 'Jupiter'),
    Flashcard(
      question: 'Who wrote "Romeo and Juliet"?',
      answer: 'William Shakespeare',
    ),
    Flashcard(
      question: 'What is the boiling point of water in Celsius?',
      answer: '100',
    ),
  ];
  int currentIndex = 0;
  bool showAnswer = false;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextCard() {
    setState(() {
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
        showAnswer = false;
        isFront = true;
        _controller.reset();
      }
    });
  }

  void prevCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        showAnswer = false;
        isFront = true;
        _controller.reset();
      }
    });
  }

  void addOrEditFlashcard({Flashcard? card, int? index}) async {
    final result = await showDialog<Flashcard>(
      context: context,
      builder: (context) {
        final qController = TextEditingController(text: card?.question ?? '');
        final aController = TextEditingController(text: card?.answer ?? '');
        return AlertDialog(
          title: Text(card == null ? 'Add Flashcard' : 'Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: aController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (qController.text.trim().isNotEmpty &&
                    aController.text.trim().isNotEmpty) {
                  Navigator.pop(
                    context,
                    Flashcard(
                      question: qController.text.trim(),
                      answer: aController.text.trim(),
                    ),
                  );
                }
              },
              child: Text(card == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        if (card == null) {
          flashcards.add(result);
          currentIndex = flashcards.length - 1;
        } else if (index != null) {
          flashcards[index] = result;
        }
        showAnswer = false;
        isFront = true;
        _controller.reset();
      });
    }
  }

  void deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
      if (currentIndex >= flashcards.length) {
        currentIndex = flashcards.length - 1;
      }
      showAnswer = false;
      isFront = true;
      _controller.reset();
    });
  }

  void flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      showAnswer = !showAnswer;
      isFront = !isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = flashcards.isNotEmpty ? flashcards[currentIndex] : null;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Flashcard Quiz'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Flashcard',
              onPressed: () => addOrEditFlashcard(),
            ),
            if (card != null) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Flashcard',
                onPressed:
                    () => addOrEditFlashcard(card: card, index: currentIndex),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete Flashcard',
                onPressed: () => deleteFlashcard(currentIndex),
              ),
            ],
          ],
        ),
        body:
            flashcards.isEmpty
                ? const Center(child: Text('No flashcards. Add one!'))
                : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder:
                            (child, animation) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                        child: GestureDetector(
                          key: ValueKey(currentIndex),
                          onTap: flipCard,
                          child: AnimatedBuilder(
                            animation: _flipAnimation,
                            builder: (context, child) {
                              final angle = _flipAnimation.value * pi;
                              final isBack = angle > pi / 2;
                              return Transform(
                                alignment: Alignment.center,
                                transform:
                                    Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(angle),
                                child: Container(
                                  width: double.infinity,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.18),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child:
                                          isBack
                                              ? Transform(
                                                alignment: Alignment.center,
                                                transform:
                                                    Matrix4.identity()
                                                      ..rotateY(pi),
                                                child: Text(
                                                  card!.answer,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 28,
                                                    color: Colors.deepPurple,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                              : Text(
                                                card!.question,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28,
                                                  color: Colors.indigo,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: currentIndex > 0 ? prevCard : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          Text(
                            '${currentIndex + 1} / ${flashcards.length}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                currentIndex < flashcards.length - 1
                                    ? nextCard
                                    : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: flipCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              showAnswer ? Colors.indigo : Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 6,
                        ),
                        child: Text(showAnswer ? 'Hide Answer' : 'Show Answer'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
