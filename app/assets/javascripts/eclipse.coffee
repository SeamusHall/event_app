$(document).on "turbolinks:load", ->

  $.ajaxSetup
    beforeSend: (xhr) -> xhr.setRequestHeader('Accept', 'text/javascript')

  $('.selectpicker').selectpicker
    # style: 'btn-info'
    size: 4

  $('form.new_order')
    .bind 'ajax:beforeSend', ->
      event.preventDefault()
      # $($(@).data('target')).empty()
      $($(@).data('rel')).append spin
    .bind 'ajax:success', (event, data, status, xhr) ->
      rel = $(@).data('rel')
      target = $(@).data('target')

      console.log('success')

      $('.fancy-spinner').fadeOut 200, ->
        $(@).remove()
    .bind 'ajax:error', (xhr, data, status) ->
      rel = $(@).data('rel')
      target = $(@).data('target')

      console.log(data.responseJSON);
      # target.html(data.responseJSON)
      htmlResponse = "<div class='alert alert-danger'>Error(s) occured while saving the Order</br></br>"
      for field, errors of data.responseJSON
        for error in errors
          htmlResponse += ('<strong>' + field + '</strong>' + ': ' + error + '</br>')
      htmlResponse += '</div>'
      $(target).html(htmlResponse);

    .bind 'ajax:complete', ->
      $('.fancy-spinner').fadeOut 200, ->
        $(@).remove()

spin = -> return "<div class='fancy-spinner' style='position: absolute !important; left: 0px; width: 100%; height: 100%; margin-top: 10px'><h2 class='center'><i class='fa fa-circle-o-notch fa-spin'></i></h2></div>"
