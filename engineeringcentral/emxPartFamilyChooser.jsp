<%--  emxPartFamilyChooser.jsp - To display and handled the fields related to the Part Family Chooser in Part Create Component.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.DomainObject,com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";
  
  public String getCustomRevision (Context context, String defaultPolicy) throws Exception {
      return new Policy(defaultPolicy).getFirstInSequence(context);      
  }
%>

<%
    String languageStr     = request.getHeader("Accept-Language");
    String objectId                 = (String)emxGetParameter(request, "objectId");
    String strNumberGenarationOn    = PropertyUtil.getSchemaProperty(context,"attribute_PartFamilyNameGeneratorOn");
    String strTableRowId[]          = emxGetParameterValues(request,"emxTableRowId");
    String strObjname               = "";
    String strNameGenFlag           = "FALSE";
    
    //Added for supporting the same code for Part Clone also- start
    String fromPartCloneAction = (String) emxGetParameter(request, "fromPartCloneAction");    
    
    
  //Added for supporting the same code for Part Clone also - end
    
    //Added for IR-097616V6R2012    
   /* String strLangPartFamily = i18nNow.getI18nString("emxEngineeringCentral.Common.PartFamily", "emxEngineeringCentralStringResource", languageStr);
    String strLangPartFamilyNameGeneratorMess = i18nNow.getI18nString("emxEngineeringCentral.Part.NameGeneratedByPartFamily", "emxEngineeringCentralStringResource", languageStr);
    */
    String strLangPartFamily = EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.PartFamily");
    String strLangPartFamilyNameGeneratorMess = EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.NameGeneratedByPartFamily");
    
    String defaultPolicy = FrameworkProperties.getProperty(context, "type_Part.defaultDevPolicy");
    String defaultType = PropertyUtil.getSchemaProperty(context,"type_Part");
    
    String SELECT_ATTRIBUTE_DEFAULT_PART_POLICY = "attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_DefaultPartPolicy") + "]";
    String SELECT_ATTRIBUTE_DEFAULT_PART_TYPE = "attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_DefaultPartType") + "]";
    String SELECT_ATTRIBUTE_NAME_GEN_ON = "attribute[" + strNumberGenarationOn + "]";
    String strPartMode = "Resolved";
    
    // NEWLY ADDED..
    String fieldNameActual  = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
    String typeAhead        = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "typeAhead"));
    String frameName        = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "frameName"));
    String fieldNameDisplay = XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "fieldNameDisplay"));
    
 // IR-082946V6R2012 : Start
    String POLICY_STANDARD_PART = PropertyUtil.getSchemaProperty(context,"policy_StandardPart");
    String POLICY_CONFIGURED_PART = PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");    
 // IR-082946V6R2012 : End
    String strPolicyDisp;
       
    int iTableRow = strTableRowId.length;
    for(int i=0 ; i<strTableRowId.length ;i++)
    {
        StringTokenizer strTokens = new StringTokenizer(strTableRowId[i],"|");
        if (strTokens.hasMoreTokens())
        {
        	objectId = strTokens.nextToken();
            Search search = new Search();
            strObjname = search.getObjectName(context, objectId);
        }
    }    
		
	boolean isMBOMInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMManufacturing",false,null,null);
	boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
	
	if (null != objectId && objectId.length() > 0)
	{	
         StringList objectSelect = new StringList(3);
         objectSelect.add(SELECT_ATTRIBUTE_DEFAULT_PART_TYPE);
         objectSelect.add(SELECT_ATTRIBUTE_NAME_GEN_ON);
         objectSelect.add(SELECT_ATTRIBUTE_DEFAULT_PART_POLICY);
         
         DomainObject domObj = DomainObject.newInstance(context, objectId);
                     
         Map dataMap = domObj.getInfo(context, objectSelect);
         
         strNameGenFlag = (String) dataMap.get(SELECT_ATTRIBUTE_NAME_GEN_ON);
         
         String strTemp = (String) dataMap.get(SELECT_ATTRIBUTE_DEFAULT_PART_POLICY);
         if (strTemp != null && !"".equals(strTemp)) {
      	   if ("policy_ConfiguredPart".equals(strTemp)) {
      		   strPartMode = "Unresolved";
      	   }
             defaultPolicy = PropertyUtil.getSchemaProperty(context,strTemp); 
         }           
         
         strTemp = (String) dataMap.get(SELECT_ATTRIBUTE_DEFAULT_PART_TYPE);
         if (strTemp != null && !"".equals(strTemp)) {
             defaultType = PropertyUtil.getSchemaProperty(context,strTemp); 
         }
	}

