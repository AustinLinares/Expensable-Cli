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

  attr_accessor :tr_type, :categories, :current_month

  def intialize
    @user = nil
    @categories = []
    @current_month = nil
    @tr_type = nil
  end

  def start
    welcome
    @current_month = Date.today
    action = validate_options(["login", "create_user", "exit"])
    @tr_type = "expense"
    case action
    when "login"
      user_data = login_form
      data_login = Services::Users.login(user_data)
      @user = Services::Users.new(data_login)
      @categories = Services::Users.categories(@user.token).map { |cat| Services::Categories.new(cat) }
    when "create_user"
      user_data = user_form
      data_new_user = Services::Users.create_user(user_data)
      @user = Services::Users.new(data_new_user)
      @categories = Services::Users.categories(@user.token).map { |cat| Services::Categories.new(cat) }
    when "exit" then exit!
    else
      puts "Invalid option"
    end
    category_table
    second_display
  end

  def second_display
    action = ""
    until action == "logout"
      action, id = get_with_options(["create", "show ID", "update ID", "delete ID", "add-to ID", "toggle", "next",
                                     "prev", "logout"])
      ids = cat_ids
      case action
      when "create"
        create_cat
        category_table
      when "show"
        if ids.include?(id.to_i)
          cat = find_category(id.to_i)
          cat.show_cat(@current_month)
          action2, id2 = get_with_options(["add", "update ID", "delete ID", "next", "prev", "back"])
          until action2 == "back"
            tr_ids = cat.trans_ids
            case action2
            when "add"
              tr_data = trans_form
              cat.add_transaction(@user.token, tr_data)
            when "update"
              if tr_ids.include?(id2.to_i)
                tr_data = trans_form
                cat.updt_transaction(@user.token, id2.to_i, tr_data)
              else
                puts "Invalid option"
              end
            when "delete"
              if tr_ids.include?(id2.to_i)
                cat.del_transaction(@user.token, id2.to_i)
              else
                puts "Invalid option"
              end
            when "next"
              next_month
            when "prev"
              prev_month
            end
            cat.show_cat(@current_month)
            action2, id2 = get_with_options(["add", "update ID", "delete ID", "next", "prev", "back"])
          end
          category_table
        else
          puts "Invalid ID"
        end
      when "update"
        if ids.include?(id.to_i)
          cat = find_category(id.to_i)
          cat_updts = update_category(id)
          cat.name = cat_updts[:name]
          cat.transaction_type = cat_updts[:transaction_type]
          category_table
        else
          puts "Invalid ID"
        end
      when "delete"
        if ids.include?(id.to_i)
          cat = find_category(id.to_i)
          @categories.delete(cat)
          delete_category(id)
          category_table
        else
          puts "Invalid ID"
        end
      when "add-to"
        if ids.include?(id.to_i)
          cat = find_category(id.to_i)
          trans_data = trans_form
          cat.add_transaction(@user.token, trans_data)
          category_table
        else
          puts "Invalid ID"
        end
      when "toggle"
        case @tr_type
        when "expense"
          @tr_type = "income"
        when "income"
          @tr_type = "expense"
        end
        category_table
      when "next"
        next_month
        category_table
      when "prev"
        prev_month
        category_table
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
    puts arr_options.join(" | ").to_s
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
      { email: email, password: password, first_name: first_name, last_name: last_name }
    else
      { email: email, password: password, first_name: first_name, last_name: last_name, phone: phone }
    end
  end

  def trans_form
    print "Amount: "
    amount = gets.chomp # needs validation
    until amount.match(/\d/)
      puts "Invalid amount"
      print "Amount: "
      amount = gets.chomp
    end
    date = date_validation
    print "Notes: "
    notes = gets.chomp
    if notes.empty?
      { amount: amount.to_i, date: date}
    else
      { amount: amount.to_i, date: date, notes: notes }
    end
  end

  def login_form
    print "Email: "
    email = gets.chomp
    email = validate_email(email, "Cannot be blank")
    print "Password: "
    password = gets.chomp
    password = validate_password(password, "Cannot be blank")
    { email: email, password: password }
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
    puts options.join(" | ")
    print "> "
    action, id = gets.chomp.split # ["update", "48"]
    id.nil? ? [action] : [action, id]
  end

  def find_category(id)
    @categories.find { |cat| cat.id == id }
  end

  def cat_ids
    total = []
    @categories.each { |cat| total << cat.id }
    total
  end

  def prev_month
    @current_month = @current_month << 1
  end

  def next_month
    @current_month = @current_month >> 1
  end
end

test = Expensable.new
test.start
