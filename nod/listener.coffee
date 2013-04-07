# This listens for changes in the field, and changes its status
# accordingly while broadcasting it via trigger()
#
class Listener

  constructor: ( el, @get, metric, msg ) ->
    @$el      = jQuery el
    @delayId  = ""                            # So we can cancel delayed checks
    @status   = true                          # We assume field to be ok
    @check    = new Checker @$el, metric      # Run this to check a field
    @msg      = new Msg     @$el, @get, msg   # Toggles showing/hiding msgs
    @events()                                 # Listen for changes on element


  events : =>
    if @$el.attr( 'type' ) is 'radio'         # Listen to all with same name
      jQuery( '[name='+@$el.attr("name")+']' ).on 'change', @runCheck
    else
      @$el.on 'change', @runCheck             # For checkboxes and select fields
      @$el.on 'blur'  , @runCheck             # On blur we run the check
      @$el.on 'keyup' , @delayedCheck if @get.delay # delayed check on keypress


  delayedCheck: =>
    clearTimeout @delayId                     # Cancel the previous delay check
    @delayId = setTimeout @runCheck, @get.delay  # Create new setTimeout


  runCheck: =>
    # Uses method described at http://api.jquery.com/deferred.then/ to 
    # accomodate ajax callbacks
    defer = jQuery.Deferred()
    chk   = defer.then => @check()
    defer.resolve()
    chk.done @change_status


  change_status : ( status ) =>
    isCorrect = !!status                      # Bool, kthx
    if @status is isCorrect then return       # Stop if nothing changed
    @status = isCorrect                       # Set the new status
    @msg.toggle @status                       # toggle msg with new status
    jQuery( @ ).trigger 'nod_toggle'          # for Nod