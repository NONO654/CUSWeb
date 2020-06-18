/**
 * @overview DocumentCommonUtils
 * @licence Copyright 2018 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOXDocumentPresenter/js/util/DocumentCommonUtils', [
                                                       'UWA/Core',
                                                       'DS/DataDragAndDrop/DataDragAndDrop',
																											 'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
                                                       'DS/PlatformAPI/PlatformAPI'
																										 ], function (UWA, DataDragAndDrop, i3DXCompassPlatformServices, PlatformAPI) {
	'use strict';

	var DocumentCommonUtils = {
        getErrorMessage: function(errorMessage){
          var str = errorMessage;
          var n = str.lastIndexOf(':');
          var finalErrorMessage = str.slice(n+1);
          return finalErrorMessage;
        },
        getLoggedInUser : function() {
          return PlatformAPI.getUser().login;
        },
      makeDroppable : function(droppableElement, dropText, dropCallback) {
        var that = this;
        if (droppableElement!==null){
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
        switch (event.type){
          case 'dragenter':
            that.dropInvite.addClassName('droppable');
            that.dropInvite.removeClassName('hidden');
            that.dropInvite.removeClassName('fileDrop');
            that.dropInvite.addClassName('show');
            break;
          case 'dragleave':
            if (event.target !== that.dropInvite) {
                  return false;
            }
            that.dropInvite.removeClassName('droppable');
            that.dropInvite.removeClassName('show');
            that.dropInvite.addClassName('hidden');
            that.dropInvite.addClassName('fileDrop');
            break;
          case 'dragover':
            that.dropInvite.removeClassName('hidden');
            that.dropInvite.removeClassName('fileDrop');
            that.dropInvite.addClassName('show');
            that.dropInvite.addClassName('droppable');
            break;
        default:
          break;
        }
        return true;
      },
			_manageDropEvent: function (dropData) {
				var that = this;
				if (dropData !== '' && dropData !== null && dropData !== undefined){
          try {
					dropData = UWA.is(dropData, 'string') ? JSON.parse(dropData): dropData;
					var items = dropData.data && dropData.data.items ? dropData.data.items : null;
					that.dropInvite.callback(items);
        } catch (err){
          that.dropInvite.removeClassName('droppable');
          that.dropInvite.removeClassName('show');
          that.dropInvite.addClassName('hidden');
          that.dropInvite.addClassName('fileDrop');
          }
				}
				else {
					that.dropInvite.callback(arguments[2]);
				}

			}
	};
	return DocumentCommonUtils;
});
