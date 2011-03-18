// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {
  $('.flash .close').click(function() {
    $(this).parent('.flash').hide('blind').remove();
  });
});
