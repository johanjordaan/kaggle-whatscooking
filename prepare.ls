_ = require 'prelude-ls'
fs = require 'fs'

training_input = require './data/train.json'
test_input = require './data/test.json'

THRESHOLD = 500   # Number of occurences of ingredient in recipes

# Sanitise the ingredient data
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

loadTestingData = (data, training_ingredients) ->
   data_set = data
     |> _.map (item) ->
         do
            id: item.id
            ingredients: splitIngredients item.ingredients

   test_index = data_set
      |> _.map (item) ->
         item.id
      |> _.zip [0 to data_set.length-1]

   features_matrix = data_set
      |> _.map (item) ->
         training_ingredients
            |> _.map (ingredient) ->
               if ingredient in item.ingredients then 1 else 0


   do
      test_index: test_index
      features_matrix: features_matrix





loadTrainingData = (data) ->
   data_set = data
     |> _.map (item) ->
         do
            cuisine: item.cuisine
            ingredients: splitIngredients item.ingredients

   cuisine_count = data_set
      |> _.count-by (item) ->
         item.cuisine
      |> _.obj-to-pairs
      |> _.sort-by ([key,count]) ->
         count
      |> _.pairs-to-obj

   cuisines = cuisine_count
      |> _.obj-to-pairs
      |> _.map ([cuisine,count]) ->
         cuisine

   ingredient_count = data_set
      |> _.map (item) ->
         item.ingredients
      |> _.flatten
      |> _.count-by (item) ->
         item
      |> _.obj-to-pairs
      |> _.filter ([ingredient,count]) ->
         count > THRESHOLD
      |> _.pairs-to-obj

   ingredients = ingredient_count
      |> _.obj-to-pairs
      |> _.map ([ingredient,count]) ->
         ingredient

   features_matrix = data_set
      |> _.map (item) ->
         ingredients
            |> _.map (ingredient) ->
               if ingredient in item.ingredients then 1 else 0

   cuisine_index = cuisines |> _.zip [0 to cuisines.length-1]
   cuisine_lookup = cuisine_index
      |> _.map ([index, name]) ->
         [name, index]
      |> _.pairs-to-obj
   result_matrix = data_set
      |> _.map (item) ->
         [cuisine_lookup[item.cuisine]]

   do
      ingredients: ingredients
      ingredients_index: ingredients |> _.zip [0 to ingredients.length-1]
      cuisine_index: cuisine_index
      features_matrix: features_matrix
      result_matrix: result_matrix

writeIndex = (name, index) ->
   stream = fs.createWriteStream name
   stream.once 'open', (fd) ->
      index
         |> _.each (item) ->
             stream.write "#{item[0]},#{item[1]}\n"
      stream.end!

writeMatrix = (name, matrix) ->
   stream = fs.createWriteStream name
   current_row = 0
   write = ->
      process.stdout.write "Writing [#{current_row}]\r"
      ok = true
      while ok
         if current_row >= matrix.length
            stream.end!

            console.log "\nDone [#{current_row}]"
            return
         tmp = ""
         matrix[current_row] |> _.each (col) -> tmp += "#{col} "
         ok  = stream.write "#{tmp}\n"
         if ok
            current_row++
         else
            stream.once 'drain', ->
               write!
   stream.once 'open', (fd) ->
      write!


training = loadTrainingData training_input
writeIndex 'data/ingredients_index', training.ingredients_index
writeIndex 'data/cuisine_index', training.cuisine_index
writeMatrix 'data/training_features_matrix', training.features_matrix
writeMatrix 'data/training_result_matrix', training.result_matrix

test = loadTestingData test_input, training.ingredients
writeIndex 'data/test_test_index', test.test_index
writeMatrix 'data/test_features_matrix', test.features_matrix
