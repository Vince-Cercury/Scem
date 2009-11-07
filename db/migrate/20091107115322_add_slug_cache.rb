class AddSlugCache < ActiveRecord::Migration
  def self.up
    add_column :activities, :cached_slug, :string
    add_column :categories, :cached_slug, :string
    add_column :events, :cached_slug, :string
    add_column :organisms, :cached_slug, :string
    add_column :galleries, :cached_slug, :string
    add_column :terms, :cached_slug, :string
  end

  def self.down
    remove_column :activities, :cached_slug
    remove_column :categories, :cached_slug
    remove_column :events, :cached_slug
    remove_column :organisms, :cached_slug
    remove_column :galleries, :cached_slug
    remove_column :terms, :cached_slug
  end
end
