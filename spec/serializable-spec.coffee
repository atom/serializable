Serializable = require '../src/serializable'

describe "Serializable", ->
  it "provides a default implementation of .deserialize and ::serialize based on (de)serializing params", ->
    class Parent extends Serializable
      constructor: ({@child, foo}={}) ->
        @child ?= new Child(parent: this, foo: foo)

      serializeParams: ->
        child: @child.serialize()

      deserializeParams: (state) ->
        state.child = Child.deserialize(state.child, parent: this)
        state

    class Child extends Serializable
      constructor: ({@parent, @foo}) ->

      serializeParams: -> {@foo}

    parentA = new Parent(foo: 1)
    expect(parentA.child.parent).toBe parentA
    expect(parentA.child.foo).toBe 1

    parentB = Parent.deserialize(parentA.serialize())
    expect(parentB.child.parent).toBe parentB
    expect(parentB.child.foo).toBe 1

  it "allows other deserializers to be registered on a serializable class", ->
    class Superclass extends Serializable

    class SubclassA extends Superclass
      constructor: ({@foo}) ->
      serializeParams: -> {@foo}

    class SubclassB extends Superclass
      constructor: ({@bar}) ->
      serializeParams: -> {@bar}

    Superclass.registerDeserializers(SubclassA, SubclassB)

    a = Superclass.deserialize(new SubclassA(foo: 1).serialize())
    expect(a instanceof SubclassA).toBe true
    expect(a.foo).toBe 1

    b = Superclass.deserialize(new SubclassB(bar: 2).serialize())
    expect(b instanceof SubclassB).toBe true
    expect(b.bar).toBe 2

  it "allows ordered constructor parameters to be inferred from their names so constructors don't need to take a hash", ->
    class Example extends Serializable
      constructor: (@foo, @bar) ->
      serializeParams: -> {@foo, @bar}

    object = Example.deserialize(new Example(2, 1).serialize())
    expect(object.foo).toBe 2
    expect(object.bar).toBe 1

  it "returns undefined from deserialize if the deserializer's version number doesn't match", ->
    class Example extends Serializable
      @version: 1
      constructor: (@foo, @bar) ->
      serializeParams: -> {@foo, @bar}

    object = new Example(1, 2)
    state = object.serialize()
    expect(Example.deserialize(state)).toBeDefined()
    Example.version = 2
    expect(Example.deserialize(state)).toBeUndefined()
