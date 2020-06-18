define('DS/ENOFrameworkUtility/WebUtility',
		["DS/UIKIT/Alert"],
		function(Alert){
			var TransientApi = {
			showTransientMessage :function (msg, messageType) {
						var options={
								message:msg,
								messageType:messageType
						}
						this.showGenericTransientMessage(options);
					},
			showGenericTransientMessage:function (options) {
						if(! options.messageType){
							options.messageType = "error";
						}
						 var myAlert = new Alert({
						  closable: (options.closable==undefined)?true:options.closable,
						  visible: (options.visible ==undefined)?true:options.visible,
						  hideDelay: (options.hideDelay == undefined)?2500:options.hideDelay,
						  autoHide: (options.autoHide==undefined)?true:options.autoHide
						 }).inject(getTopWindow().document.body);
						 myAlert.add({ className: options.messageType, message: options.message});
						 if(options.events){
						 for(var i=0;i<options.events.eventName.length;i++){
						  myAlert.addEvent(options.events.eventName[i],options.events.eventfunction[i]);
						 }
					   } 
					},
			};
			return TransientApi;
		});
		
