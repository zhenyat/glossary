/***************************************************
 *  File:       db/seeds/20251024000010_terms_commands_examples.sql
 *  Purpose:    Seed terms (novice/business/data-formats/SQL), commands, examples
 *              Convention: examples.title = snippet, examples.descr_en = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-24
 ****************************************************/

PRAGMA foreign_keys = ON;

-- =========================
-- Terms: data-formats
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'JSON', 'JSON',
       'JavaScript Object Notation; lightweight text format for structured data. Objects {…}, arrays […]; strings are double-quoted; UTF-8 by default.',
       'JavaScript Object Notation; лёгкий текстовый формат структурированных данных. Объекты {…}, массивы […]; строки в двойных кавычках; по умолчанию UTF‑8.'
FROM categories c WHERE c.name_en = 'data-formats';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'YAML', 'YAML',
       'Human-friendly data serialization; indentation-based. Supports mappings, sequences, scalars. Superset of JSON.',
       'Человеко‑читаемый формат сериализации; основан на отступах. Поддерживает словари, списки и скаляры. Является надмножеством JSON.'
FROM categories c WHERE c.name_en = 'data-formats';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'XML', 'XML',
       'Extensible Markup Language; hierarchical tree of elements with tags and attributes. Common in configs and protocols.',
       'Расширяемый язык разметки; иерархия элементов с тегами и атрибутами. Часто используется в конфигурациях и протоколах.'
FROM categories c WHERE c.name_en = 'data-formats';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'CSV', 'CSV',
       'Comma-Separated Values; simple tabular text format. First line often contains headers; delimiter may vary (comma/semicolon).',
       'Comma-Separated Values; простой табличный текстовый формат. Первая строка — заголовки; разделитель может отличаться (запятая/точка с запятой).'
FROM categories c WHERE c.name_en = 'data-formats';

-- =========================
-- Terms: RDBMS
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'RDBMS', 'RDBMS', 'Реляционная СУБД', 'РСУБД',
       'Relational database management system; manages relational databases (tables, rows, columns).',
       'Реляционная система управления БД; управляет реляционными базами (таблицы, строки, столбцы).'
FROM categories c WHERE c.name_en = 'rdbms';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Database', 'База данных',
       'Organized collection of data stored and accessed electronically.',
       'Организованная коллекция данных, хранящихся и доступных электронно.'
FROM categories c WHERE c.name_en = 'rdbms';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Table', 'Таблица',
       'Structured set of rows and columns within a database.',
       'Структура из строк и столбцов внутри базы данных.'
FROM categories c WHERE c.name_en = 'rdbms';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Record', 'Запись',
       'A single row in a table representing one entity instance.',
       'Одна строка таблицы, представляющая экземпляр сущности.'
FROM categories c WHERE c.name_en = 'rdbms';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Field', 'Поле',
       'A column in a table; one attribute of a record.',
       'Столбец в таблице; один атрибут записи.'
FROM categories c WHERE c.name_en = 'rdbms';

-- =========================
-- Terms: SQL (incl. CRUD set)
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'JOIN', 'JOIN',
       'Combine rows from multiple tables based on a condition. Types: INNER, LEFT, FULL (engine-specific). Use ON or USING.',
       'Объединение строк из нескольких таблиц по условию. Типы: INNER, LEFT, FULL (зависит от СУБД). Используются ON или USING.'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'PRIMARY KEY', 'Первичный ключ',
       'Uniquely identifies a row. Often indexed; may be single or composite.',
       'Уникально идентифицирует строку. Обычно индексируется; может быть составным.'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'FOREIGN KEY', 'Внешний ключ',
       'Referential link to a parent table; enforces integrity (RESTRICT/CASCADE/SET NULL).',
       'Ссылка на родительскую таблицу; обеспечивает целостность (RESTRICT/CASCADE/SET NULL).'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'INDEX', 'Индекс',
       'Auxiliary structure to speed up lookups/sorts. Trade-off: extra space and slower writes.',
       'Вспомогательная структура для ускорения поиска/сортировки. Компромисс: место и более медленные записи.'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Create', 'Создать',
       'Define new objects in SQL (e.g., CREATE TABLE).',
       'Определение новых объектов в SQL (например, CREATE TABLE).'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Insert', 'Вставка',
       'Add new rows to a table (INSERT).',
       'Добавление новых строк в таблицу (INSERT).'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Update', 'Обновление',
       'Modify existing rows in a table (UPDATE).',
       'Изменение существующих строк в таблице (UPDATE).'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Delete', 'Удаление',
       'Remove rows from a table (DELETE).',
       'Удаление строк из таблицы (DELETE).'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Populate', 'Заполнить',
       'Fill a table with data; often initial data loading.',
       'Наполнение таблицы данными; часто первичная загрузка.'
