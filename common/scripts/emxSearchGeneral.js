//=================================================================
// JavaScript Methods for emxSearchGeneral.jsp
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================

    var showAdvanced        = getTopWindow().pageControl.getShowingAdvanced();
    var showingAdvanced     = showAdvanced;
    var typeChanged         = !showAdvanced;

    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIForm");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIMenu");

    function doSearch(){
        //get the form
        var theForm = document.forms[0];

        //set form target
        //theForm.target = "searchView";

        // If the page needs to do some pre-processing before displaying the results
        // Use the "searchHidden" frame for target
        theForm.target = "searchHidden";

        //validate()??
        if(validateForm(document.forms[0])){
            theForm.action = "emxSearchGeneralSavePreprocess.jsp";//"emxTable.jsp";
            theForm.submit();
        }

    }

    function validateForm(form){
        if(form && form.txtTypeDisplay.value == ""){
            alert(getTopWindow().STR_SEARCH_SELECT_TYPE);
            turnOffProgress();
            return false;
        }

        if(form && form.vaultSelction[2].checked == true)
        {
           if(form.vaultsDisplay.value == "")
           {
              alert(getTopWindow().STR_SEARCH_SELECT_VAULT);
              turnOffProgress();
              return false;
           }
           form.vaultSelction[2].value = form.vaults.value;
        }

        return true;
    }

    function doSubmit(){
        //find footer
        var footer = findFrame(getTopWindow(),"searchFoot");
        //call doFind Method
        footer.doFind();
    }
    
    // modified for Consolidated Search

    function clearType(){
       //if div is closed clear it
        if(getTopWindow().pageControl.getShowingAdvanced()){        
        	  toggleMore();             
        }
        
        document.forms[0].txtTypeDisplay.value='';
        document.forms[0].txtTypeActual.value='';
        
         if (getTopWindow().pageControl && getTopWindow().pageControl.getType()){                    
            getTopWindow().pageControl.setType(null);                    
        }  
    }
    
    // ended for Consolidated Search

    function clearContainedIn(){
        document.forms[0].txtContainedIn.value='';
        document.forms[0].txtActualContainedIn.value='';
		closeDiv();
    }

    function clearVault(){
        document.forms[0].vaultsDisplay.value='';
        document.forms[0].vaults.value='';
    }

    function disableRevision(){
        if(document.forms[0].latestRevision.checked) {
                document.forms[0].txtRev.value = "*";
                document.forms[0].txtRev.disabled = true;
        } else {
                document.forms[0].txtRev.disabled = false;
        }
    }


    function doLoad() {
        if (document.forms[0].elements.length > 0) {
            var objElement = document.forms[0].elements[0];

            if (objElement.focus) objElement.focus();
            if (objElement.select) objElement.select();
        }
        var type = getTopWindow().pageControl.getType();
        type = (type == null)? document.getElementById("txtTypeActual").value : type;
        getTopWindow().pageControl.setType(type);
        if(showAdvanced){
            typeChanged = true;
            toggleMore();
        }
		//Attach event handler for image tag, when clicked on it shows the contained in info.
		var imgTag = document.getElementById("imgTag");
		if(imgTag!=null && imgTag!="undefined")
		{
			imgTag.addEventListener("click",getContainedInInfo,false);
		}
    }

    function updateType(){
        var emxType = arguments[0];

        //if emxType == null get emyType from form
        if((typeof emxType) == "undefined"){
            emxType = document.getElementById("txtTypeActual").value;
        }

        if (getTopWindow().pageControl && emxType != getTopWindow().pageControl.getType()){
            typeChanged = true;
            document.getElementById("txtTypeActual").value = emxType;
            getTopWindow().pageControl.setType(emxType);
            if (getTopWindow().pageControl.getShowingAdvanced() == false){
                return;
            }else{
                var objDiv = document.getElementById("divMore");
                if(getTopWindow().getAdvancedSearch(typeChanged,objDiv)){
                    typeChanged = false;
                }
            }
        }
    }

    function toggleMore() {

            var objDiv = document.getElementById("divMore");
            if(getTopWindow().getAdvancedSearch(typeChanged,objDiv)){

                var imgMore = document.getElementById("imgMore");
                var theForm = document.forms[0];

                objDiv.style.display = (objDiv.style.display == "none" ? "" : "none");
                imgMore.src = (objDiv.style.display == "none" ? "../common/images/utilSearchPlus.gif" : "../common/images/utilSearchMinus.gif");
                getTopWindow().pageControl.setShowingAdvanced(objDiv.style.display == "none" ? false : true);
                //if div is closed clear it
                if(!getTopWindow().pageControl.getShowingAdvanced()){
                    removeFormElements();
                    objDiv.innerHTML = "";
                }
            }
    }

    function removeFormElements(){
        var theForm = document.forms[0];
        var formLen = theForm.elements.length;

        for(var i = formLen-1; i >=0 ; i--){
            var objParent = theForm.elements[i].parentNode;


            //alert("element name: " + theForm.elements[i].nodeName +
            //        "\nparentNode: " + objParent.nodeName);

            isDivMore(theForm.elements[i]);
            if(isInDivMore){
                objParent.removeChild(objParent.childNodes[0]);
                isInDivMore = false;
            }
        }
       return theForm;
    }

    var isInDivMore = false;
    function isDivMore(o){
        if(o.parentNode != null){
            if(o.parentNode && o.parentNode.id == "divMore"){
                isInDivMore = true;
                return;
            }
            isDivMore(o.parentNode);
        }
    }

    function setSelectedVaultOption(vaultChooserURL){
        document.SearchForm.vaultSelction[2].checked=true;
        showChooser(vaultChooserURL);
    }

	function getContainedInInfo()
	{
		closeDiv();
		var containedObjId = document.forms[0].txtActualContainedIn.value;
		var containedInType = document.forms[0].txtContainedInType.value;
		var containedInRev = document.forms[0].txtContainedInRev.value;
		var containedInName = document.forms[0].txtContainedIn.value;
		var objEvent = emxUICore.getEvent();
		if(containedObjId!='')
		{
			var sURL = "../common/emxSearchGetContainedInObjectInfo.jsp?objectId="+containedObjId+"&type="+containedInType+"&name="+containedInName+"&revision="+containedInRev;
			var oXMLHTTP = emxUICore.createHttpRequest();
			oXMLHTTP.open("GET", sURL, false);
			oXMLHTTP.send(null);
			floatingDiv = document.createElement("div");
            

			floatingDiv.name="floatingdiv";
			floatingDiv.id="floatingdiv";
			floatingDiv.style.position="absolute";
			floatingDiv.style.zIndex=5;
			document.forms[0].appendChild(floatingDiv);
            

			window.focus();
			floatingDiv.style.display = "block";
			floatingDiv.focus();
			
			
			var floatDivInnerHTML = floatingDiv.innerHTML;
			floatDivInnerHTML +=oXMLHTTP.responseText ;
			floatingDiv.innerHTML=floatDivInnerHTML;
			var floatingDivWidth = "";
			if(isIE)
			{
				floatingDivWidth = floatingDiv.firstChild.offsetWidth;
			}
			else
			{
				floatingDivWidth = floatingDiv.offsetWidth;
				
			}
			floatingDiv.setAttribute("width", floatingDivWidth);
			if(!isIE)
			{
				var divFormLayerBorder = document.getElementById("formLayerBorder");
				var tblHeader = document.getElementById("tblHeader");
				if(parseInt(divFormLayerBorder.offsetWidth) < parseInt(tblHeader.offsetWidth))
				{
					divFormLayerBorder.style.width = tblHeader.offsetWidth+50+"px";
				}
				floatingDivWidth = tblHeader.offsetWidth +20;
		    }
			
			setDivPosition(objEvent, floatingDiv,floatingDivWidth);
		}
		else
		{
			alert(emxUIConstants.STR_SEARCH_CONTAINEDIN_EMPTY);
		}
	}
	function closeDiv()
	{
            if(floatingDiv!=null)
		    {
				floatingDiv.innerHTML ="";
				floatingDiv.style.display="none";
				floatingDiv = null;
			}
		
	}
	function setDivPosition(objEvent, floatingDiv,floatingDivWidth,floatingDivHeight) 
	{
		intX = objEvent.clientX
		intY = objEvent.clientY

		//add offset to each coordinate
		intX += 15 + document.body.scrollLeft;
		intY += 15 + document.body.scrollTop;

		//make sure that all of the tooltip is visible
		if ((intX + floatingDivWidth) > (document.body.clientWidth + document.body.scrollLeft)) {

			//move it so that the right edge of the div lines up with the right edge of the window
			intX = (document.body.clientWidth + document.body.scrollLeft) - floatingDivWidth - 5;
		}

		var intWindowHeight = document.body.clientHeight || window.innerHeight;

		//make sure that all of the tooltip is visible
		if ((intY + 100) > (intWindowHeight + document.body.scrollTop)) {

			//move it so that the bottom edge of the div lines up with bottom edge of the window
			intY = (document.body.clientHeight + document.body.scrollTop) - 100;

		}
		intY = intY-40;
		floatingDiv.style.top = intY;
		floatingDiv.style.left=  intX;

};
// To display the dynamic text area when entering the name field in general search page

    function displayDynamicTextarea(element)
    {
        var textboxValueArray = new Array();
        var textboxArrayValueList = "";
        var textAreaelementsize = "";
        elementName = element.getAttribute("name");
        //textareaName="dynamicTextarea"+count;
        var fVer = parseFloat(RegExp["$1"]);
        if (document.forms[0].elements["dynamicTextarea"]!= null||document.forms[0].elements["dynamicTextarea"]!= "undefined")
        {
         	if ((isIE) && (fVer<7))
         	{
    		    document.forms[0].elements[elementName].className = "flipperIEEdit";
            }
            else 
            {
    		    document.forms[0].elements[elementName].className = "flipperMozEdit";
            }
        } 
        var divElementName = element.parentNode.lastChild.name;
  	    var elementSize = element.getAttribute("size");
  	    textAreaelementsize = elementSize-2;  
  	    var rowSize = "";
		//checking the browser whether it is IE or Mozilla
        if(isIE) 
        {
            rowSize = 4;
        }
        else
        {
            rowSize = 3;
            textAreaelementsize = elementSize - 5;
        }      
       
        if(divElementName != "divname")
        {
            objTextarea = document.createElement("div");
            objTextarea.setAttribute("name","divname");
            objTextarea.setAttribute("id","divid");
            var textBoxValue = element.value;
            objTextarea.style.margin = '-3px 0px';
            textboxValueArray = textBoxValue.split(","); 
            
            if(textboxValueArray != "*")
            {
	            textboxArrayValueList = textboxValueArray.join("\n");
	        }
            element.value = "";
            textarea = "<textarea name=\"dynamicTextarea\" cols=\""+textAreaelementsize+"\" rows=\""+rowSize+"\" onBlur='javascript:hideDynamicSetText(this)'>"+textboxArrayValueList+"</textarea>";
            objTextarea.innerHTML = textarea;
            Xpos = emxUICore.getActualLeft(element);
            Ypos = emxUICore.getActualTop(element);
            Ypos += 24;
            objTextarea.style.position = "absolute";
            emxUICore.moveTo(objTextarea,Xpos,Ypos);
            document.forms[0].appendChild(objTextarea);
            document.forms[0].elements["dynamicTextarea"].focus();
        }
    }//end function
  
   //To hide the dynamic textarea and populate the values in textbox
    function hideDynamicSetText(textareaElement)
    {
        var value = textareaElement.value;
        document.forms[0].elements[elementName].value = formatForDisplay(value);
        var divElement = document.getElementById("divid");
        divElement.innerHTML = "";   
        document.forms[0].removeChild(divElement);

        if(document.forms[0].elements["dynamicTextarea"] == null||document.forms[0].elements["dynamicTextarea"] == "undefined")
        {
            if((isIE) && (fVer<7))
            {
                document.forms[0].elements[elementName].className = "flipperIEView";
            }
            else
            {
                document.forms[0].elements[elementName].className =  "flipperMozView";
            }
       }
    }//end function
  
  
//method to set the format to display in the textbox
    function formatForDisplay(value)
    {
        var valueArray = new Array();
        var stringValue = "";
        var textBoxValue = "";
        valueArray = value.split('\n');
        textBoxValue = valueArray;
        return textBoxValue; 
    }//end function
    
