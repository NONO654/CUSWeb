<%-- DesignEffectivityUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/dmcplanning/DesignEffectivityUtil.jsp 1.3.1.2 Wed Jan 07 13:21:40 2009 GMT ds-rsarode Experimental$: ProductConfigurationUtil.jsp";
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@ page import="com.matrixone.apps.domain.DomainObject" %>
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>
<%@ page import="com.matrixone.apps.domain.util.mxType" %>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.dmcplanning.Product"%>
<%@page import = "com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import = "com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%	
	String strContextObjectId   = emxGetParameter(request, "objectId");
    String strMode = emxGetParameter(request, "mode");
    String strCreateRevise = emxGetParameter(request,"createRevise");
    String strRevision = "";
    String strDescription = "";
    String strParentProductID = "";
%>
       
       
       
      <SCRIPT language="javascript" type="text/javaScript">
         var strTreeId = "<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "jsTreeID"))%>";
         
      </SCRIPT>
        
        
 <%
    String strTreeId  = emxGetParameter(request, "jsTreeID");
    String strRelId  = emxGetParameter(request, "relId");  
    String strExceptionMode = strMode;
    String strAction                 = emxGetParameter(request, "PRCFSParam2");
    String strCreateParameter        = emxGetParameter(request, "createParameter");
    String strFromContext = emxGetParameter(request,"fromcontext");
    String productId ="";
    String newRevisionId = "";
    boolean bCloseWindow = true;
    String language  = request.getHeader("Accept-Language");
      
  try {
   
    
    if( strMode == null || strMode.equals("") || "null".equalsIgnoreCase(strMode)) 
	{
    	//do nothing
    }
    else if(strMode.equalsIgnoreCase("create"))
    {
    	com.matrixone.apps.domain.util.ENOCsrfGuard.validateRequest(context, session, request,response);
    	boolean bdesignChange = false;
    	StringList sLRemMPRelIDs = new StringList();
    	String strEffectivitySelections = emxGetParameter(request, "effectivityselections");
    	String strEffectivityUnSelections = emxGetParameter(request, "effectivitydeselections");
    	String fromDesignMatrix = emxGetParameter(request, "fromdesignmatrix");
    	if(UIUtil.isNullOrEmpty(fromDesignMatrix))
    	{
    		fromDesignMatrix = "";
    	}
    	if(fromDesignMatrix.equalsIgnoreCase("True"))
    	{
    		PropertyUtil.setGlobalRPEValue(context,"fromDesignMatrix","True");
    		PropertyUtil.setGlobalRPEValue(context,"fromDesignEffectivity","False");
    	}
    	else
    	{
    		PropertyUtil.setGlobalRPEValue(context,"fromDesignEffectivity","True");
    	}
    	String matrixmasterId = emxGetParameter(request, "masterId");
    	if(UIUtil.isNullOrEmpty(matrixmasterId))
    	{
    		matrixmasterId = "";
    	}
    	PropertyUtil.setGlobalRPEValue(context,"masterId",matrixmasterId);
    	
    	if(strEffectivitySelections==null)
        {
            strEffectivitySelections = "";
        }
    	if(strEffectivityUnSelections==null)
        {
    		strEffectivityUnSelections = "";
        }
    	
        // Tokenize the unselected managed Revisions to pass to the editEffecticity to make necessary disconnections.
        
        StringList slEffectivityDeSelections = new StringList();
        StringTokenizer strDeSelectionTok = new StringTokenizer(strEffectivityUnSelections, ",");
        String strDeselectedKey = null;
        while(strDeSelectionTok.hasMoreTokens())
        {
        	strDeselectedKey = strDeSelectionTok.nextToken();
            if(strDeselectedKey != null && !"".equalsIgnoreCase(strDeselectedKey))
            {
            	slEffectivityDeSelections.add(strDeselectedKey);
            }   
        }
        
     // Tokenize the selected managed Revisions to pass to the editEffecticity to make necessary connections.
        StringList slEffectivitySelections = new StringList();
        StringTokenizer strTok = new StringTokenizer(strEffectivitySelections, ",");
        String strKey = null;
        String strTempManagedRevisionId=null;
        while(strTok.hasMoreTokens())
        {
            strKey = strTok.nextToken();
            if(strKey != null && !"".equalsIgnoreCase(strKey))
            {
            	strTempManagedRevisionId = strKey.substring(0,strKey.indexOf("|"));
            	if(!slEffectivityDeSelections.contains(strTempManagedRevisionId))
            	{
            		slEffectivitySelections.add(strKey);
            	}
                
            }   
        }
        PropertyUtil.setGlobalRPEValue(context,"selectedlist",slEffectivitySelections.toString());
        String strProductId="";
        String designChoice="";
    	if("edit".equalsIgnoreCase(strAction))
    	{
			strProductId = (String)session.getAttribute("ProductId");
			designChoice = (String)session.getAttribute("designChoice");
			DomainObject domProduct = new DomainObject(strProductId);
			com.matrixone.apps.dmcplanning.Product product = new com.matrixone.apps.dmcplanning.Product(strProductId);		
			//set the RPE value for the design change is Yes/No	
			PropertyUtil.setGlobalRPEValue(context,"designChoice",designChoice);
		    product.editDesignEffectivity(context,slEffectivitySelections,slEffectivityDeSelections);
		        //Added for IR-077763V6R2012
		    ManufacturingPlan manuPlan=null;
		    product.editManufacturingPlanImplements(context,manuPlan);
		        //End of IR-077763V6R2012
    	}
    	else
    	{ 		
    	    strDescription = (String)session.getAttribute("Description");
    	    strRevision = (String)session.getAttribute("Revision");
    	    strParentProductID = (String)session.getAttribute("ParentProductID");
    	    com.matrixone.apps.dmcplanning.Product product = new com.matrixone.apps.dmcplanning.Product(strParentProductID);
    	    newRevisionId = product.reviseAndUpdateDesignEffectivity(context,strRevision,strDescription,slEffectivitySelections,slEffectivityDeSelections);
    	    session.removeAttribute("Description");
            session.removeAttribute("ParentProductID");
            session.removeAttribute("Revision");
    	}
       session.removeAttribute("ProductId");
       session.removeAttribute("designChoice");
        %>
        <%
    }else if (strMode.equalsIgnoreCase("disconnectMPForSync")){
        String strRemMPRelIDs = emxGetParameter(request,"RemMPRelIDs");
        java.util.StringTokenizer stTk = new java.util.StringTokenizer(strRemMPRelIDs,"[,],,");
        StringList sLRemMPRelIDs = new StringList();
        while(stTk.hasMoreElements())
        {
            sLRemMPRelIDs.addElement(stTk.nextToken().toString());
        }
        ManufacturingPlan manufacturingPlan = new ManufacturingPlan();  
        manufacturingPlan.disconnectManufacturingPlan(context, sLRemMPRelIDs);
    }   
  else if(strMode.equals("cleanupsession")) 
  {
		//session.removeAttribute("productEffectivity");
		session.removeAttribute("ProductId");
		session.removeAttribute("Description");
		session.removeAttribute("ParentProductID");
		
%>
        
        <script language="javascript" type="text/javaScript">
        parent.window.closeWindow(); 
        </script>
        <%
		
  }
  
    
  else if(strMode.equals("editOptions")) {
      bCloseWindow = false;
      productId = strContextObjectId;
       %>
       <SCRIPT language="javascript" type="text/javaScript">
       showModalDialog('../dmcplanning/DesignEffectivityFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,strTreeId)%>&functionality=ProductRevisionEditOptionsContentFSInstance&relId=<%=XSSUtil.encodeForJavaScript(context,strRelId)%>&suiteKey=DMCPlanning&objectId=<%=XSSUtil.encodeForJavaScript(context,productId)%>&mode=<%=XSSUtil.encodeForJavaScript(context,strMode)%>', 600, 570);
       </SCRIPT>
	   	      <%
  }
  else if (strMode
          .equalsIgnoreCase("CreateNewProductRevision"))
  {
	  String strModelId = strContextObjectId;
	  	  
	  %>
      <script language="javascript" type="text/javaScript">
      showModalDialog("../components/emxCommonFS.jsp?functionality=ProductRevisionReviseFlatViewFSInstance&PRCFSParam1=Product&context=sbEdit&suiteKey=DMCPlanning&jsTreeID="+strTreeId+"&objectId=<%=XSSUtil.encodeForURL(context,strModelId)%>",600,600);    
      </script>
 <%
	  
  }
  else if((strCreateRevise!= null && strCreateRevise.equalsIgnoreCase("revise")) &&(strMode.equalsIgnoreCase("featureSelect")))
  { 
    // Load the second page of the Flat view create process.
    bCloseWindow = false;
    String strModelId      = emxGetParameter(request, "hidProductId");
    session.removeAttribute("productEffectivity");
    strDescription    = emxGetParameter(request, "txtProductDescription");
    strRevision = emxGetParameter(request,"txtRevision");
    strParentProductID = emxGetParameter(request,"parentProductId");
    session.setAttribute("Description",strDescription);
    session.setAttribute("Revision",strRevision);
    session.setAttribute("ParentProductID",strParentProductID);
    
  }
  else if((strCreateRevise!= null && strCreateRevise.equalsIgnoreCase("create")) &&(strMode.equalsIgnoreCase("createRevise")))
  {
	  strDescription    = emxGetParameter(request, "txtProductDescription");
	     strRevision = emxGetParameter(request,"txtRevision");
	     strParentProductID = emxGetParameter(request,"parentProductId");
      com.matrixone.apps.dmcplanning.Product product = new com.matrixone.apps.dmcplanning.Product(strParentProductID);
      HashMap infoMap = new HashMap();
      infoMap.put("Revision",strRevision);
      infoMap.put("Description",strDescription);
      newRevisionId = product.revise(context,infoMap);
      
  }
  else if(strMode.equalsIgnoreCase("DesignEffectivityChooser"))
  {
      String emxTableRowId[] = emxGetParameterValues(request,"emxTableRowId");
      String modelTemplateId = emxGetParameter(request, "parentFeatureId");
      String strRowInnerHtml = "";
      StringTokenizer strTokenizer = null;
      String strManagedRevisionId = "";
      String strManagedRevisionType = "";
      String  strUsage = "";

      String strFTSelect = 
    		  "to["+ManufacturingPlanConstants.RELATIONSHIP_PRODUCTS+"]." + 
    				  ManufacturingPlanConstants.SELECT_ATTRIBUTE_FEATURE_ALLOCATION_TYPE;

      String strFTMainSelect = 
    		  "to["+ManufacturingPlanConstants.RELATIONSHIP_MAIN_PRODUCT+"]." + 
    				  ManufacturingPlanConstants.SELECT_ATTRIBUTE_FEATURE_ALLOCATION_TYPE;

      StringList slFT= new StringList();
      slFT.addElement(strFTSelect);
     
      for(int i=0;i<emxTableRowId.length;i++)
      {
          strTokenizer = new StringTokenizer(emxTableRowId[i] ,"|");
          strManagedRevisionId = strTokenizer.nextToken();
          strRowInnerHtml = Product.getHTMLforInsertManagedSeries(context,strManagedRevisionId);
          DomainObject domObj = new DomainObject(strManagedRevisionId);

          Map mp = domObj.getInfo(context,slFT);
          if (mp.containsKey(strFTMainSelect)) {
              strUsage = (String)mp.get(strFTMainSelect);
          } else {
              strUsage = (String)mp.get(strFTSelect);
          }
         
          %>
          <script language="javascript" type="text/javaScript">
          
              var rowInnerHtml = "<%=XSSUtil.encodeForJavaScript(context,strRowInnerHtml)%>";
              var modelTemplateId = "<%=XSSUtil.encodeForJavaScript(context,modelTemplateId)%>";
              var managedRevisionId = "<%=XSSUtil.encodeForJavaScript(context,strManagedRevisionId)%>";
              var usage = "<%=XSSUtil.encodeForJavaScript(context,strUsage)%>";
              getTopWindow().getWindowOpener().addNewRow(rowInnerHtml,modelTemplateId,managedRevisionId,usage);
               
          </script>
          <%
      }
      %>
      <script language="javascript" type="text/javaScript">
           //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
           getTopWindow().closeWindow();
      </script>
      <%
  }
  else if(strMode.equalsIgnoreCase("checkDesignChangeConfirm")){
	     // Set RPE variable to skip the Cyclic condition Check 
  	boolean bdesignChange = false;
  	StringList sLRemMPRelIDs = new StringList();
	String setPrdId = emxGetParameter(request, "setProductID");
	if(setPrdId==null)
	{
		setPrdId="";
	}
	if(setPrdId.equalsIgnoreCase("SetPID"))
			{
				productId = emxGetParameter(request, "ProductId");
				session.setAttribute("ProductId",productId);		
			}
	String strEffectivityUnSelections = emxGetParameter(request, "effectivitydeselections");
	String strEffectivitySelections = emxGetParameter(request, "effectivityselections");	
	StringList slEffectivitySelections = new StringList();
	slEffectivitySelections.add(strEffectivitySelections);
	if(strEffectivityUnSelections==null){
		strEffectivityUnSelections = "";
	}
	// Tokenize the unselected managed Revisions to pass to the editEffecticity to make necessary disconnections.
	StringList slEffectivityDeSelections = new StringList();
	StringTokenizer strDeSelectionTok = new StringTokenizer(strEffectivityUnSelections, ",");
	String strDeselectedKey = null;
	while(strDeSelectionTok.hasMoreTokens()){
		strDeselectedKey = strDeSelectionTok.nextToken();
	    if(strDeselectedKey != null && !"".equalsIgnoreCase(strDeselectedKey)){
	    	slEffectivityDeSelections.add(strDeselectedKey);
	    }   
	}
	// Tokenize the unselected managed Revisions to pass to the editEffecticity to make necessary disconnections.
    StringList slEffectivitySelectionsIds = new StringList();
    StringTokenizer strTok = new StringTokenizer(strEffectivitySelections, ",");
    String strKey = null;
    String strTempManagedRevisionId=null;
    while(strTok.hasMoreTokens())
    {
        strKey = strTok.nextToken();
        if(strKey != null && !"".equalsIgnoreCase(strKey))
        {
        	strTempManagedRevisionId = strKey.substring(0,strKey.indexOf("|"));
        	if(!slEffectivitySelectionsIds.contains(strTempManagedRevisionId))
        	{
        		slEffectivitySelectionsIds.add(strTempManagedRevisionId);
        	}
            
        }   
    }
    
    String strProductId="";
  	if("edit".equalsIgnoreCase(strAction)){
		strProductId = (String)session.getAttribute("ProductId");
		DomainObject domProduct = new DomainObject(strProductId);				
		com.matrixone.apps.dmcplanning.Product product = new com.matrixone.apps.dmcplanning.Product(strProductId);
		bdesignChange = product.checkBeforeEditDesignEffectivity(context,slEffectivitySelectionsIds,slEffectivityDeSelections);	 
		 if(bdesignChange==true){
			    session.setAttribute("designChoice","yes");
			    }
  	}
  	else{
  	}
    out.println("bdesignChange=");
    out.println(bdesignChange);
    out.println("#");
   
   
   %>
 
   <%
  }
  else 
  {
	//do nothing
  } 
    if (bCloseWindow==true) {
      
         if(strMode.equals("create") || strMode.equals("editOptions"))
          {%>
          <script>
            parent.parent.window.closeWindow();
            </script>
         <%} 
      }
  }// End of the try block
  catch (Exception ex) {
      if(ex.toString()!=null && (ex.toString().trim()).length()>0)
          emxNavErrorObject.addMessage(ex.toString().trim());
       %>
       
       <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
           
      <%
      if(strExceptionMode.equalsIgnoreCase("createRevise")|| strExceptionMode.equalsIgnoreCase("create")) { %>
      <script>
      //IR-030718V6R2011 winow should not close on exception
      parent.window.location.href=parent.window.location.href;
      </script>
      <%
      }
      }// end of catch
   %> 
    
    
    
