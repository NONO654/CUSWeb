/*
 * Lightweight RTE - jQuery Plugin, version 1.2
 * Copyright (c) 2009 Andrey Gayvoronsky - http://www.gayvoronsky.com
 */

jQuery.fn.rte = function(options, editors) {
	if(!editors || editors.constructor != Array)
		editors = new Array();
		
	jQuery(this).each(function(i) {
		var id = (this.id) ? this.id : editors.length;
		editors[id] = new lwRTE (this, options || {});
	});
	
	return editors;
}

var emxUIRTE = new Object;
emxUIRTE.RTE_TAGS = ["strong","em","b","i","u", "p","sup","sub","strike","s","span","br"];
emxUIRTE.RTE_SUP_TAGS = ["br","strong","em","b","i","u", "p","sup","sub","strike","s","span"];
emxUIRTE.get_rte_data = function _emxUIRTE_get_rte_data (value, paramName) {
	var rteValueXml = emxUICore.createXMLDOM();
    rteValueXml.loadXML("<mxLinkRoot/>");
    var textNode = rteValueXml.createTextNode(value);
    var theRoot  = rteValueXml.documentElement;
    theRoot.appendChild(textNode);
    //while loading RTE no need to do input-filter pass skipInputFilter = true, 
    //or else if the param name of RTE is available pass the param name
    var extraParam = "skipInputFilter=true";  
    if(typeof paramName!='undefined' &&  paramName != null) {
    	 extraParam = "paramName=" + paramName;
    }    
    var responseText = emxUICore.getTextXMLDataPost("../common/emxFreezePaneValidate.jsp?rteValue=true&"+extraParam, rteValueXml.xml);
    return emxUICore.selectSingleNode(responseText ,"/mxRoot/message/display/text()").nodeValue;
}

var lwRTE_resizer = function(textarea) {
	this.drag = false;
	this.rte_zone = jQuery(textarea).parents('.rte-zone');
}

lwRTE_resizer.mousedown = function(resizer, e) {
	resizer.drag = true;
	resizer.event = (typeof(e) == "undefined") ? window.event : e;
	resizer.rte_obj = jQuery(".rte-resizer", resizer.rte_zone).prev().eq(0);
	jQuery('body', document).css('cursor', 'se-resize');
	return false;
}

lwRTE_resizer.mouseup = function(resizer, e) {
	resizer.drag = false;
	jQuery('body', document).css('cursor', 'auto');
	return false;
}

lwRTE_resizer.mousemove = function(resizer, e) {
	if(resizer.drag) {
		e = (typeof(e) == "undefined") ? window.event : e;
		var w = Math.max(1, resizer.rte_zone.width() + e.screenX - resizer.event.screenX);
		var h = Math.max(1, resizer.rte_obj.height() + e.screenY - resizer.event.screenY);
		resizer.rte_zone.width(w);
		resizer.rte_obj.height(h);
		resizer.event = e;
	}
	return false;
}

var lwRTE = function (textarea, options) {
	this.css		= [];
	this.css_class	= options.frame_class || '';
	this.base_url	= options.base_url || '';
	this.width		= options.width || jQuery(textarea).width() || '100%';
	this.height		= options.height || jQuery(textarea).height() || 350;
	this.iframe		= null;
	this.iframe_doc	= null;
	this.textarea	= null;
	this.event		= null;
	this.range		= null;
	this.toolbars	= {rte: '', html : ''};
	this.controls	= {rte: {}, html: {}};
	//below is a toggle for html/css mode
	//this.controls	= {rte: {disable: {hint: 'Source editor'}}, html: {enable: {hint: 'Visual editor'}}};
	this.callback   = options.callback || null;
	this.ok_cancel  = options.ok_cancel || false;

	jQuery.extend(this.controls.rte, options.controls_rte || {});
	jQuery.extend(this.controls.html, options.controls_html || {});
	jQuery.extend(this.css, options.css || {});

	if(document.designMode || document.contentEditable) {
		jQuery(textarea).wrap(jQuery('<div style="height:160px"></div>').addClass('rte-zone').width(this.width));		
		jQuery('<div class="rte-resizer"><a href="#"></a></div>').insertAfter(textarea);
		if(this.ok_cancel){
			jQuery('.rte-resizer').prepend(jQuery('<input id="rte_ok" class="mx_btn-apply" type="button"><input id="rte_cancel" class="mx_btn-cancel" type="button">'));
			jQuery('#rte_ok').val(emxUIConstants.RTE_OK).attr('title',emxUIConstants.RTE_OK);
			jQuery('#rte_cancel').val(emxUIConstants.RTE_CANCEL).attr('title',emxUIConstants.RTE_CANCEL);
			if(this.callback){
				var self = this;
				jQuery('#rte_ok').bind('click',function(){self.callback()});
				jQuery('#rte_cancel').bind('click',function(){jQuery('.formLayer').remove();});
			}
		}
		var resizer = new lwRTE_resizer(textarea);
		
		jQuery(".rte-resizer a", jQuery(textarea).parents('.rte-zone')).mousedown(function(e) {
			jQuery(document).mousemove(function(e) {
				return lwRTE_resizer.mousemove(resizer, e);
			});

			jQuery(document).mouseup(function(e) {
				return lwRTE_resizer.mouseup(resizer, e)
			});

			return lwRTE_resizer.mousedown(resizer, e);
		});

		this.textarea	= textarea;
		this.enable_design_mode();
	}
}

