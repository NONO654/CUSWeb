<%--  emxDataSpecializationValidation.jsp
   Copyright (c) 1999-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
 --%>
 
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttrInfos"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.ontology_itfs.OntoException"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
                 
<%@page import = "java.util.Arrays"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.ArrayList"%>
 <%

String postProcessURL = emxGetParameter(request, "postProcessURL");
String form = emxGetParameter(request, "form");
String attributeId = emxGetParameter(request, "objectId");

//NLS Messages 
String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");
String defaultValNLSNotReal = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotReal","Default Value");
String rangeNLSNotReal = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotReal","One of authorized values");
String defaultValNLSNotInt = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotInteger","Default Value");
String rangeNLSNotInt = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotInteger","One of authorized values");
String defValueMaxLengthExceeded = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DefaultValueExceedMaxLength");
String rangeMaxLengthExceeded = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.RangeValueExceedMaxLength");
String defValueNotOneOfRanges = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DefaultValueNotOneOfRanges");
String removeDupRanges = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.RemoveDupRanges");
String nlsPackageExist = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.CheckMsg.PackageAlreadyExist");
String nlsNameNotAlphaNum = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.NotAlphanumericName");
String nlsPackNameNotAlpha = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.NotAlphanumericPackageName");
String nlsPrefixNotAlpha = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.NotAlphanumericNewPrefix");
String realWillBeShortened = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeLongReal");
String maxLengthNotInt= DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.MaxLengthNotInt");
String maxLengthNotGreaterZero= DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.MaxLengthNotGreaterZero");
String maxLengthNotGreaterThanMin = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.MaxLengthNotGreaterThanMin");
String nlsClear = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.Clear");
String nlsErrAlphaNumAuthorizedVal = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.InvalidAuthorizedValue");
String errPrefixFirstChar =  DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.FirstCharPrefix");
String errPrefixLength =  DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.PrefixLength");
String nlsErrUkName = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.InvalidUniquekeyName");
String nlsErrUkAttrSelection = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.SelectAttributeForUK");


String[] nlsMsg=null;
String attrType="";
String attrLength="";
String attrPublishStatus="no";
boolean hasRanges=false;
boolean isMultiValued=false;
if(! "true".equals(nlsTrue)){
	nlsMsg = new String[]{nlsTrue, nlsFalse};
}else {
	nlsMsg = new String[]{"" , ""};
 }
ArrayList<String> listBool = new ArrayList<String>();
for (String s : nlsMsg) {  
	listBool.add(s);  
}
String nlsNotBool = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.AttributeNotBoolean",listBool);

ArrayList<String> dmaKWDPackages = new ArrayList<String>();
//YI3 - postProcessURL is used here to differenciate between the FullEditCustoAttributeForm form and the NewCustoAttributeForm
//if postProcessURL is empty it means that we are in the editForm
IDAuManager manager = DAuManagerAccess.getDAuManager(); 
if (null != manager){
	//check package name existance: 
	if(form.equals("NewCustoPackageForm") || form.equals("NewDeploymentPackageForm")){
		dmaKWDPackages.addAll(manager.getSpecializablePackagesNames(context));
		dmaKWDPackages.addAll(manager.getDeploymentPackagesNames(context));
	}
	if ((null != attributeId) && !attributeId.isEmpty()  && form.equals("FullEditCustoAttributeForm") )//&& postProcessURL.isEmpty()) 
	{
		try{
			//FullEditCustoAttributeForm 
			IDAuAttribute attribute = manager.getAttributeFromId(context, attributeId);
			//	System.out.println("YI3 - emxDataSpecializationValidation - attrName : "+attribute.getName(context));
			if(null!= attribute){
				IDAuAttrInfos attrInfos = attribute.getAttrInfos(context);
				attrType = attrInfos.getType(context);
				attrPublishStatus = attribute.getPublishStatus(context);
				attrLength = attrInfos.getLength(context);
				//BMN2 - 25/03/15 IR-361045
				if(attrLength==null || attrLength.equalsIgnoreCase("0"))
				{
					attrLength="";
				}
				hasRanges = !attrInfos.getRange(context).isEmpty();
				isMultiValued = attrInfos.getMultiValuated(context);
			if(attribute.hasMagnitude(context))
				attrType="Real";
				// System.out.println("YI3 - emxDataSpecializationValidation - attrType : "+attrType);
				%>
			  <script language="javascript">    
				function checkEditDefault()
				{
					var Type="<%=attrType%>";  
					var maxLength="<%=attrLength%>"; 
						  if (Type =="Real") {
							
								var defVal = document.forms['editDataForm'].elements['defaultValue'].value;
								if (isDefaultValueFieldNotEmpty() && ! reg_Double.test(trim(document.forms['editDataForm'].elements['defaultValue'].value)))
								{ 
									alert("<%=defaultValNLSNotReal%>");
									return false;
								}
								if(isDefaultValueFieldNotEmpty())
								{
									document.forms['editDataForm'].elements['defaultValue'].value = checkRealValues(defVal);
								}
								// check that authorizes values are Reals (signed or not)
								if(authorizedValues.length !=0){
									//document.forms['editDataForm'].elements['defaultValue'].value = checkRealValues(defVal);
									for(i=0; i<authorizedValues.length;i++){								
										if (authorizedValues[i] !='' && ! reg_Double.test(authorizedValues[i]))
										{ 
											alert("<%=rangeNLSNotReal%>");
											return false;
										}
									}
								}
							}     
					   else if(Type =="Integer") {
							var defValue = document.forms['editDataForm'].elements['defaultValue'].value;
							//document.forms['editDataForm'].elements['defaultValue'].value = parseInt(defValue);
							//defValue = parseInt(defValue);
							if (isDefaultValueFieldNotEmpty() && ! reg_SInteger.test(parseInt(defValue)))
							{
								alert("<%=defaultValNLSNotInt%>");
								return false;
							}
							if(isDefaultValueFieldNotEmpty())
							{
								document.forms['editDataForm'].elements['defaultValue'].value = parseInt(defValue);
							}
							//checks that authorizes values is an integer (signed or not) .
							if(authorizedValues.length !=0){
								for(i=0; i<authorizedValues.length;i++){
									if (authorizedValues[i] !='' && ! reg_SInteger.test(authorizedValues[i]))
									{ 
										alert("<%=rangeNLSNotInt%>");
										return false;
									}
								}
							}
						}
					   else if (Type =="Boolean") {
						  
								  var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;
								  defvalue = defvalue.toLowerCase();
								  // BMN2 :  11/02/15
								  if (isDefaultValueFieldNotEmpty() && trim(defvalue) != "true"
									  && trim(defvalue) != "false"
										  && trim(defvalue) != (trim("<%=nlsTrue%>")).toLowerCase()
											  && trim(defvalue) != (trim("<%=nlsFalse%>")).toLowerCase() ) {
									  alert("<%=nlsNotBool%>");
									return false;
								  }
						}
						else if (Type =="String") {
									var nodeNewMaxLength =document.forms['editDataForm'].elements['attrLength'];
									if(nodeNewMaxLength){
										var newMaxLength = nodeNewMaxLength.value;
										if(parseInt(newMaxLength)!=parseInt(maxLength)){
											maxLength=newMaxLength;
										}	
									}
								    var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;
									if (isDefaultValueFieldNotEmpty() &&undefined != document.forms['editDataForm'].elements['defaultValue']) {
										var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;
										if (maxLength.length > 0 && defvalue.length>maxLength)
										{	
											alert("<%=defValueMaxLengthExceeded%>");
											return false;
										}
									}
									//checks that authorizes values is an integer (signed or not) .
									if(authorizedValues.length !=0){
										for(i=0; i<authorizedValues.length;i++){
										var range = authorizedValues[i];
											if (range !='' && maxLength.length > 0 && range.length>maxLength)
											{ 
												alert("<%=rangeMaxLengthExceeded%>");
												return false;
											}
										}
									}
						}
					return true;
				}      
			  </script>
			  <%
			}
	  	}catch(Exception e){
			
		}
	}
}

 %>
 
