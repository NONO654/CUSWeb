/*
//XLV Created to remove repeatative code from application, such code which is not working on any context.
Common Utility functions, which will not require any this/that context for working
//e.g. string manipulations, objects formatting, log etc.
 */
define('DS/ENOXDocumentCockpit/js/util/DocCockpitIdCardAttributeCreator', ['UWA/Class',
		'UWA/Class/Model',
		'DS/ENOXDocumentCockpit/js/FileKPI',
		'i18n!DS/ENOXDocumentCockpit/assets/nls/DocumentCockpit'
		//NLS File for common strings used//
	],
	function (UWAClass, UWAModel, FileKPI, Document_NLS) {
	'use strict';

	//Singleton class//
	var DocCockpitIdCardAttributeCreator = UWAClass.singleton({
			/*Method to return model required for ID Card initialization */
			prepareIdCardData: function (data, modelEventForIdCard, modelEventForKPI) {

				var fileSize = 0;
				var l_Doc,
				l_Form,
				l_Listeners;
				var that = this;

				if (data.relateddata.files.length > 0) {
					fileSize = data.relateddata.files[0].dataelements['fileSize'];
				}
				var dataDetails = {
					'@id': data.id,
					'@attributes': {
						'attr_Name': data.dataelements['name'],
						'attr_Title': data.dataelements['title'] ? data.dataelements['title']
						 : data.dataelements['name'],
						'attr_Version': data.dataelements['revision'],
						'attr_Type': data.type,
						'attr_Thumbnail': data.dataelements['image'],
						'attr_Creation_Date': data.dataelements['originated'],
						'attr_Modification_Date': data.dataelements['modified'],
						'attr_Reserved_By': data.dataelements['reservedby'],
						'attr_Maturity': data.dataelements['state'],
						'attr_Description': data.dataelements['description'],
						'attr_Owner': data.relateddata.ownerInfo[0].dataelements['name'],
						'attr_FileSize': fileSize
						// attr//data.dataelements['image']
					}
				};

				// if (debug_DocumentDetailsPresenter) {
				// 	console.log('dataDetails---------' + dataDetails);
				// }
				if (dataDetails === undefined || dataDetails === null) {
					return;
				}
				var l_docId = dataDetails['@id'];
				var l_docAttributes = dataDetails['@attributes'];
				var l_attributesForIdCard = [];
				var creation_date = data.dataelements['originated'] ? data.dataelements['originated'] : '';
				var mod_date = data.dataelements['modified'] ? data.dataelements['modified'] : '';
				if (creation_date) {
					var date = new Date(creation_date);
					// 		propObj = date.toDateString();
					creation_date = date.toDateString();
				}
				if (mod_date) {
					var date = new Date(mod_date);
					// 		propObj = date.toDateString();
					mod_date = date.toDateString();
				}
				//if(l_docAttributes['attr_FileSize'])

				var l_attributesForIdCard = [{
						name: Document_NLS.DOC_IDCard_Type, //dataAttributes['attr_type'] ? dataAttributes['attr_type']['@name'] : 'Type',
						value: data.type ? data.type : ''
					}, {
						name: Document_NLS.DOC_IDCard_Owner,
						value: data.relateddata.ownerInfo[0].dataelements['name'] ? data.relateddata.ownerInfo[0].dataelements['name'] : '',
						type: 'type-hyperlink',
						displayWhenMinified: true,
						editable: true
					}, {
						name: Document_NLS.DOC_IDCard_Creation_Date, //dataAttributes['attr_created'] ? dataAttributes['attr_created']['@name'] : 'Creation Date',
						value: creation_date
					}, {
						name: Document_NLS.DOC_IDCard_Maturity, //'Maturity',
						value: data.dataelements['state'] ? data.dataelements['state'] : '',
						type: 'type-hyperlink',
					    displayWhenMinified: true,
				        editable: true
					}, {
						name: Document_NLS.DOC_IDCard_Mod_Date, //dataAttributes['attr_modified'] ? dataAttributes['attr_modified']['@name'] : 'Modification Date',
						value: mod_date
					}, {
						name: Document_NLS.DOC_IDCard_Reserved_By, //dataAttributes['attr_modified'] ? dataAttributes['attr_modified']['@name'] : 'Modification Date',
						value: data.dataelements['reservedby'] ? data.dataelements['reservedby'] : ''
					}
				];

				// for (var prop in l_docAttributes) {
				// 	// dataForModel.attributes.push({prop.slice(prop.indexOf('_')+1)] =
				// 	// l_modelAttributes[prop]['@value'}];
				// 	var propName = prop.slice(prop.indexOf('_') + 1);
				// 	var propObj = l_docAttributes[prop];
				// 	if (propName == 'Creation_Date' || propName == 'Modification_Date') {
				// 		propName = propName.replace('_', ' ');
				// 		var date = new Date(propObj);
				// 		propObj = date.toDateString();
				// 	}
				// 	if (propName == 'Reserved_By') {
				// 		propName = propName.replace('_', ' ');
				// 	}
				// 	if (propName !== 'Name' && propName !== 'Title' && propName !== 'Version'
				// 		 && propName !== 'Thumbnail' && propName !== 'FileSize'
				// 		 && propName !== 'Description') {
				// 		var idCardAttribute = {
				// 			'name': propName,
				// 			'value': propObj
				// 		};
				// 		// maturity
				// 		if (propName == 'Maturity' || propName == 'Owner') {
				// 			UWA.merge(idCardAttribute, {
				// 				type: 'type-hyperlink'
				// 			});
				// 		}
				//
				// 		l_attributesForIdCard.push(idCardAttribute);
				// 	}
				// }

				var kpiComplexity = new FileKPI();
				kpiComplexity.init({
					name: Document_NLS.DOC_Latest_file_Size,
					originalValue: l_docAttributes['attr_FileSize'] + ' Bytes',
					modelEvents: modelEventForKPI
				});
				// this._kpiModelEvents.publish({ event: 'kpi-under-computation' });
				var dataForModel = {
					id: l_docId,
					name: dataDetails['@attributes']
					 && dataDetails['@attributes']['attr_Title'] ? dataDetails['@attributes']['attr_Title']
					 : '',
					version: dataDetails['@attributes']
					 && dataDetails['@attributes']['attr_Version'] ? dataDetails['@attributes']['attr_Version']
					 : '',
					thumbnail: dataDetails['@attributes']
					 && dataDetails['@attributes']['attr_Thumbnail'] ? '' : '',
					modelEvents: modelEventForIdCard,
					freezones: [
						'<p class="xmodel-idcard-p-freezone" title="'
						 + l_docAttributes['attr_Description'] + '">'
						 + l_docAttributes['attr_Description'] + '</p>',
						kpiComplexity.getDOMContent()], // ['<p style="text-align:
					attributes: l_attributesForIdCard,
					withToggleMinifiedButton: true,
				    withActionsButton: false
				};
				return new UWAModel(dataForModel);
			}
		});

	DocCockpitIdCardAttributeCreator.init(); //will call singletons init as its not defined for this class//
	return DocCockpitIdCardAttributeCreator;
});
