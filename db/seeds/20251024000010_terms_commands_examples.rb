################################################################################
#   File:     db/seeds/20251024000010_terms_commands_examples.rb
#   Purpose:  Seed terms (novice/business/data-formats/SQL), commands, examples
#             Convention: examples.title = snippet, examples.descr_en = phrase
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-24
################################################################################
# frozen_string_literal: true

# Helpers
def ensure_category!(en, ru)
  Category.find_or_create_by!(name_en: en) { |c| c.name_ru = ru }
end

def add_term!(category:, en:, ru:, abbr_en: nil, abbr_ru: nil, descr_en: nil, descr_ru: nil)
  Term.find_or_create_by!(category: category, en: en) do |t|
    t.ru       = ru
    t.abbr_en  = abbr_en
    t.abbr_ru  = abbr_ru
    t.descr_en = descr_en
    t.descr_ru = descr_ru
  end
end

# Ensure categories exist (no-op if seeded already)
data_formats = ensure_category!("data-formats", "Форматы данных")
shell        = ensure_category!("shell",        "Командная оболочка")
sql_cat      = ensure_category!("sql",          "SQL")
rdbms        = ensure_category!("rdbms",        "Реляционные СУБД")
programming  = ensure_category!("programming",  "Программирование")
it_general   = ensure_category!("it-general",   "ИТ (общее)")
unix_cat     = ensure_category!("unix",         "Unix/Linux")
finance      = ensure_category!("finance",      "Финансы")

# -----------------------------
# Terms: data-formats
# -----------------------------
[
  { en: "JSON", ru: "JSON",
    descr_en: "JavaScript Object Notation; lightweight text format for structured data. Objects {…}, arrays […]; strings are double-quoted; UTF-8 by default.",
    descr_ru: "JavaScript Object Notation; лёгкий текстовый формат структурированных данных. Объекты {…}, массивы […]; строки в двойных кавычках; по умолчанию UTF‑8." },
  { en: "YAML", ru: "YAML",
    descr_en: "Human-friendly data serialization; indentation-based. Supports mappings, sequences, scalars. Superset of JSON.",
    descr_ru: "Человеко‑читаемый формат сериализации; основан на отступах. Поддерживает словари, списки и скаляры. Является надмножеством JSON." },
  { en: "XML",  ru: "XML",
    descr_en: "Extensible Markup Language; hierarchical tree of elements with tags and attributes. Common in configs and protocols.",
    descr_ru: "Расширяемый язык разметки; иерархия элементов с тегами и атрибутами. Часто используется в конфигурациях и протоколах." },
  { en: "CSV",  ru: "CSV",
    descr_en: "Comma-Separated Values; simple tabular text format. First line often contains headers; delimiter may vary (comma/semicolon).",
    descr_ru: "Comma-Separated Values; простой табличный текстовый формат. Первая строка — заголовки; разделитель может отличаться (запятая/точка с запятой)." }
].each { |t| add_term!(category: data_formats, **t) }

# -----------------------------
# Terms: RDBMS
# -----------------------------
[
  { en: "RDBMS",   ru: "Реляционная СУБД", abbr_en: "RDBMS", abbr_ru: "РСУБД",
    descr_en: "Relational database management system; manages relational databases (tables, rows, columns).",
    descr_ru: "Реляционная система управления БД; управляет реляционными базами (таблицы, строки, столбцы)." },
  { en: "Database", ru: "База данных",
    descr_en: "Organized collection of data stored and accessed electronically.",
    descr_ru: "Организованная коллекция данных, хранящихся и доступных электронно." },
  { en: "Table",  ru: "Таблица",
    descr_en: "Structured set of rows and columns within a database.",
    descr_ru: "Структура из строк и столбцов внутри базы данных." },
  { en: "Record", ru: "Запись",
    descr_en: "A single row in a table representing one entity instance.",
    descr_ru: "Одна строка таблицы, представляющая экземпляр сущности." },
  { en: "Field",  ru: "Поле",
    descr_en: "A column in a table; one attribute of a record.",
    descr_ru: "Столбец в таблице; один атрибут записи." }
].each { |t| add_term!(category: rdbms, **t) }

