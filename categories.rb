 class Categories

    attr_reader :id, :name, :transaction_type, :transactions

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

    def only_month_trans(month)
      sel_trans = @transactions.select { |tr| tr[:date][5, 2] == month }
      sel_trans
    end

  end