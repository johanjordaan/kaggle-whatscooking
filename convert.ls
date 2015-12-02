_ = require 'prelude-ls'
fs = require 'fs'

training_data = require './train.json'

# Sanatise the ingredient data
splitIngredients = (ingredients) ->
  retVal = []
  ingredients |> _.each (ingredient) ->
    ingredient = ingredient.toLowerCase!
      .replace ' or ',''
      .replace ' and ',''
      .replace ' a ',''
      .replace ' the ',''
      .replace '-',' '
      .replace '"',''
      .replace "'",''
      .replace '%',''
      .replace '.',''
    ingredient |>_.words |> _.each (word) ->
      retVal.push word


# Flatten the list of cuisines and ingredients
#
types = []
ingredients = []


data_set = training_data
  |> _.map (item) ->
    types.push item.cuisine
    ingredients.concat  splitIngredients item.ingredients

    do
      cuisine: item.cuisine
      ingredient_count: item.ingredients.length
      ingredients: splitIngredients item.ingredients
  |> _.group-by (item) ->
    item.cuisine

console.log data_set.mexican


type_freq = types
  |> _.count-by (item) ->
    item
  |> _.obj-to-pairs
  |> _.sort-by ([key,count]) ->
    count

ingredient_freq = ingredients
  |> _.count-by (item) ->
    item

predict = (ingredients) ->
  splitIngredients ingredients
  type_freq[type_freq.length-2][0]

# Write a submission
#
writeSubmission =  ->
  test_data = require './test.json'
  stream = fs.createWriteStream 'submission.csv'
  stream.once 'open', (fd) ->
    stream.write "id,cuisine\n"
    test_data
      |> _.each (item) ->
        stream.write "#{item.id},#{predict(item.ingredients)}\n"
    stream.end!

writeSubmission!
