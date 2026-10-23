import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_source.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';

const String _valid = '''
---
id: scorer.rubric
version: 2
model: deepseek-chat
temperature: 0.2
variables: [questionTitle, keyPoints]
---
题目：{{questionTitle}}
要点：{{keyPoints}}
''';

void main() {
  group('PromptTemplate', () {
    test('parses front-matter and renders variables', () {
      final template = PromptTemplate.parse(_valid, assetPath: 'a.md');
      expect(template.id, 'scorer.rubric');
      expect(template.version, 2);
      expect(template.model, 'deepseek-chat');
      expect(template.temperature, 0.2);
      expect(template.variables, <String>['questionTitle', 'keyPoints']);

      final rendered = template.render(<String, String>{
        'questionTitle': 'GMP 模型',
        'keyPoints': 'M/P 解耦',
      });
      expect(rendered, contains('题目：GMP 模型'));
      expect(rendered, isNot(contains('{{')));
    });

    test('throws with id and names when variables are missing or extra', () {
      final template = PromptTemplate.parse(_valid, assetPath: 'a.md');
      expect(
        () => template.render(<String, String>{'questionTitle': 'x'}),
        throwsA(
          isA<PromptVariableException>()
              .having(
                (PromptVariableException e) => e.promptId,
                'id',
                'scorer.rubric',
              )
              .having(
                (PromptVariableException e) => e.problems.join(),
                'problems',
                contains('keyPoints'),
              ),
        ),
      );
      expect(
        () => template.render(<String, String>{
          'questionTitle': 'x',
          'keyPoints': 'y',
          'extra': 'z',
        }),
        throwsA(isA<PromptVariableException>()),
      );
    });

    test('rejects undeclared placeholders and unused variables', () {
      const source = '''
---
id: x
version: 1
model: m
temperature: 0
variables: [a, b]
---
{{a}} {{c}}
''';
      expect(
        () => PromptTemplate.parse(source, assetPath: 'x.md'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed front-matter with path context', () {
      expect(
        () => PromptTemplate.parse('no front matter', assetPath: 'bad.md'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => PromptTemplate.parse(
          '---\nid: x\nversion: 0\nmodel: m\ntemperature: 0\nvariables: [a]\n---\n{{a}}',
          assetPath: 'bad.md',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PromptRegistry', () {
    test('loads all prompts and rejects duplicate ids', () async {
      final registry = await PromptRegistry.load(
        InMemoryPromptSource(<String, String>{
          'assets/prompts/a.md': _valid,
          'assets/prompts/b.md': _valid.replaceAll(
            'scorer.rubric',
            'interviewer.system',
          ),
        }),
      );
      expect(
        registry.byId.keys,
        containsAll(<String>['scorer.rubric', 'interviewer.system']),
      );

      expect(
        () => PromptRegistry.load(
          InMemoryPromptSource(<String, String>{
            'assets/prompts/a.md': _valid,
            'assets/prompts/b.md': _valid,
          }),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('missing prompt id fails loudly', () async {
      final registry = await PromptRegistry.load(
        InMemoryPromptSource(<String, String>{'assets/prompts/a.md': _valid}),
      );
      expect(() => registry.require('nope'), throwsStateError);
    });
  });

  test('checked-in prompt assets are valid', () async {
    final dir = Directory('assets/prompts');
    final files = dir.listSync().whereType<File>().where(
      (File f) => f.path.endsWith('.md'),
    );
    expect(files.length, greaterThanOrEqualTo(2));
    final source = InMemoryPromptSource(<String, String>{
      for (final file in files) file.path: await file.readAsString(),
    });
    final registry = await PromptRegistry.load(source, directory: dir.path);
    expect(
      registry.byId.keys,
      containsAll(<String>['interviewer.system', 'scorer.rubric']),
    );
  });
}
