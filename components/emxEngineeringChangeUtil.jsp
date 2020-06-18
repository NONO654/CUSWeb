<%--
  emxEngineeringChangeUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: emxEngineeringChangeUtil.jsp.rca 1.13 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $";

--%>
<!-- @quickreview T25 DJH 14:02:06 : Correction IR-269245V6R2015 Unable to create EC from large requirement specs -->

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import= "com.matrixone.apps.common.EngineeringChange"%>
<%@page import="java.util.Random"%>

<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%
    String strMode   = emxGetParameter(request, "mode");
    String strFunctionality   = emxGetParameter(request, "functionality");    
    String strOpenerFrame   = emxGetParameter(request, "openerFrame"); 
    String strTreeId = emxGetParameter(request,"jsTreeID");
    //T25 DJH: Start Correction IR-269245V6R2015
    String key = emxGetParameter(request,"key");
    String objectId ="";
    if(key==null||key.equals("")) //To keep earlier behavior
    {
    	objectId = emxGetParameter(request, "objectId");
    }
    else //To support large data (IR-269245V6R2015)
    {
    	objectId=(String)session.getAttribute(key);
    }
    if(key!= null)
    {
		  session.removeAttribute("key");
		  key="";
	  }
    //T25 DJH: End Correction IR-269245V6R2015
    String strLanguage = context.getSession().getLanguage();    
    boolean bIsError = false; 
    String splitDelegateAssignment   = emxGetParameter(request, "splitDelegateAssignment");
    String strContextObjectId[] = request.getParameterValues("emxTableRowId");
    String strAlertMessage = DomainConstants.EMPTY_STRING;
	
    //Added for ECH Bug#371267
    boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
    
    try {       
        EngineeringChange ECBean = (EngineeringChange)DomainObject.newInstance(context,DomainConstants.TYPE_ENGINEERING_CHANGE);
        FormBean formBean        = new FormBean();
        formBean.processForm(session,request);
       
        if (strTreeId == null || "null".equalsIgnoreCase(strTreeId)) {
            strTreeId = "";
        }


     if(strContextObjectId==null && !"reject".equalsIgnoreCase(strMode) && !"close".equalsIgnoreCase(strMode))
		 {   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxComponents.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}

else{

    
        // Engineering Change object id
        String strECId = "";
      
        if (strMode !=null && strMode.equalsIgnoreCase("create") || strMode.equalsIgnoreCase("apply")) {%>
           <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
           <%//Setting the latest Locale in context
            Locale Local = request.getLocale();
            context.setLocale(Local);
            
            strECId = ECBean.create(context,formBean);

            if(strMode.equalsIgnoreCase("create")) {
%>            
                <script language="javascript" type="text/javaScript">
<%
                String strMessage = "";
                // Raise Engineering Change functionality
                if (strFunctionality != null && strFunctionality.equals("RaiseECFSInstance")) {
                    strMessage = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Alert.EngineeringChangeRaised");
                    strMessage = MessageUtil.substituteValues(context, strMessage,strECId, strLanguage);
%>
                    alert("<%=XSSUtil.encodeForJavaScript(context, strMessage)%>");
					
					//Start:OEP:2013x:IR-174856V6R2013x. Modifying refresh logic.
         	        if(getTopWindow().getWindowOpener().emxEditableTable)
				    {
        	        	  if(getTopWindow().getWindowOpener().emxEditableTable.isRichTextEditor)
					      {
						    getTopWindow().getWindowOpener().refreshSCE();//structure content editor SCE
					      }
					      else
					      {
				        	getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();   // Structure Browser
					      }
				    }
         	       //END:OEP:2013x:IR-174856V6R2013x				
				    else
				    {
				         // window.parent.getTopWindow().getWindowOpener().parent.reloadTableComponent();  // List Page
						 window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
                         getTopWindow().closeWindow();
				    }
         	       	
<%
                }
                // 'Create' Engineering Change not from context
                else if (strTreeId == null || "".equals(strTreeId) || "null".equalsIgnoreCase(strTreeId)) {
%>
                    var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                    var openerFrame = "<%=XSSUtil.encodeForJavaScript(context,strOpenerFrame)%>";
                    var portalFrameObj;
                    if (openerFrame != null && openerFrame != ""){
                  	  portalFrameObj = openerFindFrame(getTopWindow(),openerFrame);
                    }
                    if (portalFrameObj) {
                      portalFrameObj.document.location.href = portalFrameObj.document.location.href;
                    }
          //Begin of modify by Infosys for bug 297901, 04/19/2005
           //nextgenUi Changes need to take out "mode=insert" as this independent of context
                   else if (contentFrameObj){
           //XSSOK
          contentFrameObj.document.location.href="../common/emxTree.jsp?objectId=<%=strECId%>";
          } else {
            if(getTopWindow().getWindowOpener().getTopWindow().refreshTablePage) {  
              getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
            } else {  
              getTopWindow().getWindowOpener().getTopWindow().location.href = getTopWindow().getWindowOpener().getTopWindow().location.href;
            }
          }
<%
                } else {
    /*Begin of add by infosys for Bug # 298000 on 5/18/2005*/
                String strSelectRelId = "to["+DomainConstants.RELATIONSHIP_RESOLVED_TO+"].id";
                DomainObject domObjeEC = DomainObject.newInstance(context,strECId);
                String strRelId = domObjeEC.getInfo(context,strSelectRelId);
    /*End of add by infosys for Bug # 298000 on 5/18/2005*/
%>
          var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
          var openerFrame = "<%=XSSUtil.encodeForJavaScript(context,strOpenerFrame)%>";
          var portalFrameObj;
          if (openerFrame != null && openerFrame != ""){
        	  portalFrameObj = openerFindFrame(getTopWindow(),openerFrame);
          }else{
        	  portalFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"portalDisplay");
          }
          if (portalFrameObj) {
            portalFrameObj.document.location.href = portalFrameObj.document.location.href;
          }
          else if (contentFrameObj){
          /*Modified by infosys for Bug # 298000 on 5/18/2005*/
          contentFrameObj.document.location.href="../common/emxTree.jsp?objectId=<%=strECId%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context, strTreeId)%>&relId=<%=XSSUtil.encodeForURL(context, strRelId)%>";
          } else {
            if(getTopWindow().getWindowOpener().getTopWindow().refreshTablePage) {  
              getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
            } else {  
              getTopWindow().getWindowOpener().getTopWindow().location.href = getTopWindow().getWindowOpener().getTopWindow().location.href;
            }
          }
          //End of modify by Infosys for bug 297901, 04/19/2005
<%
                }
%>
                
                window.closeWindow();
                </script>
<%
                
            } 
            //when Apply button is pressed on Create Dialog page
            else if (strMode.equalsIgnoreCase("apply")) {
%>
                <script language="javascript" type="text/javaScript">
                <!-- hide JavaScript from non-JavaScript browsers --> 
                var portalFrameObj;
                var openerFrame = "<%=XSSUtil.encodeForJavaScript(context,strOpenerFrame)%>";
                if (openerFrame != null && openerFrame != ""){
              	  portalFrameObj = openerFindFrame(getTopWindow(),openerFrame);
                }
                if (portalFrameObj) {
                    portalFrameObj.document.location.href = portalFrameObj.document.location.href;
                }
                var pc = findFrame(parent, 'pagecontent');
                pc.clicked = false;         
                parent.turnOffProgress();
                </script>
                
<%
            }

        } 
        //if Remove Selected Command link on List page is pressed
        else if (strMode.equalsIgnoreCase("disconnect")) {
        	%>
            <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
            <%
            //storing table row ids in a String array
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            Map mapObjIdRelId       = EngineeringChange.getObjectIdsRelIds(strTableRowIds);

            //storing Object ids in a String array
            String[] arrObjIds = (String[])mapObjIdRelId.get("ObjId");
            //storing relationship ids in a String array
            String[] arrRelIds = (String[])mapObjIdRelId.get("RelId");

            //Retrieves context Object Id
            String strParentId = emxGetParameter(request, "objectId");
            boolean bIsRemoved = ECBean.remove(context,arrRelIds,strParentId);
%>
            <script language="javascript" type="text/javaScript">
                //refreshContentPage();
                refreshTreeDetailsPage();
			</script>
<%
        }
        //when Close button is pressed on Close Dialog page
        else if (strMode.equalsIgnoreCase("close") ) {
        	%>
            <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
            <%        	
            //getting the context object id from EC Dialog Page
            objectId         = emxGetParameter(request,"objectId");

            int iClosed      = 0;

            //Calling the close Method of EngineeringChange.java
            String strClosed = ECBean.close(context,formBean);
            if ( strClosed.equalsIgnoreCase(FrameworkUtil.lookupStateName(context, EngineeringChange.POLICY_ENGINEERING_CHANGE_STANDARD,EngineeringChange.EC_STATE_CLOSE)) ) {
 %>
              <script language="javascript" type="text/javaScript">

                   var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                   contentFrameObj.location.href=contentFrameObj.location.href;
                   window.closeWindow();
              </script>
 <%
            }
        }
        //when 'Reject' button is pressed Reject Dialog page
        else if (strMode.equalsIgnoreCase("reject") ) {
        	%>
            <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
            <%        	
            //getting the context object id from EC Dialog Page
            objectId    = emxGetParameter(request,"objectId");
            int iClosed = 0;
            String strRejected =  DomainConstants.EMPTY_STRING;
            //IR-025137V6R2011 - Beging : Added try/catch as the page wasn't closing
            try
            {
                //Calling the reject  Method of EngineeringChange.java
                strRejected = ECBean.reject(context,formBean);
                
            }catch(Exception exp)
            {
            	strAlertMessage = exp.getMessage();
            	strAlertMessage = strAlertMessage.replaceAll("\\n","");
            	if(!"".equals(strAlertMessage)){
            	   %>    
            	       <script language="javascript" type="text/javaScript">
            	           alert("<%=strAlertMessage%>");
                           var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                           contentFrameObj.location.href=contentFrameObj.location.href;
                           window.closeWindow();
            	       </script>
            	    <%
            }
            //IR-025137V6R2011 - End	
            }
            if (strRejected.equalsIgnoreCase(FrameworkUtil.lookupStateName(context, EngineeringChange.POLICY_ENGINEERING_CHANGE_STANDARD,EngineeringChange.EC_STATE_REJECT))) {
 %>
              <script language="javascript" type="text/javaScript">

                  var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                  contentFrameObj.location.href=contentFrameObj.location.href;
                 window.closeWindow();
              </script>
 <%
            }
        }
        //if Delete Selected Command link on List page is pressed
        else if(strMode.equalsIgnoreCase("delete")) {
        	%>
            <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
            <%        	
            //getting table row ids from the list page
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            String strObjectIds[]   = null;
            //getting object ids for the corresponding row ids
            strObjectIds            = ECBean.getObjectIds(strTableRowIds);
            boolean bIsDeleted      = false;
            //deleting objects from database by calling deleteObjects in EngineeringChange.java
            bIsDeleted              = ECBean.deleteObjects(context,strObjectIds,true);

            /* for deleting an object which is in a parent context,
             * delete the object from list page as well as from tree category
             */
            if (!DomainConstants.EMPTY_STRING.equals(strTreeId)) {
%>
                <script language="javascript" type="text/javaScript">
<%
                for(int i=0;i<strObjectIds.length;i++) {
%>
                    var tree = getTopWindow().trees['emxUIDetailsTree'];
                    tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strObjectIds[i])%>");
<%
                }
%>
                  refreshTreeDetailsPage();
                </script>
<%

            }
            //for deleting an object from MyDesk list page
            else {
%>
              <script language="javascript" type="text/javaScript">
            //IR-091956V6R2012 
              //refreshContentPage();
              refreshTablePage();
              </script>

<%
            }
        }
        else if (strMode.equalsIgnoreCase("addAssignee"))
        {
          String strTargetURL = null;
			if(splitDelegateAssignment!=null && splitDelegateAssignment.equalsIgnoreCase("splitDelegateAssignment"))// If splitDelegateAssignment is splitDelegateAssignment (Split Delegate Assignment Functionality), we go in here
			{
				String[] strTableRowIds1 = emxGetParameterValues(request, "emxTableRowId");

				// Getting the ObjectIds & RelIds im a Map
				Map mapObjIdRelId1       = EngineeringChange.getObjectIdsRelIds(strTableRowIds1);

				//storing Object ids in a String array
				String[] arrObjIds1 = (String[])mapObjIdRelId1.get("ObjId");
				StringList arrObjIds1List = new StringList();

				//storing relationship ids in a String array
				String[] arrRelIds1 = (String[])mapObjIdRelId1.get("RelId");

				//Retrieves context Object Id
				String strParentId1 = emxGetParameter(request, "objectId");

				// Initializing StringLists for ObjectIds and RelIds for further processing.
				StringList slArrObjIds = new StringList();
				StringList slArrRelIds = new StringList();

				if(strTableRowIds1.length>0)
				{
					for (int j=0; j<strTableRowIds1.length; j++)
					{
						//Appending Object Ids and RelIds to the StringLists
						slArrObjIds.add(arrObjIds1[j]);
						slArrRelIds.add(arrRelIds1[j]);
					}
				}
				strTargetURL = "emxCommonSearch.jsp?strParentId="+XSSUtil.encodeForURL(context, strParentId1)+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds;
			}
			else
			{
          String timeStamp = emxGetParameter(request, "timeStamp");

          HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
        

         //  String strParentId=(String)emxGetParameter(request,"productID");
// START 
	
  //String languageStr = request.getHeader("Accept-Language");

			String[] strTableRowIds1 = emxGetParameterValues(request, "emxTableRowId");

                        // If the emxTableRowId returned is Null(Add Existing Functionality), we go in here
                        if(strTableRowIds1 == null)
                        {
                           String strParentId2=(String)requestMap.get("objectId");    
                           strTargetURL = "emxCommonSearch.jsp?strParentId="+XSSUtil.encodeForURL(context, strParentId2);
                          
                        }
                        else // If the emxTableRowId returned is not Null (Delegate Assignment Functionality), we go in here
                        {

			// Getting the ObjectIds & RelIds im a Map
			Map mapObjIdRelId1       = EngineeringChange.getObjectIdsRelIds(strTableRowIds1);

				//storing Object ids in a String array
				String[] arrObjIds1 = (String[])mapObjIdRelId1.get("ObjId");
				StringList arrObjIds1List = new StringList(); 

				//storing relationship ids in a String array
				String[] arrRelIds1 = (String[])mapObjIdRelId1.get("RelId");
			//					StringList arrObjIds1List = new StringList(); 

				//Retrieves context Object Id
				String strParentId1 = emxGetParameter(request, "objectId");
				
				// Initializing StringLists for ObjectIds and RelIds for further processing. 
				StringList slArrObjIds = new StringList();
				StringList slArrRelIds = new StringList();
	
			if(strTableRowIds1.length>0)
			{
				for (int j=0; j<strTableRowIds1.length; j++)
				{
					//Appending Object Ids and RelIds to the StringLists
					slArrObjIds.add(arrObjIds1[j]);
					slArrRelIds.add(arrRelIds1[j]);
				}	
%>

 <%
			}

           String strParentId=(String)requestMap.get("productID");
           strTargetURL = "emxCommonSearch.jsp?strParentId="+XSSUtil.encodeForURL(context, strParentId)+"&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds;
    }
				}
                context.shutdown();
	%>
	<!-- //XSSOK -->
            <jsp:forward page="<%=strTargetURL%>"/>
<%
          
        } 
        else if (strMode!=null && strMode.equalsIgnoreCase("disconnectAssignee")) 
        {
        	%>
            <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
            <%
            //get the table row ids of the test case objects selected
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            //get the object ids of the tablerow ids passed
            //get the relationship ids of the table row ids passed
            Map relIdMap=EngineeringChange.getObjectIdsRelIds(arrTableRowIds);
            String[] arrRelIds = (String[]) relIdMap.get("RelId");
            String[] strObjectIds = (String[]) relIdMap.get("ObjId");
            //Call the removeObjects method of ECBean to remove the selected object
            boolean bFlag = ECBean.removeAssignee(context,arrRelIds,strObjectIds);

            //refresh the tree after disconnect
%>
            <script language="javascript" type="text/javaScript">
<%
            for(int i=0;i<strObjectIds.length;i++)
            {
%>
                //<![CDATA[
                var tree = getTopWindow().trees['emxUIDetailsTree'];
                tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strObjectIds[i])%>");
                 //]]>
<%
            }
