//=================================================================
// JavaScript DOM Type Chooser
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================

function emxUITypeChooser(blnAbstractSelect, blnMultiSelect, blnShowIcons, blnObserveHidden) {
    this.className = "emxUITypeChooser";
    this.container = null;
    this.doms = new Array;
    this.types = new Array;
    this.notTypes = new Array;
    this.abstractSelect = blnAbstractSelect;
    this.multiSelect = blnMultiSelect;
    this.showIcons = blnShowIcons;
    this.observeHidden = blnObserveHidden;
    this.allLevelsLoaded = false;
    this.fullTreeGenerated = false;
}

emxUITypeChooser.XSL_TREE = emxUIConstants.DIR_COMMON + "emxUITypeChooserTree.xsl";
emxUITypeChooser.XSL_TYPE = emxUIConstants.DIR_COMMON + "emxUITypeChooserType.xsl";
emxUITypeChooser.XSL_TYPE_CHILDREN = emxUIConstants.DIR_COMMON + "emxUITypeChooserTypeChildren.xsl";
emxUITypeChooser.XML_ALL_LEVELS = emxUIConstants.DIR_COMMON + "emxTypeChooserLoadAllLevels.jsp";
emxUITypeChooser.XML_TOP_LEVEL_ONLY = emxUIConstants.DIR_COMMON + "emxTypeChooserLoadFirstLevel.jsp";
emxUITypeChooser.XML_TYPE = emxUIConstants.DIR_COMMON + "emxTypeChooserLoadType.jsp";
emxUITypeChooser.URL_COUNT_TYPES = emxUIConstants.DIR_COMMON + "emxTypeChooserCountTypes.jsp";

emxUITypeChooser.prototype.addType = function _emxUITypeChooser_addType(strType) {
        this.types[this.types.length] = strType;
};

emxUITypeChooser.prototype.addNotType = function _emxUITypeChooser_addType(strType) {
        this.notTypes[this.notTypes.length] = strType;
};

emxUITypeChooser.prototype.addURLParams = function (strURL) {
    return strURL + "?abstractSelect=" + this.abstractSelect + "&multiSelect=" + this.multiSelect + "&showIcons=" + this.showIcons + "&ObserveHidden=" + this.observeHidden;
};



emxUITypeChooser.prototype.applyFilter = function() {

        this.setBusy(true);
        var objThis = this;
        
        this.container.innerHTML = emxUIConstants.HTML_LOADING;
        
        setTimeout(function () {
                var objRE = objThis.createExpression(objThis.selFilter.selectedIndex, objThis.txtFilter.value, objThis.isCaseSensitive.value);
                var objCurrent = objThis.doms["current"];
                var intNodes = 0;
                
                if (objThis.chkTopLevelOnly.checked) {
                        objThis.doms["current"] = objThis.generateFilteredDOM(objThis.doms["original"], objRE);
                } else {                    
                
                    if (!objThis.doms["full"]) {
                    
                        intNodes = parseInt(emxUICore.getDataPost(objThis.addURLParams(emxUITypeChooser.URL_COUNT_TYPES), objThis.getURLData().toString()));
                        
                        if (intNodes > emxUIConstants.TYPE_CHOOSER_MAX && objThis.txtFilter.value == "*") {
                            alert(emxUIConstants.ERR_TOO_MANY_TYPES);
                            objThis.doms["current"] = objCurrent;
                        } else {
                            objThis.doms["full"] =  emxUICore.getXMLDataPost(objThis.addURLParams(emxUITypeChooser.XML_ALL_LEVELS), objThis.getURLData().toString()+"&notTypes="+ objThis.notTypes.join(','));
                            objThis.sortDOM(objThis.doms["full"]);
                         }
                    }

                    if (objThis.doms["full"]) {

                        objThis.doms["current"] = objThis.generateFilteredDOM(objThis.doms["full"], objRE);
                        
                        //get the number of types
                        var intTypes = emxUICore.getElementsByTagName(objThis.doms["current"], "aef:type").length;
                    
                        if (intTypes > emxUIConstants.TYPE_CHOOSER_MAX) {
                            alert(emxUIConstants.ERR_TOO_MANY_TYPES);
                            objThis.doms["current"] = objCurrent;
                        }                                  
                    }   

                }

                objThis.displayTree();
        
                objThis.setBusy(false);
        }, 100);
};

