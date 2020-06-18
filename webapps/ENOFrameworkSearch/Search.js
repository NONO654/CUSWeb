
define('DS/ENOFrameworkSearch/Search', [
    'UWA/Drivers/Alone',
    'UWA/Core',
    'UWA/Class/Debug',
    'UWA/Controls/Abstract',
    'UWA/Class/Listener',
    'DS/SNResultUX/SNResultMgt',
    'DS/TagNavigator/TagNavigator',
    'DS/SNInfraUX/SearchRessources',
    'DS/SNInfraUX/SearchSettings',
    'DS/SNInfraUX/SearchCom',
    'DS/SNInfraUX/SearchUtils',
	'DS/SNInfraUX/PredicatesNLS'
], function (UWAAlone,
    UWACore,
    UWADebug,
    UWAAbstract,
    Listener,
    SNResultMgt,
    TagNavigator,
    SearchResources,
    SearchSettings,
    SearchCom,
    SearchUtils,
	PredicatesNLS) {

    'use strict';
    var i3DSpaceHost = UWAAbstract.extend(UWADebug, Listener, {
        name: 'DS_Result3DSpaceHost_Result3DSpaceHost',
        resultMgt: null,

        init: function (options) {
            var that = this;
      
            SearchSettings.initialize(options.url_settings);
            this.setDebugMode(SearchSettings.getDebugMode());
            var searchUIBody;
            searchUIBody = document.body;
            var preferences_wdg = options.preferences_wdg;
			
			var resources = preferences_wdg.search_ressources;

			new SearchResources(resources, function(){
			
				PredicatesNLS.setResources({
					resources: this
				});
                if (UWA.is(options.userid)) {
                    SearchUtils.setUserId(options.userid);
                    UWACore.log('User id set = ' + SearchUtils.getUserId());
                }
        
                /*client socket id */
                var client_socket_id = UWA.Utils.getUUID();
                /* widegt_id */
                var widget_id = UWA.Utils.getUUID();
                /*target div*/
                var target_div = UWACore.extendElement(searchUIBody).getElement('#' + options.searchcontent);
                
                
                var options_search = SearchUtils.getResultInitArgs({
                    'preferences_wdg':preferences_wdg
                });
                UWA.merge(options_search, {
                    tagnavigatorproxy: options.tagnavigatorproxy,
					tagger_context_id:'context2',
                    renderTo: target_div,
					widget_id:widget_id,
                    resources: this,
                    events: {
                        onReady: function () {
                            var div_recentcontent = UWACore.extendElement(searchUIBody).getElement('.onesearch_recentcontent');
                            if (div_recentcontent) {
                                // recent content displayed on the same line that icon actions
                                if ('absolute' === div_recentcontent.getStyle('position'))
                                    target_div.setStyle('height', '100%');
                                else {
                                    var height = div_recentcontent.getStyle('height');
                                    var margin = div_recentcontent.getStyle('margin-top');
                                    var total_height_recent_content = parseInt(height) + parseInt(margin);
                                    target_div.setStyle('height', searchUIBody.parentElement.clientHeight - total_height_recent_content + 'px');
                                }
                            }
                        }
                    }
                });
                
                that.resultMgt = new SNResultMgt(options_search);
				
				
				var searchcom_socket = SearchCom.createSocket({
					socket_id: client_socket_id
				});
				searchcom_socket.dispatchEvent('onWdgCreation', {  }, ['searchtopbar_socket_id']);
				searchcom_socket.addListener('onSearchWdgUpd', function (search_options) {
					if(that.resultMgt) {
                        var options_search = SearchUtils.getResultUpdateArgs({
                            'options':search_options
						});
						that.resultMgt.onSearch(options_search);
					}
				});
				var advancedSearchOptions = {
                    'maximized': true

				};
				searchcom_socket.dispatchEvent('toggleProxyFocus', advancedSearchOptions);	
			});
			
			jQuery('#searchContainer').fadeIn();
			jQuery('#closeWidget').bind('click', function(){
				if(that.resultMgt) {
					that.resultMgt.destroy();
					delete that.resultMgt;
				}
				jQuery("div#topbar").removeClass('search');
				jQuery("div#layerOverlay").css('left', '0');
			});
			jQuery("div#topbar").addClass('search');
			jQuery("div#layerOverlay").css('left', '25%');
        }

    });
    return i3DSpaceHost;
});
