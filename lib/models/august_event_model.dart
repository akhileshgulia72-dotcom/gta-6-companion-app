class AugustEventModel {
  final DateTime eventDate;

  final String eventStatus;
  final String eventLabel;

  final String eventTitle;
  final String eventLiveTitle;

  final String eventSubtitle;
  final String eventLiveSubtitle;

  final String trailerVideoId;

  final bool eventIntelEnabled;
  final String eventIntelTitle;
  final String eventIntelText;

  final bool latestUpdatesEnabled;
  final bool watchTrailerEnabled;
  final bool exploreEnabled;
  final bool eventEnabled;

  final String latestUpdatesTitle;
  final String latestUpdatesSubtitle;

  final String watchTitle;
  final String watchSubtitle;

  final String exploreTitle;
  final String exploreSubtitle;

  AugustEventModel({
    required this.eventDate,
    required this.eventStatus,
    required this.eventLabel,
    required this.eventTitle,
    required this.eventLiveTitle,
    required this.eventSubtitle,
    required this.eventLiveSubtitle,
    required this.trailerVideoId,
    required this.eventIntelEnabled,
    required this.eventIntelTitle,
    required this.eventIntelText,
    required this.latestUpdatesEnabled,
    required this.watchTrailerEnabled,
    required this.exploreEnabled,
    required this.eventEnabled,
    required this.latestUpdatesTitle,
    required this.latestUpdatesSubtitle,
    required this.watchTitle,
    required this.watchSubtitle,
    required this.exploreTitle,
    required this.exploreSubtitle,
  });

  factory AugustEventModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AugustEventModel(
      eventDate: DateTime.parse(
        json['event_date'] ??
            '2026-08-27T00:00:00',
      ),

      eventStatus:
          json['event_status'] ??
              'COUNTDOWN ACTIVE',

      eventLabel:
          json['event_label'] ??
              'SPECIAL EVENT',

      eventTitle:
          json['event_title'] ??
              'COUNTDOWN TO GTA VI',

      eventLiveTitle:
          json['event_live_title'] ??
              'THE EVENT IS LIVE',

      eventSubtitle:
          json['event_subtitle'] ??
              'Something special is coming soon.',

      eventLiveSubtitle:
          json['event_live_subtitle'] ??
              'The event is now live.',

      trailerVideoId:
          json['trailer_video_id'] ??
              'VQRLujxTm3c',

      eventIntelEnabled:
          json['event_intel_enabled'] ?? true,

      eventIntelTitle:
          json['event_intel_title'] ??
              'VICE CITY TRANSMISSION',

      eventIntelText:
          json['event_intel_text'] ??
              'Stay connected for the latest updates.',

      latestUpdatesEnabled:
          json['latest_updates_enabled'] ?? true,

      watchTrailerEnabled:
          json['watch_trailer_enabled'] ?? true,

      exploreEnabled:
          json['explore_enabled'] ?? true,

      eventEnabled:
          json['event_enabled'] ?? true,

      latestUpdatesTitle:
          json['latest_updates_title'] ??
              'LATEST',

      latestUpdatesSubtitle:
          json['latest_updates_subtitle'] ??
              'UPDATES',

      watchTitle:
          json['watch_title'] ??
              'WATCH',

      watchSubtitle:
          json['watch_subtitle'] ??
              'TRAILER',

      exploreTitle:
          json['explore_title'] ??
              'EXPLORE',

      exploreSubtitle:
          json['explore_subtitle'] ??
              'GTA 6',
    );
  }
}