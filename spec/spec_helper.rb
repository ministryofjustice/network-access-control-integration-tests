require 'socket'
require 'sequel'

Dir["./spec/support/shared_examples/*.rb"].sort.each { |f| require f }

module DBHelper
  extend RSpec::SharedContext
  let(:db) do
    Sequel.connect(
      adapter: 'mysql2',
      host: ENV.fetch('DB_HOST'),
      database: ENV.fetch('DB_NAME'),
      user: ENV.fetch('DB_USER'),
      password: ENV.fetch('DB_PASS'))
  end

  before do
    db.run("SET FOREIGN_KEY_CHECKS = 0;")
    db[:rules].truncate
    db[:policies].truncate
    db[:responses].truncate
    db[:clients].truncate
    db[:site_policies].truncate
    db[:sites].truncate
    db.run("SET FOREIGN_KEY_CHECKS = 1;")
  end
end

RSpec.configure do |c|
  c.include DBHelper
end
