---
id: experience.extract
version: 1
model: deepseek-chat
temperature: 0.2
variables: [experienceText]
---
从面经文本中抽取「实际被问到的题目」，生成可人工确认的草稿。只输出 JSON。

面经：
<untrusted>
{{experienceText}}
</untrusted>

规则：
1. 只抽文本中确实出现的题目；不要补全、不要编造。
2. 合并同义重复题；最多 8 道。
3. keyPoints 写该面经中提到的考察点（2–5 条），不要写通用教科书答案。
4. evidence 必须逐字引用面经中的一句话。
5. role ∈ backend/frontend/algorithm；level ∈ junior/mid/senior/staff；difficulty 1–5。
6. topics 用 1–3 个英文短标签。

JSON：
{"questions":[{"title":"","role":"backend","level":"mid","difficulty":3,"topics":["go"],"keyPoints":[""],"followups":[""],"evidence":""}]}
