define('DS/CfgVariantEffectivityDialog/scripts/CfgVariantSkeletonModel',
[
    'UWA/Core',
    'UWA/Class/Model'
], function (UWA, Model) {
    return Model.extend({
        defaults: function() {
            return {
                title : '',
                subtitle : '',
                content : '',
                image : '',
                icon: '',
                color: '',
                url: '',
                idModel: '',
                jsonAttr:''
            };
        }
    });
});

