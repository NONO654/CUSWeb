define('DS/ENXDataGrid/ENXRMBMenu',
		[
			'emxUICore',
			'emxUIModal',
			'emxUIConstants',
			'emxUITableUtil'
			
		],
		function(
				emxUICore,
				emxUIModal,
				emxUIConstants,
				emxUITableUtil
		){
	
	"use strict";
	var TweakerRMBMenu = {
		
			rmbClickAction: function(args){
				var targetPath = encodeURI(args.targetPath);
				var targetLocation = args.targetLocation;
				var strHref = args.href;
				var isModal = args.isModal;
				var width = args.itemWidth || '600';
				var height = args.itemHeight || '600';

				if(targetLocation == 'listHidden'){
					var objFrame = this.findFrame(window,targetLocation);
					submitWithCSRF(targetPath,objFrame);
					var customHref = args.customHref;
					emxUICore.addToPageHistory(customHref);
				}
				
				if(targetLocation == 'content' || targetLocation == 'popup'){
					window.open(targetPath,"Modal Dialog",'width=' + width + ',height='+ height);
				}
				
				if(targetLocation == 'slidein'){
					targetPath = targetPath.split(",");
					var href = targetPath[0];
					var openerFrame = targetPath[1];
					openerFrame = openerFrame.replace('$OPENERFRAME$', window.name);
					if(targetPath.indexOf("right")!= -1){
						
						var direction = targetPath[2];
						var slideInWidth = targetPath[3];
						getTopWindow().showSlideInDialog(href,isModal,openerFrame,direction,slideInWidth);
					}else{
						getTopWindow().showSlideInDialog(href,isModal,openerFrame);
					}
				}
				
				if(targetLocation == ''){
					if(strHref.indexOf("javascript:") != -1){
						var executeMethod = strHref.split("javascript:")[1];
	
//						executeMethod = 'alert("hi")';
						
						// find object
						var fn = window[executeMethod];
						// is object a function?
						if (typeof fn === "function")
							fn();
						else
							eval(executeMethod);
					}
					else{
						window.open(strHref,"Modal Dialog",'width=' + width + ',height='+ height);
					}
				}
				
			},
			
			findFrame: function(objWindow,locationString){
				switch(locationString) {
                case "_top":
                        return getTopWindow();
                case "_self":
                        return self;
                case "_parent":
                        return parent;
                default:
                     var objFrame = null;
                try{
    				for (var i = 0; i < objWindow.frames.length && !objFrame; i++) {
    					try {
    						if (objWindow.frames[i].name == locationString) {
    							objFrame = objWindow.frames[i];
    						}
    					} catch(ex){
    					}
    				}
    				for (var i=0; i < objWindow.frames.length && !objFrame; i++) {
    					objFrame = this.findFrame(objWindow.frames[i], locationString);
    				}
    			}catch (e){}
                            return objFrame;
			}
				
			}
			
	};

	return TweakerRMBMenu;
	
});

