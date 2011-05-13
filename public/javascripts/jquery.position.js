$.fn.extend({

        //获取和设置光标位置

        position:function( value ){
                var elem = this[0];
                if (elem&&(elem.tagName=="TEXTAREA"||elem.type.toLowerCase()=="text")) {
                        if($.browser.msie){
                                var rng;
                                if(elem.tagName == "TEXTAREA"){
                                        rng = elem.createTextRange();
                                }else{
                                        rng = document.selection.createRange();
                                }
                                if( value === undefined ){
                                        rng.moveStart("character",-elem.value.length);
                                        return  rng.text.length;
                                }else if(typeof value === "number" ){
                                        var index=this.position();
                                        rng.moveStart("character",value)
                                        rng.moveEnd("character",value-index+1)
                                        rng.select();
                                }
                        }else{
                                if( value === undefined ){
                                        return elem.selectionStart;
                                }else if(typeof value === "number" ){
                                        elem.selectionEnd = value;
                                        elem.selectionStart = value;
                                }
                        }
                }else{
                        if( value === undefined )
                                return undefined;
                }
        },

        //初始化对象以支持光标处插入内容

        setCaret: function(){
                if(!$.browser.msie) return;
                var initSetCaret = function(){
                        var textObj = $(this).get(0);
                        textObj.caretPos = document.selection.createRange().duplicate();
                };
                $(this)
                .click(initSetCaret)
                .select(initSetCaret)
                .keyup(initSetCaret);
        },

        //在当前对象光标处插入指定的内容

        insertAtCaret: function(textFeildValue){
                var textObj = $(this).get(0);
                if(document.all && textObj.createTextRange && textObj.caretPos){
                        var caretPos=textObj.caretPos;
                        caretPos.text = caretPos.text.charAt(caretPos.text.length-1) == '' ?
                        textFeildValue+'' : textFeildValue;
                }
                else if(textObj.setSelectionRange){
                        var rangeStart=textObj.selectionStart;
                        var rangeEnd=textObj.selectionEnd;
                        var tempStr1=textObj.value.substring(0,rangeStart);
                        var tempStr2=textObj.value.substring(rangeEnd);
                        textObj.value=tempStr1+textFeildValue+tempStr2;
                        textObj.focus();
                        var len=textFeildValue.length;
                        textObj.setSelectionRange(rangeStart+len,rangeStart+len);
                        textObj.blur();
                }
                else {
                        textObj.value+=textFeildValue;
                }
        }
})

