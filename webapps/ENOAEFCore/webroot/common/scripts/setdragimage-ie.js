/*global DataTransfer, DragEvent */

/*! setDragImage-IE - polyfill for setDragImage method for Internet Explorer 10+
 https://github.com/MihaiValentin/setDragImage-IE */

/**
 * this method preloads the image, so it will be already loaded when we will use it as a drag image
 * @param image
 */
window.setDragImageIEPreload = function(image) {
    var bodyEl,
        preloadEl;

    bodyEl = document.body;

    // create the element that preloads the  image
    preloadEl = document.createElement('div');
    preloadEl.style.background = 'url("' + image.src + '")';
    preloadEl.style.position = 'absolute';
    preloadEl.style.opacity = 0.001;

    bodyEl.appendChild(preloadEl);

    // after it has been preloaded, just remove the element so it won't stay forever in the DOM
    setTimeout(function() {
        bodyEl.removeChild(preloadEl);
    }, 5000);
};


// if the setDragImage is not available, implement it
if ('function' !== typeof DataTransfer.prototype.setDragImage) {
    DataTransfer.prototype.setDragImage = function(image, eventTarget) {
        for(var i = 0; i < eventTarget.children.length; i++) {
            eventTarget.children[i].style.display = "none";
        }
        eventTarget.appendChild(image);
        setTimeout(function() {
            var elem = document.getElementById('ghost');
            if (elem)
                elem.parentNode.removeChild(elem);
            for(var i = 0; i < eventTarget.children.length; i++) {
                eventTarget.children[i].style.display = "";
            }
        }, 0);
    };
}

