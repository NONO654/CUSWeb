<%--
  CreateUtil.jsp
  Utility JSP to handle the Create and Add Existing functionality
  
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
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature" %>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  String strMode = emxGetParameter(request,"mode");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String strObjId = emxGetParameter(request, "objectId");
  String uiType = emxGetParameter(request,"uiType");
  String strMode1 = emxGetParameter(request,"context");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String regisateredSuite = emxGetParameter(request,"SuiteDirectory");

  String strContext = emxGetParameter(request,"context");
  String strLanguage = context.getSession().getLanguage();
  
  
  String action        = "refresh";
  String msg           = "";
  String  sbEditAction = null;
  if(strMode1!=null && strMode1.equalsIgnoreCase("sbEdit"))
  {
      sbEditAction = strMode;
       strMode = strMode1 ;

  }

  String tempType = DomainConstants.EMPTY_STRING;
  boolean bIsError             = false;
  try
  {      
	  /*****************************************************************************************************************************************************/
	  if (strMode.equalsIgnoreCase("CreateNewMasterFeature")) {}
    /*****************************************************************************************************************************************************/
	
	/*****************************************************************************************************************************************************/	  
	// This Mode is for Add Existing
	else if (strMode.equalsIgnoreCase("AddExisting")) {
		
		// This is called from the Command Href of the Add Existing Product Revision under the Master Feature
		// in the context of Model
		// This block will check if a Product Revision can be added under master feature.
		// If the Master Feature's Feature Management Mode is Product Revision then only the Product Revision can be added.
        if (strContext.equalsIgnoreCase("PreProcessAddExistingModel")){

            String strObjIdContext = emxGetParameter(request,
                    "objectId");

            String[] strTableRowIds = emxGetParameterValues(request,
                    "emxTableRowId");
            String strObjectID = null;
            String strRelID = null;
            boolean canAdd = false;
            String strModelId = null;
            if (strTableRowIds!=null && strTableRowIds[0].indexOf("|") > 0) {
            	throw new FrameworkException(EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.Error.MasterFeature.AddExisting",strLanguage));
            } else {
                   StringBuffer strBuffer = new StringBuffer(400);
                   Enumeration enumParamNames = emxGetParameterNames(request);

                   while (enumParamNames.hasMoreElements()) {
                       String paramName = (String) enumParamNames.nextElement();
                       String paramValue = emxGetParameter(request,paramName);
                       strBuffer.append("&");
                       strBuffer.append(paramName);
                       strBuffer.append("=");
                       strBuffer.append(paramValue);
                       
                       session.setAttribute("params", strBuffer.toString());
                  }
             %>
            <script language="javascript" type="text/javaScript">
               showModalDialog("../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&field=TYPES=type_Model&excludeOIDprogram=ManufacturingPlanSearch:excludeMasterFeatureOfContextModel&table=FTRFeatureSearchResultsTable&Registered Suite=DMCPlanning&HelpMarker=emxhelpfullsearch&showInitialResults=false&selection=multiple&showSavedQuery=true&hideHeader=true&submitURL=../dmcplanning/CreateUtil.jsp?mode=AddExisting&context=PostAddExistingModel",850,630);
            </script>
            <%
            }
        }		
        
		// Below Block will generate the xml the need to be returned to the structure browser with the markup
        else if (strContext.equalsIgnoreCase("PostAddExistingModel")){
            com.matrixone.apps.domain.util.ENOCsrfGuard.validateRequest(context, session, request,response);
            String strSelectContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
            String strModelObjId =  emxGetParameter(request,"objectId");
            String strRelID = emxGetParameter(request,"relnID");

            String strXML = null;
            StringList strListModelTemplateIds = new StringList();
            
     if(strSelectContextObjectId==null){   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}else{
            for(int i=0;i<strSelectContextObjectId.length;i++)
            {
                StringTokenizer strTokenizer = new StringTokenizer(strSelectContextObjectId[i] , "|");
                strListModelTemplateIds.add(strTokenizer.nextToken());
            }
            try {
               com.matrixone.apps.dmcplanning.Model model = new com.matrixone.apps.dmcplanning.Model(strModelObjId);
               boolean bResult = model.connectModelTemplate(context,strListModelTemplateIds);
              %>
	          <script language="javascript" type="text/javaScript">

              //getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
              var paretToRefresh=getTopWindow().getWindowOpener().parent;
              getTopWindow().window.closeWindow();  
              paretToRefresh.location.href = paretToRefresh.location.href;
	          </script>
             <% 
             // Reload the parent window after creating if coming from Feature-Option Navigator
             } catch (Exception e) {
             session.putValue("error.message", e.getMessage());
             throw e;
         }
      }
       }
		
        // This is called from the Command Href of the Add Existing Product Revision under the Master Feature
        // in the context of Model
        // This block will check if a Product Revision can be added under master feature.
        // If the Master Feature's Feature Management Mode is Product Revision then only the Product Revision can be added.
        else if (strContext.equalsIgnoreCase("PreProcessAddExistingMasterFeature")){}       
        
        // Below Block will generate the xml the need to be returned to the structure browser with the markup
        else if (strContext.equalsIgnoreCase("PostAddExistingMasterFeature")){}
		
     }
     //took out the if statement as this canbe accomplised by passing through commnand
	//  if (strMode.equalsIgnoreCase("createManufacturingPlan"))
      
        
     
	  if (strMode.equalsIgnoreCase("createManufacturingPlanFrom"))
	     {}
	     if (strMode.equalsIgnoreCase("createManufacturingPlanFromWOContext"))
	         {}
  }
	catch(Exception e)
  {
    bIsError=true;
    if(session.getAttribute("error.message") == null){
       session.putValue("error.message", e.toString());
    }
  }// End of main Try-catck block

%>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  if (bIsError==true && (strMode.equalsIgnoreCase("create") || strMode.equalsIgnoreCase("createMultiple") || strMode.equalsIgnoreCase("editAll") || strMode.equalsIgnoreCase("editAllOptions") ||strMode.equalsIgnoreCase("copy") || strMode.equalsIgnoreCase("changeType") || strMode.equalsIgnoreCase("Form") || strMode.equalsIgnoreCase("sbEdit")) || (sbEditAction!=null && sbEditAction.equalsIgnoreCase("createMultiple") ) || ( sbEditAction!=null && sbEditAction.equalsIgnoreCase("create" )))
  {
%>
    <script language="javascript" type="text/javaScript">
     <%  if(!strMode.equalsIgnoreCase("editAll")&&!strMode.equalsIgnoreCase("editAllOptions")){
   %>
   var mp = findFrame(parent, 'pagecontent');
   mp.clicked = false;  
     // parent.frames[1].clicked = false;
      parent.turnOffProgress();
      history.back();
     <% }
       else
      {
         %>
         var footerFrameObject = findFrame(parent,"listFoot");
         footerFrameObject.location.reload();
      <%}
         %>
    </script>
<%
  }
%>
