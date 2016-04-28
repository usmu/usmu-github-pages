module Usmu::Github::Pages::Commands
end

%w{
  usmu/github/pages/commands/deploy
  usmu/github/pages/commands/init
}.each {|f| require f }
