require_relative 'lib/photostore'

include PhotoStore

# temp_data_file = Scanner.call
# data = JSON.load_file(temp_data_file)
# data.take(10).then{ pp it }
# puts data.size

store = Store.new
pp store.get(:DP2Q3636)
pp store.slice(:DP2Q3636, :DP2Q3521)