<script LANGUAGE="JavaScript">
var reg_SInteger =  /^[-]?[0-9]+$/; 
var reg_Double = /^[-]?[0-9]+((\.[0-9]+)|(\,[0-9]+))?$/
var published = "<%=attrPublishStatus%>";
var isAttrMultiValued = <%=isMultiValued%>;
var realValueMsgShowen=false;
var packages = [<% for (int i = 0; i < dmaKWDPackages.size(); i++) { %>"<%= dmaKWDPackages.get(i) %>"<%= i + 1 < dmaKWDPackages.size() ? ",":"" %><% } %>];

function checkMagnitude()
{
  alert("Magnitude is choosen");
  return 1;
}
function checkRealValues(value){
	var index = value.indexOf(".")+1;
	var decimalLength = value.substr(index,value.length).length;
	if(decimalLength <= 6){
		if(index==0)
			value += ".000000";
		else
			value += "000000".substr(0, 6-decimalLength);
	}else{ 
		// show the message only once. 
		if(!realValueMsgShowen){
			alert("<%=realWillBeShortened%>");
			realValueMsgShowen=true;
		}
		value = value.substr(0,index+6);
	}
	return value;
}

function validateUnit(obj)
{
	saveFieldObj(obj);
	//document.getElementsByName("defaultValue")[0].value= '0.0';
	if(published=="no"){
		if(undefined !=document.forms['editDataForm'].elements['multiValId']){
			if(document.forms['editDataForm'].elements['multiValId'].value=='false'){
				document.forms['editDataForm'].elements['defaultValue'].value='0.0';
			}else 
				document.forms['editDataForm'].elements['defaultValue'].value='';
		}else 
			document.forms['editDataForm'].elements['defaultValue'].value='0.0';
	}
}

function checkNames(){
	//YI3: check if name is alphanumeric 
	var re = /^[0-9a-zA-Z_]+$/; //This contains A to Z , 0 to 9 and underscores
	var regS = /^[0-9a-zA-Z\s_]+$/; //This contains A to Z , 0 to 9, underscores and spaces 
	// check attribute name
	if(undefined != document.forms['editDataForm'].elements['attrName']) {
		  if (! re.test(trim(document.forms['editDataForm'].elements['attrName'].value)))
		  { alert("<%=nlsNameNotAlphaNum%>");
		  return false;
		  }
	}
	//Check Type Name
	else if(undefined != document.forms['editDataForm'].elements['custoTypeName'] ) {
        if (! re.test(trim(document.forms['editDataForm'].elements['custoTypeName'].value)))
        { alert("<%=nlsNameNotAlphaNum%>");
        return false;
        }
	 }
	//Check Package Name
	else if(undefined != document.forms["editDataForm"]["custoPackageName"] ) {
		var packName = trim(document.forms["editDataForm"]["custoPackageName"].value);

		if (! re.test(packName))
		{	alert("<%=nlsPackNameNotAlpha%>");
			return false;
		}else{
			if(packages.indexOf(packName)!=-1)
			{
				alert("'"+packName+"' "+"<%=nlsPackageExist%>");
				return false;
			}
		}
		// Check New Prefix
		if ((document.forms['editDataForm'].elements['newPrefix'].disabled=="" || 
				document.forms['editDataForm'].elements['newPrefix'].disabled==false)
				&& document.forms['editDataForm'].elements['newPrefix'].value.length<3)
		{ 
			alert("<%=errPrefixLength%>");
		return false;
		}
	 }
	//Check Deployment Extension Name
	else if(undefined != document.forms['editDataForm'].elements['deployExtName'] ) {
	            if (! re.test(trim(document.forms['editDataForm'].elements['deployExtName'].value)))
	            { alert("<%=nlsNameNotAlphaNum%>");
	            return false;
	            }
	   }
	//Check Extension Name 
	else if(undefined != document.forms['editDataForm'].elements['custoExtName'] ) {
        if (! re.test(trim(document.forms['editDataForm'].elements['custoExtName'].value)))
        { alert("<%=nlsNameNotAlphaNum%>");
        return false;
        }
}
	//Check Uniqueness Key Name 
	  else if(undefined != document.forms['editDataForm'].elements['ukName'] ) {
	        if (! re.test(trim(document.forms['editDataForm'].elements['ukName'].value)))
	        { alert("<%=nlsNameNotAlphaNum%>");
	        return false;
	        }
	}
	return true;
}

