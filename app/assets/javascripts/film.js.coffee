class Film
  @document_ready: ->
    $('body').on('click', '#login-form-btn', Film.show_login_form)
    $('body').on('click', '#cancel_btn', Film.hide_login_form)

  @show_login_form: ->
    if $('#login_form2').hasClass('hide')
      $('#login_form2').removeClass('hide')
    else
      window.location.href = '/'
      console.log("login form is already visible")

  @hide_login_form: ->
    window.location.href = '/'

$(document).ready(Film.document_ready)
