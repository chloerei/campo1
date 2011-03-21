// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function active_flash_close() {
  $('.flash .close').click(function() {
    $(this).parent('.flash').hide('blind').remove();
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

if (history && history.pushState) {
  var loaded = false;
  $(window).bind("popstate", function() {
    if (!loaded) {
      loaded = true;
    } else {
      show_loading_notice();
      $.getScript(location.href, function(){
        hide_loading_notice();
      });
    }
  });
}
