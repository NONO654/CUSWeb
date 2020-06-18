<%--  emxFormEditDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditDisplay.jsp.rca 1.44.2.4 Mon Dec 15 02:18:31 2008 ds-ss Experimental $
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxFormUtil.inc"%>
<%@ page import = "java.util.Locale,com.matrixone.apps.framework.ui.UIUtil"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
<% String fromForm =emxGetParameter(request, "fromForm"); 
if(! "true".equalsIgnoreCase(fromForm)){
	String preProcessJavaScript = emxGetParameter(request,"preProcessJavaScript");
%>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIFormUtil.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIFormHandler.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<link rel="stylesheet" href="styles/emxUIDefault.css"/>
<link rel="stylesheet" href="styles/emxUIForm.css"/>
<link rel="stylesheet" href="styles/emxUIList.css"/>
<link rel="stylesheet" href="styles/emxUICalendar.css"/>
<link rel="stylesheet" href="styles/emxUIMenu.css"/>
<link rel="stylesheet" href="mobile/styles/emxUIMobile.css"/>
<script type="text/javascript">
    var preProcessJavaScript = "<%=XSSUtil.encodeForJavaScript(context,preProcessJavaScript)%>";
	emxUICore.addEventHandler(window, "load", function(){
	if(preProcessJavaScript && preProcessJavaScript != "" && preProcessJavaScript != "undefined"){
		FormHandler.SetPreProcess(preProcessJavaScript);
	}
	FormHandler.SetFormType("emxForm");
	FormHandler.Init();
	buildNumericFieldValues("edit");
	});
</script>
<% } %>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="uiFormCommonBean" class="com.matrixone.apps.framework.ui.UIFormCommon" scope="session"/>

<%
HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext); 


//Whole URL should not be encoded always. Encode only param values of the querystring. 
//UINavigatorUtil.encodeURL uses XSSUtil.encodeForURL API to encode querystring's param values.
String queryString = request.getQueryString();
StringBuffer prevURL = request.getRequestURL();
if (queryString != null) {
    prevURL.append('?').append(XSSUtil.encodeURLwithParsing(context,queryString));
}
String form = emxGetParameter(request, "form");
Locale loc = request.getLocale();
String title_prefix = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.WindowTitle.Body", loc );
String title = title_prefix + form;
String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");

String objectId = emxGetParameter(request, "objectId");
String portalMode = emxGetParameter(request, "portalMode");

String searchMode = emxGetParameter(request, "searchmode");

String relId = emxGetParameter(request, "relId");
String timeStamp = emxGetParameter(request, "timeStamp");
String suiteKey = emxGetParameter(request, "suiteKey");
String postProcessURL = emxGetParameter(request, "postProcessURL");
if(!UIUtil.isNullOrEmpty(postProcessURL)){
	//Whole URL should not be encoded always. Encode only param values of the querystring. 
	//UINavigatorUtil.encodeURL uses XSSUtil.encodeForURL API to encode querystring's param values.
	postProcessURL = UINavigatorUtil.encodeURL(context, postProcessURL);
}
String postProcessJPO = emxGetParameter(request, "postProcessJPO");
String cancelProcessURL = emxGetParameter(request, "cancelProcessURL");
String cancelProcessJPO = emxGetParameter(request, "cancelProcessJPO");
String pagination = emxGetParameter(request, "pagination");
Locale locale = (Locale)session.getAttribute("locale");
String mode = "";

String targetLocation = emxGetParameter(request,"targetLocation");
String slideinType = emxGetParameter(request,"slideinType");
String categoryTreeName = emxGetParameter(request, "categoryTreeName");
//String viewtoolbar = emxGetParameter(request, "viewtoolbar");
//String viewformHeader = emxGetParameter(request, "viewformHeader");


if (timeStamp == null || timeStamp.trim().length() == 0)
{
    timeStamp = UIComponent.getTimeStamp();
}
HashMap formMap = new HashMap();

String localDateFormat = ((java.text.SimpleDateFormat)java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale())).toLocalizedPattern();
String allowKeyableDates = "false";
try {
                allowKeyableDates = EnoviaResourceBundle.getProperty(context, "emxFramework.AllowKeyableDates");
} catch(Exception e) {
        allowKeyableDates = "false";
}

String requiredMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.FieldsInRedItalicsAreRequired", loc );

HashMap inputMap = new HashMap();
inputMap.put("componentType", "form");
inputMap.put("localDateFormat", localDateFormat);
inputMap.put("allowKeyableDates", allowKeyableDates);

// time zone to be used for the date fields
String timeZone = (String)session.getAttribute("timeZone");

int maxCols = 2;

