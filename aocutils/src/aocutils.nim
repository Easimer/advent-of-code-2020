import json

func minp*[T](a: openArray[T]): int =
  ## Finds the place of the minimum
  result = 0
  for i in 1 .. a.high():
    if a[i] < a[result]:
      result = i

func maxp*[T](a: openArray[T]): int =
  ## Finds the place of the maximum
  result = 0
  for i in 1 .. a.high():
    if a[i] < a[result]:
      result = i

func count*[T](arr: openArray[T], pred: proc(x: T): bool): int =
  ## Returns the number of elements for which `pred` holds.
  for elem in arr:
    if pred(elem):
      result += 1

func all*[T](arr: openArray[T], pred: proc(x: T): bool): bool =
  for elem in arr:
    if not pred(elem):
      return false
  return true

func any*[T](arr: openArray[T], pred: proc(x: T): bool): bool =
  for elem in arr:
    if pred(elem):
      return true
  return false

func contains*[T](arr: openArray[T], value: T): bool =
  for elem in arr:
    if elem == value: return true
  return false

func min*[T](arr: openArray[T]): T =
  ## Finds the value of the minimum
  var idx = 0
  for i in 1 .. arr.high():
    if arr[i] < arr[idx]:
      idx = i
  result = arr[idx]

func max*[T](arr: openArray[T]): T =
  ## Finds the value of the maximum
  var idx = 0
  for i in 1 .. arr.high():
    if arr[i] > arr[idx]:
      idx = i
  result = arr[idx]

iterator where*[T](arr: openArray[T], pred: proc(x: T): bool): T =
  for i in arr.low() .. arr.high():
    if pred(arr[i]):
      yield arr[i]
