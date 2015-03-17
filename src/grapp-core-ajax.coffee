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
    @headers = @headers || {}
    if @headers && typeof(@headers) == 'string'
      @headers = JSON.parse @headers
    headers['Accept'] = 'application/json' if @handleAs == 'json'
    headers['Authorization'] = @token if @token
    @super()
