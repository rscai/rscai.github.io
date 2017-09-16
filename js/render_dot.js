$(document).ready(function(){
    render_dot();
 });

 var render_dot = function(){
    $(".language-dot").each(function () {
        var u1 = $(this).parent().attr("custom-rendered");
        if (u1!=null) return;
        var u2 = $(this).html();
        if (u2=="") return;
        console.debug(decodeHtml(u2));
        var s = decodeHtml(u2);
        var svg = Viz(s);
        $(this).parent().attr("custom-rendered",true);
        $(this).css("display","none");
        var wrapper = $("<div class='diagram-dot'></div>");
        wrapper.append(svg);
        $(this).parent().append(wrapper);
    });
 };

 function decodeHtml(encodedContent){
    return encodedContent.replace(/&lt;/gi,'<').replace(/&gt;/gi,'>');
 }