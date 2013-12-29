{extend} = require 'underscore'
Mixin = require 'mixto'

module.exports =
class Serializable extends Mixin
  deserializers: null

  @registerDeserializers: (deserializers...) ->
    @registerDeserializer(deserializer) for deserializer in deserializers

  @registerDeserializer: (deserializer) ->
    @deserializers ?= {}
    @deserializers[deserializer.name] = deserializer

  @deserialize: (state, params) ->
    if state.deserializer is @name
      deserializer = this
    else
      deserializer = @deserializers?[state.deserializer]

    object = Object.create(deserializer.prototype)
    params = extend({}, state, params)
    params = object.deserializeParams?(params) ? params
    deserializer.call(object, params)
    object

  serialize: ->
    state = @serializeParams?() ? {}
    state.deserializer = @constructor.name
    state
