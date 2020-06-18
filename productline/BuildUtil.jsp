
<%--
  BuildUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/BuildUtil.jsp 1.5.2.3.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

 --%>

<%-- Include Files --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%--Page directives for imports --%>
<%@page import = "com.matrixone.apps.productline.Build"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%-- START - Added for Bug No. IR-046337V6R2011 --%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%-- END - Added for Bug No. IR-046337V6R2011 --%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>

<%@page import = "com.matrixone.apps.productline.Model"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.Map"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>

<%
String strDynamicEvaluationForPrefix = emxGetParameter(request, "mode");
String inputStr = emxGetParameter(request, "inputStr");
String prodId =  emxGetParameter(request, "productId");
String strLanguage = request.getHeader("Accept-Language");

boolean validationMsg = false;
if(strDynamicEvaluationForPrefix != null && strDynamicEvaluationForPrefix.equalsIgnoreCase("checkModelPrefix") && inputStr!= null && !"".equalsIgnoreCase(inputStr))
{
    out.clear();
    Model model = null;
    String orgPrefix = inputStr;
    if(prodId != null && !"".equalsIgnoreCase(prodId))
    {
        model = new Model(prodId);
        
        orgPrefix = model.getAttributeValue(context, ProductLineConstants.ATTRIBUTE_PREFIX);         
    }
    else
    {
        orgPrefix = "";
        model = new Model();
    }
    if(!orgPrefix.equalsIgnoreCase(inputStr))
    {
        validationMsg = model.checkModelPrefix(context, inputStr);
    }
    else
    {
        validationMsg=true;
    }
   
    out.write("validationMsg="+validationMsg);
    
    out.flush();
}
%>
<%!
    // This method returns the value of the system property
    private static String getSystemProperty(ServletContext application, String strKey)
    {
        String strRetVal = null;
		try {
			strRetVal = FrameworkProperties.getProperty(strKey);
        } catch (Exception e) {
        	//Do nothing
        }
        return strRetVal;
    }


    // This method returns the value of the application property
    public static String getApplicationProperty(ServletContext application, String strSuiteKey, String strKey)throws FrameworkException 
    {
        String strRetVal = null;
  		try {
  			strRetVal = FrameworkProperties.getProperty(strKey);
        } catch (Exception e) {
        	//Do nothing
        }
        return strRetVal;
    }
%>



<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<html>
  <script language="javascript" src="../common/scripts/emxUICore.js"></script>
  <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>

