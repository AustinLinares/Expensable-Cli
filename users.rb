require "json"
require "httparty"

module Services
  # base_uri("https://expensable-api.herokuapp.com/")
  # include httparty

  class Users
    include HTTParty
    base_uri("https://expensable-api.herokuapp.com/")
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
  end
end