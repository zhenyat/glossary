################################################################################
#   File:     app/web/app.rb
#   Purpose:  Sinatra app (CRUD + FTS search for Terms; CRUD for Commands/Examples)
#             Includes "Show deleted" toggle for Terms/Commands/Examples
#   Author:   ChatGPT (GPT-4.1)
#   Date:     2025-10-28
################################################################################
# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "active_record"
require "erb"

class GlossaryApp < Sinatra::Base
  configure do
    set :root, File.expand_path("../..", __dir__)
    set :views, File.expand_path("../views", __FILE__)
    set :public_folder, File.expand_path("../../public", __dir__)
    set :method_override, true
    enable :sessions
  end

  configure :development do
    register Sinatra::Reloader
  end

  # DB connection
  configure do
    db_path = ENV.fetch("DB_PATH", File.join(settings.root, "glossary.sqlite3"))
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: db_path, timeout: 5000)
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
  end

  # Load models lazily
  before do
    require_relative "../models/concerns/soft_deletable" unless defined?(SoftDeletable)
    require_relative "../models/application_record"       unless defined?(ApplicationRecord)
    require_relative "../models/category"                 unless defined?(Category)
    require_relative "../models/term"                     unless defined?(Term)
    require_relative "../models/command"                  unless defined?(Command)
    require_relative "../models/example"                  unless defined?(Example)
  end

  helpers do
    def h(s) = Rack::Utils.escape_html(s.to_s)

    def categories_for_select
      scope = Category.order(Arel.sql("name_en COLLATE NOCASE"))
      show_deleted? ? scope : scope.where(deleted_on: nil)
    end

    def show_deleted?
      params["show_deleted"] == "1"
    end

    def per_page
      n = (params[:per] || "").to_i
      (1..200).cover?(n) ? n : 20
    end

    def page
      n = (params[:page] || "").to_i
      n < 1 ? 1 : n
    end

    def offset
      (page - 1) * per_page
    end

    # FTS search for terms (do not alias left of MATCH)
    def fts_query(q, category_id: nil, limit: 20, offset: 0)
      conn = ActiveRecord::Base.connection
      where = []
      where << "t.category_id = #{category_id.to_i}" if category_id && !category_id.empty?
      where << (show_deleted? ? "1=1" : "t.deleted_on IS NULL")

      if q && !q.strip.empty?
        sql = <<~SQL
          SELECT t.*, c.name_en AS category_name,
                 bm25(terms_fts) AS rank,
                 highlight(terms_fts, 0, '<mark>', '</mark>') AS en_hl,
                 highlight(terms_fts, 1, '<mark>', '</mark>') AS ru_hl
          FROM terms_fts
          JOIN terms t      ON terms_fts.rowid = t.id
          JOIN categories c ON c.id = t.category_id
          WHERE #{where.join(" AND ")}
            AND terms_fts MATCH #{conn.quote(q)}
          ORDER BY rank
          LIMIT #{limit} OFFSET #{offset}
        SQL
        conn.exec_query(sql).to_a
      else
        sql = <<~SQL
          SELECT t.*, c.name_en AS category_name
          FROM terms t
          JOIN categories c ON c.id = t.category_id
          WHERE #{where.join(" AND ")}
          ORDER BY t.en COLLATE NOCASE
          LIMIT #{limit} OFFSET #{offset}
        SQL
        conn.exec_query(sql).to_a
      end      
    end

    # Commands listing query
    def commands_query(category_id: nil, limit: 20, offset: 0)
      conn = ActiveRecord::Base.connection
      where = []
      where << "cmd.category_id = #{category_id.to_i}" if category_id && !category_id.empty?
      where << (show_deleted? ? "1=1" : "cmd.deleted_on IS NULL")

      sql = <<~SQL
        SELECT cmd.*, c.name_en AS category_name
        FROM commands cmd
        JOIN categories c ON c.id = cmd.category_id
        WHERE #{where.join(" AND ")}
        ORDER BY c.name_en COLLATE NOCASE, cmd.title COLLATE NOCASE
        LIMIT #{limit} OFFSET #{offset}
      SQL
      conn.exec_query(sql).to_a
    end

    # Examples for a specific command
    def examples_query(command_id:, limit: 50, offset: 0)
      conn = ActiveRecord::Base.connection
      where = ["e.command_id = #{command_id.to_i}"]
      where << (show_deleted? ? "1=1" : "e.deleted_on IS NULL")

      sql = <<~SQL
        SELECT e.*
        FROM examples e
        WHERE #{where.join(" AND ")}
        ORDER BY e.title COLLATE NOCASE
        LIMIT #{limit} OFFSET #{offset}
      SQL
      conn.exec_query(sql).to_a
    end

    # Basic highlight for Commands (case-insensitive, HTML-safe).
    def simple_highlight(text, query)
      return h(text) if query.to_s.strip.empty? || text.to_s.empty?
      escaped = h(text.to_s)
      pattern = Regexp.new(Regexp.escape(query.to_s), Regexp::IGNORECASE)
      escaped.gsub(pattern) { |m| "<mark>#{m}</mark>" }
    end

    # Commands search (LIKE-based; matches title/descr_en/descr_ru)
    def commands_search(q, category_id: nil, limit: 20, offset: 0)
      conn = ActiveRecord::Base.connection
      query = q.to_s.strip
      where = []
      where << "cmd.deleted_on IS NULL" unless show_deleted?
      where << "cmd.category_id = #{category_id.to_i}" if category_id && !category_id.empty?

      if query.empty?
        # Browse mode (no query) — just list
        sql = <<~SQL
          SELECT cmd.*, c.name_en AS category_name
          FROM commands cmd
          JOIN categories c ON c.id = cmd.category_id
          #{where.empty? ? "" : "WHERE #{where.join(' AND ')}"}
          ORDER BY c.name_en COLLATE NOCASE, cmd.title COLLATE NOCASE
          LIMIT #{limit} OFFSET #{offset}
        SQL
        return conn.exec_query(sql).to_a
      end

      pat = conn.quote("%#{query}%")
      where << "(LOWER(cmd.title) LIKE LOWER(#{pat}) OR LOWER(IFNULL(cmd.descr_en,'')) LIKE LOWER(#{pat}) OR LOWER(IFNULL(cmd.descr_ru,'')) LIKE LOWER(#{pat}))"

      # naive relevance: title match counts more
      sql = <<~SQL
        SELECT
          cmd.*,
          c.name_en AS category_name,
          (CASE WHEN LOWER(cmd.title) LIKE LOWER(#{pat}) THEN 2 ELSE 0 END
           + CASE WHEN LOWER(IFNULL(cmd.descr_en,'')) LIKE LOWER(#{pat}) THEN 1 ELSE 0 END
           + CASE WHEN LOWER(IFNULL(cmd.descr_ru,'')) LIKE LOWER(#{pat}) THEN 1 ELSE 0 END) AS score
        FROM commands cmd
        JOIN categories c ON c.id = cmd.category_id
        WHERE #{where.join(" AND ")}
        ORDER BY score DESC, cmd.title COLLATE NOCASE
        LIMIT #{limit} OFFSET #{offset}
      SQL
      conn.exec_query(sql).to_a
    end

    # Categories listing (with Show deleted + pagination)
    def categories_query(limit: 20, offset: 0)
      conn = ActiveRecord::Base.connection
      where = []
      where << (show_deleted? ? "1=1" : "deleted_on IS NULL")

      sql = <<~SQL
        SELECT *
        FROM categories
        WHERE #{where.join(" AND ")}
        ORDER BY name_en COLLATE NOCASE
        LIMIT #{limit} OFFSET #{offset}
      SQL
      conn.exec_query(sql).to_a
    end
  end

  # Root → Terms
  get "/" do
    redirect "/terms"
  end

  # =========================
  # Terms
  # =========================

  get "/terms" do
    @q = params[:q].to_s
    @category_id = params[:category_id].to_s
    @categories = categories_for_select
    @rows = fts_query(@q, category_id: @category_id, limit: per_page, offset: offset)
    erb :"terms/index"
  end

  get "/terms/new" do
    @categories = categories_for_select
    @term = Term.new
    erb :"terms/new"
  end

  post "/terms" do
    @term = Term.new(
      category_id: params.dig("term", "category_id"),
      en:          params.dig("term", "en"),
      abbr_en:     params.dig("term", "abbr_en"),
      ru:          params.dig("term", "ru"),
      abbr_ru:     params.dig("term", "abbr_ru"),
      descr_en:    params.dig("term", "descr_en"),
      descr_ru:    params.dig("term", "descr_ru")
    )
    if @term.save
      redirect "/terms"
    else
      @categories = categories_for_select
      @error = @term.errors.full_messages.join(", ")
      erb :"terms/new"
    end
  end

  get "/terms/:id/edit" do
    @term = Term.find(params[:id])
    @categories = categories_for_select
    erb :"terms/edit"
  end

  put "/terms/:id" do
    @term = Term.find(params[:id])
    if @term.update(
      category_id: params.dig("term", "category_id"),
      en:          params.dig("term", "en"),
      abbr_en:     params.dig("term", "abbr_en"),
      ru:          params.dig("term", "ru"),
      abbr_ru:     params.dig("term", "abbr_ru"),
      descr_en:    params.dig("term", "descr_en"),
      descr_ru:    params.dig("term", "descr_ru")
    )
      redirect "/terms"
    else
      @categories = categories_for_select
      @error = @term.errors.full_messages.join(", ")
      erb :"terms/edit"
    end
  end

  post "/terms/:id/delete" do
    term = Term.find(params[:id])
    term.update!(deleted_on: Time.now)
    redirect "/terms?#{request.query_string}"
  end

  post "/terms/:id/restore" do
    term = Term.find(params[:id])
    term.update!(deleted_on: nil)
    redirect "/terms?#{request.query_string}"
  end

  get "/terms/:id" do
    @term = Term.find(params[:id])
    erb :"terms/show"
  end

  # =========================
  # Categories (Show deleted + CRUD)
  # =========================

  get "/categories" do
    @rows = categories_query(limit: per_page, offset: offset)
    erb :"categories/index"
  end

  get "/categories/new" do
    @category = Category.new
    erb :"categories/new"
  end

  post "/categories" do
    @category = Category.new(
      name_en: params.dig("category", "name_en"),
      name_ru: params.dig("category", "name_ru")
    )
    if @category.save
      redirect "/categories"
    else
      @error = @category.errors.full_messages.join(", ")
      erb :"categories/new"
    end
  end

  get "/categories/:id/edit" do
    @category = Category.find(params[:id])
    erb :"categories/edit"
  end

  put "/categories/:id" do
    @category = Category.find(params[:id])
    if @category.update(
      name_en: params.dig("category", "name_en"),
      name_ru: params.dig("category", "name_ru")
    )
      redirect "/categories"
    else
      @error = @category.errors.full_messages.join(", ")
      erb :"categories/edit"
    end
  end

  # Soft delete (mark as deleted_on)
  post "/categories/:id/delete" do
    cat = Category.find(params[:id])
    cat.update!(deleted_on: Time.now)
    redirect "/categories?#{request.query_string}"
  end

  # Restore (clear deleted_on)
  post "/categories/:id/restore" do
    cat = Category.find(params[:id])
    cat.update!(deleted_on: nil)
    redirect "/categories?#{request.query_string}"
  end

  # =========================
  # Commands
  # =========================

  get "/commands" do
    @category_id = params[:category_id].to_s
    @categories = categories_for_select
    @rows = commands_query(category_id: @category_id, limit: per_page, offset: offset)
    erb :"commands/index"
  end

  get "/commands/new" do
    @categories = categories_for_select
    @command = Command.new
    erb :"commands/new"
  end

  post "/commands" do
    @command = Command.new(
      category_id: params.dig("command", "category_id"),
      title:       params.dig("command", "title"),
      descr_en:    params.dig("command", "descr_en"),
      descr_ru:    params.dig("command", "descr_ru")
    )
    if @command.save
      redirect "/commands"
    else
      @categories = categories_for_select
      @error = @command.errors.full_messages.join(", ")
      erb :"commands/new"
    end
  end

  get "/commands/:id/edit" do
    @command = Command.find(params[:id])
    @categories = categories_for_select
    erb :"commands/edit"
  end

  put "/commands/:id" do
    @command = Command.find(params[:id])
    if @command.update(
      category_id: params.dig("command", "category_id"),
      title:       params.dig("command", "title"),
      descr_en:    params.dig("command", "descr_en"),
      descr_ru:    params.dig("command", "descr_ru")
    )
      redirect "/commands"
    else
      @categories = categories_for_select
      @error = @command.errors.full_messages.join(", ")
      erb :"commands/edit"
    end
  end

  post "/commands/:id/delete" do
    cmd = Command.find(params[:id])
    cmd.update!(deleted_on: Time.now)
    redirect "/commands?#{request.query_string}"
  end

  post "/commands/:id/restore" do
    cmd = Command.find(params[:id])
    cmd.update!(deleted_on: nil)
    redirect "/commands?#{request.query_string}"
  end

  get "/commands/:id" do
    @command = Command.find(params[:id])
    @examples = examples_query(command_id: @command.id, limit: 200, offset: 0)
    erb :"commands/show"
  end

  # =========================
  # Examples (nested under Command)
  # =========================

  get "/commands/:command_id/examples/new" do
    @command = Command.find(params[:command_id])
    @example = Example.new(command_id: @command.id)
    erb :"examples/new"
  end

  post "/commands/:command_id/examples" do
    @command = Command.find(params[:command_id])
    @example = Example.new(
      command_id: @command.id,
      title:      params.dig("example", "title"),
      descr_en:   params.dig("example", "descr_en"),
      descr_ru:   params.dig("example", "descr_ru")
    )
    if @example.save
      redirect "/commands/#{@command.id}"
    else
      @error = @example.errors.full_messages.join(", ")
      erb :"examples/new"
    end
  end

  get "/examples/:id/edit" do
    @example = Example.find(params[:id])
    @command = @example.command
    erb :"examples/edit"
  end

  put "/examples/:id" do
    @example = Example.find(params[:id])
    if @example.update(
      title:    params.dig("example", "title"),
      descr_en: params.dig("example", "descr_en"),
      descr_ru: params.dig("example", "descr_ru")
    )
      redirect "/commands/#{@example.command_id}"
    else
      @command = @example.command
      @error = @example.errors.full_messages.join(", ")
      erb :"examples/edit"
    end
  end

  post "/examples/:id/delete" do
    ex = Example.find(params[:id])
    ex.update!(deleted_on: Time.now)
    redirect "/commands/#{ex.command_id}?#{request.query_string}"
  end

  post "/examples/:id/restore" do
    ex = Example.find(params[:id])
    ex.update!(deleted_on: nil)
    redirect "/commands/#{ex.command_id}?#{request.query_string}"
  end

  # =========================
  # Combined Search (Terms + Commands)
  # =========================
  get "/search" do
    @q = params[:q].to_s
    @category_id = params[:category_id].to_s
    @categories = categories_for_select
    @active_tab = params[:tab].to_s
    @active_tab = "terms" unless %w[terms commands].include?(@active_tab)

    # shared pagination (kept simple)
    limit  = per_page
    off    = offset

    # Terms via FTS (with highlight/bm25)
    @term_rows = @q.strip.empty? ? [] : fts_query(@q, category_id: @category_id, limit: limit, offset: off)
    # Commands via LIKE (title/descr_*)
    @command_rows = @q.strip.empty? ? [] : commands_search(@q, category_id: @category_id, limit: limit, offset: off)

    erb :"search/index"
  end
end