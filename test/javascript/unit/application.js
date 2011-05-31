module("application.js");

test("should extract topic tags", function() {
    same($("#topic_tags").val(), '');
    same($("#topic_tags_preview").html(), '');
    extract_tags("topic_tags", "topic_tags_preview");
    $("#topic_tags").val('tag').keyup();
    same($("#topic_tags_preview").html(), '<span class="button-like">tag</span>');
    $("#topic_tags").val('tag tag2').keyup();
    same($("#topic_tags_preview").html(), '<span class="button-like">tag</span><span class="button-like">tag2</span>');
    $("#topic_tags").val('').keyup();
    same($("#topic_tags_preview").html(), '');
});
