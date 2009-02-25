# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml, :user, :form
  engine :Haml
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/auth'
