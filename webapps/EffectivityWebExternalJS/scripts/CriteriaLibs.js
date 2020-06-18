
        // Avoid leaking variables
        (function () {
            'use strict';

            // Remove any query strings
            var pathJQuery = require.toUrl('DS/EffectivityWebExternalJS/scripts/jQuery');
            var pathtags = require.toUrl('DS/EffectivityWebExternalJS/scripts/tags');
            //var configurationfeaturecriteria = require.toUrl('DS/CfgBaseUX/ConfigurationFeatureCriteria');
            //var productstatecriteria = require.toUrl('DS/CfgBaseUX/ProductStateCriteria');
            //var buildscriteria = require.toUrl('DS/CfgBaseUX/BuildCriteria');
            //var manufacturingcriteria = require.toUrl('DS/CfgBaseUX/ManufacturingPlanCriteria');
            //var timelinecriteria = require.toUrl('DS/EffectivityWebExternalJS/timeline');
            //var milestonewrapper = require.toUrl('DS/CfgBaseUX/wrapper_ownfunctionTimeline');          


            require.config({
                // path mapping for 'DS/EffectivityWebExternalJS' not found directly under baseUrl
                paths: {
                    'DS/EffectivityWebExternalJS/scripts/tags': pathtags,
                    'DS/EffectivityWebExternalJS/scripts/jQuery': pathJQuery

                    //'DS/CfgBaseUX/ConfigurationFeatureCriteria': configurationfeaturecriteria,
                    //'DS/ProductStateCriteria': productstatecriteria,
                    //'DS/BuildCriteria': buildscriteria,
                    //'DS/ManufacturingPlanCriteria': manufacturingcriteria,
                    //'DS/milestonesCfgModel':milestonewrapper,
                    //'DS/EffectivityWebMilestones': timelinecriteria
                },
                // configure the export for traditional "browser globals" JQueryUI script
                // that do not use AMD :
                shim:
                    {
                        'DS/EffectivityWebExternalJS/scripts/jQuery': {
                            // Once loaded, use the global 'JQuery' as the
                            // module value :
                            exports: 'JQuery'
                        },

                        'DS/EffectivityWebExternalJS/scripts/tags': {
                            deps: ['DS/EffectivityWebExternalJS/scripts/jQuery'],
                            exports: 'tagsinput'
                        }
                        //,
                        //'DS/CfgBaseUX/ConfigurationFeatureCriteria': {
                        //    deps: ['DS/EffectivityWebJQuery'],
                        //    exports: 'CFComponent'
                        //}

                    }
            }); // config
        })();

        define('DS/EffectivityWebExternalJS/scripts/CriteriaLibs', [
    ],
    function (CriteriaLibs) {
        'use strict';
        return CriteriaLibs;
    }
);
