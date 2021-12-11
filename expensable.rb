# Start here. Happy coding!
require "json"
require "httparty"
require "terminal-table"
require "date"
require_relative "users"
require_relative "categories"
require_relative "category_handler"

class Expensable
  include CategoryHandlbegin
  include HTTParty

  attr_reader :tr_type
  def intialize
    @date = DateTime.now
    @user = nil
    @categories = []
    @current_month = nil
    @tr_type = "expenses"
  end

  def start
    welcome
    action = ""
    until action == "exit"
    action = validate_options(["login", "create_user", "exit"])
      case action
      when "login" 
        user_data = login_form
        data_login = Services::Users.login(user_data)
        @user = Services::Users.new(data_login)
        @categories = Services::Users.categories(@user.token).map { |cat| Services::Categories.new(cat)}
        @current_month = DateTime.now.month
        # table_categories_amount(@current_month)
        @tr_type = "expense"
        category_table
        second_display
      when "create_user" 
        user_data = user_form
        data_new_user = Services::Users.create_user(user_data)
        pp @user = Services::Users.new(data_new_user)
        @categories = Services::Users.categories(@user.token)
        @tr_type = "expense"
        category_table
        second_display
      else
        puts "Invalid option"
      end
    end
  end

  def second_display
    action = ""
    until action == "logout"
    action, id = get_with_options(["create", "show ID", "update ID", "delete ID", "add-to ID", "toggle", "next", "prev", "logout"])
      case action
      when "create"
        create_cat
        category_table
      when "show" then
        cat = find_category(id.to_i)
        cat.show_cat(@current_month)
        category_table
      when "update" then puts "hey"
      when "delete"
        cat = find_category(id.to_i)
        @categories.delete(cat)
        delete_category(id)
        category_table
      when "add-to"
        cat = find_category(id.to_i)
        trans_data = trans_form
        cat.add_transaction(token, trans_data)
        category_table
      when "toggle" then puts "hey"
      when "next" then puts "hey"
      when "prev" then puts "hey"
      when "logout" 
        Services::Users.logout(@user.token)
        start
      else
        puts "Invalid option"
      end
    end
  end

  def welcome
    puts [
      "####################################",
      "#       Welcome to Expensable      #",
      "####################################"
    ].join("\n")
  end

  def validate_options(arr_options)
    puts "#{arr_options.join(" | ")}"
    print "> "
    option = gets.chomp
    until arr_options.include? option
      puts "Invalid option"
      print "> "
      option = gets.chomp
    end
    option
  end

  def user_form
    print "Email: "
    email = gets.chomp
    email = validate_email(email, "Invalid format")
    print "Password: "
    password = gets.chomp
    password = validate_password(password, "Minimum 6 characters")
    print "First name: "
    first_name = gets.chomp
    print "Last name: "
    last_name = gets.chomp
    print "Phone: "
    phone = gets.chomp
    phone = validate_phone(phone)
    if phone.nil?
      {email: email, password: password, first_name: first_name, last_name:last_name}
    else
      {email: email, password: password, first_name: first_name, last_name:last_name, phone: phone}
    end
  end

  def trans_form
    print "Amount: "
    amount = gets.chomp.to_i # needs validation
    print "Date: "
    date = gets.chomp # needs validation
    print "Notes: "
    notes = gets.chomp # needs validation
    {amount: amount, date: date, notes: notes}
  end

  def login_form
    print "Email: "
    email = gets.chomp
    email = validate_email(email, "Cannot be blank")
    print "Password: "
    password = gets.chomp
    password = validate_password(password, "Cannot be blank")
    {email: email, password: password}
  end

  def validate_email(email, error_mess)
    until email.match(/\w+@mail.com/)
      puts error_mess
      print "Email: "
      email = gets.chomp
    end
    email
  end

  def validate_password(password, error_mess)
    until password.length >= 6
      puts error_mess
      print "Password: "
      password = gets.chomp
    end
    password
  end

  def validate_phone(phone)
    if phone.strip.empty?
      nil
    else
      until phone.match(/^\+51\s\d{9}$/) || phone.match(/^\d{9}$/)
        puts "Required format: +51 111222333 or 111222333"
        print "Phone: "
        phone = gets.chomp
      end
      phone
    end
  end

 #  def table_categories_amount(date)
 # 
 #    month_cat = @categories.select { |category| category.trans_in_month?(date.to_s) }
    # trans_month = month_cat.map { |category| category.only_month_trans(date.to_s) } 

  #   amount = 0
  #   temporal = []
  #   @categories.map do |categorie|
  #     categorie[:transactions].select do |transaction|
  #       temporal.push({categorie[:name] => transaction}) if transaction[:date][5, 2] == date.to_s
  #     end
  #   end
  #   pp temporal
  # end  
  # end

  private
  def get_with_options(options)
    action = ""
    id = nil
    loop do
      puts options.join(" | ")
      print "> "
      action, id = gets.chomp.split # ["update", "48"]
      break
    end
    id.nil? ? [action] : [action, id]
  end

  def find_category(id)
    @categories.find { |cat| cat.id == id}
  end
end


test = Expensable.new
test.start