try {

    ContextUtil.startTransaction(context, false);

    //Added for pre process hook-up
    Vector userRoleList = PersonUtil.getAssignments(context);
	
	//For previous button in structure compare browser
	HashMap requestValuesMap = UINavigatorUtil.getRequestParameterValuesMap(request);
	requestMap.put("RequestValuesMap", requestValuesMap);
	
	mode = (String)requestMap.get("mode");
    HashMap imageData = UINavigatorUtil.getImageData(context, pageContext);
    requestMap.put("ImageData", imageData);
	String addCustAttributes =(String)emxGetParameter(request, "addCustAttributes");
    requestMap.put("addCustAttributes",addCustAttributes);
    String preProcessJPO = (String)requestMap.get("preProcessJPO");
    String preProcessURL = (String)requestMap.get("preProcessURL");
    HashMap formData = new HashMap();
    MapList fields = new MapList();

        if (form != null)
        {
            formMap = formEditBean.getForm(context, form);

            if (formMap != null)
            {
                    formData = formEditBean.setFormData(requestMap, context, timeStamp, userRoleList, true);
                    fields = formEditBean.getFormFields(formData);
                    maxCols = ((Integer)formData.get("max cols")).intValue();
            }
			//Added for BUG 344952
            for (int j = 0; j < fields.size(); j++){
                HashMap fieldTemp = (HashMap)fields.get(j);
                String strTempaccess = (String) fieldTemp.get("hasAccess");
                if(formEditBean.isGroupHolderField(fieldTemp) || formEditBean.isGroupField(fieldTemp)){
                	if(strTempaccess!=null && !"".equals(strTempaccess)&& strTempaccess.equalsIgnoreCase("false"))
                    	fields.remove(fieldTemp); 
                }
	    }
      }


    if (preProcessURL != null && !"".equals(preProcessURL) || preProcessJPO != null && !"".equals(preProcessJPO))
    {
      request.setAttribute("context", context);
      %>
        <jsp:include page="emxFormEditPreProcess.jsp" flush="true" />
      <%
    }

    String typeAheadEnabled = "true";
    try
    {
        typeAheadEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead");
    }
    catch (Exception e)
    {
    }
    
    inputMap.put("typeAheadEnabled", typeAheadEnabled);
   if(! "true".equalsIgnoreCase(fromForm)){        
    StringList incFileList = UIForm.getJSValidationFileList(context, suiteKey);
    String fileTok = "";
    for(StringItr keyItr = new StringItr(incFileList); keyItr.next();)
    {
        fileTok = keyItr.obj();
        if(fileTok.endsWith(".jsp")) {
%>
            <jsp:include page = "<%=fileTok%>" flush="true" />
<%
        }else if(fileTok.endsWith(".js")) {
%>
            <script language="javascript" src="<%=fileTok%>"></script>
<%
        }
    }
  }
%>
        
	<form name="editDataForm" autocomplete="off" method="post">
<script language="javascript">
		var myValidationRoutines = new Array();
		var myValidationRoutines1 = new Array();
</script>		
<%
    StringList slFieldNames = new StringList();
    slFieldNames.add("queryLimit");

    if (fields == null || fields.size() == 0)
    {
%>
<script language="javascript">
		//var myValidationRoutines = new Array();
		//var myValidationRoutines1 = new Array();
        parent.document.location.href = "emxFormNoDisplay.jsp";
</script>
<%
        return;

    } else {

%><table class="form">
<%
	if("slidein".equals(targetLocation) && !"wider".equals(slideinType)){
%>
  		<!-- XSSOK -->
  		<tr><td class="requiredNotice"><%=requiredMsg%></td></tr>
<%
	} else {
%>
		<!-- XSSOK -->
  		<tr><td>&nbsp;</td><td class="requiredNotice"><%=requiredMsg%></td></tr>
<%
	}
        for (int i=0; i < fields.size(); i++)
        {
            HashMap field = (HashMap)fields.get(i);

           	String sInputType = formEditBean.getSetting(field, "Input Type");
           	String sformat    = formEditBean.getSetting(field, "format");

            if (formEditBean.isDynamicAttributeField(field))
            {
                continue;
            }
            String sEditable = formEditBean.getSetting(field, "Editable");
            if ( !formEditBean.hasAccessToFiled(field) )
                continue;

            String fieldName = formEditBean.getName(field);
            slFieldNames.add(fieldName);
            //Added these lines so that the hidden fields Display,OID and Actual are not written again in the end
            slFieldNames.add(fieldName + "Display");
            slFieldNames.add(fieldName + "OID");
            slFieldNames.add(fieldName + "Actual");
            String fieldLabel = formEditBean.getLabel(field);
            String fieldType = formEditBean.getFieldType(field);

            String sRangeHelperURL = formEditBean.getSetting(field, "Range Helper URL");
            String winWidth = formEditBean.getSetting(field, "Window Width");
            String winHeight = formEditBean.getSetting(field, "Window Height");
            String maxLength = formEditBean.getSetting(field, "Maximum Length");
            String fieldSize = formEditBean.getSetting(field, "Field Size");
            if( fieldSize == null )
              fieldSize="";
            if( maxLength == null )
              maxLength="";

            String fieldValue = "";
            String fieldValueDisplay = "";

            StringList fieldValueList = formEditBean.getFieldValues(field);
            StringList fieldValueDisplayList = formEditBean.getFieldDisplayValues(field);
            //StringList fieldChoices = formEditBean.getFieldChoices(field);
            //StringList fieldChoicesDisplay = formEditBean.getFieldDisplayChoices(field);
 			// Add Validation methods to Array
 			
              if (uiFormCommonBean.isNumericField(field)) {
            	  %>
            	  	  <script language="javascript">
            		  myValidationRoutines.push(["validateNumericField","<xss:encodeForJavaScript><%=fieldName%></xss:encodeForJavaScript>"]);
            		  </script>
            	  <%
              }
              if (uiFormCommonBean.isIntegerField(field)) {
            	  %> 
	            	  <script language="javascript">
	            		myValidationRoutines.push(["validateIntegerField","<xss:encodeForJavaScript><%=fieldName%></xss:encodeForJavaScript>"]);
	            	 </script>
            	  <%
              } 
              if (uiFormCommonBean.isFieldRequired(field)) {
            	  %> 
	            	  <script language="javascript">
	        		  myValidationRoutines.push(["validateRequiredField","<xss:encodeForJavaScript><%=fieldName%></xss:encodeForJavaScript>"]);
	        		  </script>
        	  <%
      		   }             
			%>
				<script language="javascript">
				myValidationRoutines1.push(["assignValidateMethod","<xss:encodeForJavaScript><%=fieldName%></xss:encodeForJavaScript>","<%=uiFormCommonBean.getValidationMethod(field)%>"]);
				</script>
			<%
            if (fieldValueList != null && fieldValueList.size() > 0)
            {
                fieldValue = (String)fieldValueList.firstElement();

                if (fieldValueDisplayList == null || fieldValueDisplayList.size() == 0 )
                {
                    fieldValueDisplayList = fieldValueList;
                    fieldValueDisplay = fieldValue;
                } else {
                    fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
                }
            }

            if (formEditBean.isFieldSectionHeader(field))
            {
            	if ((formEditBean.getSectionLevel(field) == 1) && "wider".equals(slideinType) )
            {
            	%>
            	<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>" ><td colspan="<%=maxCols+1%>" class="heading1"><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td></tr>
            	<%
            	                }else if (formEditBean.getSectionLevel(field) == 1)
                {
%>
<tr id="calc_<%=fieldName%>"><td colspan="<%=maxCols%>" class="heading1"><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td></tr>
<%
                } else {
%>
<tr id="calc_<%=fieldName%>"><td colspan="<%=maxCols%>" class="heading2"><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td></tr>
<%
                }
            } else if (formEditBean.isFieldSectionSeparator(field))
            {
%>
<tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>"><td>&nbsp;</td></tr>
<%
            }  else if (formEditBean.isProgramHTMLOutputField(field) || formEditBean.isClassificationPathsField(field) )
            {
                String strHideLabel = formEditBean.getSetting(field, "Hide Label");
                int tempMaxCols = maxCols;
                boolean showLabel = true;
                if ("true".equalsIgnoreCase(strHideLabel)){
                  showLabel = false;
                  tempMaxCols++;
                }

                //show Multiple Fields
                String strMultipleFields = formEditBean.getSetting(field, formEditBean.SETTING_MULTIPLE_FIELDS);

                //If strMultipleFields is true, the do not add <tr> tags
                if(strMultipleFields != null && "true".equalsIgnoreCase(strMultipleFields))
                {
                    // pass show label as false
%>
                    <!-- XSSOK -->
                    <%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, false, tempMaxCols)%>
<%
                } else if (formEditBean.isGroupHolderField(field) || formEditBean.isGroupField(field))
				{
					int iTEMP = 0;
					int nonAccessCount = 0;
					Integer iGroup = new Integer(formEditBean.getFieldGroupCount(field));
					HashMap mapTotalVerticalGroups = new HashMap();
					StringList strlVerticalGroupNames = new StringList();
					// Added for web form row span layout
					if (formEditBean.isGroupHolderField(field))
						i++;
					int grpMaxCols = 2;
					for (int j = 0; j < iGroup.intValue(); i++){
						 field = (HashMap)fields.get(i);
						 
						 Integer iVerticalGroup = new Integer(formEditBean.getFieldVerticalGroupCount(field));
						 String strVerticalGroupName = (String) formEditBean.getSetting(field,"Vertical Group Name");
						
						 if(iVerticalGroup.intValue()>0){
							 strlVerticalGroupNames.add(strVerticalGroupName);
							 mapTotalVerticalGroups.put(strVerticalGroupName,iVerticalGroup);
						 }
						 if (!formEditBean.hasAccessToFiled(field) ){
							  nonAccessCount++;   
							  continue;
						 }
						  j++;
					}
					
					iGroup = new Integer(iGroup.intValue()+nonAccessCount);
					i=i-iGroup.intValue();
					
					if(mapTotalVerticalGroups!=null && mapTotalVerticalGroups.size()>0){
						for(int c=0;c<strlVerticalGroupNames.size();c++){
							Integer integer = (Integer)mapTotalVerticalGroups.get(strlVerticalGroupNames.get(c).toString());
							if(iTEMP<integer.intValue()){
								iTEMP = integer.intValue();
							}
						}
					}		

					if(strlVerticalGroupNames.size()>0) {
						  int itemp = i;
						  int itempCopy = i;
						  int temp = 0;
						  int countHideLabel = 0;
						  int iLoopExecforRowSpan = 0;
						  java.util.List<Integer> strlDisplayedFields = new ArrayList<Integer>();
						  for(int m=0;m<iGroup.intValue();) {
							 grpMaxCols = 2;
							 iLoopExecforRowSpan++;
							 %>
							 <tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>">
							 <%
							  for(int n=0;n<strlVerticalGroupNames.size()&& m<iGroup.intValue() && itemp<i+iGroup.intValue();) {
									 int iRowSpan = 1;
						grpMaxCols = 2;
									 field = (HashMap) fields.get(itemp);
									  
									 if ( !formEditBean.hasAccessToFiled(field)) {
											if(!strlDisplayedFields.contains(new Integer(itemp))){
												strlDisplayedFields.add(new Integer(itemp));   
												m++; 
											}
											itemp++;
											continue;
									  }
									  else if(strlDisplayedFields.contains(new Integer(itemp))) {
											String strnGrpName = (String) strlVerticalGroupNames.get(n);
											Integer intGrpcount = (Integer)mapTotalVerticalGroups.get(strnGrpName);
											itemp = itemp + intGrpcount.intValue();
											n++;
								  continue;  		                
									  }
									  else {
											 m++;
											 // For calculating the next element
											 String strVerGrpName = (String) strlVerticalGroupNames.get(n);
											 Integer IVerticalGrpCnt = (Integer)mapTotalVerticalGroups.get(strVerGrpName);
											  // To get the next vertical group first value
											  
											 int iNextSetFirstValue = IVerticalGrpCnt.intValue();
											  
											 // To check teh setting Hide label for displaying the label
											 String strHideLabel1 = formEditBean.getSetting(field, "Hide Label");
											 boolean showLabel1 = true;
											 if ("true".equalsIgnoreCase(strHideLabel1)){
												showLabel1 = false;
									grpMaxCols = grpMaxCols + 1;
												countHideLabel =  countHideLabel + 1;
											 }
											 
											 if(iNextSetFirstValue<iTEMP){
												  iRowSpan = 1;
											 }
											 if(iLoopExecforRowSpan != iTEMP && iLoopExecforRowSpan == IVerticalGrpCnt.intValue() ){
												  iRowSpan = iTEMP - IVerticalGrpCnt.intValue()+1;
											 }
											  // Ended calc
												
											 if ((strlVerticalGroupNames.size()*2 < maxCols) && (n == strlVerticalGroupNames.size()-1) ){
												 grpMaxCols = maxCols - (strlVerticalGroupNames.size()*2)+2;
												 if(showLabel1 == false)
													grpMaxCols = grpMaxCols + countHideLabel;
											 }
											 strlDisplayedFields.add(new Integer(itemp));	
											 %>
											 <!-- XSSOK -->
											 <%=drawFormEditElement(context, requestMap, field,inputMap, timeZone,  showLabel1, grpMaxCols,-1,false,iRowSpan)%><% 
											 // To get the next vertical group first value
											 itemp = itemp+IVerticalGrpCnt.intValue();
									  }
									  n++;
							  }
							  itemp = ++itempCopy; 
							  %>
							  </tr>
							  <%
						  }
						  i+=iGroup.intValue();
					  }
					  else {
							%>
							<tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>">
							<%
							for (int j = 0; j < iGroup.intValue(); j++,i++) {
								
									field = (HashMap)fields.get(i);
									if ( !formEditBean.hasAccessToFiled(field) )
										continue;
									
									// To check the setting Hide label for displaying the label
									String strHideLabel2 = formEditBean.getSetting(field, "Hide Label");
									boolean showLabel2 = true;
									if ("true".equalsIgnoreCase(strHideLabel2))
									  showLabel2 = false;
									
									if ( (iGroup.intValue()*2 < maxCols) && (j == iGroup.intValue()-1) )
										grpMaxCols = maxCols - (iGroup.intValue()*2)+2;
								 
									fieldLabel = formEditBean.getFieldLabel(field);
									fieldValueList = formEditBean.getFieldValues(field);
									fieldValueDisplayList = formEditBean.getFieldDisplayValues(field);
				
									if (fieldValueList != null && fieldValueList.size() > 0)
										fieldValue = (String)fieldValueList.firstElement();
				
									if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
										fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
									%><!-- XSSOK -->
									<%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, showLabel2, grpMaxCols)%>
									<%
							}
					  }
					  i--;
	%></tr><%
				}
                else
                {
%>
                <tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>">
                    <!-- XSSOK -->
                    <%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, showLabel, tempMaxCols)%>
                </tr>
<%
                }
            } else if (formEditBean.isClassificationAttributesField(field)  )
            {
                int tempMaxCols = maxCols;
                tempMaxCols++;

%><!-- XSSOK -->
                    <%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, false, tempMaxCols)%>
