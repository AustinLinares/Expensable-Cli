require "json"
require "httparty"
require_relative "categories"

module CategoryHandlbegin
  def create_cat(token)
    category_data = category_form
    new_category = Services::Categories.create_category(token, category_data)
    @categories << new_category
  end

  def category_form
    print "Name: "
    name = gets.chomp
    name = name_validation(name)
    print "Transaction type: "
    transaction_type = gets.chomp
    transaction_type = tr_type_validation(transaction_type)
    { name: name, transaction_type: transaction_type, transactions: []}
  end

  def name_validation(name)
    while name.strip.empty?
      puts "Cannot be blank"
      print "Name: "
      name = gets.chomp
    end
    name
  end

  def tr_type_validation(transaction_type)
    until transaction_type == "expense" || transaction_type == "income"
      puts "Only income or expense"
      print "Transaction type: "
      transaction_type = gets.chomp
    end
    transaction_type
  end

end