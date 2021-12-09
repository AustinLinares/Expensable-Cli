# Start here. Happy coding!
require "json"
require "httparty"
require "terminal-table"
require_relative "users"
require "date"


class Expensable
  def intialize
    @date = DateTime.now
    @user = nil
    @categories = []
    @transactions = []
    # @current_month = Date.now
    @display = "expenses"
  end

  def start
    welcome
    action = validate_options(["login", "create_user", "exit"])
    until action == "exit"
      case action
      when "login" 
        user_data = login_form
        data_login = Services::Users.login(user_data)
        @user = Services::Users.new(data_login)
        @categories = Services::Users.categories(@user.token)
        table_categories_amount(@date)
        action = validate_options(["login", "create_user", "exit"])
      when "create_user" 
        user_data = user_form
        data_new_user = Services::Users.create_user(user_data)
        @user = Services::Users.new(data_new_user)
        @categories = Services::Users.categories(@user.token)
        action = validate_options(["login", "create_user", "exit"])
      # else
      #   puts "Invalid option"
      end
    end
  end

  def welcome
  puts "####################################
  #       Welcome to Expensable      #
  ####################################"
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
    {email: email, password: password, first_name: first_name, last_name:last_name, phone: phone}
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
      phone
    else
      until phone.match(/^\+51\s\d{9}$/) || phone.match(/^\d{9}$/)
        puts "Required format: +51 111222333 or 111222333"
        print "Phone: "
        phone = gets.chomp
      end
      phone
    end
  end

  def table_categories_amount(ab)
    amount = 0
    temporal = []
    @categories.map do |categorie|
      categorie[:transactions].select do |transaction|
        temporal.push(transaction) if transaction[:date][5, 2] == ab.month.to_s
      end
    end
    pp temporal
  end
end


test = Expensable.new
test.start
