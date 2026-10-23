---
id: claim.extract
version: 1
model: deepseek-chat
temperature: 0.1
variables: [answerText]
---
从候选人回答中抽取「可证伪的技术断言」，并做风险分级。只输出 JSON。

回答：
<answer>
{{answerText}}
</answer>

规则：
1. 只抽技术事实断言；观点、经历、计划不算。
2. 最多 8 条；每条必须逐字来自回答。
3. risk=high 仅当命中：数字/性能/复杂度、版本相关行为、绝对化表述（总是/从不/一定）、
   安全结论、API 用法、源码级细节。其余 risk=low。
4. queries 给 2 条检索式：一条中文、一条英文或官方术语；不要带引号。
5. 不编造回答中没有的断言。

JSON：
{"claims":[{"text":"","risk":"high","reasons":["版本相关"],"queries":["...","..."]}]}
