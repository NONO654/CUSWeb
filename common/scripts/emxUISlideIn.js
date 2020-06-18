//=================================================================
// JavaScript emxUISlideIn.js
// version: 2.0.1
// Copyright (c) 1992-2018 Dassault Systemes.
//=================================================================
var shortcutState;
var objElm;
var emxUISlideIn = {
        name : "",
        last_slidein : [],
        current_slidein : null,
        is_closed : true,
        slidein_template : function (name,width) {
            if(jQuery('#' + name + 'SlideIn').length){
            	objElm = jQuery('#' + name + 'SlideIn');
                if(width != null && width != 'undefined' && width != 'null' && width != ''){
                	objElm.css({'width':width+'px'});
            } else {
                	objElm.css({'width':'350px'});	
                }
                return objElm;
            } else {
                objElm = jQuery('<div id="' + name + 'SlideIn" class="slide-in-panel dialog"></div>');
                if (name == "right") {
                    objElm.append(jQuery('<iframe frameborder="0" name="slideInFrame"></iframe>'));
                    objElm.css({'right':'0px'});
                    if(width != null && width != 'undefined'){
                    	objElm.css({'width':width+'px'});
                    }
                }
                jQuery('body', getTopWindow().document).append(objElm);
                return objElm;
            }
        },
        get_last_slidein : function () {
            return this.last_slidein.pop();
        },
        set_last_slidein : function (slideIn) {
            this.last_slidein.push(slideIn);
        },
        left : {
            page_content_css : function () {
                return {'left' : emxUISlideIn.current_slidein.css('width')};
            },
            panel_slidein_css : {
                'left': '0'
            }
        },
        right : {
            page_content_css : function () {
                return {'right' : emxUISlideIn.current_slidein.css('width')};
            },
            panel_slidein_css : {
                'right': '0'
            }
        },
        set_current : function (slideIn) {
            this.current_slidein = slideIn;
        },
        close_current : function (obj) {
            if(this.current_slidein){
                var dir    = this.current_slidein.dir;
                if (obj && obj.dir !== dir) {//don't close if it is the same side as last dialog
                	var sameSideSlidein = false;
                	closeSlideInDialog({'panel' : this.current_slidein}, sameSideSlidein);
                }
            }
        },
        set_closed : function () {
            this.is_closed = true;
            this.current_slidein = null;
        },
        set_opened : function () {
            this.is_closed = false;
        }
};

function adjustLeftSlideIn(slideinWidth){
	var appPanleWidth = (emxUICore.getWinWidth(getTopWindow()))/4 ;
	if(slideinWidth){
		appPanleWidth = slideinWidth;
	} else {
		if(appPanleWidth < 300)
			appPanleWidth = 300;		
		else if(appPanleWidth >400)
			appPanleWidth = 400;

		jQuery("#appsPanel").css("width",appPanleWidth+"px");
		if(jQuery("#appsPanel").is(':visible')){
			jQuery("#pageContentDiv").css('left', appPanleWidth+'px');
		}		
	}
	

	jQuery('#leftSlideIn').css("width",appPanleWidth+"px");
    	if(jQuery("#leftSlideIn").is(':visible')){
    		jQuery('#pageContentDiv').css("left",appPanleWidth+"px");
    	}
    	jQuery('#leftSlideIn').css("top",getTopWindow().toppos+"px");
    	jQuery('#appsPanel').css("top",getTopWindow().toppos+"px");
}

function adjustNavButtons(){
	if (emxUISlideIn.is_closed){
		jQuery('#divExtendedHeaderNavigation').css('right', '0');
	}else{
		jQuery('#divExtendedHeaderNavigation').css('right', '354px');
	}
}

/*
 * @author - SNA4
 * description - This API will provide the wider slide in functionality
 * if slideinWitdh specified window will be resized to the provided width
 * else then API will set the width to default width mentioned in the properties file
 */
