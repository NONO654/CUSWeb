define(
    'DS/Param/UIUtilities',
    [
        'UWA/Core',
        'UWA/Controls/Abstract',
        'DS/UIKIT/Core',
        'DS/UIKIT/Spinner',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Alert',
        'i18n!DS/ParameterizationWidget/assets/nls/ParamWdgNLS'
    ],
    function(UWA, Abstract, Core, Spinner, Button, Modal, Alert, ParamWdgNLS) {
       var paramUIUtils = {

                beingDeployed: function (imageCell, imgTitle) {
                    var paramDeploySpinner = new Spinner({visible : true});
                    imageCell.empty();
                    paramDeploySpinner.inject(imageCell);
                    imageCell.set("Title", imgTitle);
                },

                updateIcon : function(result, imageCell) {
                    var imgSpan,
                        imgTitle = 'Deployed',
                        imgClass = 'fonticon fonticon-2x fonticon-check',
                        iconColor = 'green';

                    imageCell.empty();

                    if (result != true) {
                        imgClass = 'fonticon fonticon-2x fonticon-alert';
                        imgTitle = 'Not Yet Deployed';
                        iconColor = 'red';
                    }
                    imgSpan = UWA.createElement('span', {
                        'class' : imgClass
                    }).inject(imageCell);
                    imgSpan.setStyle("color", iconColor);
                    imageCell.set("Title", imgTitle);
                },

                updateIconId : function(imageCell) {
                    var imgTitle = 'Not Deployed',
                        imgClass = 'fonticon fonticon-2x fonticon-cog',
                        iconColor = 'orange';

    				imageCell.empty();
    				var imgSpan = UWA.createElement('span', {
    					'class' : imgClass
    				}).inject(imageCell);

    				imgSpan.setStyle("color", iconColor);
    				imageCell.set("Title",imgTitle);
    			},

    			inputError : function (imageCell, imgTitle)
    			{
    				var imgClass = 'fonticon fonticon-2x fonticon-attention';
    				imageCell.empty();

    				var imgSpan = UWA.createElement('span', {
    					'class' : imgClass     	  
    				}).inject(imageCell);

    				imgSpan.setStyle("color", 'red') ; 	
    				imageCell.set("Title",imgTitle);
    			},
    			
    			beingModified : function (imageCell, imgTitle) {           	      		  		
    				var imgClass = 'fonticon fonticon-2x fonticon-pencil';
    				imageCell.empty();
    						
    				var imgSpan = UWA.createElement('span', {
    					'class' : imgClass     	  
    				}).inject(imageCell);
    				
    				imageCell.set("Title",imgTitle);  		
    			},    		

    			isInteger : function (str) {            
    			    str = str.trim();
    			    return /^[-+]?[0-9]+$/.test(str);
    			},
    			
    			testSpecialCharacters : function (iString)
				{ 		    		
    				var iChars = "!#$%^&*()+=[]\\\';,/{}|\":<>?";//-

		 			for (var i = 0; i < iString.length; i++)						
		 				if (iChars.indexOf(iString.charAt(i)) != -1)	
		 			  		return true;
		 			
		 			return false;		
		 		},	

    			createParamAccordion : function ()
    			{
    				var iAccord = new UWA.Controls.Accordion({
    					'className': 'visu-debug-panel-section', 
    					backgroundColor:'white', 
    					multiSelect: true});     
    				return iAccord;			
    			},

    			createSubParamDiv : function (iTooltip) {
    				var isubDiv =  UWA.createElement('div',{
    			 		html: [{  'tag': 'p',
    			             	  'text': ''
    			             	 },
    			             	 {
    			             		'tag': 'p',
    			             		'text': iTooltip,
    			             		'title' : iTooltip
    			             	 }]	,
    			 	});
    				return isubDiv;
    			},

    			clearDivContent : function (sDiv)
    			{
    				var currContent = sDiv.getChildren();  	

    				for (var i=0; i<currContent.length; i++)			
    					currContent[i].destroy();
    				
    				sDiv.destroy();
    			},
    			
    			createWdgAlert : function () {
    				var iAlert = new Alert({
         				closable: true,
         				visible: true,
                        autoHide : true,
                        hideDelay : 2500,
         			});
    				return iAlert;
    			},
    			
    			createResetToolbar : function (resetModal, insertDiv, fctResetProceed) {
                    var applyDiv, tableButtons, lineButtons,
                        buttonResetCell, resetBbttn,
                        that = this;

                    applyDiv =  UWA.createElement('div', {
                        'id': 'resetDiv'
                    });//.inject(insertdivID);
                          
                    tableButtons = UWA.createElement('table', {
                        'class' : '',
                        'id' : '',
                        'width' : '100%'
                    }).inject(applyDiv);

                    lineButtons = UWA.createElement('tr').inject(tableButtons);  // tbody
                          
                    buttonResetCell = UWA.createElement('td', {
                        'width' : '100%',
                        'Align' : 'right'
                    }).inject(lineButtons);
                    //
                    resetBbttn = new Button({
                        className: 'warning',
                        icon: 'arrows-ccw', //'loop',
                        attributes: {
                            disabled: false,
                            title: ParamWdgNLS.ResetOnServertooltip,
                            text : ParamWdgNLS.Reset
                        },
                        events: {
                            onClick: function () {
                            	that.confirmationModalShow(resetModal, insertDiv, fctResetProceed);                            
                            }
                        }
                    }).inject(buttonResetCell);
                    //
                    resetBbttn.getContent().setStyle("width", 120);
                    return applyDiv;
                },
                
                confirmationModalShow : function (resetModal, insertDiv, fctResetProceed) {
            		var headertitle,
            			OKBtn, CancelBtn,   
            			bodyDiv;//confirmResetModal,
            		
        				UWA.log("confirmationModalShow");

            			if (resetModal !== null) {
                            resetModal.show();//Modal already exists
                            UWA.log("Modal already exists");
            			} else {
            				UWA.log("Modal Create");
            				headertitle = UWA.createElement('h4', {
	            				text   : ParamWdgNLS.confirmResetTitle,
	            				'class': 'font-3dslight' // font-3dsbold
	            			});

	            			OKBtn = new Button({
	            				value : ParamWdgNLS.OKButton,
	            				className : 'btn btn-primary',
	            				events : {
	            					'onClick' : function() {
	            						UWA.log("DoSomething");
	            						fctResetProceed();
	            					}
	            				}
	            			});
	            			//    
	            			CancelBtn = new Button({
	            				value : ParamWdgNLS.CancelButton,
	            				className : 'btn btn-default',
	            				events : {
	            					'onClick' : function(e) {
	            						UWA.log("Cancel");
	            					}
	            				}
	            			});
	            			bodyDiv = UWA.createElement('div', {
	                            'id': 'resetContentDiv',
	                            'width' : '100%',
	                            'height': '100%'
	                        });
	            			UWA.createElement('p', {
	                            text   :  ParamWdgNLS.confirmResetMsg,
	                            'class': 'font-3dslight'// font-3dsbold
	                        }).inject(bodyDiv);
	            			//
	            			resetModal = new Modal({
	            				className: "reset-confirm-modal",
	            				closable: true,
	            				header: headertitle,
	            				body:   bodyDiv,
	            				footer: [ OKBtn, CancelBtn ]
	            			}).inject(insertDiv);
	            			//
	            			resetModal.getContent().setStyle("padding-top", 1);
	            			resetModal.show();
	            			//
	            			resetModal.getContent().getElements(".btn").forEach(function (element) {
	            				element.addEvent("click", function () {
	            					resetModal.hide();
	            				});
	            			});
            			}
                     },

                     buildDeployStsCell : function (isParamDeployed, cellWidth) {
                    	var imgCell, imgSpan,
                    		imgTitle = ParamWdgNLS.deployedParamtxt,
                    		imgClass = 'fonticon fonticon-2x fonticon-check',
                    		iconColor = 'green';

                   		if (isParamDeployed == "false") {
                   		 	imgClass = 'fonticon fonticon-2x fonticon-cog';
                   		 	imgTitle =  ParamWdgNLS.notdeployedParamtxt;
                   			iconColor = 'orange';
                   		}

                   		imgCell = UWA.createElement('td', {
                   			'width': cellWidth, //'15%',
                         	'align':'right',//'class': 'paramtd','vertical-align': 'text-bottom',
                         	'title': imgTitle
                        });
 		    		
                   		imgSpan = UWA.createElement('span', {
                   			'class' : imgClass
                 		}).inject(imgCell);
                   		
                   		imgSpan.setStyle("color", iconColor);
                   		imgCell.setStyle("vertical-align", "text-bottom");
                   		
                   		return imgCell;
                     },
                     
                     buildControlCell : function (iParamID, iArgID, iArgDefault, cellWidth) {
                    	 var controlObjectCell = UWA.createElement('td', {
                    		 'width' : cellWidth
                    	});
                    	controlObjectCell.setData('argumentNode', {
                	    	   paramid		: iParamID,
                        	   argumentid	: iArgID,
                        	   defaultval	: iArgDefault
                       	});
                    	controlObjectCell.setStyle("vertical-align", "text-bottom");
                    	return controlObjectCell;
                     },
                     
                 	 clearPreviousAccordionContent : function(iAccord) {
     					var i,
     						currContent = iAccord.getContent(),
     						nbiterations = currContent.childElementCount;

     					for (i = 0; i < nbiterations; i++) {		
     						currContent.childNodes[0].destroy();
     					}
     				 }
    	};

    	return paramUIUtils;
        	
});

