require "administrate/base_dashboard"

class BotDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    pair: Field::BelongsTo.with_options(
      searchable: true,
      searchable_fields: ['symbol'],
    ),
    pair_current_price: Field::Number,
    minimum_price: Field::Number,
    maximum_price: Field::Number,
    placed_orders_count: Field::Number,
    total_investment: Field::String.with_options(searchable: false),
    entry_price: Field::String.with_options(searchable: false),
    take_profit_price: Field::String.with_options(searchable: false),
    buy_margin_percent: Field::Number,
    sell_margin_percent: Field::Number,
    use_base_asset: Field::Boolean,
    orders: Field::HasMany.with_options(limit: 500),
    is_active: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    pair
    is_active
    pair_current_price
    minimum_price
    maximum_price
    placed_orders_count
    entry_price
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    pair
    is_active
    pair_current_price
    minimum_price
    maximum_price
    placed_orders_count
    total_investment
    entry_price
    take_profit_price
    use_base_asset
    buy_margin_percent
    sell_margin_percent
    created_at
    updated_at
    orders
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    pair
    minimum_price
    maximum_price
    placed_orders_count
    total_investment
    entry_price
    take_profit_price
    buy_margin_percent
    sell_margin_percent
    use_base_asset
    is_active
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

  # Overwrite this method to customize how bots are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(bot)
  #   "Bot ##{bot.id}"
  # end
end
