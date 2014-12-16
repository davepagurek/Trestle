var hide = function(element) {
    element.style.overflow = "hidden";
    element.style.height = getComputedStyle(element).height;
    element.style.transition = 'all .5s ease';
    element.offsetHeight = "" + element.offsetHeight; // force repaint
    element.style.height = '0';
    element.style.marginTop = "0";
    element.style.marginBottom = "0";
};
var show = function(element) {
    var prevHeight = element.style.height;
    element.style.height = 'auto';
    var endHeight = getComputedStyle(element).height;
    element.style.height = prevHeight;
    element.offsetHeight = "" + element.offsetHeight; // force repaint
    element.style.transition = 'all .5s ease';
    element.style.height = endHeight;
    element.style.marginTop = "";
    element.style.marginBottom = "";
    element.addEventListener('transitionend', function transitionEnd(event) {
        if (event.propertyName == 'height' && this.style.height == endHeight) {
            this.style.transition = '';
            this.style.height = 'auto';
            this.style.overflow = "visible";
        }
        this.removeEventListener('transitionend', transitionEnd, false);
    }, false);
};


window.addEventListener("load", function() {
    var elements = document.querySelectorAll("ul.dirlist li.dir");
    Array.prototype.forEach.call(elements, function(element) {
        element.addEventListener("click", function() {
            if (element.className.indexOf("open") != -1) {
                element.classList.remove("open");
                element.classList.add("closed");
                hide(element.querySelector("ul"));
            } else {
                element.classList.remove("closed");
                element.classList.add("open");
                show(element.querySelector("ul"));
            }
        })
    });
});
