define('DS/ENOXDocumentPresenter/js/util/DocumentSearchController',
		[
		 'DS/ENOXDocumentPresenter/js/util/DocumentSearchUtil'
	 ], function (DocumentSearchUtil) {
	'use strict';

	var DocumentSearchController = {
		init: function () {
		},
			addExistingDoc: function(DocumentPresenter, connectedIds){
				var that = this;
				DocumentSearchUtil.configureSearch();
				var searchCallback = that.addExistingDocAsInstance.bind(that, DocumentPresenter, DocumentPresenter.modelId,  that.addExistingDocAsInstance);
				DocumentSearchUtil.launchSearch({
					allowedTypes: DocumentPresenter.documentSearchTypes.toString(),
					role : '',
					criteria : '',
					multiSel : true,
					excludeList:connectedIds,
					in_apps_callback : searchCallback
				});
			},
			addExistingDocAsInstance: function(DocumentPresenter, contextItem,  onCompleteCallback,  selectedItems){
				var modelid = contextItem;
				for (var i = 0; i < selectedItems.length; i++) {
						var documentId = selectedItems[i].id? selectedItems[i].id : selectedItems[i].objectId;
							if (i === selectedItems.length-1){
									DocumentPresenter.connectDocumentToParent(documentId, modelid, selectedItems, true);
								}
								else {
										DocumentPresenter.connectDocumentToParent(documentId, modelid, selectedItems, false);
								}
				}
			}
	};
	return DocumentSearchController;
});