<%

            }
            else if (formEditBean.isTableField(field))
            {
                String table = formEditBean.getSetting(field, "table");
                String reportFormat = "HTML";
%>
<!-- XSSOK -->
<tr><td colspan="<%=maxCols%>" class="heading1">
<!-- XSSOK -->
<jsp:include page = "emxFormTableInclude.jsp" flush="true"> <jsp:param name="timeStamp" value='<%=XSSUtil.encodeForURL(context, timeStamp) + XSSUtil.encodeForURL(context, fieldName)%>'/> <jsp:param name="objectId" value='<%=XSSUtil.encodeForURL(context, objectId)%>'/> <jsp:param name="relId" value='<%=XSSUtil.encodeForURL(context, relId)%>'/> <jsp:param name="table" value='<%=table%>'/> <jsp:param name="inquiry" value='<%=formEditBean.getSetting(field, "inquiry")%>'/> <jsp:param name="program" value='<%=formEditBean.getSetting(field, "program")%>'/> <jsp:param name="sortColumnName" value='<%=formEditBean.getSetting(field, "sortColumnName")%>'/> <jsp:param name="sortDirection" value='<%=formEditBean.getSetting(field, "sortDirection")%>'/> <jsp:param name="pagination" value="0"/> <jsp:param name="selection" value="none"/> <jsp:param name="reportFormat" value='<%=reportFormat%>'/> <jsp:param name="printerFriednly" value='false'/>
</jsp:include>
</td></tr>
<%
            } else if (formEditBean.isGroupHolderField(field) || formEditBean.isGroupField(field))
            {
                int iTEMP = 0;
                int nonAccessCount = 0;
                Integer iGroup = new Integer(formEditBean.getFieldGroupCount(field));
                HashMap mapTotalVerticalGroups = new HashMap();
                StringList strlVerticalGroupNames = new StringList();
                // Added for web form row span layout
                if (formEditBean.isGroupHolderField(field))
                    i++;
                int grpMaxCols = 2;
                for (int j = 0; j < iGroup.intValue(); i++){
                     field = (HashMap)fields.get(i);
                     
                     Integer iVerticalGroup = new Integer(formEditBean.getFieldVerticalGroupCount(field));
                     String strVerticalGroupName = (String) formEditBean.getSetting(field,"Vertical Group Name");
                    
                     if(iVerticalGroup.intValue()>0){
                         strlVerticalGroupNames.add(strVerticalGroupName);
                         mapTotalVerticalGroups.put(strVerticalGroupName,iVerticalGroup);
                     }
                     if (!formEditBean.hasAccessToFiled(field) ){
                          nonAccessCount++;   
                          continue;
                     }
                      j++;
                }
                
                iGroup = new Integer(iGroup.intValue()+nonAccessCount);
                i=i-iGroup.intValue();
                
	            if(mapTotalVerticalGroups!=null && mapTotalVerticalGroups.size()>0){
                    for(int c=0;c<strlVerticalGroupNames.size();c++){
                    	Integer integer = (Integer)mapTotalVerticalGroups.get(strlVerticalGroupNames.get(c).toString());
						if(iTEMP<integer.intValue()){
						    iTEMP = integer.intValue();
						}
                    }
	            }		

	            if(strlVerticalGroupNames.size()>0) {
	     		      int itemp = i;
	     		      int itempCopy = i;
	     		      int temp = 0;
	     		      int countHideLabel = 0;
	     		      int iLoopExecforRowSpan = 0;
	     		      java.util.List<Integer> strlDisplayedFields = new ArrayList<Integer>();
	     		      for(int m=0;m<iGroup.intValue();) {
	     		         grpMaxCols = 2;
	     		         iLoopExecforRowSpan++;
	                     %>
	   		             <tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>">
	   		             <%
	     		          for(int n=0;n<strlVerticalGroupNames.size()&& m<iGroup.intValue() && itemp<i+iGroup.intValue();) {
	     		                 int iRowSpan = 1;
					grpMaxCols = 2;
	     		                 field = (HashMap) fields.get(itemp);
		    	 	              
		     		             if ( !formEditBean.hasAccessToFiled(field)) {
		     		                    if(!strlDisplayedFields.contains(new Integer(itemp))){
			     		                    strlDisplayedFields.add(new Integer(itemp));   
			     		                    m++; 
		     		                    }
		     		                    itemp++;
		     		                    continue;
		                          }
		     		              else if(strlDisplayedFields.contains(new Integer(itemp))) {
		     		                    String strnGrpName = (String) strlVerticalGroupNames.get(n);
	 		                		    Integer intGrpcount = (Integer)mapTotalVerticalGroups.get(strnGrpName);
	 		                		    itemp = itemp + intGrpcount.intValue();
	 		                		    n++;
	 						  continue;  		                
	 		            		  }
		                          else {
						              	 m++;
				    	 	             // For calculating the next element
				     		             String strVerGrpName = (String) strlVerticalGroupNames.get(n);
				     		             Integer IVerticalGrpCnt = (Integer)mapTotalVerticalGroups.get(strVerGrpName);
				                          // To get the next vertical group first value
				                          
				                         int iNextSetFirstValue = IVerticalGrpCnt.intValue();
				                          
				                         // To check teh setting Hide label for displaying the label
				    		             String strHideLabel = formEditBean.getSetting(field, "Hide Label");
				                         boolean showLabel = true;
				                         if ("true".equalsIgnoreCase(strHideLabel)){
				                            showLabel = false;
								grpMaxCols = grpMaxCols + 1;
				                            countHideLabel =  countHideLabel + 1;
				                         }
				                         
				                         if(iNextSetFirstValue<iTEMP){
				                              iRowSpan = 1;
				                         }
				                         if(iLoopExecforRowSpan != iTEMP && iLoopExecforRowSpan == IVerticalGrpCnt.intValue() ){
				                              iRowSpan = iTEMP - IVerticalGrpCnt.intValue()+1;
				                         }
				    		              // Ended calc
											
				    		             if ((strlVerticalGroupNames.size()*2 < maxCols) && (n == strlVerticalGroupNames.size()-1) ){
				    		                 grpMaxCols = maxCols - (strlVerticalGroupNames.size()*2)+2;
				    		                 if(showLabel == false)
							    		        grpMaxCols = grpMaxCols + countHideLabel;
				    		             }
				    		             strlDisplayedFields.add(new Integer(itemp));	
				    		             %><!-- XSSOK -->
				                         <%=drawFormEditElement(context, requestMap, field,inputMap, timeZone,  showLabel, grpMaxCols,-1,false,iRowSpan)%><% 
				                         // To get the next vertical group first value
									     itemp = itemp+IVerticalGrpCnt.intValue();
		                          }
		    	 	              n++;
	     		          }
	     		          itemp = ++itempCopy; 
	  					  %>
	     		          </tr>
	     		          <%
	      		      }
	     		      i+=iGroup.intValue();
				  }
     		  	  else {
	     		        %>
		     		    <tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>">
		     		    <%
		     		    int hideLabelCount =0;
		                for (int j = 0; j < iGroup.intValue(); j++,i++) {
		                    
			                    field = (HashMap)fields.get(i);
			                    if ( !formEditBean.hasAccessToFiled(field) )
			                        continue;
			                    
		                        // To check the setting Hide label for displaying the label
	                            String strHideLabel = formEditBean.getSetting(field, "Hide Label");
	                            boolean showLabel = true;
	                            if ("true".equalsIgnoreCase(strHideLabel)){
	                              showLabel = false;
	                              hideLabelCount ++; 
	                            }
	                            
			                    if ( (iGroup.intValue()*2 <= maxCols) && (j == iGroup.intValue()-1) )

			                        grpMaxCols = maxCols - (iGroup.intValue()*2)+2 +hideLabelCount;
			                 
			                    fieldLabel = formEditBean.getFieldLabel(field);
			                    fieldValueList = formEditBean.getFieldValues(field);
			                    fieldValueDisplayList = formEditBean.getFieldDisplayValues(field);
			
			                    if (fieldValueList != null && fieldValueList.size() > 0)
			                        fieldValue = (String)fieldValueList.firstElement();
			
			                    if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
			                        fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
								%>
								<!-- XSSOK -->
								<%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, showLabel, grpMaxCols)%>
								<%
		                }
     		      }
                  i--;
