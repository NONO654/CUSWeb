Compass = {
	init:function(compassTarget){
		ds = {};

		require(['UWA/Core'], function(UWA) {
		    UWA.Data.proxies.ajax = donwloadpf;
		    UWA.Data.proxies.passport = crossproxy;
		    require(['i3DXCompass/i3DXCompass'], function (Compass) {
		        Compass.initialize(
		            {
		                compassTarget : compassTarget,
		                baseImgPath : "../webapps/i3DXCompass/assets/images/",
		                myAppsBaseURL : myAppsURL,
		                baseHtmlPath: clntbaseHtmlPath,
		                baseNlsPath: clntbaseNlsPath,
		                baseAppletPath : "../WebClient/",
		                appsTarget : "appsPanel",
		                closable : true,
		                dynamic: true,
		                lang: clntlang,
		                userId:curUserId,
		                passportUrl:passportURL,
		                proxyTicketUrl:proxyTicketURL,

						launchOnSameDomain : function (url) {
							if(isWindowShadeOpened()){
								closeWindowShadeDialog();
							}
							ds.isCompassOpen = false;
							launchEnoviaApp(url);
							Compass.hideAccordion();
							if(getTopWindow().isPanelOpen){
								getTopWindow().openPanel();
							} else {
								getTopWindow().closePanel();
							}
							getTopWindow().jQuery('#appsPanel')[0].style.display = "none";
							return true;
						},
						onOpen: function () {
							ds.isCompassOpen = true;
							if(isChangeSCDialogOpen()){
								closeSecurityContextDialog();
							}

							if(!emxUISlideIn.is_closed || showSlideInDialog.mode == "tag navigator"){
								closeSlideInDialog();
								showSlideInDialog.mode = "";
							}
							var appPanel_width = getTopWindow().jQuery('#appsPanel').innerWidth();
							getTopWindow().jQuery("div#pageContentDiv").animate({'left' : appPanel_width+'px'}, 200);
							getTopWindow().jQuery("div#divExtendedHeaderContent").animate({'left' : appPanel_width+'px'}, 200);
							getTopWindow().jQuery('#appsPanel')[0].style.display = "block";
							emxUICore.setIdtoCompass();
							/*var ctxId = emxUICore.getContextId(true);
							if(ds.resetObj != false)
							{
							if(ctxId && ctxId != '' &&  ctxId != 'undfined'){
								var obj = {
									objectType: 'mime/type',
									objectId: ctxId,
									envId: curTenant,
									contextId: curSecCtx
								};
								// Set the object
		                    Compass.setObject(obj);
							} else {
		                    Compass.resetObject();
							}
							} else {
								ds.resetObj = true;
							}*/
						},
						onClose: function () {
							ds.isCompassOpen = false;
							if(getTopWindow().isPanelOpen){
								getTopWindow().openPanel();
							} else {
								getTopWindow().closePanel();
							}
							getTopWindow().jQuery('#appsPanel')[0].style.display = "none";
						},
						/**
			             * This function is called by the Compass when a change on role selection occurs. A role switches form selected to unselected
			             * @param {String}   roleId           - ID of the role (process) that changed
			             * @param {Number}   active           - true if the role is selected, false if not
			             */
			            onRoleChange: function (roleId, active) {
			            	if(active){
			            		jQuery('li#'+roleId).addClass("selected").attr("active","true");
			            		
			            	} else {
			            		jQuery('li#'+roleId).removeClass("selected").attr("active","false");
			            	}
						}
		            });

		        ds.Compass = Compass;
			});
		});
		}
};

