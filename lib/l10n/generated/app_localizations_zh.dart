// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '八股文面试模拟助手';

  @override
  String get appTagline => '八股文技术面试练习';

  @override
  String get navPractice => '练习';

  @override
  String get navBank => '题库';

  @override
  String get navReview => '复盘';

  @override
  String get navSettings => '设置';

  @override
  String get homeTitle => '今天练点什么？';

  @override
  String get homeSubtitle => '一题一评，或来一场完整的模拟面试。';

  @override
  String get homeStartDrill => '开始练习';

  @override
  String get homeStartMock => '实战模式';

  @override
  String get homeComingSoon => '即将上线';

  @override
  String get homeRecentSessions => '最近练习';

  @override
  String get homeEmptyRecent => '还没有练习记录，先从一题开始。';

  @override
  String get bankTitle => '题库';

  @override
  String get bankPlaceholder => '题库浏览与检索将在 M1 提供。';

  @override
  String get reviewTitle => '复盘';

  @override
  String get reviewPlaceholder => '整场报告与逐题回顾将在 M3 提供。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsProviderSection => '模型服务（BYOK）';

  @override
  String get settingsProviderHint =>
      '密钥只保存在系统安全存储（Keychain / Keystore），不会写入数据库或日志。';

  @override
  String get settingsBaseUrl => 'Base URL';

  @override
  String get settingsApiKey => 'API Key';

  @override
  String get settingsModel => '模型';

  @override
  String get settingsModelHint => '面试官与评分官分别配置，模型名不写死。';

  @override
  String get settingsSave => '保存';

  @override
  String get settingsTest => '测试连通';

  @override
  String get settingsTesting => '测试中…';

  @override
  String get settingsSaved => '已保存';

  @override
  String settingsConnectionOk(Object latency) {
    return '连通成功，首 token $latency ms';
  }

  @override
  String settingsConnectionFailed(Object reason) {
    return '连通失败：$reason';
  }

  @override
  String get settingsLanguage => '界面语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsLanguageZh => '简体中文';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsPrivacy => '隐私说明';

  @override
  String get settingsPrivacyBody => 'v1 不申请麦克风权限，语音输入使用系统输入法听写；回答内容默认只存本地。';

  @override
  String get settingsAbout => '关于';

  @override
  String settingsVersion(Object version) {
    return '版本 $version';
  }

  @override
  String get settingsDesignDemo => '设计系统演示';

  @override
  String get designDemoTitle => '设计系统';

  @override
  String get designDemoQuality => '玻璃降级';

  @override
  String get designQualityFull => '完整（模糊 + 折射）';

  @override
  String get designQualityBlur => '仅模糊';

  @override
  String get designQualityFlat => '纯色';

  @override
  String get designDemoContent => '内容优先，材质退后';

  @override
  String get designDemoBody => '玻璃只用于分层与聚焦，正文保持高对比。';

  @override
  String get practiceDetailTitle => '题目详情';

  @override
  String get practiceDetailPlaceholder => '题库接入后在此作答。';

  @override
  String get commonCancel => '取消';

  @override
  String get commonRetry => '重试';

  @override
  String get commonClose => '关闭';

  @override
  String get commonLoading => '加载中…';

  @override
  String get commonEmpty => '暂无数据';

  @override
  String get failureNetwork => '网络连接失败，请检查网络或代理。';

  @override
  String get failureAuth => '鉴权失败，请检查 API Key。';

  @override
  String get failureNotFound => '模型或接口不存在，请检查 Base URL 与模型名。';

  @override
  String get failureRateLimit => '请求过于频繁，请稍后重试。';

  @override
  String get failureTimeout => '请求超时，请重试。';

  @override
  String get failureParse => '响应解析失败。';

  @override
  String get failureCancelled => '已取消。';

  @override
  String get failureUnknown => '发生未知错误。';

  @override
  String get startupErrorTitle => '应用启动遇到问题';

  @override
  String get startupErrorBody => '已记录错误日志（已脱敏）。你可以重试或导出日志。';

  @override
  String get logExport => '导出日志';

  @override
  String logExportDone(Object path) {
    return '日志已导出到 $path';
  }

  @override
  String get settingsRoleInterviewer => '面试官';

  @override
  String get settingsRoleScorer => '评分官';

  @override
  String get settingsApiKeyHint => '留空则沿用已保存的密钥';

  @override
  String get settingsApiKeyStored => '已保存密钥';

  @override
  String get settingsTestNeedsKey => '请先填写 API Key';

  @override
  String get settingsTestNeedsUrl => '请先填写 Base URL 与模型名';

  @override
  String get settingsInvalidUrl => 'Base URL 需为 http(s) 地址';

  @override
  String get logExportEmpty => '暂无日志可导出';

  @override
  String get homeStartDrillHint => '单题即时评分';

  @override
  String get homeStartMockHint => '整场模拟与复盘';

  @override
  String get settingsDataSection => '数据与隐私';

  @override
  String get settingsExportLogsHint => '导出最近日志（已脱敏）用于排障。';

  @override
  String get bankSearchHint => '搜索题目、主题或关键词';

  @override
  String get bankFilterAll => '全部';

  @override
  String get bankRoleBackend => '后端';

  @override
  String get bankRoleFrontend => '前端';

  @override
  String get bankRoleAlgorithm => '算法';

  @override
  String get bankAllDifficulties => '全部难度';

  @override
  String bankDifficulty(Object level) {
    return '难度 $level';
  }

  @override
  String get bankLoadMore => '加载更多';

  @override
  String get bankNoResults => '没有匹配的题目';

  @override
  String get bankNoResultsHint => '换个关键词，或清空筛选条件。';

  @override
  String get bankRetry => '重试';

  @override
  String get bankSeedInstalling => '正在准备内置题库…';

  @override
  String bankQuestionCount(Object count) {
    return '$count 道题';
  }

  @override
  String get bankStarred => '已收藏';

  @override
  String get bankStar => '收藏';

  @override
  String get bankUnstar => '取消收藏';

  @override
  String get bankRevealAnswer => '先自答，再看答案';

  @override
  String get bankAnswerHiddenHint => '建议先写下自己的思路，再展开评分点对照。';

  @override
  String get bankAnswerSummary => '参考答案';

  @override
  String get bankKeyPoints => '评分点';

  @override
  String get bankPitfalls => '常见误区';

  @override
  String get bankFollowups => '可能的追问';

  @override
  String get bankSource => '来源';

  @override
  String get bankNotes => '我的笔记';

  @override
  String get bankNotesHint => '记录易错点、类比或自己的话术…';

  @override
  String get bankNotesSaved => '已保存';

  @override
  String get bankHistory => '历史作答';

  @override
  String get bankHistoryEmpty => '还没有作答记录。';

  @override
  String get bankYourAnswer => '我的思路（不会计分）';

  @override
  String get bankYourAnswerHint => '先写下来，再展开答案对照。';

  @override
  String get bankStatusVerified => '已校对';

  @override
  String get bankStatusCommunity => '社区待校';

  @override
  String get bankStatusAiDraft => 'AI 草稿';

  @override
  String get bankStatusUser => '我新增的';

  @override
  String get bankStatusOrphaned => '已下线';

  @override
  String get bankDetailTitle => '题目详情';

  @override
  String get bankTopicAll => '全部主题';

  @override
  String get bankClearFilters => '清空筛选';

  @override
  String bankSourceLicense(Object license) {
    return '许可：$license';
  }

  @override
  String get bankUpdateTitle => '题库更新';

  @override
  String bankUpdateCurrent(Object version) {
    return '当前版本：$version';
  }

  @override
  String get bankUpdateNotInstalled => '尚未安装题库';

  @override
  String get bankUpdateCheck => '检查更新';

  @override
  String get bankUpdateChecking => '正在检查…';

  @override
  String bankUpdateDownloading(Object percent) {
    return '正在下载 $percent%';
  }

  @override
  String bankUpdateVerifying(Object stage) {
    return '正在校验（$stage）…';
  }

  @override
  String get bankUpdateActivating => '正在切换题库…';

  @override
  String bankUpdateDone(Object version) {
    return '已更新到 $version';
  }

  @override
  String get bankUpdateUpToDate => '已是最新版本';

  @override
  String get bankUpdateFailed => '更新失败';

  @override
  String get bankUpdateCancel => '取消';

  @override
  String get bankUpdateRetry => '重试';

  @override
  String get bankUpdateMirror => '镜像地址（可选）';

  @override
  String get bankUpdateMirrorHint => 'https://mirror.example.com/bank';

  @override
  String get bankUpdateReady => '更新完成，题库已刷新。';

  @override
  String get bankImportTitle => '粘贴导入题库';

  @override
  String get bankImportHint => '粘贴题目 YAML（多题用 --- 分隔）';

  @override
  String get bankImportPreview => '预览';

  @override
  String get bankImportPolicy => '重复 ID 处理';

  @override
  String get bankImportSkip => '跳过';

  @override
  String get bankImportOverwrite => '覆盖';

  @override
  String get bankImportMerge => '合并笔记';

  @override
  String bankImportConfirm(Object count) {
    return '导入 $count 道';
  }

  @override
  String bankImportResult(
    Object created,
    Object failed,
    Object merged,
    Object overwritten,
    Object skipped,
  ) {
    return '导入完成：新增 $created，覆盖 $overwritten，合并 $merged，跳过 $skipped，失败 $failed';
  }

  @override
  String get bankImportNoValid => '没有可导入的题目，请检查 YAML 与必填字段。';

  @override
  String get bankImportConflictLabel => '重复 ID';

  @override
  String get bankImportInvalidLabel => '无效';

  @override
  String get bankImportNeedPreview => '请先预览再导入。';

  @override
  String bankImportParsed(Object conflicts, Object valid) {
    return '解析到 $valid 道可导入，$conflicts 道与已有题重复。';
  }

  @override
  String get drillTitle => '练习';

  @override
  String get drillAnswerHint => '用键盘或系统听写作答；也可以先写在别处再粘贴。';

  @override
  String drillTimer(Object duration) {
    return '作答时长（估算）：$duration';
  }

  @override
  String get drillSubmit => '提交评分';

  @override
  String get drillScoring => '评分中…';

  @override
  String get drillNext => '下一题';

  @override
  String get drillFinish => '结束练习';

  @override
  String get drillRetryScoring => '重试评分';

  @override
  String get drillAnswerEmpty => '先写点内容再提交。';

  @override
  String get drillNoQuestion => '题库里还没有可练习的题目。';

  @override
  String get drillScoringFailed => '评分失败，但你的回答已保存。';

  @override
  String get drillScoreTitle => '本题评分';

  @override
  String drillTotal(Object score) {
    return '$score / 5';
  }

  @override
  String get drillCorrectness => '正确性';

  @override
  String get drillDepth => '深度';

  @override
  String get drillStructure => '结构';

  @override
  String drillCoverage(Object percent) {
    return '要点覆盖 $percent%';
  }

  @override
  String get drillVerdictHit => '命中';

  @override
  String get drillVerdictPartial => '部分';

  @override
  String get drillVerdictMiss => '缺失';

  @override
  String get drillVerdictNotAsked => '未问';

  @override
  String get drillEvidence => '证据';

  @override
  String get drillFactualErrors => '事实错误';

  @override
  String get drillDegraded => '评分官输出无法解析，本题已降级，仅保留原始说明。';

  @override
  String get drillAppeal => '这点我答了';

  @override
  String get drillAppealTitle => '提交申诉';

  @override
  String get drillAppealHint => '贴一句你的原话，作为校准集候选。';

  @override
  String get drillAppealSaved => '已记录，不会自动改分。';

  @override
  String get drillNeedQuestion => '请先加载题目。';

  @override
  String get failureBudget => '本场 token 预算已用完，请结束本场或调高上限。';

  @override
  String get settingsUsageSection => '用量';

  @override
  String settingsUsageTokens(Object used) {
    return '本月 tokens：$used';
  }

  @override
  String get settingsUsageEmpty => '本月还没有调用记录。';

  @override
  String get mockSetupTitle => '实战配置';

  @override
  String get mockRole => '岗位方向';

  @override
  String get mockLevel => '级别';

  @override
  String get mockLevelJunior => '初级';

  @override
  String get mockLevelMid => '中级';

  @override
  String get mockLevelSenior => '高级';

  @override
  String get mockLevelStaff => '专家';

  @override
  String get mockDuration => '时长';

  @override
  String mockDurationMinutes(Object minutes) {
    return '$minutes 分钟';
  }

  @override
  String get mockDifficulty => '题目难度';

  @override
  String get mockFollowupDepth => '追问层数';

  @override
  String get mockStyle => '面试官风格';

  @override
  String get mockStyleFriendly => '友善';

  @override
  String get mockStyleNeutral => '标准';

  @override
  String get mockStyleStress => '压力';

  @override
  String get mockAllowHints => '允许提示';

  @override
  String get mockStart => '开始面试';

  @override
  String get mockResume => '继续上次面试';

  @override
  String get mockPhaseWarmup => '热身';

  @override
  String get mockPhaseSelfIntro => '自我介绍';

  @override
  String get mockPhaseProject => '项目深挖';

  @override
  String get mockPhaseKnowledge => '知识';

  @override
  String get mockPhaseSystemDesign => '系统设计';

  @override
  String get mockPhaseClosing => '反问与收尾';

  @override
  String mockRemaining(Object time) {
    return '剩余 $time';
  }

  @override
  String get mockLiveTitle => '模拟面试';

  @override
  String get mockYourAnswer => '你的回答';

  @override
  String get mockSubmit => '提交回答';

  @override
  String get mockFinishEarly => '提前结束';

  @override
  String get mockEarlyFinishHint => '结束后会标注样本不足，报告仍会生成。';

  @override
  String get mockReportTitle => '面试报告';

  @override
  String get mockReportHeadline => '一句话结论';

  @override
  String get mockReportDimensions => '能力分布';

  @override
  String get mockReportNoTurns => '本场没有作答记录。';

  @override
  String get mockReportBackHome => '返回首页';

  @override
  String mockReportEarly(Object count) {
    return '本场提前结束，仅 $count 题，样本不足。';
  }

  @override
  String get mockReportPending => '部分题目仍在后台评分。';

  @override
  String mockQuestionPrefix(Object index) {
    return '第 $index 题：';
  }

  @override
  String mockNextPhase(Object phase) {
    return '进入$phase阶段。';
  }

  @override
  String get mockInterviewer => '面试官';

  @override
  String get mockYou => '你';

  @override
  String get mockNoQuestion => '没有可用题目，无法开始面试。';

  @override
  String get mockStartFailed => '创建会话失败，请稍后重试。';

  @override
  String get mockTimeUp => '时间到，进入收尾。';

  @override
  String get mockLoadingSession => '加载会话…';

  @override
  String get mockSessionMissing => '会话不存在或已结束。';

  @override
  String get mockScoringPending => '评分中…';

  @override
  String get mockInterviewerTyping => '面试官正在说…';

  @override
  String get reportWeakest => '薄弱主题';

  @override
  String get reportNoWeakness => '暂无明显短板';

  @override
  String get reportPlan => '7 天计划';

  @override
  String get reportInterviewerView => '面试官视角';

  @override
  String get reportExport => '导出 Markdown';

  @override
  String reportExported(Object path) {
    return '已导出到 $path';
  }

  @override
  String get reportExportFailed => '导出失败';

  @override
  String get reportDelete => '删除本场';

  @override
  String get reportDeleteConfirm => '删除本场报告？';

  @override
  String get reportDeleteBody => '会话、回答与记忆都会被删除，无法恢复。';

  @override
  String get reportTurnAnswer => '我的回答';

  @override
  String get reportMissedPoints => '建议补的要点';

  @override
  String get settingsRoleSearch => '联网核查（Tavily / OpenAI Search）';

  @override
  String get drillFactChecks => '联网核查';

  @override
  String get drillFactCheckSupported => '有来源支持';

  @override
  String get drillFactCheckContradicted => '与来源矛盾';

  @override
  String get drillFactCheckUnknown => '无法确定';

  @override
  String get drillFactCheckEvidence => '证据';

  @override
  String get settingsExportAppeals => '导出申诉候选';

  @override
  String settingsAppealsExported(Object path) {
    return '已导出到 $path';
  }

  @override
  String get settingsAppealsEmpty => '还没有申诉记录。';

  @override
  String get bankTopicsTitle => '主题分类';

  @override
  String get bankAllTopics => '全部主题';

  @override
  String bankTopicSelected(Object topic) {
    return '主题：$topic';
  }

  @override
  String get bankRelatedTitle => '相关题';

  @override
  String get settingsRoleTts => '语音播报（TTS）';

  @override
  String get mockInterviewerSpeaking => '面试官正在说…';

  @override
  String get mockMuteTts => '静音';

  @override
  String get mockUnmuteTts => '取消静音';

  @override
  String get bankNewQuestion => '新建题目';

  @override
  String get bankEditTitle => '题干';

  @override
  String get bankEditBody => '补充说明（可选）';

  @override
  String get bankEditTopics => '主题（逗号分隔）';

  @override
  String get bankEditRole => '岗位';

  @override
  String get bankEditLevel => '级别';

  @override
  String get bankEditDifficulty => '难度';

  @override
  String get bankEditType => '题型';

  @override
  String get bankEditAnswerSummary => '参考答案摘要';

  @override
  String get bankEditKeyPoints => '评分点（每行一条）';

  @override
  String get bankEditKeyPointsHint => '至少一条；评分只按这些判定';

  @override
  String get bankEditPitfalls => '常见误区（每行一条，可选）';

  @override
  String get bankEditFollowups => '追问（每行一条，可选）';

  @override
  String get bankEditSourceUrl => '来源 URL（可选）';

  @override
  String get bankEditSourceTitle => '来源标题';

  @override
  String get bankEditLicense => '许可';

  @override
  String get bankSave => '保存到我的题库';

  @override
  String get bankSaveSuccess => '已保存，可立即搜索到。';

  @override
  String get bankNeedTitle => '请填写题干。';

  @override
  String get bankNeedTopics => '请至少填写一个主题。';

  @override
  String get bankNeedKeyPoints => '请至少填写一个评分点。';

  @override
  String get bankDuplicateTitle => '疑似重复题目';

  @override
  String bankDuplicateBody(Object score, Object title) {
    return '与已有题目「$title」相似度 $score。仍要新增吗？';
  }

  @override
  String get bankDuplicateKeep => '仍然新增';

  @override
  String get bankTypeKnowledge => '知识';

  @override
  String get bankTypeBehavioral => '行为';

  @override
  String get bankTypeSystemDesign => '系统设计';

  @override
  String get bankTypeCoding => '编码';

  @override
  String get bankTypeProject => '项目';

  @override
  String get bankBulkImportTitle => '批量导入';

  @override
  String get bankBulkImportHint =>
      '粘贴 YAML / JSON / CSV / Markdown。\nCSV 表头支持 title, topics, keyPoints, sourceUrl…\nMarkdown 用 ## 标题 分块。';

  @override
  String bankBulkFormat(Object format) {
    return '格式：$format';
  }

  @override
  String bankBulkInvalidLine(Object line, Object message) {
    return '第 $line 行：$message';
  }

  @override
  String get bankBulkNeedValid => '存在无效行，修复后再导入。';

  @override
  String bankBulkSummary(
    Object conflict,
    Object invalid,
    Object total,
    Object valid,
  ) {
    return '共 $total 行：有效 $valid，无效 $invalid，冲突 $conflict';
  }

  @override
  String bankBulkCommit(Object count) {
    return '导入 $count 道';
  }

  @override
  String get bankRemoteTitle => '从 GitHub 导入';

  @override
  String get bankRemoteHint =>
      '粘贴 GitHub 仓库或单文件 URL（https://github.com/owner/repo）';

  @override
  String get bankRemotePreview => '获取预览';

  @override
  String bankRemoteLicense(Object license) {
    return '许可证：$license';
  }

  @override
  String bankRemoteSummary(
    Object conflict,
    Object files,
    Object invalid,
    Object valid,
  ) {
    return '$files 个文件 · 有效 $valid / 无效 $invalid / 冲突 $conflict';
  }

  @override
  String bankRemoteImport(Object count) {
    return '导入 $count 道';
  }

  @override
  String bankRemoteFailed(Object message) {
    return '导入失败：$message';
  }

  @override
  String get bankRemoteLoading => '正在获取仓库与许可证…';

  @override
  String get bankExperienceTitle => '从面经提取题目';

  @override
  String get bankExperienceHint => '粘贴面经/复盘长文，提取后人工勾选入库。';

  @override
  String get bankExperienceExtract => '提取草稿';

  @override
  String get bankExperienceNeedKey => '请先在设置中配置评分官 API key。';

  @override
  String get bankExperienceEmpty => '没有提取到可验证的题目，换一段文本再试。';

  @override
  String bankExperienceDrafts(Object count) {
    return '提取到 $count 道草稿，勾选后入库。';
  }

  @override
  String bankExperienceSave(Object count) {
    return '保存 $count 道';
  }

  @override
  String bankExperienceSaved(Object count, Object skipped) {
    return '已保存 $count 道（跳过 $skipped 道已存在）。';
  }

  @override
  String bankExperienceEvidence(Object evidence) {
    return '依据：$evidence';
  }

  @override
  String bankExperienceFailed(Object message) {
    return '提取失败：$message';
  }

  @override
  String get mockAvatarLabel => '小深';

  @override
  String get settingsSemanticSection => '语义检索（实验）';

  @override
  String get settingsSemanticHint => '本地 bge 模型；首次需重建索引。模型不可用时自动回退关键词检索。';

  @override
  String get settingsSemanticToggle => '启用语义检索';

  @override
  String get settingsRebuildIndex => '重建向量索引';

  @override
  String settingsIndexing(Object done, Object total) {
    return '正在建立索引… $done/$total';
  }

  @override
  String settingsIndexDone(Object count, Object ms) {
    return '索引完成：$count 道题，耗时 $ms ms';
  }

  @override
  String get settingsIndexUnavailable => '本地模型不可用，已保留关键词检索。';

  @override
  String settingsIndexFailed(Object message) {
    return '索引失败：$message';
  }

  @override
  String get settingsModelCheck => '模型自检';

  @override
  String settingsModelCheckResult(
    Object dim,
    Object ms,
    Object related,
    Object unrelated,
  ) {
    return '模型正常：$dim 维；相关 $related，无关 $unrelated；3 次嵌入 $ms ms';
  }

  @override
  String get settingsModelCheckUnavailable => '模型不可用，请检查资源包。';

  @override
  String settingsSaveFailed(Object reason) {
    return '保存失败：$reason';
  }

  @override
  String get settingsApiKeyStoredHint => '••••••••••••（已保存，输入新 key 可覆盖）';

  @override
  String get bankRoleMobile => '移动端';

  @override
  String get reviewEmpty => '还没有练习记录。完成一次练习或实战后，这里会出现逐题复盘。';

  @override
  String reviewSummary(Object avg, Object finished, Object total) {
    return '共 $total 场 · 已完成 $finished 场 · 平均分 $avg';
  }

  @override
  String get reviewModeDrill => '练习';

  @override
  String get reviewModeMock => '实战';

  @override
  String reviewTurns(Object count) {
    return '$count 题';
  }

  @override
  String get reviewOpenReport => '查看整场报告';

  @override
  String get reviewOpenDrill => '查看逐题复盘';

  @override
  String get reviewNoTurns => '这场还没有作答记录。';

  @override
  String get reviewStatusActive => '进行中';

  @override
  String get reviewStatusFinished => '已完成';

  @override
  String get reviewResume => '继续';

  @override
  String reviewScore(Object score) {
    return '得分 $score';
  }

  @override
  String get reviewNoScore => '未评分';

  @override
  String get reviewAnswer => '回答';

  @override
  String get reviewQuestion => '题目';

  @override
  String get reviewGoBank => '去题库';

  @override
  String get reportTurnsTitle => '逐题复盘';

  @override
  String get reviewTrendTitle => '分数趋势';

  @override
  String reviewTrendHint(Object count) {
    return '最近 $count 场（满分 5）';
  }

  @override
  String get reviewMasteryTitle => '主题掌握度';

  @override
  String get reviewNoStats => '再完成几场练习后，这里会显示趋势与主题掌握度。';

  @override
  String reviewMasteryPercent(Object percent) {
    return '$percent%';
  }

  @override
  String reviewMasterySamples(Object count) {
    return '$count 个评分点';
  }

  @override
  String get settingsSearchHint =>
      'Tavily 填 tavily-search；OpenAI 兼容搜索填 gpt-4o-mini-search-preview（Base URL 需带 /v1）';

  @override
  String homeSelectedCount(Object count) {
    return '已选 $count 项';
  }

  @override
  String get homeDeleteSelected => '删除所选';

  @override
  String get homeDeleteConfirmTitle => '删除所选记录？';

  @override
  String homeDeleteConfirmBody(Object count) {
    return '将删除 $count 场会话及其回答、评分与报告，无法恢复。';
  }

  @override
  String get homeDeleteAction => '删除';

  @override
  String get reviewStartDrill => '去练习';
}