# -----------------------------
# Terms: SQL
# -----------------------------
[
  { en: "JOIN",         ru: "JOIN",
    descr_en: "Combine rows from multiple tables based on a condition. Types: INNER, LEFT, FULL (engine‑specific). Use ON or USING.",
    descr_ru: "Объединение строк из нескольких таблиц по условию. Типы: INNER, LEFT, FULL (зависит от СУБД). Используются ON или USING." },
  { en: "PRIMARY KEY",  ru: "Первичный ключ",
    descr_en: "Uniquely identifies a row. Often indexed; may be single or composite.",
    descr_ru: "Уникально идентифицирует строку. Обычно индексируется; может быть составным." },
  { en: "FOREIGN KEY",  ru: "Внешний ключ",
    descr_en: "Referential link to a parent table; enforces integrity (RESTRICT/CASCADE/SET NULL).",
    descr_ru: "Ссылка на родительскую таблицу; обеспечивает целостность (RESTRICT/CASCADE/SET NULL)." },
  { en: "INDEX",        ru: "Индекс",
    descr_en: "Auxiliary structure to speed up lookups/sorts. Trade‑off: extra space and slower writes.",
    descr_ru: "Вспомогательная структура для ускорения поиска/сортировки. Компромисс: место и более медленные записи." },
  { en: "Create",   ru: "Создать",
    descr_en: "Define new objects in SQL (e.g., CREATE TABLE).",
    descr_ru: "Определение новых объектов в SQL (например, CREATE TABLE)." },
  { en: "Insert",   ru: "Вставка",
    descr_en: "Add new rows to a table (INSERT).",
    descr_ru: "Добавление новых строк в таблицу (INSERT)." },
  { en: "Update",   ru: "Обновление",
    descr_en: "Modify existing rows in a table (UPDATE).",
    descr_ru: "Изменение существующих строк в таблице (UPDATE)." },
  { en: "Delete",   ru: "Удаление",
    descr_en: "Remove rows from a table (DELETE).",
    descr_ru: "Удаление строк из таблицы (DELETE)." },
  { en: "Populate", ru: "Заполнить",
    descr_en: "Fill a table with data; often initial data loading.",
    descr_ru: "Наполнение таблицы данными; часто первичная загрузка." },
  { en: "CRUD",     ru: "CRUD", abbr_en: "CRUD", abbr_ru: "CRUD",
    descr_en: "Create, Read, Update, Delete — basic data operations.",
    descr_ru: "Create, Read, Update, Delete — базовые операции с данными." }
].each { |t| add_term!(category: sql_cat, **t) }

