// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const Setting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      Setting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProvidersTable extends Providers
    with TableInfo<$ProvidersTable, ProviderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMapMeta = const VerificationMeta(
    'modelMap',
  );
  @override
  late final GeneratedColumn<String> modelMap = GeneratedColumn<String>(
    'model_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _keyRefMeta = const VerificationMeta('keyRef');
  @override
  late final GeneratedColumn<String> keyRef = GeneratedColumn<String>(
    'key_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    baseUrl,
    modelMap,
    keyRef,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUrlMeta);
    }
    if (data.containsKey('model_map')) {
      context.handle(
        _modelMapMeta,
        modelMap.isAcceptableOrUnknown(data['model_map']!, _modelMapMeta),
      );
    }
    if (data.containsKey('key_ref')) {
      context.handle(
        _keyRefMeta,
        keyRef.isAcceptableOrUnknown(data['key_ref']!, _keyRefMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      )!,
      modelMap: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_map'],
      )!,
      keyRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_ref'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ProvidersTable createAlias(String alias) {
    return $ProvidersTable(attachedDatabase, alias);
  }
}

class ProviderRow extends DataClass implements Insertable<ProviderRow> {
  final String id;
  final String kind;
  final String baseUrl;
  final String modelMap;
  final String? keyRef;
  final bool enabled;
  const ProviderRow({
    required this.id,
    required this.kind,
    required this.baseUrl,
    required this.modelMap,
    this.keyRef,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['base_url'] = Variable<String>(baseUrl);
    map['model_map'] = Variable<String>(modelMap);
    if (!nullToAbsent || keyRef != null) {
      map['key_ref'] = Variable<String>(keyRef);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ProvidersCompanion toCompanion(bool nullToAbsent) {
    return ProvidersCompanion(
      id: Value(id),
      kind: Value(kind),
      baseUrl: Value(baseUrl),
      modelMap: Value(modelMap),
      keyRef: keyRef == null && nullToAbsent
          ? const Value.absent()
          : Value(keyRef),
      enabled: Value(enabled),
    );
  }

  factory ProviderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      baseUrl: serializer.fromJson<String>(json['baseUrl']),
      modelMap: serializer.fromJson<String>(json['modelMap']),
      keyRef: serializer.fromJson<String?>(json['keyRef']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'baseUrl': serializer.toJson<String>(baseUrl),
      'modelMap': serializer.toJson<String>(modelMap),
      'keyRef': serializer.toJson<String?>(keyRef),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ProviderRow copyWith({
    String? id,
    String? kind,
    String? baseUrl,
    String? modelMap,
    Value<String?> keyRef = const Value.absent(),
    bool? enabled,
  }) => ProviderRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    baseUrl: baseUrl ?? this.baseUrl,
    modelMap: modelMap ?? this.modelMap,
    keyRef: keyRef.present ? keyRef.value : this.keyRef,
    enabled: enabled ?? this.enabled,
  );
  ProviderRow copyWithCompanion(ProvidersCompanion data) {
    return ProviderRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      modelMap: data.modelMap.present ? data.modelMap.value : this.modelMap,
      keyRef: data.keyRef.present ? data.keyRef.value : this.keyRef,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('modelMap: $modelMap, ')
          ..write('keyRef: $keyRef, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, baseUrl, modelMap, keyRef, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.baseUrl == this.baseUrl &&
          other.modelMap == this.modelMap &&
          other.keyRef == this.keyRef &&
          other.enabled == this.enabled);
}

class ProvidersCompanion extends UpdateCompanion<ProviderRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> baseUrl;
  final Value<String> modelMap;
  final Value<String?> keyRef;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ProvidersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.modelMap = const Value.absent(),
    this.keyRef = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvidersCompanion.insert({
    required String id,
    required String kind,
    required String baseUrl,
    this.modelMap = const Value.absent(),
    this.keyRef = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       baseUrl = Value(baseUrl);
  static Insertable<ProviderRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? baseUrl,
    Expression<String>? modelMap,
    Expression<String>? keyRef,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (baseUrl != null) 'base_url': baseUrl,
      if (modelMap != null) 'model_map': modelMap,
      if (keyRef != null) 'key_ref': keyRef,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvidersCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? baseUrl,
    Value<String>? modelMap,
    Value<String?>? keyRef,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ProvidersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      baseUrl: baseUrl ?? this.baseUrl,
      modelMap: modelMap ?? this.modelMap,
      keyRef: keyRef ?? this.keyRef,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (modelMap.present) {
      map['model_map'] = Variable<String>(modelMap.value);
    }
    if (keyRef.present) {
      map['key_ref'] = Variable<String>(keyRef.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvidersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('modelMap: $modelMap, ')
          ..write('keyRef: $keyRef, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, QuestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankVersionMeta = const VerificationMeta(
    'bankVersion',
  );
  @override
  late final GeneratedColumn<String> bankVersion = GeneratedColumn<String>(
    'bank_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMdMeta = const VerificationMeta('bodyMd');
  @override
  late final GeneratedColumn<String> bodyMd = GeneratedColumn<String>(
    'body_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicsMeta = const VerificationMeta('topics');
  @override
  late final GeneratedColumn<String> topics = GeneratedColumn<String>(
    'topics',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('knowledge'),
  );
  static const VerificationMeta _answerJsonMeta = const VerificationMeta(
    'answerJson',
  );
  @override
  late final GeneratedColumn<String> answerJson = GeneratedColumn<String>(
    'answer_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _followupsJsonMeta = const VerificationMeta(
    'followupsJson',
  );
  @override
  late final GeneratedColumn<String> followupsJson = GeneratedColumn<String>(
    'followups_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('community'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankVersion,
    title,
    bodyMd,
    topics,
    role,
    level,
    difficulty,
    type,
    answerJson,
    followupsJson,
    sourceUrl,
    license,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bank_version')) {
      context.handle(
        _bankVersionMeta,
        bankVersion.isAcceptableOrUnknown(
          data['bank_version']!,
          _bankVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bankVersionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body_md')) {
      context.handle(
        _bodyMdMeta,
        bodyMd.isAcceptableOrUnknown(data['body_md']!, _bodyMdMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMdMeta);
    }
    if (data.containsKey('topics')) {
      context.handle(
        _topicsMeta,
        topics.isAcceptableOrUnknown(data['topics']!, _topicsMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('answer_json')) {
      context.handle(
        _answerJsonMeta,
        answerJson.isAcceptableOrUnknown(data['answer_json']!, _answerJsonMeta),
      );
    }
    if (data.containsKey('followups_json')) {
      context.handle(
        _followupsJsonMeta,
        followupsJson.isAcceptableOrUnknown(
          data['followups_json']!,
          _followupsJsonMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bankVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bodyMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_md'],
      )!,
      topics: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      answerJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_json'],
      )!,
      followupsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}followups_json'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class QuestionRow extends DataClass implements Insertable<QuestionRow> {
  final String id;
  final String bankVersion;
  final String title;
  final String bodyMd;
  final String topics;
  final String role;
  final int level;
  final int difficulty;
  final String type;
  final String answerJson;
  final String followupsJson;
  final String? sourceUrl;
  final String? license;
  final String status;
  final DateTime updatedAt;
  const QuestionRow({
    required this.id,
    required this.bankVersion,
    required this.title,
    required this.bodyMd,
    required this.topics,
    required this.role,
    required this.level,
    required this.difficulty,
    required this.type,
    required this.answerJson,
    required this.followupsJson,
    this.sourceUrl,
    this.license,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bank_version'] = Variable<String>(bankVersion);
    map['title'] = Variable<String>(title);
    map['body_md'] = Variable<String>(bodyMd);
    map['topics'] = Variable<String>(topics);
    map['role'] = Variable<String>(role);
    map['level'] = Variable<int>(level);
    map['difficulty'] = Variable<int>(difficulty);
    map['type'] = Variable<String>(type);
    map['answer_json'] = Variable<String>(answerJson);
    map['followups_json'] = Variable<String>(followupsJson);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      bankVersion: Value(bankVersion),
      title: Value(title),
      bodyMd: Value(bodyMd),
      topics: Value(topics),
      role: Value(role),
      level: Value(level),
      difficulty: Value(difficulty),
      type: Value(type),
      answerJson: Value(answerJson),
      followupsJson: Value(followupsJson),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionRow(
      id: serializer.fromJson<String>(json['id']),
      bankVersion: serializer.fromJson<String>(json['bankVersion']),
      title: serializer.fromJson<String>(json['title']),
      bodyMd: serializer.fromJson<String>(json['bodyMd']),
      topics: serializer.fromJson<String>(json['topics']),
      role: serializer.fromJson<String>(json['role']),
      level: serializer.fromJson<int>(json['level']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      type: serializer.fromJson<String>(json['type']),
      answerJson: serializer.fromJson<String>(json['answerJson']),
      followupsJson: serializer.fromJson<String>(json['followupsJson']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      license: serializer.fromJson<String?>(json['license']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bankVersion': serializer.toJson<String>(bankVersion),
      'title': serializer.toJson<String>(title),
      'bodyMd': serializer.toJson<String>(bodyMd),
      'topics': serializer.toJson<String>(topics),
      'role': serializer.toJson<String>(role),
      'level': serializer.toJson<int>(level),
      'difficulty': serializer.toJson<int>(difficulty),
      'type': serializer.toJson<String>(type),
      'answerJson': serializer.toJson<String>(answerJson),
      'followupsJson': serializer.toJson<String>(followupsJson),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'license': serializer.toJson<String?>(license),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuestionRow copyWith({
    String? id,
    String? bankVersion,
    String? title,
    String? bodyMd,
    String? topics,
    String? role,
    int? level,
    int? difficulty,
    String? type,
    String? answerJson,
    String? followupsJson,
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> license = const Value.absent(),
    String? status,
    DateTime? updatedAt,
  }) => QuestionRow(
    id: id ?? this.id,
    bankVersion: bankVersion ?? this.bankVersion,
    title: title ?? this.title,
    bodyMd: bodyMd ?? this.bodyMd,
    topics: topics ?? this.topics,
    role: role ?? this.role,
    level: level ?? this.level,
    difficulty: difficulty ?? this.difficulty,
    type: type ?? this.type,
    answerJson: answerJson ?? this.answerJson,
    followupsJson: followupsJson ?? this.followupsJson,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    license: license.present ? license.value : this.license,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuestionRow copyWithCompanion(QuestionsCompanion data) {
    return QuestionRow(
      id: data.id.present ? data.id.value : this.id,
      bankVersion: data.bankVersion.present
          ? data.bankVersion.value
          : this.bankVersion,
      title: data.title.present ? data.title.value : this.title,
      bodyMd: data.bodyMd.present ? data.bodyMd.value : this.bodyMd,
      topics: data.topics.present ? data.topics.value : this.topics,
      role: data.role.present ? data.role.value : this.role,
      level: data.level.present ? data.level.value : this.level,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      type: data.type.present ? data.type.value : this.type,
      answerJson: data.answerJson.present
          ? data.answerJson.value
          : this.answerJson,
      followupsJson: data.followupsJson.present
          ? data.followupsJson.value
          : this.followupsJson,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      license: data.license.present ? data.license.value : this.license,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionRow(')
          ..write('id: $id, ')
          ..write('bankVersion: $bankVersion, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('topics: $topics, ')
          ..write('role: $role, ')
          ..write('level: $level, ')
          ..write('difficulty: $difficulty, ')
          ..write('type: $type, ')
          ..write('answerJson: $answerJson, ')
          ..write('followupsJson: $followupsJson, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('license: $license, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankVersion,
    title,
    bodyMd,
    topics,
    role,
    level,
    difficulty,
    type,
    answerJson,
    followupsJson,
    sourceUrl,
    license,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionRow &&
          other.id == this.id &&
          other.bankVersion == this.bankVersion &&
          other.title == this.title &&
          other.bodyMd == this.bodyMd &&
          other.topics == this.topics &&
          other.role == this.role &&
          other.level == this.level &&
          other.difficulty == this.difficulty &&
          other.type == this.type &&
          other.answerJson == this.answerJson &&
          other.followupsJson == this.followupsJson &&
          other.sourceUrl == this.sourceUrl &&
          other.license == this.license &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class QuestionsCompanion extends UpdateCompanion<QuestionRow> {
  final Value<String> id;
  final Value<String> bankVersion;
  final Value<String> title;
  final Value<String> bodyMd;
  final Value<String> topics;
  final Value<String> role;
  final Value<int> level;
  final Value<int> difficulty;
  final Value<String> type;
  final Value<String> answerJson;
  final Value<String> followupsJson;
  final Value<String?> sourceUrl;
  final Value<String?> license;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.bankVersion = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyMd = const Value.absent(),
    this.topics = const Value.absent(),
    this.role = const Value.absent(),
    this.level = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.type = const Value.absent(),
    this.answerJson = const Value.absent(),
    this.followupsJson = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.license = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String id,
    required String bankVersion,
    required String title,
    required String bodyMd,
    this.topics = const Value.absent(),
    required String role,
    this.level = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.type = const Value.absent(),
    this.answerJson = const Value.absent(),
    this.followupsJson = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.license = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bankVersion = Value(bankVersion),
       title = Value(title),
       bodyMd = Value(bodyMd),
       role = Value(role),
       updatedAt = Value(updatedAt);
  static Insertable<QuestionRow> custom({
    Expression<String>? id,
    Expression<String>? bankVersion,
    Expression<String>? title,
    Expression<String>? bodyMd,
    Expression<String>? topics,
    Expression<String>? role,
    Expression<int>? level,
    Expression<int>? difficulty,
    Expression<String>? type,
    Expression<String>? answerJson,
    Expression<String>? followupsJson,
    Expression<String>? sourceUrl,
    Expression<String>? license,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankVersion != null) 'bank_version': bankVersion,
      if (title != null) 'title': title,
      if (bodyMd != null) 'body_md': bodyMd,
      if (topics != null) 'topics': topics,
      if (role != null) 'role': role,
      if (level != null) 'level': level,
      if (difficulty != null) 'difficulty': difficulty,
      if (type != null) 'type': type,
      if (answerJson != null) 'answer_json': answerJson,
      if (followupsJson != null) 'followups_json': followupsJson,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (license != null) 'license': license,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? bankVersion,
    Value<String>? title,
    Value<String>? bodyMd,
    Value<String>? topics,
    Value<String>? role,
    Value<int>? level,
    Value<int>? difficulty,
    Value<String>? type,
    Value<String>? answerJson,
    Value<String>? followupsJson,
    Value<String?>? sourceUrl,
    Value<String?>? license,
    Value<String>? status,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      bankVersion: bankVersion ?? this.bankVersion,
      title: title ?? this.title,
      bodyMd: bodyMd ?? this.bodyMd,
      topics: topics ?? this.topics,
      role: role ?? this.role,
      level: level ?? this.level,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      answerJson: answerJson ?? this.answerJson,
      followupsJson: followupsJson ?? this.followupsJson,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      license: license ?? this.license,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bankVersion.present) {
      map['bank_version'] = Variable<String>(bankVersion.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bodyMd.present) {
      map['body_md'] = Variable<String>(bodyMd.value);
    }
    if (topics.present) {
      map['topics'] = Variable<String>(topics.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (answerJson.present) {
      map['answer_json'] = Variable<String>(answerJson.value);
    }
    if (followupsJson.present) {
      map['followups_json'] = Variable<String>(followupsJson.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('bankVersion: $bankVersion, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('topics: $topics, ')
          ..write('role: $role, ')
          ..write('level: $level, ')
          ..write('difficulty: $difficulty, ')
          ..write('type: $type, ')
          ..write('answerJson: $answerJson, ')
          ..write('followupsJson: $followupsJson, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('license: $license, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionLocalTable extends QuestionLocal
    with TableInfo<$QuestionLocalTable, QuestionLocalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMdMeta = const VerificationMeta('noteMd');
  @override
  late final GeneratedColumn<String> noteMd = GeneratedColumn<String>(
    'note_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _starredMeta = const VerificationMeta(
    'starred',
  );
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
    'starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bank'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    noteMd,
    starred,
    hidden,
    origin,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionLocalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('note_md')) {
      context.handle(
        _noteMdMeta,
        noteMd.isAcceptableOrUnknown(data['note_md']!, _noteMdMeta),
      );
    }
    if (data.containsKey('starred')) {
      context.handle(
        _starredMeta,
        starred.isAcceptableOrUnknown(data['starred']!, _starredMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  QuestionLocalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionLocalRow(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      noteMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_md'],
      )!,
      starred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}starred'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuestionLocalTable createAlias(String alias) {
    return $QuestionLocalTable(attachedDatabase, alias);
  }
}

class QuestionLocalRow extends DataClass
    implements Insertable<QuestionLocalRow> {
  final String questionId;
  final String noteMd;
  final bool starred;
  final bool hidden;

  /// `bank`（覆盖上游）或 `user`（用户自建，指南 §7.1.1）。
  final String origin;
  final DateTime updatedAt;
  const QuestionLocalRow({
    required this.questionId,
    required this.noteMd,
    required this.starred,
    required this.hidden,
    required this.origin,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['note_md'] = Variable<String>(noteMd);
    map['starred'] = Variable<bool>(starred);
    map['hidden'] = Variable<bool>(hidden);
    map['origin'] = Variable<String>(origin);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuestionLocalCompanion toCompanion(bool nullToAbsent) {
    return QuestionLocalCompanion(
      questionId: Value(questionId),
      noteMd: Value(noteMd),
      starred: Value(starred),
      hidden: Value(hidden),
      origin: Value(origin),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionLocalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionLocalRow(
      questionId: serializer.fromJson<String>(json['questionId']),
      noteMd: serializer.fromJson<String>(json['noteMd']),
      starred: serializer.fromJson<bool>(json['starred']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      origin: serializer.fromJson<String>(json['origin']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'noteMd': serializer.toJson<String>(noteMd),
      'starred': serializer.toJson<bool>(starred),
      'hidden': serializer.toJson<bool>(hidden),
      'origin': serializer.toJson<String>(origin),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuestionLocalRow copyWith({
    String? questionId,
    String? noteMd,
    bool? starred,
    bool? hidden,
    String? origin,
    DateTime? updatedAt,
  }) => QuestionLocalRow(
    questionId: questionId ?? this.questionId,
    noteMd: noteMd ?? this.noteMd,
    starred: starred ?? this.starred,
    hidden: hidden ?? this.hidden,
    origin: origin ?? this.origin,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuestionLocalRow copyWithCompanion(QuestionLocalCompanion data) {
    return QuestionLocalRow(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      noteMd: data.noteMd.present ? data.noteMd.value : this.noteMd,
      starred: data.starred.present ? data.starred.value : this.starred,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      origin: data.origin.present ? data.origin.value : this.origin,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionLocalRow(')
          ..write('questionId: $questionId, ')
          ..write('noteMd: $noteMd, ')
          ..write('starred: $starred, ')
          ..write('hidden: $hidden, ')
          ..write('origin: $origin, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(questionId, noteMd, starred, hidden, origin, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionLocalRow &&
          other.questionId == this.questionId &&
          other.noteMd == this.noteMd &&
          other.starred == this.starred &&
          other.hidden == this.hidden &&
          other.origin == this.origin &&
          other.updatedAt == this.updatedAt);
}

class QuestionLocalCompanion extends UpdateCompanion<QuestionLocalRow> {
  final Value<String> questionId;
  final Value<String> noteMd;
  final Value<bool> starred;
  final Value<bool> hidden;
  final Value<String> origin;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuestionLocalCompanion({
    this.questionId = const Value.absent(),
    this.noteMd = const Value.absent(),
    this.starred = const Value.absent(),
    this.hidden = const Value.absent(),
    this.origin = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionLocalCompanion.insert({
    required String questionId,
    this.noteMd = const Value.absent(),
    this.starred = const Value.absent(),
    this.hidden = const Value.absent(),
    this.origin = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       updatedAt = Value(updatedAt);
  static Insertable<QuestionLocalRow> custom({
    Expression<String>? questionId,
    Expression<String>? noteMd,
    Expression<bool>? starred,
    Expression<bool>? hidden,
    Expression<String>? origin,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (noteMd != null) 'note_md': noteMd,
      if (starred != null) 'starred': starred,
      if (hidden != null) 'hidden': hidden,
      if (origin != null) 'origin': origin,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionLocalCompanion copyWith({
    Value<String>? questionId,
    Value<String>? noteMd,
    Value<bool>? starred,
    Value<bool>? hidden,
    Value<String>? origin,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuestionLocalCompanion(
      questionId: questionId ?? this.questionId,
      noteMd: noteMd ?? this.noteMd,
      starred: starred ?? this.starred,
      hidden: hidden ?? this.hidden,
      origin: origin ?? this.origin,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (noteMd.present) {
      map['note_md'] = Variable<String>(noteMd.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionLocalCompanion(')
          ..write('questionId: $questionId, ')
          ..write('noteMd: $noteMd, ')
          ..write('starred: $starred, ')
          ..write('hidden: $hidden, ')
          ..write('origin: $origin, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperiencesTable extends Experiences
    with TableInfo<$ExperiencesTable, Experience> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperiencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<String> round = GeneratedColumn<String>(
    'round',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMdMeta = const VerificationMeta(
    'summaryMd',
  );
  @override
  late final GeneratedColumn<String> summaryMd = GeneratedColumn<String>(
    'summary_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _questionsJsonMeta = const VerificationMeta(
    'questionsJson',
  );
  @override
  late final GeneratedColumn<String> questionsJson = GeneratedColumn<String>(
    'questions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _credibilityMeta = const VerificationMeta(
    'credibility',
  );
  @override
  late final GeneratedColumn<String> credibility = GeneratedColumn<String>(
    'credibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    company,
    role,
    round,
    date,
    sourceUrl,
    summaryMd,
    questionsJson,
    credibility,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Experience> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('summary_md')) {
      context.handle(
        _summaryMdMeta,
        summaryMd.isAcceptableOrUnknown(data['summary_md']!, _summaryMdMeta),
      );
    }
    if (data.containsKey('questions_json')) {
      context.handle(
        _questionsJsonMeta,
        questionsJson.isAcceptableOrUnknown(
          data['questions_json']!,
          _questionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('credibility')) {
      context.handle(
        _credibilityMeta,
        credibility.isAcceptableOrUnknown(
          data['credibility']!,
          _credibilityMeta,
        ),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Experience map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Experience(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      summaryMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_md'],
      )!,
      questionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}questions_json'],
      )!,
      credibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credibility'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ExperiencesTable createAlias(String alias) {
    return $ExperiencesTable(attachedDatabase, alias);
  }
}

class Experience extends DataClass implements Insertable<Experience> {
  final String id;
  final String company;
  final String role;
  final String round;
  final DateTime? date;
  final String? sourceUrl;
  final String summaryMd;
  final String questionsJson;
  final String credibility;
  final DateTime fetchedAt;
  const Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.round,
    this.date,
    this.sourceUrl,
    required this.summaryMd,
    required this.questionsJson,
    required this.credibility,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company'] = Variable<String>(company);
    map['role'] = Variable<String>(role);
    map['round'] = Variable<String>(round);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['summary_md'] = Variable<String>(summaryMd);
    map['questions_json'] = Variable<String>(questionsJson);
    map['credibility'] = Variable<String>(credibility);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ExperiencesCompanion toCompanion(bool nullToAbsent) {
    return ExperiencesCompanion(
      id: Value(id),
      company: Value(company),
      role: Value(role),
      round: Value(round),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      summaryMd: Value(summaryMd),
      questionsJson: Value(questionsJson),
      credibility: Value(credibility),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory Experience.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Experience(
      id: serializer.fromJson<String>(json['id']),
      company: serializer.fromJson<String>(json['company']),
      role: serializer.fromJson<String>(json['role']),
      round: serializer.fromJson<String>(json['round']),
      date: serializer.fromJson<DateTime?>(json['date']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      summaryMd: serializer.fromJson<String>(json['summaryMd']),
      questionsJson: serializer.fromJson<String>(json['questionsJson']),
      credibility: serializer.fromJson<String>(json['credibility']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'company': serializer.toJson<String>(company),
      'role': serializer.toJson<String>(role),
      'round': serializer.toJson<String>(round),
      'date': serializer.toJson<DateTime?>(date),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'summaryMd': serializer.toJson<String>(summaryMd),
      'questionsJson': serializer.toJson<String>(questionsJson),
      'credibility': serializer.toJson<String>(credibility),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  Experience copyWith({
    String? id,
    String? company,
    String? role,
    String? round,
    Value<DateTime?> date = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    String? summaryMd,
    String? questionsJson,
    String? credibility,
    DateTime? fetchedAt,
  }) => Experience(
    id: id ?? this.id,
    company: company ?? this.company,
    role: role ?? this.role,
    round: round ?? this.round,
    date: date.present ? date.value : this.date,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    summaryMd: summaryMd ?? this.summaryMd,
    questionsJson: questionsJson ?? this.questionsJson,
    credibility: credibility ?? this.credibility,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  Experience copyWithCompanion(ExperiencesCompanion data) {
    return Experience(
      id: data.id.present ? data.id.value : this.id,
      company: data.company.present ? data.company.value : this.company,
      role: data.role.present ? data.role.value : this.role,
      round: data.round.present ? data.round.value : this.round,
      date: data.date.present ? data.date.value : this.date,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      summaryMd: data.summaryMd.present ? data.summaryMd.value : this.summaryMd,
      questionsJson: data.questionsJson.present
          ? data.questionsJson.value
          : this.questionsJson,
      credibility: data.credibility.present
          ? data.credibility.value
          : this.credibility,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Experience(')
          ..write('id: $id, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('round: $round, ')
          ..write('date: $date, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('summaryMd: $summaryMd, ')
          ..write('questionsJson: $questionsJson, ')
          ..write('credibility: $credibility, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    company,
    role,
    round,
    date,
    sourceUrl,
    summaryMd,
    questionsJson,
    credibility,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Experience &&
          other.id == this.id &&
          other.company == this.company &&
          other.role == this.role &&
          other.round == this.round &&
          other.date == this.date &&
          other.sourceUrl == this.sourceUrl &&
          other.summaryMd == this.summaryMd &&
          other.questionsJson == this.questionsJson &&
          other.credibility == this.credibility &&
          other.fetchedAt == this.fetchedAt);
}

class ExperiencesCompanion extends UpdateCompanion<Experience> {
  final Value<String> id;
  final Value<String> company;
  final Value<String> role;
  final Value<String> round;
  final Value<DateTime?> date;
  final Value<String?> sourceUrl;
  final Value<String> summaryMd;
  final Value<String> questionsJson;
  final Value<String> credibility;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ExperiencesCompanion({
    this.id = const Value.absent(),
    this.company = const Value.absent(),
    this.role = const Value.absent(),
    this.round = const Value.absent(),
    this.date = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.summaryMd = const Value.absent(),
    this.questionsJson = const Value.absent(),
    this.credibility = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperiencesCompanion.insert({
    required String id,
    this.company = const Value.absent(),
    this.role = const Value.absent(),
    this.round = const Value.absent(),
    this.date = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.summaryMd = const Value.absent(),
    this.questionsJson = const Value.absent(),
    this.credibility = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fetchedAt = Value(fetchedAt);
  static Insertable<Experience> custom({
    Expression<String>? id,
    Expression<String>? company,
    Expression<String>? role,
    Expression<String>? round,
    Expression<DateTime>? date,
    Expression<String>? sourceUrl,
    Expression<String>? summaryMd,
    Expression<String>? questionsJson,
    Expression<String>? credibility,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (company != null) 'company': company,
      if (role != null) 'role': role,
      if (round != null) 'round': round,
      if (date != null) 'date': date,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (summaryMd != null) 'summary_md': summaryMd,
      if (questionsJson != null) 'questions_json': questionsJson,
      if (credibility != null) 'credibility': credibility,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperiencesCompanion copyWith({
    Value<String>? id,
    Value<String>? company,
    Value<String>? role,
    Value<String>? round,
    Value<DateTime?>? date,
    Value<String?>? sourceUrl,
    Value<String>? summaryMd,
    Value<String>? questionsJson,
    Value<String>? credibility,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ExperiencesCompanion(
      id: id ?? this.id,
      company: company ?? this.company,
      role: role ?? this.role,
      round: round ?? this.round,
      date: date ?? this.date,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      summaryMd: summaryMd ?? this.summaryMd,
      questionsJson: questionsJson ?? this.questionsJson,
      credibility: credibility ?? this.credibility,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (round.present) {
      map['round'] = Variable<String>(round.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (summaryMd.present) {
      map['summary_md'] = Variable<String>(summaryMd.value);
    }
    if (questionsJson.present) {
      map['questions_json'] = Variable<String>(questionsJson.value);
    }
    if (credibility.present) {
      map['credibility'] = Variable<String>(credibility.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperiencesCompanion(')
          ..write('id: $id, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('round: $round, ')
          ..write('date: $date, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('summaryMd: $summaryMd, ')
          ..write('questionsJson: $questionsJson, ')
          ..write('credibility: $credibility, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _totalScoreMeta = const VerificationMeta(
    'totalScore',
  );
  @override
  late final GeneratedColumn<double> totalScore = GeneratedColumn<double>(
    'total_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    configJson,
    startedAt,
    endedAt,
    status,
    totalScore,
    cost,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_score')) {
      context.handle(
        _totalScoreMeta,
        totalScore.isAcceptableOrUnknown(data['total_score']!, _totalScoreMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_score'],
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String mode;
  final String configJson;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final double? totalScore;
  final double cost;
  const SessionRow({
    required this.id,
    required this.mode,
    required this.configJson,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.totalScore,
    required this.cost,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mode'] = Variable<String>(mode);
    map['config_json'] = Variable<String>(configJson);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || totalScore != null) {
      map['total_score'] = Variable<double>(totalScore);
    }
    map['cost'] = Variable<double>(cost);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      mode: Value(mode),
      configJson: Value(configJson),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      totalScore: totalScore == null && nullToAbsent
          ? const Value.absent()
          : Value(totalScore),
      cost: Value(cost),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      configJson: serializer.fromJson<String>(json['configJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      totalScore: serializer.fromJson<double?>(json['totalScore']),
      cost: serializer.fromJson<double>(json['cost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mode': serializer.toJson<String>(mode),
      'configJson': serializer.toJson<String>(configJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'totalScore': serializer.toJson<double?>(totalScore),
      'cost': serializer.toJson<double>(cost),
    };
  }

  SessionRow copyWith({
    String? id,
    String? mode,
    String? configJson,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    Value<double?> totalScore = const Value.absent(),
    double? cost,
  }) => SessionRow(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    configJson: configJson ?? this.configJson,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    totalScore: totalScore.present ? totalScore.value : this.totalScore,
    cost: cost ?? this.cost,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      totalScore: data.totalScore.present
          ? data.totalScore.value
          : this.totalScore,
      cost: data.cost.present ? data.cost.value : this.cost,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('configJson: $configJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('totalScore: $totalScore, ')
          ..write('cost: $cost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    configJson,
    startedAt,
    endedAt,
    status,
    totalScore,
    cost,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.configJson == this.configJson &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.totalScore == this.totalScore &&
          other.cost == this.cost);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> mode;
  final Value<String> configJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<double?> totalScore;
  final Value<double> cost;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.configJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.cost = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String mode,
    required String configJson,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.cost = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mode = Value(mode),
       configJson = Value(configJson),
       startedAt = Value(startedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? mode,
    Expression<String>? configJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<double>? totalScore,
    Expression<double>? cost,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (configJson != null) 'config_json': configJson,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (totalScore != null) 'total_score': totalScore,
      if (cost != null) 'cost': cost,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? mode,
    Value<String>? configJson,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<double?>? totalScore,
    Value<double>? cost,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      configJson: configJson ?? this.configJson,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      totalScore: totalScore ?? this.totalScore,
      cost: cost ?? this.cost,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<double>(totalScore.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('configJson: $configJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('totalScore: $totalScore, ')
          ..write('cost: $cost, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TurnsTable extends Turns with TableInfo<$TurnsTable, TurnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _answerTextMeta = const VerificationMeta(
    'answerText',
  );
  @override
  late final GeneratedColumn<String> answerText = GeneratedColumn<String>(
    'answer_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tStartedAtMeta = const VerificationMeta(
    'tStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> tStartedAt = GeneratedColumn<DateTime>(
    't_started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tSubmittedAtMeta = const VerificationMeta(
    'tSubmittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> tSubmittedAt = GeneratedColumn<DateTime>(
    't_submitted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreJsonMeta = const VerificationMeta(
    'scoreJson',
  );
  @override
  late final GeneratedColumn<String> scoreJson = GeneratedColumn<String>(
    'score_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    seq,
    questionId,
    questionText,
    answerText,
    tStartedAt,
    tSubmittedAt,
    scoreJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns';
  @override
  VerificationContext validateIntegrity(
    Insertable<TurnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    }
    if (data.containsKey('answer_text')) {
      context.handle(
        _answerTextMeta,
        answerText.isAcceptableOrUnknown(data['answer_text']!, _answerTextMeta),
      );
    }
    if (data.containsKey('t_started_at')) {
      context.handle(
        _tStartedAtMeta,
        tStartedAt.isAcceptableOrUnknown(
          data['t_started_at']!,
          _tStartedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tStartedAtMeta);
    }
    if (data.containsKey('t_submitted_at')) {
      context.handle(
        _tSubmittedAtMeta,
        tSubmittedAt.isAcceptableOrUnknown(
          data['t_submitted_at']!,
          _tSubmittedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tSubmittedAtMeta);
    }
    if (data.containsKey('score_json')) {
      context.handle(
        _scoreJsonMeta,
        scoreJson.isAcceptableOrUnknown(data['score_json']!, _scoreJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TurnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TurnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      ),
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      answerText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_text'],
      )!,
      tStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}t_started_at'],
      )!,
      tSubmittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}t_submitted_at'],
      )!,
      scoreJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}score_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TurnsTable createAlias(String alias) {
    return $TurnsTable(attachedDatabase, alias);
  }
}

class TurnRow extends DataClass implements Insertable<TurnRow> {
  final String id;
  final String sessionId;
  final int seq;
  final String? questionId;
  final String questionText;
  final String answerText;
  final DateTime tStartedAt;
  final DateTime tSubmittedAt;
  final String? scoreJson;
  final DateTime createdAt;
  const TurnRow({
    required this.id,
    required this.sessionId,
    required this.seq,
    this.questionId,
    required this.questionText,
    required this.answerText,
    required this.tStartedAt,
    required this.tSubmittedAt,
    this.scoreJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['seq'] = Variable<int>(seq);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<String>(questionId);
    }
    map['question_text'] = Variable<String>(questionText);
    map['answer_text'] = Variable<String>(answerText);
    map['t_started_at'] = Variable<DateTime>(tStartedAt);
    map['t_submitted_at'] = Variable<DateTime>(tSubmittedAt);
    if (!nullToAbsent || scoreJson != null) {
      map['score_json'] = Variable<String>(scoreJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TurnsCompanion toCompanion(bool nullToAbsent) {
    return TurnsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      seq: Value(seq),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      questionText: Value(questionText),
      answerText: Value(answerText),
      tStartedAt: Value(tStartedAt),
      tSubmittedAt: Value(tSubmittedAt),
      scoreJson: scoreJson == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreJson),
      createdAt: Value(createdAt),
    );
  }

  factory TurnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TurnRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      seq: serializer.fromJson<int>(json['seq']),
      questionId: serializer.fromJson<String?>(json['questionId']),
      questionText: serializer.fromJson<String>(json['questionText']),
      answerText: serializer.fromJson<String>(json['answerText']),
      tStartedAt: serializer.fromJson<DateTime>(json['tStartedAt']),
      tSubmittedAt: serializer.fromJson<DateTime>(json['tSubmittedAt']),
      scoreJson: serializer.fromJson<String?>(json['scoreJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'seq': serializer.toJson<int>(seq),
      'questionId': serializer.toJson<String?>(questionId),
      'questionText': serializer.toJson<String>(questionText),
      'answerText': serializer.toJson<String>(answerText),
      'tStartedAt': serializer.toJson<DateTime>(tStartedAt),
      'tSubmittedAt': serializer.toJson<DateTime>(tSubmittedAt),
      'scoreJson': serializer.toJson<String?>(scoreJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TurnRow copyWith({
    String? id,
    String? sessionId,
    int? seq,
    Value<String?> questionId = const Value.absent(),
    String? questionText,
    String? answerText,
    DateTime? tStartedAt,
    DateTime? tSubmittedAt,
    Value<String?> scoreJson = const Value.absent(),
    DateTime? createdAt,
  }) => TurnRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    seq: seq ?? this.seq,
    questionId: questionId.present ? questionId.value : this.questionId,
    questionText: questionText ?? this.questionText,
    answerText: answerText ?? this.answerText,
    tStartedAt: tStartedAt ?? this.tStartedAt,
    tSubmittedAt: tSubmittedAt ?? this.tSubmittedAt,
    scoreJson: scoreJson.present ? scoreJson.value : this.scoreJson,
    createdAt: createdAt ?? this.createdAt,
  );
  TurnRow copyWithCompanion(TurnsCompanion data) {
    return TurnRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      seq: data.seq.present ? data.seq.value : this.seq,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      answerText: data.answerText.present
          ? data.answerText.value
          : this.answerText,
      tStartedAt: data.tStartedAt.present
          ? data.tStartedAt.value
          : this.tStartedAt,
      tSubmittedAt: data.tSubmittedAt.present
          ? data.tSubmittedAt.value
          : this.tSubmittedAt,
      scoreJson: data.scoreJson.present ? data.scoreJson.value : this.scoreJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TurnRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('seq: $seq, ')
          ..write('questionId: $questionId, ')
          ..write('questionText: $questionText, ')
          ..write('answerText: $answerText, ')
          ..write('tStartedAt: $tStartedAt, ')
          ..write('tSubmittedAt: $tSubmittedAt, ')
          ..write('scoreJson: $scoreJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    seq,
    questionId,
    questionText,
    answerText,
    tStartedAt,
    tSubmittedAt,
    scoreJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TurnRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.seq == this.seq &&
          other.questionId == this.questionId &&
          other.questionText == this.questionText &&
          other.answerText == this.answerText &&
          other.tStartedAt == this.tStartedAt &&
          other.tSubmittedAt == this.tSubmittedAt &&
          other.scoreJson == this.scoreJson &&
          other.createdAt == this.createdAt);
}

class TurnsCompanion extends UpdateCompanion<TurnRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> seq;
  final Value<String?> questionId;
  final Value<String> questionText;
  final Value<String> answerText;
  final Value<DateTime> tStartedAt;
  final Value<DateTime> tSubmittedAt;
  final Value<String?> scoreJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TurnsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.seq = const Value.absent(),
    this.questionId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.answerText = const Value.absent(),
    this.tStartedAt = const Value.absent(),
    this.tSubmittedAt = const Value.absent(),
    this.scoreJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TurnsCompanion.insert({
    required String id,
    required String sessionId,
    required int seq,
    this.questionId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.answerText = const Value.absent(),
    required DateTime tStartedAt,
    required DateTime tSubmittedAt,
    this.scoreJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       seq = Value(seq),
       tStartedAt = Value(tStartedAt),
       tSubmittedAt = Value(tSubmittedAt),
       createdAt = Value(createdAt);
  static Insertable<TurnRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? seq,
    Expression<String>? questionId,
    Expression<String>? questionText,
    Expression<String>? answerText,
    Expression<DateTime>? tStartedAt,
    Expression<DateTime>? tSubmittedAt,
    Expression<String>? scoreJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (seq != null) 'seq': seq,
      if (questionId != null) 'question_id': questionId,
      if (questionText != null) 'question_text': questionText,
      if (answerText != null) 'answer_text': answerText,
      if (tStartedAt != null) 't_started_at': tStartedAt,
      if (tSubmittedAt != null) 't_submitted_at': tSubmittedAt,
      if (scoreJson != null) 'score_json': scoreJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TurnsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? seq,
    Value<String?>? questionId,
    Value<String>? questionText,
    Value<String>? answerText,
    Value<DateTime>? tStartedAt,
    Value<DateTime>? tSubmittedAt,
    Value<String?>? scoreJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TurnsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      seq: seq ?? this.seq,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      tStartedAt: tStartedAt ?? this.tStartedAt,
      tSubmittedAt: tSubmittedAt ?? this.tSubmittedAt,
      scoreJson: scoreJson ?? this.scoreJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (answerText.present) {
      map['answer_text'] = Variable<String>(answerText.value);
    }
    if (tStartedAt.present) {
      map['t_started_at'] = Variable<DateTime>(tStartedAt.value);
    }
    if (tSubmittedAt.present) {
      map['t_submitted_at'] = Variable<DateTime>(tSubmittedAt.value);
    }
    if (scoreJson.present) {
      map['score_json'] = Variable<String>(scoreJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('seq: $seq, ')
          ..write('questionId: $questionId, ')
          ..write('questionText: $questionText, ')
          ..write('answerText: $answerText, ')
          ..write('tStartedAt: $tStartedAt, ')
          ..write('tSubmittedAt: $tSubmittedAt, ')
          ..write('scoreJson: $scoreJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _toolCallsMeta = const VerificationMeta(
    'toolCalls',
  );
  @override
  late final GeneratedColumn<String> toolCalls = GeneratedColumn<String>(
    'tool_calls',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensMeta = const VerificationMeta('tokens');
  @override
  late final GeneratedColumn<int> tokens = GeneratedColumn<int>(
    'tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    content,
    toolCalls,
    tokens,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('tool_calls')) {
      context.handle(
        _toolCallsMeta,
        toolCalls.isAcceptableOrUnknown(data['tool_calls']!, _toolCallsMeta),
      );
    }
    if (data.containsKey('tokens')) {
      context.handle(
        _tokensMeta,
        tokens.isAcceptableOrUnknown(data['tokens']!, _tokensMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      toolCalls: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_calls'],
      ),
      tokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? toolCalls;
  final int tokens;
  final DateTime createdAt;
  const MessageRow({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.toolCalls,
    required this.tokens,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || toolCalls != null) {
      map['tool_calls'] = Variable<String>(toolCalls);
    }
    map['tokens'] = Variable<int>(tokens);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      toolCalls: toolCalls == null && nullToAbsent
          ? const Value.absent()
          : Value(toolCalls),
      tokens: Value(tokens),
      createdAt: Value(createdAt),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      toolCalls: serializer.fromJson<String?>(json['toolCalls']),
      tokens: serializer.fromJson<int>(json['tokens']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'toolCalls': serializer.toJson<String?>(toolCalls),
      'tokens': serializer.toJson<int>(tokens),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MessageRow copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    Value<String?> toolCalls = const Value.absent(),
    int? tokens,
    DateTime? createdAt,
  }) => MessageRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    role: role ?? this.role,
    content: content ?? this.content,
    toolCalls: toolCalls.present ? toolCalls.value : this.toolCalls,
    tokens: tokens ?? this.tokens,
    createdAt: createdAt ?? this.createdAt,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      toolCalls: data.toolCalls.present ? data.toolCalls.value : this.toolCalls,
      tokens: data.tokens.present ? data.tokens.value : this.tokens,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCalls: $toolCalls, ')
          ..write('tokens: $tokens, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, role, content, toolCalls, tokens, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.content == this.content &&
          other.toolCalls == this.toolCalls &&
          other.tokens == this.tokens &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> toolCalls;
  final Value<int> tokens;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.toolCalls = const Value.absent(),
    this.tokens = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String sessionId,
    required String role,
    this.content = const Value.absent(),
    this.toolCalls = const Value.absent(),
    this.tokens = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? toolCalls,
    Expression<int>? tokens,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (toolCalls != null) 'tool_calls': toolCalls,
      if (tokens != null) 'tokens': tokens,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? role,
    Value<String>? content,
    Value<String?>? toolCalls,
    Value<int>? tokens,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      toolCalls: toolCalls ?? this.toolCalls,
      tokens: tokens ?? this.tokens,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (toolCalls.present) {
      map['tool_calls'] = Variable<String>(toolCalls.value);
    }
    if (tokens.present) {
      map['tokens'] = Variable<int>(tokens.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('toolCalls: $toolCalls, ')
          ..write('tokens: $tokens, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionMemoryTable extends SessionMemory
    with TableInfo<$SessionMemoryTable, SessionMemoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionMemoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _memoryJsonMeta = const VerificationMeta(
    'memoryJson',
  );
  @override
  late final GeneratedColumn<String> memoryJson = GeneratedColumn<String>(
    'memory_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, memoryJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_memory';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionMemoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('memory_json')) {
      context.handle(
        _memoryJsonMeta,
        memoryJson.isAcceptableOrUnknown(data['memory_json']!, _memoryJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SessionMemoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionMemoryRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      memoryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionMemoryTable createAlias(String alias) {
    return $SessionMemoryTable(attachedDatabase, alias);
  }
}

class SessionMemoryRow extends DataClass
    implements Insertable<SessionMemoryRow> {
  final String sessionId;
  final String memoryJson;
  final DateTime updatedAt;
  const SessionMemoryRow({
    required this.sessionId,
    required this.memoryJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['memory_json'] = Variable<String>(memoryJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionMemoryCompanion toCompanion(bool nullToAbsent) {
    return SessionMemoryCompanion(
      sessionId: Value(sessionId),
      memoryJson: Value(memoryJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionMemoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionMemoryRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      memoryJson: serializer.fromJson<String>(json['memoryJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'memoryJson': serializer.toJson<String>(memoryJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionMemoryRow copyWith({
    String? sessionId,
    String? memoryJson,
    DateTime? updatedAt,
  }) => SessionMemoryRow(
    sessionId: sessionId ?? this.sessionId,
    memoryJson: memoryJson ?? this.memoryJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionMemoryRow copyWithCompanion(SessionMemoryCompanion data) {
    return SessionMemoryRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      memoryJson: data.memoryJson.present
          ? data.memoryJson.value
          : this.memoryJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionMemoryRow(')
          ..write('sessionId: $sessionId, ')
          ..write('memoryJson: $memoryJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, memoryJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionMemoryRow &&
          other.sessionId == this.sessionId &&
          other.memoryJson == this.memoryJson &&
          other.updatedAt == this.updatedAt);
}

class SessionMemoryCompanion extends UpdateCompanion<SessionMemoryRow> {
  final Value<String> sessionId;
  final Value<String> memoryJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionMemoryCompanion({
    this.sessionId = const Value.absent(),
    this.memoryJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionMemoryCompanion.insert({
    required String sessionId,
    required String memoryJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       memoryJson = Value(memoryJson),
       updatedAt = Value(updatedAt);
  static Insertable<SessionMemoryRow> custom({
    Expression<String>? sessionId,
    Expression<String>? memoryJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (memoryJson != null) 'memory_json': memoryJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionMemoryCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? memoryJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionMemoryCompanion(
      sessionId: sessionId ?? this.sessionId,
      memoryJson: memoryJson ?? this.memoryJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (memoryJson.present) {
      map['memory_json'] = Variable<String>(memoryJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionMemoryCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('memoryJson: $memoryJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionScoresTable extends SessionScores
    with TableInfo<$SessionScoresTable, SessionScore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionScoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _aggregateJsonMeta = const VerificationMeta(
    'aggregateJson',
  );
  @override
  late final GeneratedColumn<String> aggregateJson = GeneratedColumn<String>(
    'aggregate_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rubricVersionMeta = const VerificationMeta(
    'rubricVersion',
  );
  @override
  late final GeneratedColumn<String> rubricVersion = GeneratedColumn<String>(
    'rubric_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    aggregateJson,
    rubricVersion,
    model,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_scores';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionScore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('aggregate_json')) {
      context.handle(
        _aggregateJsonMeta,
        aggregateJson.isAcceptableOrUnknown(
          data['aggregate_json']!,
          _aggregateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateJsonMeta);
    }
    if (data.containsKey('rubric_version')) {
      context.handle(
        _rubricVersionMeta,
        rubricVersion.isAcceptableOrUnknown(
          data['rubric_version']!,
          _rubricVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rubricVersionMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  SessionScore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionScore(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      aggregateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_json'],
      )!,
      rubricVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rubric_version'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionScoresTable createAlias(String alias) {
    return $SessionScoresTable(attachedDatabase, alias);
  }
}

class SessionScore extends DataClass implements Insertable<SessionScore> {
  final String sessionId;
  final String aggregateJson;
  final String rubricVersion;
  final String model;
  final DateTime createdAt;
  const SessionScore({
    required this.sessionId,
    required this.aggregateJson,
    required this.rubricVersion,
    required this.model,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['aggregate_json'] = Variable<String>(aggregateJson);
    map['rubric_version'] = Variable<String>(rubricVersion);
    map['model'] = Variable<String>(model);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionScoresCompanion toCompanion(bool nullToAbsent) {
    return SessionScoresCompanion(
      sessionId: Value(sessionId),
      aggregateJson: Value(aggregateJson),
      rubricVersion: Value(rubricVersion),
      model: Value(model),
      createdAt: Value(createdAt),
    );
  }

  factory SessionScore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionScore(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      aggregateJson: serializer.fromJson<String>(json['aggregateJson']),
      rubricVersion: serializer.fromJson<String>(json['rubricVersion']),
      model: serializer.fromJson<String>(json['model']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'aggregateJson': serializer.toJson<String>(aggregateJson),
      'rubricVersion': serializer.toJson<String>(rubricVersion),
      'model': serializer.toJson<String>(model),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionScore copyWith({
    String? sessionId,
    String? aggregateJson,
    String? rubricVersion,
    String? model,
    DateTime? createdAt,
  }) => SessionScore(
    sessionId: sessionId ?? this.sessionId,
    aggregateJson: aggregateJson ?? this.aggregateJson,
    rubricVersion: rubricVersion ?? this.rubricVersion,
    model: model ?? this.model,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionScore copyWithCompanion(SessionScoresCompanion data) {
    return SessionScore(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      aggregateJson: data.aggregateJson.present
          ? data.aggregateJson.value
          : this.aggregateJson,
      rubricVersion: data.rubricVersion.present
          ? data.rubricVersion.value
          : this.rubricVersion,
      model: data.model.present ? data.model.value : this.model,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionScore(')
          ..write('sessionId: $sessionId, ')
          ..write('aggregateJson: $aggregateJson, ')
          ..write('rubricVersion: $rubricVersion, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sessionId, aggregateJson, rubricVersion, model, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionScore &&
          other.sessionId == this.sessionId &&
          other.aggregateJson == this.aggregateJson &&
          other.rubricVersion == this.rubricVersion &&
          other.model == this.model &&
          other.createdAt == this.createdAt);
}

class SessionScoresCompanion extends UpdateCompanion<SessionScore> {
  final Value<String> sessionId;
  final Value<String> aggregateJson;
  final Value<String> rubricVersion;
  final Value<String> model;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionScoresCompanion({
    this.sessionId = const Value.absent(),
    this.aggregateJson = const Value.absent(),
    this.rubricVersion = const Value.absent(),
    this.model = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionScoresCompanion.insert({
    required String sessionId,
    required String aggregateJson,
    required String rubricVersion,
    required String model,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       aggregateJson = Value(aggregateJson),
       rubricVersion = Value(rubricVersion),
       model = Value(model),
       createdAt = Value(createdAt);
  static Insertable<SessionScore> custom({
    Expression<String>? sessionId,
    Expression<String>? aggregateJson,
    Expression<String>? rubricVersion,
    Expression<String>? model,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (aggregateJson != null) 'aggregate_json': aggregateJson,
      if (rubricVersion != null) 'rubric_version': rubricVersion,
      if (model != null) 'model': model,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionScoresCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? aggregateJson,
    Value<String>? rubricVersion,
    Value<String>? model,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionScoresCompanion(
      sessionId: sessionId ?? this.sessionId,
      aggregateJson: aggregateJson ?? this.aggregateJson,
      rubricVersion: rubricVersion ?? this.rubricVersion,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (aggregateJson.present) {
      map['aggregate_json'] = Variable<String>(aggregateJson.value);
    }
    if (rubricVersion.present) {
      map['rubric_version'] = Variable<String>(rubricVersion.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionScoresCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('aggregateJson: $aggregateJson, ')
          ..write('rubricVersion: $rubricVersion, ')
          ..write('model: $model, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchCacheTable extends SearchCache
    with TableInfo<$SearchCacheTable, SearchCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlHashMeta = const VerificationMeta(
    'urlHash',
  );
  @override
  late final GeneratedColumn<String> urlHash = GeneratedColumn<String>(
    'url_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _textMdMeta = const VerificationMeta('textMd');
  @override
  late final GeneratedColumn<String> textMd = GeneratedColumn<String>(
    'text_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttlSMeta = const VerificationMeta('ttlS');
  @override
  late final GeneratedColumn<int> ttlS = GeneratedColumn<int>(
    'ttl_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(86400),
  );
  @override
  List<GeneratedColumn> get $columns => [
    urlHash,
    url,
    title,
    textMd,
    fetchedAt,
    ttlS,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url_hash')) {
      context.handle(
        _urlHashMeta,
        urlHash.isAcceptableOrUnknown(data['url_hash']!, _urlHashMeta),
      );
    } else if (isInserting) {
      context.missing(_urlHashMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('text_md')) {
      context.handle(
        _textMdMeta,
        textMd.isAcceptableOrUnknown(data['text_md']!, _textMdMeta),
      );
    } else if (isInserting) {
      context.missing(_textMdMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('ttl_s')) {
      context.handle(
        _ttlSMeta,
        ttlS.isAcceptableOrUnknown(data['ttl_s']!, _ttlSMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {urlHash};
  @override
  SearchCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchCacheRow(
      urlHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_hash'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      textMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_md'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      ttlS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_s'],
      )!,
    );
  }

  @override
  $SearchCacheTable createAlias(String alias) {
    return $SearchCacheTable(attachedDatabase, alias);
  }
}

class SearchCacheRow extends DataClass implements Insertable<SearchCacheRow> {
  final String urlHash;
  final String url;
  final String title;
  final String textMd;
  final DateTime fetchedAt;
  final int ttlS;
  const SearchCacheRow({
    required this.urlHash,
    required this.url,
    required this.title,
    required this.textMd,
    required this.fetchedAt,
    required this.ttlS,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url_hash'] = Variable<String>(urlHash);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['text_md'] = Variable<String>(textMd);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['ttl_s'] = Variable<int>(ttlS);
    return map;
  }

  SearchCacheCompanion toCompanion(bool nullToAbsent) {
    return SearchCacheCompanion(
      urlHash: Value(urlHash),
      url: Value(url),
      title: Value(title),
      textMd: Value(textMd),
      fetchedAt: Value(fetchedAt),
      ttlS: Value(ttlS),
    );
  }

  factory SearchCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchCacheRow(
      urlHash: serializer.fromJson<String>(json['urlHash']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      textMd: serializer.fromJson<String>(json['textMd']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      ttlS: serializer.fromJson<int>(json['ttlS']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'urlHash': serializer.toJson<String>(urlHash),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'textMd': serializer.toJson<String>(textMd),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'ttlS': serializer.toJson<int>(ttlS),
    };
  }

  SearchCacheRow copyWith({
    String? urlHash,
    String? url,
    String? title,
    String? textMd,
    DateTime? fetchedAt,
    int? ttlS,
  }) => SearchCacheRow(
    urlHash: urlHash ?? this.urlHash,
    url: url ?? this.url,
    title: title ?? this.title,
    textMd: textMd ?? this.textMd,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    ttlS: ttlS ?? this.ttlS,
  );
  SearchCacheRow copyWithCompanion(SearchCacheCompanion data) {
    return SearchCacheRow(
      urlHash: data.urlHash.present ? data.urlHash.value : this.urlHash,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      textMd: data.textMd.present ? data.textMd.value : this.textMd,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      ttlS: data.ttlS.present ? data.ttlS.value : this.ttlS,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheRow(')
          ..write('urlHash: $urlHash, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('textMd: $textMd, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('ttlS: $ttlS')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(urlHash, url, title, textMd, fetchedAt, ttlS);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchCacheRow &&
          other.urlHash == this.urlHash &&
          other.url == this.url &&
          other.title == this.title &&
          other.textMd == this.textMd &&
          other.fetchedAt == this.fetchedAt &&
          other.ttlS == this.ttlS);
}

class SearchCacheCompanion extends UpdateCompanion<SearchCacheRow> {
  final Value<String> urlHash;
  final Value<String> url;
  final Value<String> title;
  final Value<String> textMd;
  final Value<DateTime> fetchedAt;
  final Value<int> ttlS;
  final Value<int> rowid;
  const SearchCacheCompanion({
    this.urlHash = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.textMd = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.ttlS = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchCacheCompanion.insert({
    required String urlHash,
    required String url,
    this.title = const Value.absent(),
    required String textMd,
    required DateTime fetchedAt,
    this.ttlS = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : urlHash = Value(urlHash),
       url = Value(url),
       textMd = Value(textMd),
       fetchedAt = Value(fetchedAt);
  static Insertable<SearchCacheRow> custom({
    Expression<String>? urlHash,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? textMd,
    Expression<DateTime>? fetchedAt,
    Expression<int>? ttlS,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (urlHash != null) 'url_hash': urlHash,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (textMd != null) 'text_md': textMd,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (ttlS != null) 'ttl_s': ttlS,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchCacheCompanion copyWith({
    Value<String>? urlHash,
    Value<String>? url,
    Value<String>? title,
    Value<String>? textMd,
    Value<DateTime>? fetchedAt,
    Value<int>? ttlS,
    Value<int>? rowid,
  }) {
    return SearchCacheCompanion(
      urlHash: urlHash ?? this.urlHash,
      url: url ?? this.url,
      title: title ?? this.title,
      textMd: textMd ?? this.textMd,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      ttlS: ttlS ?? this.ttlS,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (urlHash.present) {
      map['url_hash'] = Variable<String>(urlHash.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textMd.present) {
      map['text_md'] = Variable<String>(textMd.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (ttlS.present) {
      map['ttl_s'] = Variable<int>(ttlS.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheCompanion(')
          ..write('urlHash: $urlHash, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('textMd: $textMd, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('ttlS: $ttlS, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FactChecksTable extends FactChecks
    with TableInfo<$FactChecksTable, FactCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FactChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claimHashMeta = const VerificationMeta(
    'claimHash',
  );
  @override
  late final GeneratedColumn<String> claimHash = GeneratedColumn<String>(
    'claim_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimMeta = const VerificationMeta('claim');
  @override
  late final GeneratedColumn<String> claim = GeneratedColumn<String>(
    'claim',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourcesJsonMeta = const VerificationMeta(
    'sourcesJson',
  );
  @override
  late final GeneratedColumn<String> sourcesJson = GeneratedColumn<String>(
    'sources_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ttlSMeta = const VerificationMeta('ttlS');
  @override
  late final GeneratedColumn<int> ttlS = GeneratedColumn<int>(
    'ttl_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2592000),
  );
  @override
  List<GeneratedColumn> get $columns => [
    claimHash,
    claim,
    verdict,
    confidence,
    sourcesJson,
    checkedAt,
    ttlS,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fact_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FactCheck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('claim_hash')) {
      context.handle(
        _claimHashMeta,
        claimHash.isAcceptableOrUnknown(data['claim_hash']!, _claimHashMeta),
      );
    } else if (isInserting) {
      context.missing(_claimHashMeta);
    }
    if (data.containsKey('claim')) {
      context.handle(
        _claimMeta,
        claim.isAcceptableOrUnknown(data['claim']!, _claimMeta),
      );
    } else if (isInserting) {
      context.missing(_claimMeta);
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('sources_json')) {
      context.handle(
        _sourcesJsonMeta,
        sourcesJson.isAcceptableOrUnknown(
          data['sources_json']!,
          _sourcesJsonMeta,
        ),
      );
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    if (data.containsKey('ttl_s')) {
      context.handle(
        _ttlSMeta,
        ttlS.isAcceptableOrUnknown(data['ttl_s']!, _ttlSMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {claimHash};
  @override
  FactCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FactCheck(
      claimHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim_hash'],
      )!,
      claim: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claim'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      sourcesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sources_json'],
      )!,
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      )!,
      ttlS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ttl_s'],
      )!,
    );
  }

  @override
  $FactChecksTable createAlias(String alias) {
    return $FactChecksTable(attachedDatabase, alias);
  }
}

class FactCheck extends DataClass implements Insertable<FactCheck> {
  final String claimHash;
  final String claim;
  final String verdict;
  final double confidence;
  final String sourcesJson;
  final DateTime checkedAt;
  final int ttlS;
  const FactCheck({
    required this.claimHash,
    required this.claim,
    required this.verdict,
    required this.confidence,
    required this.sourcesJson,
    required this.checkedAt,
    required this.ttlS,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['claim_hash'] = Variable<String>(claimHash);
    map['claim'] = Variable<String>(claim);
    map['verdict'] = Variable<String>(verdict);
    map['confidence'] = Variable<double>(confidence);
    map['sources_json'] = Variable<String>(sourcesJson);
    map['checked_at'] = Variable<DateTime>(checkedAt);
    map['ttl_s'] = Variable<int>(ttlS);
    return map;
  }

  FactChecksCompanion toCompanion(bool nullToAbsent) {
    return FactChecksCompanion(
      claimHash: Value(claimHash),
      claim: Value(claim),
      verdict: Value(verdict),
      confidence: Value(confidence),
      sourcesJson: Value(sourcesJson),
      checkedAt: Value(checkedAt),
      ttlS: Value(ttlS),
    );
  }

  factory FactCheck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FactCheck(
      claimHash: serializer.fromJson<String>(json['claimHash']),
      claim: serializer.fromJson<String>(json['claim']),
      verdict: serializer.fromJson<String>(json['verdict']),
      confidence: serializer.fromJson<double>(json['confidence']),
      sourcesJson: serializer.fromJson<String>(json['sourcesJson']),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
      ttlS: serializer.fromJson<int>(json['ttlS']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'claimHash': serializer.toJson<String>(claimHash),
      'claim': serializer.toJson<String>(claim),
      'verdict': serializer.toJson<String>(verdict),
      'confidence': serializer.toJson<double>(confidence),
      'sourcesJson': serializer.toJson<String>(sourcesJson),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
      'ttlS': serializer.toJson<int>(ttlS),
    };
  }

  FactCheck copyWith({
    String? claimHash,
    String? claim,
    String? verdict,
    double? confidence,
    String? sourcesJson,
    DateTime? checkedAt,
    int? ttlS,
  }) => FactCheck(
    claimHash: claimHash ?? this.claimHash,
    claim: claim ?? this.claim,
    verdict: verdict ?? this.verdict,
    confidence: confidence ?? this.confidence,
    sourcesJson: sourcesJson ?? this.sourcesJson,
    checkedAt: checkedAt ?? this.checkedAt,
    ttlS: ttlS ?? this.ttlS,
  );
  FactCheck copyWithCompanion(FactChecksCompanion data) {
    return FactCheck(
      claimHash: data.claimHash.present ? data.claimHash.value : this.claimHash,
      claim: data.claim.present ? data.claim.value : this.claim,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      sourcesJson: data.sourcesJson.present
          ? data.sourcesJson.value
          : this.sourcesJson,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
      ttlS: data.ttlS.present ? data.ttlS.value : this.ttlS,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FactCheck(')
          ..write('claimHash: $claimHash, ')
          ..write('claim: $claim, ')
          ..write('verdict: $verdict, ')
          ..write('confidence: $confidence, ')
          ..write('sourcesJson: $sourcesJson, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('ttlS: $ttlS')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    claimHash,
    claim,
    verdict,
    confidence,
    sourcesJson,
    checkedAt,
    ttlS,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FactCheck &&
          other.claimHash == this.claimHash &&
          other.claim == this.claim &&
          other.verdict == this.verdict &&
          other.confidence == this.confidence &&
          other.sourcesJson == this.sourcesJson &&
          other.checkedAt == this.checkedAt &&
          other.ttlS == this.ttlS);
}

class FactChecksCompanion extends UpdateCompanion<FactCheck> {
  final Value<String> claimHash;
  final Value<String> claim;
  final Value<String> verdict;
  final Value<double> confidence;
  final Value<String> sourcesJson;
  final Value<DateTime> checkedAt;
  final Value<int> ttlS;
  final Value<int> rowid;
  const FactChecksCompanion({
    this.claimHash = const Value.absent(),
    this.claim = const Value.absent(),
    this.verdict = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sourcesJson = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.ttlS = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactChecksCompanion.insert({
    required String claimHash,
    required String claim,
    required String verdict,
    this.confidence = const Value.absent(),
    this.sourcesJson = const Value.absent(),
    required DateTime checkedAt,
    this.ttlS = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : claimHash = Value(claimHash),
       claim = Value(claim),
       verdict = Value(verdict),
       checkedAt = Value(checkedAt);
  static Insertable<FactCheck> custom({
    Expression<String>? claimHash,
    Expression<String>? claim,
    Expression<String>? verdict,
    Expression<double>? confidence,
    Expression<String>? sourcesJson,
    Expression<DateTime>? checkedAt,
    Expression<int>? ttlS,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (claimHash != null) 'claim_hash': claimHash,
      if (claim != null) 'claim': claim,
      if (verdict != null) 'verdict': verdict,
      if (confidence != null) 'confidence': confidence,
      if (sourcesJson != null) 'sources_json': sourcesJson,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (ttlS != null) 'ttl_s': ttlS,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactChecksCompanion copyWith({
    Value<String>? claimHash,
    Value<String>? claim,
    Value<String>? verdict,
    Value<double>? confidence,
    Value<String>? sourcesJson,
    Value<DateTime>? checkedAt,
    Value<int>? ttlS,
    Value<int>? rowid,
  }) {
    return FactChecksCompanion(
      claimHash: claimHash ?? this.claimHash,
      claim: claim ?? this.claim,
      verdict: verdict ?? this.verdict,
      confidence: confidence ?? this.confidence,
      sourcesJson: sourcesJson ?? this.sourcesJson,
      checkedAt: checkedAt ?? this.checkedAt,
      ttlS: ttlS ?? this.ttlS,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (claimHash.present) {
      map['claim_hash'] = Variable<String>(claimHash.value);
    }
    if (claim.present) {
      map['claim'] = Variable<String>(claim.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (sourcesJson.present) {
      map['sources_json'] = Variable<String>(sourcesJson.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (ttlS.present) {
      map['ttl_s'] = Variable<int>(ttlS.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactChecksCompanion(')
          ..write('claimHash: $claimHash, ')
          ..write('claim: $claim, ')
          ..write('verdict: $verdict, ')
          ..write('confidence: $confidence, ')
          ..write('sourcesJson: $sourcesJson, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('ttlS: $ttlS, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocSourcesTable extends DocSources
    with TableInfo<$DocSourcesTable, DocSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorityMeta = const VerificationMeta(
    'authority',
  );
  @override
  late final GeneratedColumn<String> authority = GeneratedColumn<String>(
    'authority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('c'),
  );
  static const VerificationMeta _lastOkAtMeta = const VerificationMeta(
    'lastOkAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOkAt = GeneratedColumn<DateTime>(
    'last_ok_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockedMeta = const VerificationMeta(
    'blocked',
  );
  @override
  late final GeneratedColumn<bool> blocked = GeneratedColumn<bool>(
    'blocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("blocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [domain, authority, lastOkAt, blocked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doc_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('authority')) {
      context.handle(
        _authorityMeta,
        authority.isAcceptableOrUnknown(data['authority']!, _authorityMeta),
      );
    }
    if (data.containsKey('last_ok_at')) {
      context.handle(
        _lastOkAtMeta,
        lastOkAt.isAcceptableOrUnknown(data['last_ok_at']!, _lastOkAtMeta),
      );
    }
    if (data.containsKey('blocked')) {
      context.handle(
        _blockedMeta,
        blocked.isAcceptableOrUnknown(data['blocked']!, _blockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {domain};
  @override
  DocSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocSource(
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      authority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority'],
      )!,
      lastOkAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_ok_at'],
      ),
      blocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blocked'],
      )!,
    );
  }

  @override
  $DocSourcesTable createAlias(String alias) {
    return $DocSourcesTable(attachedDatabase, alias);
  }
}

class DocSource extends DataClass implements Insertable<DocSource> {
  final String domain;
  final String authority;
  final DateTime? lastOkAt;
  final bool blocked;
  const DocSource({
    required this.domain,
    required this.authority,
    this.lastOkAt,
    required this.blocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['domain'] = Variable<String>(domain);
    map['authority'] = Variable<String>(authority);
    if (!nullToAbsent || lastOkAt != null) {
      map['last_ok_at'] = Variable<DateTime>(lastOkAt);
    }
    map['blocked'] = Variable<bool>(blocked);
    return map;
  }

  DocSourcesCompanion toCompanion(bool nullToAbsent) {
    return DocSourcesCompanion(
      domain: Value(domain),
      authority: Value(authority),
      lastOkAt: lastOkAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOkAt),
      blocked: Value(blocked),
    );
  }

  factory DocSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocSource(
      domain: serializer.fromJson<String>(json['domain']),
      authority: serializer.fromJson<String>(json['authority']),
      lastOkAt: serializer.fromJson<DateTime?>(json['lastOkAt']),
      blocked: serializer.fromJson<bool>(json['blocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'domain': serializer.toJson<String>(domain),
      'authority': serializer.toJson<String>(authority),
      'lastOkAt': serializer.toJson<DateTime?>(lastOkAt),
      'blocked': serializer.toJson<bool>(blocked),
    };
  }

  DocSource copyWith({
    String? domain,
    String? authority,
    Value<DateTime?> lastOkAt = const Value.absent(),
    bool? blocked,
  }) => DocSource(
    domain: domain ?? this.domain,
    authority: authority ?? this.authority,
    lastOkAt: lastOkAt.present ? lastOkAt.value : this.lastOkAt,
    blocked: blocked ?? this.blocked,
  );
  DocSource copyWithCompanion(DocSourcesCompanion data) {
    return DocSource(
      domain: data.domain.present ? data.domain.value : this.domain,
      authority: data.authority.present ? data.authority.value : this.authority,
      lastOkAt: data.lastOkAt.present ? data.lastOkAt.value : this.lastOkAt,
      blocked: data.blocked.present ? data.blocked.value : this.blocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocSource(')
          ..write('domain: $domain, ')
          ..write('authority: $authority, ')
          ..write('lastOkAt: $lastOkAt, ')
          ..write('blocked: $blocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(domain, authority, lastOkAt, blocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocSource &&
          other.domain == this.domain &&
          other.authority == this.authority &&
          other.lastOkAt == this.lastOkAt &&
          other.blocked == this.blocked);
}

class DocSourcesCompanion extends UpdateCompanion<DocSource> {
  final Value<String> domain;
  final Value<String> authority;
  final Value<DateTime?> lastOkAt;
  final Value<bool> blocked;
  final Value<int> rowid;
  const DocSourcesCompanion({
    this.domain = const Value.absent(),
    this.authority = const Value.absent(),
    this.lastOkAt = const Value.absent(),
    this.blocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocSourcesCompanion.insert({
    required String domain,
    this.authority = const Value.absent(),
    this.lastOkAt = const Value.absent(),
    this.blocked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : domain = Value(domain);
  static Insertable<DocSource> custom({
    Expression<String>? domain,
    Expression<String>? authority,
    Expression<DateTime>? lastOkAt,
    Expression<bool>? blocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (domain != null) 'domain': domain,
      if (authority != null) 'authority': authority,
      if (lastOkAt != null) 'last_ok_at': lastOkAt,
      if (blocked != null) 'blocked': blocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocSourcesCompanion copyWith({
    Value<String>? domain,
    Value<String>? authority,
    Value<DateTime?>? lastOkAt,
    Value<bool>? blocked,
    Value<int>? rowid,
  }) {
    return DocSourcesCompanion(
      domain: domain ?? this.domain,
      authority: authority ?? this.authority,
      lastOkAt: lastOkAt ?? this.lastOkAt,
      blocked: blocked ?? this.blocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (authority.present) {
      map['authority'] = Variable<String>(authority.value);
    }
    if (lastOkAt.present) {
      map['last_ok_at'] = Variable<DateTime>(lastOkAt.value);
    }
    if (blocked.present) {
      map['blocked'] = Variable<bool>(blocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocSourcesCompanion(')
          ..write('domain: $domain, ')
          ..write('authority: $authority, ')
          ..write('lastOkAt: $lastOkAt, ')
          ..write('blocked: $blocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionEmbeddingsTable extends QuestionEmbeddings
    with TableInfo<$QuestionEmbeddingsTable, QuestionEmbeddingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimMeta = const VerificationMeta('dim');
  @override
  late final GeneratedColumn<int> dim = GeneratedColumn<int>(
    'dim',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vecMeta = const VerificationMeta('vec');
  @override
  late final GeneratedColumn<Uint8List> vec = GeneratedColumn<Uint8List>(
    'vec',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    model,
    dim,
    vec,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionEmbeddingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('dim')) {
      context.handle(
        _dimMeta,
        dim.isAcceptableOrUnknown(data['dim']!, _dimMeta),
      );
    } else if (isInserting) {
      context.missing(_dimMeta);
    }
    if (data.containsKey('vec')) {
      context.handle(
        _vecMeta,
        vec.isAcceptableOrUnknown(data['vec']!, _vecMeta),
      );
    } else if (isInserting) {
      context.missing(_vecMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId, model};
  @override
  QuestionEmbeddingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionEmbeddingRow(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      dim: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dim'],
      )!,
      vec: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vec'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuestionEmbeddingsTable createAlias(String alias) {
    return $QuestionEmbeddingsTable(attachedDatabase, alias);
  }
}

class QuestionEmbeddingRow extends DataClass
    implements Insertable<QuestionEmbeddingRow> {
  final String questionId;
  final String model;
  final int dim;
  final Uint8List vec;
  final DateTime updatedAt;
  const QuestionEmbeddingRow({
    required this.questionId,
    required this.model,
    required this.dim,
    required this.vec,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['model'] = Variable<String>(model);
    map['dim'] = Variable<int>(dim);
    map['vec'] = Variable<Uint8List>(vec);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuestionEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return QuestionEmbeddingsCompanion(
      questionId: Value(questionId),
      model: Value(model),
      dim: Value(dim),
      vec: Value(vec),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionEmbeddingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionEmbeddingRow(
      questionId: serializer.fromJson<String>(json['questionId']),
      model: serializer.fromJson<String>(json['model']),
      dim: serializer.fromJson<int>(json['dim']),
      vec: serializer.fromJson<Uint8List>(json['vec']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'model': serializer.toJson<String>(model),
      'dim': serializer.toJson<int>(dim),
      'vec': serializer.toJson<Uint8List>(vec),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuestionEmbeddingRow copyWith({
    String? questionId,
    String? model,
    int? dim,
    Uint8List? vec,
    DateTime? updatedAt,
  }) => QuestionEmbeddingRow(
    questionId: questionId ?? this.questionId,
    model: model ?? this.model,
    dim: dim ?? this.dim,
    vec: vec ?? this.vec,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuestionEmbeddingRow copyWithCompanion(QuestionEmbeddingsCompanion data) {
    return QuestionEmbeddingRow(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      model: data.model.present ? data.model.value : this.model,
      dim: data.dim.present ? data.dim.value : this.dim,
      vec: data.vec.present ? data.vec.value : this.vec,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionEmbeddingRow(')
          ..write('questionId: $questionId, ')
          ..write('model: $model, ')
          ..write('dim: $dim, ')
          ..write('vec: $vec, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    questionId,
    model,
    dim,
    $driftBlobEquality.hash(vec),
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionEmbeddingRow &&
          other.questionId == this.questionId &&
          other.model == this.model &&
          other.dim == this.dim &&
          $driftBlobEquality.equals(other.vec, this.vec) &&
          other.updatedAt == this.updatedAt);
}

class QuestionEmbeddingsCompanion
    extends UpdateCompanion<QuestionEmbeddingRow> {
  final Value<String> questionId;
  final Value<String> model;
  final Value<int> dim;
  final Value<Uint8List> vec;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuestionEmbeddingsCompanion({
    this.questionId = const Value.absent(),
    this.model = const Value.absent(),
    this.dim = const Value.absent(),
    this.vec = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionEmbeddingsCompanion.insert({
    required String questionId,
    required String model,
    required int dim,
    required Uint8List vec,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       model = Value(model),
       dim = Value(dim),
       vec = Value(vec),
       updatedAt = Value(updatedAt);
  static Insertable<QuestionEmbeddingRow> custom({
    Expression<String>? questionId,
    Expression<String>? model,
    Expression<int>? dim,
    Expression<Uint8List>? vec,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (model != null) 'model': model,
      if (dim != null) 'dim': dim,
      if (vec != null) 'vec': vec,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionEmbeddingsCompanion copyWith({
    Value<String>? questionId,
    Value<String>? model,
    Value<int>? dim,
    Value<Uint8List>? vec,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuestionEmbeddingsCompanion(
      questionId: questionId ?? this.questionId,
      model: model ?? this.model,
      dim: dim ?? this.dim,
      vec: vec ?? this.vec,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (dim.present) {
      map['dim'] = Variable<int>(dim.value);
    }
    if (vec.present) {
      map['vec'] = Variable<Uint8List>(vec.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionEmbeddingsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('model: $model, ')
          ..write('dim: $dim, ')
          ..write('vec: $vec, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionEdgesTable extends QuestionEdges
    with TableInfo<$QuestionEdgesTable, QuestionEdgeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionEdgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _srcMeta = const VerificationMeta('src');
  @override
  late final GeneratedColumn<String> src = GeneratedColumn<String>(
    'src',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dstMeta = const VerificationMeta('dst');
  @override
  late final GeneratedColumn<String> dst = GeneratedColumn<String>(
    'dst',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  @override
  List<GeneratedColumn> get $columns => [src, dst, kind, weight, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_edges';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionEdgeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('src')) {
      context.handle(
        _srcMeta,
        src.isAcceptableOrUnknown(data['src']!, _srcMeta),
      );
    } else if (isInserting) {
      context.missing(_srcMeta);
    }
    if (data.containsKey('dst')) {
      context.handle(
        _dstMeta,
        dst.isAcceptableOrUnknown(data['dst']!, _dstMeta),
      );
    } else if (isInserting) {
      context.missing(_dstMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {src, dst, kind};
  @override
  QuestionEdgeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionEdgeRow(
      src: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}src'],
      )!,
      dst: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dst'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $QuestionEdgesTable createAlias(String alias) {
    return $QuestionEdgesTable(attachedDatabase, alias);
  }
}

class QuestionEdgeRow extends DataClass implements Insertable<QuestionEdgeRow> {
  final String src;
  final String dst;

  /// similar | followup | prerequisite | variant | contrast | cluster
  final String kind;
  final double weight;
  final String source;
  const QuestionEdgeRow({
    required this.src,
    required this.dst,
    required this.kind,
    required this.weight,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['src'] = Variable<String>(src);
    map['dst'] = Variable<String>(dst);
    map['kind'] = Variable<String>(kind);
    map['weight'] = Variable<double>(weight);
    map['source'] = Variable<String>(source);
    return map;
  }

  QuestionEdgesCompanion toCompanion(bool nullToAbsent) {
    return QuestionEdgesCompanion(
      src: Value(src),
      dst: Value(dst),
      kind: Value(kind),
      weight: Value(weight),
      source: Value(source),
    );
  }

  factory QuestionEdgeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionEdgeRow(
      src: serializer.fromJson<String>(json['src']),
      dst: serializer.fromJson<String>(json['dst']),
      kind: serializer.fromJson<String>(json['kind']),
      weight: serializer.fromJson<double>(json['weight']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'src': serializer.toJson<String>(src),
      'dst': serializer.toJson<String>(dst),
      'kind': serializer.toJson<String>(kind),
      'weight': serializer.toJson<double>(weight),
      'source': serializer.toJson<String>(source),
    };
  }

  QuestionEdgeRow copyWith({
    String? src,
    String? dst,
    String? kind,
    double? weight,
    String? source,
  }) => QuestionEdgeRow(
    src: src ?? this.src,
    dst: dst ?? this.dst,
    kind: kind ?? this.kind,
    weight: weight ?? this.weight,
    source: source ?? this.source,
  );
  QuestionEdgeRow copyWithCompanion(QuestionEdgesCompanion data) {
    return QuestionEdgeRow(
      src: data.src.present ? data.src.value : this.src,
      dst: data.dst.present ? data.dst.value : this.dst,
      kind: data.kind.present ? data.kind.value : this.kind,
      weight: data.weight.present ? data.weight.value : this.weight,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionEdgeRow(')
          ..write('src: $src, ')
          ..write('dst: $dst, ')
          ..write('kind: $kind, ')
          ..write('weight: $weight, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(src, dst, kind, weight, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionEdgeRow &&
          other.src == this.src &&
          other.dst == this.dst &&
          other.kind == this.kind &&
          other.weight == this.weight &&
          other.source == this.source);
}

class QuestionEdgesCompanion extends UpdateCompanion<QuestionEdgeRow> {
  final Value<String> src;
  final Value<String> dst;
  final Value<String> kind;
  final Value<double> weight;
  final Value<String> source;
  final Value<int> rowid;
  const QuestionEdgesCompanion({
    this.src = const Value.absent(),
    this.dst = const Value.absent(),
    this.kind = const Value.absent(),
    this.weight = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionEdgesCompanion.insert({
    required String src,
    required String dst,
    required String kind,
    this.weight = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : src = Value(src),
       dst = Value(dst),
       kind = Value(kind);
  static Insertable<QuestionEdgeRow> custom({
    Expression<String>? src,
    Expression<String>? dst,
    Expression<String>? kind,
    Expression<double>? weight,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (src != null) 'src': src,
      if (dst != null) 'dst': dst,
      if (kind != null) 'kind': kind,
      if (weight != null) 'weight': weight,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionEdgesCompanion copyWith({
    Value<String>? src,
    Value<String>? dst,
    Value<String>? kind,
    Value<double>? weight,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return QuestionEdgesCompanion(
      src: src ?? this.src,
      dst: dst ?? this.dst,
      kind: kind ?? this.kind,
      weight: weight ?? this.weight,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (src.present) {
      map['src'] = Variable<String>(src.value);
    }
    if (dst.present) {
      map['dst'] = Variable<String>(dst.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionEdgesCompanion(')
          ..write('src: $src, ')
          ..write('dst: $dst, ')
          ..write('kind: $kind, ')
          ..write('weight: $weight, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClusterMembersTable extends ClusterMembers
    with TableInfo<$ClusterMembersTable, ClusterMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClusterMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clusterIdMeta = const VerificationMeta(
    'clusterId',
  );
  @override
  late final GeneratedColumn<String> clusterId = GeneratedColumn<String>(
    'cluster_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [clusterId, questionId, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cluster_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClusterMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cluster_id')) {
      context.handle(
        _clusterIdMeta,
        clusterId.isAcceptableOrUnknown(data['cluster_id']!, _clusterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clusterIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clusterId, questionId};
  @override
  ClusterMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClusterMember(
      clusterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cluster_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
    );
  }

  @override
  $ClusterMembersTable createAlias(String alias) {
    return $ClusterMembersTable(attachedDatabase, alias);
  }
}

class ClusterMember extends DataClass implements Insertable<ClusterMember> {
  final String clusterId;
  final String questionId;
  final String label;
  const ClusterMember({
    required this.clusterId,
    required this.questionId,
    required this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cluster_id'] = Variable<String>(clusterId);
    map['question_id'] = Variable<String>(questionId);
    map['label'] = Variable<String>(label);
    return map;
  }

  ClusterMembersCompanion toCompanion(bool nullToAbsent) {
    return ClusterMembersCompanion(
      clusterId: Value(clusterId),
      questionId: Value(questionId),
      label: Value(label),
    );
  }

  factory ClusterMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClusterMember(
      clusterId: serializer.fromJson<String>(json['clusterId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clusterId': serializer.toJson<String>(clusterId),
      'questionId': serializer.toJson<String>(questionId),
      'label': serializer.toJson<String>(label),
    };
  }

  ClusterMember copyWith({
    String? clusterId,
    String? questionId,
    String? label,
  }) => ClusterMember(
    clusterId: clusterId ?? this.clusterId,
    questionId: questionId ?? this.questionId,
    label: label ?? this.label,
  );
  ClusterMember copyWithCompanion(ClusterMembersCompanion data) {
    return ClusterMember(
      clusterId: data.clusterId.present ? data.clusterId.value : this.clusterId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClusterMember(')
          ..write('clusterId: $clusterId, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clusterId, questionId, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClusterMember &&
          other.clusterId == this.clusterId &&
          other.questionId == this.questionId &&
          other.label == this.label);
}

class ClusterMembersCompanion extends UpdateCompanion<ClusterMember> {
  final Value<String> clusterId;
  final Value<String> questionId;
  final Value<String> label;
  final Value<int> rowid;
  const ClusterMembersCompanion({
    this.clusterId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClusterMembersCompanion.insert({
    required String clusterId,
    required String questionId,
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clusterId = Value(clusterId),
       questionId = Value(questionId);
  static Insertable<ClusterMember> custom({
    Expression<String>? clusterId,
    Expression<String>? questionId,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clusterId != null) 'cluster_id': clusterId,
      if (questionId != null) 'question_id': questionId,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClusterMembersCompanion copyWith({
    Value<String>? clusterId,
    Value<String>? questionId,
    Value<String>? label,
    Value<int>? rowid,
  }) {
    return ClusterMembersCompanion(
      clusterId: clusterId ?? this.clusterId,
      questionId: questionId ?? this.questionId,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clusterId.present) {
      map['cluster_id'] = Variable<String>(clusterId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClusterMembersCompanion(')
          ..write('clusterId: $clusterId, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BankSourcesTable extends BankSources
    with TableInfo<$BankSourcesTable, BankSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _lastSyncMeta = const VerificationMeta(
    'lastSync',
  );
  @override
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
    'last_sync',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    url,
    license,
    lastSync,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    if (data.containsKey('last_sync')) {
      context.handle(
        _lastSyncMeta,
        lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      )!,
      lastSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $BankSourcesTable createAlias(String alias) {
    return $BankSourcesTable(attachedDatabase, alias);
  }
}

class BankSource extends DataClass implements Insertable<BankSource> {
  final String id;
  final String kind;
  final String url;
  final String license;
  final DateTime? lastSync;
  final bool enabled;
  const BankSource({
    required this.id,
    required this.kind,
    required this.url,
    required this.license,
    this.lastSync,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['url'] = Variable<String>(url);
    map['license'] = Variable<String>(license);
    if (!nullToAbsent || lastSync != null) {
      map['last_sync'] = Variable<DateTime>(lastSync);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  BankSourcesCompanion toCompanion(bool nullToAbsent) {
    return BankSourcesCompanion(
      id: Value(id),
      kind: Value(kind),
      url: Value(url),
      license: Value(license),
      lastSync: lastSync == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSync),
      enabled: Value(enabled),
    );
  }

  factory BankSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankSource(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      url: serializer.fromJson<String>(json['url']),
      license: serializer.fromJson<String>(json['license']),
      lastSync: serializer.fromJson<DateTime?>(json['lastSync']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'url': serializer.toJson<String>(url),
      'license': serializer.toJson<String>(license),
      'lastSync': serializer.toJson<DateTime?>(lastSync),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  BankSource copyWith({
    String? id,
    String? kind,
    String? url,
    String? license,
    Value<DateTime?> lastSync = const Value.absent(),
    bool? enabled,
  }) => BankSource(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    url: url ?? this.url,
    license: license ?? this.license,
    lastSync: lastSync.present ? lastSync.value : this.lastSync,
    enabled: enabled ?? this.enabled,
  );
  BankSource copyWithCompanion(BankSourcesCompanion data) {
    return BankSource(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      url: data.url.present ? data.url.value : this.url,
      license: data.license.present ? data.license.value : this.license,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankSource(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('url: $url, ')
          ..write('license: $license, ')
          ..write('lastSync: $lastSync, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, url, license, lastSync, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankSource &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.url == this.url &&
          other.license == this.license &&
          other.lastSync == this.lastSync &&
          other.enabled == this.enabled);
}

class BankSourcesCompanion extends UpdateCompanion<BankSource> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> url;
  final Value<String> license;
  final Value<DateTime?> lastSync;
  final Value<bool> enabled;
  final Value<int> rowid;
  const BankSourcesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.url = const Value.absent(),
    this.license = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BankSourcesCompanion.insert({
    required String id,
    required String kind,
    required String url,
    this.license = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       url = Value(url);
  static Insertable<BankSource> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? url,
    Expression<String>? license,
    Expression<DateTime>? lastSync,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (url != null) 'url': url,
      if (license != null) 'license': license,
      if (lastSync != null) 'last_sync': lastSync,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BankSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? url,
    Value<String>? license,
    Value<DateTime?>? lastSync,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return BankSourcesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      url: url ?? this.url,
      license: license ?? this.license,
      lastSync: lastSync ?? this.lastSync,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankSourcesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('url: $url, ')
          ..write('license: $license, ')
          ..write('lastSync: $lastSync, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LlmCallsTable extends LlmCalls with TableInfo<$LlmCallsTable, LlmCall> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LlmCallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokensInMeta = const VerificationMeta(
    'tokensIn',
  );
  @override
  late final GeneratedColumn<int> tokensIn = GeneratedColumn<int>(
    'tokens_in',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tokensOutMeta = const VerificationMeta(
    'tokensOut',
  );
  @override
  late final GeneratedColumn<int> tokensOut = GeneratedColumn<int>(
    'tokens_out',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    role,
    provider,
    model,
    tokensIn,
    tokensOut,
    latencyMs,
    cost,
    error,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'llm_calls';
  @override
  VerificationContext validateIntegrity(
    Insertable<LlmCall> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('tokens_in')) {
      context.handle(
        _tokensInMeta,
        tokensIn.isAcceptableOrUnknown(data['tokens_in']!, _tokensInMeta),
      );
    }
    if (data.containsKey('tokens_out')) {
      context.handle(
        _tokensOutMeta,
        tokensOut.isAcceptableOrUnknown(data['tokens_out']!, _tokensOutMeta),
      );
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LlmCall map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LlmCall(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      tokensIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_in'],
      )!,
      tokensOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_out'],
      )!,
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LlmCallsTable createAlias(String alias) {
    return $LlmCallsTable(attachedDatabase, alias);
  }
}

class LlmCall extends DataClass implements Insertable<LlmCall> {
  final String id;
  final String? sessionId;
  final String role;
  final String provider;
  final String model;
  final int tokensIn;
  final int tokensOut;
  final int latencyMs;
  final double cost;
  final String? error;
  final DateTime createdAt;
  const LlmCall({
    required this.id,
    this.sessionId,
    required this.role,
    required this.provider,
    required this.model,
    required this.tokensIn,
    required this.tokensOut,
    required this.latencyMs,
    required this.cost,
    this.error,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['role'] = Variable<String>(role);
    map['provider'] = Variable<String>(provider);
    map['model'] = Variable<String>(model);
    map['tokens_in'] = Variable<int>(tokensIn);
    map['tokens_out'] = Variable<int>(tokensOut);
    map['latency_ms'] = Variable<int>(latencyMs);
    map['cost'] = Variable<double>(cost);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LlmCallsCompanion toCompanion(bool nullToAbsent) {
    return LlmCallsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      role: Value(role),
      provider: Value(provider),
      model: Value(model),
      tokensIn: Value(tokensIn),
      tokensOut: Value(tokensOut),
      latencyMs: Value(latencyMs),
      cost: Value(cost),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
    );
  }

  factory LlmCall.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LlmCall(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      role: serializer.fromJson<String>(json['role']),
      provider: serializer.fromJson<String>(json['provider']),
      model: serializer.fromJson<String>(json['model']),
      tokensIn: serializer.fromJson<int>(json['tokensIn']),
      tokensOut: serializer.fromJson<int>(json['tokensOut']),
      latencyMs: serializer.fromJson<int>(json['latencyMs']),
      cost: serializer.fromJson<double>(json['cost']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String?>(sessionId),
      'role': serializer.toJson<String>(role),
      'provider': serializer.toJson<String>(provider),
      'model': serializer.toJson<String>(model),
      'tokensIn': serializer.toJson<int>(tokensIn),
      'tokensOut': serializer.toJson<int>(tokensOut),
      'latencyMs': serializer.toJson<int>(latencyMs),
      'cost': serializer.toJson<double>(cost),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LlmCall copyWith({
    String? id,
    Value<String?> sessionId = const Value.absent(),
    String? role,
    String? provider,
    String? model,
    int? tokensIn,
    int? tokensOut,
    int? latencyMs,
    double? cost,
    Value<String?> error = const Value.absent(),
    DateTime? createdAt,
  }) => LlmCall(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    role: role ?? this.role,
    provider: provider ?? this.provider,
    model: model ?? this.model,
    tokensIn: tokensIn ?? this.tokensIn,
    tokensOut: tokensOut ?? this.tokensOut,
    latencyMs: latencyMs ?? this.latencyMs,
    cost: cost ?? this.cost,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
  );
  LlmCall copyWithCompanion(LlmCallsCompanion data) {
    return LlmCall(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      role: data.role.present ? data.role.value : this.role,
      provider: data.provider.present ? data.provider.value : this.provider,
      model: data.model.present ? data.model.value : this.model,
      tokensIn: data.tokensIn.present ? data.tokensIn.value : this.tokensIn,
      tokensOut: data.tokensOut.present ? data.tokensOut.value : this.tokensOut,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      cost: data.cost.present ? data.cost.value : this.cost,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LlmCall(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('provider: $provider, ')
          ..write('model: $model, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('cost: $cost, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    role,
    provider,
    model,
    tokensIn,
    tokensOut,
    latencyMs,
    cost,
    error,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LlmCall &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.role == this.role &&
          other.provider == this.provider &&
          other.model == this.model &&
          other.tokensIn == this.tokensIn &&
          other.tokensOut == this.tokensOut &&
          other.latencyMs == this.latencyMs &&
          other.cost == this.cost &&
          other.error == this.error &&
          other.createdAt == this.createdAt);
}

class LlmCallsCompanion extends UpdateCompanion<LlmCall> {
  final Value<String> id;
  final Value<String?> sessionId;
  final Value<String> role;
  final Value<String> provider;
  final Value<String> model;
  final Value<int> tokensIn;
  final Value<int> tokensOut;
  final Value<int> latencyMs;
  final Value<double> cost;
  final Value<String?> error;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LlmCallsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.role = const Value.absent(),
    this.provider = const Value.absent(),
    this.model = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.cost = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LlmCallsCompanion.insert({
    required String id,
    this.sessionId = const Value.absent(),
    required String role,
    required String provider,
    required String model,
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.cost = const Value.absent(),
    this.error = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       provider = Value(provider),
       model = Value(model),
       createdAt = Value(createdAt);
  static Insertable<LlmCall> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? role,
    Expression<String>? provider,
    Expression<String>? model,
    Expression<int>? tokensIn,
    Expression<int>? tokensOut,
    Expression<int>? latencyMs,
    Expression<double>? cost,
    Expression<String>? error,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (role != null) 'role': role,
      if (provider != null) 'provider': provider,
      if (model != null) 'model': model,
      if (tokensIn != null) 'tokens_in': tokensIn,
      if (tokensOut != null) 'tokens_out': tokensOut,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (cost != null) 'cost': cost,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LlmCallsCompanion copyWith({
    Value<String>? id,
    Value<String?>? sessionId,
    Value<String>? role,
    Value<String>? provider,
    Value<String>? model,
    Value<int>? tokensIn,
    Value<int>? tokensOut,
    Value<int>? latencyMs,
    Value<double>? cost,
    Value<String?>? error,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LlmCallsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      tokensIn: tokensIn ?? this.tokensIn,
      tokensOut: tokensOut ?? this.tokensOut,
      latencyMs: latencyMs ?? this.latencyMs,
      cost: cost ?? this.cost,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (tokensIn.present) {
      map['tokens_in'] = Variable<int>(tokensIn.value);
    }
    if (tokensOut.present) {
      map['tokens_out'] = Variable<int>(tokensOut.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LlmCallsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('role: $role, ')
          ..write('provider: $provider, ')
          ..write('model: $model, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('cost: $cost, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BankMetaTable extends BankMeta
    with TableInfo<$BankMetaTable, BankMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activeDirMeta = const VerificationMeta(
    'activeDir',
  );
  @override
  late final GeneratedColumn<String> activeDir = GeneratedColumn<String>(
    'active_dir',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _commitMeta = const VerificationMeta('commit');
  @override
  late final GeneratedColumn<String> commit = GeneratedColumn<String>(
    'commit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signatureOkMeta = const VerificationMeta(
    'signatureOk',
  );
  @override
  late final GeneratedColumn<bool> signatureOk = GeneratedColumn<bool>(
    'signature_ok',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("signature_ok" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    activeDir,
    version,
    commit,
    installedAt,
    signatureOk,
    id,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('active_dir')) {
      context.handle(
        _activeDirMeta,
        activeDir.isAcceptableOrUnknown(data['active_dir']!, _activeDirMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('commit')) {
      context.handle(
        _commitMeta,
        commit.isAcceptableOrUnknown(data['commit']!, _commitMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('signature_ok')) {
      context.handle(
        _signatureOkMeta,
        signatureOk.isAcceptableOrUnknown(
          data['signature_ok']!,
          _signatureOkMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankMetaRow(
      activeDir: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_dir'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      commit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commit'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      ),
      signatureOk: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}signature_ok'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $BankMetaTable createAlias(String alias) {
    return $BankMetaTable(attachedDatabase, alias);
  }
}

class BankMetaRow extends DataClass implements Insertable<BankMetaRow> {
  final String activeDir;
  final String version;
  final String commit;
  final DateTime? installedAt;
  final bool signatureOk;
  final int id;
  const BankMetaRow({
    required this.activeDir,
    required this.version,
    required this.commit,
    this.installedAt,
    required this.signatureOk,
    required this.id,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['active_dir'] = Variable<String>(activeDir);
    map['version'] = Variable<String>(version);
    map['commit'] = Variable<String>(commit);
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<DateTime>(installedAt);
    }
    map['signature_ok'] = Variable<bool>(signatureOk);
    map['id'] = Variable<int>(id);
    return map;
  }

  BankMetaCompanion toCompanion(bool nullToAbsent) {
    return BankMetaCompanion(
      activeDir: Value(activeDir),
      version: Value(version),
      commit: Value(commit),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
      signatureOk: Value(signatureOk),
      id: Value(id),
    );
  }

  factory BankMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankMetaRow(
      activeDir: serializer.fromJson<String>(json['activeDir']),
      version: serializer.fromJson<String>(json['version']),
      commit: serializer.fromJson<String>(json['commit']),
      installedAt: serializer.fromJson<DateTime?>(json['installedAt']),
      signatureOk: serializer.fromJson<bool>(json['signatureOk']),
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activeDir': serializer.toJson<String>(activeDir),
      'version': serializer.toJson<String>(version),
      'commit': serializer.toJson<String>(commit),
      'installedAt': serializer.toJson<DateTime?>(installedAt),
      'signatureOk': serializer.toJson<bool>(signatureOk),
      'id': serializer.toJson<int>(id),
    };
  }

  BankMetaRow copyWith({
    String? activeDir,
    String? version,
    String? commit,
    Value<DateTime?> installedAt = const Value.absent(),
    bool? signatureOk,
    int? id,
  }) => BankMetaRow(
    activeDir: activeDir ?? this.activeDir,
    version: version ?? this.version,
    commit: commit ?? this.commit,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
    signatureOk: signatureOk ?? this.signatureOk,
    id: id ?? this.id,
  );
  BankMetaRow copyWithCompanion(BankMetaCompanion data) {
    return BankMetaRow(
      activeDir: data.activeDir.present ? data.activeDir.value : this.activeDir,
      version: data.version.present ? data.version.value : this.version,
      commit: data.commit.present ? data.commit.value : this.commit,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      signatureOk: data.signatureOk.present
          ? data.signatureOk.value
          : this.signatureOk,
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankMetaRow(')
          ..write('activeDir: $activeDir, ')
          ..write('version: $version, ')
          ..write('commit: $commit, ')
          ..write('installedAt: $installedAt, ')
          ..write('signatureOk: $signatureOk, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(activeDir, version, commit, installedAt, signatureOk, id);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankMetaRow &&
          other.activeDir == this.activeDir &&
          other.version == this.version &&
          other.commit == this.commit &&
          other.installedAt == this.installedAt &&
          other.signatureOk == this.signatureOk &&
          other.id == this.id);
}

class BankMetaCompanion extends UpdateCompanion<BankMetaRow> {
  final Value<String> activeDir;
  final Value<String> version;
  final Value<String> commit;
  final Value<DateTime?> installedAt;
  final Value<bool> signatureOk;
  final Value<int> id;
  const BankMetaCompanion({
    this.activeDir = const Value.absent(),
    this.version = const Value.absent(),
    this.commit = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.signatureOk = const Value.absent(),
    this.id = const Value.absent(),
  });
  BankMetaCompanion.insert({
    this.activeDir = const Value.absent(),
    this.version = const Value.absent(),
    this.commit = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.signatureOk = const Value.absent(),
    this.id = const Value.absent(),
  });
  static Insertable<BankMetaRow> custom({
    Expression<String>? activeDir,
    Expression<String>? version,
    Expression<String>? commit,
    Expression<DateTime>? installedAt,
    Expression<bool>? signatureOk,
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (activeDir != null) 'active_dir': activeDir,
      if (version != null) 'version': version,
      if (commit != null) 'commit': commit,
      if (installedAt != null) 'installed_at': installedAt,
      if (signatureOk != null) 'signature_ok': signatureOk,
      if (id != null) 'id': id,
    });
  }

  BankMetaCompanion copyWith({
    Value<String>? activeDir,
    Value<String>? version,
    Value<String>? commit,
    Value<DateTime?>? installedAt,
    Value<bool>? signatureOk,
    Value<int>? id,
  }) {
    return BankMetaCompanion(
      activeDir: activeDir ?? this.activeDir,
      version: version ?? this.version,
      commit: commit ?? this.commit,
      installedAt: installedAt ?? this.installedAt,
      signatureOk: signatureOk ?? this.signatureOk,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activeDir.present) {
      map['active_dir'] = Variable<String>(activeDir.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (commit.present) {
      map['commit'] = Variable<String>(commit.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (signatureOk.present) {
      map['signature_ok'] = Variable<bool>(signatureOk.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankMetaCompanion(')
          ..write('activeDir: $activeDir, ')
          ..write('version: $version, ')
          ..write('commit: $commit, ')
          ..write('installedAt: $installedAt, ')
          ..write('signatureOk: $signatureOk, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ProvidersTable providers = $ProvidersTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $QuestionLocalTable questionLocal = $QuestionLocalTable(this);
  late final $ExperiencesTable experiences = $ExperiencesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $TurnsTable turns = $TurnsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $SessionMemoryTable sessionMemory = $SessionMemoryTable(this);
  late final $SessionScoresTable sessionScores = $SessionScoresTable(this);
  late final $SearchCacheTable searchCache = $SearchCacheTable(this);
  late final $FactChecksTable factChecks = $FactChecksTable(this);
  late final $DocSourcesTable docSources = $DocSourcesTable(this);
  late final $QuestionEmbeddingsTable questionEmbeddings =
      $QuestionEmbeddingsTable(this);
  late final $QuestionEdgesTable questionEdges = $QuestionEdgesTable(this);
  late final $ClusterMembersTable clusterMembers = $ClusterMembersTable(this);
  late final $BankSourcesTable bankSources = $BankSourcesTable(this);
  late final $LlmCallsTable llmCalls = $LlmCallsTable(this);
  late final $BankMetaTable bankMeta = $BankMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    providers,
    questions,
    questionLocal,
    experiences,
    sessions,
    turns,
    messages,
    sessionMemory,
    sessionScores,
    searchCache,
    factChecks,
    docSources,
    questionEmbeddings,
    questionEdges,
    clusterMembers,
    bankSources,
    llmCalls,
    bankMeta,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('turns', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_memory', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_scores', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ProvidersTableCreateCompanionBuilder = ProvidersCompanion Function({
  required String id,
  required String kind,
  required String baseUrl,
  Value<String> modelMap,
  Value<String?> keyRef,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$ProvidersTableUpdateCompanionBuilder = ProvidersCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> baseUrl,
  Value<String> modelMap,
  Value<String?> keyRef,
  Value<bool> enabled,
  Value<int> rowid,
});

class $$ProvidersTableFilterComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelMap => $composableBuilder(
    column: $table.modelMap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyRef => $composableBuilder(
    column: $table.keyRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProvidersTableOrderingComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelMap => $composableBuilder(
    column: $table.modelMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyRef => $composableBuilder(
    column: $table.keyRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProvidersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProvidersTable> {
  $$ProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get modelMap =>
      $composableBuilder(column: $table.modelMap, builder: (column) => column);

  GeneratedColumn<String> get keyRef =>
      $composableBuilder(column: $table.keyRef, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$ProvidersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProvidersTable,
          ProviderRow,
          $$ProvidersTableFilterComposer,
          $$ProvidersTableOrderingComposer,
          $$ProvidersTableAnnotationComposer,
          $$ProvidersTableCreateCompanionBuilder,
          $$ProvidersTableUpdateCompanionBuilder,
          (
            ProviderRow,
            BaseReferences<_$AppDatabase, $ProvidersTable, ProviderRow>,
          ),
          ProviderRow,
          PrefetchHooks Function()
        > {
  $$ProvidersTableTableManager(_$AppDatabase db, $ProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> baseUrl = const Value.absent(),
                Value<String> modelMap = const Value.absent(),
                Value<String?> keyRef = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion(
                id: id,
                kind: kind,
                baseUrl: baseUrl,
                modelMap: modelMap,
                keyRef: keyRef,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String baseUrl,
                Value<String> modelMap = const Value.absent(),
                Value<String?> keyRef = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion.insert(
                id: id,
                kind: kind,
                baseUrl: baseUrl,
                modelMap: modelMap,
                keyRef: keyRef,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProvidersTable,
      ProviderRow,
      $$ProvidersTableFilterComposer,
      $$ProvidersTableOrderingComposer,
      $$ProvidersTableAnnotationComposer,
      $$ProvidersTableCreateCompanionBuilder,
      $$ProvidersTableUpdateCompanionBuilder,
      (
        ProviderRow,
        BaseReferences<_$AppDatabase, $ProvidersTable, ProviderRow>,
      ),
      ProviderRow,
      PrefetchHooks Function()
    >;
typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  required String id,
  required String bankVersion,
  required String title,
  required String bodyMd,
  Value<String> topics,
  required String role,
  Value<int> level,
  Value<int> difficulty,
  Value<String> type,
  Value<String> answerJson,
  Value<String> followupsJson,
  Value<String?> sourceUrl,
  Value<String?> license,
  Value<String> status,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<String> id,
  Value<String> bankVersion,
  Value<String> title,
  Value<String> bodyMd,
  Value<String> topics,
  Value<String> role,
  Value<int> level,
  Value<int> difficulty,
  Value<String> type,
  Value<String> answerJson,
  Value<String> followupsJson,
  Value<String?> sourceUrl,
  Value<String?> license,
  Value<String> status,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topics => $composableBuilder(
    column: $table.topics,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerJson => $composableBuilder(
    column: $table.answerJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followupsJson => $composableBuilder(
    column: $table.followupsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topics => $composableBuilder(
    column: $table.topics,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerJson => $composableBuilder(
    column: $table.answerJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followupsJson => $composableBuilder(
    column: $table.followupsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankVersion => $composableBuilder(
    column: $table.bankVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get bodyMd =>
      $composableBuilder(column: $table.bodyMd, builder: (column) => column);

  GeneratedColumn<String> get topics =>
      $composableBuilder(column: $table.topics, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get answerJson => $composableBuilder(
    column: $table.answerJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get followupsJson => $composableBuilder(
    column: $table.followupsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionsTable,
          QuestionRow,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (
            QuestionRow,
            BaseReferences<_$AppDatabase, $QuestionsTable, QuestionRow>,
          ),
          QuestionRow,
          PrefetchHooks Function()
        > {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bankVersion = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> bodyMd = const Value.absent(),
                Value<String> topics = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> answerJson = const Value.absent(),
                Value<String> followupsJson = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> license = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                bankVersion: bankVersion,
                title: title,
                bodyMd: bodyMd,
                topics: topics,
                role: role,
                level: level,
                difficulty: difficulty,
                type: type,
                answerJson: answerJson,
                followupsJson: followupsJson,
                sourceUrl: sourceUrl,
                license: license,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bankVersion,
                required String title,
                required String bodyMd,
                Value<String> topics = const Value.absent(),
                required String role,
                Value<int> level = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> answerJson = const Value.absent(),
                Value<String> followupsJson = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> license = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion.insert(
                id: id,
                bankVersion: bankVersion,
                title: title,
                bodyMd: bodyMd,
                topics: topics,
                role: role,
                level: level,
                difficulty: difficulty,
                type: type,
                answerJson: answerJson,
                followupsJson: followupsJson,
                sourceUrl: sourceUrl,
                license: license,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionsTable,
      QuestionRow,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (
        QuestionRow,
        BaseReferences<_$AppDatabase, $QuestionsTable, QuestionRow>,
      ),
      QuestionRow,
      PrefetchHooks Function()
    >;
typedef $$QuestionLocalTableCreateCompanionBuilder =
    QuestionLocalCompanion Function({
      required String questionId,
      Value<String> noteMd,
      Value<bool> starred,
      Value<bool> hidden,
      Value<String> origin,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QuestionLocalTableUpdateCompanionBuilder =
    QuestionLocalCompanion Function({
      Value<String> questionId,
      Value<String> noteMd,
      Value<bool> starred,
      Value<bool> hidden,
      Value<String> origin,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$QuestionLocalTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionLocalTable> {
  $$QuestionLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteMd => $composableBuilder(
    column: $table.noteMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionLocalTable> {
  $$QuestionLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteMd => $composableBuilder(
    column: $table.noteMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get starred => $composableBuilder(
    column: $table.starred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionLocalTable> {
  $$QuestionLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteMd =>
      $composableBuilder(column: $table.noteMd, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuestionLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionLocalTable,
          QuestionLocalRow,
          $$QuestionLocalTableFilterComposer,
          $$QuestionLocalTableOrderingComposer,
          $$QuestionLocalTableAnnotationComposer,
          $$QuestionLocalTableCreateCompanionBuilder,
          $$QuestionLocalTableUpdateCompanionBuilder,
          (
            QuestionLocalRow,
            BaseReferences<
              _$AppDatabase,
              $QuestionLocalTable,
              QuestionLocalRow
            >,
          ),
          QuestionLocalRow,
          PrefetchHooks Function()
        > {
  $$QuestionLocalTableTableManager(_$AppDatabase db, $QuestionLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<String> noteMd = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionLocalCompanion(
                questionId: questionId,
                noteMd: noteMd,
                starred: starred,
                hidden: hidden,
                origin: origin,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                Value<String> noteMd = const Value.absent(),
                Value<bool> starred = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<String> origin = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuestionLocalCompanion.insert(
                questionId: questionId,
                noteMd: noteMd,
                starred: starred,
                hidden: hidden,
                origin: origin,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionLocalTable,
      QuestionLocalRow,
      $$QuestionLocalTableFilterComposer,
      $$QuestionLocalTableOrderingComposer,
      $$QuestionLocalTableAnnotationComposer,
      $$QuestionLocalTableCreateCompanionBuilder,
      $$QuestionLocalTableUpdateCompanionBuilder,
      (
        QuestionLocalRow,
        BaseReferences<_$AppDatabase, $QuestionLocalTable, QuestionLocalRow>,
      ),
      QuestionLocalRow,
      PrefetchHooks Function()
    >;
typedef $$ExperiencesTableCreateCompanionBuilder =
    ExperiencesCompanion Function({
      required String id,
      Value<String> company,
      Value<String> role,
      Value<String> round,
      Value<DateTime?> date,
      Value<String?> sourceUrl,
      Value<String> summaryMd,
      Value<String> questionsJson,
      Value<String> credibility,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$ExperiencesTableUpdateCompanionBuilder =
    ExperiencesCompanion Function({
      Value<String> id,
      Value<String> company,
      Value<String> role,
      Value<String> round,
      Value<DateTime?> date,
      Value<String?> sourceUrl,
      Value<String> summaryMd,
      Value<String> questionsJson,
      Value<String> credibility,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ExperiencesTableFilterComposer
    extends Composer<_$AppDatabase, $ExperiencesTable> {
  $$ExperiencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryMd => $composableBuilder(
    column: $table.summaryMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionsJson => $composableBuilder(
    column: $table.questionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credibility => $composableBuilder(
    column: $table.credibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExperiencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExperiencesTable> {
  $$ExperiencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryMd => $composableBuilder(
    column: $table.summaryMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionsJson => $composableBuilder(
    column: $table.questionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credibility => $composableBuilder(
    column: $table.credibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExperiencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExperiencesTable> {
  $$ExperiencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get summaryMd =>
      $composableBuilder(column: $table.summaryMd, builder: (column) => column);

  GeneratedColumn<String> get questionsJson => $composableBuilder(
    column: $table.questionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get credibility => $composableBuilder(
    column: $table.credibility,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ExperiencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExperiencesTable,
          Experience,
          $$ExperiencesTableFilterComposer,
          $$ExperiencesTableOrderingComposer,
          $$ExperiencesTableAnnotationComposer,
          $$ExperiencesTableCreateCompanionBuilder,
          $$ExperiencesTableUpdateCompanionBuilder,
          (
            Experience,
            BaseReferences<_$AppDatabase, $ExperiencesTable, Experience>,
          ),
          Experience,
          PrefetchHooks Function()
        > {
  $$ExperiencesTableTableManager(_$AppDatabase db, $ExperiencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperiencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperiencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperiencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> round = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> summaryMd = const Value.absent(),
                Value<String> questionsJson = const Value.absent(),
                Value<String> credibility = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperiencesCompanion(
                id: id,
                company: company,
                role: role,
                round: round,
                date: date,
                sourceUrl: sourceUrl,
                summaryMd: summaryMd,
                questionsJson: questionsJson,
                credibility: credibility,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> company = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> round = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> summaryMd = const Value.absent(),
                Value<String> questionsJson = const Value.absent(),
                Value<String> credibility = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExperiencesCompanion.insert(
                id: id,
                company: company,
                role: role,
                round: round,
                date: date,
                sourceUrl: sourceUrl,
                summaryMd: summaryMd,
                questionsJson: questionsJson,
                credibility: credibility,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExperiencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExperiencesTable,
      Experience,
      $$ExperiencesTableFilterComposer,
      $$ExperiencesTableOrderingComposer,
      $$ExperiencesTableAnnotationComposer,
      $$ExperiencesTableCreateCompanionBuilder,
      $$ExperiencesTableUpdateCompanionBuilder,
      (
        Experience,
        BaseReferences<_$AppDatabase, $ExperiencesTable, Experience>,
      ),
      Experience,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String mode,
  required String configJson,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<String> status,
  Value<double?> totalScore,
  Value<double> cost,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> mode,
  Value<String> configJson,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String> status,
  Value<double?> totalScore,
  Value<double> cost,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TurnsTable, List<TurnRow>> _turnsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.turns,
    aliasName: 'sessions__id__turns__session_id',
  );

  $$TurnsTableProcessedTableManager get turnsRefs {
    final manager = $$TurnsTableTableManager(
      $_db,
      $_db.turns,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_turnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<MessageRow>>
  _messagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: 'sessions__id__messages__session_id',
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionMemoryTable, List<SessionMemoryRow>>
  _sessionMemoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionMemory,
    aliasName: 'sessions__id__session_memory__session_id',
  );

  $$SessionMemoryTableProcessedTableManager get sessionMemoryRefs {
    final manager = $$SessionMemoryTableTableManager(
      $_db,
      $_db.sessionMemory,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionMemoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionScoresTable, List<SessionScore>>
  _sessionScoresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionScores,
    aliasName: 'sessions__id__session_scores__session_id',
  );

  $$SessionScoresTableProcessedTableManager get sessionScoresRefs {
    final manager = $$SessionScoresTableTableManager(
      $_db,
      $_db.sessionScores,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionScoresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> turnsRefs(
    Expression<bool> Function($$TurnsTableFilterComposer f) f,
  ) {
    final $$TurnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableFilterComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionMemoryRefs(
    Expression<bool> Function($$SessionMemoryTableFilterComposer f) f,
  ) {
    final $$SessionMemoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionMemory,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionMemoryTableFilterComposer(
            $db: $db,
            $table: $db.sessionMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionScoresRefs(
    Expression<bool> Function($$SessionScoresTableFilterComposer f) f,
  ) {
    final $$SessionScoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionScores,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionScoresTableFilterComposer(
            $db: $db,
            $table: $db.sessionScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  Expression<T> turnsRefs<T extends Object>(
    Expression<T> Function($$TurnsTableAnnotationComposer a) f,
  ) {
    final $$TurnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.turns,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TurnsTableAnnotationComposer(
            $db: $db,
            $table: $db.turns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionMemoryRefs<T extends Object>(
    Expression<T> Function($$SessionMemoryTableAnnotationComposer a) f,
  ) {
    final $$SessionMemoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionMemory,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionMemoryTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionMemory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionScoresRefs<T extends Object>(
    Expression<T> Function($$SessionScoresTableAnnotationComposer a) f,
  ) {
    final $$SessionScoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionScores,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionScoresTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionScores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({
            bool turnsRefs,
            bool messagesRefs,
            bool sessionMemoryRefs,
            bool sessionScoresRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> totalScore = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                mode: mode,
                configJson: configJson,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                totalScore: totalScore,
                cost: cost,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mode,
                required String configJson,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> totalScore = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                mode: mode,
                configJson: configJson,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                totalScore: totalScore,
                cost: cost,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                turnsRefs = false,
                messagesRefs = false,
                sessionMemoryRefs = false,
                sessionScoresRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (turnsRefs) db.turns,
                    if (messagesRefs) db.messages,
                    if (sessionMemoryRefs) db.sessionMemory,
                    if (sessionScoresRefs) db.sessionScores,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (turnsRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          TurnRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._turnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).turnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          MessageRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionMemoryRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          SessionMemoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionMemoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionMemoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionScoresRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          SessionScore
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionScoresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionScoresRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({
        bool turnsRefs,
        bool messagesRefs,
        bool sessionMemoryRefs,
        bool sessionScoresRefs,
      })
    >;
typedef $$TurnsTableCreateCompanionBuilder = TurnsCompanion Function({
  required String id,
  required String sessionId,
  required int seq,
  Value<String?> questionId,
  Value<String> questionText,
  Value<String> answerText,
  required DateTime tStartedAt,
  required DateTime tSubmittedAt,
  Value<String?> scoreJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TurnsTableUpdateCompanionBuilder = TurnsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<int> seq,
  Value<String?> questionId,
  Value<String> questionText,
  Value<String> answerText,
  Value<DateTime> tStartedAt,
  Value<DateTime> tSubmittedAt,
  Value<String?> scoreJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TurnsTableReferences
    extends BaseReferences<_$AppDatabase, $TurnsTable, TurnRow> {
  $$TurnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('turns__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TurnsTableFilterComposer extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tStartedAt => $composableBuilder(
    column: $table.tStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tSubmittedAt => $composableBuilder(
    column: $table.tSubmittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scoreJson => $composableBuilder(
    column: $table.scoreJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableOrderingComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tStartedAt => $composableBuilder(
    column: $table.tStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tSubmittedAt => $composableBuilder(
    column: $table.tSubmittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scoreJson => $composableBuilder(
    column: $table.scoreJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tStartedAt => $composableBuilder(
    column: $table.tStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get tSubmittedAt => $composableBuilder(
    column: $table.tSubmittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scoreJson =>
      $composableBuilder(column: $table.scoreJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TurnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TurnsTable,
          TurnRow,
          $$TurnsTableFilterComposer,
          $$TurnsTableOrderingComposer,
          $$TurnsTableAnnotationComposer,
          $$TurnsTableCreateCompanionBuilder,
          $$TurnsTableUpdateCompanionBuilder,
          (TurnRow, $$TurnsTableReferences),
          TurnRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TurnsTableTableManager(_$AppDatabase db, $TurnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TurnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TurnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TurnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String?> questionId = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<String> answerText = const Value.absent(),
                Value<DateTime> tStartedAt = const Value.absent(),
                Value<DateTime> tSubmittedAt = const Value.absent(),
                Value<String?> scoreJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TurnsCompanion(
                id: id,
                sessionId: sessionId,
                seq: seq,
                questionId: questionId,
                questionText: questionText,
                answerText: answerText,
                tStartedAt: tStartedAt,
                tSubmittedAt: tSubmittedAt,
                scoreJson: scoreJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int seq,
                Value<String?> questionId = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<String> answerText = const Value.absent(),
                required DateTime tStartedAt,
                required DateTime tSubmittedAt,
                Value<String?> scoreJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TurnsCompanion.insert(
                id: id,
                sessionId: sessionId,
                seq: seq,
                questionId: questionId,
                questionText: questionText,
                answerText: answerText,
                tStartedAt: tStartedAt,
                tSubmittedAt: tSubmittedAt,
                scoreJson: scoreJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TurnsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$TurnsTableReferences._sessionIdTable(
                          db,
                        ),
                        referencedColumn: $$TurnsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TurnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TurnsTable,
      TurnRow,
      $$TurnsTableFilterComposer,
      $$TurnsTableOrderingComposer,
      $$TurnsTableAnnotationComposer,
      $$TurnsTableCreateCompanionBuilder,
      $$TurnsTableUpdateCompanionBuilder,
      (TurnRow, $$TurnsTableReferences),
      TurnRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String sessionId,
  required String role,
  Value<String> content,
  Value<String?> toolCalls,
  Value<int> tokens,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> role,
  Value<String> content,
  Value<String?> toolCalls,
  Value<int> tokens,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, MessageRow> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('messages__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolCalls => $composableBuilder(
    column: $table.toolCalls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokens => $composableBuilder(
    column: $table.tokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolCalls => $composableBuilder(
    column: $table.toolCalls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokens => $composableBuilder(
    column: $table.tokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get toolCalls =>
      $composableBuilder(column: $table.toolCalls, builder: (column) => column);

  GeneratedColumn<int> get tokens =>
      $composableBuilder(column: $table.tokens, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (MessageRow, $$MessagesTableReferences),
          MessageRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> toolCalls = const Value.absent(),
                Value<int> tokens = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                toolCalls: toolCalls,
                tokens: tokens,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String role,
                Value<String> content = const Value.absent(),
                Value<String?> toolCalls = const Value.absent(),
                Value<int> tokens = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                content: content,
                toolCalls: toolCalls,
                tokens: tokens,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$MessagesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$MessagesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, $$MessagesTableReferences),
      MessageRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SessionMemoryTableCreateCompanionBuilder =
    SessionMemoryCompanion Function({
      required String sessionId,
      required String memoryJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionMemoryTableUpdateCompanionBuilder =
    SessionMemoryCompanion Function({
      Value<String> sessionId,
      Value<String> memoryJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SessionMemoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionMemoryTable, SessionMemoryRow> {
  $$SessionMemoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_memory__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionMemoryTableFilterComposer
    extends Composer<_$AppDatabase, $SessionMemoryTable> {
  $$SessionMemoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memoryJson => $composableBuilder(
    column: $table.memoryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionMemoryTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionMemoryTable> {
  $$SessionMemoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memoryJson => $composableBuilder(
    column: $table.memoryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionMemoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionMemoryTable> {
  $$SessionMemoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memoryJson => $composableBuilder(
    column: $table.memoryJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionMemoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionMemoryTable,
          SessionMemoryRow,
          $$SessionMemoryTableFilterComposer,
          $$SessionMemoryTableOrderingComposer,
          $$SessionMemoryTableAnnotationComposer,
          $$SessionMemoryTableCreateCompanionBuilder,
          $$SessionMemoryTableUpdateCompanionBuilder,
          (SessionMemoryRow, $$SessionMemoryTableReferences),
          SessionMemoryRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionMemoryTableTableManager(_$AppDatabase db, $SessionMemoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionMemoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionMemoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionMemoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> memoryJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionMemoryCompanion(
                sessionId: sessionId,
                memoryJson: memoryJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String memoryJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionMemoryCompanion.insert(
                sessionId: sessionId,
                memoryJson: memoryJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionMemoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionMemoryTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionMemoryTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionMemoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionMemoryTable,
      SessionMemoryRow,
      $$SessionMemoryTableFilterComposer,
      $$SessionMemoryTableOrderingComposer,
      $$SessionMemoryTableAnnotationComposer,
      $$SessionMemoryTableCreateCompanionBuilder,
      $$SessionMemoryTableUpdateCompanionBuilder,
      (SessionMemoryRow, $$SessionMemoryTableReferences),
      SessionMemoryRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SessionScoresTableCreateCompanionBuilder =
    SessionScoresCompanion Function({
      required String sessionId,
      required String aggregateJson,
      required String rubricVersion,
      required String model,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SessionScoresTableUpdateCompanionBuilder =
    SessionScoresCompanion Function({
      Value<String> sessionId,
      Value<String> aggregateJson,
      Value<String> rubricVersion,
      Value<String> model,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SessionScoresTableReferences
    extends BaseReferences<_$AppDatabase, $SessionScoresTable, SessionScore> {
  $$SessionScoresTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_scores__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionScoresTableFilterComposer
    extends Composer<_$AppDatabase, $SessionScoresTable> {
  $$SessionScoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get aggregateJson => $composableBuilder(
    column: $table.aggregateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rubricVersion => $composableBuilder(
    column: $table.rubricVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionScoresTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionScoresTable> {
  $$SessionScoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get aggregateJson => $composableBuilder(
    column: $table.aggregateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rubricVersion => $composableBuilder(
    column: $table.rubricVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionScoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionScoresTable> {
  $$SessionScoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get aggregateJson => $composableBuilder(
    column: $table.aggregateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rubricVersion => $composableBuilder(
    column: $table.rubricVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionScoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionScoresTable,
          SessionScore,
          $$SessionScoresTableFilterComposer,
          $$SessionScoresTableOrderingComposer,
          $$SessionScoresTableAnnotationComposer,
          $$SessionScoresTableCreateCompanionBuilder,
          $$SessionScoresTableUpdateCompanionBuilder,
          (SessionScore, $$SessionScoresTableReferences),
          SessionScore,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionScoresTableTableManager(_$AppDatabase db, $SessionScoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionScoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionScoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionScoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> aggregateJson = const Value.absent(),
                Value<String> rubricVersion = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionScoresCompanion(
                sessionId: sessionId,
                aggregateJson: aggregateJson,
                rubricVersion: rubricVersion,
                model: model,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String aggregateJson,
                required String rubricVersion,
                required String model,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionScoresCompanion.insert(
                sessionId: sessionId,
                aggregateJson: aggregateJson,
                rubricVersion: rubricVersion,
                model: model,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionScoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionScoresTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionScoresTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionScoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionScoresTable,
      SessionScore,
      $$SessionScoresTableFilterComposer,
      $$SessionScoresTableOrderingComposer,
      $$SessionScoresTableAnnotationComposer,
      $$SessionScoresTableCreateCompanionBuilder,
      $$SessionScoresTableUpdateCompanionBuilder,
      (SessionScore, $$SessionScoresTableReferences),
      SessionScore,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SearchCacheTableCreateCompanionBuilder =
    SearchCacheCompanion Function({
      required String urlHash,
      required String url,
      Value<String> title,
      required String textMd,
      required DateTime fetchedAt,
      Value<int> ttlS,
      Value<int> rowid,
    });
typedef $$SearchCacheTableUpdateCompanionBuilder =
    SearchCacheCompanion Function({
      Value<String> urlHash,
      Value<String> url,
      Value<String> title,
      Value<String> textMd,
      Value<DateTime> fetchedAt,
      Value<int> ttlS,
      Value<int> rowid,
    });

class $$SearchCacheTableFilterComposer
    extends Composer<_$AppDatabase, $SearchCacheTable> {
  $$SearchCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get urlHash => $composableBuilder(
    column: $table.urlHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textMd => $composableBuilder(
    column: $table.textMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlS => $composableBuilder(
    column: $table.ttlS,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchCacheTable> {
  $$SearchCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get urlHash => $composableBuilder(
    column: $table.urlHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textMd => $composableBuilder(
    column: $table.textMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlS => $composableBuilder(
    column: $table.ttlS,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchCacheTable> {
  $$SearchCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get urlHash =>
      $composableBuilder(column: $table.urlHash, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textMd =>
      $composableBuilder(column: $table.textMd, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<int> get ttlS =>
      $composableBuilder(column: $table.ttlS, builder: (column) => column);
}

class $$SearchCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchCacheTable,
          SearchCacheRow,
          $$SearchCacheTableFilterComposer,
          $$SearchCacheTableOrderingComposer,
          $$SearchCacheTableAnnotationComposer,
          $$SearchCacheTableCreateCompanionBuilder,
          $$SearchCacheTableUpdateCompanionBuilder,
          (
            SearchCacheRow,
            BaseReferences<_$AppDatabase, $SearchCacheTable, SearchCacheRow>,
          ),
          SearchCacheRow,
          PrefetchHooks Function()
        > {
  $$SearchCacheTableTableManager(_$AppDatabase db, $SearchCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> urlHash = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> textMd = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> ttlS = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchCacheCompanion(
                urlHash: urlHash,
                url: url,
                title: title,
                textMd: textMd,
                fetchedAt: fetchedAt,
                ttlS: ttlS,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String urlHash,
                required String url,
                Value<String> title = const Value.absent(),
                required String textMd,
                required DateTime fetchedAt,
                Value<int> ttlS = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchCacheCompanion.insert(
                urlHash: urlHash,
                url: url,
                title: title,
                textMd: textMd,
                fetchedAt: fetchedAt,
                ttlS: ttlS,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchCacheTable,
      SearchCacheRow,
      $$SearchCacheTableFilterComposer,
      $$SearchCacheTableOrderingComposer,
      $$SearchCacheTableAnnotationComposer,
      $$SearchCacheTableCreateCompanionBuilder,
      $$SearchCacheTableUpdateCompanionBuilder,
      (
        SearchCacheRow,
        BaseReferences<_$AppDatabase, $SearchCacheTable, SearchCacheRow>,
      ),
      SearchCacheRow,
      PrefetchHooks Function()
    >;
typedef $$FactChecksTableCreateCompanionBuilder = FactChecksCompanion Function({
  required String claimHash,
  required String claim,
  required String verdict,
  Value<double> confidence,
  Value<String> sourcesJson,
  required DateTime checkedAt,
  Value<int> ttlS,
  Value<int> rowid,
});
typedef $$FactChecksTableUpdateCompanionBuilder = FactChecksCompanion Function({
  Value<String> claimHash,
  Value<String> claim,
  Value<String> verdict,
  Value<double> confidence,
  Value<String> sourcesJson,
  Value<DateTime> checkedAt,
  Value<int> ttlS,
  Value<int> rowid,
});

class $$FactChecksTableFilterComposer
    extends Composer<_$AppDatabase, $FactChecksTable> {
  $$FactChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get claimHash => $composableBuilder(
    column: $table.claimHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claim => $composableBuilder(
    column: $table.claim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcesJson => $composableBuilder(
    column: $table.sourcesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ttlS => $composableBuilder(
    column: $table.ttlS,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FactChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $FactChecksTable> {
  $$FactChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get claimHash => $composableBuilder(
    column: $table.claimHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claim => $composableBuilder(
    column: $table.claim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcesJson => $composableBuilder(
    column: $table.sourcesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ttlS => $composableBuilder(
    column: $table.ttlS,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FactChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FactChecksTable> {
  $$FactChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get claimHash =>
      $composableBuilder(column: $table.claimHash, builder: (column) => column);

  GeneratedColumn<String> get claim =>
      $composableBuilder(column: $table.claim, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourcesJson => $composableBuilder(
    column: $table.sourcesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  GeneratedColumn<int> get ttlS =>
      $composableBuilder(column: $table.ttlS, builder: (column) => column);
}

class $$FactChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FactChecksTable,
          FactCheck,
          $$FactChecksTableFilterComposer,
          $$FactChecksTableOrderingComposer,
          $$FactChecksTableAnnotationComposer,
          $$FactChecksTableCreateCompanionBuilder,
          $$FactChecksTableUpdateCompanionBuilder,
          (
            FactCheck,
            BaseReferences<_$AppDatabase, $FactChecksTable, FactCheck>,
          ),
          FactCheck,
          PrefetchHooks Function()
        > {
  $$FactChecksTableTableManager(_$AppDatabase db, $FactChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FactChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FactChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FactChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> claimHash = const Value.absent(),
                Value<String> claim = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> sourcesJson = const Value.absent(),
                Value<DateTime> checkedAt = const Value.absent(),
                Value<int> ttlS = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactChecksCompanion(
                claimHash: claimHash,
                claim: claim,
                verdict: verdict,
                confidence: confidence,
                sourcesJson: sourcesJson,
                checkedAt: checkedAt,
                ttlS: ttlS,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String claimHash,
                required String claim,
                required String verdict,
                Value<double> confidence = const Value.absent(),
                Value<String> sourcesJson = const Value.absent(),
                required DateTime checkedAt,
                Value<int> ttlS = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactChecksCompanion.insert(
                claimHash: claimHash,
                claim: claim,
                verdict: verdict,
                confidence: confidence,
                sourcesJson: sourcesJson,
                checkedAt: checkedAt,
                ttlS: ttlS,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FactChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FactChecksTable,
      FactCheck,
      $$FactChecksTableFilterComposer,
      $$FactChecksTableOrderingComposer,
      $$FactChecksTableAnnotationComposer,
      $$FactChecksTableCreateCompanionBuilder,
      $$FactChecksTableUpdateCompanionBuilder,
      (FactCheck, BaseReferences<_$AppDatabase, $FactChecksTable, FactCheck>),
      FactCheck,
      PrefetchHooks Function()
    >;
typedef $$DocSourcesTableCreateCompanionBuilder = DocSourcesCompanion Function({
  required String domain,
  Value<String> authority,
  Value<DateTime?> lastOkAt,
  Value<bool> blocked,
  Value<int> rowid,
});
typedef $$DocSourcesTableUpdateCompanionBuilder = DocSourcesCompanion Function({
  Value<String> domain,
  Value<String> authority,
  Value<DateTime?> lastOkAt,
  Value<bool> blocked,
  Value<int> rowid,
});

class $$DocSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $DocSourcesTable> {
  $$DocSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authority => $composableBuilder(
    column: $table.authority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOkAt => $composableBuilder(
    column: $table.lastOkAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get blocked => $composableBuilder(
    column: $table.blocked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $DocSourcesTable> {
  $$DocSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authority => $composableBuilder(
    column: $table.authority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOkAt => $composableBuilder(
    column: $table.lastOkAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blocked => $composableBuilder(
    column: $table.blocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocSourcesTable> {
  $$DocSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get authority =>
      $composableBuilder(column: $table.authority, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOkAt =>
      $composableBuilder(column: $table.lastOkAt, builder: (column) => column);

  GeneratedColumn<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => column);
}

class $$DocSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocSourcesTable,
          DocSource,
          $$DocSourcesTableFilterComposer,
          $$DocSourcesTableOrderingComposer,
          $$DocSourcesTableAnnotationComposer,
          $$DocSourcesTableCreateCompanionBuilder,
          $$DocSourcesTableUpdateCompanionBuilder,
          (
            DocSource,
            BaseReferences<_$AppDatabase, $DocSourcesTable, DocSource>,
          ),
          DocSource,
          PrefetchHooks Function()
        > {
  $$DocSourcesTableTableManager(_$AppDatabase db, $DocSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> domain = const Value.absent(),
                Value<String> authority = const Value.absent(),
                Value<DateTime?> lastOkAt = const Value.absent(),
                Value<bool> blocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocSourcesCompanion(
                domain: domain,
                authority: authority,
                lastOkAt: lastOkAt,
                blocked: blocked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String domain,
                Value<String> authority = const Value.absent(),
                Value<DateTime?> lastOkAt = const Value.absent(),
                Value<bool> blocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocSourcesCompanion.insert(
                domain: domain,
                authority: authority,
                lastOkAt: lastOkAt,
                blocked: blocked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocSourcesTable,
      DocSource,
      $$DocSourcesTableFilterComposer,
      $$DocSourcesTableOrderingComposer,
      $$DocSourcesTableAnnotationComposer,
      $$DocSourcesTableCreateCompanionBuilder,
      $$DocSourcesTableUpdateCompanionBuilder,
      (DocSource, BaseReferences<_$AppDatabase, $DocSourcesTable, DocSource>),
      DocSource,
      PrefetchHooks Function()
    >;
typedef $$QuestionEmbeddingsTableCreateCompanionBuilder =
    QuestionEmbeddingsCompanion Function({
      required String questionId,
      required String model,
      required int dim,
      required Uint8List vec,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QuestionEmbeddingsTableUpdateCompanionBuilder =
    QuestionEmbeddingsCompanion Function({
      Value<String> questionId,
      Value<String> model,
      Value<int> dim,
      Value<Uint8List> vec,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$QuestionEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionEmbeddingsTable> {
  $$QuestionEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dim => $composableBuilder(
    column: $table.dim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vec => $composableBuilder(
    column: $table.vec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionEmbeddingsTable> {
  $$QuestionEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dim => $composableBuilder(
    column: $table.dim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vec => $composableBuilder(
    column: $table.vec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionEmbeddingsTable> {
  $$QuestionEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get dim =>
      $composableBuilder(column: $table.dim, builder: (column) => column);

  GeneratedColumn<Uint8List> get vec =>
      $composableBuilder(column: $table.vec, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuestionEmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionEmbeddingsTable,
          QuestionEmbeddingRow,
          $$QuestionEmbeddingsTableFilterComposer,
          $$QuestionEmbeddingsTableOrderingComposer,
          $$QuestionEmbeddingsTableAnnotationComposer,
          $$QuestionEmbeddingsTableCreateCompanionBuilder,
          $$QuestionEmbeddingsTableUpdateCompanionBuilder,
          (
            QuestionEmbeddingRow,
            BaseReferences<
              _$AppDatabase,
              $QuestionEmbeddingsTable,
              QuestionEmbeddingRow
            >,
          ),
          QuestionEmbeddingRow,
          PrefetchHooks Function()
        > {
  $$QuestionEmbeddingsTableTableManager(
    _$AppDatabase db,
    $QuestionEmbeddingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionEmbeddingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> dim = const Value.absent(),
                Value<Uint8List> vec = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionEmbeddingsCompanion(
                questionId: questionId,
                model: model,
                dim: dim,
                vec: vec,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required String model,
                required int dim,
                required Uint8List vec,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuestionEmbeddingsCompanion.insert(
                questionId: questionId,
                model: model,
                dim: dim,
                vec: vec,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionEmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionEmbeddingsTable,
      QuestionEmbeddingRow,
      $$QuestionEmbeddingsTableFilterComposer,
      $$QuestionEmbeddingsTableOrderingComposer,
      $$QuestionEmbeddingsTableAnnotationComposer,
      $$QuestionEmbeddingsTableCreateCompanionBuilder,
      $$QuestionEmbeddingsTableUpdateCompanionBuilder,
      (
        QuestionEmbeddingRow,
        BaseReferences<
          _$AppDatabase,
          $QuestionEmbeddingsTable,
          QuestionEmbeddingRow
        >,
      ),
      QuestionEmbeddingRow,
      PrefetchHooks Function()
    >;
typedef $$QuestionEdgesTableCreateCompanionBuilder =
    QuestionEdgesCompanion Function({
      required String src,
      required String dst,
      required String kind,
      Value<double> weight,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$QuestionEdgesTableUpdateCompanionBuilder =
    QuestionEdgesCompanion Function({
      Value<String> src,
      Value<String> dst,
      Value<String> kind,
      Value<double> weight,
      Value<String> source,
      Value<int> rowid,
    });

class $$QuestionEdgesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionEdgesTable> {
  $$QuestionEdgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dst => $composableBuilder(
    column: $table.dst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionEdgesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionEdgesTable> {
  $$QuestionEdgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get src => $composableBuilder(
    column: $table.src,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dst => $composableBuilder(
    column: $table.dst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionEdgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionEdgesTable> {
  $$QuestionEdgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get src =>
      $composableBuilder(column: $table.src, builder: (column) => column);

  GeneratedColumn<String> get dst =>
      $composableBuilder(column: $table.dst, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$QuestionEdgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionEdgesTable,
          QuestionEdgeRow,
          $$QuestionEdgesTableFilterComposer,
          $$QuestionEdgesTableOrderingComposer,
          $$QuestionEdgesTableAnnotationComposer,
          $$QuestionEdgesTableCreateCompanionBuilder,
          $$QuestionEdgesTableUpdateCompanionBuilder,
          (
            QuestionEdgeRow,
            BaseReferences<_$AppDatabase, $QuestionEdgesTable, QuestionEdgeRow>,
          ),
          QuestionEdgeRow,
          PrefetchHooks Function()
        > {
  $$QuestionEdgesTableTableManager(_$AppDatabase db, $QuestionEdgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionEdgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionEdgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionEdgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> src = const Value.absent(),
                Value<String> dst = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionEdgesCompanion(
                src: src,
                dst: dst,
                kind: kind,
                weight: weight,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String src,
                required String dst,
                required String kind,
                Value<double> weight = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionEdgesCompanion.insert(
                src: src,
                dst: dst,
                kind: kind,
                weight: weight,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionEdgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionEdgesTable,
      QuestionEdgeRow,
      $$QuestionEdgesTableFilterComposer,
      $$QuestionEdgesTableOrderingComposer,
      $$QuestionEdgesTableAnnotationComposer,
      $$QuestionEdgesTableCreateCompanionBuilder,
      $$QuestionEdgesTableUpdateCompanionBuilder,
      (
        QuestionEdgeRow,
        BaseReferences<_$AppDatabase, $QuestionEdgesTable, QuestionEdgeRow>,
      ),
      QuestionEdgeRow,
      PrefetchHooks Function()
    >;
typedef $$ClusterMembersTableCreateCompanionBuilder =
    ClusterMembersCompanion Function({
      required String clusterId,
      required String questionId,
      Value<String> label,
      Value<int> rowid,
    });
typedef $$ClusterMembersTableUpdateCompanionBuilder =
    ClusterMembersCompanion Function({
      Value<String> clusterId,
      Value<String> questionId,
      Value<String> label,
      Value<int> rowid,
    });

class $$ClusterMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ClusterMembersTable> {
  $$ClusterMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clusterId => $composableBuilder(
    column: $table.clusterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClusterMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ClusterMembersTable> {
  $$ClusterMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clusterId => $composableBuilder(
    column: $table.clusterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClusterMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClusterMembersTable> {
  $$ClusterMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clusterId =>
      $composableBuilder(column: $table.clusterId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$ClusterMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClusterMembersTable,
          ClusterMember,
          $$ClusterMembersTableFilterComposer,
          $$ClusterMembersTableOrderingComposer,
          $$ClusterMembersTableAnnotationComposer,
          $$ClusterMembersTableCreateCompanionBuilder,
          $$ClusterMembersTableUpdateCompanionBuilder,
          (
            ClusterMember,
            BaseReferences<_$AppDatabase, $ClusterMembersTable, ClusterMember>,
          ),
          ClusterMember,
          PrefetchHooks Function()
        > {
  $$ClusterMembersTableTableManager(
    _$AppDatabase db,
    $ClusterMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClusterMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClusterMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClusterMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clusterId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClusterMembersCompanion(
                clusterId: clusterId,
                questionId: questionId,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clusterId,
                required String questionId,
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClusterMembersCompanion.insert(
                clusterId: clusterId,
                questionId: questionId,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClusterMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClusterMembersTable,
      ClusterMember,
      $$ClusterMembersTableFilterComposer,
      $$ClusterMembersTableOrderingComposer,
      $$ClusterMembersTableAnnotationComposer,
      $$ClusterMembersTableCreateCompanionBuilder,
      $$ClusterMembersTableUpdateCompanionBuilder,
      (
        ClusterMember,
        BaseReferences<_$AppDatabase, $ClusterMembersTable, ClusterMember>,
      ),
      ClusterMember,
      PrefetchHooks Function()
    >;
typedef $$BankSourcesTableCreateCompanionBuilder =
    BankSourcesCompanion Function({
      required String id,
      required String kind,
      required String url,
      Value<String> license,
      Value<DateTime?> lastSync,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$BankSourcesTableUpdateCompanionBuilder =
    BankSourcesCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> url,
      Value<String> license,
      Value<DateTime?> lastSync,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$BankSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $BankSourcesTable> {
  $$BankSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $BankSourcesTable> {
  $$BankSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankSourcesTable> {
  $$BankSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$BankSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankSourcesTable,
          BankSource,
          $$BankSourcesTableFilterComposer,
          $$BankSourcesTableOrderingComposer,
          $$BankSourcesTableAnnotationComposer,
          $$BankSourcesTableCreateCompanionBuilder,
          $$BankSourcesTableUpdateCompanionBuilder,
          (
            BankSource,
            BaseReferences<_$AppDatabase, $BankSourcesTable, BankSource>,
          ),
          BankSource,
          PrefetchHooks Function()
        > {
  $$BankSourcesTableTableManager(_$AppDatabase db, $BankSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> license = const Value.absent(),
                Value<DateTime?> lastSync = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BankSourcesCompanion(
                id: id,
                kind: kind,
                url: url,
                license: license,
                lastSync: lastSync,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String url,
                Value<String> license = const Value.absent(),
                Value<DateTime?> lastSync = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BankSourcesCompanion.insert(
                id: id,
                kind: kind,
                url: url,
                license: license,
                lastSync: lastSync,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankSourcesTable,
      BankSource,
      $$BankSourcesTableFilterComposer,
      $$BankSourcesTableOrderingComposer,
      $$BankSourcesTableAnnotationComposer,
      $$BankSourcesTableCreateCompanionBuilder,
      $$BankSourcesTableUpdateCompanionBuilder,
      (
        BankSource,
        BaseReferences<_$AppDatabase, $BankSourcesTable, BankSource>,
      ),
      BankSource,
      PrefetchHooks Function()
    >;
typedef $$LlmCallsTableCreateCompanionBuilder = LlmCallsCompanion Function({
  required String id,
  Value<String?> sessionId,
  required String role,
  required String provider,
  required String model,
  Value<int> tokensIn,
  Value<int> tokensOut,
  Value<int> latencyMs,
  Value<double> cost,
  Value<String?> error,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LlmCallsTableUpdateCompanionBuilder = LlmCallsCompanion Function({
  Value<String> id,
  Value<String?> sessionId,
  Value<String> role,
  Value<String> provider,
  Value<String> model,
  Value<int> tokensIn,
  Value<int> tokensOut,
  Value<int> latencyMs,
  Value<double> cost,
  Value<String?> error,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LlmCallsTableFilterComposer
    extends Composer<_$AppDatabase, $LlmCallsTable> {
  $$LlmCallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LlmCallsTableOrderingComposer
    extends Composer<_$AppDatabase, $LlmCallsTable> {
  $$LlmCallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LlmCallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LlmCallsTable> {
  $$LlmCallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get tokensIn =>
      $composableBuilder(column: $table.tokensIn, builder: (column) => column);

  GeneratedColumn<int> get tokensOut =>
      $composableBuilder(column: $table.tokensOut, builder: (column) => column);

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LlmCallsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LlmCallsTable,
          LlmCall,
          $$LlmCallsTableFilterComposer,
          $$LlmCallsTableOrderingComposer,
          $$LlmCallsTableAnnotationComposer,
          $$LlmCallsTableCreateCompanionBuilder,
          $$LlmCallsTableUpdateCompanionBuilder,
          (LlmCall, BaseReferences<_$AppDatabase, $LlmCallsTable, LlmCall>),
          LlmCall,
          PrefetchHooks Function()
        > {
  $$LlmCallsTableTableManager(_$AppDatabase db, $LlmCallsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LlmCallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LlmCallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LlmCallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> tokensIn = const Value.absent(),
                Value<int> tokensOut = const Value.absent(),
                Value<int> latencyMs = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LlmCallsCompanion(
                id: id,
                sessionId: sessionId,
                role: role,
                provider: provider,
                model: model,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
                latencyMs: latencyMs,
                cost: cost,
                error: error,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> sessionId = const Value.absent(),
                required String role,
                required String provider,
                required String model,
                Value<int> tokensIn = const Value.absent(),
                Value<int> tokensOut = const Value.absent(),
                Value<int> latencyMs = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<String?> error = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LlmCallsCompanion.insert(
                id: id,
                sessionId: sessionId,
                role: role,
                provider: provider,
                model: model,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
                latencyMs: latencyMs,
                cost: cost,
                error: error,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LlmCallsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LlmCallsTable,
      LlmCall,
      $$LlmCallsTableFilterComposer,
      $$LlmCallsTableOrderingComposer,
      $$LlmCallsTableAnnotationComposer,
      $$LlmCallsTableCreateCompanionBuilder,
      $$LlmCallsTableUpdateCompanionBuilder,
      (LlmCall, BaseReferences<_$AppDatabase, $LlmCallsTable, LlmCall>),
      LlmCall,
      PrefetchHooks Function()
    >;
typedef $$BankMetaTableCreateCompanionBuilder = BankMetaCompanion Function({
  Value<String> activeDir,
  Value<String> version,
  Value<String> commit,
  Value<DateTime?> installedAt,
  Value<bool> signatureOk,
  Value<int> id,
});
typedef $$BankMetaTableUpdateCompanionBuilder = BankMetaCompanion Function({
  Value<String> activeDir,
  Value<String> version,
  Value<String> commit,
  Value<DateTime?> installedAt,
  Value<bool> signatureOk,
  Value<int> id,
});

class $$BankMetaTableFilterComposer
    extends Composer<_$AppDatabase, $BankMetaTable> {
  $$BankMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get activeDir => $composableBuilder(
    column: $table.activeDir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commit => $composableBuilder(
    column: $table.commit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get signatureOk => $composableBuilder(
    column: $table.signatureOk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $BankMetaTable> {
  $$BankMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get activeDir => $composableBuilder(
    column: $table.activeDir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commit => $composableBuilder(
    column: $table.commit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get signatureOk => $composableBuilder(
    column: $table.signatureOk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankMetaTable> {
  $$BankMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get activeDir =>
      $composableBuilder(column: $table.activeDir, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get commit =>
      $composableBuilder(column: $table.commit, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get signatureOk => $composableBuilder(
    column: $table.signatureOk,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$BankMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankMetaTable,
          BankMetaRow,
          $$BankMetaTableFilterComposer,
          $$BankMetaTableOrderingComposer,
          $$BankMetaTableAnnotationComposer,
          $$BankMetaTableCreateCompanionBuilder,
          $$BankMetaTableUpdateCompanionBuilder,
          (
            BankMetaRow,
            BaseReferences<_$AppDatabase, $BankMetaTable, BankMetaRow>,
          ),
          BankMetaRow,
          PrefetchHooks Function()
        > {
  $$BankMetaTableTableManager(_$AppDatabase db, $BankMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> activeDir = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> commit = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<bool> signatureOk = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => BankMetaCompanion(
                activeDir: activeDir,
                version: version,
                commit: commit,
                installedAt: installedAt,
                signatureOk: signatureOk,
                id: id,
              ),
          createCompanionCallback:
              ({
                Value<String> activeDir = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> commit = const Value.absent(),
                Value<DateTime?> installedAt = const Value.absent(),
                Value<bool> signatureOk = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => BankMetaCompanion.insert(
                activeDir: activeDir,
                version: version,
                commit: commit,
                installedAt: installedAt,
                signatureOk: signatureOk,
                id: id,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankMetaTable,
      BankMetaRow,
      $$BankMetaTableFilterComposer,
      $$BankMetaTableOrderingComposer,
      $$BankMetaTableAnnotationComposer,
      $$BankMetaTableCreateCompanionBuilder,
      $$BankMetaTableUpdateCompanionBuilder,
      (BankMetaRow, BaseReferences<_$AppDatabase, $BankMetaTable, BankMetaRow>),
      BankMetaRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ProvidersTableTableManager get providers =>
      $$ProvidersTableTableManager(_db, _db.providers);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$QuestionLocalTableTableManager get questionLocal =>
      $$QuestionLocalTableTableManager(_db, _db.questionLocal);
  $$ExperiencesTableTableManager get experiences =>
      $$ExperiencesTableTableManager(_db, _db.experiences);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$TurnsTableTableManager get turns =>
      $$TurnsTableTableManager(_db, _db.turns);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$SessionMemoryTableTableManager get sessionMemory =>
      $$SessionMemoryTableTableManager(_db, _db.sessionMemory);
  $$SessionScoresTableTableManager get sessionScores =>
      $$SessionScoresTableTableManager(_db, _db.sessionScores);
  $$SearchCacheTableTableManager get searchCache =>
      $$SearchCacheTableTableManager(_db, _db.searchCache);
  $$FactChecksTableTableManager get factChecks =>
      $$FactChecksTableTableManager(_db, _db.factChecks);
  $$DocSourcesTableTableManager get docSources =>
      $$DocSourcesTableTableManager(_db, _db.docSources);
  $$QuestionEmbeddingsTableTableManager get questionEmbeddings =>
      $$QuestionEmbeddingsTableTableManager(_db, _db.questionEmbeddings);
  $$QuestionEdgesTableTableManager get questionEdges =>
      $$QuestionEdgesTableTableManager(_db, _db.questionEdges);
  $$ClusterMembersTableTableManager get clusterMembers =>
      $$ClusterMembersTableTableManager(_db, _db.clusterMembers);
  $$BankSourcesTableTableManager get bankSources =>
      $$BankSourcesTableTableManager(_db, _db.bankSources);
  $$LlmCallsTableTableManager get llmCalls =>
      $$LlmCallsTableTableManager(_db, _db.llmCalls);
  $$BankMetaTableTableManager get bankMeta =>
      $$BankMetaTableTableManager(_db, _db.bankMeta);
}
