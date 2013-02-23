class PostModal extends Modal

  constructor: ->
    super(arguments...)

    @reactiveBody = new Form
      templateName: 'post_form'
      model: Entry

    # Submit the form on modal submit, which closes the modal on success
    @onSubmit = =>
        @reactiveBody.submit => @close()

    # XXX create global reference in order for it to be used from anywhere
    Aufond.postModal = this

  update: (data) ->
    # Extract id attribute from data and load post data inside the form based
    # on it, before updating the modal template
    @loadPost(data.id)
    super(data)

  loadPost: (id) ->
    ###
      Load post entry inside the contained form
    ###
    @reactiveBody.load(id)