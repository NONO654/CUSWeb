define('DS/SMAProcRunAbaqusUI/Model/Tool', [
    'UWA/Class/Model',
    'UWA/Class/Debug'
], function (Model, Debug) {

    'use strict';
   
    var Tool = Model.extend(Debug, {

        urlRoot: '/activity',        
        
        defaults: {
        	id : '',
            title: '',
            ownerName : '',
            lastExecuted : '',
            description : '',
            portraitIcon : '',
            session : null,
            toolInstance : null,
            credentials : {
            	enabled : false
            },
            subtitle: '',
            actTitle : "",
            isRunnable : true
        },
        
        setup: function () {
        	//console.log('********* DS/RunAbaqusWidget/Model/Tool setup');
        	this.credentials = {enabled : false};
        },

        sync: function () {
        	//console.log('********* DS/RunAbaqusWidget/Model/Tool sync');

            // return a dummy obj with a cancel() method since
            // operations in this.safe are synchronous and not
            // cancellable.
            return {
                cancel: function () {
                    return;
                }
            };
        },

        // Validate data before you set or save it :
        validate: function () {
        	//console.log('********* DS/RunAbaqusWidget/Model/Tool validate');
        },
    });

    return Tool;
});