//List of range Values
var authorizedValues = new Array();	
var Type="<%=attrType%>";  
var hasRangesDef="<%=hasRanges%>"; 

function checkDefaultValue() {
	
	//if("" != document.forms['editDataForm'].elements['defaultValue'].value)
	// check default value if type is boolean (must be true or false)
	if (undefined != document.forms['editDataForm'].elements['attrType1']) {
	
		//check range values 
		if(!isRangeDuplicatedValues())			
			return false;
			
		if (document.forms['editDataForm'].elements['attrType1'].checked && isDefaultValueFieldNotEmpty() ) {
			if (undefined != document.forms['editDataForm'].elements['defaultValue']) {
				var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;
				defvalue = defvalue.toLowerCase();						
				 if (trim(defvalue) != "true"
					 && trim(defvalue) != "false"
						 && trim(defvalue) != (trim("<%=nlsTrue%>")).toLowerCase()
							 && trim(defvalue) != (trim("<%=nlsFalse%>")).toLowerCase() ) {
						alert("<%=nlsNotBool%>");
					return false;
				}
			}
			//	}
		}
		//checks that default value and Ranges are strings that respects the max length
		//and check that the Max Length is an Integer
		else if (document.forms['editDataForm'].elements['attrType2'].checked ) {
			var maxLength = document.forms['editDataForm'].elements['attrLength'].value;
			//check Max Length 
			if (maxLength.length > 0 && ! reg_SInteger.test(trim(maxLength)))
			{	
				alert("<%=maxLengthNotInt%>");
				return false;
			}
			// BMN2-IR-347926 03/02/15
			if(maxLength.length > 0 && maxLength<=0)
			{
				alert("<%=maxLengthNotGreaterZero%>");
				return false;
			}
			if (undefined != document.forms['editDataForm'].elements['defaultValue'] && isDefaultValueFieldNotEmpty() ) {
				var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;
				if (maxLength.length > 0 && defvalue.length>maxLength)
				{	
					alert("<%=defValueMaxLengthExceeded%>");
					return false;
				}
			}
			//checks that authorizes values is an integer (signed or not) .
			if(authorizedValues.length !=0){
				for(i=0; i<authorizedValues.length;i++){
					var range = authorizedValues[i];
					if (maxLength.length > 0 && range.length>maxLength)
					{ 
					alert("<%=rangeMaxLengthExceeded%>");
						return false;
					}
				}
			}
		}
			//checks that default value is an integer (signed or not) .
		else if (document.forms['editDataForm'].elements['attrType0'].checked ) {
			if (undefined != document.forms['editDataForm'].elements['defaultValue'] && isDefaultValueFieldNotEmpty() ) {
				var defValue = document.forms['editDataForm'].elements['defaultValue'].value;
				//document.forms['editDataForm'].elements['defaultValue'].value = parseInt(defValue);
				defValue = parseInt(defValue);
				if (! reg_SInteger.test(defValue))
				{	
					alert("<%=defaultValNLSNotInt%>");
					return false;
				}
				document.forms['editDataForm'].elements['defaultValue'].value = parseInt(defValue);
			}
			//checks that authorizes values is an integer (signed or not) .
			if(authorizedValues.length !=0){
				for(i=0; i<authorizedValues.length;i++){
					if (! reg_SInteger.test(authorizedValues[i]))
					{ 
						alert("<%=rangeNLSNotInt%>");
						return false;
					}
				}
			}
		}
			//checks that default value is Real (signed or not) .
		else if (document.forms['editDataForm'].elements['attrType3'].checked || 
					document.forms['editDataForm'].elements['attrType5'].checked) {
			if (undefined != document.forms['editDataForm'].elements['defaultValue'] && isDefaultValueFieldNotEmpty() ) {
				if (! reg_Double.test(trim(document.forms['editDataForm'].elements['defaultValue'].value)))
				{ 
					alert("<%=defaultValNLSNotReal%>");
					return false;
				}
			}
			// check that authorizes values are Reals (signed or not)
			if(authorizedValues.length !=0){
				// BMN2-IR-347926 03/02/15
				if(undefined != document.forms['editDataForm'].elements['defaultValue'] && isDefaultValueFieldNotEmpty())
					{
					var defVal = document.forms['editDataForm'].elements['defaultValue'].value;
					document.forms['editDataForm'].elements['defaultValue'].value = checkRealValues(defVal);
					}
			
				for(i=0; i<authorizedValues.length;i++){
					if (! reg_Double.test(authorizedValues[i]))
					{ 
						alert("<%=rangeNLSNotReal%>");
						return false;
					}
				}
			}
		}
		var hasEmptyRangeChecked=false;
		if(document.forms['editDataForm'].elements['addEmptyRange']!=null)
		{
			if(document.forms['editDataForm'].elements['addEmptyRange'].disabled==false && document.forms['editDataForm'].elements['addEmptyRange'].checked==true){
				hasEmptyRangeChecked = true;
			}
		}
			//checks that default value is between range values
			// BMN2-IR-347926 03/02/15
		if (authorizedValues.length!=0 && document.forms['editDataForm'].elements['multiValId'].value=='false' && hasEmptyRangeChecked==false) {
			if (undefined != document.forms['editDataForm'].elements['defaultValue'] && isDefaultValueFieldNotEmpty() ) {
				var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;	
				if (authorizedValues.indexOf(trim(defvalue)) == -1)
				{
					alert("<%=defValueNotOneOfRanges%>");					
					return false;
				}
			}else{
					alert("<%=defValueNotOneOfRanges%>");
					return false;
			}
		}
	}
	else{
		//check defaultvalue in the edit form 
		//function checkEditDefault() is genereted by the jsp 
		
		if(!isRangeDuplicatedEditValues())			
			return false;
		// BMN2-IR-347926 10/02/15
		if(!checkEditDefault())			
			  return false;
		
		var hasEditEmptyRangeChecked=false;
		if(document.forms['editDataForm'].elements['addEmptyRange']!=null)
		{
			if(document.forms['editDataForm'].elements['addEmptyRange'].disabled==false && document.forms['editDataForm'].elements['addEmptyRange'].checked==true){
				hasEditEmptyRangeChecked = true;
			}
		}
			//checks that default value is between range values
			// BMN2-IR-347926 03/02/15
		if (authorizedValues.length!=0 && document.forms['editDataForm'].elements['multiValId'].value=='false' && hasEditEmptyRangeChecked==false) {
			if (undefined != document.forms['editDataForm'].elements['defaultValue'] && isDefaultValueFieldNotEmpty() ) {
				var defvalue = document.forms['editDataForm'].elements['defaultValue'].value;	
				if (authorizedValues.indexOf(trim(defvalue)) == -1)
				{ 			
					alert("<%=defValueNotOneOfRanges%>");					
					return false;
				}
			}else{
					alert("<%=defValueNotOneOfRanges%>");					
					return false;
			}
		}
	}
return true;
}