# -----------------------------
# Terms: Programming
# -----------------------------
[
  { en: "Read",      ru: "Чтение",
    descr_en: "Obtain data from a file, DB, or input stream.",
    descr_ru: "Получение данных из файла, БД или потока ввода." },
  { en: "Write",     ru: "Запись",
    descr_en: "Persist data to a file, DB, or output stream.",
    descr_ru: "Сохранение данных в файл, БД или поток вывода." },
  { en: "Execute",   ru: "Выполнить",
    descr_en: "Run a program, command, or statement.",
    descr_ru: "Запустить выполнение программы, команды или оператора." },
  { en: "Run",       ru: "Запустить",
    descr_en: "Start a program or script.",
    descr_ru: "Начать выполнение программы или скрипта." },
  { en: "Edit",      ru: "Редактировать",
    descr_en: "Modify code or text in an editor.",
    descr_ru: "Изменять код или текст в редакторе." },
  { en: "Editor",    ru: "Редактор",
    descr_en: "Tool for editing code or text (e.g., VS Code).",
    descr_ru: "Инструмент для редактирования кода или текста (например, VS Code)." },
  { en: "Code",      ru: "Код",
    descr_en: "Text written in a programming language.",
    descr_ru: "Текст на языке программирования." },
  { en: "Statement", ru: "Оператор",
    descr_en: "Executable instruction in a programming language.",
    descr_ru: "Исполняемая инструкция языка программирования." },
  { en: "Condition", ru: "Условие",
    descr_en: "Expression that evaluates to true/false to control flow.",
    descr_ru: "Выражение, дающее true/false для управления потоком." },
  { en: "Loop",      ru: "Цикл",
    descr_en: "Repeat a block of code while a condition holds.",
    descr_ru: "Повторение блока кода, пока выполняется условие." },
  { en: "Input",     ru: "Ввод",
    descr_en: "Data provided to a program by a user or system.",
    descr_ru: "Данные, поступающие программе от пользователя или системы." },
  { en: "Output",    ru: "Вывод",
    descr_en: "Data produced by a program to screen, file, etc.",
    descr_ru: "Данные, выдаваемые программой на экран, в файл и т.д." },
  { en: "Error",     ru: "Ошибка",
    descr_en: "A problem during execution; may stop or alter flow.",
    descr_ru: "Проблема при выполнении; может остановить или изменить поток." }
].each { |t| add_term!(category: programming, **t) }

# -----------------------------
# Terms: IT-General
# -----------------------------
[
  { en: "Hardware", ru: "Аппаратное обеспечение",
    descr_en: "Physical components of a computer system.",
    descr_ru: "Физические компоненты компьютерной системы." },
  { en: "Software", ru: "Программное обеспечение",
    descr_en: "Programs and data that run on hardware.",
    descr_ru: "Программы и данные, работающие на аппаратуре." },
  { en: "Operating System", ru: "Операционная система", abbr_en: "OS", abbr_ru: "ОС",
    descr_en: "Core software that manages hardware and apps.",
    descr_ru: "Базовое ПО, управляющее аппаратурой и приложениями." },
  { en: "Application", ru: "Приложение",
    descr_en: "Program designed to perform user tasks.",
    descr_ru: "Программа, предназначенная для выполнения задач пользователя." },
  { en: "Application Programming Interface", ru: "Программный интерфейс приложения", abbr_en: "API", abbr_ru: "API",
    descr_en: "Contract for interaction between software components.",
    descr_ru: "Контракт взаимодействия между программными компонентами." },
  { en: "Command Line Interface", ru: "Интерфейс командной строки", abbr_en: "CLI", abbr_ru: "CLI",
    descr_en: "Text-based interface for entering commands.",
    descr_ru: "Текстовый интерфейс для ввода команд." },
  { en: "Graphical User Interface", ru: "Графический интерфейс пользователя", abbr_en: "GUI", abbr_ru: "GUI",
    descr_en: "Visual interface with windows, icons, and controls.",
    descr_ru: "Визуальный интерфейс с окнами, иконками и элементами управления." },
  { en: "Hot Key", ru: "Горячая клавиша",
    descr_en: "Keyboard shortcut that triggers an action.",
    descr_ru: "Сочетание клавиш для быстрого выполнения действия." },
  { en: "Command", ru: "Команда",
    descr_en: "Instruction to a computer program or shell.",
    descr_ru: "Инструкция для программы или оболочки." },
  { en: "Integrated Development Environment", ru: "Интегрированная среда разработки", abbr_en: "IDE", abbr_ru: "IDE",
    descr_en: "Suite that bundles editor, build, and debug tools.",
    descr_ru: "Среда, объединяющая редактор, сборку и отладку." }
].each { |t| add_term!(category: it_general, **t) }

