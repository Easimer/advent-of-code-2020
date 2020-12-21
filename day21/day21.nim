import algorithm
import deques
import json
import os
import options
import sets
import sequtils
import strutils
import strscans
import lists
import heapqueue
import tables
import sugar

type
  Food = object
    ingredients: seq[string]
    allergens: seq[string]

  ## Maps allergens to the ingredients that contain it
  AllergenIngredientsMap = Table[string, HashSet[string]]

  Ingredient = object
    name: string
    allergen: string

func cmpByAllergen(lhs, rhs: Ingredient): int =
  cmp(lhs.allergen, rhs.allergen)

proc readFood(f: File, food: var Food): bool =
  if f.endOfFile(): return false

  var
    ingredients: string
    allergens: string

  if not scanf(f.readline(), "$+ (contains $+)$.", ingredients, allergens):
    assert(false)

  food.ingredients = ingredients.split()
  food.allergens = allergens.split(", ")

  return true

func makeIngredientSetUniverse(foods: seq[Food]): HashSet[string] =
  for food in foods:
    for i in food.ingredients:
      result.incl(i)

func makeAllergenIngredientsMap(foods: seq[Food], allIngredients: HashSet[string]): AllergenIngredientsMap =
  # Initialize allergen -> ingredients set to universe
  for food in foods:
    for allergen in food.allergens:
      result[allergen] = allIngredients

  for food in foods:
    for allergen in food.allergens:
      let iset = toHashSet(food.ingredients)
      result[allergen] = intersection(result[allergen], iset)

## Returns the set of ingredients that contain allergens
func makeSetOfIngredientsContainingAllergens(m: AllergenIngredientsMap): HashSet[string] =
  for allergen, iset in m:
    for i in iset:
      result.incl(i)

func part1(foods: seq[Food], ingredientsNotContainingAllergens: HashSet[string]): string =
  var cnt = 0
  for food in foods:
    for ingredient in food.ingredients:
      if ingredient in ingredientsNotContainingAllergens:
        cnt += 1
  return $cnt

func getIngredientWithOneAllergen(aim: AllergenIngredientsMap): (string, string) =
  for k, v in aim:
    if len(v) == 1:
      return (k, toSeq(v.items)[0])
  assert(false)

func makeIngredientAllergenMap(ingredientsContainingAllergens: HashSet[string], allergenIngredientsMap: AllergenIngredientsMap): seq[Ingredient] =

  #while aim is not empty:
    #pick an ingredient from ICA with exactly one allergen
    #remove it from aim and put it in result
    #look for ingredients that may contain that allergen
      #remove that i-a pair

  var aim = allergenIngredientsMap

  while len(aim) > 0:
    let (a, i) = getIngredientWithOneAllergen(aim)
    result.add(Ingredient(name: i, allergen: a))
    aim.del(a)
    for allergen, ingredients in aim.mpairs:
      ingredients.excl(i)

  result.sort(cmpByAllergen)

when isMainModule:
  var
    f: File
    food: Food
    foods: seq[Food]

  let inputPath = if paramCount() > 0: paramStr(1) else: "day21.txt"
  if open(f, inputPath):
    while readFood(f, food):
      foods.add(food)

    let allIngredients = makeIngredientSetUniverse(foods)
    let allergenIngredientsMap = makeAllergenIngredientsMap(foods, allIngredients)
    let ingredientsContainingAllergens = makeSetOfIngredientsContainingAllergens(allergenIngredientsMap)
    let ingredientsNotContainingAllergens = allIngredients - ingredientsContainingAllergens

    let res1 = part1(foods, ingredientsNotContainingAllergens)

    let iam = makeIngredientAllergenMap(ingredientsContainingAllergens, allergenIngredientsMap)
    let ingredients = collect(newSeq):
      for ia in iam:
        ia.name

    let res2 = ingredients.join(",")

    echo(%*{"output1": res1, "output2": res2})
  else:
    echo("Couldn't open input file " & inputPath & "!")

