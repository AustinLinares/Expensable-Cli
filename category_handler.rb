require "json"
require "httparty"
require_relative "categories"

module CategoryHandlbegin
  def create_cat
    category_data = category_form
    new_category = Services::Categories.create_category(@user.token, category_data)
    @categories << new_category
  end

  def delete_category(id)
    deleted_note = Services::Categories.delete_category(id, @user.token)
  end

  def category_table
    month_cat = @categories.select { |category| category.trans_in_month?(@current_month.to_s) }
    table = Terminal::Table.new
    table.title = "#{@tr_type.capitalize}\n#{@current_month}"
    table.headings = ["ID", "Category", "Total"]
    table.rows = month_cat.map do |trans|
      trans.month_row(@current_month)
    end
    puts table
  end



  private
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