# -----------------------------
# Terms: Unix/Linux
# -----------------------------
[
  { en: "Linux",    ru: "Linux",
    descr_en: "Open-source Unix-like operating system kernel and ecosystem.",
    descr_ru: "Открытая Unix‑подобная ОС (ядро и экосистема)." },
  { en: "Terminal", ru: "Терминал",
    descr_en: "Program that provides a text console interface.",
    descr_ru: "Программа, предоставляющая текстовый консольный интерфейс." },
  { en: "Console",  ru: "Консоль",
    descr_en: "Text interface for interacting with the OS.",
    descr_ru: "Текстовый интерфейс для взаимодействия с ОС." },
  { en: "Directory", ru: "Каталог",
    descr_en: "Folder in a file system that contains files/directories.",
    descr_ru: "Папка файловой системы, содержащая файлы/каталоги." },
  { en: "File",      ru: "Файл",
    descr_en: "Named data object stored in a file system.",
    descr_ru: "Именованный объект данных в файловой системе." },
  { en: "Shell",     ru: "Оболочка",
    descr_en: "Command interpreter (e.g., bash, zsh) for the OS.",
    descr_ru: "Интерпретатор команд (например, bash, zsh) для ОС." }
].each { |t| add_term!(category: unix_cat, **t) }

# -----------------------------
# Terms: Finance (incl. business-IT)
# -----------------------------
[
  { en: "Customer",    ru: "Клиент",
    descr_en: "Person or organization that receives goods or services.",
    descr_ru: "Человек или организация, получающие товары или услуги." },
  { en: "Account",     ru: "Счёт",
    descr_en: "Record that tracks financial transactions and balances.",
    descr_ru: "Учётная запись финансовых операций и остатков." },
  { en: "Transaction", ru: "Транзакция",
    descr_en: "Atomic change to a balance or data; in DB: ACID unit of work.",
    descr_ru: "Атомарное изменение остатка или данных; в БД: единица работы по ACID." },
  { en: "Balance",     ru: "Баланс",
    descr_en: "Current amount of funds in an account.",
    descr_ru: "Текущая сумма средств на счёте." },
  { en: "Debit",       ru: "Дебет",
    descr_en: "Accounting entry that increases assets or expenses.",
    descr_ru: "Проводка, увеличивающая активы или расходы." },
  { en: "Credit",      ru: "Кредит",
    descr_en: "Accounting entry that increases income or liabilities.",
    descr_ru: "Проводка, увеличивающая доход или обязательства." },
  { en: "Invoice",     ru: "Инвойс (счёт‑фактура)",
    descr_en: "A document requesting payment for goods or services; lists items, prices, and due date.",
    descr_ru: "Документ с требованием оплаты за товары/услуги; содержит позиции, цены и срок оплаты." },
  { en: "Payment",     ru: "Платёж",
    descr_en: "Transfer of money to settle an invoice or obligation.",
    descr_ru: "Перевод денег для погашения инвойса или обязательства." },
  { en: "Vendor",      ru: "Поставщик",
    descr_en: "Company or person supplying goods or services.",
    descr_ru: "Компания или лицо, поставляющие товары или услуги." },
  { en: "Ledger",      ru: "Главная книга",
    descr_en: "Accounting record summarizing transactions by account (general ledger).",
    descr_ru: "Бухгалтерский регистр, суммирующий операции по счетам (главная книга)." }
].each { |t| add_term!(category: finance, **t) }

