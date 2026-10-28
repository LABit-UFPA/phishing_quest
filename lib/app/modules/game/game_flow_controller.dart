import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/answer.model.dart';
import 'package:phishing_quest/app/data/models/answer_result.model.dart';
import 'package:phishing_quest/app/data/models/question.model.dart';
import 'package:phishing_quest/app/data/repositories/game/game_repository.dart';
import 'package:phishing_quest/app/data/repositories/question/question_repository.dart';
import 'package:phishing_quest/app/data/repositories/request_repository.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/components/toast.dart';

/// Resposta dada a uma questao da partida.
class QuizRoundAnswer {
  final QuestionModel question;
  final List<AnswerModel> answers;
  final String selectedAnswerId;
  final AnswerResultModel result;

  QuizRoundAnswer({
    required this.question,
    required this.answers,
    required this.selectedAnswerId,
    required this.result,
  });

  String? get correctAnswerText => answers.firstWhereOrNull((a) => a.id == result.correctAnswerId)?.answerText;
}

/// Partida do quiz: ate [questionsPerRound] questoes sorteadas da
/// categoria. A correcao e os pontos vem de POST /game/answer.
class GameFlowController extends GetxController {
  static const int questionsPerRound = 5;

  // Arguments
  late final String categoryId;
  late final String categoryName;

  // State
  final RxList<QuestionModel> questions = <QuestionModel>[].obs;
  final RxMap<String, List<AnswerModel>> answersMap = <String, List<AnswerModel>>{}.obs;

  final RxInt currentIndex = 0.obs;
  final Rx<AnswerModel?> selectedAnswer = Rx<AnswerModel?>(null);
  final Rx<AnswerResultModel?> currentResult = Rx<AnswerResultModel?>(null);
  final RxBool isSubmitting = false.obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();

  // Results
  final RxList<QuizRoundAnswer> roundAnswers = <QuizRoundAnswer>[].obs;
  final RxInt roundPoints = 0.obs;

  QuestionModel get currentQuestion => questions[currentIndex.value];
  List<AnswerModel> get currentAnswers => answersMap[currentQuestion.id] ?? [];
  bool get isLastQuestion => currentIndex.value >= questions.length - 1;
  bool get isAnswered => currentResult.value != null;
  double get progress => questions.isEmpty ? 0.0 : (currentIndex.value + 1) / questions.length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    categoryId = args['categoryId'] as String;
    categoryName = args['categoryName'] as String;
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final questionRepo = QuestionRepository();
      final all = await questionRepo.getQuestionsByCategory(categoryId);
      final round = (all..shuffle()).take(questionsPerRound).toList();

      final answers = await Future.wait(round.map((q) => questionRepo.getAnswersByQuestion(q.id)));
      for (var i = 0; i < round.length; i++) {
        answersMap[round[i].id] = answers[i];
      }
      questions.assignAll(round);
    } on ApiException catch (e) {
      loadError.value = e.message;
    }
    isLoading.value = false;
  }

  void selectAnswer(AnswerModel answer) {
    if (isAnswered) return;
    selectedAnswer.value = answer;
  }

  /// Envia a resposta e mostra a correcao na propria questao.
  Future<void> submitAnswer() async {
    final answer = selectedAnswer.value;
    if (answer == null || isSubmitting.value || isAnswered) return;

    isSubmitting.value = true;
    try {
      final result = await GameRepository().submitAnswer(
        questionId: currentQuestion.id,
        answerId: answer.id,
      );
      currentResult.value = result;
      roundAnswers.add(QuizRoundAnswer(
        question: currentQuestion,
        answers: currentAnswers,
        selectedAnswerId: answer.id,
        result: result,
      ));
      roundPoints.value += result.pointsAwarded;
      await Get.find<AuthService>().updateScore(result.totalScore);
    } on ApiException catch (e) {
      Toast.error('Resposta não enviada', e.message);
    }
    isSubmitting.value = false;
  }

  void next() {
    if (!isAnswered) return;
    if (isLastQuestion) {
      Get.offNamed('/game/result', arguments: {
        'answers': roundAnswers.toList(),
        'roundPoints': roundPoints.value,
        'categoryId': categoryId,
        'categoryName': categoryName,
      });
      return;
    }
    selectedAnswer.value = null;
    currentResult.value = null;
    currentIndex.value++;
  }
}
