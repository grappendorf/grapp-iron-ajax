# Copyright (c) 2015 The Polymer Project Authors. All rights reserved.
# This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
# The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
# The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
# Code distributed by Google as part of the polymer project is also
# subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

Polymer

  is: 'grapp-iron-ajax'

  properties:
    url: {type: String, value: ''}
# grappendorf: params now replace ':name' parts of the url
    params: {type: Object, value: -> {}}
    method: {type: String, value: 'GET'}
    headers: {type: Object, value: -> {}}
    contentType: {type: String, value: 'application/x-www-form-urlencoded'}
    body: {type: String, value: ''}
    sync: {type: Boolean, value: false}
    handleAs: {type: String, value: 'json'}
    withCredentials: {type: Boolean, value: false}
    auto: {type: Boolean, value: false}
    verbose: {type: Boolean, value: false}
    loading: {type: Boolean, notify: true, readOnly: true}
    lastRequest: {type: Object, notify: true, readOnly: true}
    lastResponse: {type: Object, notify: true, readOnly: true}
    lastError: {type: Object, notify: true, readOnly: true}
    activeRequests: {type: Array, notify: true, readOnly: true, value: -> []}
    debounceDuration: {type: Number, value: 0, notify: true}
    _boundHandleResponse: {type: Function, value: -> @_handleResponse.bind(@)}
# grappendorf: add token property
    token: {type: String}
# grappendorf: add baseUrl property
    baseUrl: {type: String, value: ''}
# grappendorf: add path property
    path: {type: String, value: ''}
# grappendorf: add query property
    query: {type: String, value: null}

  observers: [
    '_requestOptionsChanged(baseUrl, url, path, query, method, params, headers,contentType, body, sync, handleAs, withCredentials, auto)'
  ]

# grappendorf: removed the creation of a query string from the params hash

  getRequestUrl: ->
# grappendorf: add baseUrl, path and query to url
    url = (@baseUrl + @url + @path) + (if @query then  '?' + @query else '')
# grappendorf: params replace :name expressions in the url
    for name, value of @params
      url = url.replace ":#{name}", window.encodeURIComponent(value)
    url

  getRequestHeaders: ->
    headers =
      'Content-Type': @contentType
    if @headers instanceof Object
      for key, value of @headers
        headers[key] = value.toString()
    headers

  toRequestOptions: ->
# grappendorf: set Accept and Authorization headers
    headers = @getRequestHeaders()
    headers['accept'] = 'application/json' if @handleAs == 'json'
    headers['authorization'] = @token if @token
    return {
    url: @getRequestUrl()
    method: @method,
# grappendorf: set Accept and Authorization headers
    headers: headers
    body: @body,
    async: !@sync,
    handleAs: @handleAs,
    withCredentials: @withCredentials
    }

  generateRequest: ->
    request = document.createElement 'iron-request'
    requestOptions = @toRequestOptions()
    @activeRequests.push request
    request.completes
    .then(@_boundHandleResponse)
    .catch(@_handleError.bind(@, request))
    .then(@_discardRequest.bind(@, request))
    request.send requestOptions
    @_setLastRequest request
    @_setLoading true
    @fire 'request', {request: request, options: requestOptions}
    request

  _handleResponse: (request) ->
    @_setLastResponse request.response
    @fire 'response', request

  _handleError: (request, error) ->
    if @verbose
      console.error error
    @_setLastError {request: request, error: error}
# grapendorf: set the last response
    @_setLastResponse request.xhr.response
    @fire 'error', {request: request, error: error}
# grappendorf: possibly fire an authorization error event
    if request.xhr.status == 401
      @fire 'grapp-authorization-error'

  _discardRequest: (request) ->
    requestIndex = @activeRequests.indexOf request
    if requestIndex > -1
      @activeRequests.splice requestIndex, 1
    if @activeRequests.length == 0
      @_setLoading false

  _requestOptionsChanged: ->
    @debounce 'generate-request', ->
# grappendorf: add baseUrl check
      if (!@url || @url == '') && (!@baseUrl || @baseUrl == '')
        return
      if @auto
        @generateRequest()
    , this.debounceDuration
