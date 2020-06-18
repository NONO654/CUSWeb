define('DS/ENOXDocumentCockpit/js/util/DocCockpitIdCardAttributeEditor', [
        'DS/PlatformAPI/PlatformAPI',
    ],
    function(
        PlatformAPI
    ) {

        var DocCockpitIdCardAttributeEditor = function() {};

        DocCockpitIdCardAttributeEditor.prototype.init = function(idCardChannel, options) {
            this._idCardModelEvents = idCardChannel;
            this._maturityInEdit = false;
            this._subscribeToEvents();
        };

        DocCockpitIdCardAttributeEditor.prototype.setDocIdAndInitCollabObj = function(idCardModel) {
            this._modelForIdCard = idCardModel;
            // this._modelForIdCard.addEvent('onChange', function(){
            //     console.log('Model Changed!!!');
            // });
        };
        DocCockpitIdCardAttributeEditor.prototype._subscribeToEvents = function(){
           var that = this;
           //PlatformAPI to listen to any of the object changes
           //IMP Note: Whenever there is update in any object this event will be fired(for xModel its listened at two places
           //one is here and other is in Wrapped Adv set view for information panel edit ops)
           //Depending on which presenter contains the object which is refreshed by someone else(Info,Maturity/Owner edit ops) it will be handled there.
           PlatformAPI.subscribe('DS/PADUtils/PADCommandProxy/refresh', function(eventData){
             	console.log("ID Card Model refresh Event handler!!! dce6_2");
               var currIdCardModelId = that._modelForIdCard.get('id');
                var modifiedObjIds = eventData ? (eventData.data ? (eventData.data.authored ? (eventData.data.authored.modified ? eventData.data.authored.modified: []): []): []) : [];
                //xlv: to decide whether to send array or individual ids//
                if(modifiedObjIds[0] && currIdCardModelId===modifiedObjIds[0] ){
                  that._idCardModelEvents.publish({'event': 'idcard-model-refresh', 'data' : currIdCardModelId });

                }
                // modifiedObjIds.forEach(function(modId, index){
                //     if(modId && currIdCardModelId && currIdCardModelId === modId) {
                //         that._idCardModelEvents.publish({'event': 'idcard-model-refresh', 'data' : modId });
                //     } else {
                //         console.log("Model Id for ID card instance is different, so refresh is not for ID Card!!!");
                //     }
                // });
            });
        };
        return DocCockpitIdCardAttributeEditor;
    })

/*
//Pending [as on 22 June 2018, update this section as per updates done.]
1. Currently on Update of Maturity or Owner there is no mechanism to reflect these changes on ID Card!!!


*/
