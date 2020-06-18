/**
 * @overview DocumentCommonUtils
 * @licence Copyright 2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOXDocumentCockpit/js/util/DocCockpitCommonUtils', [
                                                       'UWA/Core',
                                                       'DS/DataDragAndDrop/DataDragAndDrop',
                                                       'DS/PlatformAPI/PlatformAPI'
																										 ], function (UWA,DataDragAndDrop,PlatformAPI) {
	'use strict';

	var DocCockpitCommonUtils = {


				// getPlatformServiceURL : function(service) {
				// 	var serviceURL = '';
				// 	i3DXCompassPlatformServices.getPlatformServices({
				// 		onComplete : function(data) {
				// 			var platformServices = data[0];
				// 			serviceURL = platformServices[service];
				// 			return serviceURL;
				// 		}
				// 	});
				// 	return serviceURL;
				// },

			/**
			 * Function to handle Drag and Drop behavior
			 * @param {Object} [droppableElement] drop container
			 * @param {string} [dropText] text to appear in drop area
			 * @param {function} [dropCallback] callback function to invoke
			 */
       getLoggedInUser : function() {
         return PlatformAPI.getUser().login;
       },
			makeDroppable : function(droppableElement, dropText, dropCallback) {
				var that = this;
        if(droppableElement!=null){
    				//that.dropInvite = droppableElement;
            that.dropInvite = droppableElement.getElement('#droppable');
      				if (!that.dropInvite){
      					that.dropInvite = new UWA.createElement('div', {
      						id: 'droppable',
      						'class': 'hidden',
      						html: dropText
      					}).inject(droppableElement);
      				}
    				that.dropInvite.callback = dropCallback;
    				var dragEvents = {
    						enter : that._manageDragEvents.bind(that),
    						leave : that._manageDragEvents.bind(that),
    						over : that._manageDragEvents.bind(that),
    						drop : that._manageDropEvent.bind(that)
    				};
    				DataDragAndDrop.droppable(droppableElement, dragEvents);
          }
			},

			_manageDragEvents: function (el, event) {
        var that = this;
        var droppableElement = that.dropInvite.parentElement;
				switch (event.type){
          case 'dragenter':
  					that.dropInvite.addClassName('droppable1');
  					that.dropInvite.removeClassName('hidden');
            that.dropInvite.removeClassName('fileDrop1');
  					that.dropInvite.addClassName('show');
  					break;
  				case 'dragleave':
  					if (event.target !== that.dropInvite) {
  				        return false;
  				  }
  					that.dropInvite.removeClassName('droppable1');
  					that.dropInvite.removeClassName('show');
  					that.dropInvite.addClassName('hidden');
            that.dropInvite.addClassName('fileDrop1');
  					break;
  				case 'dragover':
  					that.dropInvite.removeClassName('hidden');
            that.dropInvite.removeClassName('fileDrop1');
  					that.dropInvite.addClassName('show');
            that.dropInvite.addClassName('droppable1');
  					break;
				default:
					break;
				}
				return true;
			},

			_manageDropEvent: function (dropData) {
				console.log(arguments.length);
				var that = this;
				if(dropData != '' && dropData != null ){
					dropData = UWA.is(dropData, 'string') ? JSON.parse(dropData): dropData;
					var items = dropData.data && dropData.data.items ? dropData.data.items : null;
					that.dropInvite.callback(items);
				}
				else {
					that.dropInvite.callback(arguments[2]);
				}

			}
	};
	return DocCockpitCommonUtils;
});