# -----------------------------
# Commands + Examples (snippet in title, phrase in descr_en)
# -----------------------------
def upsert_example!(command:, snippet:, phrase_en:, phrase_ru:)
  ex = Example.find_by(command: command, title: snippet) ||
       Example.find_by(command: command, title: phrase_en)
  if ex
    ex.update!(title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  else
    Example.create!(command: command, title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  end
end

# Shell commands
[
  {
    title: "ls",
    descr_en: "List directory contents.", descr_ru: "Список файлов и директорий.",
    examples: [
      ['ls -la', 'List all files (incl. hidden)', 'Показать все файлы (включая скрытые): ls -la'],
      ['ls -lh', 'Human-readable sizes',          'Читаемые размеры: ls -lh'],
      ['ls -lS', 'Sort by size (desc)',           'Сортировка по размеру (убывание): ls -lS']
    ]
  },
  {
    title: "grep",
    descr_en: "Search text using patterns.", descr_ru: "Поиск текста по шаблону.",
    examples: [
      ['grep -R "json" . -n', 'Recursive search',       'Рекурсивный поиск: grep -R "json" . -n'],
      ['grep -w "JOIN" file', 'Match whole word',       'Совпадение целого слова: grep -w "JOIN" file'],
      ['grep -in "yaml" file','Ignore case + line num', 'Игнор регистра + номер строки: grep -in "yaml" file']
    ]
  },
  {
    title: "find",
    descr_en: "Search for files and directories.", descr_ru: "Поиск файлов и директорий.",
    examples: [
      ['find . -type f -name "*.rb"',                   'Find Ruby files',         'Найти Ruby-файлы: find . -type f -name "*.rb"'],
      ['find /var/log -type f -size +10M',              'Files >10MB',             'Файлы >10MB: find /var/log -type f -size +10M'],
      ['find . -type f -maxdepth 1 -exec ls -l {} \\;', 'Execute on each (ls -l)', 'Выполнить для каждого: find . -type f -maxdepth 1 -exec ls -l {} \\;']
    ]
  }
].each do |c|
  cmd = Command.find_or_create_by!(category: shell, title: c[:title]) do |m|
    m.descr_en = c[:descr_en]; m.descr_ru = c[:descr_ru]
  end
  c[:examples].each do |snip, phr_en, phr_ru|
    upsert_example!(command: cmd, snippet: snip, phrase_en: phr_en, phrase_ru: phr_ru)
  end
end

# SQL commands
[
  {
    title: "SELECT",
    descr_en: "Retrieve rows from one or more tables.", descr_ru: "Извлечение строк из одной или нескольких таблиц.",
    examples: [
      ["SELECT * FROM terms LIMIT 10;",                           "Basic select",   "Простой выбор: SELECT * FROM terms LIMIT 10;"],
      ["SELECT en, ru FROM terms WHERE en LIKE 'J%' ORDER BY en;","Filter + order", "Фильтр + сортировка: SELECT en, ru FROM terms WHERE en LIKE 'J%' ORDER BY en;"]
    ]
  },
  {
    title: "INSERT",
    descr_en: "Add new rows to a table.", descr_ru: "Добавление новых строк в таблицу.",
    examples: [
      ["INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, 'JSON', 'JSON');",
       "Insert term (pseudo)", "Вставка термина (пример): INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, 'JSON', 'JSON');"]
    ]
  },
  {
    title: "UPDATE",
    descr_en: "Modify existing rows.", descr_ru: "Изменение существующих строк.",
    examples: [
      ["UPDATE terms SET ru='Джсон' WHERE en='JSON';",
       "Update RU name", "Обновить русское имя: UPDATE terms SET ru='Джсон' WHERE en='JSON';"]
    ]
  },
  {
    title: "DELETE",
    descr_en: "Remove rows (hard delete). In this app we prefer soft deletes via deleted_on.",
    descr_ru: "Удаление строк (жёсткое). В этом приложении предпочтительны мягкие удаления через deleted_on.",
    examples: [
      ["DELETE FROM terms WHERE en='XML';",
       "Hard delete", "Жёсткое удаление: DELETE FROM terms WHERE en='XML';"]
    ]
  }
].each do |c|
  cmd = Command.find_or_create_by!(category: sql_cat, title: c[:title]) do |m|
    m.descr_en = c[:descr_en]; m.descr_ru = c[:descr_ru]
  end
  c[:examples].each do |snip, phr_en, phr_ru|
    upsert_example!(command: cmd, snippet: snip, phrase_en: phr_en, phrase_ru: phr_ru)
  end
end
