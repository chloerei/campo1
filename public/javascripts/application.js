// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function active_flash_close() {
  $('.flash .close').click(function() {
    $(this).parent('.flash').hide('blind', function(){
      $(this).remove();
    })
  });
}

function display_flash(type, message) {
  var message = $('<div class="flash">' + message + '<span class="close">x</span></div>');
  message.addClass(type);
  message.hide();
  $('#mainbar').prepend(message);
  message.show('blind');
  active_flash_close();
}

function show_loading_notice() {
  $('#loading-notice').show();
}
function hide_loading_notice() {
  $('#loading-notice').hide();
}

$(document).ready(function () {
  active_flash_close();
});

function extract_tags(input, preview) {
  var input_element = $('#' + input);
  var preview_element = $('#' + preview);

  input_element.keyup( function() {
      tag_list = $.trim($(this).val()).split(/\s+/).map(function (tag) {
        if (tag !== '') {
          return '<span class="button-like">' + tag + '</span>'; 
        }
      }).join('');
      preview_element.html(tag_list);
  });
}
