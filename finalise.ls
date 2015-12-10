_ = require 'prelude-ls'
fs = require 'fs'

# Write a submission
#
writeSubmission = (submission) ->
  test_data = require './test.json'
  stream = fs.createWriteStream 'submission.csv'
  stream.once 'open', (fd) ->
    stream.write "id,cuisine\n"
    test_data
      |> _.each (item) ->
        stream.write "#{item.id},#{predict(item.ingredients)}\n"
    stream.end!

# Read the dish_index to get the dish id's



# Read the cuisine_index to get the list of cuisines and their indexes
#

# Read the test_result_matrix this will need to be converted to dish id and
# a matching cuisine id
#
