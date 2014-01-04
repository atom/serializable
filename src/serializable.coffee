{extend} = require 'underscore'
Mixin = require 'mixto'
getParameterNames = require 'get-parameter-names'

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

    return unless deserializer? and deserializer.version is state.version

    object = Object.create(deserializer.prototype)
    params = extend({}, state, params)
    delete params.deserializer

    if typeof object.deserializeParams is 'function'
      params = object.deserializeParams(params)

    return unless params?

    deserializer.parameterNames ?= getParameterNames(deserializer)
    if deserializer.parameterNames.length > 1 or params.hasOwnProperty(deserializer.parameterNames[0])
      orderedParams = deserializer.parameterNames.map (name) -> params[name]
      deserializer.call(object, orderedParams...)
    else
      deserializer.call(object, params)
    object

  serialize: ->
    state = @serializeParams?() ? {}
    state.deserializer = @constructor.name
    state.version = @constructor.version if @constructor.version?
    state

  testSerialization: (params) ->
    @constructor.deserialize(@serialize(), params)