emxUITypeChooser.prototype.init = function _emxUITypeChooser_init() {

        this.chkTopLevelOnly = document.getElementById("chkTopLevelOnly");
        this.txtFilter = document.getElementById("txtFilter");
        this.btnFilter = document.getElementById("btnFilter");
        this.selFilter = document.getElementById("selFilter");
        this.isCaseSensitive = document.getElementById("hiddenCaseSensitive");
        
        this.screen = document.getElementById("divScreen");
        
        this.loadDefinition();        

};

emxUITypeChooser.prototype.setBusy = function (blnBusy) {
        if (blnBusy) {                
                this.btnFilter.disabled = true;
                this.txtFilter.disabled = true;
                this.selFilter.disabled = true;
                this.chkTopLevelOnly.disabled = true;
                this.screen.style.visibility = "visible";
                turnOnProgress();
        } else {
                this.btnFilter.disabled = false;
                this.txtFilter.disabled = false;
                this.selFilter.disabled = false;
                this.chkTopLevelOnly.disabled = false;
                this.screen.style.visibility = "hidden";
                turnOffProgress();
        }
};

/**
 * Creates the URL parameters necessary to load the initial data from the database.
 * @return A string of URL parameters.
 */
emxUITypeChooser.prototype.getURLData = function () {

        try {
                var objBuf = new emxUIStringBuffer();
                
                objBuf.write("numTypes=");
                objBuf.write(this.types.length);
                
                for (var i=0; i < this.types.length; i++) {
                        objBuf.write("&type");
                        objBuf.write(i);
                        objBuf.write("=");
                        objBuf.write(encodeURI(this.types[i]));
                }
        
                return objBuf.toString();
        } catch (objError) {
                alert(emxUIConstants.STR_JS_AnErrorOWEDTBSTTS);
        }
};

/**
 * Displays the current tree by transforming the XML DOM using XSLT
 * and inserting it into the container.
 */
emxUITypeChooser.prototype.displayTree = function () {
        this.container.innerHTML = "<form onSubmit='javascript:doDone();return false;'>" + emxUICore.transformToText(this.doms["current"], this.doms["xsl-tree"]) + "</form>";
};

/**
 * Loads the type chooser XML definition.
 */
emxUITypeChooser.prototype.loadDefinition = function () {

    var strURL = this.addURLParams(emxUITypeChooser.XML_TOP_LEVEL_ONLY);


    try {
        var objThis = this;
        objThis.setBusy(true);
                             
        setTimeout(function () {       
    		strURL = strURL + "&notTypes="+ objThis.notTypes.join(',');
            objThis.doms["original"] = emxUICore.getXMLDataPost(strURL, objThis.getURLData().toString());
            objThis.sortDOM(objThis.doms["original"]);
            objThis.doms["xsl-tree"] = emxUICore.GetXSLRemote(emxUITypeChooser.XSL_TREE);                
            objThis.doms["xsl-type"] = emxUICore.GetXSLRemote(emxUITypeChooser.XSL_TYPE);                
            objThis.doms["xsl-type-children"] = emxUICore.GetXSLRemote(emxUITypeChooser.XSL_TYPE_CHILDREN);                
            objThis.applyFilter();     
            objThis.setBusy(false); 
        }, 100);
    } catch (objError) {
        alert(emxUIConstants.STR_JS_AnErrorOWTTLTD);        
    }
        
};