<%@page import="java.util.StringTokenizer"%>


<HTML>
    <BODY class="white" onload=loadUtil("<%=XSSUtil.encodeForJavaScript(context,strMode)%>","<%=XSSUtil.encodeForJavaScript(context,strAction)%>","<%=XSSUtil.encodeForJavaScript(context,String.valueOf(bCloseWindow))%>","<%=XSSUtil.encodeForJavaScript(context,strCreateParameter)%>")>
    <FORM name="ProductRevisionUtil" method="post" >
      <INPUT type="hidden" name="forNetscape" >
    <INPUT type="hidden" name="fromcontext" value="<xss:encodeForHTML><%=strFromContext%></xss:encodeForHTML>">
            &nbsp
    </FORM>
    </BODY>

  <SCRIPT language="javascript" type="text/javaScript">
    
    function loadUtil(strMode,strAction,bCloseWindow,strCreateParameter) {


var formName = document.ProductRevisionUtil;
      formName.target= "_top";
      var strTreeId = '<%=XSSUtil.encodeForJavaScript(context,strTreeId)%>';
      var strRelId = '<%=XSSUtil.encodeForJavaScript(context,strRelId)%>';
      var strCreateRevise = '<%=XSSUtil.encodeForJavaScript(context,strCreateRevise)%>';
      var strParentProductID = '<%=XSSUtil.encodeForJavaScript(context,strParentProductID)%>';
      var objectId = '<%=XSSUtil.encodeForJavaScript(context,strContextObjectId)%>';
      

       if(strMode == "featureSelect") 
      {
         formName.action="DesignEffectivityFS.jsp?FSmode=featureSelect&PRCFSParam2=createNewProductRevision&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&jsTreeID="+strTreeId+"&objectId="+objectId+"&functionality=ProductRevisionCreateFlatViewContentFSInstance&relId=&suiteKey=DMCPlanning&relId="+strRelId+"&createRevise="+strCreateRevise+"&ParentProductID="+strParentProductID;
         formName.submit();
      }

       if((strMode == "create" && strAction != "edit") || strMode == "createRevise")
       {
    	   <%
           String strProductRevisions = i18nStringNowUtil("DMCPlanning.Tree.ProductRevisions",bundle,acceptLanguage);
           %>
    	   var tree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
           var node = tree.findNodeByName("Product Revisions");
           var strURL = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,newRevisionId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,strTreeId)%>"
           if (node != null && node !="null" && node !="" && node !="undefined" && node !="NaN")
           {
               var strNodeID = node.nodeID;
               strURL = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,newRevisionId)%>&mode=insert&jsTreeID="+strNodeID;
           }
           //End of add by Enovia MatrixOne for bug #298012, 04/01/2005
           var Contentframe = findFrame(getTopWindow().window.getWindowOpener().getTopWindow(),"content");
           Contentframe.location = strURL;
           parent.parent.window.closeWindow();

       }
       if((strMode == "create" && strAction == "edit") )
       {
    	   parent.window.closeWindow();
       }
       
    }

    </SCRIPT>
    </HTML>  





