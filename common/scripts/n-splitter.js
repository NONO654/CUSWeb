/*
* jQuery.nsplitter.js - animated splitter plugin
*
* version 1.0 2010-09-14
* 
*/

/**
 * jQuery.splitter() plugin implements a N-pane resizable animated window, using 
 * existing DIV elements for layout.
 * Based on 2-way splitter from http://krikus.com/js/splitter
 * Adapted to handle N-way splitting (but also dropped some other features)
 *
 * @example $("#splitterContainer").splitter({splitVertical:true});
 * @desc Create a vertical splitter with toggle button
 *
 * @example $("#splitterContainer").splitter({splitVertical:true,slave:$("#rightSplitterContainer")});
 * @desc Create a vertical splitter with toggle button,and bind resize event to the slave element
 *
 * @name splitter
 * @type jQuery
 * @param Object options Options for the splitter (required)
 * @cat Plugins/Splitter
 * @return jQuery
 */

;
// See http://docs.jquery.com/Plugins/Authoring for jquery plugin authoring guidance
(function ($) {
	$.fn.splitter = function (method) {
		if ( methods[method] ) {
		  return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
		} else if ( typeof method === 'object' || ! method ) {
		  return init.apply( this, arguments );
		} else {
		  $.error( 'Method ' +  method + ' does not exist' );
		}    
	};

	// public methods (aside from the initializer)
	var methods = {
		pause: function () { 
			return this.each(function() {
				$(this).data('splitter').paused = true; 
			});
		},
		resume: function () { 
			return this.each(function() {
				$(this).data('splitter').paused = false; 
			});
		},
		isPaused: function () { 
			return $(this[0]).data('splitter').paused;
		}
	}
	
	var _divAboveIframes; //catches events when dragging over iframes
	var _ghost; //splitbar  ghosted element 
	var _ismovingNow = false; // animaton state flag
	var _splitPerc;
	var _statusBarWidth;
	var _splitBarWidth=11;
	var _isMultiPaneView;

	function minSize(pane) {
		return parseInt($(pane).attr("minsize")  || "0");
	}
	
	function init(args) {
        return this.each(function () {
			// Default opts
			var defaults = {
                ghostClass: 'working',
                // class name for _ghosted splitter and hovered button
                invertClass: 'invert',
                //class name for invert splitter button
                animSpeed: 250, //animation speed in ms
				fit: true // total size of panes must fit within window
            };
			
			var orientation = args.splitHorizontal ? 'h' : 'v';
			var orientationParams = {
                v: { // Vertical
                    moving: "left",
                    sizing: "width",
                    eventPos: "pageX",
                    splitbarClass: "splitbarV",
                    buttonClass: "splitbuttonV",
                    cursor: "e-resize"
                },
                h: { // Horizontal 
                    moving: "top",
                    sizing: "height",
                    eventPos: "pageY",
                    splitbarClass: "splitbarH",
                    buttonClass: "splitbuttonH",
                    cursor: "n-resize"
                }
            }[orientation];
			
			// Merge all of the above settings into opts
            var opts = $.extend(defaults, orientationParams, args);

            var splitter = $(this);
            var slave = opts.slave; //optional, elemt forced to receive resize event

            var panes = $(">*", splitter).not(".pv-col.closed-cols"); // all children become panes
			
			if (!opts.fit) {
				// create a dummy "pane" so last "real" pane will have a splitter after it
				panes.last().append($("<div style='height:11px'></div>"));
				panes = $(">*", splitter).not(".pv-col.closed-cols");
			}
			
			var splitbars = $();

			// create a record of parameters specific to each splitbar
			function mkSplitContext(splitbar) {
				var A = $(splitbar[0].previousSibling);
				var B = $(splitbar[0].nextSibling);
				if(B[0].className == "pv-col closed-cols hidden" || B[0].className == "pv-col closed-cols"){
					B= $(splitbar[0].nextSibling.nextSibling);
				}
				
				var splitPos = B.position()[opts.moving] - splitter.offset()[opts.moving] ;
				var container = getPVContainerSize(opts.sizing);
				var splitPercent = splitPos / container * 100;
				if($(A).attr("class")=="pv-col"){
					B.css("float","left");
				}
				
				return {
					// This group of settings pertains to the entire splitter
					splitter: splitter,
					opts: opts,
					panes: panes,
					splitbars: splitbars,

					// this group of settings is specific to this one splitbar, 
					// and the two adjacent panes (A and B) on either side of it
					splitPos: splitPos,
					splitPercent: splitPercent,
					A: A,
					B: B,
					minA: minSize(A),
					minB: minSize(B)
				}
			}
			if(panes.length >= 3){
				_isMultiPaneView = true;
			}
			for (var i = 0; i < panes.length - 1; i++) {
//				(function() { // BEGIN PER-PANE CLOSURE
					//Create splitbar 
					var splitbar = $('<div><span></span></div>');					
					$(panes[i]).after(splitbar);
					
					splitbars = splitbars.add(splitbar);
					
					var context = mkSplitContext(splitbar);
					splitbar.data('splitter', context);
					
					
					if(panes.length>2 && i==panes.length-2){						
						$(".hide-pv-col-button",panes[i+1]).click(function() {
							localStorage.setItem(this.id, false);							
							
							var currentCol = $(this).parents(".pv-col");							
							if(currentCol.size()==0){
								currentCol = $(this).parents(".pv-channel");
							}
							
							currentCol.css("display","none");
							currentCol.prev(".pv-col.closed-cols").toggleClass('hidden').children(".rotate90").empty();//vertical status bar
							currentCol.prev(".pv-col.closed-cols").prev(".splitbarV").css("display","none");//vertical splitter
							
							
							$(this).parents(".pv-col, .pv-channel").find(".tab-active").each(function(){
								var activeTabName = $(this).attr("title");
								$(this).parents(".pv-col, .pv-channel").prev().children(".rotate90").append('<button class="show-pv-col">'+activeTabName+'</button>');								
							});
							
							var size = getPVContainerSize("width");							
							var splitpos = splitbar.data("splitter").splitPos;
							_statusBarWidth = $(".pv-col.closed-cols").width()+3;
							var end = size-_statusBarWidth;
						
							toggelChannel(splitter, splitbar, (splitpos==end)?splitpos:end, true);
							_splitPerc = (splitpos/size)*100;
							
						});						
						
						$(panes[i+1]).prev().click(function(){
							$(this).toggleClass('hidden');							
							var currentCol = $(this).next(".pv-col");
							if(currentCol.size()==0){
								currentCol = $(this).next(".pv-channel");
							}
							localStorage.setItem("col-"+currentCol.find(".tab-inactive, .tab-active").first().attr("title"),true);
							var splitter = $(this).prev();							
							splitter.css("display","");
							
							var size = getPVContainerSize("width");							
							var splitpos = splitbar.data("splitter").splitPos;
							
							var splitPercPos = (size * _splitPerc) /100;
							toggelChannel(splitter, splitbar, splitPercPos, false);
							$(this).next().css("display","");
							_splitPerc = (splitpos/size)*100;
						});						
					}					
					
					if(emxUIConstants.UI_AUTOMATION == "true"){
						var spliterName = "";
						if(opts.splitbarClass == "splitbarH"){
							spliterName = "splitbarH" + "-" + (i+1);
						}else{
							var tempid = this.id;
							spliterName = "splitbarV" + tempid.substr(8,tempid.length) + "-" + (i+1);
						}
						splitbar.attr({
							"data-aid": spliterName
						});
					}
					
					splitbar.attr({
						"class": opts.splitbarClass,
						unselectable: "on"
					}).css({
						"cursor": opts.cursor,
						"user-select": "none",
						"-webkit-user-select": "none",
						"-khtml-user-select": "none",
						"-moz-user-select": "none"
					}).bind("mousedown.splitter", startDrag);				
//				})(); // END PER-PANE CLOSURE  -- CLOSURE NO LONGER NEEDED
			} //end each pane

			splitter.data('splitter', {
				opts: opts,
				panes: panes,
				splitbars: splitbars
			});
			
			// resize  event handlers;			
			splitter.bind("resize.splitter", function (e) {
				if (splitter.splitter('isPaused')) return;
				if (e.target != this) return;
				//Code to avoid V-scrollbar incase of single row
				resizeContainer(splitter, false);
			});			
			$(window).bind("resize.splitter", function (e) {
				if (splitter.splitter('isPaused')) return;
				resizeContainer(splitter, false);
			});			
			resizeContainer(splitter, true);
			var currentRow = $(this);
			if(currentRow.hasClass("pv-row") && $(".pv-col",currentRow).size()=="1"){
				var tabName = "col-"+currentRow.find(".pv-channel:last").find(".tab-active:first").attr("title");
				if(localStorage.getItem(tabName)=="false"){				
					setTimeout(function() {$("div[id='"+tabName+"']").trigger( "click" ); }, 150);
				}
			}else if(currentRow.hasClass("pv-col") && currentRow.parent(".pv-row").children(".pv-col").size() >3){
				currentRow = currentRow.parent(".pv-row").children(".pv-col:last")
				var tabName = "col-"+currentRow.find(".pv-channel:first").find(".tab-active:first").attr("title");
				if(localStorage.getItem(tabName)=="false"){				
					setTimeout(function() {$("div[id='"+tabName+"']").trigger( "click" ); }, 150);
				}
			}
        });  // END each splitter
    }; // END FUNCTION INIT

	function startDrag(e) {
		var splitbar = $(e.target);
		var context = splitbar.data('splitter');
		var A = context.A;
		var B = context.B;
		var splitter = context.splitter;
		
		//if (e.target != this) return;
		if (! _divAboveIframes) {
			_divAboveIframes = $('<div class="aboveIframes"></div>')
				.css("background", "transparent url(images/utilSpacer.gif)");
			$('body').append(_divAboveIframes[0]);
		}
		var clonesSplitbar = splitbar.clone(false);
		context.initPos = splitbar.position();
		context.initPos[context.opts.moving] -= splitbar[context.opts.sizing]();
		context.initPos[context.opts.moving] += splitter.scrollTop();
		clonesSplitbar.addClass(context.opts.ghostClass)
			.css('position', 'absolute')
			.css('z-index', '250')
			.css("-webkit-user-select", "none")
			.width(splitbar.width())
			.height(splitbar.height())
			.css(context.opts.moving, context.initPos[context.opts.moving]);
		
		_ghost = _ghost || clonesSplitbar.insertAfter(A);
		_ghost.data('splitter', splitbar);
		context.panes.css("-webkit-user-select", "none"); // Safari selects A/B text on a move
		context._posSplit = e[context.opts.eventPos]+ splitter.scrollTop();

		$(document)
			.bind("mousemove.splitter", performDrag)
			.bind("mouseup.splitter", endDrag);			
	}

	
    function performDrag(e) {
        if (!_ghost) return;
        var splitbar = _ghost.data('splitter');
        var context = splitbar.data('splitter');
        var splitter = context.splitter;
        var A = context.A;
        var B = context.B;

        var ePos = e[context.opts.eventPos] + splitter.scrollTop();
        var barsize = splitbar[context.opts.sizing]() + (2 * parseInt(splitbar.css('border-' + context.opts.moving + '-width'))); //+ border. cheap&dirty
        _splitBarWidth = barsize;
        // Set a limit on motion: cannot drag a splitbar beyond next splitbar
        // var end refers to end of space available to A, which is either
        // the start of a possible pane following B, or the end of the container
        var containerSize;
        if(context.opts.sizing== "height"){
			//containerSize =	B.offset()[context.opts.moving]+ B.height()+ barsize +splitter.scrollTop();//Total  container height
			containerSize = getPVContainerSize(context.opts.sizing);
		}
		else{
			containerSize = context.splitter[context.opts.sizing]();//width
		}
		var start = A.offset()[context.opts.moving]+ splitter.scrollTop();
		var end;
		var incr;
        if (B[0].nextSibling) {
            end = $(B[0].nextSibling).offset()[context.opts.moving]+ splitter.scrollTop() ;
            if($(B[0].nextSibling).offset()[context.opts.moving]==0){
            	end = containerSize-(4*_statusBarWidth);//if spliter bar is hidden then the user can scroll right till 2 times of _statusBarWidth.
            }
        } else {
            end = containerSize;
        }
        if(context.opts.sizing== "height"){
        	incr = Math.min(Math.max(ePos, start + barsize + 60/* PortalTabs*/), end - barsize*2 - 40) - context._posSplit;
        }
        else{
        	incr = Math.min(Math.max(ePos, start + barsize + 40), end - barsize*2 - 20) - context._posSplit;
        }
       	_ghost.css(context.opts.moving, context.initPos[context.opts.moving] + incr);
    } 

	
	function endDrag(e) {
        if (!_ghost) return;
        var splitbar = _ghost.data('splitter');
        var context = splitbar.data('splitter');
        var splitter = context.splitter;
		if (!context.A) return;

		var p = _ghost.position();

		_ghost.data('splitter', null);
		_ghost.remove();
		_divAboveIframes.remove();
		_divAboveIframes = null;
		_ghost = null;
		
		var barsize = splitbar[context.opts.sizing]() + (2 * parseInt(splitbar.css('border-' + context.opts.moving + '-width'))); //+ border. cheap&dirty

		context.panes.css("-webkit-user-select", "text"); // let Safari select text again
		$(document).unbind("mousemove.splitter").unbind("mouseup.splitter");
		
		var splitPos = p[context.opts.moving] + barsize - context.splitter.position()[context.opts.moving];		
		//gqh: IR-146992V6R2013
		splitter.data('splitter').paused = true; 
		splitTo(splitbar, splitPos, (context.initPos[context.opts.moving] > p[context.opts.moving]), false, true , false, true);
		setTimeout(function() {splitter.data('splitter').paused = false;updateLocalStorage(context); }, 500);		
		context.initPos = 0;		
		
	}
	
	function updateLocalStorage(context){
		var channelAId = context.A.attr("id");
		var channelBId = context.B.attr("id");
		var channelA , channelB;
		var containerWidth = getPVContainerSize(context.opts.sizing);
		if(context.opts.sizing=="width"){
			channelA = (context.A.width()/containerWidth*100).toFixed() + "%";
			channelB = (context.B.width()/containerWidth*100).toFixed() + "%";
		}else{
			channelA = (context.A.height()).toFixed() + "px";
			channelB = (context.B.height()).toFixed() + "px";			
		}
		
		var locStorageMap = JSON.parse(localStorage.getItem("ls-"+jQuery(".pv-container").attr("data-portalName")));			
		locStorageMap[channelAId]=channelA;
		locStorageMap[channelBId]=channelB;
		
		localStorage.setItem("ls-"+jQuery(".pv-container").attr("data-portalName"), JSON.stringify(locStorageMap));	
		
	}
	
	function getPVContainerSize(sizing){
		if(sizing == "height"){
			var rowHeight = 0;
    		var pvContainer = document.getElementById("divPowerView");
    		for(pvRow = pvContainer.firstChild; pvRow != null ; pvRow.nextSibling == null ? pvRow = null: pvRow = pvRow.nextSibling ){
   				if(pvRow.className == "pv-row"){
   					rowHeight += pvRow.offsetHeight;
   					rowHeight +=_splitBarWidth-2;
   				}
			}
			rowHeight -=_splitBarWidth-2;
			return(rowHeight);
		}	
		else{
			var containerWidth = document.getElementById("divPvRow-1").offsetWidth;
			return containerWidth;
		}
	}	
	
	

	// Two distinct modes of operation:
	// fit==true -> zero-sum pane size deltas (grow one, shrink the other)
	// fit==false -> resize one pane w/o resizing opposite pane
	function splitTo(splitbar, splitPos, reversedorder, fast , splitbarDrag, isPVContainerScrolled, resizeEvent) {
		var context = splitbar.data('splitter');

		var A = context.A;
		var B = context.B;
		var barsize = splitbar[context.opts.sizing]() + (2 * parseInt(splitbar.css('border-' + context.opts.moving + '-width'))); //+ border. cheap&dirty
		var containerSize = getPVContainerSize(context.opts.sizing);
		//gqh: IR-146992V6R2013
		//if (context.splitter.splitter('isPaused')) {
			//alert("should not have called splitTo when paused");
			//return;
		//}
		if (_ismovingNow || splitPos == undefined) return; //generally MSIE problem
		_ismovingNow = true;
		context.splitPos = splitPos;

		
		var offsetA = A.offset()[context.opts.moving];
		var offsetB = B.offset()[context.opts.moving];
		
		if(splitbarDrag || isPVContainerScrolled){
			offsetA += context.splitter.scrollTop();
 			offsetB += context.splitter.scrollTop();
 		}
		if(splitbarDrag){
			splitPos  += context.splitter.scrollTop();
			if(context.opts.sizing == "height"){
				splitPos  -= _splitBarWidth;
			}		
		}
		
		var endPoint = containerSize;
		
		// var end refers to end of space available to A, which is either
		// the start of a possible pane following B, or the end of the container
		if (B[0].nextSibling) {
			var end = $(B[0].nextSibling).offset()[context.opts.moving];
			if($(B[0].nextSibling).offset()[context.opts.moving]==0){
				end = containerSize-_statusBarWidth;			
			}
			if(isPVContainerScrolled || splitbarDrag ){
				end += context.splitter.scrollTop();
			}
		} else {
			var end = endPoint;
		}
		
		var offsetWidth1 =3;
		
		if(_isMultiPaneView && resizeEvent && !Browser.FIREFOX){			
				offsetWidth1 = 1;
		}
		
		var zIndexA = A[0].style.zIndex;
		var zIndexB = B[0].style.zIndex;
		var zIndexExist = ((typeof zIndexA != "undefined") && (zIndexA != "")) || ((typeof zIndexB != "undefined") && (zIndexB != ""));
		if(context.opts.sizing == "height") {
			var sizeA = Math.round(Math.max(0, (splitPos - offsetA)));
			var sizeB = Math.round(Math.max(0, (end - Math.round(splitPos) - (_splitBarWidth-2))));
		} else if(context.opts.sizing == "width" && zIndexExist && zIndexA > zIndexB) {
			var sizeA = Math.round(Math.max(0, (end - offsetA)));
			var sizeB = Math.round(Math.max(0, (end - splitPos)));
		} else if(context.opts.sizing == "width" && zIndexExist && zIndexB > zIndexA) {
			var sizeA = Math.round(Math.max(0, (splitPos - offsetA - barsize - offsetWidth1)));
			var sizeB = Math.round(Math.max(0, (end - offsetB)));
		} else if($(splitbar).css("display")=="none") {			
			var sizeA = Math.max(0, (splitPos - offsetA - offsetWidth1));
			var sizeB = Math.max(0, (end - splitPos));
			if(sizeB<_statusBarWidth){
				sizeA = sizeA-(_statusBarWidth-sizeB);
				sizeB=_statusBarWidth;
			}
		} else {
			var sizeA = Math.max(0, (splitPos - offsetA - barsize - offsetWidth1));
			var sizeB = Math.max(0, (end - splitPos));
		}
		
		
		
		if (fast) {
			A.css(context.opts.sizing, sizeA + 'px');
			if (context.opts.fit) {
				B.css(context.opts.sizing, sizeB + 'px');
			}
			
			context.panes.trigger("resize");
			if (context.opts.slave) context.opts.slave.trigger("resize");
			
			_ismovingNow = false;
			context.splitPercent = splitPos / containerSize * 100
			return true;
		}
		if (reversedorder) { //reduces flickering if total percentage becomes more  than 100 (possible while animating)
			var anob = {};
			anob[context.opts.sizing] = sizeA + 'px';
			A.animate(anob, context.opts.animSpeed, function () {
				if ($(this)[context.opts.sizing]() < 2) {
					$(this).css('display', 'none');
					B.stop(true, true);
					B[context.opts.sizing](containerSize + 'px');
				}
			});
			if (context.opts.fit) {
				var anob2 = {};
				anob2[context.opts.sizing] = sizeB + 'px';
				B.animate(anob2, context.opts.animSpeed, function () {
					if ($(this)[context.opts.sizing]() < 2) {
						$(this).css('display', 'none');
						A.stop(true, true);
						A[context.opts.sizing](containerSize + 'px')
					}
				});
			}
		} else {
			if (context.opts.fit) {
				var anob = {};
				anob[context.opts.sizing] = sizeB + 'px';
				B.animate(anob, context.opts.animSpeed, function () {
					if ($(this)[context.opts.sizing]() < 2) {
						$(this).css('display', 'none');
						A.stop(true, true);
						A[context.opts.sizing](containerSize + 'px')
					}
				});
			}
			var anob = {};
			anob[context.opts.sizing] = sizeA + 'px';
			A.animate(anob, context.opts.animSpeed, function () {
				if ($(this)[context.opts.sizing]() < 2) {
					$(this).css('display', 'none');
					B.stop(true, true);
					B[context.opts.sizing](containerSize + 'px');
				}
			});
		}
		//trigger resize evt
		context.splitter.queue(function () {
			setTimeout(function () {
				context.splitter.dequeue();
				_ismovingNow = false;
				context.panes.trigger("resize");
				if (context.opts.slave) context.opts.slave.trigger("resize");
				var container = getPVContainerSize(context.opts.sizing);
				context.splitPercent = splitPos / container * 100;
			}, context.opts.animSpeed + 5);
		});

	} //end splitTo()

	
	function toggelChannel(splitter, splitbar, splitPos, reversedorder, perc) {
		var context = splitbar.data('splitter');
		
		var A = $(splitbar[0].previousSibling);
		var B = $(splitbar[0].nextSibling);
		if(B[0].className == "pv-col closed-cols hidden" || B[0].className == "pv-col closed-cols"){
			B= $(splitbar[0].nextSibling.nextSibling);
		}
				
		var containerSize = getPVContainerSize(context.opts.sizing);
		
		if($(A[0]).offset()[context.opts.moving] > splitPos){
			splitPos = $(A[0]).offset()[context.opts.moving] + (containerSize - $(A[0]).offset()[context.opts.moving])/2;
		}
		
		var endPoint = containerSize;
		context.splitPercent = (splitPos) / containerSize * 100;
	

		if (B[0].nextSibling) {
			var end = $(B[0].nextSibling).offset()[context.opts.moving];			
		} else {
			var end = endPoint;
		}
	
		var barsize = splitbar[context.opts.sizing]() + (2 * parseInt(splitbar.css('border-' + context.opts.moving + '-width'))); //+ border. cheap&dirty
		var sizeA = splitPos ;
		
		var sizeB = end - splitPos;
		if(reversedorder){
			sizeA =  Math.round(splitPos - $(A[0]).offset()[context.opts.moving]);
			sizeB = Math.round(sizeB + _statusBarWidth);			
		}else{			
			sizeA = Math.round(containerSize-sizeB- $(A[0]).offset()[context.opts.moving]);
			sizeB = Math.round(sizeB-barsize-3);
		}	
		
		
				var anob = {};
				anob[context.opts.sizing] = sizeA + 'px';
				A.animate(anob, context.opts.animSpeed, function () {
					if ($(this)[context.opts.sizing]() < 2) {
						$(this).css('display', 'none');
						B.stop(true, true);
						B[context.opts.sizing](sizeB + 'px');
					}
					if (context.opts.fit) {
						var anob2 = {};
						anob2[context.opts.sizing] = sizeB + 'px';
						B.animate(anob2, context.opts.animSpeed, function () {
							if ($(this)[context.opts.sizing]() < 2) {
								$(this).css('display', 'none');
								A.stop(true, true);
								A[context.opts.sizing](sizeA + 'px');
							}
						});
					}
		});	
				
		}	
	

		// TODO
	// Currently, this function does not consider size constraints at all.
	// That work is still TODO.
	//
	// This function allocates the available space to the panes at init time,
	// and then again at window resize events.  
	// It attempts to honor pane size constraints as follows:
	// 
	// - If enforceConstraints is false:
	//   if a pane is already violating a constraint (or at its limit before violating),
	//   don't make it worse, but also don't make it better (i.e. don't further reduce 
	//   a pane that's already too small).
	//   However, let's say the window has been shrunk, all panes will either shrink
	//   or stay the same size; none will grow
	// - If enforceConstraints is true:
	//   Attempt to resize panes so as to no longer be violating constraints
	//   That means some panes may grow and others may shrink
	function resizeContainer(splitter, enforceContstraints) {
		var splitterData = splitter.data('splitter');
		var panes = splitterData.panes;
		var splitbars = splitterData.splitbars;
		var opts = splitterData.opts;
		var newContainerSize = getPVContainerSize(opts.sizing);
		 	
		// TODO: apply all necessary size adjustments, allocating available space as
		// per constraints and as per rules in function comments
		
		// adjust all split positions
		splitbars.each(function() {
			var oldPercent = $(this).data('splitter').splitPercent;
			var newPos = oldPercent * newContainerSize / 100;
			var isPVContainerScrolled = false;
		 	if(splitter.scrollTop() > 0){
		 		 isPVContainerScrolled = true;
		 	}
			
			splitTo($(this), newPos, false, true, false, isPVContainerScrolled);
		});
		// when opened in the popup,and when the container height is less than window height, the number of channels will get the equal height  
		var myWin = getTopWindow().getWindowOpener();
		var pvContainer = document.getElementById("divPowerView");
		if(typeof myWin != "undefined" && myWin != null && myWin != "" && opts.sizing == "height"){
		    var objRow =  document.getElementsByClassName("pv-row");
			for(var i=0;i<objRow.length;i++){
				objRow[i].style.height =  emxUICore.getWindowHeight() / (objRow.length) + "px"
			}
		}
		// when the container height is less than window height, first row gets the diff height  
		else if(opts.sizing == "height" && newContainerSize < emxUICore.getWindowHeight()-4 ){
			var diff = emxUICore.getWindowHeight() - newContainerSize;
			var newHeight = pvContainer.firstChild.offsetHeight + diff - 30;
			pvContainer.firstChild.style.height =  newHeight + "px";
		}		
		
		// If not in "fit" mode splitPercent's are invalidated; update them
		if (!opts.fit) {
			splitbars.each(function() {
				var newPos = $(this).data('splitter').splitPos;
				var newPercent = newPos / newContainerSize * 100;
				$(this).data('splitter').splitPercent = newPercent
			});
		}
	}
	
})(jQuery);