FROM categories c WHERE c.name_en = 'sql';
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'CRUD', 'CRUD', 'CRUD', 'CRUD',
       'Create, Read, Update, Delete — basic data operations.',
       'Create, Read, Update, Delete — базовые операции с данными.'
FROM categories c WHERE c.name_en = 'sql';

-- =========================
-- Terms: Programming
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Read', 'Чтение',
       'Obtain data from a file, DB, or input stream.',
       'Получение данных из файла, БД или потока ввода.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Write', 'Запись',
       'Persist data to a file, DB, or output stream.',
       'Сохранение данных в файл, БД или поток вывода.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Execute', 'Выполнить',
       'Run a program, command, or statement.',
       'Запустить выполнение программы, команды или оператора.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Run', 'Запустить',
       'Start a program or script.',
       'Начать выполнение программы или скрипта.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Edit', 'Редактировать',
       'Modify code or text in an editor.',
       'Изменять код или текст в редакторе.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Editor', 'Редактор',
       'Tool for editing code or text (e.g., VS Code).',
       'Инструмент для редактирования кода или текста (например, VS Code).'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Code', 'Код',
       'Text written in a programming language.',
       'Текст на языке программирования.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Statement', 'Оператор',
       'Executable instruction in a programming language.',
       'Исполняемая инструкция языка программирования.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Condition', 'Условие',
       'Expression that evaluates to true/false to control flow.',
       'Выражение, дающее true/false для управления потоком.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Loop', 'Цикл',
       'Repeat a block of code while a condition holds.',
       'Повторение блока кода, пока выполняется условие.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Input', 'Ввод',
       'Data provided to a program by a user or system.',
       'Данные, поступающие программе от пользователя или системы.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Output', 'Вывод',
       'Data produced by a program to screen, file, etc.',
       'Данные, выдаваемые программой на экран, в файл и т.д.'
FROM categories c WHERE c.name_en = 'programming';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Error', 'Ошибка',
       'A problem during execution; may stop or alter flow.',
       'Проблема при выполнении; может остановить или изменить поток.'
FROM categories c WHERE c.name_en = 'programming';

-- =========================
-- Terms: IT-General
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Hardware', 'Аппаратное обеспечение',
       'Physical components of a computer system.',
       'Физические компоненты компьютерной системы.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Software', 'Программное обеспечение',
       'Programs and data that run on hardware.',
       'Программы и данные, работающие на аппаратуре.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'Operating System', 'OS', 'Операционная система', 'ОС',
       'Core software that manages hardware and apps.',
       'Базовое ПО, управляющее аппаратурой и приложениями.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Application', 'Приложение',
       'Program designed to perform user tasks.',
       'Программа, предназначенная для выполнения задач пользователя.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'Application Programming Interface', 'API', 'Программный интерфейс приложения', 'API',
       'Contract for interaction between software components.',
       'Контракт взаимодействия между программными компонентами.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'Command Line Interface', 'CLI', 'Интерфейс командной строки', 'CLI',
       'Text-based interface for entering commands.',
       'Текстовый интерфейс для ввода команд.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'Graphical User Interface', 'GUI', 'Графический интерфейс пользователя', 'GUI',
       'Visual interface with windows, icons, and controls.',
       'Визуальный интерфейс с окнами, иконками и элементами управления.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Hot Key', 'Горячая клавиша',
       'Keyboard shortcut that triggers an action.',
       'Сочетание клавиш для быстрого выполнения действия.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Command', 'Команда',
       'Instruction to a computer program or shell.',
       'Инструкция для программы или оболочки.'
