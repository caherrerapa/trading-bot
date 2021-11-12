require "administrate/base_dashboard"

class PairDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    bots: Field::HasMany,
    symbol: Field::String.with_options(searchable: true),
    quote_asset: Field::String,
    base_asset: Field::String,
    current_price: Field::Number,
    tick_size: Field::Number,
    minimum_price: Field::Number,
    maximum_price: Field::Number,
    lot_size: Field::Number,
    minimum_size: Field::Number,
    maximum_size: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    symbol
    quote_asset
    base_asset
    current_price
    bots
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    symbol
    current_price
    quote_asset
    base_asset
    tick_size
    minimum_price
    maximum_price
    lot_size
    minimum_size
    maximum_size
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    symbol
    quote_asset
    base_asset
    current_price
    tick_size
    minimum_price
    maximum_price
    lot_size
    minimum_size
    maximum_size
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how pairs are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(pair)
    pair.symbol
  end
end