function showSlideInDialog(url, isModal, openerFrame, direction,slideinWidth){
	// call showWiderSlideInDialog if the slideinWidth has some value specified by user
	// else if the slideinWidth specified as wide , then take the value from the properties file
	
	if(slideinWidth != null)
	{
		if(slideinWidth == 'wide'){
			slideinWidth = emxUIConstants.WIDER_SLIDEIN_VALUE;
		} else if( slideinWidth <= 350 ){
			slideinWidth = null; 
		}
		else if( slideinWidth >= 900){
			 slideinWidth = 900;
		}
		
	}
	//showWiderSlideInDialog(url , isModal, openerFrame , "990");
    var dir = (direction == "left") ? "left" : "right";
    //close other slideins
    emxUISlideIn.close_current({'dir' : dir});
    //open this slidein
    var slideIn = emxUISlideIn.slidein_template(dir,slideinWidth);

    if(dir == "left"){
    	if(slideinWidth){
    		adjustLeftSlideIn(slideinWidth);
    	} else {
    		adjustLeftSlideIn();
    	}
    } else {
    	jQuery('#rightSlideIn').css("top",getTopWindow().toppos+"px");
    }

    slideIn.css('top',jQuery('#pageHeadDiv').height());
    slideIn.dir = dir;
    emxUISlideIn.set_current(slideIn);

	if(isModal) {
		jQuery("div#layerOverlay").css('display', 'block');
        jQuery("div#layerOverlay").css('top',0);
		if(dir == "right" && typeof jQuery("div#topbar") != "undefined" && jQuery("div#topbar").length > 0){
			jQuery("div#topbar")[0].addClassName("slide-in-dialog slide-in-context");
		}
	}

        slideIn.css('z-index', '250');
        jQuery('div#leftSlideIn').css('z-index','250');
        jQuery('div#rightSlideIn').css('z-index','1250');
		
    if (dir == "right") {
        if(url.indexOf("javascript:") == 0){
		eval(url);
        } else {
            url = url + "&openerFrame="+encodeURIComponent(openerFrame);
            	url = url+"&targetLocation=slidein";
            if(slideinWidth != 'undefined' && slideinWidth != null) {
            	url = url +"&slideinType=wider";
            }
        	findFrame(getTopWindow(), 'slideInFrame').location.href = url;
            slideIn.slideInFrame = 'slideInFrame';
        }
    } else {
        if (emxUISlideIn.current_slidein.find('#tn-target').length){
            jQuery('#tn-target').hide();
            jQuery('body').append(jQuery('#tn-target'));
        }
        slideIn.load(url, function () {
            if (showSlideInDialog.mode == "refinements") {
                emxUIAutoFilter._set_id(url);
            }
        });
    }

    //if (emxUISlideIn.is_closed){//only slidein if not already there
    	if(emxUIConstants.STR_SLIDEIN_ANIMATIONTYPE == 'fade'){
            jQuery("div#pageContentDiv").css(emxUISlideIn[dir].page_content_css());
            slideIn.css(emxUISlideIn[dir].panel_slidein_css)
            .fadeIn(emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
    	} else {
            slideIn.animate(emxUISlideIn[dir].panel_slidein_css, emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
            jQuery("div#pageContentDiv").animate(emxUISlideIn[dir].page_content_css(), emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
            if(dir == "left"){
            	jQuery("div#divExtendedHeaderContent").animate(emxUISlideIn[dir].page_content_css(), emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
            }
    	}

        slideIn.css('display', 'block');
        emxUISlideIn.set_opened();

        if (dir == "right") {
            adjustNavButtons();
        }
    //}

	//jQuery was returning the default value for style when it's actually null and hence we are fetching the value using getElementById
	var dispalyStyle = jQuery(document.getElementById('windowshade')).is(':visible')? 'block' : 'none';
    if(getTopWindow() && getTopWindow().closeWindowShadeDialog && jQuery("div#windowshade") && dispalyStyle.length != 0 && dispalyStyle != "none" ) {
    	getTopWindow().closeWindowShadeDialog();
    }
}
function showShortcutDialog(){
	shortcutState=true;
	var key = "";
	if(getTopWindow().opener){
		key = getTopWindow().window.name;
	}else{
		key="Shortcut_Content";
	}

	jQuery.ajax({
		   url: "../common/emxShortcutGetData.jsp?action=initializeShortcutMap&key="+key,
		   cache: false
	});

	var ts = new Date().getTime();//prevent caching of filter page in IE
    getTopWindow().showSlideInDialog('../common/emxShortcut.jsp?no-cache='+ts+'&key='+key, false);
}

function closeShortcutDialog(){
	shortcutState=false;
	closeSlideInPanel();
}

function refreshShortcut(){
	if(shortcutState == true){
		setTimeout("showShortcutDialog()",100);
	}
}

function closeSlideInDialog(obj, sameSideSlidein){
    if (emxUISlideIn.current_slidein.find('#tn-target').length){
        jQuery('#tn-target').hide();
        jQuery('body').append(jQuery('#tn-target'));
    }
	if (jQuery("#pageContentDiv")){
        jQuery("#pageContentDiv").css('right', '0px');
    }
	closeSlideInPanel(obj);

	// var sameSideSlidein = false means the current slidein direction is not same as previous slidein
	// In that case the Shortcut slidein window will not open.
	// IR-198167V6R2014: Fixed as part of this IR
	if(shortcutState == true && sameSideSlidein !== false){
		setTimeout("showShortcutDialog()",20);
	}

}

function closeSlideInPanel(obj) {

    obj = obj || {'panel' : emxUISlideIn.current_slidein};
    var cntpos = getTopWindow().leftpos;
    if(typeof ds != "undefined" && ds.isCompassOpen){
		cntpos = "300px";
	}else if (jQuery("div#leftPanelMenu").is(':visible') && parseInt(jQuery("div#leftPanelMenu").css('left')) >= 16){
		cntpos = jQuery("div#leftPanelMenu").width() +  jQuery("div#panelToggle").width() + 'px';
	}else if(parseInt(jQuery("div#mydeskpanel").css('left')) < 0){
		cntpos = jQuery("div#panelToggle").width() + 'px';
	}
	else if(jQuery("div#mydeskpanel").length == 0){
		cntpos = 0 + 'px';
	}
    var dir = obj.panel.dir,
        fadeWidth = "-" + obj.panel.css('width');
	if(emxUIConstants.STR_SLIDEIN_ANIMATIONTYPE == 'fade'){
        obj.panel.fadeOut(emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED, function() {
            obj.panel.css(dir, fadeWidth);
            jQuery("div#pageContentDiv").css(dir,cntpos);
		});
	}else {
		if(dir=='right'){
        obj.panel.animate({'right': fadeWidth}, emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
		}else{
		obj.panel.animate({'left': fadeWidth}, emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
		}
        if(jQuery("div#panelToggle").is('.open') && getTopWindow().isMobile){
			jQuery("div#pageContentDiv").animate({'left': '230px', 'right' : '0px'}, emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);
		}else{
           jQuery("div#pageContentDiv").animate({'left': cntpos, 'right' : '0px'}, emxUIConstants.NUM_SLIDEIN_ANIMATIONSPEED);}
        jQuery("div#divExtendedHeaderContent").css('left','0px');
	}

    obj.panel.css('display', 'none');
    obj.panel.css('z-index', '50');

	jQuery("div.content-mask").css('display', 'none');
    if (dir == 'right') {
        findFrame(getTopWindow(), 'slideInFrame').location.href = "../common/emxBlank.jsp";
}
    emxUISlideIn.set_closed();
    if (dir == 'right') {
        adjustNavButtons();
		if(typeof jQuery("div#topbar") != "undefined" && jQuery("div#topbar").length > 0){
			jQuery("div#topbar").removeClass("slide-in-dialog  slide-in-context");
		}
		jQuery('#content').contents().find('#middle').css('float','right');
    }
}

var gSearchURL = "";
function showDefaultSearch() {
	if(gSearchURL.length == 0){
		showWindowShadeDialog("../common/emxFullSearch.jsp?table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&showInitialResults=false&genericDelete=true", true);
	}
	else{
		showWindowShadeDialog("","",true);
	}
}

function showWindowShadeDialog(url, isModal,showOnlyDiv, genericShade){
	var divName = genericShade ? 'genericwindowshade' : 'windowshade';
	var frameName = genericShade ? 'genericWindowShadeFrame' : 'windowShadeFrame';
	if(jQuery('div#windowshade')){
	   jQuery('div#layerOverlay').addClass('search-mask') ;
	}
	if(true) {
		jQuery('div.group-center')[0].className ="toolbar group-center";
		if(emxUIConstants.STR_QUERY_TYPE == 'Indexed' && !genericShade){
			jQuery('#AEF6WTagger').addClass('disabled');
		}
	}
	jQuery("div#"+divName).zIndex(1251);
	if(url && url.indexOf('emxFullSearch.jsp')>- 1){
		gSearchURL = url;
	}
	if(!showOnlyDiv){
	frames[frameName].location.href = url + "&targetLocation=windowshade";
	}
	var closeHeight = jQuery("div#"+divName).height() + "px";
	jQuery("div#"+divName).css("bottom", closeHeight);

	if(emxUIConstants.STR_WINDOWSHADE_ANIMATIONTYPE == 'fade'){
		jQuery("div#"+divName).css("bottom", '0px');
		if(typeof browsers != 'undefined' && !browsers.SAFARI){
			jQuery("div#"+divName).fadeIn(emxUIConstants.NUM_WINDOWSHADE_ANIMATIONSPEED);
		}
	} else {
		jQuery("div#"+divName).animate({bottom:'0px'}, emxUIConstants.NUM_WINDOWSHADE_ANIMATIONSPEED);
	}

	jQuery("div#"+divName).css('display', 'block');
	addMaskToGlobalToolbar(genericShade);
	jQuery("div#"+divName).css('top',(jQuery('#pageHeadDiv').height() - jQuery('div#tabBar').height()));
	jQuery('div.group-center')[0].className ="toolbar group-center";
}


function closeWindowShadeDialog(genericShade, forDrag){
	var divName = genericShade ? 'genericwindowshade' : 'windowshade';
	jQuery('div.group-center')[0].className ="toolbar group-center";
	var closeHeight = jQuery("div#"+divName).height() + "px";
	getTopWindow().refreshShortcut();
if(emxUIConstants.STR_QUERY_TYPE == 'Indexed'  && !genericShade){
		jQuery('#AEF6WTagger').removeClass('disabled');
	}
	if(genericShade){
		 jQuery('.active').removeClass('active');
	}
	//if(!jQuery('div.windowshade').is(":visible")){
		closeMaskToGlobalToolbar(genericShade);
	//}

	if(forDrag){
		jQuery("div#"+divName).fadeOut(1500);
		/*jQuery("div#"+divName).zIndex(-2);
		jQuery("div#"+divName).animate({'z-index': -2}, 1000, 'linear', function(){
			jQuery("div#"+divName).css('z-index', -2);
		});*/
	} else if(emxUIConstants.STR_WINDOWSHADE_ANIMATIONTYPE == 'fade'){
		jQuery("div#"+divName).fadeOut(emxUIConstants.NUM_WINDOWSHADE_ANIMATIONSPEED, function(){
			//jQuery("div#"+divName).css('z-index', '50');
			jQuery("div#"+divName).css('bottom', closeHeight);
		});
	} else {
		jQuery("div#"+divName).animate({bottom: closeHeight}, emxUIConstants.NUM_WINDOWSHADE_ANIMATIONSPEED, function(){
			//jQuery("div#"+divName).css('z-index', '50');
		});
	}
}
function isWindowShadeOpened(){
		if((typeof $("div#windowshade")[0] !="undefined" &&  $("div#windowshade")[0].style.display == 'block') ||  (typeof $("div#genericwindowshade")[0] !="undefined" && $("div#genericwindowshade")[0].style.display == 'block')){
			return true;
		}else{
			return false;
		}
}
/*V6R2014 UKU
To add mask to Gloabl toolbar;so that user cannt click on any item on GLOBAL TOOLBAR apart from search
*/
function addMaskToGlobalToolbar(genericShade){
	if(isWindowShadeOpened() || isChangeSCDialogOpen()){

		jQuery("div#layerOverlayRight").css('display', 'block');
		jQuery("div#layerOverlayLeft").css('display', 'block');
		jQuery("div#layerOverlay").css('display', 'block');
		if(genericShade){
			jQuery("div#layerOverlay").css('top',0);
		} else {
			jQuery("div#layerOverlay").css('top',jQuery('div#globalToolbar').height());
		}
	}
}

function closeMaskToGlobalToolbar(genericShade){
	jQuery("div#layerOverlayLeft").css('display', 'none');
	jQuery("div#layerOverlayRight").css('display', 'none');
	jQuery("div#layerOverlay").css('display', 'none');
	jQuery("div#layerOverlay").css('top','0');
	if(!genericShade){
		jQuery('div.group-center')[0].className ="toolbar group-center";
		}
}

function isChangeSCDialogOpen(){
	if((typeof jQuery("div#panelouter")[0] !="undefined" &&  jQuery("div#panelouter")[0].style.visibility == "visible")){
		return true;
	} else {
		return false;
	}
}

function closeSecurityContextDialog()
{
	document.getElementById("panelouter").style.visibility = "hidden";
	jQuery("div#panelouter").hide();
	closeMaskToGlobalToolbar(true);
	$('#switchContextDialog').innerHTML = "";
}

function changeSecurityContextDialog(collabSpace)
{
	//var scurl = "emxSecurityContextSelection.jsp?switchContext=true&ts="+(new Date).getTime();
	var scurl = "emxSecurityContextSelection.jsp?switchContext=true";
	if(jQuery('div#layerOverlay').hasClass('search-mask')){
	jQuery('div#layerOverlay').removeClass('search-mask') ;
	}
	if(collabSpace != null )
	{
		scurl = scurl + "&collabSpace="+encodeURIComponent(collabSpace);
	}
	var frameContent = findFrame(getTopWindow(),"content");
	
	if(frameContent.cntFrameURL != null && typeof frameContent.cntFrameURL != "undefined"){
		var cntFrameURl = frameContent.cntFrameURL;
		if(cntFrameURl.contains("collabSpace")){
			
			cntFrameURl = emxUICore.removeURLParam(cntFrameURl,"collabSpace");
		}
		scurl= scurl + "&ContentURL="+cntFrameURl;
	}else{
		scurl= scurl + "&ContentURL="+frameContent.document.location.href;
	}
	$('#switchContextDialog').load(scurl, {noncache: new Date().getTime()},  function(){
		var pnlouter = document.getElementById('panelouter');
	    var hlfht = pnlouter.offsetHeight;
	hlfht = hlfht/2;
	    var tp = '-' + hlfht + 'px';
	    pnlouter.style.marginTop = tp;

	    var hlflft = pnlouter.offsetWidth;
	    hlflft = hlflft/2;
	    var lft = '-' + hlflft + 'px';
	    pnlouter.style.marginLeft = lft;
		pnlouter.style.visibility = "visible";
	addMaskToGlobalToolbar(true);
	});
	if(emxUICore.objElem.dynamicName != "AEFPersonMenu"){
	showMarkOnMenuItem(event.currentTarget,jQuery(event.target).parents('div.menu-panel'));
	}
}

//This function is called on "My Physical Location" command from Gloabl toolbar
function changePhysicalLocationDialog(collabSpace)
{
	var scurl = "../exportcontrol/EXCPhysicalLocationCountryChange.jsp";
	if(jQuery('div#layerOverlay').hasClass('search-mask')){
		jQuery('div#layerOverlay').removeClass('search-mask') ;
	}
	if(collabSpace != null )
	{
		scurl = scurl + "&collabSpace="+encodeURIComponent(collabSpace);
	}
	$('#switchContextDialog').load(scurl, {noncache: new Date().getTime()},  function(){
		var pnlouter = document.getElementById('panelouter');
		var hlfht = pnlouter.offsetHeight;
		hlfht = hlfht/2;
		var tp = '-' + hlfht + 'px';
		pnlouter.style.marginTop = tp;

		var hlflft = pnlouter.offsetWidth;
		hlflft = hlflft/2;
		var lft = '-' + hlflft + 'px';
		pnlouter.style.marginLeft = lft;
		pnlouter.style.visibility = "visible";
		addMaskToGlobalToolbar(true);
	});
	if(emxUICore.objElem.dynamicName != "AEFPersonMenu"){
		showMarkOnMenuItem(event.currentTarget,jQuery(event.target).parents('div.menu-panel'));
	}
}
