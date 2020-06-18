define('DS/ENOChgActionGridUX/scripts/Wrapper/ChgSplitViewWrapper', [
    'DS/ENOXSplitView/js/ENOXSplitView'
],
  function(ENOXSplitView) {
        var ENOXSplitViewWrapper = ENOXSplitView;

        ENOXSplitViewWrapper.prototype.getLeftViewWrapper = function () {
            return UWA.extendElement(this.getLeft());
        }

        ENOXSplitViewWrapper.prototype.getRightViewWrapper = function () {
            return UWA.extendElement(this.getRight());
        }

        ENOXSplitViewWrapper.prototype.addRightCloseButton = function(){
            if(this._rightPanel != null){
                var closer = UWA.createElement("div",{
                    "class":"splitview-close fonticon fonticon-expand-left",
          "title": "Close",
          'styles': {
            'font-size': '20px'
          }
                });
                closer.inject(this._rightPanel);
                var me = this;
                closer.onclick = function(e){
          me._hideSide("left");
                    me._rightPanel.classList.remove("right-container-mobile-view");
          var expandLeft = document.querySelector('.fonticon-expand-left');
          if (expandLeft) {
            expandLeft.removeClassName('fonticon-expand-left');
            expandLeft.addClassName('fonticon-expand-right');
          } else {
            var expandRight = document.querySelector('.fonticon-expand-right');
            me._showSide("left");
            expandRight.removeClassName('fonticon-expand-right');
            expandRight.addClassName('fonticon-expand-left');
                    }
          //me._rightPanel.removeClassName("right-container-mobile-view");
                }
            }
        }
		document.addEventListener('touchstart', handleTouchStart, false);
document.addEventListener('touchmove', handleTouchMove, false);

var xDown = null;
var yDown = null;

function getTouches(evt) {
  return evt.touches ||             // browser API
         evt.originalEvent.touches; // jQuery
}

function handleTouchStart(evt) {
    const firstTouch = getTouches(evt)[0];
    xDown = firstTouch.clientX;
    yDown = firstTouch.clientY;
};

function handleTouchMove(evt) {
    if ( ! xDown || ! yDown ) {
        return;
    }

    var xUp = evt.touches[0].clientX;
    var yUp = evt.touches[0].clientY;

    var xDiff = xDown - xUp;
    var yDiff = yDown - yUp;

      if (Math.abs(xDiff) > Math.abs(yDiff)) {
        /*most significant*/
        if ( xDiff > 0 ) {
          /* left swipe */
        } else {

          jQuery('.splitview-close').click();

        }
    } else {
        if ( yDiff > 0 ) {
            /* up swipe */
        } else {
            /* down swipe */
        }
    }
    /* reset values */
    xDown = null;
    yDown = null;
};


        return ENOXSplitViewWrapper;
    });
