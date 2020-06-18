/**
 * jQuery plugin for Pretty looking right click context menu.
 *
 * Requires popup.js and popup.css to be included in your page. And jQuery, obviously.
 *
 * Usage:
 *
 *   $('.something').contextPopup({
 *     title: 'Some title',
 *     items: [
 *       {label:'My Item', icon:'/some/icon1.png', action:function() { alert('hi'); }},
 *       {label:'Item #2', icon:'/some/icon2.png', action:function() { alert('yo'); }},
 *       null, // divider
 *       {label:'Blahhhh', icon:'/some/icon3.png', action:function() { alert('bye'); }},
 *     ]
 *   });
 *
 * Icon needs to be 16x16. I recommend the Fugue icon set from: http://p.yusukekamiyamane.com/ 
 *
 * - Joe Walnes, 2011 http://joewalnes.com/
 *   https://github.com/joewalnes/jquery-simple-context-menu
 *
 * MIT License: https://github.com/joewalnes/jquery-simple-context-menu/blob/master/LICENSE.txt
 */

if (typeof ($simjq) == 'undefined'){
	var $simjq = jQuery.noConflict();
}


jQuery.fn.contextPopup = function(menuData) {
	// Define default settings
	var settings = {
		contextMenuClass: 'contextMenuPlugin',
		gutterLineClass: 'gutterLine',
		headerClass: 'header',
		seperatorClass: 'divider',
		title: '',
		items: []
	};
	
	// merge them
	$simjq.extend(settings, menuData);

  // Build popup menu HTML
  function createMenu(e) {
    var menu = $simjq('<ul class="' + settings.contextMenuClass + '"><div class="' + settings.gutterLineClass + '"></div></ul>')
      .appendTo(document.body);
    if (settings.title) {
      $simjq('<li class="' + settings.headerClass + '"></li>').text(settings.title).appendTo(menu);
    }
    settings.items.forEach(function(item) {
      if (item) {
        var rowCode = '<li><a href="#"><span></span></a></li>';
        // if(item.icon)
        //   rowCode += '<img>';
        // rowCode +=  '<span></span></a></li>';
        var row = $simjq(rowCode).appendTo(menu);
        var iconType;
        if(item.icon){
        	
        	//Make sure item.iconType is defined as something.
        	item.iconType = item.iconType || "";
        	
        	//Allow for functional icon type
        	if(typeof item.iconType == "string" || item.iconType instanceof String){
        		iconType = item.iconType;
        	} else {
        		iconType = item.iconType(); 
        	};
        	
        	if(iconType == "jquery"){
        		var icon = $simjq('<div class="sim-ui-contextMenuIcon ui-icon">');
        		icon.addClass(item.icon);
        		
        	} else {
				var icon = $simjq('<img>');
				icon.attr('src', item.icon);
        	};
        	
        	icon.insertBefore(row.find('span'));
        };
        
        //Added check to allow for functional computation of labels
        if(typeof item.label == "string" || item.label instanceof String){
        	row.find('span').text(item.label);
        } else {
        	row.find('span').text(item.label());
        };
        
        
        if (item.action) {
          row.find('a').click(function(){ item.action(e); });
        }
      } else {
        $simjq('<li class="' + settings.seperatorClass + '"></li>').appendTo(menu);
      }
    });
    menu.find('.' + settings.headerClass ).text(settings.title);
    return menu;
  }

  // On contextmenu event (right click)
  this.bind('contextmenu', function(e) {	
    var menu = createMenu(e)
      .show();
    
    var left = e.pageX + 5, /* nudge to the right, so the pointer is covering the title */
        top = e.pageY;
    if (top + menu.height() >= $simjq(window).height()) {
        top -= menu.height();
    }
    if (left + menu.width() >= $simjq(window).width()) {
        left -= menu.width();
    }

    // Create and show menu
    menu.css({zIndex:1000001, left:left, top:top})
      .bind('contextmenu', function() { return false; });

    // Cover rest of page with invisible div that when clicked will cancel the popup.
    var bg = $simjq('<div></div>')
      .css({left:0, top:0, width:'100%', height:'100%', position:'absolute', zIndex:1000000})
      .appendTo(document.body)
      .bind('contextmenu click', function() {
        // If click or right click anywhere else on page: remove clean up.
        bg.remove();
        menu.remove();
        return false;
      });

    // When clicking on a link in menu: clean up (in addition to handlers on link already)
    menu.find('a').click(function() {
      bg.remove();
      menu.remove();
    });

    // Cancel event, so real browser popup doesn't appear.
    return false;
  });

  return this;
};

jQuery.fn.refreshContextPopup = function(menuData) {
	this.unbind('contextmenu');
	this.contextPopup(menuData);
}