function trim(str)
{
	while(str.substring(0,1)==' ')
	{
		str=str.substring(1,str.length);
	}

	while(str.length > 0 && str.substring(str.length-1,str.length)==' ')
	{
		str=str.substring(0,str.length-1);
	}
	return str;
}

function isDefaultValueFieldNotEmpty(){
	if("" != document.forms['editDataForm'].elements['defaultValue'].value)
		return true; 
	else 
		return false;
}


function isRangeDuplicatedValues()
{
	authorizedValues = new Array();	
	if(Type!="Boolean"){	
		var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
		// BMN2-IR-347926 03/02/15
		var parentDiv= node.parentNode.parentNode; 
		//var trNode= node.parentNode.parentNode.parentNode.parentNode; //<tr> node
		//var table = trNode.parentNode.parentNode
		//node.value='';
		//if range combox selected : 
		var j=0;
		var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
		// BMN2-IR-347926 03/02/15
		var children = parentDiv.childNodes;
		for(i=0; i<parentDiv.childElementCount;i++){
			if(children[i].firstChild){
				node = document.forms['editDataForm'].elements[children[i].firstChild.getAttribute("name")];
			}
			else{
				node =null;
			}
			
			if (node && undefined != node){
				
				//yi3
				if(node.value!=''){
					if((document.forms['editDataForm'].elements['attrType3'] && document.forms['editDataForm'].elements['attrType3'].checked) || 
						(document.forms['editDataForm'].elements['attrType5'] && document.forms['editDataForm'].elements['attrType5'].checked)){
						node.value = (node.value).replace(",",".");
						if(!isNaN(parseFloat(node.value)))
						{
							node.value = parseFloat(node.value);
							node.value= checkRealValues(node.value);
						}
					}
					if((document.forms['editDataForm'].elements['attrType0'] && document.forms['editDataForm'].elements['attrType0'].checked)){
						if(!isNaN(parseInt(node.value)))
						{
							node.value = parseInt(node.value);
						}
					}
					// BMN2-IR-347926 03/02/15
					if(authorizedValues.length !=0 && -1 != authorizedValues.indexOf(node.value)){
						alert("<%=removeDupRanges%>");
						return false;
					}
						authorizedValues[j++]=trim(node.value);
				}
			}  
		}
	}
	return true;
}

function isRangeDuplicatedEditValues()
{
	authorizedValues = new Array();	
	// BMN2-IR-347926 03/02/15
	if(Type!="Boolean"){	
		var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
		var parentDiv= node.parentNode.parentNode; 
		//node.value='';
		//if range combox selected : 
		var j=0;
		var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));	
		var children = parentDiv.childNodes; 
		//alert(parentDiv.childElementCount);
		for(i=0; i<parentDiv.childElementCount;i++){
			//node = document.forms['editDataForm'].elements[nodeId+"_"+i+"_rng"];
			if(children[i].firstChild)
				node = document.forms['editDataForm'].elements[children[i].firstChild.getAttribute("name")];
			else 
				node =null;

			if (node && undefined != node){
				//alert(node.value+" index : "+authorizedValues.indexOf(node.value));
				if(node.value!=''){
					if(Type !='' && Type=="Integer"){
						if(!isNaN(parseInt(node.value)))
							{
								node.value = parseInt(node.value);
							}
						
					}
					// BMN2-IR-347926 03/02/15			
					if(Type !='' && Type=="Real"){
						node.value = (node.value).replace(",",".");
						if(!isNaN(parseFloat(node.value)))
						{
							node.value = parseFloat(node.value);
							node.value= checkRealValues(node.value);
						}
						
					}
					
					if(authorizedValues.length !=0 && -1 != authorizedValues.indexOf(node.value)){
						alert("<%=removeDupRanges%>");
						return false;
					}

					authorizedValues[j++]=trim(node.value);
				}
			}  
		}
	}
	return true;
}

function deleteField(id)
  {
  	//var node = document.getElementById(id);
	var node = document.forms['editDataForm'].elements[id];	
  	var trNode= node.parentNode.parentNode.parentNode; //<tr> node
  	var table = trNode.parentNode.parentNode
  	table.deleteRow(trNode.rowIndex);
  	
  	//Store Order
  	 var order;
  	 if(id.match("rng")){
  		 id = id.substring(0, id.indexOf("_rng")); 	
		 id = id.substring(0, id.indexOf("_"));  	
  	 }
  	 var inputName = id+"_order";
  	 order = document.getElementById(inputName);
  	 if(order){
  	 order.value = "";
  	 var tbody = table.childNodes[0];
  	 for(i=0; i<tbody.childElementCount;i++){
  		 var child = tbody.childNodes[i];
  		 var cName = child.childNodes[0].childNodes[0].name;
  		 if(!cName){
  			 order.value += child.childNodes[0].childNodes[1].name;
  		 }else{
  			 order.value += child.childNodes[0].childNodes[0].name;
  		 }
  		 order.value += ":";
  	 	}
  	 }
  }


  function deleteEditField(id)
  {
	var node = document.forms['editDataForm'].elements[id];
	var div = node.parentNode;
  	var parentDiv= div.parentNode; 
	parentDiv.removeChild(div);
  	
  }
  
  
    function clearField(id)
  {
	var node = document.forms['editDataForm'].elements[id];
	node.value = ''; 
	node = document.forms['editDataForm'].elements[id+"_msvalue"];
  	if (undefined != node)
		node.value='#0';
  }
  
  
  

