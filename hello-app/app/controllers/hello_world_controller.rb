class HelloWorldController < ApplicationController
  def index
    render plain: "Hello World v2.1"
  end
end
