# ADR-0004：小深形象先用 CustomPainter 状态机，Rive 资产后补

- 状态：已接受（临时）
- 日期：2026-10-22

## 背景

指南要求 T-063/T-064 使用 Rive 状态机（idle/listening/thinking/speaking），但仓库没有
`.riv` 资产，Agent 环境也无法用 Rive Editor 授权设计「小深」IP。阻塞 Rive 集成会连带
阻塞实战页的状态反馈。

## 决策

- T-064 先实现与 Rive 状态机同构的 `InterviewerAvatarState` 与 `InterviewerAvatar`
  （CustomPainter：呼吸、眨眼、说话口型、思考气泡、倾听表情）。
- 实战页按 `speaking > thinking > listening > idle` 映射，头像只做状态展示，不参与评分。
- T-063 保持未完成：正式 `.riv` 资产、Rive runtime、状态机输入替换后，再删除本临时实现。

## 后果

- 现在三端可用，无新增原生依赖。
- 视觉与 Rive 设计稿不一致；正式资产到位后需一次替换，接口不变。
- 不违反「形象不参与评分/不持久化人脸」的边界。
