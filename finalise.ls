_ = require 'prelude-ls'
fs = require 'fs'

# Write a submission
#
writeSubmission = (submission) ->
  stream = fs.createWriteStream './data/submission.csv'
  stream.once 'open', (fd) ->
    stream.write "id,cuisine\n"
    submission
      |> _.each ([id,guess]) ->
        stream.write "#{id},#{guess}\n"
    stream.end!

fs.readFile './data/test_test_index', 'utf8', (err, test_index_data) ->
   if err? then throw err;
   fs.readFile './data/cuisine_index', 'utf8', (err, cuisine_index_data) ->
      if err? then throw err;
      fs.readFile './data/submission_matrix', 'utf8', (err, submission_matrix) ->
         if err? then throw err;

         cuisine_lookup = cuisine_index_data.split "\n"
            |> _.filter (line) ->
               line.trim!.length > 0
            |> _.map (line) ->
               tokens = line.split ","
               [tokens[0],tokens[1]]
            |> _.pairs-to-obj

         guess = submission_matrix.trim!.split(" ")
            |> _.filter (item) ->
               item.trim!.length > 0
            |> _.map (item) ->
               cuisine_lookup[item]

         test_ids = test_index_data.split "\n"
            |> _.filter (line) ->
               line.trim!.length > 0
            |> _.map (line) ->
               tokens = line.split ","
               tokens[1]

         writeSubmission _.zip test_ids,guess
