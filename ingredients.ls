_ = require 'prelude-ls'
fs = require 'fs'
distance = require 'jaro-winkler'

training_input = require './data/train.json'
test_input = require './data/test.json'

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


ingredients = training_input
   |> _.map (item) ->
      item.ingredients
   |> _.flatten
   |> _.map (item) ->
      item.toLowerCase!
         .replace /[^\x00-\x7F]/g, ''
         .replace /[\d]/g, ''
         .replace /[\(\)\[\]\.\"\'\%\$]\\\/;\-,]/g,''
   |> _.group-by (item) ->
      item
   |> _.obj-to-pairs
   |> _.flatten

console.log ingredients.length
for i from 0 to ingredients.length-2
   for j from i+1 to ingredients.length-1
      d = distance ingredients[i],ingredients[j]
   console.log i

#ingredients
#   |> _.each (item) ->
#      d = distance item,ingredients[1200]
#      if d > 0.85
#         console.log item,d
