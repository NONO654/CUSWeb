define('DS/EffectivityInlineEditor/utils/DictionaryUtils', [
    'DS/CfgDictionary/CfgDictionaryTypeEnum',
    'DS/CfgBaseUX/scripts/CfgData',
    'DS/CfgBaseUX/scripts/CfgUtility',
	'i18n!DS/EffectivityInlineEditor/assets/nls/EffectivityInlineEditor',
    'text!DS/EffectivityInlineEditor/assets/dicoV3_template.json'
], function (CfgDictionaryTypeEnum, CfgData, CfgUtility, AppNLS, DicoV3Template) {
    'use strict';

    var DictionaryUtils = {

        /**
         * Convert a dictionary from CFCO format to V3 portfolio format
         * @param {Object} JSON dico CFCO format
         * @return {Object} JSON dico V3 format
        */
        convertDicoFromCFCO: function (dicoCFCO) {
            var dico = JSON.parse(DicoV3Template);

            var features = dicoCFCO.features;
            var i = 0, j = 0;
            for (i = 0; i < features.length; i += 1) {
                var currentFeature = features[i];

                if (currentFeature.current !== 'Preliminary') {
                    if (currentFeature.selectionType === 'Single') {
                        var variant = {kind: 'reference', attributes: {}};
                        variant.id = currentFeature.id;
                        variant.lid = currentFeature.logicalId;
                        variant.attributes._image = currentFeature.image;
                        variant.attributes._name = currentFeature.displayValue;
                        variant.attributes._value = currentFeature.name;

                        var variantValues = [];
                        for (j = 0; j < currentFeature.options.length; j += 1) {
                            var varValue = {attributes: {}};
                            varValue.id = currentFeature.options[j].id;
                            varValue.rel_lid = currentFeature.options[j].parentRelLogicalId;
                            varValue.attributes._image = currentFeature.options[j].image;
                            varValue.attributes._name = currentFeature.options[j].displayValue;
                            varValue.attributes._value = currentFeature.options[j].name;
                            varValue.attributes.type = CfgDictionaryTypeEnum.VALUE;
                            variantValues.push(varValue);
                        }
                        variant.values = {member: variantValues};
                        dico.portfolioClasses.member[0].portfolioComponents.member[0].variants.member.push(variant);
                    } else if (currentFeature.selectionType === 'Multiple') {
                        var variabilityGroup = {
                            id: currentFeature.id,
                            lid: currentFeature.logicalId,
                            attributes: {_name: currentFeature.displayValue, _value: currentFeature.name},
                            selectionType: 'Multiple'
                        };

                        var options = [];
                        for (j = 0; j < currentFeature.options.length; j += 1) {
                            options.push({
                                id: currentFeature.options[j].id,
                                rel_id: currentFeature.options[j].parentRelId,
                                rel_lid: currentFeature.options[j].parentRelLogicalId,
                                feature_id: currentFeature.logicalId, 
                                image: currentFeature.options[j].image,
                                name: currentFeature.options[j].displayValue,
                                attributes: {_name: currentFeature.options[j].displayValue, _value: currentFeature.options[j].name},
                                kind: 'reference'
                            });
                        }
                        variabilityGroup.options = {member: options};
                        dico.portfolioClasses.member[0].portfolioComponents.member[0].variabilityGroups.member.push(variabilityGroup);
                    }
                }
            }

            return dico;
        },
        
        /**
         * Create and return an object containing the dictionary (V3 format) mapped by id and by name
         * @param {Object} dictionary (portfolio V3 format)
         * @return {Object} containing two maps (byId and byName)
         */
        createMapsFromDico: function (dictionary) {
            var mapByName = {};
            var mapById = {};
            var dico_inside = (dictionary.portfolioClasses) ? dictionary.portfolioClasses.member[0].portfolioComponents.member[0] : dictionary;
            var flatVariants = dico_inside.variants ? dico_inside.variants.member : [];
            var flatVGs = dico_inside.variabilityGroups ? dico_inside.variabilityGroups.member : [];

            flatVariants.forEach(function (variant) {
                mapByName[variant.attributes._value] = variant;
                mapById[variant.lid] = variant;

                variant.values.member.forEach(function (varValue) {
                    mapByName[varValue.attributes._value] = varValue;
                    mapById[varValue.rel_lid] = varValue;
                });
            });
            flatVGs.forEach(function (VG) {
                mapByName[VG.attributes._value] = VG;
                mapById[VG.lid] = VG;

                VG.options.member.forEach(function (option) {
                    mapByName[option.attributes._value] = option;
                    mapById[option.rel_lid] = option;
                });
            });

            return {byName: mapByName, byId: mapById};
         },

        /**
         * Create a partial dictionary from Combination expression
         * @param {Object[]} effectivity expression (varEffJsonWtihLabel format)
         * @return {Object} temporary dictionary JSON V3 format
         */
        createPartialDictionaryFromEffectivityExpression: function (effExpr) {
            var dico = JSON.parse(DicoV3Template), alreadyCreated = {};

            if (effExpr === undefined || effExpr === null) {
                // If no expression passed, return empty dico
                return dico;
            }

            effExpr.forEach(function (uselessObject) {
                uselessObject.Combination.forEach(function (comb) {
                    var featureValue = comb.Feature.value;

                    if (alreadyCreated[featureValue] === undefined) {
                        var variant = {kind: 'reference', attributes: {}};
                        variant.id = comb.Feature.DescId;
                        variant.lid = comb.Feature.DescId;
                        variant.attributes._name = comb.Feature.label;
                        variant.attributes._value = featureValue;
                        alreadyCreated[featureValue] = [];    // Will contain variantValues
                        variant.values = {member: alreadyCreated[featureValue]};
                        dico.portfolioClasses.member[0].portfolioComponents.member[0].variants.member.push(variant);
                    }

                    comb.Options.forEach(function (anotherUselessObject) {
                        var opt = anotherUselessObject.Option;
                        var optionValue = opt.value;
                        if (!alreadyCreated[optionValue]) {
                            var varValue = {attributes: {}};
                            varValue.id = opt.DescId;
                            varValue.rel_lid = opt.DescId;
                            varValue.attributes._name = opt.label;
                            varValue.attributes._value = optionValue;
                            varValue.attributes.type = CfgDictionaryTypeEnum.VALUE;
                            alreadyCreated[optionValue] = true;    // Tag varValue has already added to dictionary
                            alreadyCreated[featureValue].push(varValue);    // Push varValue in corresponding feature name
                        }
                    });
                });
            });

            return dico;
        },

        getModelDictionary: function (model) {
            var that = this;

            return new Promise(function (resolve) {
                var dictionary = CfgData.getDictionaryByCriteria(model.id, 'features');
                if (dictionary.features === null) {
			
					var wParam = "";
					
					if(model.currentEvoExpression !== "")
						wParam = {evolutionExpression: JSON.stringify({"filterExpression":model.currentEvoExpression})};
					
                    CfgUtility.getLegacyCfgDico(model.id, wParam).then(function (response) {
						
						var optimized_features = [];
							for(var i=0; i<response.features.length; i++){
								var ftr = response.features[i];
								if(ftr.current === 'Preliminary')
									continue;
								else
								optimized_features.push(ftr);
							}					
						response.features=optimized_features;					
						if(response.features.length == 0)
							CfgUtility.showwarning(AppNLS.NO_FEATURES,'warning');
						
                        CfgData.addDictionaryByCriteria(model.id, response, 'features');
                        model.dico = that.convertDicoFromCFCO(response);
                        model._dicoMapped = that.createMapsFromDico(model.dico);
                        resolve('dictionary loaded from server');                          
                    });
                } else {
                    model.dico = that.convertDicoFromCFCO(dictionary);
                    model._dicoMapped = that.createMapsFromDico(model.dico);
                    resolve('dictionary loaded from cache'); 
                }
            });
        }
    };

    return DictionaryUtils;
});