%></tr><%
            } else if (formEditBean.isTableHolderField(field) )
            {
                String languageStr = request.getHeader("Accept-Language");
                String colCount = formEditBean.getSetting(field, "Field Table Columns");
                String rowCount = formEditBean.getSetting(field, "Field Table Rows");
                String colHeader = formEditBean.getSetting(field, "Field Column Headers");
                String rowHeader = formEditBean.getSetting(field, "Field Row Headers");

                String fieldSuite = formEditBean.getSetting(field, "Registered Suite");
                String stringResourceFile = UINavigatorUtil.getStringResourceFileId(context,fieldSuite);

                colHeader = EnoviaResourceBundle.getProperty(context,stringResourceFile, loc, colHeader);
                rowHeader = EnoviaResourceBundle.getProperty(context, stringResourceFile, loc,  rowHeader);

                StringList colHeaderList = FrameworkUtil.split(colHeader, ",");
                StringList rowHeaderList = FrameworkUtil.split(rowHeader, ",");

                int cols = (Integer.valueOf(colCount)).intValue();
                int rows = (Integer.valueOf(rowCount)).intValue();
                i++;

%><!-- XSSOK -->
<tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>"><td colspan="<%=maxCols%>"><table border="0" width="100%" cellpadding="5" cellspacing="2"><tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>">
<td class="label" >&nbsp;</td><%
                for (int j = 0; j < cols; j++)
                {
                    String colHeaderName = (String)colHeaderList.get(j);
                    String i18nColHeaderValue =EnoviaResourceBundle.getProperty(context, stringResourceFile, loc, colHeaderName);

%>
<td class="label" ><%=XSSUtil.encodeForHTML(context, i18nColHeaderValue,false)%></td>
<%
                }

                for (int r = 0; r < rows; r++)
                {
                    String rowHeaderName = (String)rowHeaderList.get(r);
                    String i18nRowHeaderValue = EnoviaResourceBundle.getProperty(context, stringResourceFile, loc,  rowHeaderName);

%></tr><td class="label" ><%=XSSUtil.encodeForHTML(context, i18nRowHeaderValue,false)%></td>
<%
                    for (int k = 0; k < cols; k++,i++)
                    {
                        field = (HashMap)fields.get(i);
                        fieldName = formEditBean.getName(field);

                        if ( !formEditBean.hasAccessToFiled(field) )
                        {
                             field.put("field_display_value","");
                             field.put("field_value","");
                             formEditBean.modifySetting(field,"Editable","false");
                        }

%><%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, false, 2)%><%
                    }
                }

                i--;
