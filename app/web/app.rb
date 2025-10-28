################################################################################
#   File:     app/web/app.rb
#   Purpose:  Sinatra app (CRUD + FTS search for Terms)
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

  # DB connection (reuse your ENV DB_PATH)
  configure do
    db_path = ENV.fetch("DB_PATH", File.join(settings.root, "glossary.sqlite3"))
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: db_path, timeout: 5000)
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
  end

  # Load models
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
      Category.where(deleted_on: nil).order(Arel.sql("name_en COLLATE NOCASE"))
    end

    def per_page
      n = (params[:per] || "").to_i   # nil-safe
      (1..200).cover?(n) ? n : 20     # clamp to sane bounds; default 20
    end

    def page
      n = (params[:page] || "").to_i  # nil-safe
      n < 1 ? 1 : n                    # minimum 1
    end

    def offset
      (page - 1) * per_page
    end


    # FTS search using terms_fts (do not alias left of MATCH)
    def fts_query(q, category_id: nil, limit: 20, offset: 0)
      conn = ActiveRecord::Base.connection
      where = ["t.deleted_on IS NULL"]
      where << "t.category_id = #{category_id.to_i}" if category_id && !category_id.empty?

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
        # Browse mode (no FTS), order by English term
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
  end

  get "/" do
    redirect "/terms"
  end

  # Terms index + search
  get "/terms" do
    @q = params[:q].to_s
    @category_id = params[:category_id].to_s
    @categories = categories_for_select
    @rows = fts_query(@q, category_id: @category_id, limit: per_page, offset: offset)
    erb :"terms/index"
  end

  # New
  get "/terms/new" do
    @categories = categories_for_select
    @term = Term.new
    erb :"terms/new"
  end

  # Create
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

  # Edit
  get "/terms/:id/edit" do
    @term = Term.find(params[:id])
    @categories = categories_for_select
    erb :"terms/edit"
  end

  # Update
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

  # Soft-delete
  post "/terms/:id/delete" do
    term = Term.find(params[:id])
    term.update!(deleted_on: Time.now)
    redirect "/terms"
  end

  # Restore
  post "/terms/:id/restore" do
    term = Term.find(params[:id])
    term.update!(deleted_on: nil)
    redirect "/terms"
  end

  # Show (optional)
  get "/terms/:id" do
    @term = Term.find(params[:id])
    erb :"terms/show"
  end
end
