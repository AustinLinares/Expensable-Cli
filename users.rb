require "json"
require "httparty"

module Services
  # base_uri("https://expensable-api.herokuapp.com/")
  # include httparty

  class Users
    include HTTParty
    base_uri("https://expensable-api.herokuapp.com/")
    attr_accessor :id, :email, :first_name, :last_name, :phone, :token

    def initialize(id:, email:, first_name:, last_name:, phone:, token:)
      @id = id
      @email = email
      @first_name = first_name
      @last_name = last_name
      @phone = phone
      @token = token
    end

    def self.create_user(user_data)
      options = {
        headers: { "Content-Type": "application/json" },
        body: user_data.to_json
      }

      response = post("/signup", options)
      # raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.login(user_data)
      options = {
        headers: { "Content-Type": "application/json" },
        body: user_data.to_json
      }
      response = post("/login", options)

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.categories(token)
      options = {
        headers: { Authorization: "Token token=#{token}" }
      }

      response = get("/categories", options)
      # raise(HTTParty::ResponseError, response) unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.logout(token)
      options = {
        headers: { Authorization: "Token token=#{token}" }
      }

      delete("/logout", options)
    end
  end
end
