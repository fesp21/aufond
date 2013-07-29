class @Export extends MeteorModel
  ###
    Static export of a User timeline

    Caracteristics of a timeline export
    - An export mustn't have any external dependencies (aka work offline)
    - An export must be static (not served through any routing system)
    - A user can only export its own timeline
    - An export must be created through server methods, in order to be able to
    implement frequency limits and avoid other exploits
    - An export is generated asynchronously and this model reflects its
    reference and progress status

    TODO remove all static assets (both local and from CDN) when destroying an
    export document
  ###
  @mongoCollection: new Meteor.Collection 'exports'

  @allow: ->
    return unless Meteor.isServer
    @mongoCollection.allow
      insert: (userId, doc) ->
        # Only allow logged in users to create documents
        return false unless userId?
        # Don't allow users to create documents on behalf of other users
        return userId is doc.createdBy
      update: (userId, doc, fields, modifier) ->
        # Don't allow users to alter exports (they can only be altered through
        # server methods)
        return false
      remove: (userId, doc) ->
        # Don't allow guests to remove anything
        return false unless userId?
        # The root user can delete any document of any user
        return true if User.find(userId)?.isRoot()
        # Don't allow users to remove other users' documents
        return userId is doc.createdBy

  constructor: (data = {}, isNew = true) ->
    super(arguments...)
    if isNew
      @set
        # Bind the current user to any created export implicitly
        createdBy: Meteor.userId()
        # Provide a default status message
        status: 'Pending...'

  mongoInsert: (callback) ->
    super (error, model) ->
      callback(arguments...) if _.isFunction(callback)
      unless error?
        # Start generating timeline export if the model was saved successfully
        Meteor.call('generateExport', model.get('_id'))

  getUser: ->
    ###
      Proxy for fetching the User document of the Export author
    ###
    return User.find(@get('createdBy'))

  getUsername: ->
    ###
      Proxy for fetching the username of the Export author
    ###
    return @getUser().get('username')


Export.publish('exports')
Export.allow()