%></tr></table></td></tr><%
            } else {
			    String strHideLabel = formEditBean.getSetting(field, "Hide Label");
                int tempMaxCols = maxCols;
                boolean showLabel = true;
                if ("true".equalsIgnoreCase(strHideLabel)){
                  showLabel = false;
                  tempMaxCols++;
                }
                %><tr id="calc_<%=XSSUtil.encodeForHTMLAttribute(context, fieldName)%>"><%=drawFormEditElement(context, requestMap, field, inputMap, timeZone, showLabel, tempMaxCols)%>
<%              
                    

%>
                </tr>
	       <%
                 }
        }
    }  
   	 %>
    
        
   	    <%
        for (int i=0; i < fields.size(); i++)
        {
        	%>
     <script type="text/javascript">
        try 
        {
     	     var field = null;
   	    <%
        	
            HashMap field     = (HashMap)fields.get(i);
           	String fieldName  = formEditBean.getName(field);
            String fieldType  = formEditBean.getFieldType(field);
           	String sInputType = formEditBean.getSetting(field, "Input Type");
           	String sformat    = formEditBean.getSetting(field, "format");
           	String fieldValue =   "";
           	StringList fieldValueList = formEditBean.getFieldValues(field);
            if (fieldValueList != null && fieldValueList.size() > 0)
                fieldValue = (String)fieldValueList.firstElement();
           %>
           	field = FieldFactory.CreateField("<xss:encodeForJavaScript><%=fieldName.replaceAll(" ", "_")%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=fieldType%></xss:encodeForJavaScript>","<%=sInputType%>","<%=sformat%>","<%=field.get("AssociatedWithUOM")%>");
           	<%
           	String jsFieldName = formEditBean.getSetting(field,"jsFieldName");
           	String jsFieldValue = fieldValue;
            if(jsFieldValue == null || "".equals(jsFieldValue)){
                jsFieldValue = "0";
            }
           	HashMap settings = formEditBean.getSettings(field);
			Iterator keyItr  = settings.keySet().iterator();
			while(keyItr.hasNext())
			{
				String key   = (String)keyItr.next();
			%>	//<![CDATA[ //XSSOK ]]>
			field.AddSetting( new Setting("<%=key%>",<%=UINavigatorUtil.toJSONString(formEditBean.getSetting(field,key))%>));
			<%
			}
			StringList fieldChoices 	   = formEditBean.getFieldChoices(field);
			StringList fieldDisplayChoices = formEditBean.getFieldDisplayChoices(field);
			
			if(fieldChoices != null && fieldDisplayChoices != null)
			{
			  for(int l = 0 ; l < fieldChoices.size(); l++)
			  {
		 	%> //<![CDATA[ //XSSOK ]]>
			field.AddRange( new Range(<%=UINavigatorUtil.toJSONString((String)fieldDisplayChoices.get(l))%>,<%=UINavigatorUtil.toJSONString((String)fieldChoices.get(l))%>)); 
		 	<%
			  }
			}
           	%>FormHandler.AddField(field);
           	<% 
            boolean isNum = "numeric".equals(formEditBean.getSetting(field,"Data Type"));
            if(isNum)
            {
            %> var jsFieldName = field.GetSettingValue("jsFieldName");
               eval("var <%=jsFieldName%> = <%=jsFieldValue%>;");
            <%
            }
            
   	  %>
       }catch(ex) 
       {
       }
       </script>
       <%
            
            String rangeHelperURL = formEditBean.getRangeHelperURL(field);
            // add the type ahead javascript, the tag checks if the feature is enabled
        String strTypeAheadSetting=formEditBean.getSetting(field,"TypeAhead");
        if (UIUtil.isNullOrEmpty(rangeHelperURL) && UIUtil.isNullOrEmpty(strTypeAheadSetting))
            {
                strTypeAheadSetting="true";
            }
        String sTypeAheadProgram = formEditBean.getSetting(field, "TypeAhead Program");
        String sTypeAheadFunction = formEditBean.getSetting(field, "TypeAhead Function");
        
        if (((formEditBean.isTextBoxField(field) && UIUtil.isNullOrEmpty(rangeHelperURL) && formEditBean.isFieldEditable(field))
            ||(formEditBean.isFieldManualEditable(field) && rangeHelperURL != null && rangeHelperURL.length() > 0) 
            || (formEditBean.isDateField(field) && formEditBean.isFieldManualEditable(field))) 
            && "true".equalsIgnoreCase(typeAheadEnabled) && "true".equalsIgnoreCase(strTypeAheadSetting)
            )
        {  
                String tagDisplayFieldName;
                String tagHiddenFieldName;
                
                if (rangeHelperURL != null && rangeHelperURL.length() > 0)
                {
                    tagDisplayFieldName = fieldName + "Display";
                    tagHiddenFieldName = fieldName;
                }
                else
                {
                    tagDisplayFieldName = fieldName;
                    tagHiddenFieldName = "";
                }
                
                String tagTypeAheadProgram = formEditBean.getSetting(field, "TypeAhead Program");
                String tagTypeAheadFunction = formEditBean.getSetting(field, "TypeAhead Function");
                String tagTypeAheadCharacterCount = formEditBean.getSetting(field, "TypeAhead Character Count");
                String tagTypeAheadValidate = formEditBean.getSetting(field,"Type Ahead Validate");
                if(UIUtil.isNullOrEmpty(tagTypeAheadValidate)){
                    tagTypeAheadValidate = "true";
                }

                String selectionMode = "single";
                if(!UIUtil.isNullOrEmpty(rangeHelperURL) && (rangeHelperURL.indexOf("selection=multiple") > -1 || rangeHelperURL.indexOf("SelectType=multiselect") > -1)) {
                    selectionMode = "multiple";
                }
                
                String isDateField ="false";
                if (formEditBean.isDateField(field)){
                    isDateField="true";
                }
            
   %>            
   				<!-- XSSOK -->
                <emxUtil:displayTypeAheadValues context ="<%= context %>" form ="<%= XSSUtil.encodeForXML(context, form) %>" field ="<%= fieldName %>" displayField ="<%= tagDisplayFieldName %>" hiddenField ="<%= tagHiddenFieldName %>" program ="<%= tagTypeAheadProgram %>" function  ="<%= tagTypeAheadFunction %>" characterCount ="<%= tagTypeAheadCharacterCount %>" isdatefield ="<%= isDateField %>" timeStamp ="<%= XSSUtil.encodeForXML(context, timeStamp) %>" uiType ="form" typeAheadValidate ="<%= tagTypeAheadValidate %>" selectionMode ="<%=selectionMode %>" rangeHelperURL ="<%=rangeHelperURL %>"
                />
                <!-- XSSOK -->
        <%    
        }
       }
                  //take all params passed in and draw hidden fields
                  Enumeration eNumParameters = emxGetParameterNames(request);
                  while( eNumParameters.hasMoreElements() ) {
                    String strParamName = (String)eNumParameters.nextElement();
                    String strValue ="";
                     //If the parameter contains multiple values, create multiple hidden
                                            //fields so that all the values are retained
                                            String strParamValues[] = emxGetParameterValues(request, strParamName);
                                                                    if (!strParamName.equals("formaction") && !strParamName.equals("form") && !strParamName.equals("mode")){
                                                                         if(!slFieldNames.contains(strParamName)){
                                                                                if (strParamValues != null) {
                                                                                        for (int iCount=0; iCount<strParamValues.length; iCount++) {                                                                                        	
                                                                                            strValue = strParamValues[iCount]; 
                                                                                            //this findAndReplace may not be required, we will remove this in next release and test it thoroughly, whether all the use cases works fine. 
                                                                                            strValue=FrameworkUtil.findAndReplace(strValue,"'","\'");
                                                                                            strValue=FrameworkUtil.findAndReplace(strValue,"\"","\\\"");

                                                                %>
                                                                      <input type=hidden name="<xss:encodeForHTMLAttribute><%=strParamName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=strValue%></xss:encodeForHTMLAttribute>" />
                                                                      
                                                                <%
                }}
                                        }
                    }
                  }
 
} catch (Exception ex) {

    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}
