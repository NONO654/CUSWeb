define('DS/FolderEditorOpenness/FolderEditorSecurityContextCustomization', [
    'UWA/Core',
    // To test SampleImplementation // 'DS/FolderOpennessSamples/SampleImplementation',  // to be removed before delivery
    'UWA/Class'
],
function(Core,
    // To test SampleImplementation // SampleImplementation,                             // to be removed before delivery
    Class)
{
    'use strict';

    var FolderEditorSecurityContextCustomization = Class.singleton({
        name: 'FolderEditorSecurityContextCustomization',

        init: function(options) {
            this._parent(options);
        },

        /**
        * Function useComputedSecurityContext
        *   @returns a boolean indicating whether Folder Editor widget should subsequently use this openness
        */
        useComputedSecurityContext: function() {
            // To test SampleImplementation // // For debug only (to be remove from delivered version) ////////////////////////
            // To test SampleImplementation // var returnedValue = SampleImplementation.useComputedSecurityContext();
            // To test SampleImplementation // return returnedValue;
            // To test SampleImplementation // ////////////////////////////////////////////////////////////////////////////////

            // This is the default implementation, which returns false, meaning the openness is not activated
            return false;
        },

        /**
        * Function to compute SecurityContext corresponding to a Folder
        *   @param folderId: a string representing the id of the folder being selected
        *   @param avaliableSecurityContexts: an array of strings representing the list of Security Contexts available to the current connected user.
        *   @returns a string representing the computed Security Context
        *	        If the returned value is one of input availableSecurityContext, the current Security Context of Folder Editor is updated with the returned vale.
        *           If the returned value is not one of input availableSecurityContext, it will be ignored, i.e. no change of current Security Context.
        */
        computeSecurityContext: function(folderId, availableSecurityContexts) {
            // To test SampleImplementation // // For debug only (to be remove from delivered version) ////////////////////////
            // To test SampleImplementation // var returnedValue = SampleImplementation.computeSecurityContext(folderId, availableSecurityContexts);
            // To test SampleImplementation // return returnedValue;
            // To test SampleImplementation // ////////////////////////////////////////////////////////////////////////////////

            // This is the default, empty implementation, which returns nothing
        },

        /**
         * Function to activate legacy active bookmark
         *   @param folderId: a string representing the id of the folder being selected
         *   @param avaliableSecurityContexts: an array of strings representing the list of Security Contexts available to the current connected user.
         *   @returns a string representing the computed Security Context
         *	        If the returned value is one of input availableSecurityContext, the current Security Context of Folder Editor is updated with the returned vale.
         *           If the returned value is not one of input availableSecurityContext, it will be ignored, i.e. no change of current Security Context.
         */
        isActiveBookmarkActivated: function() {
            return false;
        },

        /**
         * Function to activate Import CSV command
         */
        isImportCSVActivated: function(){
        	return this.isActiveBookmarkActivated() || false;
        }

    });
    return FolderEditorSecurityContextCustomization;
});
