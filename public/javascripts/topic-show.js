function append_mention(name) {
  $('#editor-input').val($('#editor-input').val() + '@' + name + ' ');
  $('#editor-input').focus();
  $('#editor-input').position($('#editor-input').val().length);
};

$(function() {
  $(".content img").aeImageResize({width: 600});
  $(".content img").each(function() {
    if ($(this).parent('a').length == 0) {
      var src = $(this).attr('src');
      var a = $('<a/>').attr('href', src).attr('target', '_blank').attr('class', 'fancybox');
      $(this).wrap(a);
    }
  });
  $(".content .fancybox").fancybox({
    'autoScale'          : false,
    'hideOnContentClick' : true,
    'speedIn'            : 100,
    'speedOut'           : 100
  });

  $('.content a').each(function() {
    if ( $(this).attr('href').match(/http:\/\/v.youku.com\/v_show\/id_([a-zA-Z0-9\=]+).html/) ) {
      $(this).after('<br /><embed src="http://player.youku.com/player.php/sid/' + RegExp.$1 + '/v.swf" quality="high" width="610" height="498" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash"></embed><br />')
    };

    if ( $(this).attr('href').match(/http:\/\/www.tudou.com\/programs\/view\/([a-zA-Z0-9_]+)/) ) {
      $(this).after('<br /><embed src="http://www.tudou.com/v/' + RegExp.$1 + '/v.swf" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" wmode="opaque" width="610" height="498"></embed><br />')
    };
  })
});
