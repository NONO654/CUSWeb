<%--
  ProductUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ProductUtil.jsp 1.7.2.4.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.productline.*"%>
<%@page import="com.matrixone.apps.common.Search"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>


<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="java.util.StringTokenizer"%>

  <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIModal.js"></script>


<%
  String strMode = "";
  boolean result = true;
  boolean bIsError = false;
  com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
  try{

    //Get the mode called
    strMode = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request, "jsTreeID");
    String objectId = emxGetParameter(request, "objectId");
    String productId = "";
    
    // For HDM Start
    String vcDocumentType = emxGetParameter(request, "vcDocumentType");
    String strPath = emxGetParameter(request, "path");
    String sFormat = emxGetParameter(request, "format");
    String strStore = emxGetParameter(request, "server");
    String strSelector = emxGetParameter(request, "selector");
    sFormat = "generic";

    if(sFormat==null || "null".equals(sFormat) || " ".equals(sFormat) || "".equals(sFormat)) {
        sFormat = "generic";
    }
    sFormat = "generic";
    // For HDM End

    // Added for FCA Start
    boolean isFCAInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionForecastAnalysis",false,null,null);
    // Added for FCA End
    
    /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
    String strRelId= "";
    String strSelectRelId = "";
    /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/

    Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");

    if (strMode.equalsIgnoreCase("createProduct"))
    {
        Model modelBean = new Model();
		//Modifications for BUG: 376215 - Start
        //If is UNT Installed and property setting(ModelPrefixMandatoryAndUnique) is true
   	 	if( com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appInstallTypeUnitTracking",false,null,null)){
   	 	    try{
	        String propVal = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"emxUnitTracking.Model.ModelPrefixMandatoryAndUnique");
	    	    if(propVal!= null && propVal.equalsIgnoreCase("true")) {
    	    		result = modelBean.checkModelPrefix(context, emxGetParameter(request, "txtModelPrefix"));
    	    	}
   	 	    }catch(Exception e){}
   	 	}
