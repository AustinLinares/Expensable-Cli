require "minitest/autorun"
require_relative "categories"
require_relative "category_handler"

class CatTest < Minitest::Test
  include CategoryHandlbegin

  def test_select_month_transactions
    data = {id: 240,
            name: "Other",
            transaction_type: "income",
            transactions: [
              {id: 1918, amount: 120, date: "2021-10-12", notes: "Headphones"},
              {id: 1919, amount: 250, date: "2021-11-20", notes: "HD Webcam"},
              {id: 1920, amount: 250, date: "2021-12-25", notes: "Keyboard"},
              {id: 2722, amount: 300, date: "2021-01-01", notes: "Mouse"}
            ]
          }
    date = "2021-12"

    category = Services::Categories.new(data)
    selected = category.only_month_trans(date)

    assert_equal(selected.length, 1)
    assert_equal(selected[0][:id], 1920)
    assert_equal(category.name, "Other")
  end

  def test_validation_data
    data = {id: 240,
            name: "Other",
            transaction_type: "income",
            transactions: [
              {id: 1918, amount: 120, date: "2021-10-12", notes: "Headphones"},
              {id: 1919, amount: 250, date: "2021-11-20", notes: "HD Webcam"},
              {id: 1920, amount: 250, date: "2021-12-25", notes: "Keyboard"},
              {id: 2722, amount: 300, date: "2021-01-01", notes: "Mouse"}
            ]
          }
    tr_id = 2722
    tr_type = "income"
    category = Services::Categories.new(data)
    tr_selected = category.find_tr(tr_id)

    assert_equal(tr_selected.length, 4)
    assert_equal(tr_selected[:id], tr_id)
    assert_equal(category.transaction_type, tr_type_validation(tr_type))
  end
end