_ = require 'prelude-ls'
x = require './train.json'


# Flatten the list of cuisines and ingredients
#
types = []
ingredients = []

x |> _.each (meal) ->
  types.push meal.cuisine
  meal.ingredients |> _.each (ingredient) ->
    ingredient = ingredient.toLowerCase!
      .replace 'or',''
      .replace 'and',''
      .replace '-',' '
      .replace '"',''
      .replace "'",''
      .replace '%',''
      .replace '.',''
    ingredient |>_.words |> _.each (word) ->
        ingredients.push word

type_freq = types
  |> _.count-by (item) ->
    item

ingredient_freq = ingredients
  |> _.count-by (item) ->
    item

console.log (ingredient_freq |> _.obj-to-pairs).length

ingredient_freq
  |> _.obj-to-pairs
  |> _.filter ([a,b]) ->
      b > 10
  |> console.log