%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">

function valueExistsInListBox(selectbox, valuseToSearch) {
	var pfExists = false;
	
	for (var i = 0; i < selectbox.options.length; i++) {
		if (selectbox.options[i].value == valuseToSearch) {
			pfExists = true;
			break;
		}
	}
	
	return pfExists;
}

function addSelectOption (fromTypeAhead, selectObj, text, value, isSelected) {    
    if (fromTypeAhead == "true") {
        selectObj.options[selectObj.options.length] = new Option(text, value, false, isSelected);
    } else {
        var newOption = getTopWindow().getWindowOpener().document.createElement("OPTION"); 
        newOption.text = text;
        newOption.value = value;
        newOption.selected = isSelected;
        selectObj.options[selectObj.options.length] = newOption;
    }
}

function removeOptions(selectbox, valueToDel) {	
	for (var i = 0; i < selectbox.options.length; i++) {
		if (selectbox.options[i].value == valueToDel) {
			 selectbox.remove(i);
		}
	}
}

function isValidInputField(inputField) {
	return (inputField == null || inputField == undefined) ? false : true;
}


function setAndRefresh()
{
	//XSSOK
	var typeAhead = "<%=typeAhead%>";
	//XSSOK
       var fname = "<%=frameName%>";
	var targetWindow = null;
	if(typeAhead == "true")
	{
	    if(fname != ""&& "null"!=fname && null!=fname){
	    	//XSSOK
	    	targetWindow = getTopWindow().findFrame(window.parent, "<%=frameName%>");
	    }
	    else
	        targetWindow = window.parent;
	}else
	{
	    targetWindow = getTopWindow().getWindowOpener();
	}
	//XSSOK
	var tmpFieldNameActual     = "<%=fieldNameActual%>";
	//XSSOK
	var tmpFieldNameDisplay    = "<%=fieldNameDisplay%>";
	var tmpFieldNameOID        = tmpFieldNameActual + "OID";
	
	var vfieldNameActual   = targetWindow.document.getElementById(tmpFieldNameActual);
	var vfieldNameDisplay  = targetWindow.document.getElementById(tmpFieldNameDisplay);
	var vfieldNameOID      = targetWindow.document.getElementById(tmpFieldNameOID);
	var sAutoNameSeries    = targetWindow.document.getElementById("AutoNameSeriesId");
    var sNameField         = targetWindow.document.getElementById("Name");
    var sAutoNameCheck     = targetWindow.document["autoNameCheck"];
    var txtPFAutoName      = targetWindow.document["PartFamilyAutoName"];
    var createMode         = targetWindow.document.forms[0]["createMode"];
    createMode = (createMode == null || createMode == "undefined") ? "" : createMode.value;

        //XSSOK
    var sNameGenFlag =  "<%=strNameGenFlag%>";
	
    if (vfieldNameActual==null && vfieldNameDisplay==null){
        vfieldNameActual    =targetWindow.document.forms[0][tmpFieldNameActual];
        vfieldNameDisplay   =targetWindow.document.forms[0][tmpFieldNameDisplay];
        vfieldNameOID       =targetWindow.document.forms[0][tmpFieldNameOID];
    }
    if  (sAutoNameSeries == null) {
    	sAutoNameSeries    = targetWindow.document.forms[0][sAutoNameSeries];
    }
    
    if (!isValidInputField(sAutoNameSeries)) {
		sAutoNameSeries = targetWindow.document.forms[0]["NameId"];
	}
    
    if  (sNameField == null) {
    	sNameField    = targetWindow.document.forms[0][sNameField];
    }
    if  (sAutoNameCheck == null) {
    	sAutoNameCheck = targetWindow.document.forms[0]["autoNameCheck"];
    }
    if (txtPFAutoName == null) {
    	txtPFAutoName  = targetWindow.document.forms[0]["PartFamilyAutoName"];
    }
    
	//XSSOK
	var sObjName           ="<%=strObjname%>";
	var sOID               ="<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
	//XSSOK
	var sAutoNameGenOn     ="<%=strNameGenFlag%>";
   
  // setting the field values 
    vfieldNameDisplay.value = sObjName;
    vfieldNameActual.value  = sObjName;
    vfieldNameOID.value     = sOID;
    txtPFAutoName.value     = sAutoNameGenOn;

    /*if (isValidInputField(sNameField) && sNameField.requiredValidate != null) {
        sNameField.oldRequiredValidate = sNameField.requiredValidate;
    }*/
    
    if(sAutoNameSeries != null){
	    if (sNameGenFlag == "TRUE") {
	       // For introducing new value in Auto Name Series
	       //if (sAutoNameSeries.options.length <= 5) {
	           //Modified for IR-097616V6R2012 
	           //XSSOK
	       if (!valueExistsInListBox(sAutoNameSeries, "Part Family")) {
	           //XSSOK
	           var langPartFamily="<%=strLangPartFamily%>";
	           addSelectOption(typeAhead, sAutoNameSeries, langPartFamily, "Part Family", true);
		   }
	        sAutoNameSeries.value = "Part Family";
		    // Auto Name check
		    
		    if (isValidInputField(sAutoNameCheck)) {
	        	sAutoNameCheck.checked = true; 
	        	sAutoNameCheck.disabled = true;
		    }
	
	        // Disable the name
	        if (isValidInputField(sNameField)) {
	        	sNameField.requiredValidate = null;	        
		        sNameField.disabled = true;
		        sNameField.value = "";
		        sAutoNameSeries.disabled = true;
	        }

	        if ("<xss:encodeForJavaScript><%= fromPartCloneAction%></xss:encodeForJavaScript>" == "true") {
	        	if (isValidInputField(sNameField)) {
	        		sNameField.disabled = true;    
	        	}
	        	sAutoNameSeries.disabled = true;
	        	if (isValidInputField(sAutoNameCheck)) {
	        		sAutoNameCheck.disabled = true;
	        	}
	        	//XSSOK
	        	alert("<%=strLangPartFamilyNameGeneratorMess%>");	        	
		    }	        
	        
	    } else {
	        if(sAutoNameSeries.value== "Part Family") {
	            sAutoNameSeries.value = "Not Selected"; 
	        }
	        if (isValidInputField(sAutoNameCheck)) {
	        	sAutoNameCheck.checked = false;
	        }
	        
	        if (isValidInputField(sNameField)) {
		        sNameField.value = "";        
		        sNameField.requiredValidate = sNameField.oldRequiredValidate;
		        sNameField.disabled = false;
	        }
	        
	        removeOptions(sAutoNameSeries, "Part Family");

	        if ("<xss:encodeForJavaScript><%= fromPartCloneAction%></xss:encodeForJavaScript>" == "true") {
	        	if (isValidInputField(sNameField)) {
	        		sNameField.disabled = false;    
	        	}
                sAutoNameSeries.disabled = false;
                if (isValidInputField(sAutoNameCheck)) {
                	sAutoNameCheck.disabled = false;    
                }
            }	        
	    }
    }else{
    	if (isValidInputField(sAutoNameCheck)) {
    		sAutoNameCheck.checked = true;
    	}
    	
    	if (isValidInputField(sNameField)) {
	    	sNameField.value = "";
	    	sNameField.disabled = false;
	    	sNameField.requiredValidate = false;
    	}
    }
    if(typeAhead != "true") {
    	getTopWindow().closeWindow();
    }

if ("<xss:encodeForJavaScript><%= fromPartCloneAction%></xss:encodeForJavaScript>" != "true") {

    var createModeField = targetWindow.document.forms[0].createMode;
    var createModeValue = "";
    if(createModeField != null && createModeField != "undefined") {
    	createModeValue = createModeField.value;
    }

    if(createModeValue == "MFG") {
    	targetWindow.reloadForm();
        return;
    }
//XSSOK
	targetWindow.document.forms[0].TypeActualDisplay.value = "<%= UINavigatorUtil.getAdminI18NString("Type", defaultType, context.getSession().getLanguage()) %>";
	//XSSOK
	targetWindow.document.forms[0].TypeActual.value = "<%= defaultType %>";

    
    var listBox = targetWindow.document.getElementById("PartModeId");     

    var partModeFound = true;
    if (listBox != null && listBox != "undefined") {
    	partModeFound = false;
	    for (var i = 0; i < listBox.length; i++) {
	    	//XSSOK
	        if (listBox.options[i].value == "<%= strPartMode %>") {
	            listBox.options[i].selected = "true";
	            partModeFound = true;            
	        }
	    }
    }

    if (partModeFound) {
	    if ((listBox != null && listBox.value == "Unresolved") || (createMode=="assignTopLevelPart")) {        
	    	targetWindow.document.getElementById("CustomRevisionLevel").readOnly = true;
	    	if (targetWindow.document.forms[0].ECODisplay) {
		    	targetWindow.document.forms[0].ECODisplay.readOnly = true;
		    	targetWindow.document.forms[0].btnECO.disabled = true;
	    	}
	    } else {        
	        targetWindow.document.getElementById("CustomRevisionLevel").readOnly = false;
	        if (targetWindow.document.forms[0].ECODisplay) {
	        	targetWindow.document.forms[0].ECODisplay.readOnly = false;
	        	targetWindow.document.forms[0].btnECO.disabled = false;
	        }
	    }
	    
	    policyListBox = targetWindow.document.getElementById("PolicyId");
	    policyListBox.length = 0;
            var defaultPolicy = "<%= defaultPolicy%>";
   	    if (defaultPolicy == "<%=POLICY_CONFIGURED_PART%>" || createMode == "assignTopLevelPart") {
<%			
			strPolicyDisp = i18nNow.getAdminI18NString("Policy", POLICY_CONFIGURED_PART, languageStr);
%>
			//XSSOK
            addSelectOption(typeAhead, policyListBox, "<%= strPolicyDisp%>", "<%= POLICY_CONFIGURED_PART %>", true);		    
		                 
		} else {
<%			  BusinessType partBusinessType = new BusinessType(DomainConstants.TYPE_PART, context.getVault());
	          PolicyList allPartPolicyList = partBusinessType.getPoliciesForPerson(context, false);
	          PolicyItr partPolicyItr = new PolicyItr(allPartPolicyList);
	          
	          boolean bcamInstall = FrameworkUtil.isSuiteRegistered(context, "appVersionX-BOMCostAnalytics", false, null, null);	          
	          
	          Policy policyValue;
	          String policyName;
	          String policyClassification;

	          while (partPolicyItr.next()) {
	              policyValue = (Policy) partPolicyItr.obj();
	              policyName = policyValue.getName();
	              policyClassification = EngineeringUtil.getPolicyClassification(context, policyName);

	              if (!isMBOMInstalled && POLICY_STANDARD_PART.equalsIgnoreCase(policyName)) {
	                  continue;
	              }

	              if (POLICY_CONFIGURED_PART.equalsIgnoreCase(policyName) && !isECCInstalled) {
	                  continue;
	              }
	              if (bcamInstall) {
	                  if ("Cost".equals(policyClassification)) {
	                      continue;
	                  }
	              }
	              if (EngineeringUtil.getPolicyClassification(context,policyName).equals("Equivalent")
	                      || EngineeringUtil.getPolicyClassification(context, policyName).equals("Manufacturing")) {
	                  continue;
	              }
	              strPolicyDisp = i18nNow.getAdminI18NString("Policy", policyName, languageStr);
%>	              
				//XSSOK
                  addSelectOption(typeAhead, policyListBox, "<%= strPolicyDisp%>", "<%= policyName %>", <%= defaultPolicy.equals(policyName)%>);	              
<%	                                              
	          }
%>
		}

		//XSSOK
	    targetWindow.document.getElementById("CustomRevisionLevel").value = "<%= getCustomRevision (context, defaultPolicy)%>";
    }
}    
    
 // IR-082946V6R2012 : End
}
</script>
<html>
<body onload=setAndRefresh()>
</body>
</html>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


