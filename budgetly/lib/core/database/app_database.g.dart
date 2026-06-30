// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WalletsTable extends Wallets with TableInfo<$WalletsTable, Wallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialBalanceMinorMeta =
      const VerificationMeta('initialBalanceMinor');
  @override
  late final GeneratedColumn<int> initialBalanceMinor = GeneratedColumn<int>(
    'initial_balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    currencyCode,
    initialBalanceMinor,
    archived,
    sortOrder,
    color,
    icon,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('initial_balance_minor')) {
      context.handle(
        _initialBalanceMinorMeta,
        initialBalanceMinor.isAcceptableOrUnknown(
          data['initial_balance_minor']!,
          _initialBalanceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialBalanceMinorMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      initialBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance_minor'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }
}

class Wallet extends DataClass implements Insertable<Wallet> {
  final int id;
  final String name;
  final String type;
  final String currencyCode;
  final int initialBalanceMinor;
  final bool archived;
  final int sortOrder;
  final int? color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.initialBalanceMinor,
    required this.archived,
    required this.sortOrder,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['currency_code'] = Variable<String>(currencyCode);
    map['initial_balance_minor'] = Variable<int>(initialBalanceMinor);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      currencyCode: Value(currencyCode),
      initialBalanceMinor: Value(initialBalanceMinor),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Wallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wallet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      initialBalanceMinor: serializer.fromJson<int>(
        json['initialBalanceMinor'],
      ),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      color: serializer.fromJson<int?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'initialBalanceMinor': serializer.toJson<int>(initialBalanceMinor),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'color': serializer.toJson<int?>(color),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Wallet copyWith({
    int? id,
    String? name,
    String? type,
    String? currencyCode,
    int? initialBalanceMinor,
    bool? archived,
    int? sortOrder,
    Value<int?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Wallet(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    currencyCode: currencyCode ?? this.currencyCode,
    initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Wallet copyWithCompanion(WalletsCompanion data) {
    return Wallet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      initialBalanceMinor: data.initialBalanceMinor.present
          ? data.initialBalanceMinor.value
          : this.initialBalanceMinor,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wallet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('initialBalanceMinor: $initialBalanceMinor, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    currencyCode,
    initialBalanceMinor,
    archived,
    sortOrder,
    color,
    icon,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wallet &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.currencyCode == this.currencyCode &&
          other.initialBalanceMinor == this.initialBalanceMinor &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WalletsCompanion extends UpdateCompanion<Wallet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> currencyCode;
  final Value<int> initialBalanceMinor;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<int?> color;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WalletsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.initialBalanceMinor = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required String currencyCode,
    required int initialBalanceMinor,
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       currencyCode = Value(currencyCode),
       initialBalanceMinor = Value(initialBalanceMinor);
  static Insertable<Wallet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? currencyCode,
    Expression<int>? initialBalanceMinor,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (initialBalanceMinor != null)
        'initial_balance_minor': initialBalanceMinor,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WalletsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? currencyCode,
    Value<int>? initialBalanceMinor,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<int?>? color,
    Value<String?>? icon,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WalletsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currencyCode: currencyCode ?? this.currencyCode,
      initialBalanceMinor: initialBalanceMinor ?? this.initialBalanceMinor,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (initialBalanceMinor.present) {
      map['initial_balance_minor'] = Variable<int>(initialBalanceMinor.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('initialBalanceMinor: $initialBalanceMinor, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _mainCategoryPkMeta = const VerificationMeta(
    'mainCategoryPk',
  );
  @override
  late final GeneratedColumn<int> mainCategoryPk = GeneratedColumn<int>(
    'main_category_pk',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    kind,
    mainCategoryPk,
    archived,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('main_category_pk')) {
      context.handle(
        _mainCategoryPkMeta,
        mainCategoryPk.isAcceptableOrUnknown(
          data['main_category_pk']!,
          _mainCategoryPkMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      mainCategoryPk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}main_category_pk'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String? icon;
  final int? color;
  final String kind;
  final int? mainCategoryPk;
  final bool archived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.kind,
    this.mainCategoryPk,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || mainCategoryPk != null) {
      map['main_category_pk'] = Variable<int>(mainCategoryPk);
    }
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      kind: Value(kind),
      mainCategoryPk: mainCategoryPk == null && nullToAbsent
          ? const Value.absent()
          : Value(mainCategoryPk),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<int?>(json['color']),
      kind: serializer.fromJson<String>(json['kind']),
      mainCategoryPk: serializer.fromJson<int?>(json['mainCategoryPk']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<int?>(color),
      'kind': serializer.toJson<String>(kind),
      'mainCategoryPk': serializer.toJson<int?>(mainCategoryPk),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<int?> color = const Value.absent(),
    String? kind,
    Value<int?> mainCategoryPk = const Value.absent(),
    bool? archived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    kind: kind ?? this.kind,
    mainCategoryPk: mainCategoryPk.present
        ? mainCategoryPk.value
        : this.mainCategoryPk,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      kind: data.kind.present ? data.kind.value : this.kind,
      mainCategoryPk: data.mainCategoryPk.present
          ? data.mainCategoryPk.value
          : this.mainCategoryPk,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('kind: $kind, ')
          ..write('mainCategoryPk: $mainCategoryPk, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    color,
    kind,
    mainCategoryPk,
    archived,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.kind == this.kind &&
          other.mainCategoryPk == this.mainCategoryPk &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<int?> color;
  final Value<String> kind;
  final Value<int?> mainCategoryPk;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.kind = const Value.absent(),
    this.mainCategoryPk = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required String kind,
    this.mainCategoryPk = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<String>? kind,
    Expression<int>? mainCategoryPk,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (kind != null) 'kind': kind,
      if (mainCategoryPk != null) 'main_category_pk': mainCategoryPk,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? icon,
    Value<int?>? color,
    Value<String>? kind,
    Value<int?>? mainCategoryPk,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      kind: kind ?? this.kind,
      mainCategoryPk: mainCategoryPk ?? this.mainCategoryPk,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (mainCategoryPk.present) {
      map['main_category_pk'] = Variable<int>(mainCategoryPk.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('kind: $kind, ')
          ..write('mainCategoryPk: $mainCategoryPk, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ObjectivesTable extends Objectives
    with TableInfo<$ObjectivesTable, Objective> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectivesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    amountMinor,
    walletId,
    currencyCode,
    deadline,
    color,
    icon,
    pinned,
    archived,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'objectives';
  @override
  VerificationContext validateIntegrity(
    Insertable<Objective> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Objective map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Objective(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ObjectivesTable createAlias(String alias) {
    return $ObjectivesTable(attachedDatabase, alias);
  }
}

class Objective extends DataClass implements Insertable<Objective> {
  final int id;
  final String name;
  final String type;
  final int amountMinor;
  final int? walletId;
  final String currencyCode;
  final DateTime? deadline;
  final int? color;
  final String? icon;
  final bool pinned;
  final bool archived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Objective({
    required this.id,
    required this.name,
    required this.type,
    required this.amountMinor,
    this.walletId,
    required this.currencyCode,
    this.deadline,
    this.color,
    this.icon,
    required this.pinned,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<int>(walletId);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ObjectivesCompanion toCompanion(bool nullToAbsent) {
    return ObjectivesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      amountMinor: Value(amountMinor),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      currencyCode: Value(currencyCode),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      pinned: Value(pinned),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Objective.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Objective(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      walletId: serializer.fromJson<int?>(json['walletId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      color: serializer.fromJson<int?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'walletId': serializer.toJson<int?>(walletId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'color': serializer.toJson<int?>(color),
      'icon': serializer.toJson<String?>(icon),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Objective copyWith({
    int? id,
    String? name,
    String? type,
    int? amountMinor,
    Value<int?> walletId = const Value.absent(),
    String? currencyCode,
    Value<DateTime?> deadline = const Value.absent(),
    Value<int?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    bool? pinned,
    bool? archived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Objective(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    amountMinor: amountMinor ?? this.amountMinor,
    walletId: walletId.present ? walletId.value : this.walletId,
    currencyCode: currencyCode ?? this.currencyCode,
    deadline: deadline.present ? deadline.value : this.deadline,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Objective copyWithCompanion(ObjectivesCompanion data) {
    return Objective(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Objective(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('walletId: $walletId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('deadline: $deadline, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    amountMinor,
    walletId,
    currencyCode,
    deadline,
    color,
    icon,
    pinned,
    archived,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Objective &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.walletId == this.walletId &&
          other.currencyCode == this.currencyCode &&
          other.deadline == this.deadline &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ObjectivesCompanion extends UpdateCompanion<Objective> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> amountMinor;
  final Value<int?> walletId;
  final Value<String> currencyCode;
  final Value<DateTime?> deadline;
  final Value<int?> color;
  final Value<String?> icon;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ObjectivesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.walletId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.deadline = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ObjectivesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required int amountMinor,
    this.walletId = const Value.absent(),
    required String currencyCode,
    this.deadline = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode);
  static Insertable<Objective> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<int>? walletId,
    Expression<String>? currencyCode,
    Expression<DateTime>? deadline,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (walletId != null) 'wallet_id': walletId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (deadline != null) 'deadline': deadline,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ObjectivesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int>? amountMinor,
    Value<int?>? walletId,
    Value<String>? currencyCode,
    Value<DateTime?>? deadline,
    Value<int?>? color,
    Value<String?>? icon,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ObjectivesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      walletId: walletId ?? this.walletId,
      currencyCode: currencyCode ?? this.currencyCode,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectivesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('walletId: $walletId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('deadline: $deadline, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialTypeMeta = const VerificationMeta(
    'specialType',
  );
  @override
  late final GeneratedColumn<String> specialType = GeneratedColumn<String>(
    'special_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transferWalletIdMeta = const VerificationMeta(
    'transferWalletId',
  );
  @override
  late final GeneratedColumn<int> transferWalletId = GeneratedColumn<int>(
    'transfer_wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _objectiveFkMeta = const VerificationMeta(
    'objectiveFk',
  );
  @override
  late final GeneratedColumn<int> objectiveFk = GeneratedColumn<int>(
    'objective_fk',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES objectives (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _attachmentPathMeta = const VerificationMeta(
    'attachmentPath',
  );
  @override
  late final GeneratedColumn<String> attachmentPath = GeneratedColumn<String>(
    'attachment_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodAddedMeta = const VerificationMeta(
    'methodAdded',
  );
  @override
  late final GeneratedColumn<String> methodAdded = GeneratedColumn<String>(
    'method_added',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    specialType,
    amountMinor,
    currencyCode,
    date,
    walletId,
    transferWalletId,
    categoryId,
    title,
    note,
    tags,
    recurrenceRule,
    objectiveFk,
    attachmentPath,
    methodAdded,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('special_type')) {
      context.handle(
        _specialTypeMeta,
        specialType.isAcceptableOrUnknown(
          data['special_type']!,
          _specialTypeMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('transfer_wallet_id')) {
      context.handle(
        _transferWalletIdMeta,
        transferWalletId.isAcceptableOrUnknown(
          data['transfer_wallet_id']!,
          _transferWalletIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('objective_fk')) {
      context.handle(
        _objectiveFkMeta,
        objectiveFk.isAcceptableOrUnknown(
          data['objective_fk']!,
          _objectiveFkMeta,
        ),
      );
    }
    if (data.containsKey('attachment_path')) {
      context.handle(
        _attachmentPathMeta,
        attachmentPath.isAcceptableOrUnknown(
          data['attachment_path']!,
          _attachmentPathMeta,
        ),
      );
    }
    if (data.containsKey('method_added')) {
      context.handle(
        _methodAddedMeta,
        methodAdded.isAcceptableOrUnknown(
          data['method_added']!,
          _methodAddedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      specialType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      )!,
      transferWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_wallet_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      objectiveFk: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}objective_fk'],
      ),
      attachmentPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_path'],
      ),
      methodAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_added'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String type;
  final String specialType;
  final int amountMinor;
  final String currencyCode;
  final DateTime date;
  final int walletId;
  final int? transferWalletId;
  final int? categoryId;
  final String? title;
  final String? note;
  final String? tags;
  final String? recurrenceRule;
  final int? objectiveFk;
  final String? attachmentPath;
  final String? methodAdded;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Transaction({
    required this.id,
    required this.type,
    required this.specialType,
    required this.amountMinor,
    required this.currencyCode,
    required this.date,
    required this.walletId,
    this.transferWalletId,
    this.categoryId,
    this.title,
    this.note,
    this.tags,
    this.recurrenceRule,
    this.objectiveFk,
    this.attachmentPath,
    this.methodAdded,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['special_type'] = Variable<String>(specialType);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['date'] = Variable<DateTime>(date);
    map['wallet_id'] = Variable<int>(walletId);
    if (!nullToAbsent || transferWalletId != null) {
      map['transfer_wallet_id'] = Variable<int>(transferWalletId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || objectiveFk != null) {
      map['objective_fk'] = Variable<int>(objectiveFk);
    }
    if (!nullToAbsent || attachmentPath != null) {
      map['attachment_path'] = Variable<String>(attachmentPath);
    }
    if (!nullToAbsent || methodAdded != null) {
      map['method_added'] = Variable<String>(methodAdded);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      specialType: Value(specialType),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      date: Value(date),
      walletId: Value(walletId),
      transferWalletId: transferWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferWalletId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      objectiveFk: objectiveFk == null && nullToAbsent
          ? const Value.absent()
          : Value(objectiveFk),
      attachmentPath: attachmentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentPath),
      methodAdded: methodAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(methodAdded),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      specialType: serializer.fromJson<String>(json['specialType']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      date: serializer.fromJson<DateTime>(json['date']),
      walletId: serializer.fromJson<int>(json['walletId']),
      transferWalletId: serializer.fromJson<int?>(json['transferWalletId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      title: serializer.fromJson<String?>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      tags: serializer.fromJson<String?>(json['tags']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      objectiveFk: serializer.fromJson<int?>(json['objectiveFk']),
      attachmentPath: serializer.fromJson<String?>(json['attachmentPath']),
      methodAdded: serializer.fromJson<String?>(json['methodAdded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'specialType': serializer.toJson<String>(specialType),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'date': serializer.toJson<DateTime>(date),
      'walletId': serializer.toJson<int>(walletId),
      'transferWalletId': serializer.toJson<int?>(transferWalletId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'title': serializer.toJson<String?>(title),
      'note': serializer.toJson<String?>(note),
      'tags': serializer.toJson<String?>(tags),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'objectiveFk': serializer.toJson<int?>(objectiveFk),
      'attachmentPath': serializer.toJson<String?>(attachmentPath),
      'methodAdded': serializer.toJson<String?>(methodAdded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transaction copyWith({
    int? id,
    String? type,
    String? specialType,
    int? amountMinor,
    String? currencyCode,
    DateTime? date,
    int? walletId,
    Value<int?> transferWalletId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
    Value<int?> objectiveFk = const Value.absent(),
    Value<String?> attachmentPath = const Value.absent(),
    Value<String?> methodAdded = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Transaction(
    id: id ?? this.id,
    type: type ?? this.type,
    specialType: specialType ?? this.specialType,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    date: date ?? this.date,
    walletId: walletId ?? this.walletId,
    transferWalletId: transferWalletId.present
        ? transferWalletId.value
        : this.transferWalletId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    title: title.present ? title.value : this.title,
    note: note.present ? note.value : this.note,
    tags: tags.present ? tags.value : this.tags,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    objectiveFk: objectiveFk.present ? objectiveFk.value : this.objectiveFk,
    attachmentPath: attachmentPath.present
        ? attachmentPath.value
        : this.attachmentPath,
    methodAdded: methodAdded.present ? methodAdded.value : this.methodAdded,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      specialType: data.specialType.present
          ? data.specialType.value
          : this.specialType,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      date: data.date.present ? data.date.value : this.date,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      transferWalletId: data.transferWalletId.present
          ? data.transferWalletId.value
          : this.transferWalletId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      tags: data.tags.present ? data.tags.value : this.tags,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      objectiveFk: data.objectiveFk.present
          ? data.objectiveFk.value
          : this.objectiveFk,
      attachmentPath: data.attachmentPath.present
          ? data.attachmentPath.value
          : this.attachmentPath,
      methodAdded: data.methodAdded.present
          ? data.methodAdded.value
          : this.methodAdded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('specialType: $specialType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('date: $date, ')
          ..write('walletId: $walletId, ')
          ..write('transferWalletId: $transferWalletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('objectiveFk: $objectiveFk, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('methodAdded: $methodAdded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    specialType,
    amountMinor,
    currencyCode,
    date,
    walletId,
    transferWalletId,
    categoryId,
    title,
    note,
    tags,
    recurrenceRule,
    objectiveFk,
    attachmentPath,
    methodAdded,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.specialType == this.specialType &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.date == this.date &&
          other.walletId == this.walletId &&
          other.transferWalletId == this.transferWalletId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.note == this.note &&
          other.tags == this.tags &&
          other.recurrenceRule == this.recurrenceRule &&
          other.objectiveFk == this.objectiveFk &&
          other.attachmentPath == this.attachmentPath &&
          other.methodAdded == this.methodAdded &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> specialType;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<DateTime> date;
  final Value<int> walletId;
  final Value<int?> transferWalletId;
  final Value<int?> categoryId;
  final Value<String?> title;
  final Value<String?> note;
  final Value<String?> tags;
  final Value<String?> recurrenceRule;
  final Value<int?> objectiveFk;
  final Value<String?> attachmentPath;
  final Value<String?> methodAdded;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.specialType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.date = const Value.absent(),
    this.walletId = const Value.absent(),
    this.transferWalletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.objectiveFk = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.methodAdded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.specialType = const Value.absent(),
    required int amountMinor,
    required String currencyCode,
    required DateTime date,
    required int walletId,
    this.transferWalletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.tags = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.objectiveFk = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.methodAdded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : type = Value(type),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       date = Value(date),
       walletId = Value(walletId);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? specialType,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? date,
    Expression<int>? walletId,
    Expression<int>? transferWalletId,
    Expression<int>? categoryId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? tags,
    Expression<String>? recurrenceRule,
    Expression<int>? objectiveFk,
    Expression<String>? attachmentPath,
    Expression<String>? methodAdded,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (specialType != null) 'special_type': specialType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (date != null) 'date': date,
      if (walletId != null) 'wallet_id': walletId,
      if (transferWalletId != null) 'transfer_wallet_id': transferWalletId,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (tags != null) 'tags': tags,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (objectiveFk != null) 'objective_fk': objectiveFk,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      if (methodAdded != null) 'method_added': methodAdded,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? specialType,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<DateTime>? date,
    Value<int>? walletId,
    Value<int?>? transferWalletId,
    Value<int?>? categoryId,
    Value<String?>? title,
    Value<String?>? note,
    Value<String?>? tags,
    Value<String?>? recurrenceRule,
    Value<int?>? objectiveFk,
    Value<String?>? attachmentPath,
    Value<String?>? methodAdded,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      specialType: specialType ?? this.specialType,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
      transferWalletId: transferWalletId ?? this.transferWalletId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      objectiveFk: objectiveFk ?? this.objectiveFk,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      methodAdded: methodAdded ?? this.methodAdded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (specialType.present) {
      map['special_type'] = Variable<String>(specialType.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (transferWalletId.present) {
      map['transfer_wallet_id'] = Variable<int>(transferWalletId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (objectiveFk.present) {
      map['objective_fk'] = Variable<int>(objectiveFk.value);
    }
    if (attachmentPath.present) {
      map['attachment_path'] = Variable<String>(attachmentPath.value);
    }
    if (methodAdded.present) {
      map['method_added'] = Variable<String>(methodAdded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('specialType: $specialType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('date: $date, ')
          ..write('walletId: $walletId, ')
          ..write('transferWalletId: $transferWalletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('tags: $tags, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('objectiveFk: $objectiveFk, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('methodAdded: $methodAdded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedAmountMinorMeta =
      const VerificationMeta('plannedAmountMinor');
  @override
  late final GeneratedColumn<int> plannedAmountMinor = GeneratedColumn<int>(
    'planned_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _specificModeMeta = const VerificationMeta(
    'specificMode',
  );
  @override
  late final GeneratedColumn<bool> specificMode = GeneratedColumn<bool>(
    'specific_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("specific_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _includeIncomeMeta = const VerificationMeta(
    'includeIncome',
  );
  @override
  late final GeneratedColumn<bool> includeIncome = GeneratedColumn<bool>(
    'include_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_income" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _includeDebtCreditMeta = const VerificationMeta(
    'includeDebtCredit',
  );
  @override
  late final GeneratedColumn<bool> includeDebtCredit = GeneratedColumn<bool>(
    'include_debt_credit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_debt_credit" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _includeBalanceCorrectionMeta =
      const VerificationMeta('includeBalanceCorrection');
  @override
  late final GeneratedColumn<bool> includeBalanceCorrection =
      GeneratedColumn<bool>(
        'include_balance_correction',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_balance_correction" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _includeInOtherBudgetsMeta =
      const VerificationMeta('includeInOtherBudgets');
  @override
  late final GeneratedColumn<bool> includeInOtherBudgets =
      GeneratedColumn<bool>(
        'include_in_other_budgets',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("include_in_other_budgets" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _absoluteLimitMeta = const VerificationMeta(
    'absoluteLimit',
  );
  @override
  late final GeneratedColumn<bool> absoluteLimit = GeneratedColumn<bool>(
    'absolute_limit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("absolute_limit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    periodStart,
    periodEnd,
    currencyCode,
    isIncome,
    pinned,
    archived,
    color,
    plannedAmountMinor,
    specificMode,
    includeIncome,
    includeDebtCredit,
    includeBalanceCorrection,
    includeInOtherBudgets,
    absoluteLimit,
    recurrenceRule,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('planned_amount_minor')) {
      context.handle(
        _plannedAmountMinorMeta,
        plannedAmountMinor.isAcceptableOrUnknown(
          data['planned_amount_minor']!,
          _plannedAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('specific_mode')) {
      context.handle(
        _specificModeMeta,
        specificMode.isAcceptableOrUnknown(
          data['specific_mode']!,
          _specificModeMeta,
        ),
      );
    }
    if (data.containsKey('include_income')) {
      context.handle(
        _includeIncomeMeta,
        includeIncome.isAcceptableOrUnknown(
          data['include_income']!,
          _includeIncomeMeta,
        ),
      );
    }
    if (data.containsKey('include_debt_credit')) {
      context.handle(
        _includeDebtCreditMeta,
        includeDebtCredit.isAcceptableOrUnknown(
          data['include_debt_credit']!,
          _includeDebtCreditMeta,
        ),
      );
    }
    if (data.containsKey('include_balance_correction')) {
      context.handle(
        _includeBalanceCorrectionMeta,
        includeBalanceCorrection.isAcceptableOrUnknown(
          data['include_balance_correction']!,
          _includeBalanceCorrectionMeta,
        ),
      );
    }
    if (data.containsKey('include_in_other_budgets')) {
      context.handle(
        _includeInOtherBudgetsMeta,
        includeInOtherBudgets.isAcceptableOrUnknown(
          data['include_in_other_budgets']!,
          _includeInOtherBudgetsMeta,
        ),
      );
    }
    if (data.containsKey('absolute_limit')) {
      context.handle(
        _absoluteLimitMeta,
        absoluteLimit.isAcceptableOrUnknown(
          data['absolute_limit']!,
          _absoluteLimitMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_end'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      plannedAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount_minor'],
      )!,
      specificMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}specific_mode'],
      )!,
      includeIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_income'],
      )!,
      includeDebtCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_debt_credit'],
      )!,
      includeBalanceCorrection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_balance_correction'],
      )!,
      includeInOtherBudgets: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_other_budgets'],
      )!,
      absoluteLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}absolute_limit'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final String name;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String currencyCode;
  final bool isIncome;
  final bool pinned;
  final bool archived;
  final int? color;
  final int plannedAmountMinor;
  final bool specificMode;
  final bool includeIncome;
  final bool includeDebtCredit;
  final bool includeBalanceCorrection;
  final bool includeInOtherBudgets;
  final bool absoluteLimit;
  final String? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Budget({
    required this.id,
    required this.name,
    required this.periodStart,
    required this.periodEnd,
    required this.currencyCode,
    required this.isIncome,
    required this.pinned,
    required this.archived,
    this.color,
    required this.plannedAmountMinor,
    required this.specificMode,
    required this.includeIncome,
    required this.includeDebtCredit,
    required this.includeBalanceCorrection,
    required this.includeInOtherBudgets,
    required this.absoluteLimit,
    this.recurrenceRule,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['currency_code'] = Variable<String>(currencyCode);
    map['is_income'] = Variable<bool>(isIncome);
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['planned_amount_minor'] = Variable<int>(plannedAmountMinor);
    map['specific_mode'] = Variable<bool>(specificMode);
    map['include_income'] = Variable<bool>(includeIncome);
    map['include_debt_credit'] = Variable<bool>(includeDebtCredit);
    map['include_balance_correction'] = Variable<bool>(
      includeBalanceCorrection,
    );
    map['include_in_other_budgets'] = Variable<bool>(includeInOtherBudgets);
    map['absolute_limit'] = Variable<bool>(absoluteLimit);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      name: Value(name),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      currencyCode: Value(currencyCode),
      isIncome: Value(isIncome),
      pinned: Value(pinned),
      archived: Value(archived),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      plannedAmountMinor: Value(plannedAmountMinor),
      specificMode: Value(specificMode),
      includeIncome: Value(includeIncome),
      includeDebtCredit: Value(includeDebtCredit),
      includeBalanceCorrection: Value(includeBalanceCorrection),
      includeInOtherBudgets: Value(includeInOtherBudgets),
      absoluteLimit: Value(absoluteLimit),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      color: serializer.fromJson<int?>(json['color']),
      plannedAmountMinor: serializer.fromJson<int>(json['plannedAmountMinor']),
      specificMode: serializer.fromJson<bool>(json['specificMode']),
      includeIncome: serializer.fromJson<bool>(json['includeIncome']),
      includeDebtCredit: serializer.fromJson<bool>(json['includeDebtCredit']),
      includeBalanceCorrection: serializer.fromJson<bool>(
        json['includeBalanceCorrection'],
      ),
      includeInOtherBudgets: serializer.fromJson<bool>(
        json['includeInOtherBudgets'],
      ),
      absoluteLimit: serializer.fromJson<bool>(json['absoluteLimit']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'isIncome': serializer.toJson<bool>(isIncome),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'color': serializer.toJson<int?>(color),
      'plannedAmountMinor': serializer.toJson<int>(plannedAmountMinor),
      'specificMode': serializer.toJson<bool>(specificMode),
      'includeIncome': serializer.toJson<bool>(includeIncome),
      'includeDebtCredit': serializer.toJson<bool>(includeDebtCredit),
      'includeBalanceCorrection': serializer.toJson<bool>(
        includeBalanceCorrection,
      ),
      'includeInOtherBudgets': serializer.toJson<bool>(includeInOtherBudgets),
      'absoluteLimit': serializer.toJson<bool>(absoluteLimit),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Budget copyWith({
    int? id,
    String? name,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? currencyCode,
    bool? isIncome,
    bool? pinned,
    bool? archived,
    Value<int?> color = const Value.absent(),
    int? plannedAmountMinor,
    bool? specificMode,
    bool? includeIncome,
    bool? includeDebtCredit,
    bool? includeBalanceCorrection,
    bool? includeInOtherBudgets,
    bool? absoluteLimit,
    Value<String?> recurrenceRule = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Budget(
    id: id ?? this.id,
    name: name ?? this.name,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    currencyCode: currencyCode ?? this.currencyCode,
    isIncome: isIncome ?? this.isIncome,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    color: color.present ? color.value : this.color,
    plannedAmountMinor: plannedAmountMinor ?? this.plannedAmountMinor,
    specificMode: specificMode ?? this.specificMode,
    includeIncome: includeIncome ?? this.includeIncome,
    includeDebtCredit: includeDebtCredit ?? this.includeDebtCredit,
    includeBalanceCorrection:
        includeBalanceCorrection ?? this.includeBalanceCorrection,
    includeInOtherBudgets: includeInOtherBudgets ?? this.includeInOtherBudgets,
    absoluteLimit: absoluteLimit ?? this.absoluteLimit,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      color: data.color.present ? data.color.value : this.color,
      plannedAmountMinor: data.plannedAmountMinor.present
          ? data.plannedAmountMinor.value
          : this.plannedAmountMinor,
      specificMode: data.specificMode.present
          ? data.specificMode.value
          : this.specificMode,
      includeIncome: data.includeIncome.present
          ? data.includeIncome.value
          : this.includeIncome,
      includeDebtCredit: data.includeDebtCredit.present
          ? data.includeDebtCredit.value
          : this.includeDebtCredit,
      includeBalanceCorrection: data.includeBalanceCorrection.present
          ? data.includeBalanceCorrection.value
          : this.includeBalanceCorrection,
      includeInOtherBudgets: data.includeInOtherBudgets.present
          ? data.includeInOtherBudgets.value
          : this.includeInOtherBudgets,
      absoluteLimit: data.absoluteLimit.present
          ? data.absoluteLimit.value
          : this.absoluteLimit,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isIncome: $isIncome, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('color: $color, ')
          ..write('plannedAmountMinor: $plannedAmountMinor, ')
          ..write('specificMode: $specificMode, ')
          ..write('includeIncome: $includeIncome, ')
          ..write('includeDebtCredit: $includeDebtCredit, ')
          ..write('includeBalanceCorrection: $includeBalanceCorrection, ')
          ..write('includeInOtherBudgets: $includeInOtherBudgets, ')
          ..write('absoluteLimit: $absoluteLimit, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    periodStart,
    periodEnd,
    currencyCode,
    isIncome,
    pinned,
    archived,
    color,
    plannedAmountMinor,
    specificMode,
    includeIncome,
    includeDebtCredit,
    includeBalanceCorrection,
    includeInOtherBudgets,
    absoluteLimit,
    recurrenceRule,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.name == this.name &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.currencyCode == this.currencyCode &&
          other.isIncome == this.isIncome &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.color == this.color &&
          other.plannedAmountMinor == this.plannedAmountMinor &&
          other.specificMode == this.specificMode &&
          other.includeIncome == this.includeIncome &&
          other.includeDebtCredit == this.includeDebtCredit &&
          other.includeBalanceCorrection == this.includeBalanceCorrection &&
          other.includeInOtherBudgets == this.includeInOtherBudgets &&
          other.absoluteLimit == this.absoluteLimit &&
          other.recurrenceRule == this.recurrenceRule &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<String> currencyCode;
  final Value<bool> isIncome;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<int?> color;
  final Value<int> plannedAmountMinor;
  final Value<bool> specificMode;
  final Value<bool> includeIncome;
  final Value<bool> includeDebtCredit;
  final Value<bool> includeBalanceCorrection;
  final Value<bool> includeInOtherBudgets;
  final Value<bool> absoluteLimit;
  final Value<String?> recurrenceRule;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.color = const Value.absent(),
    this.plannedAmountMinor = const Value.absent(),
    this.specificMode = const Value.absent(),
    this.includeIncome = const Value.absent(),
    this.includeDebtCredit = const Value.absent(),
    this.includeBalanceCorrection = const Value.absent(),
    this.includeInOtherBudgets = const Value.absent(),
    this.absoluteLimit = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String currencyCode,
    this.isIncome = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.color = const Value.absent(),
    this.plannedAmountMinor = const Value.absent(),
    this.specificMode = const Value.absent(),
    this.includeIncome = const Value.absent(),
    this.includeDebtCredit = const Value.absent(),
    this.includeBalanceCorrection = const Value.absent(),
    this.includeInOtherBudgets = const Value.absent(),
    this.absoluteLimit = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       currencyCode = Value(currencyCode);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<String>? currencyCode,
    Expression<bool>? isIncome,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<int>? color,
    Expression<int>? plannedAmountMinor,
    Expression<bool>? specificMode,
    Expression<bool>? includeIncome,
    Expression<bool>? includeDebtCredit,
    Expression<bool>? includeBalanceCorrection,
    Expression<bool>? includeInOtherBudgets,
    Expression<bool>? absoluteLimit,
    Expression<String>? recurrenceRule,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (isIncome != null) 'is_income': isIncome,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (color != null) 'color': color,
      if (plannedAmountMinor != null)
        'planned_amount_minor': plannedAmountMinor,
      if (specificMode != null) 'specific_mode': specificMode,
      if (includeIncome != null) 'include_income': includeIncome,
      if (includeDebtCredit != null) 'include_debt_credit': includeDebtCredit,
      if (includeBalanceCorrection != null)
        'include_balance_correction': includeBalanceCorrection,
      if (includeInOtherBudgets != null)
        'include_in_other_budgets': includeInOtherBudgets,
      if (absoluteLimit != null) 'absolute_limit': absoluteLimit,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? periodStart,
    Value<DateTime>? periodEnd,
    Value<String>? currencyCode,
    Value<bool>? isIncome,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<int?>? color,
    Value<int>? plannedAmountMinor,
    Value<bool>? specificMode,
    Value<bool>? includeIncome,
    Value<bool>? includeDebtCredit,
    Value<bool>? includeBalanceCorrection,
    Value<bool>? includeInOtherBudgets,
    Value<bool>? absoluteLimit,
    Value<String?>? recurrenceRule,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      currencyCode: currencyCode ?? this.currencyCode,
      isIncome: isIncome ?? this.isIncome,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      color: color ?? this.color,
      plannedAmountMinor: plannedAmountMinor ?? this.plannedAmountMinor,
      specificMode: specificMode ?? this.specificMode,
      includeIncome: includeIncome ?? this.includeIncome,
      includeDebtCredit: includeDebtCredit ?? this.includeDebtCredit,
      includeBalanceCorrection:
          includeBalanceCorrection ?? this.includeBalanceCorrection,
      includeInOtherBudgets:
          includeInOtherBudgets ?? this.includeInOtherBudgets,
      absoluteLimit: absoluteLimit ?? this.absoluteLimit,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (plannedAmountMinor.present) {
      map['planned_amount_minor'] = Variable<int>(plannedAmountMinor.value);
    }
    if (specificMode.present) {
      map['specific_mode'] = Variable<bool>(specificMode.value);
    }
    if (includeIncome.present) {
      map['include_income'] = Variable<bool>(includeIncome.value);
    }
    if (includeDebtCredit.present) {
      map['include_debt_credit'] = Variable<bool>(includeDebtCredit.value);
    }
    if (includeBalanceCorrection.present) {
      map['include_balance_correction'] = Variable<bool>(
        includeBalanceCorrection.value,
      );
    }
    if (includeInOtherBudgets.present) {
      map['include_in_other_budgets'] = Variable<bool>(
        includeInOtherBudgets.value,
      );
    }
    if (absoluteLimit.present) {
      map['absolute_limit'] = Variable<bool>(absoluteLimit.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('isIncome: $isIncome, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('color: $color, ')
          ..write('plannedAmountMinor: $plannedAmountMinor, ')
          ..write('specificMode: $specificMode, ')
          ..write('includeIncome: $includeIncome, ')
          ..write('includeDebtCredit: $includeDebtCredit, ')
          ..write('includeBalanceCorrection: $includeBalanceCorrection, ')
          ..write('includeInOtherBudgets: $includeInOtherBudgets, ')
          ..write('absoluteLimit: $absoluteLimit, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionBudgetsTable extends TransactionBudgets
    with TableInfo<$TransactionBudgetsTable, TransactionBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<int> budgetId = GeneratedColumn<int>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budgets (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, budgetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {transactionId, budgetId},
  ];
  @override
  TransactionBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_id'],
      )!,
    );
  }

  @override
  $TransactionBudgetsTable createAlias(String alias) {
    return $TransactionBudgetsTable(attachedDatabase, alias);
  }
}

class TransactionBudget extends DataClass
    implements Insertable<TransactionBudget> {
  final int id;
  final int transactionId;
  final int budgetId;
  const TransactionBudget({
    required this.id,
    required this.transactionId,
    required this.budgetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['budget_id'] = Variable<int>(budgetId);
    return map;
  }

  TransactionBudgetsCompanion toCompanion(bool nullToAbsent) {
    return TransactionBudgetsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      budgetId: Value(budgetId),
    );
  }

  factory TransactionBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionBudget(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      budgetId: serializer.fromJson<int>(json['budgetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'budgetId': serializer.toJson<int>(budgetId),
    };
  }

  TransactionBudget copyWith({int? id, int? transactionId, int? budgetId}) =>
      TransactionBudget(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        budgetId: budgetId ?? this.budgetId,
      );
  TransactionBudget copyWithCompanion(TransactionBudgetsCompanion data) {
    return TransactionBudget(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionBudget(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('budgetId: $budgetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, budgetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionBudget &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.budgetId == this.budgetId);
}

class TransactionBudgetsCompanion extends UpdateCompanion<TransactionBudget> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> budgetId;
  const TransactionBudgetsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.budgetId = const Value.absent(),
  });
  TransactionBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int budgetId,
  }) : transactionId = Value(transactionId),
       budgetId = Value(budgetId);
  static Insertable<TransactionBudget> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? budgetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (budgetId != null) 'budget_id': budgetId,
    });
  }

  TransactionBudgetsCompanion copyWith({
    Value<int>? id,
    Value<int>? transactionId,
    Value<int>? budgetId,
  }) {
    return TransactionBudgetsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      budgetId: budgetId ?? this.budgetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<int>(budgetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('budgetId: $budgetId')
          ..write(')'))
        .toString();
  }
}

class $BudgetCategoryLimitsTable extends BudgetCategoryLimits
    with TableInfo<$BudgetCategoryLimitsTable, BudgetCategoryLimit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetCategoryLimitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<int> budgetId = GeneratedColumn<int>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budgets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _plannedAmountMinorMeta =
      const VerificationMeta('plannedAmountMinor');
  @override
  late final GeneratedColumn<int> plannedAmountMinor = GeneratedColumn<int>(
    'planned_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    budgetId,
    categoryId,
    walletId,
    plannedAmountMinor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_category_limits';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetCategoryLimit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    }
    if (data.containsKey('planned_amount_minor')) {
      context.handle(
        _plannedAmountMinorMeta,
        plannedAmountMinor.isAcceptableOrUnknown(
          data['planned_amount_minor']!,
          _plannedAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedAmountMinorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {budgetId, categoryId, walletId},
  ];
  @override
  BudgetCategoryLimit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetCategoryLimit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      ),
      plannedAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount_minor'],
      )!,
    );
  }

  @override
  $BudgetCategoryLimitsTable createAlias(String alias) {
    return $BudgetCategoryLimitsTable(attachedDatabase, alias);
  }
}

class BudgetCategoryLimit extends DataClass
    implements Insertable<BudgetCategoryLimit> {
  final int id;
  final int budgetId;
  final int categoryId;
  final int? walletId;
  final int plannedAmountMinor;
  const BudgetCategoryLimit({
    required this.id,
    required this.budgetId,
    required this.categoryId,
    this.walletId,
    required this.plannedAmountMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['budget_id'] = Variable<int>(budgetId);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || walletId != null) {
      map['wallet_id'] = Variable<int>(walletId);
    }
    map['planned_amount_minor'] = Variable<int>(plannedAmountMinor);
    return map;
  }

  BudgetCategoryLimitsCompanion toCompanion(bool nullToAbsent) {
    return BudgetCategoryLimitsCompanion(
      id: Value(id),
      budgetId: Value(budgetId),
      categoryId: Value(categoryId),
      walletId: walletId == null && nullToAbsent
          ? const Value.absent()
          : Value(walletId),
      plannedAmountMinor: Value(plannedAmountMinor),
    );
  }

  factory BudgetCategoryLimit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetCategoryLimit(
      id: serializer.fromJson<int>(json['id']),
      budgetId: serializer.fromJson<int>(json['budgetId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      walletId: serializer.fromJson<int?>(json['walletId']),
      plannedAmountMinor: serializer.fromJson<int>(json['plannedAmountMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'budgetId': serializer.toJson<int>(budgetId),
      'categoryId': serializer.toJson<int>(categoryId),
      'walletId': serializer.toJson<int?>(walletId),
      'plannedAmountMinor': serializer.toJson<int>(plannedAmountMinor),
    };
  }

  BudgetCategoryLimit copyWith({
    int? id,
    int? budgetId,
    int? categoryId,
    Value<int?> walletId = const Value.absent(),
    int? plannedAmountMinor,
  }) => BudgetCategoryLimit(
    id: id ?? this.id,
    budgetId: budgetId ?? this.budgetId,
    categoryId: categoryId ?? this.categoryId,
    walletId: walletId.present ? walletId.value : this.walletId,
    plannedAmountMinor: plannedAmountMinor ?? this.plannedAmountMinor,
  );
  BudgetCategoryLimit copyWithCompanion(BudgetCategoryLimitsCompanion data) {
    return BudgetCategoryLimit(
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      plannedAmountMinor: data.plannedAmountMinor.present
          ? data.plannedAmountMinor.value
          : this.plannedAmountMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoryLimit(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('walletId: $walletId, ')
          ..write('plannedAmountMinor: $plannedAmountMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, budgetId, categoryId, walletId, plannedAmountMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetCategoryLimit &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.categoryId == this.categoryId &&
          other.walletId == this.walletId &&
          other.plannedAmountMinor == this.plannedAmountMinor);
}

class BudgetCategoryLimitsCompanion
    extends UpdateCompanion<BudgetCategoryLimit> {
  final Value<int> id;
  final Value<int> budgetId;
  final Value<int> categoryId;
  final Value<int?> walletId;
  final Value<int> plannedAmountMinor;
  const BudgetCategoryLimitsCompanion({
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.walletId = const Value.absent(),
    this.plannedAmountMinor = const Value.absent(),
  });
  BudgetCategoryLimitsCompanion.insert({
    this.id = const Value.absent(),
    required int budgetId,
    required int categoryId,
    this.walletId = const Value.absent(),
    required int plannedAmountMinor,
  }) : budgetId = Value(budgetId),
       categoryId = Value(categoryId),
       plannedAmountMinor = Value(plannedAmountMinor);
  static Insertable<BudgetCategoryLimit> custom({
    Expression<int>? id,
    Expression<int>? budgetId,
    Expression<int>? categoryId,
    Expression<int>? walletId,
    Expression<int>? plannedAmountMinor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (categoryId != null) 'category_id': categoryId,
      if (walletId != null) 'wallet_id': walletId,
      if (plannedAmountMinor != null)
        'planned_amount_minor': plannedAmountMinor,
    });
  }

  BudgetCategoryLimitsCompanion copyWith({
    Value<int>? id,
    Value<int>? budgetId,
    Value<int>? categoryId,
    Value<int?>? walletId,
    Value<int>? plannedAmountMinor,
  }) {
    return BudgetCategoryLimitsCompanion(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      plannedAmountMinor: plannedAmountMinor ?? this.plannedAmountMinor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<int>(budgetId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (plannedAmountMinor.present) {
      map['planned_amount_minor'] = Variable<int>(plannedAmountMinor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoryLimitsCompanion(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('walletId: $walletId, ')
          ..write('plannedAmountMinor: $plannedAmountMinor')
          ..write(')'))
        .toString();
  }
}

class $BudgetWalletsTable extends BudgetWallets
    with TableInfo<$BudgetWalletsTable, BudgetWallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetWalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<int> budgetId = GeneratedColumn<int>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES budgets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, budgetId, walletId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_wallets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetWallet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {budgetId, walletId},
  ];
  @override
  BudgetWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetWallet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_id'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      )!,
    );
  }

  @override
  $BudgetWalletsTable createAlias(String alias) {
    return $BudgetWalletsTable(attachedDatabase, alias);
  }
}

class BudgetWallet extends DataClass implements Insertable<BudgetWallet> {
  final int id;
  final int budgetId;
  final int walletId;
  const BudgetWallet({
    required this.id,
    required this.budgetId,
    required this.walletId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['budget_id'] = Variable<int>(budgetId);
    map['wallet_id'] = Variable<int>(walletId);
    return map;
  }

  BudgetWalletsCompanion toCompanion(bool nullToAbsent) {
    return BudgetWalletsCompanion(
      id: Value(id),
      budgetId: Value(budgetId),
      walletId: Value(walletId),
    );
  }

  factory BudgetWallet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetWallet(
      id: serializer.fromJson<int>(json['id']),
      budgetId: serializer.fromJson<int>(json['budgetId']),
      walletId: serializer.fromJson<int>(json['walletId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'budgetId': serializer.toJson<int>(budgetId),
      'walletId': serializer.toJson<int>(walletId),
    };
  }

  BudgetWallet copyWith({int? id, int? budgetId, int? walletId}) =>
      BudgetWallet(
        id: id ?? this.id,
        budgetId: budgetId ?? this.budgetId,
        walletId: walletId ?? this.walletId,
      );
  BudgetWallet copyWithCompanion(BudgetWalletsCompanion data) {
    return BudgetWallet(
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetWallet(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('walletId: $walletId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, budgetId, walletId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetWallet &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.walletId == this.walletId);
}

class BudgetWalletsCompanion extends UpdateCompanion<BudgetWallet> {
  final Value<int> id;
  final Value<int> budgetId;
  final Value<int> walletId;
  const BudgetWalletsCompanion({
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.walletId = const Value.absent(),
  });
  BudgetWalletsCompanion.insert({
    this.id = const Value.absent(),
    required int budgetId,
    required int walletId,
  }) : budgetId = Value(budgetId),
       walletId = Value(walletId);
  static Insertable<BudgetWallet> custom({
    Expression<int>? id,
    Expression<int>? budgetId,
    Expression<int>? walletId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (walletId != null) 'wallet_id': walletId,
    });
  }

  BudgetWalletsCompanion copyWith({
    Value<int>? id,
    Value<int>? budgetId,
    Value<int>? walletId,
  }) {
    return BudgetWalletsCompanion(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      walletId: walletId ?? this.walletId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<int>(budgetId.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetWalletsCompanion(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('walletId: $walletId')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialTypeMeta = const VerificationMeta(
    'specialType',
  );
  @override
  late final GeneratedColumn<String> specialType = GeneratedColumn<String>(
    'special_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transferWalletIdMeta = const VerificationMeta(
    'transferWalletId',
  );
  @override
  late final GeneratedColumn<int> transferWalletId = GeneratedColumn<int>(
    'transfer_wallet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wallets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleRuleMeta = const VerificationMeta(
    'scheduleRule',
  );
  @override
  late final GeneratedColumn<String> scheduleRule = GeneratedColumn<String>(
    'schedule_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionType,
    specialType,
    amountMinor,
    currencyCode,
    walletId,
    transferWalletId,
    categoryId,
    title,
    note,
    scheduleRule,
    startDate,
    endDate,
    nextDueDate,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('special_type')) {
      context.handle(
        _specialTypeMeta,
        specialType.isAcceptableOrUnknown(
          data['special_type']!,
          _specialTypeMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('transfer_wallet_id')) {
      context.handle(
        _transferWalletIdMeta,
        transferWalletId.isAcceptableOrUnknown(
          data['transfer_wallet_id']!,
          _transferWalletIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('schedule_rule')) {
      context.handle(
        _scheduleRuleMeta,
        scheduleRule.isAcceptableOrUnknown(
          data['schedule_rule']!,
          _scheduleRuleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleRuleMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      specialType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wallet_id'],
      )!,
      transferWalletId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_wallet_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      scheduleRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_rule'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransaction extends DataClass
    implements Insertable<RecurringTransaction> {
  final int id;
  final String transactionType;
  final String specialType;
  final int amountMinor;
  final String currencyCode;
  final int walletId;
  final int? transferWalletId;
  final int? categoryId;
  final String? title;
  final String? note;
  final String scheduleRule;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextDueDate;
  final bool active;
  final DateTime createdAt;
  const RecurringTransaction({
    required this.id,
    required this.transactionType,
    required this.specialType,
    required this.amountMinor,
    required this.currencyCode,
    required this.walletId,
    this.transferWalletId,
    this.categoryId,
    this.title,
    this.note,
    required this.scheduleRule,
    required this.startDate,
    this.endDate,
    this.nextDueDate,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_type'] = Variable<String>(transactionType);
    map['special_type'] = Variable<String>(specialType);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['wallet_id'] = Variable<int>(walletId);
    if (!nullToAbsent || transferWalletId != null) {
      map['transfer_wallet_id'] = Variable<int>(transferWalletId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['schedule_rule'] = Variable<String>(scheduleRule);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      transactionType: Value(transactionType),
      specialType: Value(specialType),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      walletId: Value(walletId),
      transferWalletId: transferWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferWalletId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      scheduleRule: Value(scheduleRule),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransaction(
      id: serializer.fromJson<int>(json['id']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      specialType: serializer.fromJson<String>(json['specialType']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      walletId: serializer.fromJson<int>(json['walletId']),
      transferWalletId: serializer.fromJson<int?>(json['transferWalletId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      title: serializer.fromJson<String?>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      scheduleRule: serializer.fromJson<String>(json['scheduleRule']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionType': serializer.toJson<String>(transactionType),
      'specialType': serializer.toJson<String>(specialType),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'walletId': serializer.toJson<int>(walletId),
      'transferWalletId': serializer.toJson<int?>(transferWalletId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'title': serializer.toJson<String?>(title),
      'note': serializer.toJson<String?>(note),
      'scheduleRule': serializer.toJson<String>(scheduleRule),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringTransaction copyWith({
    int? id,
    String? transactionType,
    String? specialType,
    int? amountMinor,
    String? currencyCode,
    int? walletId,
    Value<int?> transferWalletId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? scheduleRule,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<DateTime?> nextDueDate = const Value.absent(),
    bool? active,
    DateTime? createdAt,
  }) => RecurringTransaction(
    id: id ?? this.id,
    transactionType: transactionType ?? this.transactionType,
    specialType: specialType ?? this.specialType,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    walletId: walletId ?? this.walletId,
    transferWalletId: transferWalletId.present
        ? transferWalletId.value
        : this.transferWalletId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    title: title.present ? title.value : this.title,
    note: note.present ? note.value : this.note,
    scheduleRule: scheduleRule ?? this.scheduleRule,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringTransaction copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      specialType: data.specialType.present
          ? data.specialType.value
          : this.specialType,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      transferWalletId: data.transferWalletId.present
          ? data.transferWalletId.value
          : this.transferWalletId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      scheduleRule: data.scheduleRule.present
          ? data.scheduleRule.value
          : this.scheduleRule,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransaction(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('specialType: $specialType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('walletId: $walletId, ')
          ..write('transferWalletId: $transferWalletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('scheduleRule: $scheduleRule, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionType,
    specialType,
    amountMinor,
    currencyCode,
    walletId,
    transferWalletId,
    categoryId,
    title,
    note,
    scheduleRule,
    startDate,
    endDate,
    nextDueDate,
    active,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransaction &&
          other.id == this.id &&
          other.transactionType == this.transactionType &&
          other.specialType == this.specialType &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.walletId == this.walletId &&
          other.transferWalletId == this.transferWalletId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.note == this.note &&
          other.scheduleRule == this.scheduleRule &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.nextDueDate == this.nextDueDate &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransaction> {
  final Value<int> id;
  final Value<String> transactionType;
  final Value<String> specialType;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<int> walletId;
  final Value<int?> transferWalletId;
  final Value<int?> categoryId;
  final Value<String?> title;
  final Value<String?> note;
  final Value<String> scheduleRule;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime?> nextDueDate;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.specialType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.walletId = const Value.absent(),
    this.transferWalletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.scheduleRule = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String transactionType,
    this.specialType = const Value.absent(),
    required int amountMinor,
    this.currencyCode = const Value.absent(),
    required int walletId,
    this.transferWalletId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    required String scheduleRule,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : transactionType = Value(transactionType),
       amountMinor = Value(amountMinor),
       walletId = Value(walletId),
       scheduleRule = Value(scheduleRule),
       startDate = Value(startDate);
  static Insertable<RecurringTransaction> custom({
    Expression<int>? id,
    Expression<String>? transactionType,
    Expression<String>? specialType,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<int>? walletId,
    Expression<int>? transferWalletId,
    Expression<int>? categoryId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? scheduleRule,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? nextDueDate,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionType != null) 'transaction_type': transactionType,
      if (specialType != null) 'special_type': specialType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (walletId != null) 'wallet_id': walletId,
      if (transferWalletId != null) 'transfer_wallet_id': transferWalletId,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (scheduleRule != null) 'schedule_rule': scheduleRule,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurringTransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? transactionType,
    Value<String>? specialType,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<int>? walletId,
    Value<int?>? transferWalletId,
    Value<int?>? categoryId,
    Value<String?>? title,
    Value<String?>? note,
    Value<String>? scheduleRule,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime?>? nextDueDate,
    Value<bool>? active,
    Value<DateTime>? createdAt,
  }) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      specialType: specialType ?? this.specialType,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      walletId: walletId ?? this.walletId,
      transferWalletId: transferWalletId ?? this.transferWalletId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      note: note ?? this.note,
      scheduleRule: scheduleRule ?? this.scheduleRule,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (specialType.present) {
      map['special_type'] = Variable<String>(specialType.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (transferWalletId.present) {
      map['transfer_wallet_id'] = Variable<int>(transferWalletId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (scheduleRule.present) {
      map['schedule_rule'] = Variable<String>(scheduleRule.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('specialType: $specialType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('walletId: $walletId, ')
          ..write('transferWalletId: $transferWalletId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('scheduleRule: $scheduleRule, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

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
  @override
  List<GeneratedColumn> get $columns => [key, value];
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
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssociatedTitlesTable extends AssociatedTitles
    with TableInfo<$AssociatedTitlesTable, AssociatedTitle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssociatedTitlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exactMatchMeta = const VerificationMeta(
    'exactMatch',
  );
  @override
  late final GeneratedColumn<bool> exactMatch = GeneratedColumn<bool>(
    'exact_match',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exact_match" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    categoryId,
    exactMatch,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'associated_titles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssociatedTitle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('exact_match')) {
      context.handle(
        _exactMatchMeta,
        exactMatch.isAcceptableOrUnknown(data['exact_match']!, _exactMatchMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssociatedTitle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssociatedTitle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      exactMatch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exact_match'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssociatedTitlesTable createAlias(String alias) {
    return $AssociatedTitlesTable(attachedDatabase, alias);
  }
}

class AssociatedTitle extends DataClass implements Insertable<AssociatedTitle> {
  final int id;
  final String title;
  final int categoryId;
  final bool exactMatch;
  final DateTime createdAt;
  const AssociatedTitle({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.exactMatch,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['category_id'] = Variable<int>(categoryId);
    map['exact_match'] = Variable<bool>(exactMatch);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssociatedTitlesCompanion toCompanion(bool nullToAbsent) {
    return AssociatedTitlesCompanion(
      id: Value(id),
      title: Value(title),
      categoryId: Value(categoryId),
      exactMatch: Value(exactMatch),
      createdAt: Value(createdAt),
    );
  }

  factory AssociatedTitle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssociatedTitle(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      exactMatch: serializer.fromJson<bool>(json['exactMatch']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'categoryId': serializer.toJson<int>(categoryId),
      'exactMatch': serializer.toJson<bool>(exactMatch),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssociatedTitle copyWith({
    int? id,
    String? title,
    int? categoryId,
    bool? exactMatch,
    DateTime? createdAt,
  }) => AssociatedTitle(
    id: id ?? this.id,
    title: title ?? this.title,
    categoryId: categoryId ?? this.categoryId,
    exactMatch: exactMatch ?? this.exactMatch,
    createdAt: createdAt ?? this.createdAt,
  );
  AssociatedTitle copyWithCompanion(AssociatedTitlesCompanion data) {
    return AssociatedTitle(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      exactMatch: data.exactMatch.present
          ? data.exactMatch.value
          : this.exactMatch,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedTitle(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('exactMatch: $exactMatch, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, categoryId, exactMatch, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssociatedTitle &&
          other.id == this.id &&
          other.title == this.title &&
          other.categoryId == this.categoryId &&
          other.exactMatch == this.exactMatch &&
          other.createdAt == this.createdAt);
}

class AssociatedTitlesCompanion extends UpdateCompanion<AssociatedTitle> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> categoryId;
  final Value<bool> exactMatch;
  final Value<DateTime> createdAt;
  const AssociatedTitlesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.exactMatch = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssociatedTitlesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int categoryId,
    this.exactMatch = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       categoryId = Value(categoryId);
  static Insertable<AssociatedTitle> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? categoryId,
    Expression<bool>? exactMatch,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (categoryId != null) 'category_id': categoryId,
      if (exactMatch != null) 'exact_match': exactMatch,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssociatedTitlesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? categoryId,
    Value<bool>? exactMatch,
    Value<DateTime>? createdAt,
  }) {
    return AssociatedTitlesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      exactMatch: exactMatch ?? this.exactMatch,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (exactMatch.present) {
      map['exact_match'] = Variable<bool>(exactMatch.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedTitlesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('exactMatch: $exactMatch, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DeleteLogsTable extends DeleteLogs
    with TableInfo<$DeleteLogsTable, DeleteLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeleteLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, jsonData, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delete_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeleteLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeleteLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeleteLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $DeleteLogsTable createAlias(String alias) {
    return $DeleteLogsTable(attachedDatabase, alias);
  }
}

class DeleteLog extends DataClass implements Insertable<DeleteLog> {
  final int id;
  final String type;
  final String jsonData;
  final DateTime deletedAt;
  const DeleteLog({
    required this.id,
    required this.type,
    required this.jsonData,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['json_data'] = Variable<String>(jsonData);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  DeleteLogsCompanion toCompanion(bool nullToAbsent) {
    return DeleteLogsCompanion(
      id: Value(id),
      type: Value(type),
      jsonData: Value(jsonData),
      deletedAt: Value(deletedAt),
    );
  }

  factory DeleteLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeleteLog(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'jsonData': serializer.toJson<String>(jsonData),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  DeleteLog copyWith({
    int? id,
    String? type,
    String? jsonData,
    DateTime? deletedAt,
  }) => DeleteLog(
    id: id ?? this.id,
    type: type ?? this.type,
    jsonData: jsonData ?? this.jsonData,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  DeleteLog copyWithCompanion(DeleteLogsCompanion data) {
    return DeleteLog(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeleteLog(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('jsonData: $jsonData, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, jsonData, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeleteLog &&
          other.id == this.id &&
          other.type == this.type &&
          other.jsonData == this.jsonData &&
          other.deletedAt == this.deletedAt);
}

class DeleteLogsCompanion extends UpdateCompanion<DeleteLog> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> jsonData;
  final Value<DateTime> deletedAt;
  const DeleteLogsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  DeleteLogsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String jsonData,
    this.deletedAt = const Value.absent(),
  }) : type = Value(type),
       jsonData = Value(jsonData);
  static Insertable<DeleteLog> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? jsonData,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (jsonData != null) 'json_data': jsonData,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  DeleteLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? jsonData,
    Value<DateTime>? deletedAt,
  }) {
    return DeleteLogsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      jsonData: jsonData ?? this.jsonData,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeleteLogsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('jsonData: $jsonData, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ObjectivesTable objectives = $ObjectivesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $TransactionBudgetsTable transactionBudgets =
      $TransactionBudgetsTable(this);
  late final $BudgetCategoryLimitsTable budgetCategoryLimits =
      $BudgetCategoryLimitsTable(this);
  late final $BudgetWalletsTable budgetWallets = $BudgetWalletsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AssociatedTitlesTable associatedTitles = $AssociatedTitlesTable(
    this,
  );
  late final $DeleteLogsTable deleteLogs = $DeleteLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    wallets,
    categories,
    objectives,
    transactions,
    budgets,
    transactionBudgets,
    budgetCategoryLimits,
    budgetWallets,
    recurringTransactions,
    settings,
    associatedTitles,
    deleteLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('categories', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('objectives', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'objectives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_budgets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'budgets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_budgets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'budgets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_category_limits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_category_limits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_category_limits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'budgets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_wallets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budget_wallets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wallets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('associated_titles', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WalletsTableCreateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required String currencyCode,
      required int initialBalanceMinor,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<int?> color,
      Value<String?> icon,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WalletsTableUpdateCompanionBuilder =
    WalletsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String> currencyCode,
      Value<int> initialBalanceMinor,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<int?> color,
      Value<String?> icon,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WalletsTableReferences
    extends BaseReferences<_$AppDatabase, $WalletsTable, Wallet> {
  $$WalletsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ObjectivesTable, List<Objective>>
  _objectivesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.objectives,
    aliasName: $_aliasNameGenerator(db.wallets.id, db.objectives.walletId),
  );

  $$ObjectivesTableProcessedTableManager get objectivesRefs {
    final manager = $$ObjectivesTableTableManager(
      $_db,
      $_db.objectives,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_objectivesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(db.wallets.id, db.transactions.walletId),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionTransferWalletTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactions,
        aliasName: $_aliasNameGenerator(
          db.wallets.id,
          db.transactions.transferWalletId,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionTransferWallet {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.transferWalletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionTransferWalletTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BudgetCategoryLimitsTable,
    List<BudgetCategoryLimit>
  >
  _budgetCategoryLimitsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.budgetCategoryLimits,
        aliasName: $_aliasNameGenerator(
          db.wallets.id,
          db.budgetCategoryLimits.walletId,
        ),
      );

  $$BudgetCategoryLimitsTableProcessedTableManager
  get budgetCategoryLimitsRefs {
    final manager = $$BudgetCategoryLimitsTableTableManager(
      $_db,
      $_db.budgetCategoryLimits,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _budgetCategoryLimitsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetWalletsTable, List<BudgetWallet>>
  _budgetWalletsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetWallets,
    aliasName: $_aliasNameGenerator(db.wallets.id, db.budgetWallets.walletId),
  );

  $$BudgetWalletsTableProcessedTableManager get budgetWalletsRefs {
    final manager = $$BudgetWalletsTableTableManager(
      $_db,
      $_db.budgetWallets,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetWalletsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringTransactionsTable,
    List<RecurringTransaction>
  >
  _recurringTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: $_aliasNameGenerator(
          db.wallets.id,
          db.recurringTransactions.walletId,
        ),
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringTransactionsTable,
    List<RecurringTransaction>
  >
  _recurringTransferWalletTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: $_aliasNameGenerator(
          db.wallets.id,
          db.recurringTransactions.transferWalletId,
        ),
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransferWallet {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.transferWalletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransferWalletTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WalletsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialBalanceMinor => $composableBuilder(
    column: $table.initialBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> objectivesRefs(
    Expression<bool> Function($$ObjectivesTableFilterComposer f) f,
  ) {
    final $$ObjectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objectives,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectivesTableFilterComposer(
            $db: $db,
            $table: $db.objectives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionTransferWallet(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.transferWalletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetCategoryLimitsRefs(
    Expression<bool> Function($$BudgetCategoryLimitsTableFilterComposer f) f,
  ) {
    final $$BudgetCategoryLimitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetCategoryLimits,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoryLimitsTableFilterComposer(
            $db: $db,
            $table: $db.budgetCategoryLimits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetWalletsRefs(
    Expression<bool> Function($$BudgetWalletsTableFilterComposer f) f,
  ) {
    final $$BudgetWalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetWallets,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetWalletsTableFilterComposer(
            $db: $db,
            $table: $db.budgetWallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringTransactionsRefs(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.walletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> recurringTransferWallet(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.transferWalletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBalanceMinor => $composableBuilder(
    column: $table.initialBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletsTable> {
  $$WalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialBalanceMinor => $composableBuilder(
    column: $table.initialBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> objectivesRefs<T extends Object>(
    Expression<T> Function($$ObjectivesTableAnnotationComposer a) f,
  ) {
    final $$ObjectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.objectives,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.objectives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionTransferWallet<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.transferWalletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetCategoryLimitsRefs<T extends Object>(
    Expression<T> Function($$BudgetCategoryLimitsTableAnnotationComposer a) f,
  ) {
    final $$BudgetCategoryLimitsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.budgetCategoryLimits,
          getReferencedColumn: (t) => t.walletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoryLimitsTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetCategoryLimits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> budgetWalletsRefs<T extends Object>(
    Expression<T> Function($$BudgetWalletsTableAnnotationComposer a) f,
  ) {
    final $$BudgetWalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetWallets,
      getReferencedColumn: (t) => t.walletId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetWalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetWallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringTransactionsRefs<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.walletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringTransferWallet<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.transferWalletId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletsTable,
          Wallet,
          $$WalletsTableFilterComposer,
          $$WalletsTableOrderingComposer,
          $$WalletsTableAnnotationComposer,
          $$WalletsTableCreateCompanionBuilder,
          $$WalletsTableUpdateCompanionBuilder,
          (Wallet, $$WalletsTableReferences),
          Wallet,
          PrefetchHooks Function({
            bool objectivesRefs,
            bool transactionsRefs,
            bool transactionTransferWallet,
            bool budgetCategoryLimitsRefs,
            bool budgetWalletsRefs,
            bool recurringTransactionsRefs,
            bool recurringTransferWallet,
          })
        > {
  $$WalletsTableTableManager(_$AppDatabase db, $WalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> initialBalanceMinor = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WalletsCompanion(
                id: id,
                name: name,
                type: type,
                currencyCode: currencyCode,
                initialBalanceMinor: initialBalanceMinor,
                archived: archived,
                sortOrder: sortOrder,
                color: color,
                icon: icon,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required String currencyCode,
                required int initialBalanceMinor,
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WalletsCompanion.insert(
                id: id,
                name: name,
                type: type,
                currencyCode: currencyCode,
                initialBalanceMinor: initialBalanceMinor,
                archived: archived,
                sortOrder: sortOrder,
                color: color,
                icon: icon,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WalletsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                objectivesRefs = false,
                transactionsRefs = false,
                transactionTransferWallet = false,
                budgetCategoryLimitsRefs = false,
                budgetWalletsRefs = false,
                recurringTransactionsRefs = false,
                recurringTransferWallet = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (objectivesRefs) db.objectives,
                    if (transactionsRefs) db.transactions,
                    if (transactionTransferWallet) db.transactions,
                    if (budgetCategoryLimitsRefs) db.budgetCategoryLimits,
                    if (budgetWalletsRefs) db.budgetWallets,
                    if (recurringTransactionsRefs) db.recurringTransactions,
                    if (recurringTransferWallet) db.recurringTransactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (objectivesRefs)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          Objective
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._objectivesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).objectivesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.walletId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.walletId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionTransferWallet)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._transactionTransferWalletTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionTransferWallet,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transferWalletId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetCategoryLimitsRefs)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          BudgetCategoryLimit
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._budgetCategoryLimitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetCategoryLimitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.walletId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetWalletsRefs)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          BudgetWallet
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._budgetWalletsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetWalletsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.walletId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringTransactionsRefs)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          RecurringTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._recurringTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.walletId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringTransferWallet)
                        await $_getPrefetchedData<
                          Wallet,
                          $WalletsTable,
                          RecurringTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$WalletsTableReferences
                              ._recurringTransferWalletTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WalletsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransferWallet,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transferWalletId == item.id,
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

typedef $$WalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletsTable,
      Wallet,
      $$WalletsTableFilterComposer,
      $$WalletsTableOrderingComposer,
      $$WalletsTableAnnotationComposer,
      $$WalletsTableCreateCompanionBuilder,
      $$WalletsTableUpdateCompanionBuilder,
      (Wallet, $$WalletsTableReferences),
      Wallet,
      PrefetchHooks Function({
        bool objectivesRefs,
        bool transactionsRefs,
        bool transactionTransferWallet,
        bool budgetCategoryLimitsRefs,
        bool budgetWalletsRefs,
        bool recurringTransactionsRefs,
        bool recurringTransferWallet,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> icon,
      Value<int?> color,
      required String kind,
      Value<int?> mainCategoryPk,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> icon,
      Value<int?> color,
      Value<String> kind,
      Value<int?> mainCategoryPk,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _mainCategoryPkTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.categories.mainCategoryPk, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get mainCategoryPk {
    final $_column = $_itemColumn<int>('main_category_pk');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mainCategoryPkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.transactions.categoryId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BudgetCategoryLimitsTable,
    List<BudgetCategoryLimit>
  >
  _budgetCategoryLimitsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.budgetCategoryLimits,
        aliasName: $_aliasNameGenerator(
          db.categories.id,
          db.budgetCategoryLimits.categoryId,
        ),
      );

  $$BudgetCategoryLimitsTableProcessedTableManager
  get budgetCategoryLimitsRefs {
    final manager = $$BudgetCategoryLimitsTableTableManager(
      $_db,
      $_db.budgetCategoryLimits,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _budgetCategoryLimitsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringTransactionsTable,
    List<RecurringTransaction>
  >
  _recurringTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: $_aliasNameGenerator(
          db.categories.id,
          db.recurringTransactions.categoryId,
        ),
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssociatedTitlesTable, List<AssociatedTitle>>
  _associatedTitlesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.associatedTitles,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.associatedTitles.categoryId,
    ),
  );

  $$AssociatedTitlesTableProcessedTableManager get associatedTitlesRefs {
    final manager = $$AssociatedTitlesTableTableManager(
      $_db,
      $_db.associatedTitles,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _associatedTitlesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get mainCategoryPk {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainCategoryPk,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetCategoryLimitsRefs(
    Expression<bool> Function($$BudgetCategoryLimitsTableFilterComposer f) f,
  ) {
    final $$BudgetCategoryLimitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetCategoryLimits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoryLimitsTableFilterComposer(
            $db: $db,
            $table: $db.budgetCategoryLimits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringTransactionsRefs(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> associatedTitlesRefs(
    Expression<bool> Function($$AssociatedTitlesTableFilterComposer f) f,
  ) {
    final $$AssociatedTitlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.associatedTitles,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssociatedTitlesTableFilterComposer(
            $db: $db,
            $table: $db.associatedTitles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get mainCategoryPk {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainCategoryPk,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get mainCategoryPk {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainCategoryPk,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetCategoryLimitsRefs<T extends Object>(
    Expression<T> Function($$BudgetCategoryLimitsTableAnnotationComposer a) f,
  ) {
    final $$BudgetCategoryLimitsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.budgetCategoryLimits,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoryLimitsTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetCategoryLimits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringTransactionsRefs<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> associatedTitlesRefs<T extends Object>(
    Expression<T> Function($$AssociatedTitlesTableAnnotationComposer a) f,
  ) {
    final $$AssociatedTitlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.associatedTitles,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssociatedTitlesTableAnnotationComposer(
            $db: $db,
            $table: $db.associatedTitles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool mainCategoryPk,
            bool transactionsRefs,
            bool budgetCategoryLimitsRefs,
            bool recurringTransactionsRefs,
            bool associatedTitlesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> mainCategoryPk = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                kind: kind,
                mainCategoryPk: mainCategoryPk,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                required String kind,
                Value<int?> mainCategoryPk = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                kind: kind,
                mainCategoryPk: mainCategoryPk,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mainCategoryPk = false,
                transactionsRefs = false,
                budgetCategoryLimitsRefs = false,
                recurringTransactionsRefs = false,
                associatedTitlesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (budgetCategoryLimitsRefs) db.budgetCategoryLimits,
                    if (recurringTransactionsRefs) db.recurringTransactions,
                    if (associatedTitlesRefs) db.associatedTitles,
                  ],
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
                        if (mainCategoryPk) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mainCategoryPk,
                                    referencedTable: $$CategoriesTableReferences
                                        ._mainCategoryPkTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._mainCategoryPkTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetCategoryLimitsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          BudgetCategoryLimit
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._budgetCategoryLimitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetCategoryLimitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringTransactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          RecurringTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (associatedTitlesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          AssociatedTitle
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._associatedTitlesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).associatedTitlesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool mainCategoryPk,
        bool transactionsRefs,
        bool budgetCategoryLimitsRefs,
        bool recurringTransactionsRefs,
        bool associatedTitlesRefs,
      })
    >;
typedef $$ObjectivesTableCreateCompanionBuilder =
    ObjectivesCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required int amountMinor,
      Value<int?> walletId,
      required String currencyCode,
      Value<DateTime?> deadline,
      Value<int?> color,
      Value<String?> icon,
      Value<bool> pinned,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ObjectivesTableUpdateCompanionBuilder =
    ObjectivesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<int> amountMinor,
      Value<int?> walletId,
      Value<String> currencyCode,
      Value<DateTime?> deadline,
      Value<int?> color,
      Value<String?> icon,
      Value<bool> pinned,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ObjectivesTableReferences
    extends BaseReferences<_$AppDatabase, $ObjectivesTable, Objective> {
  $$ObjectivesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WalletsTable _walletIdTable(_$AppDatabase db) => db.wallets
      .createAlias($_aliasNameGenerator(db.objectives.walletId, db.wallets.id));

  $$WalletsTableProcessedTableManager? get walletId {
    final $_column = $_itemColumn<int>('wallet_id');
    if ($_column == null) return null;
    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.objectives.id,
      db.transactions.objectiveFk,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.objectiveFk.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObjectivesTableFilterComposer
    extends Composer<_$AppDatabase, $ObjectivesTable> {
  $$ObjectivesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.objectiveFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectivesTableOrderingComposer
    extends Composer<_$AppDatabase, $ObjectivesTable> {
  $$ObjectivesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObjectivesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObjectivesTable> {
  $$ObjectivesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.objectiveFk,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObjectivesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObjectivesTable,
          Objective,
          $$ObjectivesTableFilterComposer,
          $$ObjectivesTableOrderingComposer,
          $$ObjectivesTableAnnotationComposer,
          $$ObjectivesTableCreateCompanionBuilder,
          $$ObjectivesTableUpdateCompanionBuilder,
          (Objective, $$ObjectivesTableReferences),
          Objective,
          PrefetchHooks Function({bool walletId, bool transactionsRefs})
        > {
  $$ObjectivesTableTableManager(_$AppDatabase db, $ObjectivesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObjectivesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObjectivesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObjectivesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int?> walletId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ObjectivesCompanion(
                id: id,
                name: name,
                type: type,
                amountMinor: amountMinor,
                walletId: walletId,
                currencyCode: currencyCode,
                deadline: deadline,
                color: color,
                icon: icon,
                pinned: pinned,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required int amountMinor,
                Value<int?> walletId = const Value.absent(),
                required String currencyCode,
                Value<DateTime?> deadline = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ObjectivesCompanion.insert(
                id: id,
                name: name,
                type: type,
                amountMinor: amountMinor,
                walletId: walletId,
                currencyCode: currencyCode,
                deadline: deadline,
                color: color,
                icon: icon,
                pinned: pinned,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObjectivesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({walletId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
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
                        if (walletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.walletId,
                                    referencedTable: $$ObjectivesTableReferences
                                        ._walletIdTable(db),
                                    referencedColumn:
                                        $$ObjectivesTableReferences
                                            ._walletIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Objective,
                          $ObjectivesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ObjectivesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObjectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.objectiveFk == item.id,
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

typedef $$ObjectivesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObjectivesTable,
      Objective,
      $$ObjectivesTableFilterComposer,
      $$ObjectivesTableOrderingComposer,
      $$ObjectivesTableAnnotationComposer,
      $$ObjectivesTableCreateCompanionBuilder,
      $$ObjectivesTableUpdateCompanionBuilder,
      (Objective, $$ObjectivesTableReferences),
      Objective,
      PrefetchHooks Function({bool walletId, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required String type,
      Value<String> specialType,
      required int amountMinor,
      required String currencyCode,
      required DateTime date,
      required int walletId,
      Value<int?> transferWalletId,
      Value<int?> categoryId,
      Value<String?> title,
      Value<String?> note,
      Value<String?> tags,
      Value<String?> recurrenceRule,
      Value<int?> objectiveFk,
      Value<String?> attachmentPath,
      Value<String?> methodAdded,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> specialType,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<DateTime> date,
      Value<int> walletId,
      Value<int?> transferWalletId,
      Value<int?> categoryId,
      Value<String?> title,
      Value<String?> note,
      Value<String?> tags,
      Value<String?> recurrenceRule,
      Value<int?> objectiveFk,
      Value<String?> attachmentPath,
      Value<String?> methodAdded,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WalletsTable _walletIdTable(_$AppDatabase db) =>
      db.wallets.createAlias(
        $_aliasNameGenerator(db.transactions.walletId, db.wallets.id),
      );

  $$WalletsTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<int>('wallet_id')!;

    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WalletsTable _transferWalletIdTable(_$AppDatabase db) =>
      db.wallets.createAlias(
        $_aliasNameGenerator(db.transactions.transferWalletId, db.wallets.id),
      );

  $$WalletsTableProcessedTableManager? get transferWalletId {
    final $_column = $_itemColumn<int>('transfer_wallet_id');
    if ($_column == null) return null;
    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transferWalletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObjectivesTable _objectiveFkTable(_$AppDatabase db) =>
      db.objectives.createAlias(
        $_aliasNameGenerator(db.transactions.objectiveFk, db.objectives.id),
      );

  $$ObjectivesTableProcessedTableManager? get objectiveFk {
    final $_column = $_itemColumn<int>('objective_fk');
    if ($_column == null) return null;
    final manager = $$ObjectivesTableTableManager(
      $_db,
      $_db.objectives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_objectiveFkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionBudgetsTable, List<TransactionBudget>>
  _transactionBudgetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionBudgets,
        aliasName: $_aliasNameGenerator(
          db.transactions.id,
          db.transactionBudgets.transactionId,
        ),
      );

  $$TransactionBudgetsTableProcessedTableManager get transactionBudgetsRefs {
    final manager = $$TransactionBudgetsTableTableManager(
      $_db,
      $_db.transactionBudgets,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionBudgetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialType => $composableBuilder(
    column: $table.specialType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodAdded => $composableBuilder(
    column: $table.methodAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableFilterComposer get transferWalletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferWalletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectivesTableFilterComposer get objectiveFk {
    final $$ObjectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveFk,
      referencedTable: $db.objectives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectivesTableFilterComposer(
            $db: $db,
            $table: $db.objectives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionBudgetsRefs(
    Expression<bool> Function($$TransactionBudgetsTableFilterComposer f) f,
  ) {
    final $$TransactionBudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionBudgets,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionBudgetsTableFilterComposer(
            $db: $db,
            $table: $db.transactionBudgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialType => $composableBuilder(
    column: $table.specialType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodAdded => $composableBuilder(
    column: $table.methodAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableOrderingComposer get transferWalletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferWalletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectivesTableOrderingComposer get objectiveFk {
    final $$ObjectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveFk,
      referencedTable: $db.objectives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectivesTableOrderingComposer(
            $db: $db,
            $table: $db.objectives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get specialType => $composableBuilder(
    column: $table.specialType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get methodAdded => $composableBuilder(
    column: $table.methodAdded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableAnnotationComposer get transferWalletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferWalletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObjectivesTableAnnotationComposer get objectiveFk {
    final $$ObjectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.objectiveFk,
      referencedTable: $db.objectives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObjectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.objectives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionBudgetsRefs<T extends Object>(
    Expression<T> Function($$TransactionBudgetsTableAnnotationComposer a) f,
  ) {
    final $$TransactionBudgetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionBudgets,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionBudgetsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionBudgets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool walletId,
            bool transferWalletId,
            bool categoryId,
            bool objectiveFk,
            bool transactionBudgetsRefs,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> specialType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<int?> transferWalletId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int?> objectiveFk = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<String?> methodAdded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                specialType: specialType,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                date: date,
                walletId: walletId,
                transferWalletId: transferWalletId,
                categoryId: categoryId,
                title: title,
                note: note,
                tags: tags,
                recurrenceRule: recurrenceRule,
                objectiveFk: objectiveFk,
                attachmentPath: attachmentPath,
                methodAdded: methodAdded,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<String> specialType = const Value.absent(),
                required int amountMinor,
                required String currencyCode,
                required DateTime date,
                required int walletId,
                Value<int?> transferWalletId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int?> objectiveFk = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<String?> methodAdded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                specialType: specialType,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                date: date,
                walletId: walletId,
                transferWalletId: transferWalletId,
                categoryId: categoryId,
                title: title,
                note: note,
                tags: tags,
                recurrenceRule: recurrenceRule,
                objectiveFk: objectiveFk,
                attachmentPath: attachmentPath,
                methodAdded: methodAdded,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                walletId = false,
                transferWalletId = false,
                categoryId = false,
                objectiveFk = false,
                transactionBudgetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionBudgetsRefs) db.transactionBudgets,
                  ],
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
                        if (walletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.walletId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._walletIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._walletIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (transferWalletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transferWalletId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._transferWalletIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._transferWalletIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (objectiveFk) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.objectiveFk,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._objectiveFkTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._objectiveFkTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionBudgetsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          TransactionBudget
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionBudgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionBudgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool walletId,
        bool transferWalletId,
        bool categoryId,
        bool objectiveFk,
        bool transactionBudgetsRefs,
      })
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime periodStart,
      required DateTime periodEnd,
      required String currencyCode,
      Value<bool> isIncome,
      Value<bool> pinned,
      Value<bool> archived,
      Value<int?> color,
      Value<int> plannedAmountMinor,
      Value<bool> specificMode,
      Value<bool> includeIncome,
      Value<bool> includeDebtCredit,
      Value<bool> includeBalanceCorrection,
      Value<bool> includeInOtherBudgets,
      Value<bool> absoluteLimit,
      Value<String?> recurrenceRule,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> periodStart,
      Value<DateTime> periodEnd,
      Value<String> currencyCode,
      Value<bool> isIncome,
      Value<bool> pinned,
      Value<bool> archived,
      Value<int?> color,
      Value<int> plannedAmountMinor,
      Value<bool> specificMode,
      Value<bool> includeIncome,
      Value<bool> includeDebtCredit,
      Value<bool> includeBalanceCorrection,
      Value<bool> includeInOtherBudgets,
      Value<bool> absoluteLimit,
      Value<String?> recurrenceRule,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionBudgetsTable, List<TransactionBudget>>
  _transactionBudgetsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionBudgets,
        aliasName: $_aliasNameGenerator(
          db.budgets.id,
          db.transactionBudgets.budgetId,
        ),
      );

  $$TransactionBudgetsTableProcessedTableManager get transactionBudgetsRefs {
    final manager = $$TransactionBudgetsTableTableManager(
      $_db,
      $_db.transactionBudgets,
    ).filter((f) => f.budgetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionBudgetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $BudgetCategoryLimitsTable,
    List<BudgetCategoryLimit>
  >
  _budgetCategoryLimitsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.budgetCategoryLimits,
        aliasName: $_aliasNameGenerator(
          db.budgets.id,
          db.budgetCategoryLimits.budgetId,
        ),
      );

  $$BudgetCategoryLimitsTableProcessedTableManager
  get budgetCategoryLimitsRefs {
    final manager = $$BudgetCategoryLimitsTableTableManager(
      $_db,
      $_db.budgetCategoryLimits,
    ).filter((f) => f.budgetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _budgetCategoryLimitsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetWalletsTable, List<BudgetWallet>>
  _budgetWalletsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.budgetWallets,
    aliasName: $_aliasNameGenerator(db.budgets.id, db.budgetWallets.budgetId),
  );

  $$BudgetWalletsTableProcessedTableManager get budgetWalletsRefs {
    final manager = $$BudgetWalletsTableTableManager(
      $_db,
      $_db.budgetWallets,
    ).filter((f) => f.budgetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetWalletsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get specificMode => $composableBuilder(
    column: $table.specificMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeIncome => $composableBuilder(
    column: $table.includeIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeDebtCredit => $composableBuilder(
    column: $table.includeDebtCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeBalanceCorrection => $composableBuilder(
    column: $table.includeBalanceCorrection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInOtherBudgets => $composableBuilder(
    column: $table.includeInOtherBudgets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get absoluteLimit => $composableBuilder(
    column: $table.absoluteLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionBudgetsRefs(
    Expression<bool> Function($$TransactionBudgetsTableFilterComposer f) f,
  ) {
    final $$TransactionBudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionBudgets,
      getReferencedColumn: (t) => t.budgetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionBudgetsTableFilterComposer(
            $db: $db,
            $table: $db.transactionBudgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetCategoryLimitsRefs(
    Expression<bool> Function($$BudgetCategoryLimitsTableFilterComposer f) f,
  ) {
    final $$BudgetCategoryLimitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetCategoryLimits,
      getReferencedColumn: (t) => t.budgetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetCategoryLimitsTableFilterComposer(
            $db: $db,
            $table: $db.budgetCategoryLimits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetWalletsRefs(
    Expression<bool> Function($$BudgetWalletsTableFilterComposer f) f,
  ) {
    final $$BudgetWalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetWallets,
      getReferencedColumn: (t) => t.budgetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetWalletsTableFilterComposer(
            $db: $db,
            $table: $db.budgetWallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get specificMode => $composableBuilder(
    column: $table.specificMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeIncome => $composableBuilder(
    column: $table.includeIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeDebtCredit => $composableBuilder(
    column: $table.includeDebtCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeBalanceCorrection => $composableBuilder(
    column: $table.includeBalanceCorrection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInOtherBudgets => $composableBuilder(
    column: $table.includeInOtherBudgets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get absoluteLimit => $composableBuilder(
    column: $table.absoluteLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get specificMode => $composableBuilder(
    column: $table.specificMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeIncome => $composableBuilder(
    column: $table.includeIncome,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeDebtCredit => $composableBuilder(
    column: $table.includeDebtCredit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeBalanceCorrection => $composableBuilder(
    column: $table.includeBalanceCorrection,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get includeInOtherBudgets => $composableBuilder(
    column: $table.includeInOtherBudgets,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get absoluteLimit => $composableBuilder(
    column: $table.absoluteLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> transactionBudgetsRefs<T extends Object>(
    Expression<T> Function($$TransactionBudgetsTableAnnotationComposer a) f,
  ) {
    final $$TransactionBudgetsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionBudgets,
          getReferencedColumn: (t) => t.budgetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionBudgetsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionBudgets,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> budgetCategoryLimitsRefs<T extends Object>(
    Expression<T> Function($$BudgetCategoryLimitsTableAnnotationComposer a) f,
  ) {
    final $$BudgetCategoryLimitsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.budgetCategoryLimits,
          getReferencedColumn: (t) => t.budgetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BudgetCategoryLimitsTableAnnotationComposer(
                $db: $db,
                $table: $db.budgetCategoryLimits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> budgetWalletsRefs<T extends Object>(
    Expression<T> Function($$BudgetWalletsTableAnnotationComposer a) f,
  ) {
    final $$BudgetWalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgetWallets,
      getReferencedColumn: (t) => t.budgetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetWalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgetWallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({
            bool transactionBudgetsRefs,
            bool budgetCategoryLimitsRefs,
            bool budgetWalletsRefs,
          })
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> periodEnd = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> plannedAmountMinor = const Value.absent(),
                Value<bool> specificMode = const Value.absent(),
                Value<bool> includeIncome = const Value.absent(),
                Value<bool> includeDebtCredit = const Value.absent(),
                Value<bool> includeBalanceCorrection = const Value.absent(),
                Value<bool> includeInOtherBudgets = const Value.absent(),
                Value<bool> absoluteLimit = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                name: name,
                periodStart: periodStart,
                periodEnd: periodEnd,
                currencyCode: currencyCode,
                isIncome: isIncome,
                pinned: pinned,
                archived: archived,
                color: color,
                plannedAmountMinor: plannedAmountMinor,
                specificMode: specificMode,
                includeIncome: includeIncome,
                includeDebtCredit: includeDebtCredit,
                includeBalanceCorrection: includeBalanceCorrection,
                includeInOtherBudgets: includeInOtherBudgets,
                absoluteLimit: absoluteLimit,
                recurrenceRule: recurrenceRule,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime periodStart,
                required DateTime periodEnd,
                required String currencyCode,
                Value<bool> isIncome = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<int> plannedAmountMinor = const Value.absent(),
                Value<bool> specificMode = const Value.absent(),
                Value<bool> includeIncome = const Value.absent(),
                Value<bool> includeDebtCredit = const Value.absent(),
                Value<bool> includeBalanceCorrection = const Value.absent(),
                Value<bool> includeInOtherBudgets = const Value.absent(),
                Value<bool> absoluteLimit = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                name: name,
                periodStart: periodStart,
                periodEnd: periodEnd,
                currencyCode: currencyCode,
                isIncome: isIncome,
                pinned: pinned,
                archived: archived,
                color: color,
                plannedAmountMinor: plannedAmountMinor,
                specificMode: specificMode,
                includeIncome: includeIncome,
                includeDebtCredit: includeDebtCredit,
                includeBalanceCorrection: includeBalanceCorrection,
                includeInOtherBudgets: includeInOtherBudgets,
                absoluteLimit: absoluteLimit,
                recurrenceRule: recurrenceRule,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionBudgetsRefs = false,
                budgetCategoryLimitsRefs = false,
                budgetWalletsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionBudgetsRefs) db.transactionBudgets,
                    if (budgetCategoryLimitsRefs) db.budgetCategoryLimits,
                    if (budgetWalletsRefs) db.budgetWallets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionBudgetsRefs)
                        await $_getPrefetchedData<
                          Budget,
                          $BudgetsTable,
                          TransactionBudget
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetsTableReferences
                              ._transactionBudgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionBudgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetCategoryLimitsRefs)
                        await $_getPrefetchedData<
                          Budget,
                          $BudgetsTable,
                          BudgetCategoryLimit
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetsTableReferences
                              ._budgetCategoryLimitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetsTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetCategoryLimitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetWalletsRefs)
                        await $_getPrefetchedData<
                          Budget,
                          $BudgetsTable,
                          BudgetWallet
                        >(
                          currentTable: table,
                          referencedTable: $$BudgetsTableReferences
                              ._budgetWalletsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BudgetsTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetWalletsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.budgetId == item.id,
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

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({
        bool transactionBudgetsRefs,
        bool budgetCategoryLimitsRefs,
        bool budgetWalletsRefs,
      })
    >;
typedef $$TransactionBudgetsTableCreateCompanionBuilder =
    TransactionBudgetsCompanion Function({
      Value<int> id,
      required int transactionId,
      required int budgetId,
    });
typedef $$TransactionBudgetsTableUpdateCompanionBuilder =
    TransactionBudgetsCompanion Function({
      Value<int> id,
      Value<int> transactionId,
      Value<int> budgetId,
    });

final class $$TransactionBudgetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionBudgetsTable,
          TransactionBudget
        > {
  $$TransactionBudgetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
        $_aliasNameGenerator(
          db.transactionBudgets.transactionId,
          db.transactions.id,
        ),
      );

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BudgetsTable _budgetIdTable(_$AppDatabase db) =>
      db.budgets.createAlias(
        $_aliasNameGenerator(db.transactionBudgets.budgetId, db.budgets.id),
      );

  $$BudgetsTableProcessedTableManager get budgetId {
    final $_column = $_itemColumn<int>('budget_id')!;

    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionBudgetsTable> {
  $$TransactionBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionBudgetsTable> {
  $$TransactionBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableOrderingComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionBudgetsTable> {
  $$TransactionBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionBudgetsTable,
          TransactionBudget,
          $$TransactionBudgetsTableFilterComposer,
          $$TransactionBudgetsTableOrderingComposer,
          $$TransactionBudgetsTableAnnotationComposer,
          $$TransactionBudgetsTableCreateCompanionBuilder,
          $$TransactionBudgetsTableUpdateCompanionBuilder,
          (TransactionBudget, $$TransactionBudgetsTableReferences),
          TransactionBudget,
          PrefetchHooks Function({bool transactionId, bool budgetId})
        > {
  $$TransactionBudgetsTableTableManager(
    _$AppDatabase db,
    $TransactionBudgetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionBudgetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<int> budgetId = const Value.absent(),
              }) => TransactionBudgetsCompanion(
                id: id,
                transactionId: transactionId,
                budgetId: budgetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transactionId,
                required int budgetId,
              }) => TransactionBudgetsCompanion.insert(
                id: id,
                transactionId: transactionId,
                budgetId: budgetId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionBudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false, budgetId = false}) {
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
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionBudgetsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionBudgetsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (budgetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.budgetId,
                                referencedTable:
                                    $$TransactionBudgetsTableReferences
                                        ._budgetIdTable(db),
                                referencedColumn:
                                    $$TransactionBudgetsTableReferences
                                        ._budgetIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$TransactionBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionBudgetsTable,
      TransactionBudget,
      $$TransactionBudgetsTableFilterComposer,
      $$TransactionBudgetsTableOrderingComposer,
      $$TransactionBudgetsTableAnnotationComposer,
      $$TransactionBudgetsTableCreateCompanionBuilder,
      $$TransactionBudgetsTableUpdateCompanionBuilder,
      (TransactionBudget, $$TransactionBudgetsTableReferences),
      TransactionBudget,
      PrefetchHooks Function({bool transactionId, bool budgetId})
    >;
typedef $$BudgetCategoryLimitsTableCreateCompanionBuilder =
    BudgetCategoryLimitsCompanion Function({
      Value<int> id,
      required int budgetId,
      required int categoryId,
      Value<int?> walletId,
      required int plannedAmountMinor,
    });
typedef $$BudgetCategoryLimitsTableUpdateCompanionBuilder =
    BudgetCategoryLimitsCompanion Function({
      Value<int> id,
      Value<int> budgetId,
      Value<int> categoryId,
      Value<int?> walletId,
      Value<int> plannedAmountMinor,
    });

final class $$BudgetCategoryLimitsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BudgetCategoryLimitsTable,
          BudgetCategoryLimit
        > {
  $$BudgetCategoryLimitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BudgetsTable _budgetIdTable(_$AppDatabase db) =>
      db.budgets.createAlias(
        $_aliasNameGenerator(db.budgetCategoryLimits.budgetId, db.budgets.id),
      );

  $$BudgetsTableProcessedTableManager get budgetId {
    final $_column = $_itemColumn<int>('budget_id')!;

    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(
          db.budgetCategoryLimits.categoryId,
          db.categories.id,
        ),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WalletsTable _walletIdTable(_$AppDatabase db) =>
      db.wallets.createAlias(
        $_aliasNameGenerator(db.budgetCategoryLimits.walletId, db.wallets.id),
      );

  $$WalletsTableProcessedTableManager? get walletId {
    final $_column = $_itemColumn<int>('wallet_id');
    if ($_column == null) return null;
    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetCategoryLimitsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetCategoryLimitsTable> {
  $$BudgetCategoryLimitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetCategoryLimitsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetCategoryLimitsTable> {
  $$BudgetCategoryLimitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableOrderingComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetCategoryLimitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetCategoryLimitsTable> {
  $$BudgetCategoryLimitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get plannedAmountMinor => $composableBuilder(
    column: $table.plannedAmountMinor,
    builder: (column) => column,
  );

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetCategoryLimitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetCategoryLimitsTable,
          BudgetCategoryLimit,
          $$BudgetCategoryLimitsTableFilterComposer,
          $$BudgetCategoryLimitsTableOrderingComposer,
          $$BudgetCategoryLimitsTableAnnotationComposer,
          $$BudgetCategoryLimitsTableCreateCompanionBuilder,
          $$BudgetCategoryLimitsTableUpdateCompanionBuilder,
          (BudgetCategoryLimit, $$BudgetCategoryLimitsTableReferences),
          BudgetCategoryLimit,
          PrefetchHooks Function({
            bool budgetId,
            bool categoryId,
            bool walletId,
          })
        > {
  $$BudgetCategoryLimitsTableTableManager(
    _$AppDatabase db,
    $BudgetCategoryLimitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetCategoryLimitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetCategoryLimitsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BudgetCategoryLimitsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> budgetId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> walletId = const Value.absent(),
                Value<int> plannedAmountMinor = const Value.absent(),
              }) => BudgetCategoryLimitsCompanion(
                id: id,
                budgetId: budgetId,
                categoryId: categoryId,
                walletId: walletId,
                plannedAmountMinor: plannedAmountMinor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int budgetId,
                required int categoryId,
                Value<int?> walletId = const Value.absent(),
                required int plannedAmountMinor,
              }) => BudgetCategoryLimitsCompanion.insert(
                id: id,
                budgetId: budgetId,
                categoryId: categoryId,
                walletId: walletId,
                plannedAmountMinor: plannedAmountMinor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetCategoryLimitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({budgetId = false, categoryId = false, walletId = false}) {
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
                        if (budgetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.budgetId,
                                    referencedTable:
                                        $$BudgetCategoryLimitsTableReferences
                                            ._budgetIdTable(db),
                                    referencedColumn:
                                        $$BudgetCategoryLimitsTableReferences
                                            ._budgetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$BudgetCategoryLimitsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$BudgetCategoryLimitsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (walletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.walletId,
                                    referencedTable:
                                        $$BudgetCategoryLimitsTableReferences
                                            ._walletIdTable(db),
                                    referencedColumn:
                                        $$BudgetCategoryLimitsTableReferences
                                            ._walletIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$BudgetCategoryLimitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetCategoryLimitsTable,
      BudgetCategoryLimit,
      $$BudgetCategoryLimitsTableFilterComposer,
      $$BudgetCategoryLimitsTableOrderingComposer,
      $$BudgetCategoryLimitsTableAnnotationComposer,
      $$BudgetCategoryLimitsTableCreateCompanionBuilder,
      $$BudgetCategoryLimitsTableUpdateCompanionBuilder,
      (BudgetCategoryLimit, $$BudgetCategoryLimitsTableReferences),
      BudgetCategoryLimit,
      PrefetchHooks Function({bool budgetId, bool categoryId, bool walletId})
    >;
typedef $$BudgetWalletsTableCreateCompanionBuilder =
    BudgetWalletsCompanion Function({
      Value<int> id,
      required int budgetId,
      required int walletId,
    });
typedef $$BudgetWalletsTableUpdateCompanionBuilder =
    BudgetWalletsCompanion Function({
      Value<int> id,
      Value<int> budgetId,
      Value<int> walletId,
    });

final class $$BudgetWalletsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetWalletsTable, BudgetWallet> {
  $$BudgetWalletsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BudgetsTable _budgetIdTable(_$AppDatabase db) =>
      db.budgets.createAlias(
        $_aliasNameGenerator(db.budgetWallets.budgetId, db.budgets.id),
      );

  $$BudgetsTableProcessedTableManager get budgetId {
    final $_column = $_itemColumn<int>('budget_id')!;

    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WalletsTable _walletIdTable(_$AppDatabase db) =>
      db.wallets.createAlias(
        $_aliasNameGenerator(db.budgetWallets.walletId, db.wallets.id),
      );

  $$WalletsTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<int>('wallet_id')!;

    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetWalletsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetWalletsTable> {
  $$BudgetWalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetWalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetWalletsTable> {
  $$BudgetWalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableOrderingComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetWalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetWalletsTable> {
  $$BudgetWalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.budgetId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetWalletsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetWalletsTable,
          BudgetWallet,
          $$BudgetWalletsTableFilterComposer,
          $$BudgetWalletsTableOrderingComposer,
          $$BudgetWalletsTableAnnotationComposer,
          $$BudgetWalletsTableCreateCompanionBuilder,
          $$BudgetWalletsTableUpdateCompanionBuilder,
          (BudgetWallet, $$BudgetWalletsTableReferences),
          BudgetWallet,
          PrefetchHooks Function({bool budgetId, bool walletId})
        > {
  $$BudgetWalletsTableTableManager(_$AppDatabase db, $BudgetWalletsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetWalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetWalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetWalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> budgetId = const Value.absent(),
                Value<int> walletId = const Value.absent(),
              }) => BudgetWalletsCompanion(
                id: id,
                budgetId: budgetId,
                walletId: walletId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int budgetId,
                required int walletId,
              }) => BudgetWalletsCompanion.insert(
                id: id,
                budgetId: budgetId,
                walletId: walletId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetWalletsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({budgetId = false, walletId = false}) {
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
                    if (budgetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.budgetId,
                                referencedTable: $$BudgetWalletsTableReferences
                                    ._budgetIdTable(db),
                                referencedColumn: $$BudgetWalletsTableReferences
                                    ._budgetIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (walletId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.walletId,
                                referencedTable: $$BudgetWalletsTableReferences
                                    ._walletIdTable(db),
                                referencedColumn: $$BudgetWalletsTableReferences
                                    ._walletIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$BudgetWalletsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetWalletsTable,
      BudgetWallet,
      $$BudgetWalletsTableFilterComposer,
      $$BudgetWalletsTableOrderingComposer,
      $$BudgetWalletsTableAnnotationComposer,
      $$BudgetWalletsTableCreateCompanionBuilder,
      $$BudgetWalletsTableUpdateCompanionBuilder,
      (BudgetWallet, $$BudgetWalletsTableReferences),
      BudgetWallet,
      PrefetchHooks Function({bool budgetId, bool walletId})
    >;
typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<int> id,
      required String transactionType,
      Value<String> specialType,
      required int amountMinor,
      Value<String> currencyCode,
      required int walletId,
      Value<int?> transferWalletId,
      Value<int?> categoryId,
      Value<String?> title,
      Value<String?> note,
      required String scheduleRule,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> nextDueDate,
      Value<bool> active,
      Value<DateTime> createdAt,
    });
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<int> id,
      Value<String> transactionType,
      Value<String> specialType,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<int> walletId,
      Value<int?> transferWalletId,
      Value<int?> categoryId,
      Value<String?> title,
      Value<String?> note,
      Value<String> scheduleRule,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> nextDueDate,
      Value<bool> active,
      Value<DateTime> createdAt,
    });

final class $$RecurringTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction
        > {
  $$RecurringTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WalletsTable _walletIdTable(_$AppDatabase db) =>
      db.wallets.createAlias(
        $_aliasNameGenerator(db.recurringTransactions.walletId, db.wallets.id),
      );

  $$WalletsTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<int>('wallet_id')!;

    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WalletsTable _transferWalletIdTable(_$AppDatabase db) =>
      db.wallets.createAlias(
        $_aliasNameGenerator(
          db.recurringTransactions.transferWalletId,
          db.wallets.id,
        ),
      );

  $$WalletsTableProcessedTableManager? get transferWalletId {
    final $_column = $_itemColumn<int>('transfer_wallet_id');
    if ($_column == null) return null;
    final manager = $$WalletsTableTableManager(
      $_db,
      $_db.wallets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transferWalletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(
          db.recurringTransactions.categoryId,
          db.categories.id,
        ),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialType => $composableBuilder(
    column: $table.specialType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleRule => $composableBuilder(
    column: $table.scheduleRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WalletsTableFilterComposer get walletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableFilterComposer get transferWalletId {
    final $$WalletsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferWalletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableFilterComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialType => $composableBuilder(
    column: $table.specialType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleRule => $composableBuilder(
    column: $table.scheduleRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WalletsTableOrderingComposer get walletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableOrderingComposer get transferWalletId {
    final $$WalletsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferWalletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableOrderingComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialType => $composableBuilder(
    column: $table.specialType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get scheduleRule => $composableBuilder(
    column: $table.scheduleRule,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WalletsTableAnnotationComposer get walletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.walletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WalletsTableAnnotationComposer get transferWalletId {
    final $$WalletsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferWalletId,
      referencedTable: $db.wallets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WalletsTableAnnotationComposer(
            $db: $db,
            $table: $db.wallets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableAnnotationComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder,
          (RecurringTransaction, $$RecurringTransactionsTableReferences),
          RecurringTransaction,
          PrefetchHooks Function({
            bool walletId,
            bool transferWalletId,
            bool categoryId,
          })
        > {
  $$RecurringTransactionsTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String> specialType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> walletId = const Value.absent(),
                Value<int?> transferWalletId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> scheduleRule = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecurringTransactionsCompanion(
                id: id,
                transactionType: transactionType,
                specialType: specialType,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                walletId: walletId,
                transferWalletId: transferWalletId,
                categoryId: categoryId,
                title: title,
                note: note,
                scheduleRule: scheduleRule,
                startDate: startDate,
                endDate: endDate,
                nextDueDate: nextDueDate,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String transactionType,
                Value<String> specialType = const Value.absent(),
                required int amountMinor,
                Value<String> currencyCode = const Value.absent(),
                required int walletId,
                Value<int?> transferWalletId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String scheduleRule,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecurringTransactionsCompanion.insert(
                id: id,
                transactionType: transactionType,
                specialType: specialType,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                walletId: walletId,
                transferWalletId: transferWalletId,
                categoryId: categoryId,
                title: title,
                note: note,
                scheduleRule: scheduleRule,
                startDate: startDate,
                endDate: endDate,
                nextDueDate: nextDueDate,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                walletId = false,
                transferWalletId = false,
                categoryId = false,
              }) {
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
                        if (walletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.walletId,
                                    referencedTable:
                                        $$RecurringTransactionsTableReferences
                                            ._walletIdTable(db),
                                    referencedColumn:
                                        $$RecurringTransactionsTableReferences
                                            ._walletIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (transferWalletId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.transferWalletId,
                                    referencedTable:
                                        $$RecurringTransactionsTableReferences
                                            ._transferWalletIdTable(db),
                                    referencedColumn:
                                        $$RecurringTransactionsTableReferences
                                            ._transferWalletIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$RecurringTransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$RecurringTransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$RecurringTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTransactionsTable,
      RecurringTransaction,
      $$RecurringTransactionsTableFilterComposer,
      $$RecurringTransactionsTableOrderingComposer,
      $$RecurringTransactionsTableAnnotationComposer,
      $$RecurringTransactionsTableCreateCompanionBuilder,
      $$RecurringTransactionsTableUpdateCompanionBuilder,
      (RecurringTransaction, $$RecurringTransactionsTableReferences),
      RecurringTransaction,
      PrefetchHooks Function({
        bool walletId,
        bool transferWalletId,
        bool categoryId,
      })
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
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
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
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
typedef $$AssociatedTitlesTableCreateCompanionBuilder =
    AssociatedTitlesCompanion Function({
      Value<int> id,
      required String title,
      required int categoryId,
      Value<bool> exactMatch,
      Value<DateTime> createdAt,
    });
typedef $$AssociatedTitlesTableUpdateCompanionBuilder =
    AssociatedTitlesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> categoryId,
      Value<bool> exactMatch,
      Value<DateTime> createdAt,
    });

final class $$AssociatedTitlesTableReferences
    extends
        BaseReferences<_$AppDatabase, $AssociatedTitlesTable, AssociatedTitle> {
  $$AssociatedTitlesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.associatedTitles.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssociatedTitlesTableFilterComposer
    extends Composer<_$AppDatabase, $AssociatedTitlesTable> {
  $$AssociatedTitlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exactMatch => $composableBuilder(
    column: $table.exactMatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssociatedTitlesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssociatedTitlesTable> {
  $$AssociatedTitlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exactMatch => $composableBuilder(
    column: $table.exactMatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssociatedTitlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssociatedTitlesTable> {
  $$AssociatedTitlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get exactMatch => $composableBuilder(
    column: $table.exactMatch,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssociatedTitlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssociatedTitlesTable,
          AssociatedTitle,
          $$AssociatedTitlesTableFilterComposer,
          $$AssociatedTitlesTableOrderingComposer,
          $$AssociatedTitlesTableAnnotationComposer,
          $$AssociatedTitlesTableCreateCompanionBuilder,
          $$AssociatedTitlesTableUpdateCompanionBuilder,
          (AssociatedTitle, $$AssociatedTitlesTableReferences),
          AssociatedTitle,
          PrefetchHooks Function({bool categoryId})
        > {
  $$AssociatedTitlesTableTableManager(
    _$AppDatabase db,
    $AssociatedTitlesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssociatedTitlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssociatedTitlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssociatedTitlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<bool> exactMatch = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssociatedTitlesCompanion(
                id: id,
                title: title,
                categoryId: categoryId,
                exactMatch: exactMatch,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int categoryId,
                Value<bool> exactMatch = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssociatedTitlesCompanion.insert(
                id: id,
                title: title,
                categoryId: categoryId,
                exactMatch: exactMatch,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssociatedTitlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$AssociatedTitlesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$AssociatedTitlesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$AssociatedTitlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssociatedTitlesTable,
      AssociatedTitle,
      $$AssociatedTitlesTableFilterComposer,
      $$AssociatedTitlesTableOrderingComposer,
      $$AssociatedTitlesTableAnnotationComposer,
      $$AssociatedTitlesTableCreateCompanionBuilder,
      $$AssociatedTitlesTableUpdateCompanionBuilder,
      (AssociatedTitle, $$AssociatedTitlesTableReferences),
      AssociatedTitle,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$DeleteLogsTableCreateCompanionBuilder =
    DeleteLogsCompanion Function({
      Value<int> id,
      required String type,
      required String jsonData,
      Value<DateTime> deletedAt,
    });
typedef $$DeleteLogsTableUpdateCompanionBuilder =
    DeleteLogsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> jsonData,
      Value<DateTime> deletedAt,
    });

class $$DeleteLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DeleteLogsTable> {
  $$DeleteLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeleteLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeleteLogsTable> {
  $$DeleteLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeleteLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeleteLogsTable> {
  $$DeleteLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$DeleteLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeleteLogsTable,
          DeleteLog,
          $$DeleteLogsTableFilterComposer,
          $$DeleteLogsTableOrderingComposer,
          $$DeleteLogsTableAnnotationComposer,
          $$DeleteLogsTableCreateCompanionBuilder,
          $$DeleteLogsTableUpdateCompanionBuilder,
          (
            DeleteLog,
            BaseReferences<_$AppDatabase, $DeleteLogsTable, DeleteLog>,
          ),
          DeleteLog,
          PrefetchHooks Function()
        > {
  $$DeleteLogsTableTableManager(_$AppDatabase db, $DeleteLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeleteLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeleteLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeleteLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
              }) => DeleteLogsCompanion(
                id: id,
                type: type,
                jsonData: jsonData,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String jsonData,
                Value<DateTime> deletedAt = const Value.absent(),
              }) => DeleteLogsCompanion.insert(
                id: id,
                type: type,
                jsonData: jsonData,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeleteLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeleteLogsTable,
      DeleteLog,
      $$DeleteLogsTableFilterComposer,
      $$DeleteLogsTableOrderingComposer,
      $$DeleteLogsTableAnnotationComposer,
      $$DeleteLogsTableCreateCompanionBuilder,
      $$DeleteLogsTableUpdateCompanionBuilder,
      (DeleteLog, BaseReferences<_$AppDatabase, $DeleteLogsTable, DeleteLog>),
      DeleteLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ObjectivesTableTableManager get objectives =>
      $$ObjectivesTableTableManager(_db, _db.objectives);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$TransactionBudgetsTableTableManager get transactionBudgets =>
      $$TransactionBudgetsTableTableManager(_db, _db.transactionBudgets);
  $$BudgetCategoryLimitsTableTableManager get budgetCategoryLimits =>
      $$BudgetCategoryLimitsTableTableManager(_db, _db.budgetCategoryLimits);
  $$BudgetWalletsTableTableManager get budgetWallets =>
      $$BudgetWalletsTableTableManager(_db, _db.budgetWallets);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$AssociatedTitlesTableTableManager get associatedTitles =>
      $$AssociatedTitlesTableTableManager(_db, _db.associatedTitles);
  $$DeleteLogsTableTableManager get deleteLogs =>
      $$DeleteLogsTableTableManager(_db, _db.deleteLogs);
}