%>
</table>
<input type="hidden" name="isPopup" value="false" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" id="mode" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" id="categoryTreeName" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTreeName%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>"/>
<input id="formId" type="hidden" name="form" value="<xss:encodeForHTMLAttribute><%=form%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="emxSuiteDirectory" value="<xss:encodeForHTMLAttribute><%=emxSuiteDirectory%></xss:encodeForHTMLAttribute>" />
<input id="timeStamp" type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="postProcessURL" value="<xss:encodeForHTMLAttribute><%=postProcessURL%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="postProcessJPO" value="<xss:encodeForHTMLAttribute><%=postProcessJPO%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" id="uiType" name="uiType" value="form" />
<input id="paginationId" type="hidden" name="pagination" value="<xss:encodeForHTMLAttribute><%=pagination%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" id="sessionRemove" name="sessionRemove" value="" />
<!-- XSSOK -->
<input type="hidden" name="prevURL" value="<%=prevURL.toString()%>" /0> <!-- for previous button in structure compare browser -->
<input id="targetLocation" type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%=targetLocation%></xss:encodeForHTMLAttribute>"/>
<input id="slideinType" type="hidden" name="slideinType" value="<xss:encodeForHTMLAttribute><%=slideinType%></xss:encodeForHTMLAttribute>"/>


</form>
<iframe class='hidden-frame' name='formEditHidden' HEIGHT='0' WIDTH='0'></iframe>