define(
    'DS/Param/CommonUtilities',
    [
        'UWA/Core',   
        'UWA/Controls/Abstract',
   	 	'DS/UIKIT/Core'
    ],
    function(UWA,Abstract,Core){
    	//@fullReview  ZUR 14/10/11 2015x HL Param Widgetization
    	var paramUtils = {
    			    			    
    			paramStructBuilder: function (fields) 
    			{
    				var fields = fields.split(',');
    				var count = fields.length;

    				function constructor() 
    				{
    					for (var i = 0; i < count; i++)
    						this[fields[i]] = arguments[i];
    				}
    				return constructor;
    			},    			
    		
    			requestDataFromServer : function (wdgProps,completeFct,failFct) 
    			{         		
    				var url = wdgProps.env_url+'/resources/ParamWS/access/DomainInfo';  
        			console.log("requestDataFromServer::"+url);
         		
        			UWA.Data.request(url, {
  						
    				data: {
    					domainid: wdgProps.domainName,
    					tenant : wdgProps.tenantID
    				},
    				headers: {
						'Accept' : 'application/ds-json',
						'Content-Type' :'application/ds-json',
						'Accept-Language' : widget.lang
         			},
    				method: 'get', 
    				type: 'json',// application/ds-json
    				proxy: 'passport',					
    				//cache: 0,
    				onComplete: function(json){
    					completeFct(json); },
         			onFailure: function(json){
         				failFct(json);}
	        		});

    			},//of Function requestDataFromServer  
    			
    			ApplySingleParamModifOnServer:function(wdgProps, ctrlObjectCell, iValue, theImageCell, onSuccessfct, onFailurefct)
    			{
    				var url = wdgProps.env_url+"/resources/ParamWS/access/postparams?tenant="+wdgProps.tenantID;               
    	
		   	 		var ParamID = ctrlObjectCell.getData('argumentNode').paramid;
   					var argID = ctrlObjectCell.getData('argumentNode').argumentid;
 
        			var jsonArr = [];                  
        			var ArgArr = [];
                     	               	   
        			ArgArr.push({id:argID,value:iValue});
        	   
        			var iParam = {
        		   			domain:wdgProps.domainName,        				
    			   			id:ParamID,
   	   			   			argument : ArgArr
   	   				};
        	                			
       	 			jsonArr.push(iParam);
		  	
         			var datatoSend = {
        	   		domain 	 : wdgProps.domainName,
        	   		parameter:jsonArr
         			};               
                                	
           			UWA.Data.request(url, {
           				timeout: 100000,
              			method: 'POST',             
              			data: JSON.stringify(datatoSend),
             			type: 'json',
                		proxy: 'passport',
                 
             			headers: {
                 			'Content-Type':'application/ds-json',
                 			'Accept': 'application/ds-json'                                        
            			},

             			onFailure : function (json) {
             				onFailurefct(json, theImageCell);  
                 		},
             
             			onComplete: function(json){                	 		
             				onSuccessfct(json, theImageCell);
                 		}                  
             		});        
    			},
    			    			
    			GetTicketForDownload:function(wdgProps, onSuccessfct, onFailurefct)
    			{    			
    				var url = wdgProps.env_url+'/resources/ParamWS/access/getCheckoutParamFileTicket';  
        			console.log("requestDataFromServer::"+url);
         		
        			UWA.Data.request(url, {  						
    				data: {    	
    					tenant : wdgProps.tenantID
    				},
    				headers: {
             		'Accept': 'application/ds-json',
             		'Content-Type':'application/ds-json'
         			},
    				method: 'get', 
    				type: 'json',
    				proxy: 'passport',					
    				onComplete: function(json){
    					onSuccessfct(json); },
         			onFailure: function(json){
         				onFailurefct(json);}
	        		});				
    				
    			},
    			
    			dispatchNeedDeployEvt:function (wdgProps)
				{        			
    				console.log("Some Parameters are not deployed "+wdgProps.socketID);        			
    				wdgProps.socket.dispatchEvent('needDeploy', {callerSocketID:wdgProps.socketID});					
				}    				    			
    			
    		};
    	
    	
    	
    return paramUtils;    	
    	
    });

