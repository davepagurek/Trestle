function insertAtCaret(areaId,text) {
    var txtarea = document.getElementById(areaId);
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );
    if (br == "ie") {
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -txtarea.value.length);
        strPos = range.text.length;
    }
    else if (br == "ff") strPos = txtarea.selectionStart;

    var front = (txtarea.value).substring(0,strPos);
    var back = (txtarea.value).substring(strPos,txtarea.value.length);
    txtarea.value=front+text+back;
    strPos = strPos + text.length;
    if (br == "ie") {
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -txtarea.value.length);
        range.moveStart ('character', strPos);
        range.moveEnd ('character', 0);
        range.select();
    }
    else if (br == "ff") {
        txtarea.selectionStart = strPos;
        txtarea.selectionEnd = strPos;
        txtarea.focus();
    }
    txtarea.scrollTop = scrollPos;
}
window.addEventListener("load", function() {
    document.getElementById("spellcheck").addEventListener("change", function(e) {
        if (document.getElementById("spellcheck").checked) {
            document.getElementById("content").spellcheck = true;
        } else {
            document.getElementById("content").spellcheck = false;
        }
        var txt = document.getElementById("content").value;
        document.getElementById("content").value = "";
        document.getElementById("content").value = txt;
    });

    document.getElementById("content").addEventListener("keydown", function(e) {
        var keyCode = e.keyCode || e.which;
        if (keyCode == 9) {
           e.preventDefault();
           insertAtCaret("content", "\t");
        }
    });
});