emxUITypeChooser.prototype.setContainer = function _emxUITypeChooser_setContainer(objDOMParent) {
        this.container = objDOMParent;
};




emxUITypeChooser.prototype.generateFullTree = function (objXML) {
        
        var objNewXML = emxUICore.createXMLDOM();
        var objRoot = emxUICore.getElementsByTagName(objXML, "aef:root")[0];
        var objRootLabel =emxUICore.getElementsByTagName(objRoot, "aef:label")[0].cloneNode(true);
        var objNewRoot = objRoot.cloneNode(false);
        var arrTypes = emxUICore.getElementsByTagName(objXML, "aef:type");

        objNewXML.appendChild(objXML.documentElement.cloneNode(false));
        objNewXML.documentElement.appendChild(objNewRoot);
        objNewRoot.appendChild(objRootLabel.cloneNode(true));
        
        for (var i=0; i < arrTypes.length; i++) {
                objNewXML.documentElement.childNodes[0].appendChild(arrTypes[i].cloneNode(true));
        }
        
        this.sortDOM(objNewXML);

        return objNewXML;
        
};


/**
 * Handles expanding/collapsing of subtrees. If the node's children
 * haven't been loaded yet, it loads them.
 * @param strID The unique ID to locate the HTML elements for this type.
 * @param strTypeName The type that is being expanded/collapsed.
 */
emxUITypeChooser.prototype.toggleExpand = function (strID, strTypeName, notTypes) {

        var objDivA = document.getElementById("div" + strID + "A");
        var objDivB = document.getElementById("div" + strID + "B");
        var objTD = document.getElementById("td" + strID);
        var objImg = objTD.getElementsByTagName("img")[0];
		if(isChrome || isEdge){
			 var currDivId = "#"+"div" + strID + "B";
			 this.hasSiblings = false;
			 var level = jQuery(currDivId).parentsUntil("#divRootB").length;
				if(jQuery(currDivId).nextAll().length > 0){
					this.hasSiblings = true;
				}
		}
	

        if (objDivB.childNodes.length > 1 || (isMoz && objDivB.firstChild.tagName.indexOf("RESULT") > -1)) {
			
                if (objDivB.style.display == "none") {
                        objDivB.style.display = "inline";
                        objImg.src = objImg.src.replace("Closed", "Open");
                } else {
                        objDivB.style.display = "none";
                        objImg.src = objImg.src.replace("Open", "Closed");
                }
        } else {


		var objThis = this;
	 
		if (objThis.addTypeToDOM(strTypeName, objThis.doms["current"], notTypes)) {
            this.setBusy(true);
			
            
            if (objDivB.style.display == "none") {
                objDivB.style.display = "inline";
                objImg.src = objImg.src.replace("Closed", "Open");
            } else {
                objDivB.style.display = "none";
                objImg.src = objImg.src.replace("Open", "Closed");
            }
            
       
        
            setTimeout(function () {
  
                    //check to see if the type has to be loaded
                 
                        if (objThis.doms["full"]) {
							
                            objThis.addTypeToDOM(strTypeName, objThis.doms["full"]);
                        }
                        
                        objThis.addTypeToDOM(strTypeName, objThis.doms["original"], notTypes);
                                        
                        var objNewNode = emxUICore.selectSingleNode(objThis.doms["current"].documentElement, "//aef:type[@name='" + strTypeName + "']");
						if(isChrome || isEdge){
							var siblingsLevels = "";
							var ancestorNodes = emxUICore.selectNodes(objNewNode,"ancestor::node()[not(name() = 'aef:root') and not(name() = 'aef:typechooser') and not(name() = '')]");
							for(var i=1; i<ancestorNodes.length; i++){
								if(ancestorNodes[i].attributes["hasSiblings"].value == "true"){
									siblingsLevels = siblingsLevels.concat(String(ancestorNodes[i].attributes["currentLevel"].value));
								}
							}
							if(true == objThis.hasSiblings){ 
								siblingsLevels = siblingsLevels.concat(String(level));
							}
							objNewNode.setAttribute("siblingsLevels",siblingsLevels);
                      		objNewNode.setAttribute("currentLevel",(level)); 
							objNewNode.setAttribute("hasSiblings",objThis.hasSiblings); 
						}else{
							objNewNode.setAttribute("browserSpecific","IE");
						}
                        objDivB.innerHTML = emxUICore.transformToText(objNewNode, objThis.doms["xsl-type-children"]);
                        
                        var childNodesXML = emxUICore.createXMLDOM();            
        				childNodesXML.loadXML(objNewNode.xml);
        				childNodes = emxUICore.selectNodes(childNodesXML.documentElement, "//aef:type");
        				if(childNodes.length == 1){
        					objDivB.lastChild.style.display = "none";
        				}
                    
                    objThis.setBusy(false);
					
            }, 500);
			}
		else{
			  objThis.setBusy(false);
		}
        
        }
};