lwRTE.prototype.editor_cmd = function(command, args) {
	//this.iframe.contentWindow.focus();
	try {
		/* #RTL start ris */
				if(command=="rtl") //#RTL
				{
					this.iframe_doc.dir=this.iframe_doc.dir=="rtl"?"ltr":"rtl";
				}
				else {
					if(isIE && this.iframe_doc.body.innerText.length == this.iframe_doc.getSelection().toString().length) {
						this.iframe_doc.body.innerHTML = this.iframe_doc.body.innerHTML+"";	
					}
					this.iframe_doc.execCommand(command, false, args);		
				}
		/* #RTL end */	
		if(isEdge){
		   jQuery(this.iframe_doc.body).trigger('blur');
		}
	} catch(e) {
	}
	//this.iframe.contentWindow.focus();
	this.iframe_doc.body.focus();
}

lwRTE.prototype.get_toolbar = function() {
	var editor = (this.iframe) ? jQuery(this.iframe) : jQuery(this.textarea);
	return (editor.prev().hasClass('rte-toolbar')) ? editor.prev() : null;
}

lwRTE.prototype.activate_toolbar = function(editor, tb) {
	var old_tb = this.get_toolbar();

	if(old_tb)
		old_tb.remove();

	jQuery(editor).before(jQuery(tb).clone(true));
}
	
