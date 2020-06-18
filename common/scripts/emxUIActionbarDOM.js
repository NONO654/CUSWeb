/*!================================================================
 *  JavaScript Actionbar DOM Component
 *  emxUIActionbarDOM.js
 *  Version 1.4
 *  Requires: emxUICore.js, emxUICoreMenu.js
 *  Last Updated: 9-May-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the definition of the actionbar for use in
 *  DOM-compliant Web browsers such as IE and Mozilla. Any page
 *  that uses this file should also link to emxUIActionbar.css
 *  for the appropriate style to show up.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIActionbarDOM.js.rca 1.4 Wed Oct 22 15:48:57 2008 przemek Experimental przemek $
 *=================================================================
 */
var localActionBar = localActionbar = null;
//! Class emxUIActionbar
//!     This object represents an actionbar.
function emxUIActionbar() {
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.innerLayer = null;
        this.items = new Array;
        this.outerLayer = null;
        this.button = null;
        this.layer = null;
        this.menu = null;
        this.isFooter = false;
        this.stylesheet = emxUIActionbar.CSS_FILE;
        this.left = emxUIActionbar.POS_LEFT;
        this.top = emxUIActionbar.POS_TOP;
        this.width = emxUIActionbar.SIZE_WIDTH;
        localActionbar = localActionBar = this;
}
emxUIActionbar.prototype = new emxUIObject;
emxUIActionbar.POS_TOP = 57;
emxUIActionbar.POS_LEFT = 10;
emxUIActionbar.SIZE_WIDTH = 300;
emxUIActionbar.IMG_BULLET = emxUIConstants.DIR_IMAGES + "utilActionbarBullet.gif";
emxUIActionbar.IMG_PREV_ARROW = emxUIConstants.DIR_IMAGES + "utilActionbarLeftArrow.gif";
emxUIActionbar.IMG_NEXT_ARROW = emxUIConstants.DIR_IMAGES + "utilActionbarRightArrow.gif";
emxUIActionbar.IMG_PREV_GRAY_ARROW = emxUIConstants.DIR_IMAGES + "buttonActionbarPrevDisabled.gif";
emxUIActionbar.IMG_NEXT_GRAY_ARROW = emxUIConstants.DIR_IMAGES + "buttonActionbarNextDisabled.gif";
emxUIActionbar.DELAY_BETWEEN = 50;
emxUIActionbar.SCROLL_DISTANCE = 10;
emxUIActionbar.CSS_FILE = emxUICore.getStyleSheet("emxUIActionbar");
//! Public Class Method emxUIActionbar.signalEnd()
//!     This method signals that the scrolling should finish.
emxUIActionbar.signalDone = function _emxUIActionbar_signalDone() {
        localActionbar.endScroll();
};
//! Public Method emxUIActionbar.addItem()
//!     This method adds an item to the actionbar.
emxUIActionbar.prototype.addItem = function _emxUIActionbar_addItem(objItem) {
        this.items.push(objItem);
        objItem.parent = this;
        return objItem;
};
//! Deprecated Public Method emxUIActionbar.addLink()
//!     This method adds an item to the actionbar. This method
//!     is deprecated. Use emxUIActionbar.addItem(new emxUIActionbarItem(...))
//!     instead.
emxUIActionbar.prototype.addLink = function _emxUIActionbar_addLink(strText, strURL, strTarget) {
        this.addItem(new emxUIActionbarItem(null, strText, strURL, strTarget));
};
//! Deprecated Public Method emxUIActionbar.draw()
//!     This method draws the actionbar. This method
//!     is deprecated. Use emxUIActionbar.init() in the page
//!     event handler instead.
emxUIActionbar.prototype.draw = function _emxUIActionbar_draw() {
        var objThis = this;
        emxUICore.addEventHandler(window, "load", function () { objThis.init() });
};
//! Public Method emxUIActionbar.init()
//!     This method draws the actionbar. It should be called in
//!     the page
emxUIActionbar.prototype.init = function _emxUIActionbar_init() {
        if (this.items.length == 0) return;
        this.outerLayer = document.createElement("div");
        this.outerLayer.className = "actionbar-outer";
        this.outerLayer.style.position = "absolute";
        this.outerLayer.style.overflow = "hidden";
        this.outerLayer.style.visibility = "hidden";
        this.innerLayer = document.createElement("div");
        this.innerLayer.className = "actionbar-inner";
        this.innerLayer.style.marginLeft = "0px";
        this.innerLayer.innerHTML = "<table border=\"0\" class=\"actionbar-inner\" cellpadding=\"0\" cellspacing=\"0\"><tbody><tr></tr></tbody></table>";
        this.outerLayer.appendChild(this.innerLayer);
        for (var i=0; i < this.items.length; i++) {
                this.innerLayer.childNodes[0].rows[0].appendChild(this.items[i].createActionDOM());
        }
        document.body.appendChild(this.outerLayer);
        emxUICore.moveTo(this.outerLayer, this.left, this.top);
        if (isMinIE55 && isWin) {
                this.isFooter = (this.top == 10);
                var i = -1, intWidth = 0;
                while(intWidth < this.width && i < this.items.length-1) {
                        intWidth += this.items[++i].element.offsetWidth;
                }
                if (intWidth > this.width) {
                        for (var j=i; j < this.items.length; j++) {
                               this.innerLayer.childNodes[0].rows[0].removeChild(this.innerLayer.childNodes[0].rows[0].lastChild);
                        }
                        this.button = document.createElement("td");
                        this.button.className = "action-menu-button";
                        this.button.innerHTML = "&nbsp;";
                        this.button.onmouseover = function () { this.className = "action-menu-button-hover"; };
                        this.button.onmouseout = function () { this.className = "action-menu-button"; };
                        this.innerLayer.childNodes[0].rows[0].appendChild(this.button);
                        var objThis = this;
                        if (this.isFooter) {
                                this.button.onclick = function () { objThis.menu.show(-1, -objThis.menu.finalHeight, objThis.button); };
                        } else {
                                this.button.onclick = function () { objThis.menu.show(-1, objThis.button.offsetHeight, objThis.button); };
                        }
                        this.menu = new emxUIActionbarMenu(this);
                        for (var j=i; j < this.items.length; j++) {
                                this.menu.addItem(this.items[j]);
                        }
                        this.menu.init();
                }
        } else {
                this.outerLayer.style.width = this.width + "px";
                if (this.width < this.innerLayer.childNodes[0].offsetWidth && this.items.length > 1) {
                        this.nextButton = document.createElement("div");
                        this.nextButton.style.position = "absolute";
                        this.nextButton.className = "action-next";
                        this.nextButton.oncontextmenu = cancelEvent;
                        this.nextButton.style.position = "absolute";
                        this.nextButton.innerHTML = "<img src=\"" + emxUIActionbar.IMG_NEXT_ARROW + "\" border=\"0\" />";
                        emxUICore.moveTo(this.nextButton, this.left + this.outerLayer.offsetWidth + 16, this.top);
                        document.body.appendChild(this.nextButton);
                        this.prevButton = document.createElement("div");
                        this.prevButton.style.position = "absolute";
                        this.prevButton.className = "action-prev";
                        this.prevButton.oncontextmenu = cancelEvent;
                        this.prevButton.style.position = "absolute";
                        this.prevButton.innerHTML = "<img src=\"" + emxUIActionbar.IMG_PREV_ARROW + "\" border=\"0\" />";
                        emxUICore.moveTo(this.prevButton, this.left + this.outerLayer.offsetWidth, this.top);
                        document.body.appendChild(this.prevButton);
                        var objThis = this;
                        this.nextButton.onmousedown = function () { objThis.scroll(false); };
                        this.nextButton.onmouseup = function () { objThis.endScroll() };
                        this.prevButton.onmousedown = function () { objThis.scroll(true); };
                        this.prevButton.onmouseup = function () { objThis.endScroll() };
                }
        }
        emxUICore.show(this.outerLayer);
};
//! Public Method emxUIActionbar.scroll()
//!     This method scrolls the actionbar.
emxUIActionbar.prototype.scroll = function _emxUIActionbar_scroll(blnRight) {
        var objThis = this;
        if (isIE && isWin) {
                if (blnRight) {
                        this.prevButton.setCapture();
                } else {
                        this.nextButton.setCapture();
                }
        } else if (isMoz) {
                window.addEventListener("mouseup", emxUIActionbar.signalDone, true);
        }
        var intStop = blnRight ? 0 : -(this.innerLayer.childNodes[0].offsetWidth - this.outerLayer.offsetWidth);
        var intIncrement = blnRight ? emxUIActionbar.SCROLL_DISTANCE : -emxUIActionbar.SCROLL_DISTANCE;
        if (parseInt(this.innerLayer.style.marginLeft) != intStop) {
                if (Math.abs(parseInt(this.innerLayer.style.marginLeft) - intStop) < emxUIActionbar.SCROLL_DISTANCE){
                        this.innerLayer.style.marginLeft = intStop + "px";
                } else {
                        this.innerLayer.style.marginLeft = (parseInt(this.innerLayer.style.marginLeft) + intIncrement) + "px";
                }
                this.timeoutID = setTimeout("localActionbar.scroll(" + blnRight + ")", emxUIActionbar.DELAY_BETWEEN);
        } else {
                this.endScroll();
        }
};
//! Public Method emxUIActionbar.endScroll()
//!     This method stops the scroll of the actionbar.
emxUIActionbar.prototype.endScroll = function _emxUIActionbar_endScroll() {
        if (isIE && isWin) {
                this.prevButton.releaseCapture();
                this.nextButton.releaseCapture();
        } else if (isMoz) {
                window.removeEventListener("mouseup", emxUIActionbar.signalDone, true)
        }
        clearTimeout(this.timeoutID);
        switch (parseInt(this.innerLayer.style.marginLeft)) {
                case 0:
                        this.prevButton.src = emxUIActionbar.IMG_PREV_GRAY_ARROW;
                        this.nextButton.src = emxUIActionbar.IMG_NEXT_ARROW;
                        break;
                case -(this.innerLayer.childNodes[0].offsetWidth - this.outerLayer.offsetWidth):
                        this.prevButton.src = emxUIActionbar.IMG_PREV_ARROW;
                        this.nextButton.src = emxUIActionbar.IMG_NEXT_GRAY_ARROW;
                        break;
                default:
                        this.prevButton.src = emxUIActionbar.IMG_PREV_ARROW;
                        this.nextButton.src = emxUIActionbar.IMG_NEXT_ARROW;
        }
};
//! Class emxUIActionbarSeparator
function emxUIActionbarSeparator () {
        this.superclass = emxUICoreMenuSeparator;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUIActionbarSeparator";
}
emxUIActionbarSeparator.prototype = new emxUICoreMenuSeparator;
//! Class emxUIActionbarItem
//!     This object represents an actionbar item.
function emxUIActionbarItem(strIcon, strText, strURL, strTarget) {
        this.superclass = emxUICoreMenuLink;
        this.superclass(strText, strURL, strTarget);
        delete this.superclass;
        this.element = null;
        this.icon = strIcon ? emxUICore.getIcon(strIcon) : null;
        this.target = strTarget;
        this.text = strText;
        this.url = strURL;
}
emxUIActionbarItem.prototype = new emxUICoreMenuLink;
//! Private Method emxUIActionbarItem.click()
//!     This method simulates a click on the link.
emxUIActionbarItem.prototype.click = function _emxUIActionbarItem_click() {
        emxUICore.link(this.url, this.target);
        this.reset();
};
//! Private Method emxUIActionbarItem.createActionDOM()
//!     This method gets the DOM to represent this item.
emxUIActionbarItem.prototype.createActionDOM = function _emxUIActionbarItem_createActionDOM() {
        this.element = document.createElement("td");
        this.element.className = this.icon ? "iconaction" : "action";
        var objThis = this;
        this.element.onclick = function () { objThis.click() };
        this.element.onmouseover = function () { this.className = objThis.icon ? "iconaction-hover" : "action-hover"; };
        this.element.onmouseout = function () { this.className = objThis.icon ? "iconaction" : "action"; };
        this.element.style.backgroundImage = "url(" + this.icon + ")";
        this.element.style.backgroundRepeat = "no-repeat";
        this.element.noWrap = "nowrap";
        this.element.innerHTML = this.text;
        return this.element;
};
//! Private Method emxUIActionbarItem.createDOM()
//!     This method creates the DOM representation of the link.
emxUIActionbarItem.prototype.createDOM = function _emxUIActionbarItem_createDOM(objDoc) {
        this.emxUICoreMenuItemCreateDOM(objDoc);
        this.rowElement.setAttribute("menuType", MENU.LINK);
        this.rowElement.className = "menu-item";
        var objTD = objDoc.createElement("td");
        if (this.icon) {
                objTD.style.backgroundImage = "url(" + this.icon + ")";
                objTD.style.backgroundRepeat = "no-repeat";
                objTD.noWrap = "nowrap";
        }
        objTD.className = "menu-label";
        objTD.innerHTML = this.text;
        this.rowElement.appendChild(objTD);
        return this.rowElement;
};
//! Private Method emxUIActionbarItem.reset()
//!     This method resets the view of the menu link.
emxUIActionbarItem.prototype.reset = function _emxUIActionbarItem_reset() {
        if (this.rowElement) {
                this.rowElement.className = "menu-item";
        } else {
                this.element.className = this.icon ? "iconaction" : "action";
        }
};
//! Class emxUIActionbarMenu
//!     This object represents an actionbar as a pop up menu.
function emxUIActionbarMenu(objActionbar) {
        this.superclass = emxUICorePopupMenu;
        this.superclass();
        delete this.superclass;
        this.actionbar = objActionbar;
        this.cssClass = "actionbar";
        this.emxClassName = "emxUIActionbarMenu";
        this.stylesheet = this.actionbar.stylesheet;
}
emxUIActionbarMenu.prototype = new emxUICorePopupMenu;
//! Private Method emxUIActionbarMenu.show()
//!     This method shows the menu.
emxUIActionbarMenu.prototype.show = function _emxUIActionbarMenu_show(intX, intY, objRef) {
        var objThis = this;
        if (isMinIE55 && isWin) {
                this.menu.show(intX, intY, this.templateInnerLayer.offsetWidth, this.finalHeight, objRef);
                this.timeoutID = setTimeout(function () {
                        if (objThis.menu.isOpen) {
                                objThis.timeoutID = setTimeout(arguments.callee, MENU.WATCH_DELAY);
                        } else {
                                objThis.hide();
                        }
                }, MENU.WATCH_DELAY);
        } else {
                var intFinalX = intX + this.layer.offsetWidth;
                var intFinalY = intY + this.layer.offsetHeight;
                if (intFinalX > document.body.scrollLeft + emxUICore.getWindowWidth()) {
                        intX = document.body.scrollLeft + emxUICore.getWindowWidth() - this.layer.offsetWidth;
                } else if (intX < 0) {
                        intX = 0;
                }
                if (intFinalY > document.body.scrollTop + emxUICore.getWindowHeight()) {
                        intY = document.body.scrollTop + emxUICore.getWindowHeight() - this.layer.offsetHeight;
                }
                emxUICore.moveTo(this.layer, intX, intY);
                emxUICore.show(this.layer);
                var fnTemp = function () { objThis.hide(); };
                window.addEventListener("blur", fnTemp, true);
                window.addEventListener("click", fnTemp, true);
        }
        this.visible = true;
        this.fireEvent("show");
};
function jsActionBar() {
	return new emxUIActionbar;
}
