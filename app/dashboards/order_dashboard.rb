require "administrate/base_dashboard"

class OrderDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    bot: Field::BelongsTo,
    id: Field::Number,
    exchange_order_id: Field::String,
    client_order_id: Field::String,
    price: Field::String.with_options(searchable: false),
    original_quantity: Field::String.with_options(searchable: false),
    executed_quantity: Field::String.with_options(searchable: false),
    cumulative_quote_quantity: Field::String.with_options(searchable: false),
    status: Field::String,
    type: Field::String,
    side: Field::String,
    fills: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    exchange_order_id
    side
    price
    original_quantity
    status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    bot
    id
    exchange_order_id
    client_order_id
    price
    original_quantity
    executed_quantity
    cumulative_quote_quantity
    status
    type
    side
    fills
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    bot
    exchange_order_id
    client_order_id
    price
    original_quantity
    executed_quantity
    cumulative_quote_quantity
    status
    type
    side
    fills
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

  # Overwrite this method to customize how orders are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(order)
  #   "Order ##{order.id}"
  # end
end
