class A
  privateVar = 4
  constructor: ->
    @fieldA = 123
    privateVar = 5
  methodA: -> "test#{@fieldA}+#{privateVar}"
  methodB: (a) -> @methodA() + a
a = new A
return a.methodB("ololo")