<%
   //Instantiating the Build bean
    Build buildBean = (Build)DomainObject.newInstance(context,ProductLineConstants.TYPE_BUILDS,"PRODUCTLINE");
     String strMode = emxGetParameter(request,"mode");
    String strJsTreeID = emxGetParameter(request, "jsTreeID");
    String strCommandSource = emxGetParameter(request, "commandSource");
    boolean bIsError = false;
    try
    {
        //Create objects
        if (strMode.equalsIgnoreCase("create"))
        {
            //Instantiating the FormBean
            com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();

            //Processing the form using FormBean.processForm
            formBean.processForm(session,request);
            //Setting the latest Locale in context
                             Locale Local = request.getLocale();
                            context.setLocale(Local);
            //Calling the createBuild Method of Build.java
            String strNewObjId = buildBean.create(context,formBean);
              /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
              String strObjId = emxGetParameter(request, "objectId");
              String strRelName = buildBean.getRelName(context,strObjId);
              String strSelectRelId = "to["+strRelName+"].id";
              DomainObject domObjBuild = DomainObject.newInstance(context,strNewObjId);
              String strRelId = domObjBuild.getInfo(context,strSelectRelId);
              /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
            if (strCommandSource.equalsIgnoreCase("actions"))
            {
%>
<!--Javascript for opening the tree with the object Id of the object that has been created-->
  <script language="javascript" type="text/javaScript">
    var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
   //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
    contentFrameObj.document.location.href= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strJsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
	//Commented the for Bug 349517
	/* var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
    topFrameObj.window.focus();
	*/  
    parent.window.closeWindow();

  </script>
<%
            }
            else if (strJsTreeID == null || "".equals(strJsTreeID) || "null".equals(strJsTreeID))//If jsTreeID = "" then the Build is being created from nouns tab
            {
%>
<!--Opening the tree when creating form Nouns tab-->
  <script language="javascript" type="text/javaScript">

    var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
     //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
    contentFrameObj.document.location.href= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strJsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
	//Commented the for Bug 349517
/*    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
    topFrameObj.window.focus();
  */  parent.window.closeWindow();
  </script>
 <%
            }
            else
            {
%>
<!--Opening the tree when creating from under a context-->
  <script language="javascript" type="text/javaScript">
    var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
   //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
    contentFrameObj.document.location.href= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,strJsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
	//Commented the for Bug 349517
/*    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
    topFrameObj.window.focus();
  */  parent.window.closeWindow();
  </script>
<%
            }
        }
        //Delete objects
        else if(strMode.equalsIgnoreCase("delete"))
        {
        	
            try
            {
            //Instantiating ProductLineCommon.java
            ProductLineCommon commonBean = new ProductLineCommon();

            //Instantiating ProductLineUtil.java bean
            ProductLineUtil utilBean = new ProductLineUtil();

            //Getting the table row ids of the selected objects from the request
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            //Getting the object ids from the table row ids
            String arrObjectIds[] = null;
            arrObjectIds = utilBean.getObjectIds(arrTableRowIds);

            //Calling the deleteObjects() method of ProductLineCommon.java
            boolean bIsDeleted = false;
            //bIsDeleted = commonBean.deleteObjects(context,arrObjectIds,true);
            
            // Added for Frozen State Mapping for Product Function
            String objectId =  emxGetParameter(request, "objectId");
            StringList lstPRDChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
            Map productMap = new HashMap();
            if(ProductLineCommon.isNotNull(objectId)){
            StringList listSelect = new StringList();
            listSelect.add(DomainConstants.SELECT_TYPE);
            listSelect.add(DomainConstants.SELECT_CURRENT);
            DomainObject domObj = DomainObject.newInstance(context, objectId);
                productMap = domObj.getInfo(context, listSelect);
            }
            String  strFrozenStates = EnoviaResourceBundle.getProperty(context, "Configuration.FrozenState.type_Products");
       		String  strStates       = strFrozenStates.replaceAll("policy_Product.state_", "");
       		String[] arrFrozenStates    = strStates.split(",");
       		List listFrozenStates       = new ArrayList();
       		listFrozenStates = Arrays.asList(arrFrozenStates);
       		// Added for Frozen State Mapping for Product Function
            
            if(lstPRDChildTypes.contains((String) productMap.get(DomainConstants.SELECT_TYPE)) && listFrozenStates.contains((String) productMap.get(DomainConstants.SELECT_CURRENT))){
            	String strAlertString = "emxProduct.Alert.DeleteUnits";
                String strErrorMessage = i18nStringNowUtil(strAlertString,bundle,strLanguage);
                throw new FrameworkException(strErrorMessage);
            }else{
                bIsDeleted = Build.deleteBuilds(context,arrObjectIds);
            }
            	
            //Added to refresh only the content page if there is no tree available
		    if (strJsTreeID != null && !strJsTreeID.equals("") && !strJsTreeID.equals("null")) {
%>
  <script language="javascript" type="text/javaScript">

<%
				for(int i=0;i<arrObjectIds.length;i++){
%>

		    var tree = getTopWindow().trees['emxUIDetailsTree'];		    
		    tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
<%			
				}
%>
        	refreshTreeDetailsPage();
        	refreshTablePage();
		</script>
<%
      		} else {
%>
	  	<script language="javascript" type="text/javaScript">
	  		  //refreshTablePage();
			//refreshContentPage();
				//Modify for PLC Categories consolidation
				var detailsDisplay = findFrame(getTopWindow(),"PLCProductBuildTreeCategory");
				if (detailsDisplay == null) {
					detailsDisplay = findFrame(getTopWindow(),"detailsDisplay");                        
		        }
				if (detailsDisplay == null) {
					detailsDisplay = findFrame(getTopWindow(),"content");                        
		        }
				detailsDisplay.location.href = detailsDisplay.location.href;
  </script>
<%
        }
            }catch(Exception e){
                //IR-023633 - Starts
                throw e;
                //IR-023633 - End
            }
        //Remove objects
  		}else if(strMode.equalsIgnoreCase("disconnect"))
        {
  			// Added for Bug No. IR-046337V6R2011
  			String removeType = emxGetParameter(request, "remType");//remType=features
  			
  		  try
          {
            //Instantiating ProductLineCommon.java
            ProductLineCommon commonBean = new ProductLineCommon();

            //Instantiating ProductLineUtil.java
            ProductLineUtil utilBean = new ProductLineUtil();

            //Getting the table row ids of the selected objects from the request
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            String[] arrObjectIds = utilBean.getObjectIds(arrTableRowIds);

            //Getting the object ids from the table row ids
            Map relIdMap = utilBean.getObjectIdsRelIds(arrTableRowIds);

            //Obtaining the relationship ids from the Map returned by the previous step
            String[] arrRelIds = (String[]) relIdMap.get("RelId");

            // START - Added/Modified for Bug No. IR-046337V6R2011
            if(removeType!=null && !removeType.equals("") && removeType.equals("features"))
            {
            	DomainRelationship.disconnect(context, arrRelIds);
            	%>
            	<script language="javascript" type="text/javaScript">
            	window.parent.location.href=window.parent.location.href;
            	</script>
            	<%
            }else
            {
            //Calling the removeObjects() method of ProductLineCommon.java
            boolean bIsRemoved = false;
            //Below code modified for IR-033143
            ContextUtil.pushContext(context);
            Map lstObjects = commonBean.removeBuildObjects(context,arrRelIds,arrObjectIds);
            String strBuildMsg =  EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.RemoveBuildsMessage",strLanguage);
            String strBuildNames = (String)lstObjects.get("BuildNames");
            String[] strRemovedObjIds = (String[])lstObjects.get("ObjectIds");
            //End of Modification for IR-033143
            //Added for BUG: 373978
            commonBean.removePrefix(context,arrObjectIds);
            //Added for 2011 UNT feature.
            commonBean.disconnectBuildsFromMfgPlans(context,arrObjectIds);
            ContextUtil.popContext(context);
%>
  <script language="javascript" type="text/javaScript">
  //Below code added for IR-033143
  var strBuildNames = "<%=XSSUtil.encodeForJavaScript(context,strBuildNames)%>";
  var strMsg = "<%=XSSUtil.encodeForJavaScript(context,strBuildMsg)%>";
  if(strBuildNames!=null && strBuildNames!="") {
  	alert(strMsg+strBuildNames);
  }
  //End 
<%
            for(int i=0;i<strRemovedObjIds.length;i++)
            {
%>
  var tree = getTopWindow().trees['emxUIDetailsTree'];
    if( tree.getSelectedNode()!=null)
    {
    tree.getSelectedNode().removeChild("<%=XSSUtil.encodeForJavaScript(context,strRemovedObjIds[i])%>");
    }
<%
            }
%>
// refreshTreeDetailsPage();
				//Modify for PLC Categories consolidation
				var detailsDisplay = findFrame(getTopWindow(),"PLCProductBuildTreeCategory");
				if (detailsDisplay == null) {
					detailsDisplay = findFrame(getTopWindow(),"detailsDisplay");                        
		        }
				detailsDisplay.location.href = detailsDisplay.location.href;
  </script>
<%
            }//END if-else 
            // END - Added/Modified for Bug No. IR-046337V6R2011
        }catch(Exception e){} 
  		  
        //Add Existing
        }else if (strMode.equalsIgnoreCase("addExisting"))
        {
            //Getting the parent objectId
            String strObjectId = emxGetParameter(request, "objectId");

            //Getting the parent type by calling the getType method of Build.java
            String strType = buildBean.getType(context,strObjectId,"type");
%>
  <form name="ShowTable" method="post" >
    <input type="hidden" name="HiddenField" >
  </form>
<%
            //If type is Hardware product
            if (strType.equalsIgnoreCase("Hardware Product") == true)
            {
%>
  <!--Javascript to call emxTable.jsp with top action bar as PLCHardwareBuildTopActionBar-->
  <script language="javascript" type="text/javaScript">
    var formName = document.ShowTable;
  </script>
<%
            }
            else if (strType.equalsIgnoreCase("Software Product") == true)
            {
%>
  <!--Javascript to call emxTable.jsp with top action bar as PLCSoftwareBuildTopActionBar  -->
  <script language="javascript" type="text/javaScript">
      var formName = document.ShowTable;
  </script>
<%
            }
        }
        //To upload External Files
        else if(strMode.equalsIgnoreCase("uploadExternal"))
        {
            String objectId = emxGetParameter(request,"objectId");
            String strObjectAction = emxGetParameter(request,"objectAction");
            String strJPOName = emxGetParameter(request,"JPOName");
            String strParentRelName = emxGetParameter(request,"parentRelName");
            String strAppDir = emxGetParameter(request,"appDir");
            String strAppName =emxGetParameter(request,"appName");
            String strShowDesc =emxGetParameter(request,"showDescription");
            String strFIleChange = emxGetParameter(request,"allowFileNameChange");
            String strShowFormat = emxGetParameter(request,"showFormat");
            String strOverride = emxGetParameter(request,"override");

            StringBuffer uploadURLStrBuff=new StringBuffer(80);
            uploadURLStrBuff.append("../components/emxCommonDocumentPreCheckin.jsp?parentId=" + objectId);
            uploadURLStrBuff.append("&parentRelName=" + XSSUtil.encodeForURL(context,strParentRelName));
            uploadURLStrBuff.append("&appDir="+XSSUtil.encodeForURL(context,strAppDir) + "&appName="+XSSUtil.encodeForURL(context,strAppName));
            uploadURLStrBuff.append("&showDescription=" + XSSUtil.encodeForURL(context,strShowDesc) + "&allowFileNameChange=" + XSSUtil.encodeForURL(context,strFIleChange));
            uploadURLStrBuff.append("&showFormat=" + XSSUtil.encodeForURL(context,strShowFormat));
            uploadURLStrBuff.append("&JPOName=" +  XSSUtil.encodeForURL(context,strJPOName));
            uploadURLStrBuff.append("&objectAction=" + XSSUtil.encodeForURL(context,strObjectAction));
            uploadURLStrBuff.append("&defaultType=" + "type_SoftwareDistribution");

%>
            <script>
               window.location.href ="<%=XSSUtil.encodeForJavaScript(context,uploadURLStrBuff.toString())%>";
                
            </script>


<%
        }
     //Delete Distributions objects
        else if(strMode.equalsIgnoreCase("deleteDistribution"))
        {

            //Instantiating ProductLineUtil.java bean
            ProductLineUtil utilBean = new ProductLineUtil();

            //Getting the table row ids of the selected objects from the request
            String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");

            //Getting the object ids from the table row ids
            String arrObjectIds[] = utilBean.getObjectIds(arrTableRowIds);


            //Calling the deleteObjects() method of Build.java
            buildBean.deleteObjects(context, arrObjectIds, false);

            for(int i=0;i<arrObjectIds.length;i++)
          {
%>

  <script language="javascript" type="text/javaScript">
  <!-- hide JavaScript from non-JavaScript browsers -->
  //<![CDATA[

  var tree = window.getTopWindow().objDetailsTree;
  tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");

  //]]>
  </script>
<%
          }
%>
 <!--Javascript to reload the tree-->
  <script language="javascript" type="text/javaScript">
    refreshTreeDetailsPage();
  </script>
<%
        }
        else if(strMode.equalsIgnoreCase("refreshTree"))
        {
            Enumeration eNumParameters = emxGetParameterNames(request);
            while( eNumParameters.hasMoreElements() )
            {
              String strParamName = (String)eNumParameters.nextElement();
            }
                        
            String strBuildOID = emxGetParameter(request,"objectId");
            String strOldProductOID = emxGetParameter(request,"Product");
            String strNewProductOID = emxGetParameter(request,"ProductOID");
           
            if(!strOldProductOID.equals(strNewProductOID))
           {
              %>
              <script language="javascript" type="text/javaScript">
				  
		var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
        contentFrameObj.document.location.href= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strBuildOID)%>&mode=insert";  
         parent.window.closeWindow();

               </script>

              <%
			//Below code added for IR- 034075
             }else{  %>   
              <script language="javascript" type="text/javaScript">
            	getTopWindow().getWindowOpener().getTopWindow().refreshTreeDetailsPage();
              </script>
            <%
             }
            //End of modification - IR-034075
           }
   
    }
    catch(Exception e)
    {
        //Forming the alert String
        bIsError = true;
        //Adding the Error message to the session
        session.putValue("error.message", e.getMessage());
   }
%>
  
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  if (bIsError==true && strMode.equalsIgnoreCase("create"))
  {
%>
    <script language="javascript" type="text/javaScript">


    var pc =findFrame(parent,"pagecontent");
    pc.clicked = false;
    parent.turnOffProgress(); 
      history.back();
    </script>
<%
  }
%>
</html>
