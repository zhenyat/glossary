################################################################################
#   File:     db/seeds/20251028000110_git_core_commands.rb
#   Purpose:  Seed Git commands (clone/commit/push/branch/log) with examples
#             Convention: examples.title = snippet, descr_* = phrase
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
# frozen_string_literal: true

def ensure_category!(en, ru)
  Category.find_or_create_by!(name_en: en) { |c| c.name_ru = ru }
end

def upsert_example!(command:, snippet:, phrase_en:, phrase_ru:)
  ex = Example.find_by(command: command, title: snippet) ||
       Example.find_by(command: command, title: phrase_en) # backward compatibility
  if ex
    ex.update!(title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  else
    Example.create!(command: command, title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  end
end

def upsert_command!(category:, title:, descr_en:, descr_ru:, examples:)
  cmd = Command.find_or_create_by!(category: category, title: title)
  if cmd.descr_en != descr_en || cmd.descr_ru != descr_ru
    cmd.update!(descr_en: descr_en, descr_ru: descr_ru)
  end
  examples.each do |snip, phr_en, phr_ru|
    upsert_example!(command: cmd, snippet: snip, phrase_en: phr_en, phrase_ru: phr_ru)
  end
end

git = ensure_category!("git", "Git")

commands = [
  {
    title: "clone",
    descr_en: "Clone a repository.",
    descr_ru: "Клонировать репозиторий.",
    examples: [
      ["git clone https://github.com/USER/REPO.git",                         "Clone repo via HTTPS",                     "Клонировать репозиторий по HTTPS"],
      ["git clone -b main https://github.com/USER/REPO.git project",         "Clone specific branch into folder",        "Клонировать конкретную ветку в папку"],
      ["git clone --depth 1 https://github.com/USER/REPO.git",               "Shallow clone (latest history only)",      "Поверхностное клонирование (только последняя история)"]
    ]
  },
  {
    title: "commit",
    descr_en: "Record changes to the repository.",
    descr_ru: "Зафиксировать изменения в репозитории.",
    examples: [
      ["git commit -m \"Initial commit\"",    "Commit with message",                       "Фиксация с комментарием"],
      ["git commit -am \"Update\"",           "Stage modified and commit (-a)",            "Проиндексировать изменённые и зафиксировать (-a)"],
      ["git commit --amend -m \"Fix message\"","Amend last commit message",                 "Изменить сообщение последнего коммита"]
    ]
  },
  {
    title: "push",
    descr_en: "Update remote refs along with associated objects.",
    descr_ru: "Отправить коммиты на удалённый репозиторий.",
    examples: [
      ["git push",                         "Push current branch",                           "Отправить текущую ветку"],
      ["git push -u origin main",         "Push and set upstream",                         "Отправить и установить upstream"],
      ["git push --force-with-lease",     "Force push safely (with lease)",                "Форсированная отправка с защитой (with lease)"]
    ]
  },
  {
    title: "branch",
    descr_en: "List, create, or delete branches.",
    descr_ru: "Просмотр, создание и удаление веток.",
    examples: [
      ["git branch",                 "List local branches",                         "Список локальных веток"],
      ["git branch -M main",         "Rename current branch to main",               "Переименовать текущую ветку в main"],
      ["git branch -d feature/foo",  "Delete local branch (merged)",                "Удалить локальную ветку (после слияния)"]
    ]
  },
  {
    title: "log",
    descr_en: "Show commit logs.",
    descr_ru: "Показать историю коммитов.",
    examples: [
      ["git log --oneline --graph --decorate --all",    "Compact graph of all branches",             "Компактный граф всех веток"],
      ["git log -p -- path/to/file",                    "Show patch for a file history",              "Показать патчи в истории файла"],
      ["git log --since \"2 weeks ago\" --author \"Alice\"", "Filter by date and author",             "Фильтр по дате и автору"]
    ]
  }
]

commands.each do |c|
  upsert_command!(
    category: git,
    title: c[:title],
    descr_en: c[:descr_en],
    descr_ru: c[:descr_ru],
    examples: c[:examples]
  )
end
