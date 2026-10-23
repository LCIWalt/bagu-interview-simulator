import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'八股文面试模拟助手'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In zh, this message translates to:
  /// **'八股文技术面试练习'**
  String get appTagline;

  /// No description provided for @navPractice.
  ///
  /// In zh, this message translates to:
  /// **'练习'**
  String get navPractice;

  /// No description provided for @navBank.
  ///
  /// In zh, this message translates to:
  /// **'题库'**
  String get navBank;

  /// No description provided for @navReview.
  ///
  /// In zh, this message translates to:
  /// **'复盘'**
  String get navReview;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'今天练点什么？'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'一题一评，或来一场完整的模拟面试。'**
  String get homeSubtitle;

  /// No description provided for @homeStartDrill.
  ///
  /// In zh, this message translates to:
  /// **'开始练习'**
  String get homeStartDrill;

  /// No description provided for @homeStartMock.
  ///
  /// In zh, this message translates to:
  /// **'实战模式'**
  String get homeStartMock;

  /// No description provided for @homeComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将上线'**
  String get homeComingSoon;

  /// No description provided for @homeRecentSessions.
  ///
  /// In zh, this message translates to:
  /// **'最近练习'**
  String get homeRecentSessions;

  /// No description provided for @homeEmptyRecent.
  ///
  /// In zh, this message translates to:
  /// **'还没有练习记录，先从一题开始。'**
  String get homeEmptyRecent;

  /// No description provided for @bankTitle.
  ///
  /// In zh, this message translates to:
  /// **'题库'**
  String get bankTitle;

  /// No description provided for @bankPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'题库浏览与检索将在 M1 提供。'**
  String get bankPlaceholder;

  /// No description provided for @reviewTitle.
  ///
  /// In zh, this message translates to:
  /// **'复盘'**
  String get reviewTitle;

  /// No description provided for @reviewPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'整场报告与逐题回顾将在 M3 提供。'**
  String get reviewPlaceholder;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsProviderSection.
  ///
  /// In zh, this message translates to:
  /// **'模型服务（BYOK）'**
  String get settingsProviderSection;

  /// No description provided for @settingsProviderHint.
  ///
  /// In zh, this message translates to:
  /// **'密钥只保存在系统安全存储（Keychain / Keystore），不会写入数据库或日志。'**
  String get settingsProviderHint;

  /// No description provided for @settingsBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'Base URL'**
  String get settingsBaseUrl;

  /// No description provided for @settingsApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key'**
  String get settingsApiKey;

  /// No description provided for @settingsModel.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get settingsModel;

  /// No description provided for @settingsModelHint.
  ///
  /// In zh, this message translates to:
  /// **'面试官与评分官分别配置，模型名不写死。'**
  String get settingsModelHint;

  /// No description provided for @settingsSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get settingsSave;

  /// No description provided for @settingsTest.
  ///
  /// In zh, this message translates to:
  /// **'测试连通'**
  String get settingsTest;

  /// No description provided for @settingsTesting.
  ///
  /// In zh, this message translates to:
  /// **'测试中…'**
  String get settingsTesting;

  /// No description provided for @settingsSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get settingsSaved;

  /// No description provided for @settingsConnectionOk.
  ///
  /// In zh, this message translates to:
  /// **'连通成功，首 token {latency} ms'**
  String settingsConnectionOk(Object latency);

  /// No description provided for @settingsConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连通失败：{reason}'**
  String settingsConnectionFailed(Object reason);

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'界面语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageZh.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get settingsLanguageZh;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settingsThemeDark;

  /// No description provided for @settingsPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私说明'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In zh, this message translates to:
  /// **'v1 不申请麦克风权限，语音输入使用系统输入法听写；回答内容默认只存本地。'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String settingsVersion(Object version);

  /// No description provided for @settingsDesignDemo.
  ///
  /// In zh, this message translates to:
  /// **'设计系统演示'**
  String get settingsDesignDemo;

  /// No description provided for @designDemoTitle.
  ///
  /// In zh, this message translates to:
  /// **'设计系统'**
  String get designDemoTitle;

  /// No description provided for @designDemoQuality.
  ///
  /// In zh, this message translates to:
  /// **'玻璃降级'**
  String get designDemoQuality;

  /// No description provided for @designQualityFull.
  ///
  /// In zh, this message translates to:
  /// **'完整（模糊 + 折射）'**
  String get designQualityFull;

  /// No description provided for @designQualityBlur.
  ///
  /// In zh, this message translates to:
  /// **'仅模糊'**
  String get designQualityBlur;

  /// No description provided for @designQualityFlat.
  ///
  /// In zh, this message translates to:
  /// **'纯色'**
  String get designQualityFlat;

  /// No description provided for @designDemoContent.
  ///
  /// In zh, this message translates to:
  /// **'内容优先，材质退后'**
  String get designDemoContent;

  /// No description provided for @designDemoBody.
  ///
  /// In zh, this message translates to:
  /// **'玻璃只用于分层与聚焦，正文保持高对比。'**
  String get designDemoBody;

  /// No description provided for @practiceDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'题目详情'**
  String get practiceDetailTitle;

  /// No description provided for @practiceDetailPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'题库接入后在此作答。'**
  String get practiceDetailPlaceholder;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get commonEmpty;

  /// No description provided for @failureNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络或代理。'**
  String get failureNetwork;

  /// No description provided for @failureAuth.
  ///
  /// In zh, this message translates to:
  /// **'鉴权失败，请检查 API Key。'**
  String get failureAuth;

  /// No description provided for @failureNotFound.
  ///
  /// In zh, this message translates to:
  /// **'模型或接口不存在，请检查 Base URL 与模型名。'**
  String get failureNotFound;

  /// No description provided for @failureRateLimit.
  ///
  /// In zh, this message translates to:
  /// **'请求过于频繁，请稍后重试。'**
  String get failureRateLimit;

  /// No description provided for @failureTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请重试。'**
  String get failureTimeout;

  /// No description provided for @failureParse.
  ///
  /// In zh, this message translates to:
  /// **'响应解析失败。'**
  String get failureParse;

  /// No description provided for @failureCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消。'**
  String get failureCancelled;

  /// No description provided for @failureUnknown.
  ///
  /// In zh, this message translates to:
  /// **'发生未知错误。'**
  String get failureUnknown;

  /// No description provided for @startupErrorTitle.
  ///
  /// In zh, this message translates to:
  /// **'应用启动遇到问题'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In zh, this message translates to:
  /// **'已记录错误日志（已脱敏）。你可以重试或导出日志。'**
  String get startupErrorBody;

  /// No description provided for @logExport.
  ///
  /// In zh, this message translates to:
  /// **'导出日志'**
  String get logExport;

  /// No description provided for @logExportDone.
  ///
  /// In zh, this message translates to:
  /// **'日志已导出到 {path}'**
  String logExportDone(Object path);

  /// No description provided for @settingsRoleInterviewer.
  ///
  /// In zh, this message translates to:
  /// **'面试官'**
  String get settingsRoleInterviewer;

  /// No description provided for @settingsRoleScorer.
  ///
  /// In zh, this message translates to:
  /// **'评分官'**
  String get settingsRoleScorer;

  /// No description provided for @settingsApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'留空则沿用已保存的密钥'**
  String get settingsApiKeyHint;

  /// No description provided for @settingsApiKeyStored.
  ///
  /// In zh, this message translates to:
  /// **'已保存密钥'**
  String get settingsApiKeyStored;

  /// No description provided for @settingsTestNeedsKey.
  ///
  /// In zh, this message translates to:
  /// **'请先填写 API Key'**
  String get settingsTestNeedsKey;

  /// No description provided for @settingsTestNeedsUrl.
  ///
  /// In zh, this message translates to:
  /// **'请先填写 Base URL 与模型名'**
  String get settingsTestNeedsUrl;

  /// No description provided for @settingsInvalidUrl.
  ///
  /// In zh, this message translates to:
  /// **'Base URL 需为 http(s) 地址'**
  String get settingsInvalidUrl;

  /// No description provided for @logExportEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志可导出'**
  String get logExportEmpty;

  /// No description provided for @homeStartDrillHint.
  ///
  /// In zh, this message translates to:
  /// **'单题即时评分'**
  String get homeStartDrillHint;

  /// No description provided for @homeStartMockHint.
  ///
  /// In zh, this message translates to:
  /// **'整场模拟与复盘'**
  String get homeStartMockHint;

  /// No description provided for @settingsDataSection.
  ///
  /// In zh, this message translates to:
  /// **'数据与隐私'**
  String get settingsDataSection;

  /// No description provided for @settingsExportLogsHint.
  ///
  /// In zh, this message translates to:
  /// **'导出最近日志（已脱敏）用于排障。'**
  String get settingsExportLogsHint;

  /// No description provided for @bankSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索题目、主题或关键词'**
  String get bankSearchHint;

  /// No description provided for @bankFilterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get bankFilterAll;

  /// No description provided for @bankRoleBackend.
  ///
  /// In zh, this message translates to:
  /// **'后端'**
  String get bankRoleBackend;

  /// No description provided for @bankRoleFrontend.
  ///
  /// In zh, this message translates to:
  /// **'前端'**
  String get bankRoleFrontend;

  /// No description provided for @bankRoleAlgorithm.
  ///
  /// In zh, this message translates to:
  /// **'算法'**
  String get bankRoleAlgorithm;

  /// No description provided for @bankAllDifficulties.
  ///
  /// In zh, this message translates to:
  /// **'全部难度'**
  String get bankAllDifficulties;

  /// No description provided for @bankDifficulty.
  ///
  /// In zh, this message translates to:
  /// **'难度 {level}'**
  String bankDifficulty(Object level);

  /// No description provided for @bankLoadMore.
  ///
  /// In zh, this message translates to:
  /// **'加载更多'**
  String get bankLoadMore;

  /// No description provided for @bankNoResults.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的题目'**
  String get bankNoResults;

  /// No description provided for @bankNoResultsHint.
  ///
  /// In zh, this message translates to:
  /// **'换个关键词，或清空筛选条件。'**
  String get bankNoResultsHint;

  /// No description provided for @bankRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get bankRetry;

  /// No description provided for @bankSeedInstalling.
  ///
  /// In zh, this message translates to:
  /// **'正在准备内置题库…'**
  String get bankSeedInstalling;

  /// No description provided for @bankQuestionCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 道题'**
  String bankQuestionCount(Object count);

  /// No description provided for @bankStarred.
  ///
  /// In zh, this message translates to:
  /// **'已收藏'**
  String get bankStarred;

  /// No description provided for @bankStar.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get bankStar;

  /// No description provided for @bankUnstar.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get bankUnstar;

  /// No description provided for @bankRevealAnswer.
  ///
  /// In zh, this message translates to:
  /// **'先自答，再看答案'**
  String get bankRevealAnswer;

  /// No description provided for @bankAnswerHiddenHint.
  ///
  /// In zh, this message translates to:
  /// **'建议先写下自己的思路，再展开评分点对照。'**
  String get bankAnswerHiddenHint;

  /// No description provided for @bankAnswerSummary.
  ///
  /// In zh, this message translates to:
  /// **'参考答案'**
  String get bankAnswerSummary;

  /// No description provided for @bankKeyPoints.
  ///
  /// In zh, this message translates to:
  /// **'评分点'**
  String get bankKeyPoints;

  /// No description provided for @bankPitfalls.
  ///
  /// In zh, this message translates to:
  /// **'常见误区'**
  String get bankPitfalls;

  /// No description provided for @bankFollowups.
  ///
  /// In zh, this message translates to:
  /// **'可能的追问'**
  String get bankFollowups;

  /// No description provided for @bankSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get bankSource;

  /// No description provided for @bankNotes.
  ///
  /// In zh, this message translates to:
  /// **'我的笔记'**
  String get bankNotes;

  /// No description provided for @bankNotesHint.
  ///
  /// In zh, this message translates to:
  /// **'记录易错点、类比或自己的话术…'**
  String get bankNotesHint;

  /// No description provided for @bankNotesSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get bankNotesSaved;

  /// No description provided for @bankHistory.
  ///
  /// In zh, this message translates to:
  /// **'历史作答'**
  String get bankHistory;

  /// No description provided for @bankHistoryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有作答记录。'**
  String get bankHistoryEmpty;

  /// No description provided for @bankYourAnswer.
  ///
  /// In zh, this message translates to:
  /// **'我的思路（不会计分）'**
  String get bankYourAnswer;

  /// No description provided for @bankYourAnswerHint.
  ///
  /// In zh, this message translates to:
  /// **'先写下来，再展开答案对照。'**
  String get bankYourAnswerHint;

  /// No description provided for @bankStatusVerified.
  ///
  /// In zh, this message translates to:
  /// **'已校对'**
  String get bankStatusVerified;

  /// No description provided for @bankStatusCommunity.
  ///
  /// In zh, this message translates to:
  /// **'社区待校'**
  String get bankStatusCommunity;

  /// No description provided for @bankStatusAiDraft.
  ///
  /// In zh, this message translates to:
  /// **'AI 草稿'**
  String get bankStatusAiDraft;

  /// No description provided for @bankStatusUser.
  ///
  /// In zh, this message translates to:
  /// **'我新增的'**
  String get bankStatusUser;

  /// No description provided for @bankStatusOrphaned.
  ///
  /// In zh, this message translates to:
  /// **'已下线'**
  String get bankStatusOrphaned;

  /// No description provided for @bankDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'题目详情'**
  String get bankDetailTitle;

  /// No description provided for @bankTopicAll.
  ///
  /// In zh, this message translates to:
  /// **'全部主题'**
  String get bankTopicAll;

  /// No description provided for @bankClearFilters.
  ///
  /// In zh, this message translates to:
  /// **'清空筛选'**
  String get bankClearFilters;

  /// No description provided for @bankSourceLicense.
  ///
  /// In zh, this message translates to:
  /// **'许可：{license}'**
  String bankSourceLicense(Object license);

  /// No description provided for @bankUpdateTitle.
  ///
  /// In zh, this message translates to:
  /// **'题库更新'**
  String get bankUpdateTitle;

  /// No description provided for @bankUpdateCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前版本：{version}'**
  String bankUpdateCurrent(Object version);

  /// No description provided for @bankUpdateNotInstalled.
  ///
  /// In zh, this message translates to:
  /// **'尚未安装题库'**
  String get bankUpdateNotInstalled;

  /// No description provided for @bankUpdateCheck.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get bankUpdateCheck;

  /// No description provided for @bankUpdateChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检查…'**
  String get bankUpdateChecking;

  /// No description provided for @bankUpdateDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在下载 {percent}%'**
  String bankUpdateDownloading(Object percent);

  /// No description provided for @bankUpdateVerifying.
  ///
  /// In zh, this message translates to:
  /// **'正在校验（{stage}）…'**
  String bankUpdateVerifying(Object stage);

  /// No description provided for @bankUpdateActivating.
  ///
  /// In zh, this message translates to:
  /// **'正在切换题库…'**
  String get bankUpdateActivating;

  /// No description provided for @bankUpdateDone.
  ///
  /// In zh, this message translates to:
  /// **'已更新到 {version}'**
  String bankUpdateDone(Object version);

  /// No description provided for @bankUpdateUpToDate.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本'**
  String get bankUpdateUpToDate;

  /// No description provided for @bankUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败'**
  String get bankUpdateFailed;

  /// No description provided for @bankUpdateCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get bankUpdateCancel;

  /// No description provided for @bankUpdateRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get bankUpdateRetry;

  /// No description provided for @bankUpdateMirror.
  ///
  /// In zh, this message translates to:
  /// **'镜像地址（可选）'**
  String get bankUpdateMirror;

  /// No description provided for @bankUpdateMirrorHint.
  ///
  /// In zh, this message translates to:
  /// **'https://mirror.example.com/bank'**
  String get bankUpdateMirrorHint;

  /// No description provided for @bankUpdateReady.
  ///
  /// In zh, this message translates to:
  /// **'更新完成，题库已刷新。'**
  String get bankUpdateReady;

  /// No description provided for @bankImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'粘贴导入题库'**
  String get bankImportTitle;

  /// No description provided for @bankImportHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴题目 YAML（多题用 --- 分隔）'**
  String get bankImportHint;

  /// No description provided for @bankImportPreview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get bankImportPreview;

  /// No description provided for @bankImportPolicy.
  ///
  /// In zh, this message translates to:
  /// **'重复 ID 处理'**
  String get bankImportPolicy;

  /// No description provided for @bankImportSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get bankImportSkip;

  /// No description provided for @bankImportOverwrite.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get bankImportOverwrite;

  /// No description provided for @bankImportMerge.
  ///
  /// In zh, this message translates to:
  /// **'合并笔记'**
  String get bankImportMerge;

  /// No description provided for @bankImportConfirm.
  ///
  /// In zh, this message translates to:
  /// **'导入 {count} 道'**
  String bankImportConfirm(Object count);

  /// No description provided for @bankImportResult.
  ///
  /// In zh, this message translates to:
  /// **'导入完成：新增 {created}，覆盖 {overwritten}，合并 {merged}，跳过 {skipped}，失败 {failed}'**
  String bankImportResult(
    Object created,
    Object failed,
    Object merged,
    Object overwritten,
    Object skipped,
  );

  /// No description provided for @bankImportNoValid.
  ///
  /// In zh, this message translates to:
  /// **'没有可导入的题目，请检查 YAML 与必填字段。'**
  String get bankImportNoValid;

  /// No description provided for @bankImportConflictLabel.
  ///
  /// In zh, this message translates to:
  /// **'重复 ID'**
  String get bankImportConflictLabel;

  /// No description provided for @bankImportInvalidLabel.
  ///
  /// In zh, this message translates to:
  /// **'无效'**
  String get bankImportInvalidLabel;

  /// No description provided for @bankImportNeedPreview.
  ///
  /// In zh, this message translates to:
  /// **'请先预览再导入。'**
  String get bankImportNeedPreview;

  /// No description provided for @bankImportParsed.
  ///
  /// In zh, this message translates to:
  /// **'解析到 {valid} 道可导入，{conflicts} 道与已有题重复。'**
  String bankImportParsed(Object conflicts, Object valid);

  /// No description provided for @drillTitle.
  ///
  /// In zh, this message translates to:
  /// **'练习'**
  String get drillTitle;

  /// No description provided for @drillAnswerHint.
  ///
  /// In zh, this message translates to:
  /// **'用键盘或系统听写作答；也可以先写在别处再粘贴。'**
  String get drillAnswerHint;

  /// No description provided for @drillTimer.
  ///
  /// In zh, this message translates to:
  /// **'作答时长（估算）：{duration}'**
  String drillTimer(Object duration);

  /// No description provided for @drillSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交评分'**
  String get drillSubmit;

  /// No description provided for @drillScoring.
  ///
  /// In zh, this message translates to:
  /// **'评分中…'**
  String get drillScoring;

  /// No description provided for @drillNext.
  ///
  /// In zh, this message translates to:
  /// **'下一题'**
  String get drillNext;

  /// No description provided for @drillFinish.
  ///
  /// In zh, this message translates to:
  /// **'结束练习'**
  String get drillFinish;

  /// No description provided for @drillRetryScoring.
  ///
  /// In zh, this message translates to:
  /// **'重试评分'**
  String get drillRetryScoring;

  /// No description provided for @drillAnswerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'先写点内容再提交。'**
  String get drillAnswerEmpty;

  /// No description provided for @drillNoQuestion.
  ///
  /// In zh, this message translates to:
  /// **'题库里还没有可练习的题目。'**
  String get drillNoQuestion;

  /// No description provided for @drillScoringFailed.
  ///
  /// In zh, this message translates to:
  /// **'评分失败，但你的回答已保存。'**
  String get drillScoringFailed;

  /// No description provided for @drillScoreTitle.
  ///
  /// In zh, this message translates to:
  /// **'本题评分'**
  String get drillScoreTitle;

  /// No description provided for @drillTotal.
  ///
  /// In zh, this message translates to:
  /// **'{score} / 5'**
  String drillTotal(Object score);

  /// No description provided for @drillCorrectness.
  ///
  /// In zh, this message translates to:
  /// **'正确性'**
  String get drillCorrectness;

  /// No description provided for @drillDepth.
  ///
  /// In zh, this message translates to:
  /// **'深度'**
  String get drillDepth;

  /// No description provided for @drillStructure.
  ///
  /// In zh, this message translates to:
  /// **'结构'**
  String get drillStructure;

  /// No description provided for @drillCoverage.
  ///
  /// In zh, this message translates to:
  /// **'要点覆盖 {percent}%'**
  String drillCoverage(Object percent);

  /// No description provided for @drillVerdictHit.
  ///
  /// In zh, this message translates to:
  /// **'命中'**
  String get drillVerdictHit;

  /// No description provided for @drillVerdictPartial.
  ///
  /// In zh, this message translates to:
  /// **'部分'**
  String get drillVerdictPartial;

  /// No description provided for @drillVerdictMiss.
  ///
  /// In zh, this message translates to:
  /// **'缺失'**
  String get drillVerdictMiss;

  /// No description provided for @drillVerdictNotAsked.
  ///
  /// In zh, this message translates to:
  /// **'未问'**
  String get drillVerdictNotAsked;

  /// No description provided for @drillEvidence.
  ///
  /// In zh, this message translates to:
  /// **'证据'**
  String get drillEvidence;

  /// No description provided for @drillFactualErrors.
  ///
  /// In zh, this message translates to:
  /// **'事实错误'**
  String get drillFactualErrors;

  /// No description provided for @drillDegraded.
  ///
  /// In zh, this message translates to:
  /// **'评分官输出无法解析，本题已降级，仅保留原始说明。'**
  String get drillDegraded;

  /// No description provided for @drillAppeal.
  ///
  /// In zh, this message translates to:
  /// **'这点我答了'**
  String get drillAppeal;

  /// No description provided for @drillAppealTitle.
  ///
  /// In zh, this message translates to:
  /// **'提交申诉'**
  String get drillAppealTitle;

  /// No description provided for @drillAppealHint.
  ///
  /// In zh, this message translates to:
  /// **'贴一句你的原话，作为校准集候选。'**
  String get drillAppealHint;

  /// No description provided for @drillAppealSaved.
  ///
  /// In zh, this message translates to:
  /// **'已记录，不会自动改分。'**
  String get drillAppealSaved;

  /// No description provided for @drillNeedQuestion.
  ///
  /// In zh, this message translates to:
  /// **'请先加载题目。'**
  String get drillNeedQuestion;

  /// No description provided for @failureBudget.
  ///
  /// In zh, this message translates to:
  /// **'本场 token 预算已用完，请结束本场或调高上限。'**
  String get failureBudget;

  /// No description provided for @settingsUsageSection.
  ///
  /// In zh, this message translates to:
  /// **'用量'**
  String get settingsUsageSection;

  /// No description provided for @settingsUsageTokens.
  ///
  /// In zh, this message translates to:
  /// **'本月 tokens：{used}'**
  String settingsUsageTokens(Object used);

  /// No description provided for @settingsUsageEmpty.
  ///
  /// In zh, this message translates to:
  /// **'本月还没有调用记录。'**
  String get settingsUsageEmpty;

  /// No description provided for @mockSetupTitle.
  ///
  /// In zh, this message translates to:
  /// **'实战配置'**
  String get mockSetupTitle;

  /// No description provided for @mockRole.
  ///
  /// In zh, this message translates to:
  /// **'岗位方向'**
  String get mockRole;

  /// No description provided for @mockLevel.
  ///
  /// In zh, this message translates to:
  /// **'级别'**
  String get mockLevel;

  /// No description provided for @mockLevelJunior.
  ///
  /// In zh, this message translates to:
  /// **'初级'**
  String get mockLevelJunior;

  /// No description provided for @mockLevelMid.
  ///
  /// In zh, this message translates to:
  /// **'中级'**
  String get mockLevelMid;

  /// No description provided for @mockLevelSenior.
  ///
  /// In zh, this message translates to:
  /// **'高级'**
  String get mockLevelSenior;

  /// No description provided for @mockLevelStaff.
  ///
  /// In zh, this message translates to:
  /// **'专家'**
  String get mockLevelStaff;

  /// No description provided for @mockDuration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get mockDuration;

  /// No description provided for @mockDurationMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{minutes} 分钟'**
  String mockDurationMinutes(Object minutes);

  /// No description provided for @mockDifficulty.
  ///
  /// In zh, this message translates to:
  /// **'题目难度'**
  String get mockDifficulty;

  /// No description provided for @mockFollowupDepth.
  ///
  /// In zh, this message translates to:
  /// **'追问层数'**
  String get mockFollowupDepth;

  /// No description provided for @mockStyle.
  ///
  /// In zh, this message translates to:
  /// **'面试官风格'**
  String get mockStyle;

  /// No description provided for @mockStyleFriendly.
  ///
  /// In zh, this message translates to:
  /// **'友善'**
  String get mockStyleFriendly;

  /// No description provided for @mockStyleNeutral.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get mockStyleNeutral;

  /// No description provided for @mockStyleStress.
  ///
  /// In zh, this message translates to:
  /// **'压力'**
  String get mockStyleStress;

  /// No description provided for @mockAllowHints.
  ///
  /// In zh, this message translates to:
  /// **'允许提示'**
  String get mockAllowHints;

  /// No description provided for @mockStart.
  ///
  /// In zh, this message translates to:
  /// **'开始面试'**
  String get mockStart;

  /// No description provided for @mockResume.
  ///
  /// In zh, this message translates to:
  /// **'继续上次面试'**
  String get mockResume;

  /// No description provided for @mockPhaseWarmup.
  ///
  /// In zh, this message translates to:
  /// **'热身'**
  String get mockPhaseWarmup;

  /// No description provided for @mockPhaseSelfIntro.
  ///
  /// In zh, this message translates to:
  /// **'自我介绍'**
  String get mockPhaseSelfIntro;

  /// No description provided for @mockPhaseProject.
  ///
  /// In zh, this message translates to:
  /// **'项目深挖'**
  String get mockPhaseProject;

  /// No description provided for @mockPhaseKnowledge.
  ///
  /// In zh, this message translates to:
  /// **'知识'**
  String get mockPhaseKnowledge;

  /// No description provided for @mockPhaseSystemDesign.
  ///
  /// In zh, this message translates to:
  /// **'系统设计'**
  String get mockPhaseSystemDesign;

  /// No description provided for @mockPhaseClosing.
  ///
  /// In zh, this message translates to:
  /// **'反问与收尾'**
  String get mockPhaseClosing;

  /// No description provided for @mockRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {time}'**
  String mockRemaining(Object time);

  /// No description provided for @mockLiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'模拟面试'**
  String get mockLiveTitle;

  /// No description provided for @mockYourAnswer.
  ///
  /// In zh, this message translates to:
  /// **'你的回答'**
  String get mockYourAnswer;

  /// No description provided for @mockSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交回答'**
  String get mockSubmit;

  /// No description provided for @mockFinishEarly.
  ///
  /// In zh, this message translates to:
  /// **'提前结束'**
  String get mockFinishEarly;

  /// No description provided for @mockEarlyFinishHint.
  ///
  /// In zh, this message translates to:
  /// **'结束后会标注样本不足，报告仍会生成。'**
  String get mockEarlyFinishHint;

  /// No description provided for @mockReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'面试报告'**
  String get mockReportTitle;

  /// No description provided for @mockReportHeadline.
  ///
  /// In zh, this message translates to:
  /// **'一句话结论'**
  String get mockReportHeadline;

  /// No description provided for @mockReportDimensions.
  ///
  /// In zh, this message translates to:
  /// **'能力分布'**
  String get mockReportDimensions;

  /// No description provided for @mockReportNoTurns.
  ///
  /// In zh, this message translates to:
  /// **'本场没有作答记录。'**
  String get mockReportNoTurns;

  /// No description provided for @mockReportBackHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get mockReportBackHome;

  /// No description provided for @mockReportEarly.
  ///
  /// In zh, this message translates to:
  /// **'本场提前结束，仅 {count} 题，样本不足。'**
  String mockReportEarly(Object count);

  /// No description provided for @mockReportPending.
  ///
  /// In zh, this message translates to:
  /// **'部分题目仍在后台评分。'**
  String get mockReportPending;

  /// No description provided for @mockQuestionPrefix.
  ///
  /// In zh, this message translates to:
  /// **'第 {index} 题：'**
  String mockQuestionPrefix(Object index);

  /// No description provided for @mockNextPhase.
  ///
  /// In zh, this message translates to:
  /// **'进入{phase}阶段。'**
  String mockNextPhase(Object phase);

  /// No description provided for @mockInterviewer.
  ///
  /// In zh, this message translates to:
  /// **'面试官'**
  String get mockInterviewer;

  /// No description provided for @mockYou.
  ///
  /// In zh, this message translates to:
  /// **'你'**
  String get mockYou;

  /// No description provided for @mockNoQuestion.
  ///
  /// In zh, this message translates to:
  /// **'没有可用题目，无法开始面试。'**
  String get mockNoQuestion;

  /// No description provided for @mockStartFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建会话失败，请稍后重试。'**
  String get mockStartFailed;

  /// No description provided for @mockTimeUp.
  ///
  /// In zh, this message translates to:
  /// **'时间到，进入收尾。'**
  String get mockTimeUp;

  /// No description provided for @mockLoadingSession.
  ///
  /// In zh, this message translates to:
  /// **'加载会话…'**
  String get mockLoadingSession;

  /// No description provided for @mockSessionMissing.
  ///
  /// In zh, this message translates to:
  /// **'会话不存在或已结束。'**
  String get mockSessionMissing;

  /// No description provided for @mockScoringPending.
  ///
  /// In zh, this message translates to:
  /// **'评分中…'**
  String get mockScoringPending;

  /// No description provided for @mockInterviewerTyping.
  ///
  /// In zh, this message translates to:
  /// **'面试官正在说…'**
  String get mockInterviewerTyping;

  /// No description provided for @reportWeakest.
  ///
  /// In zh, this message translates to:
  /// **'薄弱主题'**
  String get reportWeakest;

  /// No description provided for @reportNoWeakness.
  ///
  /// In zh, this message translates to:
  /// **'暂无明显短板'**
  String get reportNoWeakness;

  /// No description provided for @reportPlan.
  ///
  /// In zh, this message translates to:
  /// **'7 天计划'**
  String get reportPlan;

  /// No description provided for @reportInterviewerView.
  ///
  /// In zh, this message translates to:
  /// **'面试官视角'**
  String get reportInterviewerView;

  /// No description provided for @reportExport.
  ///
  /// In zh, this message translates to:
  /// **'导出 Markdown'**
  String get reportExport;

  /// No description provided for @reportExported.
  ///
  /// In zh, this message translates to:
  /// **'已导出到 {path}'**
  String reportExported(Object path);

  /// No description provided for @reportExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get reportExportFailed;

  /// No description provided for @reportDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除本场'**
  String get reportDelete;

  /// No description provided for @reportDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除本场报告？'**
  String get reportDeleteConfirm;

  /// No description provided for @reportDeleteBody.
  ///
  /// In zh, this message translates to:
  /// **'会话、回答与记忆都会被删除，无法恢复。'**
  String get reportDeleteBody;

  /// No description provided for @reportTurnAnswer.
  ///
  /// In zh, this message translates to:
  /// **'我的回答'**
  String get reportTurnAnswer;

  /// No description provided for @reportMissedPoints.
  ///
  /// In zh, this message translates to:
  /// **'建议补的要点'**
  String get reportMissedPoints;

  /// No description provided for @settingsRoleSearch.
  ///
  /// In zh, this message translates to:
  /// **'联网核查（Tavily / OpenAI Search）'**
  String get settingsRoleSearch;

  /// No description provided for @drillFactChecks.
  ///
  /// In zh, this message translates to:
  /// **'联网核查'**
  String get drillFactChecks;

  /// No description provided for @drillFactCheckSupported.
  ///
  /// In zh, this message translates to:
  /// **'有来源支持'**
  String get drillFactCheckSupported;

  /// No description provided for @drillFactCheckContradicted.
  ///
  /// In zh, this message translates to:
  /// **'与来源矛盾'**
  String get drillFactCheckContradicted;

  /// No description provided for @drillFactCheckUnknown.
  ///
  /// In zh, this message translates to:
  /// **'无法确定'**
  String get drillFactCheckUnknown;

  /// No description provided for @drillFactCheckEvidence.
  ///
  /// In zh, this message translates to:
  /// **'证据'**
  String get drillFactCheckEvidence;

  /// No description provided for @settingsExportAppeals.
  ///
  /// In zh, this message translates to:
  /// **'导出申诉候选'**
  String get settingsExportAppeals;

  /// No description provided for @settingsAppealsExported.
  ///
  /// In zh, this message translates to:
  /// **'已导出到 {path}'**
  String settingsAppealsExported(Object path);

  /// No description provided for @settingsAppealsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有申诉记录。'**
  String get settingsAppealsEmpty;

  /// No description provided for @bankTopicsTitle.
  ///
  /// In zh, this message translates to:
  /// **'主题分类'**
  String get bankTopicsTitle;

  /// No description provided for @bankAllTopics.
  ///
  /// In zh, this message translates to:
  /// **'全部主题'**
  String get bankAllTopics;

  /// No description provided for @bankTopicSelected.
  ///
  /// In zh, this message translates to:
  /// **'主题：{topic}'**
  String bankTopicSelected(Object topic);

  /// No description provided for @bankRelatedTitle.
  ///
  /// In zh, this message translates to:
  /// **'相关题'**
  String get bankRelatedTitle;

  /// No description provided for @settingsRoleTts.
  ///
  /// In zh, this message translates to:
  /// **'语音播报（TTS）'**
  String get settingsRoleTts;

  /// No description provided for @mockInterviewerSpeaking.
  ///
  /// In zh, this message translates to:
  /// **'面试官正在说…'**
  String get mockInterviewerSpeaking;

  /// No description provided for @mockMuteTts.
  ///
  /// In zh, this message translates to:
  /// **'静音'**
  String get mockMuteTts;

  /// No description provided for @mockUnmuteTts.
  ///
  /// In zh, this message translates to:
  /// **'取消静音'**
  String get mockUnmuteTts;

  /// No description provided for @bankNewQuestion.
  ///
  /// In zh, this message translates to:
  /// **'新建题目'**
  String get bankNewQuestion;

  /// No description provided for @bankEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'题干'**
  String get bankEditTitle;

  /// No description provided for @bankEditBody.
  ///
  /// In zh, this message translates to:
  /// **'补充说明（可选）'**
  String get bankEditBody;

  /// No description provided for @bankEditTopics.
  ///
  /// In zh, this message translates to:
  /// **'主题（逗号分隔）'**
  String get bankEditTopics;

  /// No description provided for @bankEditRole.
  ///
  /// In zh, this message translates to:
  /// **'岗位'**
  String get bankEditRole;

  /// No description provided for @bankEditLevel.
  ///
  /// In zh, this message translates to:
  /// **'级别'**
  String get bankEditLevel;

  /// No description provided for @bankEditDifficulty.
  ///
  /// In zh, this message translates to:
  /// **'难度'**
  String get bankEditDifficulty;

  /// No description provided for @bankEditType.
  ///
  /// In zh, this message translates to:
  /// **'题型'**
  String get bankEditType;

  /// No description provided for @bankEditAnswerSummary.
  ///
  /// In zh, this message translates to:
  /// **'参考答案摘要'**
  String get bankEditAnswerSummary;

  /// No description provided for @bankEditKeyPoints.
  ///
  /// In zh, this message translates to:
  /// **'评分点（每行一条）'**
  String get bankEditKeyPoints;

  /// No description provided for @bankEditKeyPointsHint.
  ///
  /// In zh, this message translates to:
  /// **'至少一条；评分只按这些判定'**
  String get bankEditKeyPointsHint;

  /// No description provided for @bankEditPitfalls.
  ///
  /// In zh, this message translates to:
  /// **'常见误区（每行一条，可选）'**
  String get bankEditPitfalls;

  /// No description provided for @bankEditFollowups.
  ///
  /// In zh, this message translates to:
  /// **'追问（每行一条，可选）'**
  String get bankEditFollowups;

  /// No description provided for @bankEditSourceUrl.
  ///
  /// In zh, this message translates to:
  /// **'来源 URL（可选）'**
  String get bankEditSourceUrl;

  /// No description provided for @bankEditSourceTitle.
  ///
  /// In zh, this message translates to:
  /// **'来源标题'**
  String get bankEditSourceTitle;

  /// No description provided for @bankEditLicense.
  ///
  /// In zh, this message translates to:
  /// **'许可'**
  String get bankEditLicense;

  /// No description provided for @bankSave.
  ///
  /// In zh, this message translates to:
  /// **'保存到我的题库'**
  String get bankSave;

  /// No description provided for @bankSaveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已保存，可立即搜索到。'**
  String get bankSaveSuccess;

  /// No description provided for @bankNeedTitle.
  ///
  /// In zh, this message translates to:
  /// **'请填写题干。'**
  String get bankNeedTitle;

  /// No description provided for @bankNeedTopics.
  ///
  /// In zh, this message translates to:
  /// **'请至少填写一个主题。'**
  String get bankNeedTopics;

  /// No description provided for @bankNeedKeyPoints.
  ///
  /// In zh, this message translates to:
  /// **'请至少填写一个评分点。'**
  String get bankNeedKeyPoints;

  /// No description provided for @bankDuplicateTitle.
  ///
  /// In zh, this message translates to:
  /// **'疑似重复题目'**
  String get bankDuplicateTitle;

  /// No description provided for @bankDuplicateBody.
  ///
  /// In zh, this message translates to:
  /// **'与已有题目「{title}」相似度 {score}。仍要新增吗？'**
  String bankDuplicateBody(Object score, Object title);

  /// No description provided for @bankDuplicateKeep.
  ///
  /// In zh, this message translates to:
  /// **'仍然新增'**
  String get bankDuplicateKeep;

  /// No description provided for @bankTypeKnowledge.
  ///
  /// In zh, this message translates to:
  /// **'知识'**
  String get bankTypeKnowledge;

  /// No description provided for @bankTypeBehavioral.
  ///
  /// In zh, this message translates to:
  /// **'行为'**
  String get bankTypeBehavioral;

  /// No description provided for @bankTypeSystemDesign.
  ///
  /// In zh, this message translates to:
  /// **'系统设计'**
  String get bankTypeSystemDesign;

  /// No description provided for @bankTypeCoding.
  ///
  /// In zh, this message translates to:
  /// **'编码'**
  String get bankTypeCoding;

  /// No description provided for @bankTypeProject.
  ///
  /// In zh, this message translates to:
  /// **'项目'**
  String get bankTypeProject;

  /// No description provided for @bankBulkImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'批量导入'**
  String get bankBulkImportTitle;

  /// No description provided for @bankBulkImportHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 YAML / JSON / CSV / Markdown。\nCSV 表头支持 title, topics, keyPoints, sourceUrl…\nMarkdown 用 ## 标题 分块。'**
  String get bankBulkImportHint;

  /// No description provided for @bankBulkFormat.
  ///
  /// In zh, this message translates to:
  /// **'格式：{format}'**
  String bankBulkFormat(Object format);

  /// No description provided for @bankBulkInvalidLine.
  ///
  /// In zh, this message translates to:
  /// **'第 {line} 行：{message}'**
  String bankBulkInvalidLine(Object line, Object message);

  /// No description provided for @bankBulkNeedValid.
  ///
  /// In zh, this message translates to:
  /// **'存在无效行，修复后再导入。'**
  String get bankBulkNeedValid;

  /// No description provided for @bankBulkSummary.
  ///
  /// In zh, this message translates to:
  /// **'共 {total} 行：有效 {valid}，无效 {invalid}，冲突 {conflict}'**
  String bankBulkSummary(
    Object conflict,
    Object invalid,
    Object total,
    Object valid,
  );

  /// No description provided for @bankBulkCommit.
  ///
  /// In zh, this message translates to:
  /// **'导入 {count} 道'**
  String bankBulkCommit(Object count);

  /// No description provided for @bankRemoteTitle.
  ///
  /// In zh, this message translates to:
  /// **'从 GitHub 导入'**
  String get bankRemoteTitle;

  /// No description provided for @bankRemoteHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 GitHub 仓库或单文件 URL（https://github.com/owner/repo）'**
  String get bankRemoteHint;

  /// No description provided for @bankRemotePreview.
  ///
  /// In zh, this message translates to:
  /// **'获取预览'**
  String get bankRemotePreview;

  /// No description provided for @bankRemoteLicense.
  ///
  /// In zh, this message translates to:
  /// **'许可证：{license}'**
  String bankRemoteLicense(Object license);

  /// No description provided for @bankRemoteSummary.
  ///
  /// In zh, this message translates to:
  /// **'{files} 个文件 · 有效 {valid} / 无效 {invalid} / 冲突 {conflict}'**
  String bankRemoteSummary(
    Object conflict,
    Object files,
    Object invalid,
    Object valid,
  );

  /// No description provided for @bankRemoteImport.
  ///
  /// In zh, this message translates to:
  /// **'导入 {count} 道'**
  String bankRemoteImport(Object count);

  /// No description provided for @bankRemoteFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{message}'**
  String bankRemoteFailed(Object message);

  /// No description provided for @bankRemoteLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在获取仓库与许可证…'**
  String get bankRemoteLoading;

  /// No description provided for @bankExperienceTitle.
  ///
  /// In zh, this message translates to:
  /// **'从面经提取题目'**
  String get bankExperienceTitle;

  /// No description provided for @bankExperienceHint.
  ///
  /// In zh, this message translates to:
  /// **'粘贴面经/复盘长文，提取后人工勾选入库。'**
  String get bankExperienceHint;

  /// No description provided for @bankExperienceExtract.
  ///
  /// In zh, this message translates to:
  /// **'提取草稿'**
  String get bankExperienceExtract;

  /// No description provided for @bankExperienceNeedKey.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置中配置评分官 API key。'**
  String get bankExperienceNeedKey;

  /// No description provided for @bankExperienceEmpty.
  ///
  /// In zh, this message translates to:
  /// **'没有提取到可验证的题目，换一段文本再试。'**
  String get bankExperienceEmpty;

  /// No description provided for @bankExperienceDrafts.
  ///
  /// In zh, this message translates to:
  /// **'提取到 {count} 道草稿，勾选后入库。'**
  String bankExperienceDrafts(Object count);

  /// No description provided for @bankExperienceSave.
  ///
  /// In zh, this message translates to:
  /// **'保存 {count} 道'**
  String bankExperienceSave(Object count);

  /// No description provided for @bankExperienceSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存 {count} 道（跳过 {skipped} 道已存在）。'**
  String bankExperienceSaved(Object count, Object skipped);

  /// No description provided for @bankExperienceEvidence.
  ///
  /// In zh, this message translates to:
  /// **'依据：{evidence}'**
  String bankExperienceEvidence(Object evidence);

  /// No description provided for @bankExperienceFailed.
  ///
  /// In zh, this message translates to:
  /// **'提取失败：{message}'**
  String bankExperienceFailed(Object message);

  /// No description provided for @mockAvatarLabel.
  ///
  /// In zh, this message translates to:
  /// **'小深'**
  String get mockAvatarLabel;

  /// No description provided for @settingsSemanticSection.
  ///
  /// In zh, this message translates to:
  /// **'语义检索（实验）'**
  String get settingsSemanticSection;

  /// No description provided for @settingsSemanticHint.
  ///
  /// In zh, this message translates to:
  /// **'本地 bge 模型；首次需重建索引。模型不可用时自动回退关键词检索。'**
  String get settingsSemanticHint;

  /// No description provided for @settingsSemanticToggle.
  ///
  /// In zh, this message translates to:
  /// **'启用语义检索'**
  String get settingsSemanticToggle;

  /// No description provided for @settingsRebuildIndex.
  ///
  /// In zh, this message translates to:
  /// **'重建向量索引'**
  String get settingsRebuildIndex;

  /// No description provided for @settingsIndexing.
  ///
  /// In zh, this message translates to:
  /// **'正在建立索引… {done}/{total}'**
  String settingsIndexing(Object done, Object total);

  /// No description provided for @settingsIndexDone.
  ///
  /// In zh, this message translates to:
  /// **'索引完成：{count} 道题，耗时 {ms} ms'**
  String settingsIndexDone(Object count, Object ms);

  /// No description provided for @settingsIndexUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'本地模型不可用，已保留关键词检索。'**
  String get settingsIndexUnavailable;

  /// No description provided for @settingsIndexFailed.
  ///
  /// In zh, this message translates to:
  /// **'索引失败：{message}'**
  String settingsIndexFailed(Object message);

  /// No description provided for @settingsModelCheck.
  ///
  /// In zh, this message translates to:
  /// **'模型自检'**
  String get settingsModelCheck;

  /// No description provided for @settingsModelCheckResult.
  ///
  /// In zh, this message translates to:
  /// **'模型正常：{dim} 维；相关 {related}，无关 {unrelated}；3 次嵌入 {ms} ms'**
  String settingsModelCheckResult(
    Object dim,
    Object ms,
    Object related,
    Object unrelated,
  );

  /// No description provided for @settingsModelCheckUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'模型不可用，请检查资源包。'**
  String get settingsModelCheckUnavailable;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败：{reason}'**
  String settingsSaveFailed(Object reason);

  /// No description provided for @settingsApiKeyStoredHint.
  ///
  /// In zh, this message translates to:
  /// **'••••••••••••（已保存，输入新 key 可覆盖）'**
  String get settingsApiKeyStoredHint;

  /// No description provided for @bankRoleMobile.
  ///
  /// In zh, this message translates to:
  /// **'移动端'**
  String get bankRoleMobile;

  /// No description provided for @reviewEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有练习记录。完成一次练习或实战后，这里会出现逐题复盘。'**
  String get reviewEmpty;

  /// No description provided for @reviewSummary.
  ///
  /// In zh, this message translates to:
  /// **'共 {total} 场 · 已完成 {finished} 场 · 平均分 {avg}'**
  String reviewSummary(Object avg, Object finished, Object total);

  /// No description provided for @reviewModeDrill.
  ///
  /// In zh, this message translates to:
  /// **'练习'**
  String get reviewModeDrill;

  /// No description provided for @reviewModeMock.
  ///
  /// In zh, this message translates to:
  /// **'实战'**
  String get reviewModeMock;

  /// No description provided for @reviewTurns.
  ///
  /// In zh, this message translates to:
  /// **'{count} 题'**
  String reviewTurns(Object count);

  /// No description provided for @reviewOpenReport.
  ///
  /// In zh, this message translates to:
  /// **'查看整场报告'**
  String get reviewOpenReport;

  /// No description provided for @reviewOpenDrill.
  ///
  /// In zh, this message translates to:
  /// **'查看逐题复盘'**
  String get reviewOpenDrill;

  /// No description provided for @reviewNoTurns.
  ///
  /// In zh, this message translates to:
  /// **'这场还没有作答记录。'**
  String get reviewNoTurns;

  /// No description provided for @reviewStatusActive.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get reviewStatusActive;

  /// No description provided for @reviewStatusFinished.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get reviewStatusFinished;

  /// No description provided for @reviewResume.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get reviewResume;

  /// No description provided for @reviewScore.
  ///
  /// In zh, this message translates to:
  /// **'得分 {score}'**
  String reviewScore(Object score);

  /// No description provided for @reviewNoScore.
  ///
  /// In zh, this message translates to:
  /// **'未评分'**
  String get reviewNoScore;

  /// No description provided for @reviewAnswer.
  ///
  /// In zh, this message translates to:
  /// **'回答'**
  String get reviewAnswer;

  /// No description provided for @reviewQuestion.
  ///
  /// In zh, this message translates to:
  /// **'题目'**
  String get reviewQuestion;

  /// No description provided for @reviewGoBank.
  ///
  /// In zh, this message translates to:
  /// **'去题库'**
  String get reviewGoBank;

  /// No description provided for @reportTurnsTitle.
  ///
  /// In zh, this message translates to:
  /// **'逐题复盘'**
  String get reportTurnsTitle;

  /// No description provided for @reviewTrendTitle.
  ///
  /// In zh, this message translates to:
  /// **'分数趋势'**
  String get reviewTrendTitle;

  /// No description provided for @reviewTrendHint.
  ///
  /// In zh, this message translates to:
  /// **'最近 {count} 场（满分 5）'**
  String reviewTrendHint(Object count);

  /// No description provided for @reviewMasteryTitle.
  ///
  /// In zh, this message translates to:
  /// **'主题掌握度'**
  String get reviewMasteryTitle;

  /// No description provided for @reviewNoStats.
  ///
  /// In zh, this message translates to:
  /// **'再完成几场练习后，这里会显示趋势与主题掌握度。'**
  String get reviewNoStats;

  /// No description provided for @reviewMasteryPercent.
  ///
  /// In zh, this message translates to:
  /// **'{percent}%'**
  String reviewMasteryPercent(Object percent);

  /// No description provided for @reviewMasterySamples.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个评分点'**
  String reviewMasterySamples(Object count);

  /// No description provided for @settingsSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'Tavily 填 tavily-search；OpenAI 兼容搜索填 gpt-4o-mini-search-preview（Base URL 需带 /v1）'**
  String get settingsSearchHint;

  /// No description provided for @homeSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count} 项'**
  String homeSelectedCount(Object count);

  /// No description provided for @homeDeleteSelected.
  ///
  /// In zh, this message translates to:
  /// **'删除所选'**
  String get homeDeleteSelected;

  /// No description provided for @homeDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除所选记录？'**
  String get homeDeleteConfirmTitle;

  /// No description provided for @homeDeleteConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'将删除 {count} 场会话及其回答、评分与报告，无法恢复。'**
  String homeDeleteConfirmBody(Object count);

  /// No description provided for @homeDeleteAction.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get homeDeleteAction;

  /// No description provided for @reviewStartDrill.
  ///
  /// In zh, this message translates to:
  /// **'去练习'**
  String get reviewStartDrill;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