function addRangeField(id, showClear, showClearText, showAdd, editAttr, dateAttr)
{

	// BMN2-IR-347926 03/02/15
	var node = document.forms['editDataForm'].elements[id];
	var parentDiv= node.parentNode.parentNode; 
	
	if(maxFlag==true){
		maxCount = parentDiv.children.length;
		maxFlag=false;
	}
	var clear="<%=nlsClear%>";
	var useNode = node;
	maxCount++;	
	var newId;
	var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
	if(showAdd){
		newId = id.substring(0, id.length-1)+(maxCount);
	}else{
		if(node.type=="text"){
			newId = nodeId+"_"+(maxCount)+"_rng";
		}else{
			newId = node.name+"_"+(maxCount)+"_rng";			
		}
	}
	
	var newdiv = document.createElement('div');
	newdiv.setAttribute("id","attrRange_html");
	newdiv.setAttribute("name",newId);

	var className = "";
	var divHTML = "<div id=\"attrRange_html\" name=\""+newId+"\">";
	var textHTML = "<input id=\""+newId+"\"type=text name=\""+newId+"\" onChange=\"checkAlphaNum(this)\" class=\""+className+"\"  title=\""+node.title+"\"></input>";
	var textHTMLDisabled = "<input id=\""+newId+"\"type=text name=\""+newId+"\" class=\""+className+"\"  title=\""+node.title+"\" disabled></input>";
	var removeIconHTML = "<a id=\""+newId+"_a\" onclick='javascript: deleteEditField(\""+newId+"\")' href='javascript:void(0);'><img src=\"../common/images/iconActionListRemove.gif\" alt=\"Add Value\" border=\"0\" /></a>"				
	var calendarHTML ="<a href=\"javascript:if(document.forms['editDataForm'].elements['attrType4'].checked){javascript:showCalendar('editDataForm','"+newId+"',saveFieldObjByName('"+newId+"'));}\">";
	var calendarIconHTML ="<img src=\"../common/images/iconSmallCalendar.gif\" id=\"calendarImg\" alt=\"Date Picker\" border=\"0\"></a>&nbsp;";
	var showClearHTML = "&nbsp;<a href='javascript:clearField(\""+newId+"\")'>" + clear + "</a>";
	var hiddenField = "<input type=\"hidden\" name=\""+newId+"_msvalue\" value=\"\">";
	
	
	if (document.forms['editDataForm'].elements['attrType4'].checked) {
		newdiv.innerHTML = divHTML+textHTMLDisabled+calendarHTML+calendarIconHTML+removeIconHTML+showClearHTML+hiddenField;
	}else 
	{
		newdiv.innerHTML = divHTML+textHTML+calendarHTML+calendarIconHTML+removeIconHTML+showClearHTML+hiddenField;
	}
		
	
	parentDiv.appendChild(newdiv);
	
}

function resetDefaultValue()
  {
	// BMN2-IR-347926 03/02/15
	document.forms['editDataForm'].elements['defaultValue_msvalue'].value = '#0';
	
	if (document.forms['editDataForm'].elements['attrType0'].checked ) {
		document.forms['editDataForm'].elements['defaultValue'].value='0';
	}
	else if(document.forms['editDataForm'].elements['attrType3'].checked || document.forms['editDataForm'].elements['attrType5'].checked ){
		document.forms['editDataForm'].elements['defaultValue'].value='0.0';
	}
	else 
	{
		document.forms['editDataForm'].elements['defaultValue'].value='';
					
		
		}
	
  }

// BMN2-IR-347926 03/02/15
function resetEditDefaultValue()
{
	document.forms['editDataForm'].elements['defaultValue_msvalue'].value = '#0';	
	if (Type=="Integer") {
		document.forms['editDataForm'].elements['defaultValue'].value='0';
	}
	else if( Type=="Real"){
		document.forms['editDataForm'].elements['defaultValue'].value='0.0';
	}
	else 
	{
		document.forms['editDataForm'].elements['defaultValue'].value='';
	}
	
}

function resetRangeFields()
  {
  
	// BMN2-IR-347926 03/02/15
	/*
	//this.form.defaultValue.value=''
	if(undefined !=document.forms['editDataForm'].elements['multiValId']){
		
		if(document.forms['editDataForm'].elements['multiValId'].value=='false'){
			resetDefaultValue();
		}
		else 
			document.forms['editDataForm'].elements['defaultValue'].value='';
		
	}else{
		resetDefaultValue();
	}*/
	
		
	var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
	var nodeMs = document.forms['editDataForm'].elements['attrRange_0_rng_msvalue'];
	
	if(undefined!=node)
	{
		node.value='';
	}
	if(undefined!=nodeMs)
	{
		nodeMs.value='#0';
	}
	removeRangeFields();
	// BMN2-IR-347926 03/02/15
 	/*var trNode= node.parentNode.parentNode.parentNode.parentNode; //<tr> node
  	var table = trNode.parentNode.parentNode
 	var tbody = table.childNodes[0];
	node.value='';
	//if range combox selected : 
	var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
  	for(i=0; i<table.childElementCount;i++){
		node = document.forms['editDataForm'].elements[nodeId+"_"+i+"_rng"];	
		if (undefined != node)
			node.value='';
	}*/

  }
  
