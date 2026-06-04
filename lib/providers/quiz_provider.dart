import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizProvider with ChangeNotifier {
  List<dynamic> _quizzes = [];
  Map<String, dynamic>? _activeQuiz;
  final List<dynamic> _quizHistory = [];
  final List<dynamic> _leaderboard = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get quizzes => _quizzes;
  Map<String, dynamic>? get activeQuiz => _activeQuiz;
  List<dynamic> get quizHistory => _quizHistory;
  List<dynamic> get leaderboard => _leaderboard;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load available quizzes
  Future<void> loadQuizzes(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quizzes = await ApiService.fetchQuizzes(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load detailed quiz with questions
  Future<void> loadQuizDetails(String token, String quizId) async {
    _isLoading = true;
    _errorMessage = null;
    _activeQuiz = null; // Clear previous
    notifyListeners();

    try {
      _activeQuiz = await ApiService.fetchQuizDetails(token, quizId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit quiz answers
  Future<Map<String, dynamic>?> submitQuizAnswers(
      String token, String quizId, List<Map<String, dynamic>> answers) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.submitQuiz(token, quizId, answers);
      if (res['error'] != null) {
        _errorMessage = res['error'];
        return null;
      }
      return res;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
