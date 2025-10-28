/***************************************************
 *  File:       db/seeds/20251028000110_git_core_commands.sql
 *  Purpose:    Seed Git commands (clone/commit/push/branch/log) with examples
 *              Convention: examples.title = snippet, descr_* = phrase
 *  Author:     ChatGPT (GPT-4.1)
 *  Date:       2025-10-28
 ****************************************************/

PRAGMA foreign_keys = ON;

-- Commands (UPSERT on (category_id, title))
INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'clone', 'Clone a repository.', 'Клонировать репозиторий.'
FROM categories c WHERE c.name_en='git'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'commit', 'Record changes to the repository.', 'Зафиксировать изменения в репозитории.'
FROM categories c WHERE c.name_en='git'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'push', 'Update remote refs along with associated objects.', 'Отправить коммиты на удалённый репозиторий.'
FROM categories c WHERE c.name_en='git'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'branch', 'List, create, or delete branches.', 'Просмотр, создание и удаление веток.'
FROM categories c WHERE c.name_en='git'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO commands (category_id, title, descr_en, descr_ru)
SELECT c.id, 'log', 'Show commit logs.', 'Показать историю коммитов.'
FROM categories c WHERE c.name_en='git'
ON CONFLICT(category_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- Examples (UPSERT on (command_id, title))

-- clone
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git clone https://github.com/USER/REPO.git', 'Clone repo via HTTPS', 'Клонировать репозиторий по HTTPS'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('clone')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git clone -b main https://github.com/USER/REPO.git project', 'Clone specific branch into folder', 'Клонировать конкретную ветку в папку'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('clone')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git clone --depth 1 https://github.com/USER/REPO.git', 'Shallow clone (latest history only)', 'Поверхностное клонирование (только последняя история)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('clone')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- commit
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git commit -m "Initial commit"', 'Commit with message', 'Фиксация с комментарием'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('commit')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git commit -am "Update"', 'Stage modified and commit (-a)', 'Проиндексировать изменённые и зафиксировать (-a)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('commit')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git commit --amend -m "Fix message"', 'Amend last commit message', 'Изменить сообщение последнего коммита'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('commit')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- push
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git push', 'Push current branch', 'Отправить текущую ветку'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('push')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git push -u origin main', 'Push and set upstream', 'Отправить и установить upstream'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('push')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git push --force-with-lease', 'Force push safely (with lease)', 'Форсированная отправка с защитой (with lease)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('push')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- branch
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git branch', 'List local branches', 'Список локальных веток'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('branch')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git branch -M main', 'Rename current branch to main', 'Переименовать текущую ветку в main'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('branch')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git branch -d feature/foo', 'Delete local branch (merged)', 'Удалить локальную ветку (после слияния)'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('branch')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

-- log
INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git log --oneline --graph --decorate --all', 'Compact graph of all branches', 'Компактный граф всех веток'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('log')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git log -p -- path/to/file', 'Show patch for a file history', 'Показать патчи в истории файла'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('log')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;

INSERT INTO examples (command_id, title, descr_en, descr_ru)
SELECT cmd.id, 'git log --since ''2 weeks ago'' --author "Alice"', 'Filter by date and author', 'Фильтр по дате и автору'
FROM commands cmd JOIN categories c ON c.id=cmd.category_id
WHERE c.name_en='git' AND lower(cmd.title)=lower('log')
ON CONFLICT(command_id, title) DO UPDATE SET descr_en=excluded.descr_en, descr_ru=excluded.descr_ru;