// BMN2-IR-347926 03/02/15
function resetEditRangeFields()
  {
  	
	var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
	var nodeMs = document.forms['editDataForm'].elements['attrRange_0_rng_msvalue'];
  	if(undefined!=node)
  		{
  		node.value='';
  		}
	if(undefined!=nodeMs)
		{
		nodeMs.value='#0';
		}
	removeEditRangeFields();
	
	
  }
  function resetEditFields()
  {
	//clearField("defaultValue");
	document.forms['editDataForm'].elements['defaultValue'].value = '';	
	if(Type!="Boolean"){
		document.forms['editDataForm'].elements['attrRange_0_rng'].value = '';
		if(Type=="Date"){
			document.forms['editDataForm'].elements['defaultValue_msvalue'].value = '#0';			
			document.forms['editDataForm'].elements['attrRange_0_rng_msvalue'].value = '#0';
		}
	}
	//clearField("attrRange_0_rng");
  }
  	
  function setDisableRangeFields(disable)
  {
	// BMN2-IR-347926 03/02/15
	//document.forms['editDataForm'].elements['defaultValue'].disabled=disable;
	if(Type!="Boolean"){
		var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
		node.disabled=disable;
		/*var trNode= node.parentNode.parentNode.parentNode.parentNode; //<tr> node
		var table = trNode.parentNode.parentNode;
		node.disabled=disable;
		//if range combox selected : 
		var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
		for(i=0; i<table.childElementCount;i++){
			node = document.forms['editDataForm'].elements[nodeId+"_"+i+"_rng"];	
			if (undefined != node)
				node.disabled=disable;
		}*/
	}
  }
  
function onChangeMultiValue(input){
	
	// BMN2-IR-347926 03/02/15
	/*if(input.selectedIndex==1)
	{
		
		//setDisableRangeFields(true);
		setDisableRangeFields(false);
		resetRangeFields();
		removeRangeFields();
	}
	else{
		if(!document.forms['editDataForm'].elements['attrType4'].checked)
		{
			if(!document.forms['editDataForm'].elements['attrType1'].checked){
				setDisableRangeFields(false);
				resetRangeFields();
			}else 
				document.forms['editDataForm'].elements['defaultValue'].disabled=false;
		} 
	}*/
	// BMN2-IR-347926 03/02/15
	resetDefaultValue();
	resetRangeFields();
	
	if(input.options[input.selectedIndex].value=='true'){
		// On désactive le champs de default value
		document.forms['editDataForm'].elements['defaultValue'].disabled=true;
		
		// On active le champs de "Autorized value"
		setDisableRangeFields(false);
		
	}
	else{
		var emptyRangeValueChecked=false;
		// On active le champs de default value
		if(document.forms['editDataForm'].elements['addEmptyRange'])
		{
			if(document.forms['editDataForm'].elements['addEmptyRange'].checked==true)
			{
				emptyRangeValueChecked=true;
			}
		}
		if(emptyRangeValueChecked==false)
		{
			document.forms['editDataForm'].elements['defaultValue'].disabled=false;
		}
		// On active le champs de "Autorized value"
		setDisableRangeFields(false);
		
	
	}
	
	
	// si c'est un type boolean
	if(document.forms['editDataForm'].elements['attrType1'].checked){
		// On désactive le champs de "Autorized value"
		// Car un boolean ne peut avoir de valeur autorisées
		setDisableRangeFields(true);
	}
	
	
	// Si c'est un type Date
	if(document.forms['editDataForm'].elements['attrType4'].checked){
		// On désactive le champs de "Autorized value"
		setDisableRangeFields(true);
		// On désactive le champs de default value
		document.forms['editDataForm'].elements['defaultValue'].disabled=true;
	}

		
}
function onChangeEditMultiValue(input){
	// BMN2-IR-347926 03/02/15
	/*if(input.options[input.selectedIndex].value=='true'){
		setDisableRangeFields(true);
		removeEditRangeFields();
		resetEditFields();
	}else{
		setDisableRangeFields(false);
	}
	*/
	// BMN2-IR-347926 03/02/15
	resetEditDefaultValue();
	resetEditRangeFields();
	
	if(input.options[input.selectedIndex].value=='true'){
		// On désactive le champs de default value
		document.forms['editDataForm'].elements['defaultValue'].disabled=true;
		
		// On active le champs de "Autorized value"
		setDisableRangeFields(false);
		
	}
	else{
		var editEmptyRangeValueChecked=false;
		if(document.forms['editDataForm'].elements['addEmptyRange'])
		{
			if(document.forms['editDataForm'].elements['addEmptyRange'].checked==true)
			{
				editEmptyRangeValueChecked=true;
			}
		}
		if(editEmptyRangeValueChecked==false)
		{
		// On active le champs de default value
		document.forms['editDataForm'].elements['defaultValue'].disabled=false;
		}
		// On active le champs de "Autorized value"
		setDisableRangeFields(false);
		
	
	}
	
	
	// si c'est un type boolean
	if(Type=="Boolean"){
		// On désactive le champs de "Autorized value"
		// Car un boolean ne peut avoir de valeur autorisées
		setDisableRangeFields(true);
	}
	
	
	// Si c'est un type Date
	if(Type=="Date"){
		// On désactive le champs de "Autorized value"
		setDisableRangeFields(true);
		// On désactive le champs de default value
		document.forms['editDataForm'].elements['defaultValue'].disabled=true;
	}	
}
function removeRangeFields()
  {
	// BMN2-IR-347926 03/02/15
//   	var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
//   	var trNode= node.parentNode.parentNode.parentNode.parentNode; //<tr> node
//   	var table = trNode.parentNode.parentNode
// 	//node.value='';
// 	//if range combox selected : 
// 	var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
//   	for(i=1; i<table.childElementCount-1;i++){
// 		node = document.forms['editDataForm'].elements[nodeId+"_"+i+"_rng"];
// 		if (undefined != node){
// 			var trNodeToRemove= node.parentNode.parentNode.parentNode; //<tr> node
// 			var tableToRemove = trNodeToRemove.parentNode.parentNode;
// 			tableToRemove.deleteRow(trNodeToRemove.rowIndex);
// 		}  	
// 	 }

	// BMN2-IR-347926 03/02/15
	var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
	var parentDiv= node.parentNode.parentNode; 
	var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
	
	var vLength = parentDiv.childElementCount;
	if(vLength!=1){
		for(i=1; i<vLength;i++){
			parentDiv.removeChild(parentDiv.childNodes[1]);
		}
	}
	
  }
 