FROM categories c WHERE c.name_en = 'it-general';
INSERT OR IGNORE INTO terms (category_id, en, abbr_en, ru, abbr_ru, descr_en, descr_ru)
SELECT c.id, 'Integrated Development Environment', 'IDE', 'Интегрированная среда разработки', 'IDE',
       'Suite that bundles editor, build, and debug tools.',
       'Среда, объединяющая редактор, сборку и отладку.'
FROM categories c WHERE c.name_en = 'it-general';

-- =========================
-- Terms: Unix/Linux
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Linux', 'Linux',
       'Open-source Unix-like operating system kernel and ecosystem.',
       'Открытая Unix‑подобная ОС (ядро и экосистема).'
FROM categories c WHERE c.name_en = 'unix';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Terminal', 'Терминал',
       'Program that provides a text console interface.',
       'Программа, предоставляющая текстовый консольный интерфейс.'
FROM categories c WHERE c.name_en = 'unix';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Console', 'Консоль',
       'Text interface for interacting with the OS.',
       'Текстовый интерфейс для взаимодействия с ОС.'
FROM categories c WHERE c.name_en = 'unix';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Directory', 'Каталог',
       'Folder in a file system that contains files/directories.',
       'Папка файловой системы, содержащая файлы/каталоги.'
FROM categories c WHERE c.name_en = 'unix';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'File', 'Файл',
       'Named data object stored in a file system.',
       'Именованный объект данных в файловой системе.'
FROM categories c WHERE c.name_en = 'unix';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Shell', 'Оболочка',
       'Command interpreter (e.g., bash, zsh) for the OS.',
       'Интерпретатор команд (например, bash, zsh) для ОС.'
FROM categories c WHERE c.name_en = 'unix';

-- =========================
-- Terms: Finance (incl. business-IT)
-- =========================
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Customer', 'Клиент',
       'Person or organization that receives goods or services.',
       'Человек или организация, получающие товары или услуги.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Account', 'Счёт',
       'Record that tracks financial transactions and balances.',
       'Учётная запись финансовых операций и остатков.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Transaction', 'Транзакция',
       'Atomic change to a balance or data; in DB: ACID unit of work.',
       'Атомарное изменение остатка или данных; в БД: единица работы по ACID.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Balance', 'Баланс',
       'Current amount of funds in an account.',
       'Текущая сумма средств на счёте.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Debit', 'Дебет',
       'Accounting entry that increases assets or expenses.',
       'Проводка, увеличивающая активы или расходы.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Credit', 'Кредит',
       'Accounting entry that increases income or liabilities.',
       'Проводка, увеличивающая доход или обязательства.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Invoice', 'Инвойс (счёт‑фактура)',
       'A document requesting payment for goods or services; lists items, prices, and due date.',
       'Документ с требованием оплаты за товары/услуги; содержит позиции, цены и срок оплаты.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Payment', 'Платёж',
       'Transfer of money to settle an invoice or obligation.',
       'Перевод денег для погашения инвойса или обязательства.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Vendor', 'Поставщик',
       'Company or person supplying goods or services.',
       'Компания или лицо, поставляющие товары или услуги.'
FROM categories c WHERE c.name_en = 'finance';
INSERT OR IGNORE INTO terms (category_id, en, ru, descr_en, descr_ru)
SELECT c.id, 'Ledger', 'Главная книга',
       'Accounting record summarizing transactions by account (general ledger).',
       'Бухгалтерский регистр, суммирующий операции по счетам (главная книга).'
FROM categories c WHERE c.name_en = 'finance';

-- =========================
-- Commands: shell
-- =========================
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'ls',   'List directory contents.', 'Список файлов и директорий.' FROM categories c WHERE c.name_en = 'shell';
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'grep', 'Search text using patterns.', 'Поиск текста по шаблону.' FROM categories c WHERE c.name_en = 'shell';
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'find', 'Search for files and directories.', 'Поиск файлов и директорий.' FROM categories c WHERE c.name_en = 'shell';

