Polymer 'grapp-core-ajax',

  processError: (xhr) ->
    try
      response = JSON.parse xhr.responseText
    catch
      response = ''
    @fire 'core-error',
      status: xhr.status
      response: response
      xhr: xhr

  go: ->
    @add_accept_header()
    @super()

  add_headers: (headers) ->
    @headers = @headers || {}
    if @headers && typeof(@headers) == 'string'
      @headers = JSON.parse @headers
    for key of headers
      @headers[key] = headers[key]

  add_csrf_header: ->
    @add_headers
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content

  add_accept_header: ->
    @add_headers {'Accept': 'application/json'}
