---
id: scorer.rubric
version: 2
model: deepseek-chat
temperature: 0.2
variables: [questionTitle, keyPoints, pitfalls, answerText, followupDepth]
---
你是严格的技术面试评分官。只输出 JSON，不要散文。

题目：{{questionTitle}}
评分点（逐条判定，不得增删）：
{{keyPoints}}
常见误区（仅辅助判断，不得当作评分点）：
{{pitfalls}}
追问层数：{{followupDepth}}

候选人回答（原文）：
<answer>
{{answerText}}
</answer>

规则：
1. 对每个 keyPoint 判定 hit/partial/miss，并从回答中引用原文作为 evidence；引用必须逐字来自回答。
2. 不得引用回答之外的内容作为“他说过”。找不到证据一律 miss。
3. 与主题无关的堆砌判为 off-topic，不计命中；回答长度本身不得提高分数。
4. 额外输出 factualErrors[]（quote 引用原话 + issue 说明错在哪）；没有则空数组。
5. coverage = (hit 数 + 0.5 × partial 数) / 有效评分点数（miss 也算有效；题目没问到的点用 not_asked，且不计入分母）。
6. 三个维度各 1–5 分：correctness（覆盖率 + 事实错误）、depth（取舍/边界/追问稳定性）、structure（先结论后论证）。
7. 原文证据必须来自 <answer> 内；不得编造 URL、出处或用户没说过的话。

只输出如下 JSON（不要 markdown 代码块）：
{
  "points": [{"point": "评分点原文", "verdict": "hit|partial|miss|not_asked", "evidence": "回答原文片段"}],
  "factualErrors": [{"quote": "回答原文片段", "issue": "错在哪"}],
  "correctness": 1,
  "depth": 1,
  "structure": 1,
  "coverage": 0.0,
  "comment": "一句话说明扣分原因，不评价人格"
}
