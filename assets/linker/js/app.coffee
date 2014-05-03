((io) ->
  # as soon as this file is loaded, connect automatically,
  # Listen for Comet messages from Sails

  #/////////////////////////////////////////////////////////
  # Replace the following with your own custom logic
  # to run when a new message arrives from the Sails.js
  # server.
  #/////////////////////////////////////////////////////////

  #////////////////////////////////////////////////////

  #/////////////////////////////////////////////////////////
  # Here's where you'll want to add any custom logic for
  # when the browser establishes its socket connection to
  # the Sails.js server.
  #/////////////////////////////////////////////////////////

  #/////////////////////////////////////////////////////////

  # Expose connected `socket` instance globally so that it's easy
  # to experiment with from the browser console while prototyping.
  # Simple log function to keep the example simple

  log = ->
    console.log.apply console, arguments  if console
  socket = io.connect()
  log "Connecting to Sails.js..."  if console
  socket.on "connect", socketConnected = ->
    socket.on "message", messageReceived = (message) ->
      log "New comet message received :: ", message

    log """
      Socket is now connected and globally accessible as `socket`.
      e.g. to send a GET request to Sails, try
      `socket.get("/", function (response) " + "{ console.log(response); })`
    """

  window.socket = socket

# In case you're wrapping socket.io to prevent pollution of the global namespace,
# you can replace `window.io` with your own `io` here:
) window.io
