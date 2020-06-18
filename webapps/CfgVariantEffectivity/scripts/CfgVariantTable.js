/**
 * @module DS/CfgVariantEffectivity/scripts/CfgVariantTable
 */
  require.config({
	paths: {
		jquery: window.jQueryURL
	}
}); 
define('DS/CfgVariantEffectivity/scripts/CfgVariantTable', ['UWA/Controls/Drag', 'DS/UIKIT/Input/Button', 'UWA/Core', 'DS/UIKIT/Modal', 'DS/WebappsUtils/WebappsUtils', 'DS/WAFData/WAFData', 'DS/PlatformAPI/PlatformAPI', 'DS/UIKIT/Autocomplete', 'DS/UIKIT/Iconbar', 'DS/Notifications/NotificationsManagerUXMessages', 'DS/Notifications/NotificationsManagerViewOnScreen','DS/CfgVariantEffectivity/scripts/CfgVariantExpServices','DS/CfgVariantEffectivity/scripts/CfgVariantUtility', 'DS/DataDragAndDrop/DataDragAndDrop', 'jquery','i18n!DS/CfgVariantEffectivity/assets/nls/CfgVariantEffectivity'],
  function(Drag, Button, Core, Modal, WebappsUtils, WAFData, PlatformAPI, Autocomplete, Iconbar, NotificationsManager, NotificationsManagerViewOnScreen,CfgVariantExpServices, CfgVariantUtility,DataDragAndDrop, jQuery, CfgVarEffNLS) {


    var CfgVariantTable = {};
    var isMultiSelectOn = false;
	var isEBoxMinimized = false;
	var isEBoxMaximized = false;
	var globalAutoComplete = null;

    //Corrent Color for Zebra Effect
    var CurrentColor = 1;

    //Dataset to build from webservice call
    var hierarchicalDataset = {};
    
	CfgVariantTable.uncheckImgUrl=WebappsUtils.getWebappsAssetUrl("CfgVariantEffectivity", "icons/CfgEffUnCheckIcon.png");	 
	CfgVariantTable.checkImgUrl= WebappsUtils.getWebappsAssetUrl("CfgVariantEffectivity", "icons/CfgEffCheckIcon.png");
	CfgVariantTable.cfgEff_img_class  = "cfgEff_img";
	CfgVariantTable.AdjustCSSOfSearchIcon = function(maindiv){
		var searchIcon = maindiv.getElement('div#searchIconCont').getElement('span.fonticon-search');
		searchIcon.setAttribute('style','font-size:14px!important;position:absolute;right:2px;bottom:10px;');
		var cancelIcon = maindiv.getElement('div.AutoPick1div').getElement('span.fonticon-clear');
		cancelIcon.setAttribute('style','right:15px;');			
	};
	
	CfgVariantTable.AdjustCSSOfTableIconBar = function(maindiv){
		var sizeOfIcon = "font-size:18px!important;";
		
		var iconBarContainer = maindiv.getElement('div#containerIconbar');
		var iconBar = iconBarContainer.getElement('.iconbar');
		iconBar.setAttribute('style','float:right;');
		
		var plusIcon = iconBarContainer.getElement('span.fonticon-plus');
		plusIcon.setAttribute('style',sizeOfIcon);
		
		var clearIcon = iconBarContainer.getElement('span.fonticon-clear');
		clearIcon.setAttribute('style',sizeOfIcon);
		
		var docsIcon = iconBarContainer.getElement('span.fonticon-docs');
		docsIcon.setAttribute('style',sizeOfIcon);		
		
		var trashIcon = iconBarContainer.getElement('span.fonticon-trash');
		trashIcon.setAttribute('style',sizeOfIcon);
	
		
		var selectonIcon = iconBarContainer.getElement('span.fonticon-select-on');
		selectonIcon.setAttribute('style',sizeOfIcon);
			
		
		/*jQuery("div#containerIconbar").find(".iconbar").css("float","right"); 
			jQuery("div#containerIconbar").find("span.fonticon-plus").attr("style","font-size:18px!important;");
			jQuery("div#containerIconbar").find("span.fonticon-clear").attr("style","font-size:18px!important;");
			jQuery("div#containerIconbar").find("span.fonticon-docs").attr("style","font-size:18px!important;");
			jQuery("div#containerIconbar").find("span.fonticon-trash").attr("style","font-size:18px!important;");
			jQuery("div#containerIconbar").find("span.fonticon-select-on").attr("style","font-size:18px!important;");
			*/
	};
	CfgVariantTable.AdjustCSSOfExpBoxIconBar = function(maindiv){		
		var expIconBar = maindiv.getElement('div#effExpHeaderIconBar');
	
		var minusIcon = expIconBar.getElement('span.fonticon-minus');
		minusIcon.setAttribute('style','font-size:18px!important;');
		
		var resizeIcon = expIconBar.getElement('span.fonticon-resize-full');
		resizeIcon.setAttribute('style','font-size:16px!important;');
		/*
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-minus").attr("style","font-size:18px!important;");
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-resize-full").attr("style","font-size:16px!important;");
		*/
	};
	
     CfgVariantTable.AdjustCSSOfIcons =function(maindiv){
		    CfgVariantTable.AdjustCSSOfSearchIcon(maindiv);
			CfgVariantTable.AdjustCSSOfTableIconBar(maindiv);	
			CfgVariantTable.AdjustCSSOfExpBoxIconBar(maindiv);			
     };
 
   CfgVariantTable.DisplayEffectivityExpression = function() {      
        var expanderContent = document.getElementById("expanderContent");
        jQuery(expanderContent)[0].setContent(CfgVariantExpServices.GetEffectivityExpression());   			
    };

    //Function to clear the tables contents
    CfgVariantTable.ClearTable = function(auto) {
      document.getElementById('tableH').empty();
      document.getElementById('tableL').empty();
      document.getElementById('tableD').empty();
      var jsonobjEffExpText = CfgVariantExpServices.GetJSONText();
      var json = JSON.parse(jsonobjEffExpText);
      json.Combinations = [];
      var stringjson = JSON.stringify(json);
      CfgVariantExpServices.SetJSONText(stringjson);
     
	  if(auto != null && auto != 'undefined'){
      auto.getItems().forEach(function(item) {      
        auto.enableItem(item.value);
      });
	}
       CfgVariantTable.DisplayEffectivityExpression();   

    };
	
	//QD9 
	CfgVariantTable.getAutoItem = function(auto,toBeCheckedItem){
		var item =false;
		var items = auto.getItems();
			for(var i=0;i<items.length;i++){
				if(items[i].label == toBeCheckedItem.label && items[i].value == toBeCheckedItem.value){
					item = items[i];
					break;
				}
			}
		return item;
	};
	//QD9 
	//Empty check
	CfgVariantTable.EmptyCheck = function(){
		if(jQuery("table#tableL").children('tbody').length == 0){
			jQuery("div#emptyContent").css("display","block");
			jQuery("div#emptyContent").css("height","calc(100% - 40px)");	
			jQuery("div#containerData").css("display","none");	
			jQuery("div#containerData").css("height","0px");		
			CfgVariantTable.DisableMultiSelectMenu();
			jQuery("div#containerIconbar").hide();
			return true;			
		}
		else{
			jQuery("div#emptyContent").css("display","none");
			jQuery("div#emptyContent").css("height","0px");
			jQuery("div#containerData").css("display","block");
			jQuery("div#containerData").css("height","calc(100% - 40px)");			
			jQuery("div#containerIconbar").show();
			return false;
		}
	};
	
	//QD9 
	//Load Model with JSON On UI
	CfgVariantTable.RenderModelWithJSONOnUI = function(model){							
		CfgVariantTable.DisableMultiSelectMenu();
		CfgVariantTable.RestoreEBox(globalAutoComplete);
		
		var jsonobjEffExpText =  model.get("jsonAttr");    

		CfgVariantTable.ClearTable(globalAutoComplete);
		
		if(jsonobjEffExpText == null || jsonobjEffExpText == 'undefined' || jsonobjEffExpText == ''){
			CfgVariantTable.EmptyCheck();					
			return;
		}
		
							
		var redraw_json = JSON.parse(jsonobjEffExpText);
		
		for( var col = 0; col < redraw_json.Combinations.length ; col++){
			//Combination iteration (column)
			for( var opt = 0; opt < redraw_json.Combinations[col].Combination.length; opt++){
				
				for( var op = 0; op < redraw_json.Combinations[col].Combination[opt].Options.length; op++){					
					var item = CfgVariantTable.getAutoItem(globalAutoComplete,redraw_json.Combinations[col].Combination[opt].Options[op].Option);					
					CfgVariantTable.onSelectElement(item, -1, globalAutoComplete);				                   
				}		
			}
		}
		
		for( var col = 0; col < redraw_json.Combinations.length ; col++){  		
			if(redraw_json.Combinations[col].Combination.length > 0)
			CfgVariantTable.AddColumn(tableH, tableD, tableL);
		}
		
		for( var col = 0; col < redraw_json.Combinations.length ; col++){
			var combinationCol = redraw_json.Combinations[col];
			//var col_num = combinationItem.Id;
			var col_num = col;
			for( var opt = 0; opt < combinationCol.Combination.length; opt++){
				var featureCombination = combinationCol.Combination[opt];
				
			for( var op = 0; op < featureCombination.Options.length; op++){	
					var COption = featureCombination.Options[op].Option;
					var row_num = CfgVariantTable.GetRowNoOfCFOption(COption);
					if(row_num == null) {
						console.log("CfgVariantTable.redrawTable  : Row_num could not be identified while rendering redraw_json");
					}
					var td = CfgVariantTable.GetTdByCordinates('tableD',row_num,col_num);
					if(td!=null){
						CfgVariantTable.UpdateImgCheckBox(td.getElementsByTagName('img')[0],'on');
						var item = CfgVariantTable.getAutoItem(globalAutoComplete,redraw_json.Combinations[col].Combination[opt].Options[op].Option);
						var parentItem = globalAutoComplete.getItem(item.parentItemId);
						CfgVariantExpServices.AddCheckBoxBehaviourOnSelect(col_num, parentItem, item);
						CfgVariantTable.DisplayEffectivityExpression();
					}
					else{
						console.log("CfgVariantTable.redrawTable  : TD could not be retrieved while rendering redraw_json");	
					}
				}
			}
		}
	
		CfgVariantTable.EmptyCheck();						
	};
	CfgVariantTable.EnableMultiSelectMenu = function(){
		isMultiSelectOn = true;
		jQuery("div#containerIconbar").find("span.fonticon-select-on").css("color","#368ec4");
		jQuery("table#tableH").find("img").show();
		jQuery("div#containerIconbar").find("li.item").each(function(){
			if(jQuery(this).children("span.fonticon-docs").length == 1 || jQuery(this).children("span.fonticon-trash").length == 1 ){
				jQuery(this).show();
			}
		});	
	};
	CfgVariantTable.DisableMultiSelectMenu = function(){
		isMultiSelectOn = false;								
		
		jQuery("div#containerIconbar").find("span.fonticon-select-on").css("color","#b4b6ba");
		jQuery("table#tableH").find("img").hide();
		jQuery("div#containerIconbar").find("li.item").each(function(){
			if(jQuery(this).children("span.fonticon-docs").length == 1 || jQuery(this).children("span.fonticon-trash").length == 1 ){
				jQuery(this).hide();
			}
		});
				
	};
	CfgVariantTable.RestoreMaximizedEBox = function(auto){
		isEBoxMaximized = false;		
		if(auto)
			auto.enable();
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-minus").css("color","#b4b6ba");
		jQuery("div#effExpHeaderIconBar").find("li.item span.fonticon-resize-small").attr("class","fonticon fonticon-resize-full");
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-resize-full").css("color","#b4b6ba");
		jQuery("div#containerHeaderBar").css("display","block");	
		jQuery("div#effArea").css("height","calc(100% - 40px)");	
		jQuery("div#containerEffectivityTable").css("display","block");
                jQuery("div#containerEffectivityTable").css("height","calc(100% - 150px)");
		CfgVariantTable.EmptyCheck();		
		jQuery("div#containerEffectivityExpression").css("height","150px");		
		jQuery("div#expanderContent").css("display","block");
		jQuery("div#expanderContent").css("height","calc(100% - 50px)");
	};
	CfgVariantTable.RestoreMinimizedEBox = function(){
		isEBoxMinimized = false;		
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-minus").css("color","#b4b6ba");						
		jQuery("div#effArea").css("height","calc(100% - 40px)");	
		jQuery("div#containerEffectivityTable").css("display","block");
                jQuery("div#containerEffectivityTable").css("height","calc(100% - 150px)");
		CfgVariantTable.EmptyCheck();		
		jQuery("div#containerEffectivityExpression").css("height","150px");		
		jQuery("div#expanderContent").css("display","block");
		jQuery("div#expanderContent").css("height","calc(100% - 50px)");
	};
	CfgVariantTable.RestoreEBox = function(auto){
		isEBoxMaximized = false;
		isEBoxMinimized = false;
		if(auto)
			auto.enable();
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-minus").css("color","#b4b6ba");
		jQuery("div#effExpHeaderIconBar").find("li.item span.fonticon-resize-small").attr("class","fonticon fonticon-resize-full");
		jQuery("div#effExpHeaderIconBar").find("span.fonticon-resize-full").css("color","#b4b6ba");
		jQuery("div#containerHeaderBar").css("display","block");	
		jQuery("div#effArea").css("height","calc(100% - 40px)");	
		jQuery("div#containerEffectivityTable").css("display","block");
                jQuery("div#containerEffectivityTable").css("height","calc(100% - 150px)");
		CfgVariantTable.EmptyCheck();		
		jQuery("div#containerEffectivityExpression").css("height","150px");		
		jQuery("div#expanderContent").css("display","block");
		jQuery("div#expanderContent").css("height","calc(100% - 50px)");
	 };
    
	CfgVariantTable.MaximizeEBox = function(auto){
			if(isEBoxMinimized == true){
				CfgVariantTable.RestoreMinimizedEBox();
			}			
			isEBoxMaximized = true;
			if(auto)
				auto.disable();
			jQuery("div#effExpHeaderIconBar").find("li.item span.fonticon-resize-full").attr("class","fonticon fonticon-resize-small");
			jQuery("div#effExpHeaderIconBar").find("span.fonticon-resize-small").css("color","#368ec4");
                        jQuery("div#containerEffectivityTable").css("height","0%");	
			jQuery("div#containerEffectivityTable").css("display","none");	
			jQuery("div#containerHeaderBar").css("display","none");	
			jQuery("div#effArea").css("height","100%");				
			jQuery("div#containerIconbar").hide();
			jQuery("div#containerEffectivityExpression").css("height","100%");	
			
	};
	CfgVariantTable.MinimizeEBox = function(auto){
		    if(isEBoxMaximized == true){
				CfgVariantTable.RestoreMaximizedEBox(auto);
			}
			isEBoxMinimized = true;
			if(auto)
				auto.enable();
			jQuery("div#effExpHeaderIconBar").find("span.fonticon-minus").css("color","#368ec4");
			jQuery("div#containerHeaderBar").css("display","block");	
			jQuery("div#effArea").css("height","calc(100% - 40px)");
			jQuery("div#containerEffectivityTable").css("display","block");
           	        jQuery("div#containerEffectivityTable").css("height","calc(100% - 50px)");	
			CfgVariantTable.EmptyCheck();
			jQuery("div#containerEffectivityExpression").css("height","50px");
			jQuery("div#expanderContent").css("height","0px");
			jQuery("div#expanderContent").css("display","none");
	};
	
  	CfgVariantTable.InitModelWithDictionaryOnUI = function(MainDiv, model, collection){		
			globalAutoComplete = null;
			CfgVariantExpServices.SetModel(model);
			CfgVariantExpServices.SetCollection(collection);	 
			
		    effContainer = UWA.createElement('div');
            effContainer.setAttribute("id", "effContainer");
			MainDiv.appendChild(effContainer);    
			  
            containerHeaderBar = UWA.createElement('div');
            containerHeaderBar.setAttribute("id", "containerHeaderBar");

            containerAuto = UWA.createElement('div');
            containerAuto.setAttribute("id", "containerAuto");
            containerIconbar = UWA.createElement('div');
            containerIconbar.setAttribute("id", "containerIconbar");               

            containerHeaderBar.appendChild(containerAuto);     
            containerHeaderBar.appendChild(containerIconbar);

            effContainer.appendChild(containerHeaderBar);          


            var autocompleteHierarchicalInput = new Autocomplete({
                multiSelect: false,
                showSuggestsOnFocus: false, //To show the elements before selecting one
                placeholder: CfgVarEffNLS.Auto_Place_Holder,
                // minLengthBeforeSearch: 2,
                disabled: false,
                allowFreeInput: true,

                // closableItems: true,

                events: {

                    //Manage events on the autocomplete component
                    onSelect: function(item, position) {

                        CfgVariantTable.onSelectElement(item, position, this);
                        this.onUnselect(item);

                    },
                    onUnselect: function(item, position) {

                    }
                }

            });
			
			var AutoPick1 = UWA.createElement("div", {
                'class': 'AutoPick1div'
            });
            AutoPick1.setStyles({
                position: 'relative',
                marginRight: '15px'
            });
            AutoPick1.style.display = "inline-block";
            autocompleteHierarchicalInput.inject(AutoPick1);
            AutoPick1.inject(containerAuto);

            var SearchIconSpan1 = UWA.createElement('span', {
                'class': "fonticon fonticon-1x fonticon-search"
            });      
            var imgSearchContainer1 = UWA.createElement('div', {
                'class': 'imgSearchContainer1',
				'id': 'searchIconCont'
            });
		
            imgSearchContainer1.style.opacity = '0.5';
            imgSearchContainer1.addClassName('imgFocusIdenty');
            imgSearchContainer1.addContent(SearchIconSpan1);
            SearchIconSpan1.inject(imgSearchContainer1);			
			
            imgSearchContainer1.addEventListener("click", function() {
                autocompleteHierarchicalInput.showAll();               
            });

            imgSearchContainer1.inject(AutoPick1);		    			
			
			var inconbar = new Iconbar({
                renderTo: containerIconbar,
                items: [{
                        fonticon: 'plus',				
                        text: CfgVarEffNLS.Add_Col,
                        handler: function() {
                            CfgVariantTable.AddColumn(tableH, tableD, tableL);
                        }
                    },					
					{
                        fonticon: 'clear',
                        text: CfgVarEffNLS.Clear_Table,
                        handler: function() {						  
                           CfgVariantTable.ClearTable(autocompleteHierarchicalInput);	
						   CfgVariantTable.EmptyCheck();					      											 
                        }
                    },
					{
                        fonticon: 'docs',
                        text: CfgVarEffNLS.Clone_Col,
                        handler: function() {
                            CfgVariantTable.GetCombinationsToDuplicate(tableH, tableD, tableL);
                        }
                    },          
                    {
                        fonticon: 'trash',
                        text: CfgVarEffNLS.Del_Col,
                        handler: function() {
                            CfgVariantTable.DeleteColumn(tableH, tableD);
							
                        }
                    },					
                    {
                        fonticon: 'select-on',
                        text: CfgVarEffNLS.Multi_Select,
                        handler: function() {    							
						 if(jQuery("table#tableH").children('tbody').length == 1){
							if(isMultiSelectOn === false){
								//Disabled, Enable it
								CfgVariantTable.EnableMultiSelectMenu();
							}
							else{	
								//Enabled, Disable it
								CfgVariantTable.DisableMultiSelectMenu(); 								
							}                                                                               
						  }
                        }
                    }                  

                ]
				
            });			
			
			
            containerEffectivityTable = UWA.createElement('div');
            containerEffectivityTable.setAttribute("id", "containerEffectivityTable");

            containerHeader = UWA.createElement('div');
            containerHeader.setAttribute("id", "containerHeader");
            containerHeader.setAttribute("class", "containerscroll");
         
            containerEffectivityTable.appendChild(containerHeader);

			emptyContent = UWA.createElement('div',{				
				styles:{
				'color':'silver',
				'text-align':'center',
				'justify-content': 'center',				
				'display': 'none'
			}});
			emptyContent.setAttribute("id","emptyContent");
			emptyContent.setHTML("<span class='fonticon fonticon-2x fonticon-doc'></span><br/><font-size='17px>"+CfgVarEffNLS.No_Eff_IconMsg+"</font>");					
			containerEffectivityTable.appendChild(emptyContent);
			
			containerData = UWA.createElement('div');
            containerData.setAttribute("id", "containerData");
			containerEffectivityTable.appendChild(containerData);
			
            containerLeft = UWA.createElement('div');
            containerLeft.setAttribute("id", "containerLeft");
            containerLeft.setAttribute("class", "containerscroll");
            containerData.appendChild(containerLeft);

            container = UWA.createElement('div');
            container.setAttribute("id", "container");
            container.setAttribute("class", "containerscroll");
            containerData.appendChild(container);
           
            var tableH = UWA.createElement("table");
            var tableL = UWA.createElement("table");
            var tableD = UWA.createElement("table");


            tableH.setAttribute("id", "tableH");
            tableH.setAttribute("class", "table");

            tableL.setAttribute("id", "tableL");
            tableL.setAttribute("class", "table");

            tableD.setAttribute("id", "tableD");
            tableD.setAttribute("class", "table");

            containerHeader.appendChild(tableH);
            containerLeft.appendChild(tableL);
            container.appendChild(tableD);

            containerHeader.addEventListener("mouseover", function() {
                containerHeader.style.overflowY = "scroll";
                container.style.overflowY = "scroll";
            });
            container.addEventListener("mouseover", function() {
                containerHeader.style.overflowY = "scroll";
                container.style.overflowY = "scroll";
            });

            containerHeader.addEventListener("mouseout", function() {
                containerHeader.style.overflowY = "hidden";
                container.style.overflowY = "hidden";
            });
            container.addEventListener("mouseout", function() {
                containerHeader.style.overflowY = "hidden";
                container.style.overflowY = "hidden";
            });

            if (containerLeft.addEventListener) {
                // IE9, Chrome, Safari, Opera
                // container.addEventListener("mousewheel", MouseWheelHandler, true);
                containerLeft.addEventListener("scroll", CfgVariantTable.MouseWheelHandler, true);
                // Firefox
                // container.addEventListener("DOMMouseScroll", MouseWheelHandler, true);
                containerLeft.addEventListener("scroll", CfgVariantTable.MouseWheelHandler, true);
            }
            // IE 6/7/8
            else
                // container.attachEvent("onmousewheel", MouseWheelHandler);  
                containerLeft.addEventListener("scroll", CfgVariantTable.MouseWheelHandler, true);

            if (container.addEventListener) {
                // IE9, Chrome, Safari, Opera
                // container.addEventListener("mousewheel", MouseWheelHandler, true);
                container.addEventListener("scroll", CfgVariantTable.MouseWheelHandler, true);
                // Firefox
                // container.addEventListener("DOMMouseScroll", MouseWheelHandler, true);
                container.addEventListener("scroll", CfgVariantTable.MouseWheelHandler, true);
            }
            // IE 6/7/8
            else
                // container.attachEvent("onmousewheel", MouseWheelHandler);  
                container.addEventListener("scroll", CfgVariantTable.MouseWheelHandler, true);

            var effArea = UWA.createElement('div');
            effArea.setAttribute("id", "effArea");
            effContainer.appendChild(effArea);

            effArea.appendChild(containerEffectivityTable);        


            var containerEffectivityExpression = UWA.createElement('div');

            containerEffectivityExpression.setAttribute("id", "containerEffectivityExpression");
            effArea.appendChild(containerEffectivityExpression);
           
            var effExpHeader =  UWA.createElement('div',{
			styles:{
			    height:'40px'			
			}
	     });
            effExpHeader.setAttribute("id", "effExpHeader");
            effExpHeader.inject(containerEffectivityExpression);
	      
            var effExpHeaderTitle =  UWA.createElement('div',{
			text:CfgVarEffNLS.Eff_Expression,
			styles:{			  			
			  float:'left',
			  fontWeight:'bold',
			  paddingTop: '5px'
			}
	     });
            effExpHeaderTitle.setAttribute("id", "effExpHeaderTitle");
            effExpHeaderTitle.inject(effExpHeader);

	     var effExpHeaderIconBar =  UWA.createElement('div',{			
			styles:{
			  float:'right'			  
			}
	     });
            effExpHeaderIconBar.setAttribute("id", "effExpHeaderIconBar");
            effExpHeaderIconBar.inject(effExpHeader);
            var expIconBar = new Iconbar({
                renderTo: effExpHeaderIconBar,
                items: [{
                        fonticon: 'minus',						
						name: 'minimize_icon',
                       /* text: CfgVarEffNLS.Min_EBox,*/
                        handler: function() {
							if(isEBoxMinimized === false){
								//Minimize it
								CfgVariantTable.MinimizeEBox(autocompleteHierarchicalInput);
							}
							else{	
								//Restore it
								CfgVariantTable.RestoreEBox(autocompleteHierarchicalInput); 			
								
							}                                  							
                        }
                    },
                    {
                        fonticon: 'resize-full',						
						name: 'maximize_icon',						
                      /*  text: CfgVarEffNLS.Max_EBox,*/
                        handler: function() {
							if(isEBoxMaximized === false){
								//Maximize it
								CfgVariantTable.MaximizeEBox(autocompleteHierarchicalInput);
							}
							else{	
								//Restore it
								CfgVariantTable.RestoreEBox(autocompleteHierarchicalInput); 								
							}                                               										
                        }
                    }           
                ]

            });
		
	     var effExpContent = UWA.createElement('div',{
			text:'', /*CfgVarEffNLS.No_Eff_Msg*/
			styles: {
		        overflow: 'auto',
			 border: '1px solid #D4D4D4',
			 padding:'5px'			
    			}
		});
	    effExpContent.setAttribute("id", "expanderContent");		
            effExpContent.inject(containerEffectivityExpression);
 
	
		/******* Load Dictionary ****************/
		
		MainDiv.getElement('div#containerIconbar').hide();	
		CfgVariantTable.AdjustCSSOfIcons(MainDiv);
		
	    var dictionaryData = CfgVariantUtility.getCachedModelDictionary(model.get('idModel'));
		if(dictionaryData == null){			
			CfgVariantUtility.getModelDictionary(model.get('idModel')).then(function(dictionaryData){
					CfgVariantTable.DrawDictionary(autocompleteHierarchicalInput, dictionaryData);					
					CfgVariantTable.RenderModelWithJSONOnUI(model);
				},function (error_response) {										
					CfgUtility.showwarning(CfgVarEffNLS.Dictionary_Error,'error');	
				}
			); 			
		}
		else{	
			CfgVariantTable.DrawDictionary(autocompleteHierarchicalInput, dictionaryData);			
			CfgVariantTable.RenderModelWithJSONOnUI(model);
		}
				
	};

	//function to draw Dictionary
	CfgVariantTable.DrawDictionary = function(autocompleteHierarchicalInput, dictionaryData){
			var y = JSON.stringify(dictionaryData);
			var jsonExInf = JSON.parse(y);
			CfgVariantExpServices.SetJsonContextID(jsonExInf.name);

			if (jsonExInf.features.length == 0) {
			  window.notifs = NotificationsManager;
			  NotificationsManagerViewOnScreen.setNotificationManager(window.notifs);
			  // Configurates the notification options.
			  var infoOptions = {
				level: 'warning',
				title: CfgVarEffNLS.No_Conf_Features_Title,
				subtitle: '',
				message:  CfgVarEffNLS.No_Conf_Features_Msg,
				sticky: false
			  };
			  // Adds the notification options.
			  window.notifs.addNotif(infoOptions);
			} else {
			  //parsing the result and retrieving information
			  
			  var jsonDatasetText = '{"name" : "Objects","items": [';
			  for (var key = 0; key < jsonExInf.features.length; key++) {
			   if(jsonExInf.features[key].options.length == 0){			   
				   continue;
			   }
			   jsonDatasetText = jsonDatasetText + '{"label": ' + '"' + jsonExInf.features[key].displayValue + '"' + ',"value": ' + '"' + jsonExInf.features[key].name + '"' + ',"items": [';
				for (var subkey = 0; subkey < jsonExInf.features[key].options.length; subkey++) {
				  jsonDatasetText = jsonDatasetText + '{"label": ' + '"' + jsonExInf.features[key].options[subkey].displayValue + '"' + ',"value" : ' + '"' + jsonExInf.features[key].options[subkey].name + '"' + '},'
				 }
				jsonDatasetText = jsonDatasetText.substring(0, jsonDatasetText.length - 1);
				jsonDatasetText = jsonDatasetText + "]},";
			  }
			  jsonDatasetText = jsonDatasetText.substring(0, jsonDatasetText.length - 1);
			  jsonDatasetText = jsonDatasetText + "]}";
			
			  hierarchicalDataset = JSON.parse(jsonDatasetText);
			  autocompleteHierarchicalInput.addDataset(hierarchicalDataset);

			  autocompleteHierarchicalInput.getItems().forEach(function(item) {
			 
				autocompleteHierarchicalInput.enableItem(item.value);
			  });

			}	
		
			globalAutoComplete = autocompleteHierarchicalInput;				
			
	};
    
	//Function to add dynamically a Zebra Effect to the table
    CfgVariantTable.AddZebraEffect = function(tableD) {
      var NbRows = document.getElementById('tableD').rows.length;
      for (var j = 0; j < NbRows; j++) {
        if (document.getElementById('tableD').rows[j].cells.length > 0) {
          if (CurrentColor == 1) {
            document.getElementById('tableD').rows[j].style.backgroundColor = "#ffffff";
            document.getElementById('tableL').rows[j].style.backgroundColor = "#ffffff";
            CurrentColor = 0;
          } else {
            document.getElementById('tableD').rows[j].style.backgroundColor = "#f4f5f6";
            document.getElementById('tableL').rows[j].style.backgroundColor = "#f4f5f6";
            CurrentColor = 1;
          }
        } else {}
      }
      CurrentColor = 1;
    };

    //Synchronizing scrolls between tables
    CfgVariantTable.MouseWheelHandler = function(event) {
      var $elm = jQuery(event.target);
      var SourceTableScroll = $elm.parent().attr('id');
      var SourceTableScroll = $elm.attr('id')
      if (SourceTableScroll == 'container') { // or any other filtering condition
        // do some stuff
        var containerLeft = document.getElementById("containerLeft");
        jQuery(containerLeft).scrollTop($elm.scrollTop());
        var containerHeader = document.getElementById("containerHeader");
        jQuery(containerHeader).scrollLeft($elm.scrollLeft());

      }
      return true;
    };

    //Get Parent feature of a selected option (in autocomplete Hierarchical structure)
     CfgVariantTable.GetParentConfigFeature = function(tableL, Childindex) {
      var indiceCOCourant = Childindex;
      var trouve = false;
      var CF = {};
      while ((trouve == false) && (indiceCOCourant >= 0)) {
        var x = parseInt(jQuery(tableL).find('tr:eq(' + indiceCOCourant + ')').children('td:first-child').attr('rowspan'));
        var x1 = jQuery(tableL).find('tr:eq(' + indiceCOCourant + ')').children('td:first-child');
        if (x > 0) {
          CF.label = tableL.rows[indiceCOCourant].cells[0].getElementsByClassName("textContainer1")[0].innerText;
		  CF.value = tableL.rows[indiceCOCourant].cells[0].getElementsByClassName("textContainer1")[0].getAttribute("FOName");
          trouve = true;
        } else {
          indiceCOCourant--;
        }
      }
     return CF;
    };

    //Get option label at a specific table index
   CfgVariantTable.GetConfigOption = function(tableL, row_num) {
      var CO ={};
	  CO.label = tableL.rows[row_num].cells[0].getElementsByClassName("textContainer1")[0].innerText;
      CO.value = tableL.rows[row_num].cells[0].getElementsByClassName("textContainer1")[0].getAttribute("FOName");
      
      return CO;
    };


    //Delete one column from the combination table
    CfgVariantTable.DeleteColumnSelected = function(tableH, tableD, position) {
      var n = jQuery(tableH).find('th:eq(' + position + ')').index();
      CfgVariantExpServices.UpdateCombinationsIfDeleteColumn(n);
      CfgVariantTable.DisplayEffectivityExpression();

      if ((jQuery(tableH).find('tr:eq(0)').children('th').length) >= 1) {
        jQuery(tableH).find('th:eq(' + position + ')').remove();
      }
      jQuery(tableD).find('tr').each(function() {

        var tds = jQuery(this).children('td').length;
        if (tds >= 1) {
          jQuery(this).children('td:eq(' + position + ')').remove();
        }
      });
    };

    //Delete a number of columns (it's a function that loops all the selected columns and calls the DeleteColumnSelected method)
    CfgVariantTable.DeleteColumn = function(tableH, tableD) {
      var ColsNumber = document.getElementById('tableH').rows[0].cells.length;
      var i = ColsNumber - 1;
      while (i >= 0) {
		  var imgElement = document.getElementById('tableH').rows[0].cells[i].getElementsByTagName('img')[0];
        if (imgElement.hasAttribute('eff_state') && imgElement.getAttribute('eff_state') === '1') {        
          CfgVariantTable.DeleteColumnSelected(tableH, tableD, i);
        }
        i--;
      }
	  
	 
      //If there is no more combinations selected , we should add a new one
      if (document.getElementById('tableH').rows[0].cells.length == 0) {
        CfgVariantTable.AddColumn(tableH, tableD, tableL);
		if(isMultiSelectOn === true)
			jQuery("table#tableH").find("img").show();
      }
	  
	  var json = JSON.parse(CfgVariantExpServices.GetJSONText());
	  for(var i=0;i< json.Combinations.length;i++){
		json.Combinations[i].Id =  i; 
	  }
	  
	  
    };

	/* QD9
	 create tri state check box behaviour using images
	 
	 state : 
			off = unchecked check box
			on = checked box
			not = not (future requirement)
	 */
	 
	CfgVariantTable.CreateImgCheckBox = function(state) {	 	 
	  
      var CBox = UWA.createElement("img");
	  CBox.setAttribute("class",CfgVariantTable.cfgEff_img_class);
	  
	  if(state === 'off'){
		CBox.setAttribute("src",CfgVariantTable.uncheckImgUrl);
		CBox.setAttribute("eff_state","0");
	  }
	  else if(state === 'on'){
		CBox.setAttribute("src",CfgVariantTable.checkImgUrl);
		CBox.setAttribute("eff_state","1");  
	  }
	  else if(state === 'not'){
		  //future requirement for NOT implementation
	  }		  
	  
	  return CBox;
	}
	
	/* QD9
	 update state of check box
	 
	 state : 
			off = unchecked check box
			on = checked box
			not = not (future requirement)
	 */
	 
	CfgVariantTable.UpdateImgCheckBox = function(CBox,state) {
	  
	  if(state === 'off'){
		CBox.setAttribute("src",CfgVariantTable.uncheckImgUrl);
		CBox.setAttribute("eff_state","0");
	  }
	  else if(state === 'on'){
		CBox.setAttribute("src",CfgVariantTable.checkImgUrl);
		CBox.setAttribute("eff_state","1");  
	  }
	  else if(state === 'not'){
		  //future requirement for NOT implementation
	  }		  	  
	  return CBox;
	}
	
    //Adding a new combination column
    CfgVariantTable.AddColumn = function(tableH, tableD, tableL) {	  
	 
      //Adding a table Header
      var trowH = jQuery(tableH).find('tr:eq(' + 0 + ') ');
      var headerC = UWA.createElement("TH");
	  
	  var TH_CBox = CfgVariantTable.CreateImgCheckBox('off');
	  
      var CheckBoxes = document.getElementById('tableH').getElementsByTagName('img');

      if (CheckBoxes.length == 0){
        TH_CBox.hide();
      }
      else{
          if(CheckBoxes[0].style.display === 'none'){
          TH_CBox.hide();
          }
          else
          {
            TH_CBox.show();
          }
      }
    
      TH_CBox.inject(headerC);
	  
      headerC.onclick = function() {
		jQuery(this).find('img.cfgEff_img').each(function() { // there will be only one iteration
				  if (jQuery(this).attr('eff_state') === '0') {					 					
					  CfgVariantTable.UpdateImgCheckBox(jQuery(this)[0],'on');						
                  } 
                  else if (jQuery(this).attr('eff_state') === '1') {					 
					  CfgVariantTable.UpdateImgCheckBox(jQuery(this)[0],'off');
                  } 				 			  
                });
      };
	  
      trowH.append(headerC);
      
	
      for (var i = 0; i <= jQuery('#tableL tr').length; i++) {
        jQuery(tableL).find('tr:eq(' + i + ') ').each(function() {

          var trow = jQuery(this);
          var trowD = jQuery(tableD).find('tr:eq(' + i + ') ');
          var x = parseInt(trow.children('td:not(:empty)').first().attr('rowspan'));
          if (x > 0) {} else {
           if (trow.index() == 0) {

            } else {
              //Adding a td
              var COSelected;
              var CFSelected;
              var tdata = UWA.createElement("TD");
			  var TD_CBox = CfgVariantTable.CreateImgCheckBox('off');
			  TD_CBox.inject(tdata);
              trowD.append(tdata);

              tdata.onclick = function(event) {
                var jQueryelm = jQuery(event.target);
                var row_index = jQuery(this).parent().index();
                var col_index = jQuery(this).index();

                //Getting the label of the config option selected
                var COSelected = CfgVariantTable.GetConfigOption(tableL, row_index);
                //Get ParentFeature
                var CFSelected = CfgVariantTable.GetParentConfigFeature(tableL, row_index);

				jQuery(this).find('img.cfgEff_img').each(function() { // there will be only one iteration
				  if (jQuery(this).attr('eff_state') === '0') {
					  // Need to update behaviour as user want to check box 
					  CfgVariantExpServices.AddCheckBoxBehaviourOnSelect(col_index, CFSelected, COSelected);
					  CfgVariantTable.UpdateImgCheckBox(jQuery(this)[0],'on');
						
                  } 
                  else if (jQuery(this).attr('eff_state') === '1') {
					  // Need to update behaviour as user want to uncheck box
					  CfgVariantExpServices.AddCheckBoxBehaviourOnUnSelect(col_index, CFSelected, COSelected);
					  CfgVariantTable.UpdateImgCheckBox(jQuery(this)[0],'off');
                  } 				 			  
                });
						
				CfgVariantTable.DisplayEffectivityExpression();          
				
				//Add column if check box checked 
                var c = false;
                jQuery('#tableD').find('tr td:last-child img').each(function() {
                  if (jQuery(this).attr('eff_state') === '1') {
                    if (c == false) {
                      CfgVariantTable.AddColumn(tableH, tableD, tableL);
                      c = true;
                    }
                  } 
                });			     
                   		        			
				              
              } 

            }
          }
        });
      } 
	  CfgVariantExpServices.UpdateJsonOnAddColumn();
    };

    //Add new rows to the combination table when an element is selected
    CfgVariantTable.UpdateDataRows = function(tableHeader, tableData, rowt, MGMTable) {
     var columnCount;      
if (document.getElementById('tableH').rows.length == 0) {
        columnCount = 0;
      } else {
        columnCount = document.getElementById('tableH').rows[0].cells.length;
      }

      for (var j = 1; j <= columnCount; j++) {
        //adding a td
        var tdata = UWA.createElement("TD");
		var CBox = CfgVariantTable.CreateImgCheckBox('off');
        CBox.inject(tdata);
		
        rowt.appendChild(tdata);
        var COSelected;
        var CFSelected;
   
        tdata.onclick = function() {
		
          var row_index = jQuery(this).parent().index();
          var col_index = jQuery(this).index();

         //Get Config option selected
          var COSelected = CfgVariantTable.GetConfigOption(tableL, row_index);
          //Get Parent Config Feature
          var CFSelected = CfgVariantTable.GetParentConfigFeature(tableL, row_index);
		  
		   jQuery(this).find('img.cfgEff_img').each(function() { // there will be only one iteration
				  if (jQuery(this).attr('eff_state') === '0') {
					  // Need to update behaviour as user want to check box 
					  CfgVariantExpServices.AddCheckBoxBehaviourOnSelect(col_index, CFSelected, COSelected);
					  CfgVariantTable.UpdateImgCheckBox(jQuery(this)[0],'on');
						
                  } 
                  else if (jQuery(this).attr('eff_state') === '1') {
					  // Need to update behaviour as user want to uncheck box
					  CfgVariantExpServices.AddCheckBoxBehaviourOnUnSelect(col_index, CFSelected, COSelected);
					  CfgVariantTable.UpdateImgCheckBox(jQuery(this)[0],'off');
                  } 				 			  
            });
						
			CfgVariantTable.DisplayEffectivityExpression();        
		  
		  //Add column if check box checked
          var c = false;
          jQuery('#tableD').find('tr td:last-child img').each(function() {
            if (jQuery(this).attr('eff_state') === '1') {
              if (c == false) {
                CfgVariantTable.AddColumn(tableHeader, tableData, tableL);
                c = true;
              }
            } 
          });        

        } 
      }
    };

    //Check if a combination column is empty or not (no checkbox was selected within this column)
    CfgVariantTable.isEmpty = function(tableD, index) {
      var empty = true;
      var RowsNumber = document.getElementById('tableD').rows.length;
      var i = 0;
      while ((i < RowsNumber) && (empty == true)) {
        if (document.getElementById('tableD').rows[i].cells.length > 0) {
		var imgElement = document.getElementById('tableD').rows[i].cells[index].getElementsByTagName('img')[0];
          if (imgElement.hasAttribute('eff_state') && imgElement.getAttribute('eff_state') === '1') {			  
            return false;
          }
        }
        i++;
      }
      return true;
    };

	 CfgVariantTable.GetRowNoOfCFOption = function(CFOption){
		 var leftTable = document.getElementById('tableL');
		for(var row=0 ; row<leftTable.rows.length ; row++ ) {
			for (var col=0; col<leftTable.rows[row].cells.length ; col++){
				var td = leftTable.rows[row].cells[col];
				var textDiv = td.getElementsByClassName("textContainer1");
				if(CFOption.label == textDiv[0].textContent && CFOption.value == textDiv[0].getAttribute("FOName") )
					return row;
			}
		}
		return null;
	 };
	 
	 CfgVariantTable.GetTdByCordinates = function(tableId, rowNum, colNum){
		 var table = document.getElementById(tableId);
		for(var row=0 ; row<table.rows.length ; row++ ) {
			for (var col=0; col<table.rows[row].cells.length ; col++){
				var td = table.rows[row].cells[col];
				if((row == rowNum) && (col == colNum))
					return td;
			}
		}
		return null;
	 }
	 
    //Duplicate Selected columns
    CfgVariantTable.GetCombinationsToDuplicate = function(tableH, tableD, tableL) {
      var DuplicatedArray = [];
      var ColsNumber = document.getElementById('tableH').rows[0].cells.length;
  
      for (var i = 0; i < ColsNumber; i++) {
		var imgElement = document.getElementById('tableH').rows[0].cells[i].getElementsByTagName('img')[0];         
        if (imgElement.hasAttribute('eff_state') && imgElement.getAttribute('eff_state') === '1') {

          var RowsNumber = document.getElementById('tableD').rows.length;
          for (var j = 0; j < RowsNumber; j++) {
              if (document.getElementById('tableD').rows[j].cells.length > 0) {
              var imgElement1 = document.getElementById('tableD').rows[j].cells[i].getElementsByTagName('img')[0];   
              if (imgElement1.hasAttribute('eff_state') && imgElement1.getAttribute('eff_state') === '1') {
                DuplicatedArray.push(true);
              } else {
                DuplicatedArray.push(false);
              }
            } else {
              DuplicatedArray.push(false);
            }
          }

          var empty = CfgVariantTable.isEmpty(tableD, ColsNumber - 1);
          if (empty == false) {
            CfgVariantTable.AddColumn(tableH, tableD, tableL);
          } 
          //Create new Combination and check cells cloned
          for (var cpt = 0; cpt < RowsNumber; cpt++) {
         
            if (document.getElementById('tableD').rows[cpt].cells.length > 0) {
              if (DuplicatedArray[cpt] == true) {
                CfgVariantTable.UpdateImgCheckBox(document.getElementById('tableD').rows[cpt].cells[document.getElementById('tableH').rows[0].cells.length - 1].getElementsByTagName('img')[0], 'on');
                //Getting the Combination ID
                var col_index = document.getElementById('tableH').rows[0].cells.length - 1;
                //Getting the label of the config option selected
                var COSelected = CfgVariantTable.GetConfigOption(tableL, cpt);            
                //Get ParentFeature
                var CFSelected = CfgVariantTable.GetParentConfigFeature(tableL, cpt);
             
                CfgVariantExpServices.AddCheckBoxBehaviourOnSelect(col_index, CFSelected, COSelected);
                CfgVariantTable.DisplayEffectivityExpression();
              }
            }
          }

        } 
        DuplicatedArray = [];
      }
      CfgVariantTable.AddColumn(tableH, tableD, tableL);
    };

    //Check if an element (CF/CO) was already instanciated or not
    CfgVariantTable.checkIfExists = function(item, tableL) {
      var i = 0;
      var trouve = false;
      if ((document.getElementById('tableL').rows.length > 0)) {
        while ((i < document.getElementById('tableL').rows.length) && (trouve == false)) {
        // console.log(tableL.rows[i].cells[0].getElementsByClassName("textContainer1")[0].innerText);
        if ((document.getElementById('tableL').rows[i].cells.length > 0)) {
          if (tableL.rows[i].cells[0].getElementsByClassName("textContainer1")[0].innerText == item.label && tableL.rows[i].cells[0].getElementsByClassName("textContainer1")[0].getAttribute("FOName") == item.value ) 
           {
            trouve = true;
            // console.log('Element Found');
           } else 
           {
            i++;
           }
          }
        }
      }

      return trouve;
    };

    //Add an element to the table once it is selected
    CfgVariantTable.AddElementLeftTable = function(element, item, auto) {
      var widthVal = '90%';
	  if(item.parent != null && item.parent != 'undefined' && item.parent == true){
		  //Feature
		  widthVal = '110px';
	  }
	  else{
		  //Option
		  widthVal = '185px';
	  }
	  var textContainer1 = UWA.createElement('div', {
        'class': 'textContainer1'
      });

      textContainer1.innerText = item.label;
      textContainer1.setStyles({
        width: widthVal
      });
	  textContainer1.setAttribute("FOName",item.value);
	  textContainer1.setAttribute("title",item.value);	  
	  
      element.appendChild(textContainer1);

      var SearchIconSpan1 = UWA.createElement('span', {
        'class': "wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-close "
      });

      var CloseContainer = UWA.createElement('div', {
        'class': 'CloseContainer'
      });
      CloseContainer.setStyles({
        width: '10%'
      });
      // CloseContainer.style.opacity = '0.5';
      CloseContainer.addClassName('CloseContainer');
      CloseContainer.addContent(SearchIconSpan1);
      SearchIconSpan1.inject(CloseContainer);
      element.appendChild(CloseContainer);

      element.addEventListener("mouseover", function() {
        CloseContainer.style.visibility = "visible";
      });
      element.addEventListener("mouseout", function() {
        CloseContainer.style.visibility = "hidden";
      });

       SearchIconSpan1.addEventListener("click", function() {
        var ipItem ={};
		ipItem.label = this.parentElement.parentElement.getElementsByClassName("textContainer1")[0].innerText;
		ipItem.value = this.parentElement.parentElement.getElementsByClassName("textContainer1")[0].getAttribute("FOName");
        var item = CfgVariantTable.getAutoItem(auto,ipItem);
  CfgVariantTable.onUnSelectElement(item, auto);

      });
    };

    //Function to run once an element (CF/CO) is selected
    CfgVariantTable.onSelectElement = function(item, position, auto) {

      var NbRows = document.getElementById('tableD').rows.length;
      if(NbRows == 0){
        var row = tableH.insertRow(-1);
       
      }
       
      var ArrayMembers = [];
      // hierarchicalDataset
    for (var key = 0; key < hierarchicalDataset.items.length; key++) {
        if (hierarchicalDataset.items[key].value == item.value && hierarchicalDataset.items[key].label == item.label) {
          for (var subkey = 0; subkey < hierarchicalDataset.items[key].items.length; subkey++) {					ArrayMembers.push(hierarchicalDataset.items[key].items[subkey]);
          }
        }
      }

      var x = ArrayMembers.length + 1;

      var Exists = CfgVariantTable.checkIfExists(item, tableL);
      if (Exists == true) {
        if (x > 1) {
          console.log('CF already Exists !!');
          //Select the options in the autocomplete component
           for (var key = 0; key <= (hierarchicalDataset.items.length - 1); key++) {
            if (hierarchicalDataset.items[key].value == item.value && hierarchicalDataset.items[key].label == item.label) {
              var ParentLabel = item.label;
		  var ParentValue = item.value;
			  
              for (var subkey = 0; subkey <= (hierarchicalDataset.items[key].items.length - 1); subkey++) {
				
                var item = CfgVariantTable.getAutoItem(auto,hierarchicalDataset.items[key].items[subkey]);
      
                if (item.disabled == false) {
                  //Treatment to do on SubElements (Options) of a Config Feature
                  var i = 0;
                  var trouve = false;
                  var RowNoun = '';

                  while ((i <= jQuery('#tableD tr').length) && (trouve == false)) {
                    var trow = jQuery(tableL).find('tr:eq(' + i + ')');
                    RowNoun = trow.text();
                    // ** need to debug && trow.find("td:eq('0') div.textContainer1").attr("FOName") == ParentValue
                    if (RowNoun == ParentLabel) {
                      trouve = true;
                    } else
                      i++;
                  }          
                  var x = parseInt(jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child').attr('rowspan'));
             
                  jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child').attr('rowspan', x + 1);
                  var row11 = tableL.insertRow(i + 1);
                  var CellCO11 = row11.insertCell(-1); //This is the first column : CO
                  CfgVariantTable.AddElementLeftTable(CellCO11, item, auto);

                  jQuery(row11).addClass('LeftColumnOptions');

                  // var tableRef = document.getElementById('tableD').getElementsByTagName('tbody')[0];
                  var row1 = document.getElementById('tableD').getElementsByTagName('tbody')[0].insertRow(i + 1);
                  CfgVariantTable.UpdateDataRows(tableH, tableD, row1);
                  //Disable Option in autocomplete
                  auto.disableItem(item.value);
                }
             
              }
              auto.disableItem(ParentValue);
              CfgVariantTable.AddZebraEffect(tableD);
            }
          }

      
        } else {
          console.log('Option already Exists !!')
    
        }
      } else {
        // Feature doesn't exist
        if (x > 1) {
          //A  feature is selected
          var row1 = tableL.insertRow(-1);
          var CellCF1 = row1.insertCell(-1); //This is the first column : CF
          CfgVariantTable.AddElementLeftTable(CellCF1, item, auto);
          CellCF1.rowSpan = ArrayMembers.length + 1;
          jQuery(row1).addClass('LeftColumnFeatures');
          var row = tableD.insertRow(-1);
          for (var i = 1; i <= ArrayMembers.length; i++) {
            var row1 = tableL.insertRow(-1);
            var CellCO1 = row1.insertCell(-1);

            CfgVariantTable.AddElementLeftTable(CellCO1, ArrayMembers[i - 1], auto);

            jQuery(row1).addClass('LeftColumnOptions');

            var row = document.getElementById('tableD').getElementsByTagName('tbody')[0].insertRow(-1);

            CfgVariantTable.UpdateDataRows(tableH, tableD, row)
          }

          // disable feature
          auto.disableItem(item.value);

          //Select the options in the autocomplete component
           for (var key = 0; key <= (hierarchicalDataset.items.length - 1); key++) {
            if (hierarchicalDataset.items[key].value == item.value && hierarchicalDataset.items[key].label == item.label) {
              for (var subkey = 0; subkey <= (hierarchicalDataset.items[key].items.length - 1); subkey++) {
                //Treatment to do on SubElements (Options) of a Config Feature 
                var item = CfgVariantTable.getAutoItem(auto,hierarchicalDataset.items[key].items[subkey]);
                if (auto.isSelected(auto.getId(), item) == false) {
                  //Disable all options
                  auto.disableItem(item.value);
                }
              }
            }
          }

        } else {
       
          var thisItem = item;

          var ParentItem = auto.getItem(thisItem.parentItemId);
         

          var nombre = (jQuery('#tableL tr').length);

          //if the table is blank
          if (jQuery('#tableL tr').length == 0) {
            var row01 = tableL.insertRow(-1);
            var CellCF01 = row01.insertCell(-1); //This is the first column : CF

            CfgVariantTable.AddElementLeftTable(CellCF01, ParentItem, auto);

            CellCF01.rowSpan = 2;
            jQuery(row01).addClass('LeftColumnFeatures');

            var row11 = tableL.insertRow(-1);
            var CellCO11 = row11.insertCell(-1); //This is the first column : CO

            CfgVariantTable.AddElementLeftTable(CellCO11, thisItem, auto);

            jQuery(row11).addClass('LeftColumnOptions');

            var row = tableD.insertRow(-1);
            jQuery(row).addClass('LeftColumnFeatures');

            var row1 = document.getElementById('tableD').getElementsByTagName('tbody')[0].insertRow(-1);

            CfgVariantTable.UpdateDataRows(tableH, tableD, row1);

            auto.disableItem(thisItem.value);


          } else {
            var i = 0;
            var trouve = false;
            var RowNoun = '';

          while ((i <= jQuery('#tableD tr').length) && (trouve == false)) {
              var trow = jQuery(tableL).find('tr:eq(' + i + ')');
              RowNoun = trow.text();   //&& trow.find("td:eq('0') div.textContainer1").attr("FOName") == ParentItem.value         
              if (RowNoun == ParentItem.label ) {
                trouve = true;
              } else
                i++;
            }

            //The Parent Feature was instanciated
            if (trouve == true) {
              if (auto.isSelected(auto.getId(), ParentItem) == true) {               
              }

              var x = parseInt(jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child').attr('rowspan'));
              jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child').attr('rowspan', x + 1);

              var row11 = tableL.insertRow(i + 1);
              var CellCO11 = row11.insertCell(-1); //This is the first column : CO

              CfgVariantTable.AddElementLeftTable(CellCO11, thisItem, auto);

              jQuery(row11).addClass('LeftColumnOptions');

              // var tableRef = document.getElementById('tableD').getElementsByTagName('tbody')[0];
              var row1 = document.getElementById('tableD').getElementsByTagName('tbody')[0].insertRow(i + 1);

              CfgVariantTable.UpdateDataRows(tableH, tableD, row1);

              //Disable Option in autocomplete
              auto.disableItem(thisItem.value);

            } else {

              //Parent Feature not instanciated
              var row01 = tableL.insertRow(-1);
              var CellCF01 = row01.insertCell(-1); //This is the first column : CF

              CfgVariantTable.AddElementLeftTable(CellCF01, ParentItem, auto);

              CellCF01.rowSpan = 2;
              jQuery(row01).addClass('LeftColumnFeatures');

              var row11 = tableL.insertRow(-1);
              var CellCO11 = row11.insertCell(-1); //This is the first column : CO

              CfgVariantTable.AddElementLeftTable(CellCO11, thisItem, auto);

              jQuery(row11).addClass('LeftColumnOptions');

              var row = tableD.insertRow(-1);
              jQuery(row).addClass('LeftColumnFeatures');

              // var tableRef = document.getElementById('tableD').getElementsByTagName('tbody')[0];
              var row1 = document.getElementById('tableD').getElementsByTagName('tbody')[0].insertRow(-1);

              //Treatment to to on the option's parent feature
              if (auto.isSelected(auto.getId(), ParentItem) == false) {
                // auto.onSelect(ParentItem);
              }
              CfgVariantTable.UpdateDataRows(tableH, tableD, row1);

              //Disable Option in autocomplete
              auto.disableItem(thisItem.value);
            }
          }

          //Check whether the option is last remaining to be selected, if so, we select the parent option
          var isLast = true;
          if (auto.isSelected(auto.getId(), ParentItem) == false) {
            //Select the options in the autocomplete component
            for (var key = 0; key <= (hierarchicalDataset.items.length - 1); key++) {
              if (hierarchicalDataset.items[key].value == ParentItem.value && hierarchicalDataset.items[key].label == ParentItem.label) {
                for (var subkey = 0; subkey <= (hierarchicalDataset.items[key].items.length - 1); subkey++) {

                  //Treatment to do on SubElements (Options) of a Config Feature 
                  var item = CfgVariantTable.getAutoItem(auto,hierarchicalDataset.items[key].items[subkey]);
                  if (item.disabled == false) {
                    isLast = false;
                  }

                }
              }
            }
            if (isLast == true) {                 
              auto.disableItem(ParentItem.value);
            }
          }


        }
        //Add a first Combination
        if (document.getElementById('tableH').rows[0].cells.length == 0) {
          CfgVariantTable.AddColumn(tableH, tableD, tableL);
        }
        CfgVariantTable.AddZebraEffect(tableD);

      }
	   CfgVariantTable.EmptyCheck();
    };

    //Function to run once unselecting an element
    CfgVariantTable.onUnSelectElement = function(item, auto) {
      var ind = 0;
      var that = auto; //This is the autocomplete component

      jQuery(tableL).find('tr').each(function() {
        var trow = jQuery(this);
        var x = parseInt(trow.children('td:not(:empty)').first().attr('rowspan'));


        if (x > 0) { //If we unselect a Config Feature
          if (trow.text() == item.label) {
            ind = trow.index();
            var ArrayMembers = [];

            //Enable all options of feature
            for (var key = 0; key <= (hierarchicalDataset.items.length - 1); key++) {
              if (hierarchicalDataset.items[key].value == item.value && hierarchicalDataset.items[key].label == item.label) {
                for (var subkey = 0; subkey <= (hierarchicalDataset.items[key].items.length - 1); subkey++) {                 
                  ArrayMembers.push(hierarchicalDataset.items[key].items[subkey]);
                  var item1 = CfgVariantTable.getAutoItem(that,hierarchicalDataset.items[key].items[subkey]);
                  if (item1.disabled == true) {
                    that.enableItem(item1.value);
                  }

                }
                //Delete All Config Options from Combination
                for (var i = 0; i < ArrayMembers.length; i++) {
                  // console.log('ArrayMembers[i]'+ArrayMembers[i]);
                  CfgVariantExpServices.UpdateCombinationsIfUnselected(ArrayMembers[i]);
				  CfgVariantTable.DisplayEffectivityExpression();
                }
              } //if value == CF
            } //End For

            for (var i = 1; i <= x; i++) {
              tableL.deleteRow(ind);
              tableD.deleteRow(ind);

            }
          }

          //enable Feature in autocomplete
          that.enableItem(item.value);

        } else { // if we Unselect a Config Option
          CfgVariantExpServices.UpdateCombinationsIfUnselected(item);
		  CfgVariantTable.DisplayEffectivityExpression();
          if (trow.text() == item.label) {
            ind = trow.index();
            var i = ind;
            var trouve = false;

            var NbRowspanNextCurrent = parseInt(jQuery(tableL).find('tr:eq(' + (i + 1) + ')').children('td:first-child').attr('rowspan'));

            while ((trouve == false) && (i >= 0)) {
              var x = parseInt(jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child').attr('rowspan'));
              var x1 = jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child');
              if (x > 0) {
                //Décrémenter le rowspan
                jQuery(tableL).find('tr:eq(' + i + ')').children('td:first-child').attr('rowspan', x - 1);
                trouve = true;
              } else {
                i--;
              }
            }

            if ((i + 1) == ind) { //if CO is just after the parent CF
              if (NbRowspanNextCurrent > 0) { //if CO is just after the parent CF and it is the only child
                tableL.deleteRow(ind);
                tableL.deleteRow(i);

                tableD.deleteRow(ind);

                //Unselect Parent Feature (for autocomplete Multi select mode only)


              } else {
                if (ind == (jQuery('#tableL tr').length) - 1) { //Si la CO est la derniere dans la table
                  tableL.deleteRow(ind);
                  tableL.deleteRow(i);

                  tableD.deleteRow(ind);
                  tableD.deleteRow(i);
                  //On deselectionne le pere de l'autocomplete component


                } else {
                  tableL.deleteRow(ind);
                  // tableD.deleteRow(ind);
                }

              }
            } else //Normale CO unselecting case
              tableL.deleteRow(ind);
            tableD.deleteRow(ind);

          }
          CfgVariantTable.AddZebraEffect(tableD);

          //enable option and feature
          that.enableItem(item.value);
          var ParentItem = that.getItem(item.parentItemId);
          if (ParentItem.disabled == true) {
            that.enableItem(ParentItem.value);
          }

        }

      });

      //If no elements are selected, we clear the table
      if (jQuery('#tableL tr').length == 0) {
        CfgVariantTable.ClearTable(auto);
      }

		CfgVariantTable.EmptyCheck();
    };
    return CfgVariantTable;
  });
