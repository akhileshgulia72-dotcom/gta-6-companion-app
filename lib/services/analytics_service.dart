import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics =
      FirebaseAnalytics.instance;

  static Future<void> appOpened() async {
    await _analytics.logAppOpen();
  }

  static Future<void> quizStarted() async {
    await _analytics.logEvent(
      name: 'quiz_started',
    );
  }

  static Future<void> questionAnswered({
    required bool correct,
  }) async {
    await _analytics.logEvent(
      name: 'question_answered',
      parameters: {
        'correct': correct ? 1 : 0,
      },
    );
  }

  static Future<void> quizCompleted({
    required int score,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {
        'score': score,
      },
    );
  }

  static Future<void> newsOpened() async {
    await _analytics.logEvent(
      name: 'news_opened',
    );
  }

  static Future<void> galleryOpened() async {
    await _analytics.logEvent(
      name: 'gallery_opened',
    );
  }

  static Future<void> luckyDrawOpened() async {
    await _analytics.logEvent(
      name: 'lucky_draw_opened',
    );
  }

  static Future<void> premiumOpened() async {
    await _analytics.logEvent(
      name: 'premium_screen_opened',
    );
  }

  static Future<void> premiumPurchased() async {
    await _analytics.logEvent(
      name: 'premium_purchase',
      parameters: {
        'product_id': 'gta6_premium',
      },
    );
  }
}