-- Cleanup old phrase-as-title rows, then insert swapped examples (snippet in title)
-- SHELL: ls
DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('ls'))
  AND title IN ('List all files (incl. hidden)','Human-readable sizes','Sort by size (desc)');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'ls -la', 'List all files (incl. hidden)', 'Показать все файлы (включая скрытые): ls -la'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('ls');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'ls -lh', 'Human-readable sizes', 'Читаемые размеры: ls -lh'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('ls');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'ls -lS', 'Sort by size (desc)', 'Сортировка по размеру (убывание): ls -lS'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('ls');

-- SHELL: grep
DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('grep'))
  AND title IN ('Recursive search','Match whole word','Ignore case + line num');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'grep -R "json" . -n', 'Recursive search', 'Рекурсивный поиск: grep -R "json" . -n'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('grep');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'grep -w "JOIN" file', 'Match whole word', 'Совпадение целого слова: grep -w "JOIN" file'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('grep');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'grep -in "yaml" file', 'Ignore case + line num', 'Игнор регистра + номер строки: grep -in "yaml" file'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('grep');

-- SHELL: find
DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('find'))
  AND title IN ('Find Ruby files','Files >10MB','Execute on each (ls -l)');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'find . -type f -name "*.rb"', 'Find Ruby files', 'Найти Ruby-файлы: find . -type f -name "*.rb"'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('find');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'find /var/log -type f -size +10M', 'Files >10MB', 'Файлы >10MB: find /var/log -type f -size +10M'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('find');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'find . -type f -maxdepth 1 -exec ls -l {} \;', 'Execute on each (ls -l)', 'Выполнить для каждого: find . -type f -maxdepth 1 -exec ls -l {} \;'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='shell' AND lower(cmd.title)=lower('find');

-- =========================
-- Commands: SQL
-- =========================
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'SELECT', 'Retrieve rows from one or more tables.', 'Извлечение строк из одной или нескольких таблиц.' FROM categories c WHERE c.name_en='sql';
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'INSERT', 'Add new rows to a table.', 'Добавление новых строк в таблицу.' FROM categories c WHERE c.name_en='sql';
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'UPDATE', 'Modify existing rows.', 'Изменение существующих строк.' FROM categories c WHERE c.name_en='sql';
INSERT OR IGNORE INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'DELETE', 'Remove rows (hard delete). In this app we prefer soft deletes via deleted_on.', 'Удаление строк (жёсткое). В этом приложении предпочтительны мягкие удаления через deleted_on.' FROM categories c WHERE c.name_en='sql';

-- SQL examples (snippet in title)
DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT'))
  AND title IN ('Basic select','Filter + order');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT * FROM terms LIMIT 10;', 'Basic select', 'Простой выбор: SELECT * FROM terms LIMIT 10;'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'SELECT en, ru FROM terms WHERE en LIKE ''J%'' ORDER BY en;', 'Filter + order', 'Фильтр + сортировка: SELECT en, ru FROM terms WHERE en LIKE ''J%'' ORDER BY en;'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('SELECT');

DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT'))
  AND title IN ('Insert term (pseudo)');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, ''JSON'', ''JSON'');', 'Insert term (pseudo)', 'Вставка термина (пример): INSERT INTO terms(category_id, en, ru) VALUES (/*cat_id*/, ''JSON'', ''JSON'');'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('INSERT');

DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE'))
  AND title IN ('Update RU name');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'UPDATE terms SET ru=''Джсон'' WHERE en=''JSON'';', 'Update RU name', 'Обновить русское имя: UPDATE terms SET ru=''Джсон'' WHERE en=''JSON'';'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('UPDATE');

DELETE FROM examples
WHERE command_id IN (SELECT cmd.id FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('DELETE'))
  AND title IN ('Hard delete');
INSERT OR IGNORE INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'DELETE FROM terms WHERE en=''XML'';', 'Hard delete', 'Жёсткое удаление: DELETE FROM terms WHERE en=''XML'';'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id WHERE c.name_en='sql' AND lower(cmd.title)=lower('DELETE');