lwRTE.prototype.enable_design_mode = function() {
	var self = this, 
		id = jQuery(self.textarea).attr('id') || jQuery(self.textarea).attr('name');

	// need to be created this way
	self.iframe	= document.createElement("iframe");
	self.iframe.frameBorder = 0;
	self.iframe.frameMargin = 0;
	self.iframe.framePadding = 0;
	self.iframe.width = '100%';
	self.iframe.height = self.height || '100%';
	self.iframe.style.position	= "relative";
	self.iframe.src	= "";
//spellchecker attribute sc_dojoType
	self.iframe.setAttribute("sc_dojoType", "scayt.ui");

	if(jQuery(self.textarea).attr('class'))
		self.iframe.className = jQuery(self.textarea).attr('class');

	if(jQuery(self.textarea).attr('id')){
		self.iframe.id = jQuery(self.textarea).attr('id')+'_rte';
	}

	if(jQuery(self.textarea).attr('name'))
		self.iframe.title = jQuery(self.textarea).attr('name');

	var content	= jQuery(self.textarea).val();
	content = content.replace(/<span dir="LTR"\/>/gi,  '<span dir="LTR"></span>');
	content = content.replace(/<span dir="RTL"\/>/gi,  '<span dir="RTL"></span>');
    if(content.indexOf('<') != -1 && content.indexOf('>') != -1){
    	content = emxUIRTE.get_rte_data(content);
    }
	
	jQuery(self.textarea).hide().after(self.iframe);
	//self.textarea	= null;
	

	var base = (self.base_url) ? "<base href='" + self.base_url + "' />" : '';
	var style = (self.css_class) ? "class='" + self.css_class + " verbatim'" : "class='verbatim'";

	// Mozilla need this to display caret
	/*if(jQuery.trim(content) == '')
		content	= '<br>';*/
	/* #RTL start ris */
	var isRTL=false;
	if(content.indexOf("<div")==0){
		isRTL=true;
		content=content.replace('<div dir="rtl">', '');
		content=content.replace('</div>', '');
	}
	/* #RTL end */
	//Replace trailing <br/> with <div><br></div> -- Start
	var matcher = /(<br\/>)*$/g.exec(content);
	if (matcher) {
		var contentToReplace = Browser.IE ? "<p><br></p>" : "<div><br></div>";
		var brContent = matcher[0].replace(/<br\/>/g, contentToReplace);
		content = content.substring(0, matcher.index) + brContent;
	}
	//Replace trailing <br/> with <div><br></div> -- End
	var doc = "<!DOCTYPE html><head>" + base + "</head><body " + style + " style='padding:5px; background-color:white;'>" + content + "</body></html>";

	self.iframe_doc	= self.iframe.contentWindow.document;

	try {
		self.iframe_doc.designMode = 'on';
	} catch ( e ) {
		// Will fail on Gecko if the editor is placed in an hidden container element
		// The design mode will be set ones the editor is focused
		jQuery(self.iframe_doc).focus(function() { self.iframe_doc.designMode(); } );
	}

	self.iframe_doc.open();
	self.iframe_doc.write(doc);
	self.iframe_doc.close();

	for(var i = 0; i < self.css.length ; i++){
		jQuery("head",self.iframe_doc).append(jQuery("<link type='text/css' rel='stylesheet' href='" + self.css[i] + "' />"));
	}
	
	jQuery(self.iframe).bind('blur',function(){		//fix for IE11
		self.update_hidden_field();
	});
		
	jQuery(self.iframe_doc).bind('blur',function(){
		self.update_hidden_field();
	});
	
	jQuery(self.iframe_doc.body).bind('blur',function(){
		self.update_hidden_field();
	});
	
	jQuery(self.iframe_doc).bind('paste', function(e){
	    e = jQuery.extend({},e,{type:'afterpaste'});
		var tempTriggerElem;
		if(e.target.tagName !== 'BODY') {
			tempTriggerElem = jQuery(e.target).closest('body')[0];
		} else {
			tempTriggerElem = e.target;
		}	
		
	    window.setTimeout(function(){ jQuery(tempTriggerElem).trigger(e.type);},0);
	  });

	jQuery(self.iframe_doc).bind('afterpaste', function() {
		jQuery('body', self.iframe_doc).html(cleanup_word(jQuery('body', self.iframe_doc).html(), true, true, true,true));
	}.bind(this));

	jQuery(self.iframe.contentWindow).bind('focus',function(){
		if(typeof FormHandler != 'undefined'){
			FormHandler.GetField(self.textarea.name).HandleFocusEvent();	
		}
	});
	
	jQuery(self.iframe.contentWindow).bind('keydown',function(e){
        if(e.ctrlKey){
			 if (e.keyCode == 65 || e.keyCode == 97) {
				e.preventDefault();
			}
      }
    });
	
	if(!self.toolbars.rte)
		self.toolbars.rte	= self.create_toolbar(self.controls.rte);

	self.activate_toolbar(self.iframe, self.toolbars.rte);

	jQuery(self.iframe).parents('form').submit( 
		function() { self.disable_design_mode(true); }
	);

	jQuery(self.iframe_doc).mouseup(function(event) { 
		if(self.iframe_doc.selection)
			self.range = self.iframe_doc.selection.createRange();  //store to restore later(IE fix)

		self.set_selected_controls( (event.target) ? event.target : event.srcElement, self.controls.rte); 
	});

	jQuery(self.iframe_doc).blur(function(event){ 
		if(self.iframe_doc.selection) 
			self.range = self.iframe_doc.selection.createRange(); // same fix for IE as above
	});

	jQuery(self.iframe_doc).keyup(function(event) { self.set_selected_controls( self.get_selected_element(), self.controls.rte); });

	 //Mozilla CSS styling off
	if(!isIE){
		self.iframe_doc.execCommand('styleWithCSS', false, false);
	}else if(isMinIE9){
		self.iframe_doc.execCommand("AutoUrlDetect", false, false); 
	}
	
	self.textarea.updateRTE = function(value){
		self.update_RTE_values(value);
	};
	
	self.textarea.enableRTE = function(value){
		self.iframe_doc.designMode = 'on';
	};
	
	self.textarea.disableRTE = function(){
		self.iframe_doc.designMode = 'off';
	};
	
	/* #RTL start ris */	
	if(isRTL==true)
	{
		self.iframe_doc.dir="rtl";	
		$('.rtl').addClass('active');
	}
	/* #RTL end */		
}

