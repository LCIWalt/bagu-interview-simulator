// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bagu Interview Simulator';

  @override
  String get appTagline => 'Bagu-style technical interview practice';

  @override
  String get navPractice => 'Practice';

  @override
  String get navBank => 'Bank';

  @override
  String get navReview => 'Review';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'What shall we practice today?';

  @override
  String get homeSubtitle =>
      'One question at a time, or a full mock interview.';

  @override
  String get homeStartDrill => 'Start practice';

  @override
  String get homeStartMock => 'Mock interview';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get homeRecentSessions => 'Recent sessions';

  @override
  String get homeEmptyRecent => 'No sessions yet. Start with one question.';

  @override
  String get bankTitle => 'Question bank';

  @override
  String get bankPlaceholder => 'Browsing and search arrive in M1.';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewPlaceholder =>
      'Full reports and per-question review arrive in M3.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProviderSection => 'Model provider (BYOK)';

  @override
  String get settingsProviderHint =>
      'Keys live in the system secure storage (Keychain / Keystore), never in the database or logs.';

  @override
  String get settingsBaseUrl => 'Base URL';

  @override
  String get settingsApiKey => 'API key';

  @override
  String get settingsModel => 'Model';

  @override
  String get settingsModelHint =>
      'Interviewer and scorer are configured separately; model names are never hard-coded.';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsTest => 'Test connection';

  @override
  String get settingsTesting => 'Testing…';

  @override
  String get settingsSaved => 'Saved';

  @override
  String settingsConnectionOk(Object latency) {
    return 'Connected, first token in $latency ms';
  }

  @override
  String settingsConnectionFailed(Object reason) {
    return 'Connection failed: $reason';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageZh => '简体中文';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'v1 never requests microphone access; dictation uses the system keyboard. Answers stay on device by default.';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get settingsDesignDemo => 'Design system demo';

  @override
  String get designDemoTitle => 'Design system';

  @override
  String get designDemoQuality => 'Glass fallback';

  @override
  String get designQualityFull => 'Full (blur + refraction)';

  @override
  String get designQualityBlur => 'Blur only';

  @override
  String get designQualityFlat => 'Flat';

  @override
  String get designDemoContent => 'Content first, material second';

  @override
  String get designDemoBody =>
      'Glass is only for layering and focus; body text keeps high contrast.';

  @override
  String get practiceDetailTitle => 'Question detail';

  @override
  String get practiceDetailPlaceholder =>
      'Answer here once the bank is wired up.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmpty => 'Nothing here yet';

  @override
  String get failureNetwork =>
      'Network failed. Check your connection or proxy.';

  @override
  String get failureAuth => 'Authentication failed. Check the API key.';

  @override
  String get failureNotFound =>
      'Model or endpoint not found. Check the base URL and model name.';

  @override
  String get failureRateLimit => 'Too many requests. Please retry shortly.';

  @override
  String get failureTimeout => 'Request timed out. Please retry.';

  @override
  String get failureParse => 'Could not parse the response.';

  @override
  String get failureCancelled => 'Cancelled.';

  @override
  String get failureUnknown => 'Something went wrong.';

  @override
  String get startupErrorTitle => 'The app hit a problem';

  @override
  String get startupErrorBody =>
      'An error was logged with sensitive data redacted. You can retry or export logs.';

  @override
  String get logExport => 'Export logs';

  @override
  String logExportDone(Object path) {
    return 'Logs exported to $path';
  }

  @override
  String get settingsRoleInterviewer => 'Interviewer';

  @override
  String get settingsRoleScorer => 'Scorer';

  @override
  String get settingsApiKeyHint => 'Leave blank to keep the saved key';

  @override
  String get settingsApiKeyStored => 'Key saved';

  @override
  String get settingsTestNeedsKey => 'Enter an API key first';

  @override
  String get settingsTestNeedsUrl => 'Enter a base URL and model first';

  @override
  String get settingsInvalidUrl => 'Base URL must be an http(s) address';

  @override
  String get logExportEmpty => 'No logs to export yet';

  @override
  String get homeStartDrillHint => 'One question, instant score';

  @override
  String get homeStartMockHint => 'Full mock with a report';

  @override
  String get settingsDataSection => 'Data & privacy';

  @override
  String get settingsExportLogsHint =>
      'Export recent (redacted) logs for troubleshooting.';

  @override
  String get bankSearchHint => 'Search questions, topics or keywords';

  @override
  String get bankFilterAll => 'All';

  @override
  String get bankRoleBackend => 'Backend';

  @override
  String get bankRoleFrontend => 'Frontend';

  @override
  String get bankRoleAlgorithm => 'Algorithms';

  @override
  String get bankAllDifficulties => 'All difficulties';

  @override
  String bankDifficulty(Object level) {
    return 'Difficulty $level';
  }

  @override
  String get bankLoadMore => 'Load more';

  @override
  String get bankNoResults => 'No matching questions';

  @override
  String get bankNoResultsHint => 'Try another keyword or clear the filters.';

  @override
  String get bankRetry => 'Retry';

  @override
  String get bankSeedInstalling => 'Preparing the built-in bank…';

  @override
  String bankQuestionCount(Object count) {
    return '$count questions';
  }

  @override
  String get bankStarred => 'Starred';

  @override
  String get bankStar => 'Star';

  @override
  String get bankUnstar => 'Unstar';

  @override
  String get bankRevealAnswer => 'Answer first, then reveal';

  @override
  String get bankAnswerHiddenHint =>
      'Write down your own answer before comparing with the rubric.';

  @override
  String get bankAnswerSummary => 'Reference answer';

  @override
  String get bankKeyPoints => 'Key points';

  @override
  String get bankPitfalls => 'Common pitfalls';

  @override
  String get bankFollowups => 'Likely follow-ups';

  @override
  String get bankSource => 'Source';

  @override
  String get bankNotes => 'My notes';

  @override
  String get bankNotesHint =>
      'Capture pitfalls, analogies or your own phrasing…';

  @override
  String get bankNotesSaved => 'Saved';

  @override
  String get bankHistory => 'Answer history';

  @override
  String get bankHistoryEmpty => 'No answers yet.';

  @override
  String get bankYourAnswer => 'My outline (not scored)';

  @override
  String get bankYourAnswerHint => 'Write it down, then reveal the answer.';

  @override
  String get bankStatusVerified => 'Verified';

  @override
  String get bankStatusCommunity => 'Community';

  @override
  String get bankStatusAiDraft => 'AI draft';

  @override
  String get bankStatusUser => 'Mine';

  @override
  String get bankStatusOrphaned => 'Retired';

  @override
  String get bankDetailTitle => 'Question detail';

  @override
  String get bankTopicAll => 'All topics';

  @override
  String get bankClearFilters => 'Clear filters';

  @override
  String bankSourceLicense(Object license) {
    return 'License: $license';
  }

  @override
  String get bankUpdateTitle => 'Update question bank';

  @override
  String bankUpdateCurrent(Object version) {
    return 'Current version: $version';
  }

  @override
  String get bankUpdateNotInstalled => 'No bank installed yet';

  @override
  String get bankUpdateCheck => 'Check for updates';

  @override
  String get bankUpdateChecking => 'Checking…';

  @override
  String bankUpdateDownloading(Object percent) {
    return 'Downloading $percent%';
  }

  @override
  String bankUpdateVerifying(Object stage) {
    return 'Verifying ($stage)…';
  }

  @override
  String get bankUpdateActivating => 'Activating bank…';

  @override
  String bankUpdateDone(Object version) {
    return 'Updated to $version';
  }

  @override
  String get bankUpdateUpToDate => 'Already up to date';

  @override
  String get bankUpdateFailed => 'Update failed';

  @override
  String get bankUpdateCancel => 'Cancel';

  @override
  String get bankUpdateRetry => 'Retry';

  @override
  String get bankUpdateMirror => 'Mirror URL (optional)';

  @override
  String get bankUpdateMirrorHint => 'https://mirror.example.com/bank';

  @override
  String get bankUpdateReady => 'Update complete. The bank has been refreshed.';

  @override
  String get bankImportTitle => 'Import questions';

  @override
  String get bankImportHint =>
      'Paste question YAML (separate multiple with ---)';

  @override
  String get bankImportPreview => 'Preview';

  @override
  String get bankImportPolicy => 'On duplicate ID';

  @override
  String get bankImportSkip => 'Skip';

  @override
  String get bankImportOverwrite => 'Overwrite';

  @override
  String get bankImportMerge => 'Merge notes';

  @override
  String bankImportConfirm(Object count) {
    return 'Import $count';
  }

  @override
  String bankImportResult(
    Object created,
    Object failed,
    Object merged,
    Object overwritten,
    Object skipped,
  ) {
    return 'Done: $created created, $overwritten overwritten, $merged merged, $skipped skipped, $failed failed';
  }

  @override
  String get bankImportNoValid =>
      'Nothing importable. Check the YAML and required fields.';

  @override
  String get bankImportConflictLabel => 'Duplicate ID';

  @override
  String get bankImportInvalidLabel => 'Invalid';

  @override
  String get bankImportNeedPreview => 'Preview before importing.';

  @override
  String bankImportParsed(Object conflicts, Object valid) {
    return '$valid importable, $conflicts duplicate IDs.';
  }

  @override
  String get drillTitle => 'Practice';

  @override
  String get drillAnswerHint =>
      'Type or use system dictation; you can also paste an answer written elsewhere.';

  @override
  String drillTimer(Object duration) {
    return 'Answer time (estimated): $duration';
  }

  @override
  String get drillSubmit => 'Submit for scoring';

  @override
  String get drillScoring => 'Scoring…';

  @override
  String get drillNext => 'Next question';

  @override
  String get drillFinish => 'End practice';

  @override
  String get drillRetryScoring => 'Retry scoring';

  @override
  String get drillAnswerEmpty => 'Write something first.';

  @override
  String get drillNoQuestion => 'No questions available yet.';

  @override
  String get drillScoringFailed => 'Scoring failed, but your answer was saved.';

  @override
  String get drillScoreTitle => 'Score';

  @override
  String drillTotal(Object score) {
    return '$score / 5';
  }

  @override
  String get drillCorrectness => 'Correctness';

  @override
  String get drillDepth => 'Depth';

  @override
  String get drillStructure => 'Structure';

  @override
  String drillCoverage(Object percent) {
    return 'Key point coverage $percent%';
  }

  @override
  String get drillVerdictHit => 'Hit';

  @override
  String get drillVerdictPartial => 'Partial';

  @override
  String get drillVerdictMiss => 'Miss';

  @override
  String get drillVerdictNotAsked => 'Not asked';

  @override
  String get drillEvidence => 'Evidence';

  @override
  String get drillFactualErrors => 'Factual errors';

  @override
  String get drillDegraded =>
      'The scorer output could not be parsed; this turn is degraded and only the raw comment is kept.';

  @override
  String get drillAppeal => 'I covered this';

  @override
  String get drillAppealTitle => 'Submit appeal';

  @override
  String get drillAppealHint =>
      'Quote your own words; it becomes a calibration candidate.';

  @override
  String get drillAppealSaved =>
      'Recorded. Scores are not changed automatically.';

  @override
  String get drillNeedQuestion => 'Load a question first.';

  @override
  String get failureBudget =>
      'The token budget for this session is exhausted. End the session or raise the limit.';

  @override
  String get settingsUsageSection => 'Usage';

  @override
  String settingsUsageTokens(Object used) {
    return 'Tokens this month: $used';
  }

  @override
  String get settingsUsageEmpty => 'No calls this month yet.';

  @override
  String get mockSetupTitle => 'Mock setup';

  @override
  String get mockRole => 'Role';

  @override
  String get mockLevel => 'Level';

  @override
  String get mockLevelJunior => 'Junior';

  @override
  String get mockLevelMid => 'Mid';

  @override
  String get mockLevelSenior => 'Senior';

  @override
  String get mockLevelStaff => 'Staff';

  @override
  String get mockDuration => 'Duration';

  @override
  String mockDurationMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get mockDifficulty => 'Difficulty';

  @override
  String get mockFollowupDepth => 'Follow-up depth';

  @override
  String get mockStyle => 'Interviewer style';

  @override
  String get mockStyleFriendly => 'Friendly';

  @override
  String get mockStyleNeutral => 'Neutral';

  @override
  String get mockStyleStress => 'Stress';

  @override
  String get mockAllowHints => 'Allow hints';

  @override
  String get mockStart => 'Start interview';

  @override
  String get mockResume => 'Resume last interview';

  @override
  String get mockPhaseWarmup => 'Warm-up';

  @override
  String get mockPhaseSelfIntro => 'Self introduction';

  @override
  String get mockPhaseProject => 'Project deep dive';

  @override
  String get mockPhaseKnowledge => 'Knowledge';

  @override
  String get mockPhaseSystemDesign => 'System design';

  @override
  String get mockPhaseClosing => 'Q&A and wrap-up';

  @override
  String mockRemaining(Object time) {
    return '$time left';
  }

  @override
  String get mockLiveTitle => 'Mock interview';

  @override
  String get mockYourAnswer => 'Your answer';

  @override
  String get mockSubmit => 'Submit answer';

  @override
  String get mockFinishEarly => 'Finish early';

  @override
  String get mockEarlyFinishHint =>
      'The report will be marked as a small sample.';

  @override
  String get mockReportTitle => 'Interview report';

  @override
  String get mockReportHeadline => 'One-line summary';

  @override
  String get mockReportDimensions => 'Ability profile';

  @override
  String get mockReportNoTurns => 'No answers in this session.';

  @override
  String get mockReportBackHome => 'Back home';

  @override
  String mockReportEarly(Object count) {
    return 'Ended early with $count questions; the sample is small.';
  }

  @override
  String get mockReportPending => 'Some answers are still being scored.';

  @override
  String mockQuestionPrefix(Object index) {
    return 'Question $index: ';
  }

  @override
  String mockNextPhase(Object phase) {
    return 'Moving to $phase.';
  }

  @override
  String get mockInterviewer => 'Interviewer';

  @override
  String get mockYou => 'You';

  @override
  String get mockNoQuestion => 'No questions available.';

  @override
  String get mockStartFailed => 'Could not create the session. Please retry.';

  @override
  String get mockTimeUp => 'Time is up. Wrapping up.';

  @override
  String get mockLoadingSession => 'Loading session…';

  @override
  String get mockSessionMissing => 'Session not found or already ended.';

  @override
  String get mockScoringPending => 'Scoring…';

  @override
  String get mockInterviewerTyping => 'Interviewer is speaking…';

  @override
  String get reportWeakest => 'Weak topics';

  @override
  String get reportNoWeakness => 'No clear weakness yet';

  @override
  String get reportPlan => '7-day plan';

  @override
  String get reportInterviewerView => 'Interviewer view';

  @override
  String get reportExport => 'Export Markdown';

  @override
  String reportExported(Object path) {
    return 'Exported to $path';
  }

  @override
  String get reportExportFailed => 'Export failed';

  @override
  String get reportDelete => 'Delete session';

  @override
  String get reportDeleteConfirm => 'Delete this report?';

  @override
  String get reportDeleteBody =>
      'The session, answers and memory will be deleted permanently.';

  @override
  String get reportTurnAnswer => 'My answer';

  @override
  String get reportMissedPoints => 'Points to revisit';

  @override
  String get settingsRoleSearch => 'Web fact-check (Tavily / OpenAI Search)';

  @override
  String get drillFactChecks => 'Web fact-check';

  @override
  String get drillFactCheckSupported => 'Supported';

  @override
  String get drillFactCheckContradicted => 'Contradicted';

  @override
  String get drillFactCheckUnknown => 'Unknown';

  @override
  String get drillFactCheckEvidence => 'Evidence';

  @override
  String get settingsExportAppeals => 'Export appeal candidates';

  @override
  String settingsAppealsExported(Object path) {
    return 'Exported to $path';
  }

  @override
  String get settingsAppealsEmpty => 'No appeals yet.';

  @override
  String get bankTopicsTitle => 'Topics';

  @override
  String get bankAllTopics => 'All topics';

  @override
  String bankTopicSelected(Object topic) {
    return 'Topic: $topic';
  }

  @override
  String get bankRelatedTitle => 'Related questions';

  @override
  String get settingsRoleTts => 'Text to speech';

  @override
  String get mockInterviewerSpeaking => 'Interviewer is speaking…';

  @override
  String get mockMuteTts => 'Mute';

  @override
  String get mockUnmuteTts => 'Unmute';

  @override
  String get bankNewQuestion => 'New question';

  @override
  String get bankEditTitle => 'Question';

  @override
  String get bankEditBody => 'Notes (optional)';

  @override
  String get bankEditTopics => 'Topics (comma separated)';

  @override
  String get bankEditRole => 'Role';

  @override
  String get bankEditLevel => 'Level';

  @override
  String get bankEditDifficulty => 'Difficulty';

  @override
  String get bankEditType => 'Type';

  @override
  String get bankEditAnswerSummary => 'Reference answer';

  @override
  String get bankEditKeyPoints => 'Key points (one per line)';

  @override
  String get bankEditKeyPointsHint => 'At least one; scoring uses only these';

  @override
  String get bankEditPitfalls => 'Pitfalls (one per line, optional)';

  @override
  String get bankEditFollowups => 'Follow-ups (one per line, optional)';

  @override
  String get bankEditSourceUrl => 'Source URL (optional)';

  @override
  String get bankEditSourceTitle => 'Source title';

  @override
  String get bankEditLicense => 'License';

  @override
  String get bankSave => 'Save to my bank';

  @override
  String get bankSaveSuccess => 'Saved and searchable.';

  @override
  String get bankNeedTitle => 'Enter the question.';

  @override
  String get bankNeedTopics => 'Add at least one topic.';

  @override
  String get bankNeedKeyPoints => 'Add at least one key point.';

  @override
  String get bankDuplicateTitle => 'Possible duplicate';

  @override
  String bankDuplicateBody(Object score, Object title) {
    return 'Similar to “$title” ($score). Add anyway?';
  }

  @override
  String get bankDuplicateKeep => 'Add anyway';

  @override
  String get bankTypeKnowledge => 'Knowledge';

  @override
  String get bankTypeBehavioral => 'Behavioral';

  @override
  String get bankTypeSystemDesign => 'System design';

  @override
  String get bankTypeCoding => 'Coding';

  @override
  String get bankTypeProject => 'Project';

  @override
  String get bankBulkImportTitle => 'Bulk import';

  @override
  String get bankBulkImportHint =>
      'Paste YAML / JSON / CSV / Markdown.\nCSV headers: title, topics, keyPoints, sourceUrl…\nMarkdown blocks start with ## title.';

  @override
  String bankBulkFormat(Object format) {
    return 'Format: $format';
  }

  @override
  String bankBulkInvalidLine(Object line, Object message) {
    return 'Line $line: $message';
  }

  @override
  String get bankBulkNeedValid => 'Fix invalid rows before importing.';

  @override
  String bankBulkSummary(
    Object conflict,
    Object invalid,
    Object total,
    Object valid,
  ) {
    return '$total rows: $valid valid, $invalid invalid, $conflict conflicts';
  }

  @override
  String bankBulkCommit(Object count) {
    return 'Import $count';
  }

  @override
  String get bankRemoteTitle => 'Import from GitHub';

  @override
  String get bankRemoteHint =>
      'Paste a GitHub repo or file URL (https://github.com/owner/repo)';

  @override
  String get bankRemotePreview => 'Fetch preview';

  @override
  String bankRemoteLicense(Object license) {
    return 'License: $license';
  }

  @override
  String bankRemoteSummary(
    Object conflict,
    Object files,
    Object invalid,
    Object valid,
  ) {
    return '$files files · $valid valid / $invalid invalid / $conflict conflicts';
  }

  @override
  String bankRemoteImport(Object count) {
    return 'Import $count';
  }

  @override
  String bankRemoteFailed(Object message) {
    return 'Import failed: $message';
  }

  @override
  String get bankRemoteLoading => 'Fetching repository and license…';

  @override
  String get bankExperienceTitle => 'Extract from interview notes';

  @override
  String get bankExperienceHint =>
      'Paste an interview write-up; review drafts before saving.';

  @override
  String get bankExperienceExtract => 'Extract drafts';

  @override
  String get bankExperienceNeedKey =>
      'Configure a scorer API key in Settings first.';

  @override
  String get bankExperienceEmpty =>
      'No verifiable questions found; try another text.';

  @override
  String bankExperienceDrafts(Object count) {
    return '$count drafts. Select the ones to save.';
  }

  @override
  String bankExperienceSave(Object count) {
    return 'Save $count';
  }

  @override
  String bankExperienceSaved(Object count, Object skipped) {
    return 'Saved $count (skipped $skipped existing).';
  }

  @override
  String bankExperienceEvidence(Object evidence) {
    return 'Evidence: $evidence';
  }

  @override
  String bankExperienceFailed(Object message) {
    return 'Extraction failed: $message';
  }

  @override
  String get mockAvatarLabel => 'Xiao Shen';

  @override
  String get settingsSemanticSection => 'Semantic search (experimental)';

  @override
  String get settingsSemanticHint =>
      'Local bge model; build the index once. Falls back to keyword search if unavailable.';

  @override
  String get settingsSemanticToggle => 'Enable semantic search';

  @override
  String get settingsRebuildIndex => 'Rebuild vector index';

  @override
  String settingsIndexing(Object done, Object total) {
    return 'Indexing… $done/$total';
  }

  @override
  String settingsIndexDone(Object count, Object ms) {
    return 'Indexed $count questions in $ms ms';
  }

  @override
  String get settingsIndexUnavailable =>
      'Local model unavailable; keyword search remains active.';

  @override
  String settingsIndexFailed(Object message) {
    return 'Indexing failed: $message';
  }

  @override
  String get settingsModelCheck => 'Model self-check';

  @override
  String settingsModelCheckResult(
    Object dim,
    Object ms,
    Object related,
    Object unrelated,
  ) {
    return 'Model OK: $dim-d; related $related, unrelated $unrelated; 3 embeddings in $ms ms';
  }

  @override
  String get settingsModelCheckUnavailable =>
      'Model unavailable; check bundled assets.';

  @override
  String settingsSaveFailed(Object reason) {
    return 'Save failed: $reason';
  }

  @override
  String get settingsApiKeyStoredHint =>
      '•••••••••••• (saved; type a new key to replace)';

  @override
  String get bankRoleMobile => 'Mobile';

  @override
  String get reviewEmpty =>
      'No practice records yet. Finish a drill or mock interview to see reviews here.';

  @override
  String reviewSummary(Object avg, Object finished, Object total) {
    return '$total sessions · $finished finished · average $avg';
  }

  @override
  String get reviewModeDrill => 'Drill';

  @override
  String get reviewModeMock => 'Mock';

  @override
  String reviewTurns(Object count) {
    return '$count questions';
  }

  @override
  String get reviewOpenReport => 'Open full report';

  @override
  String get reviewOpenDrill => 'Open per-question review';

  @override
  String get reviewNoTurns => 'No answers in this session yet.';

  @override
  String get reviewStatusActive => 'In progress';

  @override
  String get reviewStatusFinished => 'Finished';

  @override
  String get reviewResume => 'Resume';

  @override
  String reviewScore(Object score) {
    return 'Score $score';
  }

  @override
  String get reviewNoScore => 'Not scored';

  @override
  String get reviewAnswer => 'Answer';

  @override
  String get reviewQuestion => 'Question';

  @override
  String get reviewGoBank => 'Open bank';

  @override
  String get reportTurnsTitle => 'Per-question review';

  @override
  String get reviewTrendTitle => 'Score trend';

  @override
  String reviewTrendHint(Object count) {
    return 'Last $count sessions (out of 5)';
  }

  @override
  String get reviewMasteryTitle => 'Topic mastery';

  @override
  String get reviewNoStats =>
      'Complete a few more sessions to see trends and topic mastery.';

  @override
  String reviewMasteryPercent(Object percent) {
    return '$percent%';
  }

  @override
  String reviewMasterySamples(Object count) {
    return '$count scored points';
  }

  @override
  String get settingsSearchHint =>
      'Use tavily-search for Tavily, or gpt-4o-mini-search-preview for OpenAI-compatible search (Base URL needs /v1)';

  @override
  String homeSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get homeDeleteSelected => 'Delete selected';

  @override
  String get homeDeleteConfirmTitle => 'Delete selected sessions?';

  @override
  String homeDeleteConfirmBody(Object count) {
    return '$count sessions and their answers, scores and reports will be deleted permanently.';
  }

  @override
  String get homeDeleteAction => 'Delete';

  @override
  String get reviewStartDrill => 'Start practice';
}
