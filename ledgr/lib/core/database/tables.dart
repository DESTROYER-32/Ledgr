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
  IntColumn get decimals => integer().withDefault(const Constant(2))();
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
  IntColumn get mainCategoryPk => integer().references(Categories, #id).nullable()();
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
  IntColumn get walletId => integer().references(Wallets, #id)();
  @ReferenceName('transactionTransferWallet')
  IntColumn get transferWalletId =>
      integer().references(Wallets, #id).nullable()();
  IntColumn get categoryId =>
      integer().references(Categories, #id).nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get budgetFksExclude => text().nullable()();
  TextColumn get budgetFks => text().nullable()();
  IntColumn get objectiveFk => integer().references(Objectives, #id).nullable()();
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
  IntColumn get plannedAmountMinor => integer().withDefault(const Constant(0))();
  BoolColumn get specificMode => boolean().withDefault(const Constant(false))();
  BoolColumn get includeIncome => boolean().withDefault(const Constant(true))();
  BoolColumn get includeDebtCredit => boolean().withDefault(const Constant(true))();
  BoolColumn get includeBalanceCorrection => boolean().withDefault(const Constant(true))();
  BoolColumn get includeInOtherBudgets => boolean().withDefault(const Constant(true))();
  BoolColumn get absoluteLimit => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BudgetCategoryLimit')
class BudgetCategoryLimits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get budgetId => integer().references(Budgets, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get walletId => integer().references(Wallets, #id).nullable()();
  IntColumn get plannedAmountMinor => integer()();
}

@DataClassName('BudgetWallet')
class BudgetWallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get budgetId => integer().references(Budgets, #id)();
  IntColumn get walletId => integer().references(Wallets, #id)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{budgetId, walletId}];
}

@DataClassName('RecurringTransaction')
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionType => text()();
  TextColumn get specialType => text().withDefault(const Constant('none'))();
  IntColumn get amountMinor => integer()();
  IntColumn get walletId => integer().references(Wallets, #id)();
  @ReferenceName('recurringTransferWallet')
  IntColumn get transferWalletId =>
      integer().references(Wallets, #id).nullable()();
  IntColumn get categoryId =>
      integer().references(Categories, #id).nullable()();
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
  IntColumn get walletId => integer().references(Wallets, #id).nullable()();
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
  IntColumn get categoryId => integer().references(Categories, #id)();
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

@DataClassName('ExchangeRate')
class ExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fromCurrency => text()();
  TextColumn get toCurrency => text()();
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [{fromCurrency, toCurrency}];
}
