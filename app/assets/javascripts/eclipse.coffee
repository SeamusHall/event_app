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

    active1 = false
    active2 = false
    active3 = false
    active4 = false
    $('.parent2').on 'mousedown touchstart', ->
      if !active1
        $(this).find('.test1').css
          'background-color': 'gray'
          'transform': 'translate(-0px,125px)'
      else
        $(this).find('.test1').css
          'background-color': 'dimGray'
          'transform': 'none'
      if !active2
        $(this).find('.test2').css
          'background-color': 'gray'
          'transform': 'translate(-60px,105px)'
      else
        $(this).find('.test2').css
          'background-color': 'darkGray'
          'transform': 'none'
      if !active3
        $(this).find('.test3').css
          'background-color': 'gray'
          'transform': 'translate(-105px,60px)'
      else
        $(this).find('.test3').css
          'background-color': 'silver'
          'transform': 'none'
      if !active4
        $(this).find('.test4').css
          'background-color': 'gray'
          'transform': 'translate(-125px,0px)'
      else
        $(this).find('.test4').css
          'background-color': 'silver'
          'transform': 'none'
      active1 = !active1
      active2 = !active2
      active3 = !active3
      active4 = !active4
      return
    return
spin = -> return "<div class='fancy-spinner' style='position: absolute !important; left: 0px; width: 100%; height: 100%; margin-top: 10px'><h2 class='center'><i class='fa fa-circle-o-notch fa-spin'></i></h2></div>"
