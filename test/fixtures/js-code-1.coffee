class Base
  privateVar = 4
  constructor: ->
    privateVar = 5
  methodA: -> 
    "test#{@fieldA}+#{privateVar}"

class A extends Base
  constructor: ->
    super
    @fieldA = 123
    @pMethB = methodB
  methodB: (a) => 
    if a in [1, 2, 3]
      @methodA() + a
    else
      false

a = new A
a.methodB(1)