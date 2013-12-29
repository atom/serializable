{extend} = require 'underscore'
Mixin = require 'mixto'

module.exports =
class Serializable extends Mixin
  @deserialize: (state, params) ->
    object = Object.create(@prototype)
    params = extend({}, state, params)
    params = object.deserializeParams?(params) ? params
    @call(object, params)
    object

  serialize: ->
    state = @serializeParams?() ? {}
    state.deserializer = @constructor.name
    state
