/*
 * Collection with presetted URL (used as the Root renderer collection)
 */
  require.config({
	paths: {
		jquery: window.jQueryURL
	}
});
define('DS/CfgVariantEffectivityDialog/scripts/CfgVariantSkeletonCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',

    'DS/CfgVariantEffectivityDialog/scripts/CfgVariantSkeletonModel',

    // WebApps
    'DS/WebappsUtils/WebappsUtils',
    'DS/PlatformAPI/PlatformAPI',
    'DS/WAFData/WAFData',
    'DS/CfgVariantEffectivity/scripts/CfgVariantUtility',
    'DS/CfgVariantEffectivity/scripts/CfgVariantExpServices',
    'DS/UIKIT/Tooltip',
    'jquery',
    'i18n!DS/CfgVariantEffectivityDialog/assets/nls/CfgVariantEffectivityDialog'
], function(UWA, Model, Collection, TestDataNodeModel, WebappsUtils, PlatformAPI, WAFData,CfgVariantUtility,CfgVariantExpServices,Tooltip,jQuery,CfgVarEffDialogNLS) {

    var myCollection = function(productID){
        var pid = productID;
    return Collection.extend({
        model: TestDataNodeModel,
	    initEffectivityJson:true,
        url: WebappsUtils.getWebappsAssetUrl('CfgVariantEffectivityDialog', 'projects.json'),
        setup: function() {
          
            this.url = WebappsUtils.getWebappsAssetUrl('CfgVariantEffectivityDialog', 'projects.json');
        },
        getEffectivityJSON:function(callback)
        {
			var that = this;
            // var InstanceID = enoviaServerFilterWidget.InstanceId;
    															
			if(that.initEffectivityJson == false){
				callback();
				return;
			}
	     
   		    that.initEffectivityJson = false;							
                           
			if(CfgVariantUtility.hasEffectivity == false){		
				console.log("Has No Effectivity, Initializing Models to Default values with model name and empty Combinations"); 
				
				for(var j=0;j< that.length;j++){
					var json = {"name":that.at(j).get('title'),"Combinations":[]};						
					that.at(j).set('jsonAttr',JSON.stringify(json));																		
				 } 							  
				callback();
			    return;
			}				  
		                         
							  
            var parsedXML = jQuery.parseXML(CfgVariantUtility.varEffXML);                             
            var finalJson = CfgVariantExpServices.ConvertXMLToJsonNew(parsedXML);
            var descJson = CfgVariantExpServices.ConvertXMLToDescriptionJson(parsedXML);                
			CfgVariantUtility.descriptionJson = descJson;
			
			for(var i =0; i< finalJson.length ; i++){
				var json = JSON.parse(finalJson[i]);
				
				if(json.Combinations.length > 0)
					json = CfgVariantUtility.FillModelsWithDisplayName(json);
				
				for(var j=0;j< that.length;j++){					
					if(that.at(j).get('subtitle') ===  json.name){
						that.at(j).set('jsonAttr',JSON.stringify(json));
						break;
					}
				} 	
			}   
				  			  
            callback();
                      

        },
        parse: function(data) {

            if (Array.isArray(data)) {

					var getAttributeValue = function (arrList, key){
						var attrValue = "";
						for(var i = 0 ; i < arrList.length ; i++){
							if(arrList[i].name == key){
								attrValue = arrList[i].value;
								if(attrValue == null || attrValue == 'undefined')
									attrValue='';
								break;
							}
						}
						
						return attrValue;
						
					};
   
                    
                
                    var jsonExInf = CfgVariantUtility.data;
                    console.log(jsonExInf);
					var myAppsUrl = enoviaServerFilterWidget.baseURL;//PlatformAPI.getApplicationConfiguration('app.urls.myapps');                    
                  	var imgurl = '';
					var iconurl = ''; 					
			if(myAppsUrl != null && myAppsUrl != 'undefined' && myAppsUrl !=''){
						//imgurl = myAppsUrl + '/snresources/images/icons/large/iconLargeDefault.png';
			    //iconurl = myAppsUrl + '/snresources/images/icons/small/I_PLCModel.bmp';
			    imgurl = enoviaServerFilterWidget.baseURL + "/common/images/I_Model_Thumbnail.png";
						iconurl = enoviaServerFilterWidget.baseURL + "/common/images/iconSmallModel.png";
			}			
					
                   for (var i = 0; i <= jsonExInf.length - 1; i++) {
                      
                        var CurrentModel = jsonExInf[i];
						var ProductId = CurrentModel.physicalID;
			   if(CurrentModel.preview_url !=null && CurrentModel.preview_url != 'undefined' && CurrentModel.preview_url !='')
				   imgurl = CurrentModel.preview_url;
                           var displayNameVal = getAttributeValue(CurrentModel.data, 'Marketing Name');  
			   var nameVal =   getAttributeValue(CurrentModel.basicData, 'name');
			   var stateVal = CfgVarEffDialogNLS.Maturity + ":" +getAttributeValue(CurrentModel.basicData, 'current');    
			   var ownerVal = CfgVarEffDialogNLS.Owner+ ":" +getAttributeValue(CurrentModel.basicData, 'owner');
        		   var contentVal = "<span style='color:#77797c'>"+ stateVal +"</span>" + "<br>" +"<span style='color:#77797c'>"+ ownerVal +"</span>";						                                                         
                    
                        var element = '{ "id": "' + i + '", "title": "' + displayNameVal + '", "subtitle": "' + nameVal + '", "content": "' + contentVal + '","image": "' + imgurl + '", "icon": "' + iconurl + '", "color": "", "url": "", "idModel": "' + ProductId + '" }';
                        var JsonElement = JSON.parse(element);
                        data.push(JsonElement);

        
                };
             }

            return data;
        }
    });
    }
    return myCollection;
});