lwRTE.prototype.update_hidden_field = function() {
	var self = this;
	var oldValue = jQuery(self.textarea).val();
	if(jQuery('body', self.iframe_doc).text().trim() != ""){
		var ifhtml = $('body', self.iframe_doc).html();
        ifhtml = ifhtml.replace( /<(\w[^>]*) style="([^\"]*)"([^>]*)/gi, "<$1$3" ) ;
		/* #RTL start ris */	
		var content = ifhtml.replace(/<[\/]{0,1}(A)[^><]*>/gi,"").replace(/&nbsp;/gi, " ").replace(/&lt;/gi, "<").replace(/&gt;/gi, ">").replace(/&amp;/gi, "&").replace(/<br>/gi, "<br/>");
		//To remove combination <br/> to avoid extra br created -- Start
		
		var searchStringToDetectRemovalOfStartBR = Browser.IE? "<p>": "<div>";
		var i=0;
		while( i<6 ) {
			content = content.replace(/<(b|strong)><br\/><\/\1>/g, "<br/>")
								.replace(/<(i|em)><br\/><\/\1>/g, "<br/>")
								.replace(/<u><br\/><\/u>/g, "<br/>")
								.replace(/<strike><br\/><\/strike>/g, "<br/>")
								.replace(/<sub><br\/><\/sub>/g, "<br/>")
								.replace(/<sup><br\/><\/sup>/g, "<br/>")
					  ;
			i++;
		}
		//To remove combination <br/> to avoid extra br created -- End
		
		content = content.replace(/<(div|p)><br\/><\/\1>/g, "<br/>");
		
		var matcher = /<\/(div|p)>[^<div>|<p>]/g.exec(content);///<\/div>[^<div>|<p>]/.exec(content);
		if (matcher) {
			var pos = matcher.index;
			content = content.substring(0, pos+6) + "<br/>" + content.substring(pos+6);
		}
		
		//To check and remove extra br at the begining after converting the content -- Start
		var contentWithoutBR = new String(content);
		contentWithoutBR = contentWithoutBR.replace(/<br\/>/g, "");
		var canRemoveStartBR = contentWithoutBR.indexOf(searchStringToDetectRemovalOfStartBR) == 0;
		//To check and remove extra br at the begining after converting the content -- End
		
		content = content.replace(/<(div|p)>/g,"<br/>").replace(/<\/(div|p)>/g,"");
		if( canRemoveStartBR ) {
			content = content.replace("<br/>","");
		}
		if(self.iframe_doc.dir=="rtl")
			content="<div dir=\"rtl\">" + content + "</div>"
			
		jQuery(self.textarea).val(content);
		/* #RTL end */	
		
	}else{
		jQuery(self.textarea).val("");
	}
	if(typeof FormHandler != 'undefined'){
	FormHandler.GetField(self.textarea.name).FireChangeEvent();
	}
	if(self.textarea.onchange && oldValue != jQuery(self.textarea).val()){
		self.textarea.onchange();
	}
}

lwRTE.prototype.update_RTE_values = function(value) {
	var self = this;
	jQuery('body', self.iframe_doc).html(value);
	jQuery(self.textarea).val(value);
}
    
