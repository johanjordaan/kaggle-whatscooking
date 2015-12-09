_ = require 'prelude-ls'
fs = require 'fs'

training_data = require './train.json'

# Sanatise the ingredient data
#
splitIngredients = (ingredients) ->
   retVal = []
   ingredients |> _.each (ingredient) ->
      ingredient = ingredient.toLowerCase!
         .replace /[^\x00-\x7F]/g, ''
         .replace /[\d]/g, ''
         .replace /[\(\)\[\]\.\"\'\%\$]\\\/;\-,]/g,''
      ingredient
         |> _.words
         |> _.unique
         |> _.filter (word) ->
            word.length>3
         |> _.each (word) ->
            retVal.push word
   retVal

data_set = training_data
  |> _.map (item) ->
    do
      cuisine: item.cuisine
      ingredient_count: item.ingredients.length
      ingredients: splitIngredients item.ingredients

type_freq = data_set
   |> _.count-by (item) ->
      item.cuisine
   |> _.obj-to-pairs
   |> _.sort-by ([key,count]) ->
      count
   |> _.pairs-to-obj

threshold = 20
ingredient_count = data_set
   |> _.map (item) ->
      item.ingredients
   |> _.flatten
   |> _.count-by (item) ->
      item
   |> _.obj-to-pairs
   |> _.filter ([ingredient,count]) ->
      count>threshold
   |> _.pairs-to-obj

ingredients = ingredient_count
   |> _.obj-to-pairs
   |> _.map ([ingredient,count]) ->
      ingredient

#console.log ingredients,ingredients.length
console.log '-----------------------'

matrix = data_set
   |> _.map (item) ->
      ingredients
         |> _.map (ingredient) ->
            if ingredient in item.ingredients then 1 else 0

stream = fs.createWriteStream 'training_matrix'
stream.once 'open', (fd) ->
   matrix
      |> _.each (row) ->
         row |> _.each (col) -> stream.write "#{col} "
         stream.write "\n"
   stream.end!





# Write a submission
#
writeSubmission = (predict) ->
  test_data = require './test.json'
  stream = fs.createWriteStream 'submission.csv'
  stream.once 'open', (fd) ->
    stream.write "id,cuisine\n"
    test_data
      |> _.each (item) ->
        stream.write "#{item.id},#{predict(item.ingredients)}\n"
    stream.end!