//   	End of modifications - 376215
        if(!result)
        {
            %>
            <script language="javascript" type="text/javaScript">
             alert("<%=i18nStringNowUtil("emxProductLine.Model.ObjectCannotBeCreated",bundle,acceptLanguage)%>");
             parent.window.closeWindow();          
            </script>
            <%
        }
        else
		{
		      try
		      {
		          
		              //com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
		              String strAction = emxGetParameter(request,"PRCFSParam2");
		              formBean.processForm(session,request);
		              String parentObjId = (String)formBean.getElementValue("objectId");
		               //Setting the latest Locale in context
		               Locale Local = request.getLocale();
		               context.setLocale(Local);
		               productId = productBean.create(context,formBean);
		               
		               // Added for FCA Start
		               if(isFCAInstalled)
                        {
			                String strProjectId = emxGetParameter(request,"contextParentId");
			                if(null!=strProjectId && !"null".equals(strProjectId) && !"".equals(strProjectId) )
			                {
				                DomainObject domProjectSpaceObject = DomainObject.newInstance(context,strProjectId);
				                String strTypeName = domProjectSpaceObject.getInfo(context,DomainConstants.SELECT_TYPE);
				                String strType = DomainConstants.TYPE_PROJECT_SPACE;
				                if(!"".equals(strTypeName) && strType.equals(strTypeName))
				                {
					               StringList strProductIdList = new StringList();
					               strProductIdList.add(productId);
					               HashMap mpProjectProduct = new HashMap();
					               mpProjectProduct.put("from",strProjectId);
					               mpProjectProduct.put("to",strProductIdList);
					               JPO.invoke(context, "emxForecastManagement", null, "postProcessActionOnProductCreation", JPO.packArgs(mpProjectProduct), String.class);
				                }
			                }
                        }
                     // Added for FCA End
		%>
		
		  <script language="javascript" type="text/javaScript">
		    //<![CDATA[
		<%
		
		/*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
		
		String contextParentObjId = (String)formBean.getElementValue("contextParentId");
		String strRelName= productBean.getRelName(context,contextParentObjId);
		strSelectRelId = "to["+strRelName+"].id";
		DomainObject domObjProduct = DomainObject.newInstance(context,productId);
		strRelId = domObjProduct.getInfo(context,strSelectRelId);
		String ContextMode = (String)formBean.getElementValue("ContextMode");
		
		/* START : Added by 3dplm , To connect Model to Design Responsibility connected to the Product */
		DomainObject domObjProductNew = new DomainObject(productId);
		String strRDOId = domObjProductNew.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id");
		if(strRDOId != null)
		{
			 final String SELECT_PARENT_PRODUCT = ("to["+ ProductLineConstants.RELATIONSHIP_PRODUCTS+"].from.id");
			 final String SELECT_PARENT_MAIN_PRODUCT = ("to["+ ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.id");
			 String strModelID="";
			 java.util.Map  mapContext = domObjProductNew.getInfo(context, new StringList(SELECT_PARENT_PRODUCT));
			 if(mapContext.containsKey(SELECT_PARENT_PRODUCT))
				 strModelID = (String)mapContext.get(SELECT_PARENT_PRODUCT);
			 else if(mapContext.containsKey(SELECT_PARENT_MAIN_PRODUCT))
				 strModelID = (String)mapContext.get(SELECT_PARENT_MAIN_PRODUCT);
			 
			DomainObject newDomObjModel = new DomainObject(strModelID);
	
			ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);

		try{
			newDomObjModel.setRelatedObject(context,ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY,false,strRDOId);
		}catch(Exception e){
         session.putValue("error.message", e.getMessage());
		}
	
			ContextUtil.popContext(context);
		}
		/* End : Added by 3dplm , To connect Model to Design Responsibility connected to the Product */
		
                // HDM: Specific code for the HDM system (in SCC)
                if(vcDocumentType!=null && !vcDocumentType.equals("null")){
                    String jpoName = "emxSCCHDMDSFA";
                    String methodName = "connectDSFA";
                    HashMap argsMap = new HashMap();
                    argsMap.put("objectId",productId);
                    argsMap.put("vcDocumentType",vcDocumentType);
                    argsMap.put("objectAction","connectVCFileFolder");
                    argsMap.put("path",strPath);
                    argsMap.put("format",sFormat);
                    argsMap.put("server",strStore);
                    argsMap.put("selector",strSelector);
                    String[] args = JPO.packArgs(argsMap);
                    if(productId != null && !"".equals(productId) && strStore != null && !"".equals(strStore) && strPath != null && !"".equals(strPath))
                    {
                        HashMap objectMap = (HashMap)JPO.invoke(context, jpoName, null, methodName, args, HashMap.class);
                    }
                }
                // HDM: End of HDM specific code

		/*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
		        if (strAction!= null && strAction.equalsIgnoreCase("Action"))
		        {
		%>
		         var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");		        
		        contentFrameObj.document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,productId)%>&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>&relId=<%=XSSUtil.encodeForJavaScript(context,strRelId)%>";
		<%
		       }else if (ContextMode.equalsIgnoreCase("Model") || ContextMode.equalsIgnoreCase("Product"))
		        {  
		            if (ContextMode.equalsIgnoreCase("Model")){
		            //comes here when create product in context of Model
		            %>
		            var contentFrameObj1 = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");			           
		            if(contentFrameObj1.addStructureTreeNode)
		            contentFrameObj1.addStructureTreeNode("<%=productId%>","<%=contextParentObjId%>","<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>","Productline");
		            
		            try
		            {        
		                var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
		                topFrameObj.window.focus();
		            }catch(e){
		                //alert if anything other than permission denied
		                if(-2146828218 != e.number){
		                   alert(e.description)
		                }    
		            }       
		           // var link = "../common/emxTree.jsp?objectId=<%=productId%>&relId=<%=strRelId%>&mode=insert";
		            //contentFrameObj1.document.location.href = link;		           
		            parent.window.closeWindow();
		            
		           <%
		           }else if(ContextMode.equalsIgnoreCase("Product")){
		        	   //comes here create product from mydesk
		           %>
		           var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
		         
		           contentFrameObj.document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,productId)%>&mode=replace&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
		           parent.window.closeWindow();
		           
		<%}
		        }else
                {
                    ///Added for FCA start
                    String strParentId = emxGetParameter(request,"contextParentId");
                    if (!strParentId.equals("null") && strParentId!=null && !strParentId.equals("") && isFCAInstalled)
                    {
                        DomainObject domParentObj = DomainObject.newInstance(context,strParentId);
                        if(domParentObj.isKindOf(context,DomainConstants.TYPE_PROJECT_SPACE))
                        {
                            %>
                            getTopWindow().window.getWindowOpener().parent.document.location.href=getTopWindow().window.getWindowOpener().parent.document.location.href;
                            getTopWindow().window.closeWindow();
                            <%
                        }
                    }
                    else
                    {
                        %>
                         var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                         //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
                         contentFrameObj.document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,productId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
                        <%
                    }
                    ////Added for FCA end
                }
		%>
		       
		        parent.window.closeWindow();
		
		    //]]>
		  </script>
		
		<%
		      }catch(Exception e){
		        bIsError=true;
		     
		        emxNavErrorObject.addMessage(e.getMessage()); 
		       
		        //session.putValue("error.message", e.getMessage());

		      }
		  }
    }

    //----------------------------------------------------------------------------------------------
    // deleteProduct & deleteVersion
    //----------------------------------------------------------------------------------------------
    else if (strMode.equalsIgnoreCase("deleteProduct") || strMode.equalsIgnoreCase("deleteVersion"))
    {
      try
      {
    	PropertyUtil.setGlobalRPEValue(context,"ContextRemoveCheckForMCF","TRUE");
        String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        String arrObjectIds[] = null;

        boolean bIsFromTree = false;
        if (arrTableRowIds[0].indexOf("|") > 0 ) 
        {
          arrObjectIds = com.matrixone.apps.productline.ProductLineUtil.getObjectIds(arrTableRowIds);
          bIsFromTree = true;
        } 
        else 
        {
          arrObjectIds = arrTableRowIds;
        }

   	    // For Product Derivations, if we are Deleting from the Product Based Derivation Summary, then the user is NOT
   	    // allowed to delete the root node.  Make sure we stop that here.
   	    boolean isProductDeletable = true;

    	// This command object sends an extra parameter letting us know we are in the right place.
    	// Get the parameter to see if we need to check for Root Node
   	    boolean isDerivationFromProduct;
   	    String strDerivationFromProduct = emxGetParameter(request, "isDerivationFromProduct");
        if(strDerivationFromProduct == null || "null".equalsIgnoreCase(strDerivationFromProduct) || strDerivationFromProduct.isEmpty()) {
            isDerivationFromProduct = false;
        } else {
        	isDerivationFromProduct = Boolean.valueOf(strDerivationFromProduct).booleanValue();
        }
        
        for(int i=0;i<arrObjectIds.length;i++) { 
        	boolean isfrozenState = Product.isFrozenState(context,arrObjectIds[i]);
	        boolean isnonlastnode =  com.matrixone.apps.productline.ProductLineUtil.hasChild(context, arrObjectIds[i]);
	      
        // Check all of the products sent it to see if any of them are the root node.
        // This is needed in the case where the product has no children and deleting the root node
        // would leave no context object for the Product Properties page.
        if (arrObjectIds[i].equalsIgnoreCase(objectId)) {
	    if (isDerivationFromProduct) {
   	        		// We have the top node of the tree.  Do not allow deletion!
	   	        	isProductDeletable = false;
%>
                    <script language="javascript" type="text/javaScript">
                        alert("<%=i18nStringNowUtil("emxProduct.Delete.OnRoot",bundle,acceptLanguage)%>");
	                </script>
<%
                    break;
                }
	    }else if(isfrozenState){
	   
	        //checks if the product is in frozen(release or obsolete) state
	        //this case is needed if the product is in release or obsolete state
      		isProductDeletable = false;
%>
            <script language="javascript" type="text/javaScript">
                alert("<%=i18nStringNowUtil("emxProduct.Delete.FrozenState",bundle,acceptLanguage)%>");
            </script>
<%
      		break;
      		}else if(isnonlastnode){
        
        //checks if the product is last node or not
        //this case is needed in case if the product has one or more children
        	isProductDeletable = false;
%>
            <script language="javascript" type="text/javaScript">
                alert("<%=i18nStringNowUtil("emxProduct.Delete.NonLastNode",bundle,acceptLanguage)%>");
            </script>
<%
      		break;
        }
        
   	   }
      

   	    if (isProductDeletable) {

    	    // Delete the product
            boolean bFlag = productBean.delete(context,arrObjectIds,strMode);

            if (bIsFromTree)
            {
%>
                <script language="javascript" type="text/javaScript">
<%
	                
                    for(int i=0;i<arrObjectIds.length;i++)
                    {
%>
                        <!-- hide JavaScript from non-JavaScript browsers -->
                        //<![CDATA[

                        var tree = window.getTopWindow().objDetailsTree;
                        tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
                        var objStructureTree = getTopWindow().objStructureFancyTree;
                        if(objStructureTree && objStructureTree.isActive){
                         var node = objStructureTree.getNodeById("<%=XSSUtil.encodeForJavaScript(context, arrObjectIds[i])%>");
                         if (node) {
                        	node.removeChildren();
                            node.remove();
                         }
                        }
                        //]]>
<%
                    }
	
%>
                    refreshTreeDetailsPage();
                    //releasing mouse events after Deletion
                </script>

<%
            }
            else
            {
%>
                <script language="javascript" type="text/javaScript">
                    refreshTablePage();
                </script>
<%

            }
        }
      }catch(Exception e){
    	// Product-> Planning->Product Evolution->Delete non Root Product
    	// exclude Check trigger blocked event- message being put in to session so that it will be not dispayed
        if (e.toString()!=null && e.toString().indexOf("Check trigger blocked event")< 0) {
          String strAlertString = "emxProduct.Alert." + e.getMessage();//incorrect in case of e.getMessage alredy internationalized 
          String strErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);

          if ("".equals(strErrorMessage))
          {
            strErrorMessage = i18nStringNowUtil("emxProduct.Alert.DeleteFailure",bundle,acceptLanguage)+ e.getMessage();
          }else
          {
            strErrorMessage = i18nStringNowUtil("emxProduct.Alert.DeleteFailure",bundle,acceptLanguage)+ strErrorMessage;

          }
          session.putValue("error.message", strErrorMessage);      
         }
      }
    }

    else if(strMode.equals("GoverningProjectSB")){   	 
        String fieldNameActual = emxGetParameter(request, "fieldNameActual");
        String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
        String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
        String prdId=emxGetParameter(request,"objectId");
        StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
        String strObjectId = strTokenizer.nextToken() ; 
        String  strAlertMessage="";
        DomainObject objContext = new DomainObject(strObjectId);
        String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME); 
       %>
        <script language="javascript" type="text/javaScript">

        var vfieldNameActual = "";
        var vfieldNameDisplay = "";
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
            vfieldNameActual = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
            vfieldNameDisplay = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
            if(vfieldNameDisplay[0]){
                vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
            }
            else{
                vfieldNameDisplay = self.getTopWindow().frames['slideInFrame'].frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                vfieldNameActual = self.getTopWindow().frames['slideInFrame'].frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
            }
            
        }

        if(flag == "true"){
            //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
        	getTopWindow().close();
        }                      
        </script>
        <%
    
    }

    //----------------------------------------------------------------------------------------------
    // copyProduct
    //----------------------------------------------------------------------------------------------
    else if (strMode.equalsIgnoreCase("copyProduct"))
    {
      String strContextWindow = emxGetParameter(request, "PRCFSParam1");

      try{
        

        formBean.processForm(session,request);
        String sourceObjectId = (String)formBean.getElementValue("sourceObjectId");
        String destinationObjectId = (String)formBean.getElementValue("destinationObjectId");
        //Modified the Signature for Bug 309271 by Enovia MatrixOne on 02 Dec 2005
        //productBean.copyProduct(context,sourceObjectId,destinationObjectId, strMode);
        
        // Added for Frozen State Mapping for Product Function
        String strState  = "";
  	    String destObjId = (String)formBean.getElementValue("destinationObjectId");
  	    if(ProductLineCommon.isNotNull(destObjId)){
	        DomainObject destinationObj = DomainObject.newInstance(context, destObjId);
	        strState = destinationObj.getInfo(context, DomainConstants.SELECT_CURRENT);
  	    }
        String      strFrozenStates = EnoviaResourceBundle.getProperty(context, "Configuration.FrozenState.type_Products");
        String      strStates       = strFrozenStates.replaceAll("policy_Product.state_", "");
        String[] arrFrozenStates    = strStates.split(",");
        List listFrozenStates       = new ArrayList();
        listFrozenStates = Arrays.asList(arrFrozenStates);
        String strErrorMessage = "";
        if(listFrozenStates.contains(strState))
        {
      	   String strAlertString = "emxProduct.Alert.CopyProductFrozen";
           strErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);
           throw new FrameworkException(strErrorMessage);
        }		
        // Added for Frozen State Mapping for Product Function
     
        productBean.copyProductStructure(context, sourceObjectId, destinationObjectId, strMode);
        String strAlertMessage = i18nStringNowUtil("emxProduct.Alert.CopySuccessful",bundle,acceptLanguage);
        strAlertMessage = com.matrixone.apps.framework.ui.UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,strAlertMessage,destinationObjectId);

%>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[
    //copy Successful
    //XSSOK
    alert("<%=strAlertMessage%>");

<%
        if (strContextWindow.equalsIgnoreCase("ListPage"))
        {

%>
    var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
    //below line commented to keep the page at Product Evolution page after Copy
    // contentFrameObj.document.location = contentFrameObj.document.location;
  
<%
        }else{}
%>
    //releasing mouse events for Copy functionality
    parent.window.closeWindow();

  //]]>
  </script>


<%

      }catch(Exception e){
        session.putValue("error.message", e.getMessage());
      }
    }
    //Revise Functionality
    else if (strMode.equalsIgnoreCase("reviseProduct"))
    {
      try{
    	  ContextUtil.startTransaction(context,true);
        //com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
        formBean.processForm(session,request);
        String revisedObjectId = productBean.reviseProduct(context,formBean);
      /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
        String strParentObjId = (String)formBean.getElementValue("contextParentId");
        String strRelName= productBean.getRelName(context,strParentObjId);
        strSelectRelId = "to["+strRelName+"].id";
        DomainObject domObjRevisedProduct = DomainObject.newInstance(context,revisedObjectId);
        strRelId = domObjRevisedProduct.getInfo(context,strSelectRelId);
        /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/

        // HDM: Specific code to handle HDM fields.
        if(vcDocumentType!=null && !vcDocumentType.equals("null")){
            String jpoName = "emxSCCHDMDSFA";
            String methodName = "connectDSFAReviseProduct";
            HashMap argsMap = new HashMap();
            argsMap.put("objectId",revisedObjectId);
            argsMap.put("vcDocumentType",vcDocumentType);
            argsMap.put("objectAction","connectVCFileFolder");
            argsMap.put("path",strPath);
            argsMap.put("format",sFormat);
            argsMap.put("server",strStore);
            argsMap.put("selector",strSelector);
            String[] args = JPO.packArgs(argsMap);
            if(revisedObjectId != null && !"".equals(revisedObjectId)&& strStore != null && !"".equals(strStore) && strPath != null && !"".equals(strPath)) {
                HashMap objectMap = (HashMap)JPO.invoke(context, jpoName, null, methodName, args, HashMap.class);
            }
        }

        // HDM Tags Functionality.
        String strTags = (String)emxGetParameter(request,"txtTags");
        String strTagsComments = (String)emxGetParameter(request,"txtTagsComments");
        if(strTags != null && !"".equals(strTags))
        {
        	String jpoName = "emxSCCHDMProducts";
            String methodName = "createTagRelationship";
            HashMap argsMap = new HashMap();
            argsMap.put("contextParentId",strParentObjId);
            argsMap.put("revisedObjectId",revisedObjectId);
            argsMap.put("mode",strMode);
            argsMap.put("tags",strTags);
            argsMap.put("tagsComments",strTagsComments);
            String[] args = JPO.packArgs(argsMap);
            String strErrorMessage = (String)JPO.invoke(context, jpoName, null, methodName, args, String.class);
            if(strErrorMessage != null && !"".equals(strErrorMessage)) {
                throw new Exception(strErrorMessage);
            }
        }
        //HDM R213: KP2 Start
        //HDM Derivation Functionality
        String strDerivationType = (String)emxGetParameter(request,"DerivationType");
        String strDerivedFrom = (String)emxGetParameter(request, "DerivationContextActual");
        String strError = "";
        boolean flag = false;
        if(!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strDerivationType)&&
        		!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strDerivedFrom)){
        	flag = true;
        }else{
        	if(!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strDerivationType)){
                if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strDerivedFrom)){
                    String languageStr = context.getSession().getLanguage();
                    strError = EnoviaResourceBundle.getProperty(context,"SemiTeamCollab",
                            "emxSemiTeamCollab.Error.Alert.NoDerivationContext",languageStr);
                    throw new Exception(strError);
                }
            }
            if(!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strDerivedFrom)){
                if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strDerivationType)){
                    String languageStr = context.getSession().getLanguage();
                    strError = EnoviaResourceBundle.getProperty(context,"SemiTeamCollab",
                            "emxSemiTeamCollab.Error.Alert.NoDerivationType",languageStr);
                    throw new Exception(strError);
                }
            }
        }
        
        String strMergedFrom = (String)emxGetParameter(request, "MergedFromActual");
        if(!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strMergedFrom)){
        	StringList slProdIds = FrameworkUtil.split(strMergedFrom,"|");
        	if(slProdIds != null && slProdIds.size()>0){
        		if(strDerivedFrom != null && slProdIds.contains(strDerivedFrom)){
                    String languageStr = context.getSession().getLanguage();
                    strError = EnoviaResourceBundle.getProperty(context,"SemiTeamCollab",
                            "emxSemiTeamCollab.Error.Alert.SameProductForMergedFrom",languageStr);
                    throw new Exception(strError);
                }
        		String jpoName = "emxSCCHDMProducts";
                String methodName = "addMergedFrom";
                HashMap argsMap = new HashMap();
                argsMap.put("objectId",revisedObjectId);
                argsMap.put("productList",slProdIds);
                String[] args = JPO.packArgs(argsMap);
                JPO.invoke(context, jpoName, null, methodName, args, String.class);
        	}
        }
        
        if(flag){
        	
            String jpoName = "emxSCCHDMProducts";
            String methodName = "setDerivationForProduct";
            HashMap argsMap = new HashMap();
            argsMap.put("objectId",revisedObjectId);
            argsMap.put("derivedFrom",strDerivedFrom);
            argsMap.put("derivationType",strDerivationType);
            String[] args = JPO.packArgs(argsMap);
            JPO.invoke(context, jpoName, null, methodName, args, String.class);
        }

        //HDM R213: KP2 End
        // HDM: End of HDM specific code.
        
        String derivedFrom = (String)emxGetParameter(request, "DerivedFromActual");
        if(!com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(derivedFrom)){
        	String strRel = PropertyUtil.getSchemaProperty(context, "relationship_Derived");
        	domObjRevisedProduct.addFromObject(context,new matrix.db.RelationshipType(strRel),derivedFrom);
        }

%>
            <script language="javascript" type="text/javaScript">
            var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");            

<%
              String strRevision = i18nStringNowUtil("emxProduct.Tree.Revisions",bundle,acceptLanguage); 
        String ContextMode = (String)formBean.getElementValue("ContextMode");

        String strProductRevision = i18nStringNowUtil("emxProduct.Tree.ProductRevisions",bundle,acceptLanguage);

        if(ContextMode.equalsIgnoreCase("Model")){
%>
if(contentFrameObj.addStructureTreeNode)
contentFrameObj.addStructureTreeNode("<%=revisedObjectId%>","<%=strParentObjId%>","<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>","Productline");

try
{        
    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
    topFrameObj.window.focus();
}catch(e){
    //alert if anything other than permission denied
    if(-2146828218 != e.number){
       alert(e.description)
    }    
}               
             
             
<%
   }else{
	   
       DomainObject domObj = new DomainObject(revisedObjectId);
       String objName = domObj.getName(context);
       String objRevision = domObj.getRevision(context);
       String strLabel = "";
       
    
           HashMap paramMap = new HashMap();
           paramMap.put("objectId", revisedObjectId);
           HashMap mapArgs = new HashMap();
           mapArgs.put("paramMap",paramMap);
           String[] mapPacked = (String[]) JPO.packArgs(mapArgs);
           strLabel = (String)JPO.invoke(context, "emxProduct", null,
                   "getDisplayNameForNavigator", mapPacked, String.class);
      
%>
             var link = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,revisedObjectId)%>&mode=insert&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
             
             contentFrameObj.changeObjectIDInTree("<xss:encodeForJavaScript><%=strParentObjId%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=revisedObjectId%></xss:encodeForJavaScript>");
             contentFrameObj.changeObjectLabelInTree("<xss:encodeForJavaScript><%=revisedObjectId%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=strLabel%></xss:encodeForJavaScript>");
              
              contentFrameObj.document.location.href = link;
<%
   }
%>


     

        
        parent.window.closeWindow();
            </script>
<%

      ContextUtil.commitTransaction(context);
      }catch(Exception e){
    	  ContextUtil.abortTransaction(context);
          bIsError=true;
        String strAlertString = "emxProduct.Alert." + e.getMessage();
        String strErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);

        if ("".equals(strErrorMessage))
          strErrorMessage = e.getMessage();

        session.putValue("error.message", strErrorMessage);

      }
    }
    //Version Functionality
    else if (strMode.equalsIgnoreCase("versionProduct"))
    {
      try{
       // com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();

        formBean.processForm(session,request);
        //Modified the Signature for Bug 309271 by Enovia MatrixOne on 02 Dec 2005
        //String versionObjectId = productBean.versionProduct(context,formBean,strMode);
		String versionObjectId = productBean.createProductVersion(context,formBean,strMode);

		/* Start-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/
		ProductLineCommon plcBean =  new ProductLineCommon();
		String strDesRelId = emxGetParameter(request, "txtDRId");
		DomainObject objPrdVer = DomainObject.newInstance(context,versionObjectId.trim());
		if (strDesRelId != null && !"".equals(strDesRelId))
		{
			/*Start : Added by 3dPLM on 10/3/2007 to check if  Product version is already connected to RDO*/

			String strDesResIdNew = objPrdVer.getInfo(context,"relationship["+ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id");
			if(strDesResIdNew != null && !strDesResIdNew.equals(strDesRelId))
			{
				plcBean.connectRDO(context,versionObjectId,strDesRelId);
			}
			/*End : Added by 3dPLM on 10/3/2007 to check if  Product version is already connected to RDO*/
		}
		else
		  {
				String strRelIdDesRes = objPrdVer.getInfo(context,"relationship["+ProductLineConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].id");
				if(strRelIdDesRes != null)
					DomainRelationship.disconnect(context,strRelIdDesRes,true);
		  }

        /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
        String strParentId = (String)formBean.getElementValue("objectId");
        String strRelName= productBean.getRelName(context,strParentId);
        strSelectRelId = "to["+strRelName+"].id";
        DomainObject domObjVersionProduct = DomainObject.newInstance(context,versionObjectId);
        strRelId = domObjVersionProduct.getInfo(context,strSelectRelId);
        /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
%>


  <script language="javascript" type="text/javaScript">
  //<![CDATA[
<%
%>
     var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
        //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
        contentFrameObj.document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,versionObjectId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
		//Commented for Bug 349517
		/* var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
        topFrameObj.window.focus();*/
        parent.window.closeWindow();

  //]]>
  </script>


<%
      }catch(Exception e){
        bIsError = true;
        String strAlertString = "emxProduct.Alert." + e.getMessage();
        String strErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);

        if ("".equals(strErrorMessage))
          strErrorMessage = e.getMessage();

        session.putValue("error.message", strErrorMessage);

      }
    }
    //Apply version as Revision
    else if (strMode.equalsIgnoreCase("applyRevision"))
    {
      try{
        String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        String arrObjectIds[] = com.matrixone.apps.productline.ProductLineUtil.getObjectIds(arrTableRowIds);

        String versionObjectId = arrObjectIds[0];

        String strRevisionId = productBean.applyRevision(context,versionObjectId,objectId);
        String strAlertMessage = i18nStringNowUtil("emxProduct.Alert.ApplyRevisionSuccessful",bundle,acceptLanguage);
        strAlertMessage = com.matrixone.apps.framework.ui.UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,strAlertMessage,strRevisionId);

%>


  <script language="javascript" type="text/javaScript">
  //<![CDATA[
  //XSSOK
    alert("<%=strAlertMessage%>");
    var tree = window.getTopWindow().objDetailsTree;
    tree.deleteObject ("<xss:encodeForJavaScript><%=versionObjectId%></xss:encodeForJavaScript>");
    refreshTreeDetailsPage();
    //releasing mouse events
  //]]>
  </script>


<%
      }catch(Exception e){
        String strAlertString = "emxProduct.Alert." + e.getMessage();
        String strErrorMessage = i18nStringNowUtil(strAlertString,bundle,acceptLanguage);

        if ("".equals(strErrorMessage))
          strErrorMessage = e.getMessage();

        session.putValue("error.message", strErrorMessage);

      }
    }
    else if (strMode.equalsIgnoreCase("disconnect"))
    {
      //get the table row ids of the test case objects selected
      String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

      //get the relationship ids of the table row ids passed
      Map relIdMap=ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
      String[] arrRelIds = (String[]) relIdMap.get("RelId");
      String[] strObjectIds = (String[]) relIdMap.get("ObjId");

      //Call the removeObjects method to remove the selected object
      boolean bFlag = productBean.removeObjects(context,arrRelIds);
%>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[

<%
      //refresh the tree after disconnect
      for(int i=0;i<strObjectIds.length;i++)
      {
%>
    var tree = window.getTopWindow().objDetailsTree;
    tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,strObjectIds[i])%>");
<%
      }
%>
    //refreshTreeDetailsPage();
    //Modify for PLC Categories consolidation
    var contentFrameObj = findFrame(getTopWindow(),"PLCProductTaskTreeCategory");
	if (contentFrameObj == null) {
		contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");                        
	}
	contentFrameObj.location.href = contentFrameObj.location.href;
    //releasing mouse events
  //]]>
  </script>
<%

    }
   /* if mode equals "movePreprocess", then the following code extracts the table rowIds
     from the request,rename it and pass it with a different name */
  if (strMode.equalsIgnoreCase("movePreprocess"))
  {
     String STR_DELIMITER = ",";
     String strObjId = emxGetParameter(request,"objectId");
     String strParentOID = emxGetParameter(request,"parentOID");
     String strProductsToBeMovedIds = "";
     StringBuffer sbProductsToBeMovedIds = new StringBuffer("ProductsToBeMovedIds=");
     //get the table row ids of the Products objects selected
     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     //Begin of Add by Enovia MatrixOne for Bug 304880 on 5/20/2005
     if(strObjId == null || "null".equalsIgnoreCase(strObjId))
     {
        strObjId = "";
     }
     //End of Add by Enovia MatrixOne for Bug 304880 on 5/20/2005
     //form the comma delimited string of TableRowIds
     for(int i=0;i<arrTableRowIds.length;i++)
          {
           if(i > 0)
              {
               sbProductsToBeMovedIds.append(STR_DELIMITER);
               sbProductsToBeMovedIds.append(arrTableRowIds[i]);
              }
           else
              {
               sbProductsToBeMovedIds.append(arrTableRowIds[i]);
              }
          }
         strProductsToBeMovedIds = sbProductsToBeMovedIds.toString();
      %>
            <form name="moveProduct"   method="post" >
              <input type="hidden" name="forNetscape" value ="" >
            </form>
            <script language="javascript" type="text/javaScript">
            //<![CDATA[
              var hidFrmName= document.moveProduct;
              showModalDialog( "../components/emxCommonSearch.jsp?searchmode=addexisting&searchmenu=SearchAddExistingChooserMenu&searchcommand=PLCSearchModelsCommand&getAllModels=true&srcDestRelName=relationship_Products&isTo=false&selection=single&SubmitURL=../productline/ProductMoveProcess.jsp&<%=XSSUtil.encodeForURL(context,strProductsToBeMovedIds)%>&StringResourceFileId=emxProductLineStringResource&suiteKey=ProductLine&SuiteDirectory=ProductLine&objectId=<%=XSSUtil.encodeForURL(context,strObjId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentOID)%>",720,550);
             </script>
      <%
  }

    else if(strMode.equalsIgnoreCase("Form"))
    {
      try
      {
%>
      <%@include file = "PrimaryImageInclude.inc"%>
<%
      }catch(Exception e){
         session.putValue("error.message", e.getMessage());
      }
    }else if(strMode.equals("report")){
     //Instantiating ProductLineUtil.java bean
     ProductLineUtil utilBean = new ProductLineUtil();
     //Getting the table row ids of the selected objects from the request
     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     //Getting the object ids from the table row ids
     String arrObjectIds[] = null;
     arrObjectIds = utilBean.getObjectIds(arrTableRowIds);
     //Calling emxTable.jsp
%>
    <form name="Dependencyreport"   method="post" >
      <input type="hidden" name="forNetscape" value ="" >
    </form>
    <script language="javascript" type="text/javaScript">
    showNonModalDialog("../common/emxTable.jsp?table=PLCProductDependencyList&emxTableRowId=<%=XSSUtil.encodeForURL(context,arrObjectIds[0])%>&objectId=<%=XSSUtil.encodeForURL(context,arrObjectIds[0])%>&suiteKey=ProductLine&header=emxProduct.Heading.DependencyReport&program=emxProduct:getConnectedProducts&mode=ListPage&HelpMarker=emxhelpproductdependencyreport",700,500);
    </script>
<%
}else if(strMode.equalsIgnoreCase("GoverningProject")||
        strMode.equalsIgnoreCase("EditGoverningProject")){
            //Get the selected Project Id
            String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");       
                    String arrObjectIds[]=(String[])ProductLineUtil.getObjectIdsRelIdsR213(arrTableRowIds).get("ObjId");
                     String strProjectId = arrObjectIds[0];             
                      String strAlertMessage = "";

            //Get the current Governing Project of the Product
            productBean.setId(objectId);
            Map mapGovProjMap = productBean.getGoverningProjectInfo(context);         
            String strGovProjId = (String)mapGovProjMap.get(Product.SELECT_GOVERNING_PROJECT_ID);

            //Check the type of the selected project and if the type is other than Project Space then throw alert message
            if(strGovProjId!=null&&!strGovProjId.equals("")&&!strGovProjId.equalsIgnoreCase("null")&&strGovProjId.equals(strProjectId)){
                strAlertMessage = i18nStringNowUtil("emxProduct.Alert.AlreadyGoverningProject",
                                                                       bundle,
                                                                       acceptLanguage);
            }else if(!productBean.isLegalGoverningProjectType(context,strProjectId)){
                strAlertMessage = i18nStringNowUtil("emxProduct.Alert.TypeProjectSpace",
                                                                        bundle,
                                                                        acceptLanguage);
            }else if(strMode.equalsIgnoreCase("GoverningProject")){
                productBean.makeGoverningProject(context,
                                                                    strProjectId,
                                                                    (String)mapGovProjMap.get(Product.SELECT_RELATIONSHIP_GOVERNING_PROJECT_ID));
            }
            if(strAlertMessage!=null&&!strAlertMessage.equalsIgnoreCase("null")&&!strAlertMessage.equals("")){
                if(strMode.equalsIgnoreCase("EditGoverningProject")){
%>
                    <script language="javascript" type="text/javaScript">
                    //<![CDATA[
                      alert("<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>");
                      var contentFrameObj = findFrame(getTopWindow(),"listFoot");
                      contentFrameObj.document.location.reload();
                     </script>
<%
                }else{
%>
                     <script language="javascript" type="text/javaScript">
                    //<![CDATA[
                      alert("<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>");
                     </script>
<%
                }
              }else{
                    if(strMode.equalsIgnoreCase("EditGoverningProject")){
                        String timeStamp = emxGetParameter(request, "timeStamp");
                        Map mapRequest = (HashMap)tableBean.getRequestMap(timeStamp);
                        String strFrameName = (String)mapRequest.get(Search.REQ_PARAM_FRAME_NAME);
                        String strFormName = (String)mapRequest.get(Search.REQ_PARAM_FORM_NAME);
                        String strFieldNameDisplay = (String)mapRequest.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
                        String strFieldNameActual = (String)mapRequest.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
                        Search search = new Search();
                        String strProjName = search.getObjectName(context, arrObjectIds[0]);
%>
                        <script language="javascript" type="text/javaScript">
                        //<![CDATA[
                            var searchContentFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
                            if(searchContentFrame !=null){
                              txtTypeDisplay=searchContentFrame.document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)%>;
                              txtTypeActual=searchContentFrame.document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)%>;
                            }else{
                                txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)%>;
                                txtTypeActual = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)%>;
                            }
                            txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context,strProjName)%>";
                            txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[0])%>"
                            getTopWindow().closeWindow();
                         </script>