%>
            refreshTreeDetailsPage();
            //]]>
           </script>
<%
        }
        else if (strMode.equalsIgnoreCase("validateRaiseEC")) {
            //getting table row ids from the list page
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            String strSymbRelName = emxGetParameter(request, "srcDestRelName");
            String strObjectIds[]   = null;
            if (strTableRowIds != null && !"null".equals(strTableRowIds)) {
                //getting object ids for the corresponding row ids
                strObjectIds            = ECBean.getObjectIds(strTableRowIds);

                StringList listSelect = new StringList(1);
                listSelect.addElement(DomainConstants.SELECT_TYPE);

                MapList mapSelectedObjTypes = DomainObject.getInfo(context,strObjectIds,listSelect);
                Iterator typeMapItr = mapSelectedObjTypes.iterator();
                HashMap typeMap         = null;
                boolean bSupportedType = false;
                String strType = "";

                StringList supportedTypesList = null;
                supportedTypesList = EngineeringChange.getSupportedTypes(context,strSymbRelName,false,true);
                while(typeMapItr.hasNext()) {
                    typeMap = (HashMap)typeMapItr.next();
                    strType = (String)typeMap.get(DomainConstants.SELECT_TYPE);
                    if(strType != null && supportedTypesList.contains(strType) ) {
                        bSupportedType = true;
                    } else {
                        bSupportedType = false;
                        break;
                    }
                }
%>
                <script language="javascript">
<%
                if (!bSupportedType) {
%>
                    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.NotSupportedWithEC</emxUtil:i18nScript>");
                    getTopWindow().refreshTablePage();
<%
                } else {
                    StringBuffer sQueryString = new StringBuffer();
                    StringBuffer tmpStrBuf = new StringBuffer();
                    for(int i=0; i<strTableRowIds.length; i++) {
                        tmpStrBuf.append(",");
                        tmpStrBuf.append(strTableRowIds[i]);
                    }
                    // Remove the first comma seperator
                    tmpStrBuf.deleteCharAt(0);

                    Enumeration eNumParameters = emxGetParameterNames(request);
                    while( eNumParameters.hasMoreElements() ) {
                        String strParamName = (String)eNumParameters.nextElement();
                        if(!strParamName.equals("emxTableRowId")) {
                            String strParamValue = emxGetParameter( request,  strParamName);
                            sQueryString.append("&" + strParamName + "=" + strParamValue);
                        }
                    }
                   //START:OEP:2013x:IR-174856V6R2013x. set tableRowID in session
                	long number = new Random(System.currentTimeMillis()).nextLong();
                	key = "EC" + System.currentTimeMillis() + "_" + number;
                	session.setAttribute(key, tmpStrBuf.toString());
%>
         </script>
                  <body>   
                    <form name="FTREngineeringChangeSplitReplace" method="post">
                       <script language="Javascript">
                       //XSSOK
                           document.FTREngineeringChangeSplitReplace.action="../components/emxCommonFS.jsp?functionality=RaiseECFSInstance&suiteKey=Components&srcDestRelName=relationship_ECAffectedItem&connectAtFrom=true&key="+"<%=key%>";
                            document.FTREngineeringChangeSplitReplace.submit();
                        </script>     
                  </form>
                 </body>   
<%
                }
				//END:OEP:2013x:IR-174856V6R2013x
%>
 
<%
            }          
        }
        //////////////////////////////////////////////////////////
        // Autonomy search integration for Add Assignee, Affected Item, Impact Analysis,
        // Implemented Items and Resolved Items into Engineering Change
        //
        else if ("addAssigneeSubmit".equalsIgnoreCase(strMode) 
                || "AddExistingECAffectedItems".equalsIgnoreCase(strMode)
                || "AddExistingECImpactAnalysis".equalsIgnoreCase(strMode)
                || "AddExistingECImplementedItems".equalsIgnoreCase(strMode)
                || "AddExistingECSatisfiedItems".equalsIgnoreCase(strMode)) {
        	%>
            <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
            <%
              
            //R210:IR-059339V6R2011x
			DomainObject parentObject;
            String strIsTo = emxGetParameter(request, "isTo");
            String strRelSymbolic = emxGetParameter(request, "srcDestRelName");
        	String strRelationshipName = PropertyUtil.getSchemaProperty(context, strRelSymbolic);
        	
        	String emxTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        	String strTableRowId = "";
        	StringList slEmxTableRowId = new StringList();
        	
        	// From autonomy search the emxTableRowIds are submitted as
        	// <object id>|<parent id>|1,0
        	if(emxTableRowIds != null) {
			for (int i = 0; i < emxTableRowIds.length; i++) {
			    strTableRowId = emxTableRowIds[i];
			    slEmxTableRowId = FrameworkUtil.split(strTableRowId, "|");
			    if (slEmxTableRowId.size() > 0) {
				strTableRowId = (String)slEmxTableRowId.get(0);
			     if(objectId != null) {
			    	 StringTokenizer token = new StringTokenizer(objectId,",");
			             while (token.hasMoreTokens())
			             {
			                objectId = token.nextToken().trim();
			                parentObject = DomainObject.newInstance(context, objectId);
				if ("false".equalsIgnoreCase(strIsTo)) {
					com.matrixone.apps.domain.DomainRelationship.connect(context, 
						DomainObject.newInstance(context, strTableRowId), 
						strRelationshipName, 
						parentObject);
				}
				else {
					com.matrixone.apps.domain.DomainRelationship.connect(context, 
						parentObject, 
						strRelationshipName, 
						DomainObject.newInstance(context, strTableRowId));
							}
			             }
				}
			    }
			}
        	}
            
%>
			<script language="javascript">
			var openerParent = findFrame(getTopWindow(), "detailsDisplay") ? findFrame(getTopWindow(), "detailsDisplay") : findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");

			if(openerParent.emxEditableTable)
			{
				if(openerParent.emxEditableTable.isRichTextEditor)
				{
					openerParent.refreshSCE();
				}
				else // Structure Browser
				{
					if(openerParent.getRequestSetting('isIndentedView') != 'true' )
					{
						openerParent.editableTable.loadData();
					}
					openerParent.emxEditableTable.refreshStructureWithOutSort(); 
				}
		 	}
			else
			{
				//getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
				openerParent.location.href = openerParent.location.href;
			}
			if(getTopWindow().location.href.indexOf("emxNavigator.jsp")==-1) {
				getTopWindow().close();
			}
			//-->
			</script>
<%            
        }
        //
        //////////////////////////////////////////////////////////
        
        //Added for the ECH Bug#371267 - because triggers are off in case of close and reject on EC object
        if(isECHInstalled) {
            if ("close".equalsIgnoreCase(strMode) || "reject".equalsIgnoreCase(strMode)) {
				DomainObject ecObj = new DomainObject(objectId);
				matrix.util.StringList delvList = ecObj.getInfoList(context, "to["+DomainConstants.RELATIONSHIP_TASK_DELIVERABLE+"].from.id");
				
				HashMap paramMap = new HashMap();
				paramMap.put("objectId", objectId);
				paramMap.put("isBGProcess", "false");
				paramMap.put("relatedObjectIds", delvList);
				
				JPO.invoke(context, "emxChangeTask", null, "promoteRelatedObjects", JPO.packArgs(paramMap));
            }
        }
        //End Bug#371267
        
    } 
    } catch(Exception e){        
        bIsError=true;
        // Modified for bug no. IR-056437V6R2011x
        session.putValue("error.message", e.getMessage());
        String message ="";
        if(e.getMessage().indexOf("fromconnect") >0 || e.getMessage().indexOf("toconnect") >0 ){

             message=EnoviaResourceBundle.getProperty(context,
                                           "emxComponentsStringResource",
                                           context.getLocale(),
                                           "emxComponents.Common.ConnectObjectFailed");
        }else if (e.getMessage().indexOf("fromdisconnect") >0 || e.getMessage().indexOf("todisconnect") >0)
        {
            message=EnoviaResourceBundle.getProperty(context,
                                          "emxComponentsStringResource",
                                          context.getLocale(),
                                          "emxComponents.Common.DisconnectObjectFailed");
        }else{
        	message = e.getMessage();
        }
        session.putValue("error.message", message);		
    }
%> 
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    if ( bIsError==true && (strMode.equalsIgnoreCase("create") || strMode.equalsIgnoreCase("apply") || strMode.equalsIgnoreCase("close") || strMode.equalsIgnoreCase("reject")) ) {
%>
        <script language="javascript" type="text/javaScript">
        var pc = findFrame(parent, 'pagecontent');
        pc.clicked = false;         
        parent.turnOffProgress();
           
        </script>
<%
    }
%>