/**
 * Adds an individual type into the given XML DOM.
 * @param strTypeName The name of type to add.
 * @param objDOM The DOM to add into.
 */
emxUITypeChooser.prototype.addTypeToDOM = function (strTypeName, objDOM, notTypes) {


    var arrNodes = emxUICore.selectNodes(objDOM.documentElement, "//aef:type[@name='" + strTypeName + "']");
    
    //check to see if the next level of nodes needs to be loaded.
    if (arrNodes.length > 0 && arrNodes[0].getAttribute("haschildren") == "true" && emxUICore.getElementsByTagName(arrNodes[0], "aef:type").length == 0) {
        
        var objNewDOM = null;
        
        if (this.doms["type_" + strTypeName]) {
            objNewDOM = this.duplicateDOM(this.doms["type_" + strTypeName]);
        } else {
            objNewDOM =  emxUICore.getXMLData(this.addURLParams(emxUITypeChooser.XML_TYPE) + "&type=" + strTypeName + "&notTypes=" + notTypes);
            this.doms["type_" + strTypeName] = this.duplicateDOM(objNewDOM);
        }
        
        //add nodes into the original XML document
        var objNewNode = emxUICore.getElementsByTagName(objNewDOM, "aef:type")[0];

        if (isMoz) {
            objNewNode = objDOM.importNode(objNewNode, true);
        }

        if (objNewNode == null) alert(objNewDOM.xml);
        
        arrNodes[0].parentNode.replaceChild(objNewNode, arrNodes[0]);
        this.sortDOM(objNewNode);
        
        //hack to overcome weird IE behavior
        if (isIE) {
            objDOM.loadXML(objDOM.xml);
        }
        
        return true;
    } else {
        return false;
    }

};

/**
 * Sorts the types into alphabetical order.
 * @param objXML The XML DOM to sort.
 */
emxUITypeChooser.prototype.sortDOM = function (objXML) {

        function _sortDOM(objXML) {
                var arrTemp = new Array;
                var arrTypes = emxUICore.selectNodes(objXML, "aef:type");
                
                for (var i=arrTypes.length-1; i >= 0; i--) {
                        _sortDOM(arrTypes[i]);
                        arrTemp.push(arrTypes[i]);                
                }
                
                arrTemp.sort(compareDOMText);
                
                for (var i=0; i < arrTemp.length; i++) {
                        objXML.appendChild(arrTemp[i]);
                }      
        }

        var objStartNode = objXML;
        
        if (objXML.nodeType != 1) {
            objStartNode = emxUICore.getElementsByTagName(objXML, "aef:root")[0];
        }
        
        _sortDOM(objStartNode);
};



/**
 * Creates an exact duplicate of an XML DOM.
 * @param objXML The XML DOM to duplicate.
 * @return An exact duplicate of the XML DOM.
 */
