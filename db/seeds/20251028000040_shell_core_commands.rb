################################################################################
#   File:     db/seeds/20251028000040_shell_core_commands.rb
#   Purpose:  Seed core Shell commands with examples (snippet in title)
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
# frozen_string_literal: true

# Ensure category exists
def ensure_category!(en, ru)
  Category.find_or_create_by!(name_en: en) { |c| c.name_ru = ru }
end

shell = ensure_category!("shell", "Командная оболочка")

# Upsert helper for examples (title = snippet; descr_en = phrase EN; descr_ru = phrase RU)
def upsert_example!(command:, snippet:, phrase_en:, phrase_ru:)
  ex = Example.find_by(command: command, title: snippet) ||
       Example.find_by(command: command, title: phrase_en) # backwards compatibility
  if ex
    ex.update!(title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  else
    Example.create!(command: command, title: snippet, descr_en: phrase_en, descr_ru: phrase_ru)
  end
end

# Helper to upsert a command and its examples
def upsert_command!(category:, title:, descr_en:, descr_ru:, examples:)
  cmd = Command.find_or_create_by!(category: category, title: title)
  # Keep descriptions in sync if changed
  if cmd.descr_en != descr_en || cmd.descr_ru != descr_ru
    cmd.update!(descr_en: descr_en, descr_ru: descr_ru)
  end
  examples.each do |snip, phr_en, phr_ru|
    upsert_example!(command: cmd, snippet: snip, phrase_en: phr_en, phrase_ru: phr_ru)
  end
end

# Commands and examples (snippet, phrase_en, phrase_ru)
commands = [
  {
    title: "uname",
    descr_en: "Print system information.",
    descr_ru: "Показать информацию о системе.",
    examples: [
      ["uname",   "Print kernel name",             "Показать имя ядра"],
      ["uname -a","Print all system info",         "Показать всю информацию о системе"]
    ]
  },
  {
    title: "whoami",
    descr_en: "Print effective username.",
    descr_ru: "Показать имя текущего пользователя.",
    examples: [
      ["whoami", "Print effective username", "Показать имя текущего пользователя"]
    ]
  },
  {
    title: "pwd",
    descr_en: "Print working directory.",
    descr_ru: "Показать текущий каталог.",
    examples: [
      ["pwd", "Print current working directory", "Показать текущий каталог"]
    ]
  },
  {
    title: "cd",
    descr_en: "Change directory (shell builtin).",
    descr_ru: "Сменить каталог (встроенная команда).",
    examples: [
      ["cd /",  "Go to root directory",           "Перейти в корневой каталог"],
      ["cd ..", "Go up one directory",            "Перейти на уровень выше"],
      ["cd",    "Go to home directory",           "Перейти в домашний каталог"],
      ["cd -",  "Switch to previous directory",   "Перейти в предыдущий каталог"]
    ]
  },
  {
    title: "mkdir",
    descr_en: "Create directories.",
    descr_ru: "Создать каталоги.",
    examples: [
      ["mkdir project",       "Create a directory",              "Создать каталог"],
      ["mkdir -p a/b/c",      "Create directories recursively",  "Создать каталоги рекурсивно"]
    ]
  },
  {
    title: "rmdir",
    descr_en: "Remove empty directories.",
    descr_ru: "Удалить пустые каталоги.",
    examples: [
      ["rmdir empty_dir", "Remove empty directory", "Удалить пустой каталог"]
    ]
  },
  {
    title: "rm",
    descr_en: "Remove files or directories.",
    descr_ru: "Удалить файлы или каталоги.",
    examples: [
      ["rm file.txt",   "Remove a file",                                   "Удалить файл"],
      ["rm -i file.txt","Prompt before remove",                             "С запросом подтверждения"],
      ["rm -r dir",     "Remove directory recursively",                     "Удалить каталог рекурсивно"],
      ["rm -rf dir",    "Forcefully remove directory (dangerous)",          "Принудительное рекурсивное удаление (опасно)"]
    ]
  },
  {
    title: "mv",
    descr_en: "Move or rename files.",
    descr_ru: "Переместить или переименовать файлы.",
    examples: [
      ["mv source.txt dest.txt", "Rename or move a file",                   "Переименовать/переместить файл"],
      ["mv -i src dest",         "Prompt before overwrite",                 "С запросом перед перезаписью"]
    ]
  },
  {
    title: "touch",
    descr_en: "Update file timestamps or create files.",
    descr_ru: "Обновить метки времени файла или создать файл.",
    examples: [
      ["touch file.txt",                    "Create empty file or update timestamps",      "Создать пустой файл или обновить метки времени"],
      ["touch -t 202501011200 file.txt",    "Set timestamp (YYYYMMDDhhmm)",               "Установить метку времени (ГГГГММДДччмм)"],
      ["touch -a -m file.txt",              "Update access and modification time",         "Обновить время доступа и модификации"]
    ]
  },
  {
    title: "cat",
    descr_en: "Concatenate and print files.",
    descr_ru: "Объединить и вывести файлы.",
    examples: [
      ["cat file.txt",                "Print file contents",                "Вывести содержимое файла"],
      ["cat -n file.txt",             "Number lines",                       "Нумеровать строки"],
      ["cat file1 file2 > out.txt",   "Concatenate into new file",          "Объединить в новый файл"]
    ]
  },
  {
    title: "head",
    descr_en: "Output the first part of files.",
    descr_ru: "Вывести начало файла.",
    examples: [
      ["head -n 10 file.txt", "First 10 lines",  "Первые 10 строк файла"],
      ["head -c 100 file.txt","First 100 bytes", "Первые 100 байт файла"]
    ]
  },
  {
    title: "tail",
    descr_en: "Output the last part of files; follow logs.",
    descr_ru: "Вывести конец файла; следить за логами.",
    examples: [
      ["tail -n 50 file.txt", "Last 50 lines",                         "Последние 50 строк файла"],
      ["tail -f app.log",     "Follow file in real time (logs)",       "Следить за изменениями файла в реальном времени"]
    ]
  }
]

commands.each do |c|
  upsert_command!(
    category: shell,
    title: c[:title],
    descr_en: c[:descr_en],
    descr_ru: c[:descr_ru],
    examples: c[:examples]
  )
end
