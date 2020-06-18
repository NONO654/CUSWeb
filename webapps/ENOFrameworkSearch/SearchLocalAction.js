define('DS/ENOFrameworkSearch/SearchLocalAction', [
    'UWA/Core',
    'UWA/Controls/Abstract'
], function (
    UWACore,
    UWAAbstract
    ) {

    'use strict';

    var SearchLocalAction = UWAAbstract.extend({

        init: function () {
        },

        availableForTypes: function () {
            var types = [];
            if (UWA.is(document.getElementById("searchContainer"))) {
                types = [
                    'all'
                ];
            }
            return types;
        },

        getActionForObject: function (attributes, callback, info) {
		var that = this;
            if (UWA.is(attributes.sourceid, 'string') && attributes.sourceid.indexOf('3dspace') === 0 && UWA.is(callback, 'function') && (!UWA.is(info) || !UWA.is(info.inCtxOptions))) {
                require(['i18n!DS/ENOFrameworkSearch/assets/nls/ENOFrameworkSearch.json'], function (LocalActionNls) {
                    var launchTreePage = LocalActionNls.get("launch_tree_page");
                    var actionsData =  [{
                        title: launchTreePage,
                        icon: 'window',
                        id: 'enovia_properties',
                        multisel: false,
                        callback: that.openEnoviaProperties.bind(that)
                    }];
                    callback.call(null, actionsData);
                });
            }
        },

        openEnoviaProperties: function (options) {
            if (UWA.is(options)) {
                // for the case from global action dropdown
                if (Array.isArray(options) && options.length === 1) {
                    options = options[0];
                }
                jQuery('#closeWidget').click();
                var phyIds = new Array();
                phyIds.push(options.object_id);
                $.ajax({
                    url: '../resources/bps/PhyIdToObjId/phyIds',
                    dataType: 'json',
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ phyIds: phyIds }),
                    method: 'POST',
                    success: function (data) {
                        var url = '../common/emxTree.jsp?objectId=' + data.ObjIds[0];
                        emxUICore.link(url, "content");
                    }
                });
            }
        }
    });

    return SearchLocalAction;
});

