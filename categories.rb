 require "json"
 require "httparty"
 require_relative "category_handler"
 require "date"

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
          amount += tr[:amount] if tr[:date][5, 2] == date.to_s
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

    def self.delete_category(id, token)
      options = {
        headers: {
          Authorization: "Token token=#{token}"
        }
      }

      response = delete("/categories/#{id}", options)
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

  def add_transaction(token, data)
    options = {
      headers: {
        "Content-Type": "application/json",
        Authorization: "Token token=#{token}"
      },
      body: data.to_json
    }

    response = self.class.post("/categories/#{@id}/transactions", options)

    fin_data = JSON.parse(response.body, symbolize_names: true)
    @transactions << fin_data
  end

  def show_cat(date)
    rows = []
    trans = only_month_trans(date)
    table = Terminal::Table.new
    table.title = "#{@name}\n#{date}"
    table.headings = %w[ID Date Amount Notes]
    trans.each do |tr|
    rows << [tr[:id], (Date.parse tr[:date]).strftime('%a, %b %e'), tr[:amount], tr[:notes]]      
    end
    table.rows = rows
    puts table
  end

  def only_month_trans(month)
    @transactions.select { |tr| tr[:date][5, 2] == month.to_s }
  end
end
end