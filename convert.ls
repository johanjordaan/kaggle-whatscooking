_ = require 'prelude-ls'
fs = require 'fs'

training_data = require './train.json'

# Sanatise the ingredient data
#
splitIngredients = (ingredients) ->
  retVal = []
  ingredients |> _.each (ingredient) ->
    ingredient = ingredient.toLowerCase!
      .replace '-',' '
      .replace '"',''
      .replace "'",''
      .replace '!',''
      .replace '%',''
      .replace '.',''
      .replace ' or ',''
      .replace ' and ',''
      .replace ' a ',''
      .replace ' the ',''
      .replace ' it ',''
    ingredient |>_.words |> _.unique |> _.each (word) ->
      retVal.push word
  retVal

# Flatten the list of cuisines and ingredients
#
types = []
ingredients = []


data_set = training_data
  |> _.map (item) ->
    types.push item.cuisine
    ingredients.push splitIngredients item.ingredients

    do
      cuisine: item.cuisine
      ingredient_count: item.ingredients.length
      ingredients: splitIngredients item.ingredients

  |> _.group-by (item) ->
    item.cuisine

console.log splitIngredients data_set['italian'][0].ingredients

type_freq = types
  |> _.count-by (item) ->
    item
  |> _.obj-to-pairs
  |> _.sort-by ([key,count]) ->
    count

ingredient_freq = ingredients
  |> _.flatten
  |> _.count-by (item) ->
    item

console.log ingredient_freq



# Simply choose the most frequent type
mostFrequent = (ingredients) ->
  type_freq[type_freq.length-1][0]

# Make a random selectionn
randomChoice =  (ar) ->
  ar[Math.floor Math.random! * ar.length]
randomSelection = (ingredients) ->
  (randomChoice type_freq)[0]

#basedOnIngredientCount = (ingredients) ->
#  splitIngredients ingredients



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

#writeSubmission randomSelection
