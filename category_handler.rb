require "json"
require "httparty"
require_relative "categories"

module CategoryHandlbegin
  def create_cat
    category_data = category_form
    new_category = Services::Categories.create_category(@user.token, category_data)
    @categories << Services::Categories.new(new_category)
  end

  def delete_category(id)
    Services::Categories.delete_category(id, @user.token)
  end

  def update_category(id)
    cat_data = category_form(false)
    upd_cat = Services::Categories.update_category(@user.token, cat_data, id)
  end

  def category_table
    # month_cat = @categories.select { |category| category.trans_in_month?(@current_month.to_s) }
    table = Terminal::Table.new
    table.title = "#{@tr_type.capitalize}\n#{@current_month.strftime("%B %Y")}"
    table.headings = ["ID", "Category", "Total"]
    tr_selected = @categories.select { |cat| cat.transaction_type == @tr_type}
    table.rows = tr_selected.map do |cat|
      cat.month_row(@current_month.strftime("%Y-%m"))
    end
    puts table
  end



  private
  def category_form(tr = true)
    print "Name: "
    name = gets.chomp
    name = name_validation(name)
    print "Transaction type: "
    transaction_type = gets.chomp
    transaction_type = tr_type_validation(transaction_type)
    return { name: name, transaction_type: transaction_type } if tr == false
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