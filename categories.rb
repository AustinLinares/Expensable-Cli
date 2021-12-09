 require "json"
 require "httparty"
 require_relative "category_handler"

module Services
 class Categories
  include HTTParty
  attr_reader :id, :name, :transaction_type, :transactions
  base_uri("https://expensable-api.herokuapp.com/")
  def initialize(id:, name:, transaction_type:, transactions:)
    @id = id
    @name = name
    @transaction_type = transaction_type
    @transactions = transactions
  end

  def income?
    @transaction_type == "income"
  end

  def trans_in_month?(month)
    @transactions.any? { |tr| tr[:date][5, 2] == month }
  end

  # def only_month_trans(month)
  #   sel_trans = @transactions.select { |tr| tr[:date][5, 2] == month }
  #   sel_trans
  # end

  def month_row(date)
    amount = 0
    row = []
    row << @id
    row << @name
    @transactions.each do |tr|
        amount += tr[:amount] if tr[:date][5, 2] == date
    end
    row << amount
    row
  end

  def self.create_category(token, data)
    options = {
      headers: {
        "Content-Type": "application/json",
        Authorization: "Token token=#{token}"
      },
      body: data.to_json
    }

    response = post("/categories", options)
    # raise(HTTParty::ResponseError, response) unless response.success?

    JSON.parse(response.body, symbolize_names: true)
  end

  end
end