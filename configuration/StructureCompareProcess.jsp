<%--
  StructureCompareProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<%@page import="java.util.Enumeration" %>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<body >
<%
		//get the selected Objects from the Full Search Results page
		String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
        String typeAhead = emxGetParameter(request, "typeAhead");
		boolean isMobileMode = UINavigatorUtil.isMobile(context);
		try{
		    //gets the mode passed
		     String strSearchMode = emxGetParameter(request, "chooserType");
		     // if the chooser is in the Custom JSP 
		     if (strSearchMode!= null && (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser")))
		     {                       
		         String fieldNameActual = emxGetParameter(request, "fieldNameActual");
		         String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");	       
		         
		         StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
		         String strObjectId = strTokenizer.nextToken();		       
		         String strContextObjectName = LogicalFeature.getContextObjectName(context,strObjectId);%>
		         <script language="javascript" type="text/javaScript">         


		                 
		             var vfieldNameActual = "";
		             var vfieldNameDisplay = "";   
		             var vfieldNameOID = "";         
                     var flag = "false";
                     var openerObj = getTopWindow().getWindowOpener();
                    

                     if(openerObj != null){                                      
                         vfieldNameActual = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");          
                         vfieldNameDisplay = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");           
                         
                     }

                     if(vfieldNameDisplay[0]){                       
                         vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                         vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                         flag = "true";
                     }
                     else{                          
                                                                                   
                         vfieldNameDisplay = getTopWindow().frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");                      
                         vfieldNameActual = getTopWindow().frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>"); 
                        // vfieldNameActual[0] = openerObj.document.forms["editDataForm"].<%=fieldNameActual%>;
                         //vfieldNameDisplay[0] = openerObj.document.forms["editDataForm"].<%=fieldNameDisplay%>;        
                         flag = "false";                                    
                        vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;                         
                        vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;                               
                     }
                     if(flag == "true"){
                    	 var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,typeAhead)%>";
                    	 if(typeAhead != "true")
                             //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    	 getTopWindow().closeWindow();
                     }
		         </script>
<%
		     }
		     //Else loop is for PostProcess and display of Structure Compare results
		     else{
		    	 
%>
        <script language="Javascript">
                
       // var displayframe = findFrame(parent, "content");
       var displayframe = getTopWindow().frames[0];        
        var displayForm = displayframe.document.forms[0];        
        var matchBasedOn = displayForm.MatchBasedOn;
        var matchBasedOnActual = displayForm.MatchBasedOnActual;
        var compareBy = displayForm.CompareBy;
        var compareByActual = displayForm.CompareByActual;
        var compareBySelections = new Array;
        var matchBasedOnSelections = new Array;        
        for(var n=0;n<matchBasedOn.length;n++)
        {
            if(matchBasedOn[n].checked)
            {
                matchBasedOnSelections=matchBasedOnSelections+','+matchBasedOnActual[n].value;
            }
        }
        for(var n=0;n<compareBy.length;n++)
        {
            if(compareBy[n].checked)
            {
                compareBySelections = compareBySelections+','+compareByActual[n].value;
            }
        }
        </script>
<%
    String sName1               = emxGetParameter(request, "Name1");
    String sObjectId1           = emxGetParameter(request, "objectId");
    //String sName2               = emxGetParameter(request, "Name2");
  String strFeatureType       = emxGetParameter(request, "featureType");
  String sObjectId2    = emxGetParameter(request, "Name2");
  if(strFeatureType.equals("ConfigurationFeature")&&("".equals(sObjectId2)) ){
     sObjectId2  = emxGetParameter(request, "Name2OID");
   }    
    if(UIUtil.isNullOrEmpty(sObjectId2)) {
    	sObjectId2  = emxGetParameter(request, "Name2OID");
    }
  
    //Added for previous button in structure compare browser
    //storing the new selections in a string so that it can be appended to a url
    String strNameToDisplay          = emxGetParameter(request, "Name2Display");
    String[] strMatchBasedOn = null;
    String[] strCompareBy = null;
    String strCompareByValue = null;
    String strMatchBasedOnValue = null;
    java.util.Enumeration e2 = emxGetParameterNames(request);
    while (e2.hasMoreElements()) {
        String strParamName = (String)e2.nextElement(); 
		
        if ("MatchBasedOn".equalsIgnoreCase(strParamName)) {
            strMatchBasedOn = emxGetParameterValues(request, strParamName);
        }
        else if ("CompareBy".equals(strParamName)) {
            strCompareBy = emxGetParameterValues(request, strParamName);
        }
    }    
    StringBuffer buffer = new StringBuffer(128);
    if (strMatchBasedOn != null) {
        for (int i = 0; i < strMatchBasedOn.length; i++) {
            if (buffer.length() != 0) {
                buffer.append(",");
            }
            buffer.append(strMatchBasedOn[i]);
        }
        strMatchBasedOnValue = buffer.toString();
    }       
    buffer = new StringBuffer(128);
    if (strCompareBy != null) {
        for (int i = 0; i < strCompareBy.length; i++) {
            if (buffer.length() != 0) {
                buffer.append(",");
            }
            buffer.append(strCompareBy[i]);
        }
        strCompareByValue = buffer.toString();
    }  
    String sExpandLevel         = emxGetParameter(request, "ExpandLevel");
    String sFormat              = emxGetParameter(request, "Format");    
    String strURL =null;
    StringBuffer strBufURL = new StringBuffer();
    String strCompleteReportType = "Complete_Summary_Report";
    String strCommonReportType   = "Common_Components_Report";
    boolean isFTRUser = ConfigurationUtil.isFTRUser(context);
    
    //Modified For IR-205737V6R2014
    if(strFeatureType.equals("Variant") || strFeatureType.equals("VariabilityGroup") || strFeatureType.equals("Variability")|| strFeatureType.equals("ConfigurationFeature"))
    {
    	if(sFormat.equals(strCompleteReportType)){
    	sFormat = strCommonReportType;
    	}
    	String strExpandProgram = "ConfigurationFeature:expandVariabilityStucture";
    	if(strFeatureType.equals("Variant")){
    		strExpandProgram = "ConfigurationFeature:expandVariantStucture";
    	}else if(strFeatureType.equals("VariabilityGroup")){
    		strExpandProgram = "ConfigurationFeature:expandVariabilityGroupStucture";
    	}
        strBufURL.append("../common/emxIndentedTable.jsp?displayView=details&expandProgram=");
        strBufURL.append(strExpandProgram);
        strBufURL.append("&compare=compareBy&table=FTRConfigurationFeaturesStructureCompareTable&objectId=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append(",");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&reportType=");
        strBufURL.append(XSSUtil.encodeForURL(context,sFormat));
        strBufURL.append("&IsStructureCompare=TRUE&expandLevel=");
        strBufURL.append(XSSUtil.encodeForURL(context,sExpandLevel));
        strBufURL.append("&strObjectId2=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&strObjectId1=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append("&objectCompare=false&showClipboard=false&customize=false");        
        strBufURL.append("&HelpMarker=emxhelp_structurecomparereport");
        strURL = strBufURL.toString();        
    }else if(strFeatureType.equals("LogicalFeature")){
    	if((!isFTRUser && sFormat.equals(strCompleteReportType)) || (isMobileMode && sFormat.equals(strCompleteReportType))){// IR-471649-3DEXPERIENCER2017x
    		sFormat = strCommonReportType;
    	}
        strBufURL.append("../common/emxIndentedTable.jsp?displayView=details&expandProgram=LogicalFeature:getLogicalFeatureStructure&selection=multiple&toolbar=FTRLogicalFeatureCompareToolbar&compare=compareBy&table=FTRLogicalFeaturesStructureCompareTable&objectId=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append(",");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&reportType=");
        strBufURL.append(XSSUtil.encodeForURL(context,sFormat));
        strBufURL.append("&IsStructureCompare=TRUE&expandLevel=");
        strBufURL.append(XSSUtil.encodeForURL(context,sExpandLevel));
        strBufURL.append("&strObjectId2=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&strObjectId1=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append("&objectCompare=false&showClipboard=false&customize=false");        
        strBufURL.append("&HelpMarker=emxhelp_structurecomparereport&relationship=relationship_LogicalFeatures&direction=from");
        strBufURL.append("&connectionProgram=LogicalFeature:synchronizeLogicalFeature");
        strURL = strBufURL.toString();
    }
    else if(strFeatureType.equals("PVLogicalFeature") || strFeatureType.equals("PVBOMCompare")){
    	if(sFormat.equals(strCompleteReportType)){
        sFormat = strCommonReportType;
        }
    	
    	strBufURL.append("../common/emxIndentedTable.jsp?displayView=details&expandProgram=emxProductVariant:expandLogicalStructureForProductVariant&compare=compareBy&table=FTRLogicalFeaturesStructureCompareTable&objectId=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append(",");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&reportType=");
        strBufURL.append(XSSUtil.encodeForURL(context,sFormat));
        strBufURL.append("&IsStructureCompare=TRUE&expandLevel=");
        strBufURL.append(XSSUtil.encodeForURL(context,sExpandLevel));
        strBufURL.append("&strObjectId2=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&strObjectId1=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append("&objectCompare=false&showClipboard=false&customize=false");        
        strBufURL.append("&HelpMarker=emxhelp_structurecomparereport");
        strURL = strBufURL.toString();
    }
    else if(strFeatureType.equals("BOMCompare")){
    	if((!isFTRUser && sFormat.equals(strCompleteReportType)) || (isMobileMode && sFormat.equals(strCompleteReportType))){// IR-471649-3DEXPERIENCER2017x
    		sFormat = strCommonReportType;
    	}
    	
        strBufURL.append("../common/emxIndentedTable.jsp?displayView=details&expandProgram=LogicalFeature:getLogicalFeatureStructure&selection=multiple&toolbar=FTRStructureCompareEBOMToolbar&compare=compareBy&table=FTRLogicalFeaturesStructureCompareTable&objectId=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append(",");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&reportType=");
        strBufURL.append(XSSUtil.encodeForURL(context,sFormat));
        strBufURL.append("&IsStructureCompare=TRUE&expandLevel=");
        strBufURL.append(XSSUtil.encodeForURL(context,sExpandLevel));
        strBufURL.append("&strObjectId2=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&strObjectId1=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append("&connectionProgram=LogicalFeature:synchronizeEbomToProduct");
        strBufURL.append("&objectCompare=false&showClipboard=false&customize=false");        
        strBufURL.append("&HelpMarker=emxhelp_structurecomparereport");
        strURL = strBufURL.toString();
    }
    else if(strFeatureType.equals("ManufacturingFeature")){
    	if(sFormat.equals(strCompleteReportType)){
        sFormat = strCommonReportType;
        }
    	
        strBufURL.append("../common/emxIndentedTable.jsp?displayView=details&expandProgram=ManufacturingFeature:getManufacturingFeatureStructure&compare=compareBy&table=FTRLogicalFeaturesStructureCompareTable&objectId=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append(",");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&reportType=");
        strBufURL.append(XSSUtil.encodeForURL(context,sFormat));
        strBufURL.append("&IsStructureCompare=TRUE&expandLevel=");
        strBufURL.append(XSSUtil.encodeForURL(context,sExpandLevel));
        strBufURL.append("&strObjectId2=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId2));
        strBufURL.append("&strObjectId1=");
        strBufURL.append(XSSUtil.encodeForURL(context,sObjectId1));
        strBufURL.append("&objectCompare=false&showClipboard=false&customize=false");        
        strBufURL.append("&HelpMarker=emxhelp_structurecomparereport&relationship=relationship_ManufacturingFeatures&direction=from");
        strURL = strBufURL.toString();
    }
    String strPrevURL = XSSUtil.decodeFromURL(emxGetParameter(request, "prevURL"));    
	if(strPrevURL.indexOf("common/emxForm.jsp")>-1){//IR-471647-3DEXPERIENCER2017x
    	String strSecondPart=strPrevURL.substring(strPrevURL.lastIndexOf("common/emxForm.jsp?"));
    	strPrevURL="../"+strSecondPart;
    }
    //
    //Added for previous button in structure compare browser
    //Modifying the url for new selections and making sure not to allow old selections
   
    StringBuffer buffer1 = new StringBuffer(128);
    String[] strvalues = strPrevURL.split("&");
    for (int i=0; i<strvalues.length; i++) {        
        if (buffer1.length() != 0) {
            buffer1.append("&");
        }
        String[] strKeyValues = strvalues[i].split("=");
        // length check is put for IR-217082V6R2014
        if (strKeyValues != null && strKeyValues.length == 2) {
            String strKey =  strKeyValues[0];
            String strValue1 = strKeyValues[1];
            if("parentOID".equalsIgnoreCase(strKey)){
            	continue;
            }
            else if ("MatchBasedOn".equalsIgnoreCase(strKey)) {
                if (!"".equals(strMatchBasedOnValue) || strMatchBasedOnValue != null) {
                    strValue1 = strMatchBasedOnValue; 
                }
                else {
                    strValue1 = "";
                }
                buffer1.append((XSSUtil.encodeForURL(context,strKey))+"="+(XSSUtil.encodeForURL(context,strValue1)));
            }
            else if ("compareBy".equals(strKey)) {
                if (!"".equals(strCompareByValue) || strCompareByValue != null) {
                    strValue1 = strCompareByValue; 
                }
                else {
                    strValue1 = "";
                }
                buffer1.append((XSSUtil.encodeForURL(context,strKey))+"="+(XSSUtil.encodeForURL(context,strValue1)));
            }
            else if ("Name2Display".equalsIgnoreCase(strKey)) {
                if (!"".equals(strNameToDisplay) || strNameToDisplay != null) {
                    strValue1 = strNameToDisplay;                   
                }
                else {
                    strValue1 = "";
                }
               //buffer1.append(strKey+"="+strValue1);
            }
            else if ("Name2OID".equalsIgnoreCase(strKey)) {
                if (!"".equals(sObjectId2) || sObjectId2 != null) {
                    strValue1 = sObjectId2; 
                }
                else {
                    strValue1 = "";
                }
                buffer1.append((XSSUtil.encodeForURL(context,strKey))+"="+(XSSUtil.encodeForURL(context,strValue1)));
            }
            else if ("ExpandLevel".equalsIgnoreCase(strKey)) {
                if (!"".equals(sExpandLevel) || sExpandLevel != null) {
                    strValue1 = sExpandLevel; 
                }
                else {
                    strValue1 = "";
                }
                buffer1.append((XSSUtil.encodeForURL(context,strKey))+"="+(XSSUtil.encodeForURL(context,strValue1)));
            }
            else if ("Format".equalsIgnoreCase(strKey)) {
                if (!"".equals(sFormat) || sFormat != null) {
                    strValue1 = sFormat; 
                }
                else {
                    strValue1 = "";
                }
                buffer1.append((XSSUtil.encodeForURL(context,strKey))+"="+(XSSUtil.encodeForURL(context,strValue1)));
            }
            else {
                buffer1.append(strvalues[i]); 
            }
        }
        else {
            buffer1.append(strvalues[i]); 
        }
    }
    String str = buffer1.toString();
    
    if (str.indexOf("MatchBasedOn") == -1) {
        buffer1.append("&MatchBasedOn="+ (XSSUtil.encodeForURL(context,strMatchBasedOnValue)));
    }
    
    if (str.indexOf("compareBy") == -1 && strCompareByValue != null) {
        buffer1.append("&compareBy="+ (XSSUtil.encodeForURL(context,strCompareByValue)));
    }
    if (str.indexOf("Name2Display") == -1) {    	
       // buffer1.append("&Name2Display="+ strNameToDisplay);
    }
    if (str.indexOf("Name2OID") == -1) {
        buffer1.append("&Name2OID="+ (XSSUtil.encodeForURL(context,sObjectId2)));
    }
    if (str.indexOf("ExpandLevel") == -1) {
        buffer1.append("&ExpandLevel="+ (XSSUtil.encodeForURL(context,sExpandLevel)));
    }
    if (str.indexOf("Format") == -1) {
        buffer1.append("&Format="+ (XSSUtil.encodeForURL(context,sFormat)));
    }
    if (str.indexOf("Name1") == -1) {
        buffer1.append("&Name1="+ (XSSUtil.encodeForURL(context,sName1)));
    }
    if (str.indexOf("objectId") == -1) {
        buffer1.append("&objectId="+ (XSSUtil.encodeForURL(context,sObjectId1)));
    }

    
    str = buffer1.toString();
    
    //
    //End
    //
    String strNameToDisplay2=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(context,strNameToDisplay);	
    str = str + "&Name2Display="+strNameToDisplay2;
    str = com.matrixone.apps.domain.util.FrameworkUtil.encodeURL(str);
	//
	
	%>
	          <script language="Javascript">	        
	          
			var url = "<%=XSSUtil.encodeURLwithParsing(context,strURL)%>&matchBasedOn=<%=XSSUtil.encodeForURL(context,strMatchBasedOnValue)%>"+"&compareBy=<%=XSSUtil.encodeForURL(context,strCompareByValue)%>"+"&prevURL=<%=str%>";
			
//End of IR-205737V6R2014	
            //var isIE  = Browser.IE;
		    //var isFF  = Browser.FIREFOX;
            
			//if(isIE || isFF){
				getTopWindow().location.href= url;
		    //}else{
		    	//showModalDialog(url);
				//getTopWindow().close();
		    //}
		     
        </script>
        <%
		}
		}   
        catch (Exception e){        	       	
            session.putValue("error.message", e.getMessage());  
        }
        %>
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
