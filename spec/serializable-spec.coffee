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