lwRTE.prototype.disable_design_mode = function(submit) {
	var self = this;

	self.textarea = (submit) ? jQuery('<input type="hidden" />').get(0) : jQuery('<textarea></textarea>').width('100%').height(self.height).get(0);

	if(self.iframe.className)
		self.textarea.className = self.iframe.className;

	if(self.iframe.id)
		self.textarea.id = self.iframe.id.substring(0, self.iframe.id.indexOf("_rte"));
		
	if(self.iframe.title)
		self.textarea.name = self.iframe.title;
	
	jQuery(self.textarea).val(jQuery('body', self.iframe_doc).html());
	jQuery(self.iframe).before(self.textarea);

	if(!self.toolbars.html)
		self.toolbars.html	= self.create_toolbar(self.controls.html);

	if(submit != true) {
		jQuery(self.iframe_doc).remove(); //fix 'permission denied' bug in IE7 (jquery cache)
		jQuery(self.iframe).remove();
		self.iframe = self.iframe_doc = null;
		self.activate_toolbar(self.textarea, self.toolbars.html);
	}
}
    
lwRTE.prototype.toolbar_click = function(obj, control) {
	var fn = control.exec;
	var args = control.args || [];
	var is_select = (obj.tagName.toUpperCase() == 'SELECT');
	
	if(obj.className.indexOf('active') > -1 ){
		jQuery(obj).removeClass('active');
	}else{
		jQuery(obj).addClass('active');
	}
	jQuery('.rte-panel', this.get_toolbar()).remove();

	if(fn) {
		if(is_select)
			args.push(obj);

		try {
			fn.apply(this, args);
		} catch(e) {

		}
	} else if(this.iframe && control.command) {
		if(is_select) {
			args = obj.options[obj.selectedIndex].value;

			if(args.length <= 0)
				return;
		}

		this.editor_cmd(control.command, args);
	}
}
	
lwRTE.prototype.create_toolbar = function(controls) {
	var self = this;
	var tb = jQuery("<div></div>").addClass('rte-toolbar').width('100%').append(jQuery("<ul class='inline'></ul>")).append(jQuery("<div></div>").addClass('clear'));
	var obj, li;
	
	for (var key in controls){
		if(controls[key].separator) {
			li = jQuery("<li></li>").addClass('separator');
		} else {
			if(controls[key].init) {
				try {
					controls[key].init.apply(controls[key], [this]);
				} catch(e) {
				}
			}
			
			if(controls[key].select) {
				obj = jQuery(controls[key].select)
					.change( function(e) {
						self.event = e;
						self.toolbar_click(this, controls[this.className]); 
						return false;
					});
			} else {
				obj = jQuery("<a href='#'></a>")
					.attr('title', (controls[key].hint) ? controls[key].hint : key)
					.attr('rel', key)
					.click( function(e) {
						self.event = e;
						self.toolbar_click(this, controls[this.rel]); 
						return false;
					})
			}

			li = jQuery("<li></li>").append(obj.addClass(key));
		}

		jQuery("ul",tb).append(li);
	}

	jQuery('.enable', tb).click(function() {
		self.enable_design_mode();
		return false; 
	});

	jQuery('.disable', tb).click(function() {
		self.disable_design_mode();
		return false; 
	});

	return tb.get(0);
}

lwRTE.prototype.create_panel = function(title, width) {
	var self = this;
	var tb = self.get_toolbar();

	if(!tb)
		return false;

	jQuery('.rte-panel', tb).remove();
	var drag, event, left = 8, top = 8;
	var obj = self.event.currentTarget;
	do {
		if(obj.tagName.toLowerCase()== "div")
			break;
		left += obj.offsetLeft;
		top += obj.offsetTop;
	}while (obj = obj.offsetParent);
//	var left = 50;
//	var top = 50;
	
	var panel	= jQuery('<div></div>').hide().addClass('rte-panel').css({left: left+"px", top: top+"px"});
	jQuery('<div></div>')
		.addClass('rte-panel-title')
		.html(title)
		.append(jQuery("<a class='close' href='#'><img src='../common/images/buttonMiniCancel.gif'></a>")
		.click( function() { panel.remove(); return false; }))
		.mousedown( function() { drag = true; return false; })
		.mouseup( function() { drag = false; return false; })
		.mousemove( 
			function(e) {
				if(drag && event) {
					left -= event.pageX - e.pageX;
					top -=  event.pageY - e.pageY;
					panel.css( {left: left+"px", top: top+"px"} ); 
				}

				event = e;
				return false;
			} 
		)
		.appendTo(panel);

	if(width)
		panel.width(width+"px");

	tb.append(panel);
	return panel;
}

lwRTE.prototype.get_content = function() {
	return (this.iframe) ? jQuery('body', this.iframe_doc).html() : jQuery(this.textarea).val();
}