function removeEditRangeFields()
  {
  	if(Type!="Boolean"){
		var node = document.forms['editDataForm'].elements['attrRange_0_rng'];
		var parentDiv= node.parentNode.parentNode; 
		var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
		
		var vLength = parentDiv.childElementCount;
		if(vLength!=1){
			for(i=1; i<vLength;i++){
				parentDiv.removeChild(parentDiv.childNodes[1]);
			}
		}
	}
  }
 
   function addEditRangeField(id, showAdd, dateAttr)
{
	//alert("Add Range Field: "+id);
	
	var node = document.forms['editDataForm'].elements[id];
	var parentDiv= node.parentNode.parentNode; 
	
	if(maxFlag==true){
		// BMN2 12/10/2017 IR-554807
		// We retrieve the id of the last field which is like "attrRange_7_rng"
		// then isolate the number and increase later to add a new field.
		// The previous method with "parentDiv.children.length" has a bug when we remove some fields in the middle of the list, so we will add a field with one existing id.
		var lastFieldId = parentDiv.lastChild.firstElementChild.id;
		maxCount = Number.parseInt(lastFieldId.split("_")[1]);
		maxFlag=false;
	}
	var useNode = node;
	maxCount++;	
	var newId;
	var nodeId = node.id.substring(0, node.id.indexOf("_0_rng"));
	if(showAdd){
		newId = id.substring(0, id.length-1)+(maxCount);
	}else{
		if(node.type=="text"){
			newId = nodeId+"_"+(maxCount)+"_rng";
		}else{
			newId = node.name+"_"+(maxCount)+"_rng";			
		}
	}
	
	
	var newdiv = document.createElement('div');
	newdiv.setAttribute("id","attrRange_html");
	newdiv.setAttribute("name",newId);

	var className = "";
	var divHTML = "<div id=\"attrRange_html\" name=\""+newId+"\">";
	var textHTML = "<input id=\""+newId+"\"type=text name=\""+newId+"\" onChange=\"checkAlphaNum(this)\" class=\""+className+"\"  title=\""+node.title+"\"></input>";
	var textHTMLDisabled = "<input id=\""+newId+"\"type=text name=\""+newId+"\" class=\""+className+"\"  title=\""+node.title+"\" disabled></input>";
	var removeIconHTML = "<a id=\""+newId+"_a\" onclick='javascript: deleteEditField(\""+newId+"\")' href='javascript:void(0);'><img src=\"../common/images/iconActionListRemove.gif\" alt=\"Add Value\" border=\"0\" /></a>"				
	var calendarHTML ="<a href=\"javascript:if(document.forms['editDataForm'].elements['attrType4'].checked && document.forms['editDataForm'].elements['multiValId'].value=='false'){javascript:showCalendar('editDataForm','"+newId+"',saveFieldObjByName('"+newId+"'));}\">";
	var calendarIconHTML ="<img src=\"../common/images/iconSmallCalendar.gif\" id=\"calendarImg\" alt=\"Date Picker\" border=\"0\"></a>&nbsp;";
	var hiddenField = "<input type=\"hidden\" name=\""+newId+"_msvalue\" value=\"\">";
	var showClearHTML = "&nbsp;<a href='javascript:clearField(\""+newId+"\")'>clear</a>";
	
	if (dateAttr) {
		var editCalendarHTML ="<a href=\"javascript:showCalendar('editDataForm','"+newId+"',saveFieldObjByName('"+newId+"'));\">";

		newdiv.innerHTML  = divHTML+textHTMLDisabled+editCalendarHTML+calendarIconHTML+removeIconHTML+showClearHTML+hiddenField;
	}else 
		newdiv.innerHTML  = divHTML+textHTML+removeIconHTML+showClearHTML+hiddenField;
	
	parentDiv.appendChild(newdiv);
}
function checkEditMaxLength(){
	var node = document.forms['editDataForm'].elements['attrLength'];
	var min = node.min;
	var currentValue = node.value;
	if(parseInt(currentValue)<parseInt(min) || currentValue.length == 0){
		alert("<%=maxLengthNotGreaterThanMin%>"+ min);
		node.value = min;
		return;
	}
	
}

function editAttrInfinite (){
	var node = document.forms['editDataForm'].elements['attrLength'];
	var nodeCheckBoxAttrInfinite = document.forms['editDataForm'].elements['LengthAttrInfinite'];
	if(nodeCheckBoxAttrInfinite.checked){
		node.value ='';
		node.disabled =true;
		
	}
	else{
		node.disabled =false;
		node.value = node.min;
	}
}
/*
 * BMN2 13/09/2017 : IR-534160
 * This function is introduce to support only alphanumeric, '.', '-' and '_' characters for the autorized values.
 * This is not the validation function, it will only prevent the user and remove forbidden characters. 
 * If the user has created attribute with autorized values with forbidden characters it will not be removed. Only newly introduced authorized values will be 
 * impacted by this function, or if user try to change the value of existing authorized values.
 *
 */
function checkAlphaNum(a) {
	var test = false;
	 //We check that the attribute type is String
	if(document.forms['editDataForm'].hasOwnProperty('attrType2'))
	{
		  	test = document.forms['editDataForm'].elements['attrType2'].checked;
	}
	if(test || Type =="String")
	{
   		var pattern = /^[a-zA-Z0-9_.-]*$/g;
	   	var errMsg="<%=nlsErrAlphaNumAuthorizedVal%>";
	   	if(!pattern.test(a.value)){
		errMsg=errMsg.replace("%val%",a.value);
		// Display of the NLS Message
		alert(errMsg);
		// Remove forbidden characters from the field
	   	a.value=a.value.replace(/[^a-zA-Z0-9_.-]/g,'');
	   }
	 }
}

function checkPrefix(a) {
	if(a.value.length>0){
	  	var pattern = /^[a-zA-Z]+[a-zA-Z0-9_]*$/g;
	   	if(!pattern.test(a.value)){
		// Display of the NLS Message
		alert("<%=errPrefixFirstChar%>");
		a.value=a.value.replace(/[^a-zA-Z]+/,'');
	   }
	   	if(a.value.length<3){
	   	alert("<%=errPrefixLength%>");
	   }
	}
}
/*
 * BMN2 07/11/2018 : 
 * This function will hide predicate according to the type of the attribute.
 * 
 */