<%
                    }else{
%>
                        <script language="javascript" type="text/javaScript">
                        //<![CDATA[                       
                           // refreshTreeDetailsPage();
                           //Modify for PLC Categories consolidation
                           var contentFrameObj = findFrame(getTopWindow(),"PLCProductRoadmapProjectsTreeCategory");
						   if (contentFrameObj == null) {
					            contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");                        
					       }
							contentFrameObj.location.href = contentFrameObj.location.href;
                         </script>
<%
            }
       }
    }else if(strMode.equalsIgnoreCase("DisconnectProjects")){

        //Get the table row ids from the request and obtain the Map containing seperate arrays of object id and relationship id
        String arrTableRowIds[] = emxGetParameterValues(request,
                                                                                   "emxTableRowId");
        Map mapRowIds =ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
        // Added by Enovia MatrixOne for Bug # 301879 Date 04/08/2005
        String[] strObjectIds = (String[]) mapRowIds.get("ObjId");

        //Get the information of the governing project for this Product
        productBean.setId(objectId);
        Map mapGovProj = productBean.getGoverningProjectInfo(context);

        //Call the method remove selected Projects from the Product
        boolean bFlag = productBean.removeSelectedProjects(context,
                                                                                        mapRowIds,
                                                                                        mapGovProj);
        // Begin of Modify by Enovia MatrixOne for Bug # 301879 Date 04/08/2005
%>
        <script language="javascript" type="text/javaScript">
<%
        for(int i=0;i<strObjectIds.length;i++)
        {
%>
      //<![CDATA[
      var tree = getTopWindow().trees['emxUIDetailsTree'];
      tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,strObjectIds[i])%>");
      //]]>
<%
        }
%>
            //<![CDATA[
                //refreshTreeDetailsPage();
                //refreshTablePage();
        //Modify for PLC Categories consolidation
        var contentFrameObj = findFrame(getTopWindow(),"PLCProductRoadmapProjectsTreeCategory");
		if (contentFrameObj == null) {
            contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");                        
        }
		contentFrameObj.location.href = contentFrameObj.location.href;
         </script>
<%  //Added- start- HF379015V6R2011- FTR: After changes made to the Roadmap Tasks, automatically not showing...
         }else if(strMode.equalsIgnoreCase("refreshContent")){
             
         %>
          <script language="javascript" type="text/javaScript">
             //<![CDATA[
             getTopWindow().closeWindow();
             getTopWindow().getWindowOpener().location.href =getTopWindow().getWindowOpener().location.href;                 
          </script>
         <%
         
         }
  }catch(Exception e){
     session.putValue("error.message", e.getMessage());
  }


%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  if (bIsError==true && !(strMode.equalsIgnoreCase("deleteProduct") || strMode.equalsIgnoreCase("deleteVersion") || strMode.equalsIgnoreCase("applyRevision") ||strMode.equalsIgnoreCase("Form")) && result)

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


