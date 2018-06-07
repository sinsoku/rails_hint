# frozen_string_literal: true

RSpec.describe RailsHint::Schema do
  let(:content) do
    <<~SCHEMA
      ActiveRecord::Schema.define(version: 2018_06_01_024632) do

        # These are extensions that must be enabled in order to support this database
        enable_extension "plpgsql"

        create_table "posts", force: :cascade do |t|
          t.bigint "user_id", null: false
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.index ["user_id"], name: "index_posts_on_user_id"
        end

        create_table "users", force: :cascade do |t|
          t.string "email"
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
        end

        add_foreign_key "posts", "users"
      end
    SCHEMA
  end
  before { allow(File).to receive(:read) { content } }
  let(:schema) { described_class.parse("db/schema.rb") }

  describe "#version" do
    it { expect(schema.version).to eq 2018_06_01_024632 }
  end

  describe "#tables" do
    it { expect(schema.tables.size).to eq 2 }

    it "includes posts" do
      table = schema.tables.find { |t| t.name == "posts" }
      expect(table.options).to eq(force: :cascade)
      expect(table.columns).to eq([
        RailsHint::Column.new(:bigint, "user_id", null: false),
        RailsHint::Column.new(:datetime, "created_at", null: false),
        RailsHint::Column.new(:datetime, "updated_at", null: false)
      ])
      expect(table.indexes).to eq([
        RailsHint::Index.new(["user_id"], name: "index_posts_on_user_id")
      ])
      expect(table.foreign_keys).to eq([
        RailsHint::ForeignKey.new("users")
      ])
    end

    it "includes users" do
      table = schema.tables.find { |t| t.name == "users" }
      expect(table.options).to eq(force: :cascade)
      expect(table.columns).to eq([
        RailsHint::Column.new(:string, "email"),
        RailsHint::Column.new(:datetime, "created_at", null: false),
        RailsHint::Column.new(:datetime, "updated_at", null: false)
      ])
      expect(table.indexes).to be_empty
      expect(table.foreign_keys).to be_empty
    end
  end
end