lwRTE.prototype.set_content = function(content) {
	(this.iframe) ? jQuery('body', this.iframe_doc).html(content) : jQuery(this.textarea).val(content);
}

lwRTE.prototype.set_selected_controls = function(node, controls) {
	var toolbar = this.get_toolbar();

	if(!toolbar)
		return false;
		
	var key, i_node, obj, control, tag, i, value;

	try {
		for (key in controls) {
			control = controls[key];
			if(key=="rtl") continue; //#RTL
			obj = jQuery('.' + key, toolbar);

			obj.removeClass('active');

			if(!control.tags)
				continue;

			i_node = node;
			do {
				if(i_node.nodeType != 1)
					continue;

				tag	= i_node.nodeName.toLowerCase();
				if(jQuery.inArray(tag, control.tags) < 0 )
					continue;

				if(control.select) {
					obj = obj.get(0);
					if(obj.tagName.toUpperCase() == 'SELECT') {
						obj.selectedIndex = 0;

						for(i = 0; i < obj.options.length; i++) {
							value = obj.options[i].value;
							if(value && ((control.tag_cmp && control.tag_cmp(i_node, value)) || tag == value)) {
								obj.selectedIndex = i;
								break;
							}
						}
					}
				} else
					obj.addClass('active');
			}  while(i_node = i_node.parentNode)
		}
	} catch(e) {
	}
	
	return true;
}

lwRTE.prototype.get_selected_element = function () {
	var node, selection, range;
	var iframe_win	= this.iframe.contentWindow;
	
	if (iframe_win.getSelection) {
		try {
			selection = iframe_win.getSelection();
			range = selection.getRangeAt(0);
			node = range.commonAncestorContainer;
		} catch(e){
			return false;
		}
	} else {
		try {
			selection = iframe_win.document.selection;
			range = selection.createRange();
			node = range.parentElement();
		} catch (e) {
			return false;
		}
	}

	return node;
}

lwRTE.prototype.get_selection_range = function() {
	var rng	= null;
	var iframe_window = this.iframe.contentWindow;
	iframe_window.focus();
	
	if(iframe_window.getSelection) {
		rng = iframe_window.getSelection().getRangeAt(0);
	} else {
		//this.range.select(); //Restore selection, if IE lost focus.
		rng = this.iframe_doc.selection.createRange();
	}

	return rng;
}

lwRTE.prototype.get_selected_text = function() {
	var iframe_win = this.iframe.contentWindow;

	if(iframe_win.getSelection)	
		return iframe_win.getSelection().toString();

	this.range.select(); //Restore selection, if IE lost focus.
	return iframe_win.document.selection.createRange().text;
};

lwRTE.prototype.get_selected_html = function() {
	var html = null;
	var iframe_window = this.iframe.contentWindow;
	var rng	= this.get_selection_range();

	if(rng) {
		if(iframe_window.getSelection) {
			var e = document.createElement('div');
			e.appendChild(rng.cloneContents());
			html = e.innerHTML;		
		} else {
			html = rng.htmlText;
		}
	}

	return html;
};
	
lwRTE.prototype.selection_replace_with = function(html) {
	var rng	= this.get_selection_range();
	var iframe_window = this.iframe.contentWindow;

	if(!rng)
		return;
	
	this.editor_cmd('removeFormat'); // we must remove formating or we will get empty format tags!

	if(iframe_window.getSelection) {
		rng.deleteContents();
		rng.insertNode(rng.createContextualFragment(html));
		this.editor_cmd('delete');
	} else {
		this.editor_cmd('delete');
		rng.pasteHTML(html);
	}
}

lwRTE.prototype.insert_html_with = function(html) {
	var rng	= this.get_selection_range();
	var iframe_window = this.iframe.contentWindow;

	if(!rng){
		this.editor_cmd('inserthtml', html);	
	}

	if(iframe_window.getSelection) {
		var text = this.iframe_doc.createTextNode(html);
		var selection = iframe_window.getSelection();
		rng.deleteContents();
		rng.insertNode(text);
		rng.selectNodeContents(text);
		selection.collapse(selection.focusNode,selection.focusOffset);
	} else {
		rng.pasteHTML(html);
	}
	iframe_window.focus();
}

