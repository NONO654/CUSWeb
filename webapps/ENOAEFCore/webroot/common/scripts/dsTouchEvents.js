function touchHandler(event) {
    var touches = event.changedTouches, first = touches[0], type = "";
    switch (event.type) {
    case "touchstart":
        type = "mousedown";
        break;
    case "touchmove":
        type = "mousemove";
        break;
    case "touchend":
        type = "mouseup";
        break;
    default:
        return;
    }
    if(document.getElementById("searchContainer") === null || document.getElementById("searchContainer").style.display === "none"){
    var simulatedEvent = document.createEvent("MouseEvent");
    simulatedEvent.initMouseEvent(type, true, true, window, 1, first.screenX,
            first.screenY, first.clientX, first.clientY, false, false, false,
            false, 0/*left*/, null);

    first.target.dispatchEvent(simulatedEvent);
    //event.preventDefault();
}
}

function is_touch_device() {
  return ('ontouchstart' in window) // works on most browsers 
      || window.navigator.msMaxTouchPoints; // works on ie10
};

function init($) {
    // Detect touch support
    if (!is_touch_device()) {
      return;
    }
    document.addEventListener("touchstart", touchHandler, true);
    document.addEventListener("touchmove", touchHandler, true);
    document.addEventListener("touchend", touchHandler, true);
    document.addEventListener("touchcancel", touchHandler, true);
}

//-webkit-touch-callout
//onload initialization
jQuery(document).ready(function ($) {
    try {
        init(jQuery);
    } catch (e) {
        alert(e);
    }
});
