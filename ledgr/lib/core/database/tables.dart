import 'package:drift/drift.dart';

@DataClassName('Wallet')
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get currencyCode => text()();
  IntColumn get initialBalanceMinor => integer()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get kind => text()();
  IntColumn get mainCategoryPk => integer()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get specialType => text().withDefault(const Constant('none'))();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get walletId =>
      integer().references(Wallets, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('transactionTransferWallet')
  IntColumn get transferWalletId => integer()
      .references(Wallets, #id, onDelete: KeyAction.setNull)
      .nullable()();
  IntColumn get categoryId => integer()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  IntColumn get objectiveFk => integer()
      .references(Objectives, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get attachmentPath => text().nullable()();
  TextColumn get methodAdded => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  TextColumn get currencyCode => text()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get color => integer().nullable()();
  IntColumn get plannedAmountMinor =>
      integer().withDefault(const Constant(0))();
  BoolColumn get specificMode => boolean().withDefault(const Constant(false))();
  BoolColumn get includeIncome => boolean().withDefault(const Constant(true))();
  BoolColumn get includeDebtCredit =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get includeBalanceCorrection =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get includeInOtherBudgets =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get absoluteLimit =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('TransactionBudget')
class TransactionBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get budgetId =>
      integer().references(Budgets, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {transactionId, budgetId},
  ];
}

@DataClassName('BudgetCategoryLimit')
class BudgetCategoryLimits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get budgetId =>
      integer().references(Budgets, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  IntColumn get walletId => integer()
      .references(Wallets, #id, onDelete: KeyAction.setNull)
      .nullable()();
  IntColumn get plannedAmountMinor => integer()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {budgetId, categoryId, walletId},
  ];
}

@DataClassName('BudgetWallet')
class BudgetWallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get budgetId =>
      integer().references(Budgets, #id, onDelete: KeyAction.cascade)();
  IntColumn get walletId =>
      integer().references(Wallets, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {budgetId, walletId},
  ];
}

@DataClassName('RecurringTransaction')
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionType => text()();
  TextColumn get specialType => text().withDefault(const Constant('none'))();
  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  IntColumn get walletId =>
      integer().references(Wallets, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('recurringTransferWallet')
  IntColumn get transferWalletId => integer()
      .references(Wallets, #id, onDelete: KeyAction.setNull)
      .nullable()();
  IntColumn get categoryId => integer()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get scheduleRule => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('Objective')
class Objectives extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  IntColumn get walletId => integer()
      .references(Wallets, #id, onDelete: KeyAction.setNull)
      .nullable()();
  TextColumn get currencyCode => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AssociatedTitle')
class AssociatedTitles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  BoolColumn get exactMatch => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DeleteLog')
class DeleteLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get jsonData => text()();
  DateTimeColumn get deletedAt => dateTime().withDefault(currentDateAndTime)();
}