emxUITypeChooser.prototype.duplicateDOM = function (objXML) {
        var objNewXML = emxUICore.createXMLDOM();
        
        for (var i=0; i < objXML.childNodes.length; i++) {
                objNewXML.appendChild(objXML.childNodes[i].cloneNode(true));
        }
        
        return objNewXML;
};



/**
 * Creates a DOM based on the given filter.
 * @param objXML The XML DOM to filter.
 * @param objRE The regular expression to match nodes against.
 * @return A filtered DOM copy.
 */
emxUITypeChooser.prototype.generateFilteredDOM = function (objXML, objRE) {

        var objNewXML = this.duplicateDOM(objXML);
        var objRoot = emxUICore.getElementsByTagName(objNewXML, "aef:root")[0];
        var arrTypes = emxUICore.selectNodes(objRoot, "aef:type");
        
        for (var i=arrTypes.length-1; i >= 0; i--) {
            var objText = emxUICore.getElementsByTagName(arrTypes[i], "aef:text")[0];
                          //aef:text   text node
            if (!objRE.test(objText.childNodes[0].nodeValue)) {
                objRoot.removeChild(arrTypes[i]);
            }
        }
       var remTypes = emxUICore.selectNodes(objRoot, "aef:type");
       for(var j=0; j<remTypes.length; j++) {
        	for(var k=0; k<this.notTypes.length; k++) {
        		if(remTypes[j].getAttribute("name") == this.notTypes[k]){
        			objRoot.removeChild(remTypes[j]);
        		}
        	}
       }
        return objNewXML;
};

/**
 * Creates a regular expression based on the filter text.
 * @param strOpt The selected option index in the dropdown.
 * @param strFilter The filter text.
 * @return A regular expression matching the filter text.
 */
emxUITypeChooser.prototype.createExpression = function (strOpt, strFilter, isCaseSensitive) {
            
        strFilter = (strFilter.length > 0) ? strFilter : "*";

        strFilter = strFilter.replace(/^\s*/g, "");
        strFilter =  strFilter.replace(/\s+$/g, "");            
        
        strFilter = strFilter.replace(/([\.\$\^\[\]\(\)\{\}\+\-\?\|\\])/g, "\\ $1");
        strFilter = strFilter.replace(/(\\)\s([\.\$\^\[\]\(\)\{\}\+\-\?\|\\])/g, "$1$2");

        switch(strOpt){
                case 0:
                        strFilter += "*";
                        break;
                case 1:
                        strFilter = "*" + strFilter;
                        break;
                case 2:
                        strFilter = "*" + strFilter + "*";
                        break;
        }
        
        strFilter = "^" + strFilter.replace(/\*/g, ".*") + "$";
        strFilter = strFilter.replace(/\.\*\.\*/g, ".*");

        return (isCaseSensitive.toLowerCase() == "true") ? new RegExp(strFilter) : new RegExp(strFilter, "i");
};

/**
 * Returns the value of the selected item(s) in
 * the type chooser.
 * @return A string indicated the selected items.
 */
emxUITypeChooser.prototype.getValue = function () {

        var arrInputs = this.container.getElementsByTagName("input");
        var arrTemp = new Array;
        
        for (var i=0; i < arrInputs.length; i++) {
                if (arrInputs[i].name=="radType"){
                        if (arrInputs[i].checked) {
                                return arrInputs[i].value;
                        }
                } else if (arrInputs[i].checked) {
                        arrTemp.push(arrInputs[i].value);                
                }
        }
        
        return arrTemp.toString();

};

function compareDOMText(objA, objB) {

        var strA = emxUICore.getElementsByTagName(objA, "aef:text")[0].childNodes[0].nodeValue;
        var strB = emxUICore.getElementsByTagName(objB, "aef:text")[0].childNodes[0].nodeValue;
        
        if (strA < strB) {
                return -1;
        } else if (strA > strB){
                return 1;
        } else {
                return 0;
        }

}
