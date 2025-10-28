/***************************************************
 *  File:       db/seeds/20251028000040_shell_core_commands.sql
 *  Purpose:    Seed core Shell commands with examples (snippet in title)
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Helper note:
-- We use UPSERT so re-running updates descriptions without duplicating rows.

-- Commands (UPSERT per command)
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'uname', 'Print system information.', 'Показать информацию о системе.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'whoami', 'Print effective username.', 'Показать имя текущего пользователя.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'pwd', 'Print working directory.', 'Показать текущий каталог.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'cd', 'Change directory (shell builtin).', 'Сменить каталог (встроенная команда).'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'mkdir', 'Create directories.', 'Создать каталоги.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'rmdir', 'Remove empty directories.', 'Удалить пустые каталоги.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'rm', 'Remove files or directories.', 'Удалить файлы или каталоги.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'mv', 'Move or rename files.', 'Переместить или переименовать файлы.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'touch', 'Update file timestamps or create files.', 'Обновить метки времени файла или создать файл.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'cat', 'Concatenate and print files.', 'Объединить и вывести файлы.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'head', 'Output the first part of files.', 'Вывести начало файла.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'tail', 'Output the last part of files; follow logs.', 'Вывести конец файла; следить за логами.'
FROM categories c WHERE c.name_en='shell'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Examples (UPSERT per (command_id, title))
-- uname
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'uname', 'Print kernel name', 'Показать имя ядра'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('uname')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'uname -a', 'Print all system info', 'Показать всю информацию о системе'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('uname')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- whoami
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'whoami', 'Print effective username', 'Показать имя текущего пользователя'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('whoami')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- pwd
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'pwd', 'Print current working directory', 'Показать текущий каталог'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('pwd')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- cd
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cd /', 'Go to root directory', 'Перейти в корневой каталог'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cd')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cd ..', 'Go up one directory', 'Перейти на уровень выше'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cd')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cd', 'Go to home directory', 'Перейти в домашний каталог'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cd')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cd -', 'Switch to previous directory', 'Перейти в предыдущий каталог'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cd')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- mkdir
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'mkdir project', 'Create a directory', 'Создать каталог'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('mkdir')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'mkdir -p a/b/c', 'Create directories recursively', 'Создать каталоги рекурсивно'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('mkdir')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- rmdir
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'rmdir empty_dir', 'Remove empty directory', 'Удалить пустой каталог'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('rmdir')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- rm
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'rm file.txt', 'Remove a file', 'Удалить файл'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('rm')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'rm -i file.txt', 'Prompt before remove', 'С запросом подтверждения'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('rm')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'rm -r dir', 'Remove directory recursively', 'Удалить каталог рекурсивно'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('rm')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'rm -rf dir', 'Forcefully remove directory (dangerous)', 'Принудительное рекурсивное удаление (опасно)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('rm')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- mv
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'mv source.txt dest.txt', 'Rename or move a file', 'Переименовать/переместить файл'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('mv')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'mv -i src dest', 'Prompt before overwrite', 'С запросом перед перезаписью'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('mv')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- touch
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'touch file.txt', 'Create empty file or update timestamps', 'Создать пустой файл или обновить метки времени'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('touch')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'touch -t 202501011200 file.txt', 'Set timestamp (YYYYMMDDhhmm)', 'Установить метку времени (ГГГГММДДччмм)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('touch')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'touch -a -m file.txt', 'Update access and modification time', 'Обновить время доступа и модификации'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('touch')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- cat
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cat file.txt', 'Print file contents', 'Вывести содержимое файла'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cat')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cat -n file.txt', 'Number lines', 'Нумеровать строки'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cat')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'cat file1 file2 > out.txt', 'Concatenate into new file', 'Объединить в новый файл'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('cat')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- head
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'head -n 10 file.txt', 'First 10 lines', 'Первые 10 строк файла'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('head')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'head -c 100 file.txt', 'First 100 bytes', 'Первые 100 байт файла'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('head')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- tail
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'tail -n 50 file.txt', 'Last 50 lines', 'Последние 50 строк файла'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('tail')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'tail -f app.log', 'Follow file in real time (logs)', 'Следить за изменениями файла в реальном времени'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='shell' AND lower(cmd.title)=lower('tail')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;