function filterPredicate(type){
	var node = document.forms['editDataForm'].elements['combobox'];
	node.selectedIndex=0
		for( i=0;i<node.options.length;i++)
		{
			if(node.options[i].value.endsWith(type))
			{
				node.options[i].hidden=false;
				node.options[i].disabled=false;
			}
			else{
				node.options[i].hidden=true;
				node.options[i].disabled=true;
			}	
		}
}
/*
 * BMN2 07/11/2018 : 
 * This function will select the predicate previsouly chose by the user.
 */
function selectPredicateIsExists(uri){
	var node = document.forms['editDataForm'].elements['combobox'];
	for (i = 0; i < node.options.length; i++) {
		if(node.options[i].value.startsWith(uri)){
			node.options[i].selected=true;
			node.options[0].selected=false;
			break;
		}
	}
}

function onChangeMultiline(){
	var input = document.forms['editDataForm'].elements['attrMultilineId'];
		if(input.value =="true"){
			resetRangeFields();
			setDisableRangeFields(true);
			document.forms['editDataForm'].elements['multiValId'].selectedIndex=0;
			document.forms['editDataForm'].elements['multiValId'].disabled=true;
			document.forms['editDataForm'].elements['addEmptyRange'].checked=false;
			document.forms['editDataForm'].elements['addEmptyRange'].disabled=true;
		}
		else{
			resetRangeFields();
			setDisableRangeFields(false);
			document.forms['editDataForm'].elements['multiValId'].selectedIndex=0;
			document.forms['editDataForm'].elements['multiValId'].disabled=false;
			document.forms['editDataForm'].elements['addEmptyRange'].checked=false;
			document.forms['editDataForm'].elements['addEmptyRange'].disabled=false;
		}
		
		}
		
function onChangeEditMultiline(){
	var input = document.forms['editDataForm'].elements['attrMultilineId'];

	if(published.toLowerCase()=="no"){
		if(input.selectedIndex==1){
			resetRangeFields();
			setDisableRangeFields(true);
			document.forms['editDataForm'].elements['multiValId'].selectedIndex=0;
			document.forms['editDataForm'].elements['multiValId'].disabled=true;
			document.forms['editDataForm'].elements['addEmptyRange'].checked=false;
			document.forms['editDataForm'].elements['addEmptyRange'].disabled=true;
		}
		else{
			resetRangeFields();
			setDisableRangeFields(false);
			document.forms['editDataForm'].elements['multiValId'].selectedIndex=0;
			document.forms['editDataForm'].elements['multiValId'].disabled=false;
			document.forms['editDataForm'].elements['addEmptyRange'].checked=false;
			document.forms['editDataForm'].elements['addEmptyRange'].disabled=false;
		}
	}
	else{
		var hasEmptyRangeChecked=false;
		if(document.forms['editDataForm'].elements['addEmptyRange']!=null)
		{
			if(document.forms['editDataForm'].elements['addEmptyRange'].disabled==false && document.forms['editDataForm'].elements['addEmptyRange'].checked==true){
				hasEmptyRangeChecked = true;
			}
		}
		if(hasRangesDef=="true" || hasEmptyRangeChecked==true || isAttrMultiValued==true){
					// You can't change the value of the Multiline
			if(input.selectedIndex==0){
				input.selectedIndex=1;
			}
			else{
				input.selectedIndex=0;
			}
			input.disabled=true;
		}
	}
}

function onChangeSpecExt(){
	var attrConstField =emxFormGetFieldHTMLDOM('ukAttrConst');
	attrConstField.innerHTML="";
	emxFormReloadField("ukType");
}

function onChangeSpecType(){
	var attrConstField =emxFormGetFieldHTMLDOM('ukAttrConst');
	attrConstField.innerHTML="";
	emxFormReloadField("ukAttr");
}

function onChangeUKAttr()
{
	var selectedOption = this.options[this.selectedIndex];
	if(selectedOption.style.fontWeight=="" && selectedOption.value!=""){
		selectedOption.style="font-weight:bold;";
		var divConstAttr = emxFormGetFieldHTMLDOM('ukAttrConst');
		divConstAttr.innerHTML += "<button type=\"button\" value=\""+selectedOption.value+"\" onClick=\"removeAttrCont(this);\">"+selectedOption.text+"</button>";
	}

}

function removeAttrCont(opt)
{
	var combobox = emxFormGetFieldHTMLDOM('ukAttr');
	for (var i = 0 ; i<combobox.options.length ; i++) {
		if(combobox.options[i].value==opt.value)
		{
			combobox.options[i].style.fontWeight="";
			if(combobox.selectedIndex==i){
				combobox.selectedIndex=0;
			}
			opt.remove(opt);
		}
	}
}

function validateAttrConst(){
	var combobox = emxFormGetFieldHTMLDOM('ukAttr');
	var errMsg="<%=nlsErrUkAttrSelection%>";
	var toRet = false;
	var checkAttrSelected = false;
	combobox.parentElement.firstElementChild.value="";
	for (var i = 0 ; i<combobox.options.length ; i++) {
		if(combobox.options[i].style.fontWeight!="")
		{
			combobox.parentElement.firstElementChild.value+=combobox.options[i].value+"&";
			checkAttrSelected=true;
		}
	}
	if(checkAttrSelected){
		toRet=true;
	}
	else{
		alert(errMsg);
	}
	return toRet;
}

function checkUniquekeyName() {
	var ukNameField = emxFormGetFieldHTMLDOM('ukName');
	var errMsg="<%=nlsErrUkName%>";
	var name = "";
	if(ukNameField!=null){
		name=ukNameField.value;
	}
	var toRet = false;
	if(name.length<128)
	{
	   var pattern = /^[A-Za-z0-9_]+$/;
	   if(pattern.test(name)){
	   	toRet=true;
	   }
	   else{
	   	errMsg=errMsg.replace("%val%",name);
	   	alert(errMsg);
	   }
	 }
	 return toRet;
}
</script>
