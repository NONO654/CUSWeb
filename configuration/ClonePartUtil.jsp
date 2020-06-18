<%--
  ClonePartUtil.jsp
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
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%@page import="com.matrixone.apps.configuration.ProductVariant" %>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.domain.DomainConstants,matrix.db.BusinessObject" %>
<%@page import="com.matrixone.apps.productline.*" %>
<%@page import="com.matrixone.apps.domain.util.MapList,com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@page import = "java.util.Hashtable"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "matrix.db.Context"%>
<%@page import = "matrix.util.StringList"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%!

public static boolean addAssebmly(MapList partList,String strTopLevelPart,HttpSession session,Context context){
    boolean bresult=true;
    try{ 
    	for(int i=0;i<partList.size();i++){
		    Map structureMap = (Map)partList.get(i);
		    MapList childrensMapList = (MapList)structureMap.get("children");  
		    String strFeatureId=structureMap.get("id").toString(); 
			Hashtable hsData = (Hashtable)session.getValue("modifiedFeatures");
		    DomainObject domFeatureObject = new DomainObject(strFeatureId);
    // to Get the Part Family
		    List gbomList = new MapList();
		    StringList selectable = new StringList();
		    selectable.addElement("from["+ProductLineConstants.RELATIONSHIP_GBOM_TO+"].to.id");
    
		    StringBuffer stbWhereClause = new StringBuffer();
		    stbWhereClause.append("from["+ProductLineConstants.RELATIONSHIP_GBOM_TO+"].to.type=='"+ProductLineConstants.TYPE_PART_FAMILY+"'");
	    
    		gbomList = domFeatureObject.getRelatedObjects(context,
                                                    ProductLineConstants.RELATIONSHIP_GBOM_FROM,
                                                    ProductLineConstants.TYPE_GBOM,
                                                    false,
                                                    true,
                                                    1,
                                                    selectable,
                                                    null,
                                                    stbWhereClause.toString(),
                                                    null,
                                                    null,
                                                    null,
                                                    null);

		    // first condition checks if it has part family attached to it and second cheks if part is attached or not
	        if((gbomList.size()>0)){
	            if(hsData!=null){
	                Map dataMap=(Map)hsData.get(strFeatureId);
		            String strPartId=null;
				    strPartId=dataMap.get("partId").toString();
				    if(strPartId==null){
				        bresult=false;
				        return bresult;
				    } 
	            }else{
	                bresult=false;
			        return bresult;
	            }
	           
	        }
    
			if(hsData!=null && hsData.containsKey(strFeatureId)){
	    
	    			Map dataMap=(Map)hsData.get(strFeatureId);
				    String strPartId=null;
				    strPartId=dataMap.get("partId").toString();

	   
				    DomainObject objTopLevelPart= new DomainObject(strTopLevelPart);
				    DomainObject objSubPart= new DomainObject(strPartId);
				    objTopLevelPart.connectTo(context,ProductLineConstants.RELATIONSHIP_EBOM,objSubPart);
				    if(childrensMapList.size()>0){
					        addAssebmly(childrensMapList,strPartId,session,context);
				    }
			}
    	}
	    }catch(Exception e)
	    {
	        
	        session.putValue("error.message", e.getMessage());

	    }
    return bresult;
	}
%>
<%
  String strMode = emxGetParameter(request,"mode");
  String strTableRowIds = emxGetParameter(request, "emxTableRowId");
  String strPartId  = emxGetParameter(request, "objectId");
  String partOid = emxGetParameter(request,"emxTableRowId");
  String strToolTipCreate = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNew",context.getSession().getLanguage());
  String strToolTipAdd = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExisting", context.getSession().getLanguage());
  String strToolTipGenerate = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerate",context.getSession().getLanguage());
  
  String strToolTipInvalidQuantity = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.InvalidQuantity",context.getSession().getLanguage());
  String strToolTipHigherRevision =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.HigherRevision",context.getSession().getLanguage());
  String strToolTipObsoletePart = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.ObsoletePart",context.getSession().getLanguage());
  String strToolTipEBOMDifferent = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.EBOMDifferent",context.getSession().getLanguage());
  
  
  if(partOid!=null){
	  StringTokenizer strToken = new StringTokenizer(partOid,"|");
	  partOid = strToken.nextToken();
  }
  String strPartIdFromSession = (String)session.getAttribute("partId");
  if(strPartIdFromSession!=null){
      strPartId=strPartIdFromSession;
  }
  String featureId                   = "";
  String duplicate                   = "";
  String generate                    = "";
  String parentId                    = "";
  String level                    = "";
  String quantity                    = "";
  String isQuantityInvalid = "";
  String displayGenerateIcon = "";
  HashMap hmCurrentModifiedFeatureFromSession = (HashMap)session.getValue("currentmodifiedfeature");
  if(hmCurrentModifiedFeatureFromSession!=null && hmCurrentModifiedFeatureFromSession.containsKey("mode") && hmCurrentModifiedFeatureFromSession.size()>0) {
      strMode = emxGetParameter(request,"mode");
      if(strMode==null||strMode.length()<=0){
          strMode                   = (String)hmCurrentModifiedFeatureFromSession.get("mode");    
      }
  
    featureId                   = (String)hmCurrentModifiedFeatureFromSession.get("featureId");
    duplicate                   = (String)hmCurrentModifiedFeatureFromSession.get("duplicate");
    generate                    = (String)hmCurrentModifiedFeatureFromSession.get("generate");
	level                    = (String)hmCurrentModifiedFeatureFromSession.get("level");
	isQuantityInvalid  = (String)hmCurrentModifiedFeatureFromSession.get("isQuantityInvalid");
	displayGenerateIcon  = (String)hmCurrentModifiedFeatureFromSession.get("displayGenerateIcon");
	parentId                    = (String)hmCurrentModifiedFeatureFromSession.get("parentId");
 }
  else {
      if(("createpart".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("addexisting".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("generate".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("generatebyreplace".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("replacebycreatepart".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("replacebyaddexisting".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("quantity".equalsIgnoreCase(emxGetParameter(request, "mode"))) ||
         ("duplicate".equalsIgnoreCase(emxGetParameter(request, "mode")))) 
      {
          HashMap hmCurrentModifiedFeature = new HashMap();
	      hmCurrentModifiedFeature.put("mode",emxGetParameter(request, "mode"));
	      hmCurrentModifiedFeature.put("featureId",emxGetParameter(request, "featureId"));
	      hmCurrentModifiedFeature.put("duplicate",emxGetParameter(request, "duplicate"));
	      hmCurrentModifiedFeature.put("generate",emxGetParameter(request, "generate"));
	      hmCurrentModifiedFeature.put("parentId",emxGetParameter(request, "parentId"));
		  hmCurrentModifiedFeature.put("level",emxGetParameter(request, "level"));
		  hmCurrentModifiedFeature.put("isQuantityInvalid",emxGetParameter(request, "isQuantityInvalid"));
		  hmCurrentModifiedFeature.put("displayGenerateIcon",emxGetParameter(request, "displayGenerateIcon"));
		  hmCurrentModifiedFeature.put("quantity",emxGetParameter(request, "quantity"));
	      session.putValue("currentmodifiedfeature",hmCurrentModifiedFeature);
	      hmCurrentModifiedFeatureFromSession = (HashMap)session.getValue("currentmodifiedfeature");
	  	strMode                   = (String)hmCurrentModifiedFeatureFromSession.get("mode");
	    
	      featureId                   = (String)hmCurrentModifiedFeatureFromSession.get("featureId");
	      duplicate                   = (String)hmCurrentModifiedFeatureFromSession.get("duplicate");
	      generate                    = (String)hmCurrentModifiedFeatureFromSession.get("generate");
	      parentId                    = (String)hmCurrentModifiedFeatureFromSession.get("parentId");
		  level                    = (String)hmCurrentModifiedFeatureFromSession.get("level");
		  quantity                    = (String)hmCurrentModifiedFeatureFromSession.get("quantity");
		  isQuantityInvalid  = (String)hmCurrentModifiedFeatureFromSession.get("isQuantityInvalid");
		  displayGenerateIcon  = (String)hmCurrentModifiedFeatureFromSession.get("displayGenerateIcon");
	      
	  }
      else {
      	strMode = emxGetParameter(request, "mode");
      }
  }
  Hashtable modifiedFeatures = new Hashtable();
  ProductVariant productVariantBean = (ProductVariant) DomainObject.newInstance(context,ConfigurationConstants.TYPE_PRODUCT_VARIANT,"Configuration");  
  boolean  hasTechnical = false;
  boolean bIsError = false;
  try
  {
    if(strMode.equalsIgnoreCase("ClonePart"))
    {
        hasTechnical = productVariantBean.hasTechnicalFeatures(context,strTableRowIds);
            %>
            <script language="javascript" type="text/javaScript">
            var strFeatureProductId = '<%=XSSUtil.encodeForJavaScript(context,strTableRowIds)%>';
            var strPartId = '<%=XSSUtil.encodeForJavaScript(context,strPartId)%>';
          //XSSOK -JSP is DEPRECATED- will be removed as part of JSP REDUCTION
      		var hasTechnical = '<%=hasTechnical%>';
            var submitURL= null;
  	        if (hasTechnical=="false")
 	        {
	            var AlertMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.ClonePart.NoTechnicalFeatures",bundle,acceptLanguage)%>"
		        alert(AlertMsg);
		        submitURL = "../common/emxFullSearch.jsp?objectId="+strPartId+"&field=TYPES=type_LogicalFeature,type_HardwareProduct,type_SoftwareProduct,type_ServiceProduct&table=FTRFeatureSearchResultsTable&selection=single&showInitialResults=false&hideHeader=true&submitURL=../configuration/SearchUtil.jsp?functionality=ClonePart";
		        getTopWindow().location.href=submitURL;
      		}
      		else{
	            submitURL='../configuration/ClonePartFS.jsp?objectId='+strFeatureProductId+'&partId='+strPartId;
	            getTopWindow().location.href=submitURL;
      		}
            </script>
            <%
    }
    else  if(strMode.equalsIgnoreCase("clonePartGenerateMarketingEBOM")){
        String timeStamp = emxGetParameter(request, "timeStamp");
        DomainObject objPart= new DomainObject(strPartId);
        String strContextPartID = strPartId;
                
        MapList partList =  indentedTableBean.getObjectList(timeStamp);
       
        HashMap structureMap = (HashMap)partList.get(0);
        MapList childrensMapList = (MapList)structureMap.get("children");        
        boolean isAssmblyAdd=addAssebmly(childrensMapList,strPartId,session,context);
        if(!isAssmblyAdd){
            %>
            <script language="javascript" type="text/javaScript">
                alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.NoPartFamily</emxUtil:i18n>");
            </script>
            <%
            }
            else{
                %>
    	        session.removeValue("modifiedFeatures");
    	        <script language="javascript" type="text/javaScript">
    	        getTopWindow().window.closeWindow();
    	        var strURL    = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strContextPartID)%>&mode=replace";
                // //IR-097229V6R2012
		var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
                contentFrame.location.href = strURL;
    	        //parent.parent.window.getWindowOpener().parent.parent.document.location=strURL;
               </script>
    <%
            }
            
        }
    else  if((strMode.equalsIgnoreCase("generate"))||(strMode.equalsIgnoreCase("generatebyreplace"))){

		  //--------create part from part family start
				
			  Map mapTemp = new HashMap();
              Map programMap = new HashMap();
              String[] arrJPOArguments=new String[1];
              
				
				mapTemp.put("strMode",strMode.trim());
				
				mapTemp.put("featureId",featureId.trim());
				
				
              MapList objectList1 = new MapList();
              objectList1.add(mapTemp);
              programMap.put("objectList", objectList1);
              arrJPOArguments = JPO.packArgs(programMap);
				
				Object ob = JPO.invoke(context, "emxProductConfigurationEBOMBase", null, "generatePart", arrJPOArguments,DomainObject.class);
				
				
				DomainObject s = (DomainObject) ob;
				
				partOid = s.getInfo(context,"id");
              //DomainObject domPartObject = create(context, sDefaultType,  "",  "", sDefaultPolicy, strVaultName, context.getUser(), PartFamilyId, fId, "PartFamily", false, true,mapGBOMAttributes);
             
		  //--------create part from part family end
	      modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
		if(modifiedFeatures == null) {
		    modifiedFeatures = new Hashtable();
		}
  	    HashMap hmModifiedData = new HashMap();
  	    hmModifiedData.put("mode",strMode);
		hmModifiedData.put("partId",partOid);
		hmModifiedData.put("generate",generate);
		hmModifiedData.put("duplicate",duplicate);
		hmModifiedData.put("featureId",featureId);
		hmModifiedData.put("parentId",parentId);
   	
		//modifiedFeatures.add(hmModifiedData);
		modifiedFeatures.put(featureId,hmModifiedData);
		session.putValue("modifiedFeatures",modifiedFeatures);
		session.removeValue("currentmodifiedfeature");
		//cell refresh start
			String partName = new DomainObject(partOid).getInfo(context,"name");
			
			String partRevision = new DomainObject(partOid).getInfo(context,"revision");
			
			String partState = new DomainObject(partOid).getInfo(context,"current");
			
			String partType = new DomainObject(partOid).getInfo(context,"type");
			
			String higherRevision = "";
			
			String isObsolete = "";
			
			
			if(!new DomainObject(partOid).isLastRevision(context)){
				higherRevision = "true";
			}
			
			if((new DomainObject(partOid).getInfo(context,ProductLineConstants.SELECT_CURRENT)).equalsIgnoreCase("obsolete")){
				isObsolete = "true";
			}
			
			mapTemp = new HashMap();
              programMap = new HashMap();
              arrJPOArguments=new String[1];
              mapTemp.put(DomainConstants.SELECT_ID,partOid.trim());
				mapTemp.put("featureId",featureId.trim());
				
				mapTemp.put("parentId",parentId.trim());
				
              objectList1 = new MapList();
              objectList1.add(mapTemp);
              programMap.put("objectList", objectList1);
              arrJPOArguments = JPO.packArgs(programMap);
				
				boolean isEBOMDifferent = false;
				Object obj = JPO.invoke(context, "emxProductConfigurationEBOMBase", null, "callIsEBOMDifferent", arrJPOArguments,Boolean.class);
				
				Boolean s1 = (Boolean) obj;
				
				isEBOMDifferent = s1.booleanValue();
				
              
  		%>
  		 <script language="javascript" type="text/javaScript">
  		 //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
  		    var level = '<%=level%>';
			
			var newPart = '<%=XSSUtil.encodeForJavaScript(context,partName)%>';
			
			var newRevision = '<%=XSSUtil.encodeForJavaScript(context,partRevision)%>';
			
			var newState = '<%=XSSUtil.encodeForJavaScript(context,partState)%>';
			
			var newType = '<%=XSSUtil.encodeForJavaScript(context,partType)%>';
			
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var isQuantityInvalid = '<%=isQuantityInvalid%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var displayGenerateIcon = '<%=displayGenerateIcon%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var higherRevision = '<%=higherRevision%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var isObsolete = '<%=isObsolete%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var isEBOMDifferent = '<%=isEBOMDifferent%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var featureId = '<%=featureId%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var parentId = '<%=parentId%>';
			var visualCue='';
			var actionIcon='';

			
         
			var partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForURL(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForURL(context,partOid)%>'+'\')"> '+newPart+'</a></c>';
			
			var partRevision = '<c>'+newRevision+'</c>';
			var partState = '<c>'+newState+'</c>';
			var partType = '<c>'+newType+'</c>';
			var selectedAction = '<c a="&lt;img src=&quot;../common/images/iconActionCreateNewPart.gif&quot;/&gt;"><img src="../common/images/iconActionCreateNewPart.gif"/></c>';
			//logic to refresh visual cue cell start  //IR-097229V6R2012
			if(isQuantityInvalid=="true"){
				
				visualCue = '<img src="../common/images/iconStatusValidationError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipInvalidQuantity%></xss:encodeForHTMLAttribute>"/>';
				
				
			}
			if(higherRevision=="true"){
				visualCue = visualCue + '<img src="../common/images/iconSmallHigherRevision.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipHigherRevision%></xss:encodeForHTMLAttribute>"/>';
				
			}
			
			if(isObsolete=="true"){
				visualCue = visualCue + '<img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipObsoletePart%></xss:encodeForHTMLAttribute>"/>';
				
			}
			
			if(isEBOMDifferent=="true"){
				
				visualCue = visualCue + '<img src="../common/images/iconStatusValidationError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipEBOMDifferent%></xss:encodeForHTMLAttribute>"/>';
				
			}
			var visualCueColumn = '<c>'+visualCue+'</c>';
			//logic to refresh visual cue cell end
			//logic to refresh Action Icon cell start
			actionIcon = '<img src="../common/images/iconActionReplaceWithNewPart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipCreate%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/>';
			actionIcon = actionIcon + '<img src="../common/images/iconActionReplaceWithExistingPart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipAdd%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/>';
			if(displayGenerateIcon=="true"){
				actionIcon = actionIcon + '<img src="../common/images/iconActionReplaceWithGeneratedpart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipGenerate%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=true\');"/>';
			}
		
			var actionIconColumn = '<c>'+actionIcon+'</c>';
			
			//logic to refresh Action Icon cell end

			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partName,'3');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partRevision,'6');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partState,'7');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partType,'8');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,visualCueColumn,'5');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,actionIconColumn,'4');
			window.closeWindow();
			</script>
		<%
    }
    else if(strMode.equalsIgnoreCase("addexisting") || strMode.equalsIgnoreCase("replacebyaddexisting")) {

  		if(partOid==null) { 
  		%>
  		  <script language="javascript" type="text/javaScript">
		var strURL    = "../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_DevelopmentPart.state_Obsolete:CURRENT!=policy_StandardPart.state_Obsolete&HelpMarker=emxhelpfullsearch&showInitialResults=false&table=FTRFeatureSearchResultsTable&hideHeader=true";
        strURL        = strURL  + "&objectId=<%=XSSUtil.encodeForURL(context,featureId)%>";
        strURL        = strURL  + "&suiteKey=Configuration";
  		strURL        = strURL  + "&selection=single";
  		strURL        = strURL  + "&submitURL=../configuration/ClonePartUtil.jsp?mode="+'<%=XSSUtil.encodeForURL(context,strMode)%>';
  	
  		document.location.href = strURL;
  		  </script>
  		<% } else {
			
  		  modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
  		if(modifiedFeatures == null) {
  		    modifiedFeatures = new Hashtable();
  		}
  		HashMap hmModifiedData = new HashMap();
  		hmModifiedData.put("mode",strMode);
		hmModifiedData.put("partId",partOid);
		hmModifiedData.put("generate",generate);
		hmModifiedData.put("duplicate",duplicate);
		hmModifiedData.put("featureId",featureId);
		hmModifiedData.put("featureId",featureId);
		hmModifiedData.put("parentId",parentId);
	
		modifiedFeatures.put(featureId,hmModifiedData);
		session.putValue("modifiedFeatures",modifiedFeatures);
		session.removeValue("currentmodifiedfeature");
		//cell refresh start
		String partName = new DomainObject(partOid).getInfo(context,"name");
		
		String partRevision = new DomainObject(partOid).getInfo(context,"revision");
		
		String partState = new DomainObject(partOid).getInfo(context,"current");
		
		String partType = new DomainObject(partOid).getInfo(context,"type");
		
		String higherRevision = "";
		
		String isObsolete = "";
		
		
		if(!new DomainObject(partOid).isLastRevision(context)){
			higherRevision = "true";
		}
		
		if((new DomainObject(partOid).getInfo(context,ProductLineConstants.SELECT_CURRENT)).equalsIgnoreCase("obsolete")){
			isObsolete = "true";
		}
		
		Map mapTemp = new HashMap();
            Map programMap = new HashMap();
            String[] arrJPOArguments=new String[1];
            mapTemp.put(DomainConstants.SELECT_ID,partOid.trim());
			mapTemp.put("featureId",featureId.trim());
			
			mapTemp.put("parentId",parentId.trim());
			
            MapList objectList1 = new MapList();
            objectList1.add(mapTemp);
            programMap.put("objectList", objectList1);
            arrJPOArguments = JPO.packArgs(programMap);
			
			
			
            
		%>
		 <script language="javascript" type="text/javaScript">
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release. 
		var level = '<%=level%>';
		
		var newPart = '<%=XSSUtil.encodeForJavaScript(context,partName)%>';
		
		var newRevision = '<%=XSSUtil.encodeForJavaScript(context,partRevision)%>';
		
		var newState = '<%=XSSUtil.encodeForJavaScript(context,partState)%>';
		
		var newType = '<%=XSSUtil.encodeForJavaScript(context,partType)%>';
		
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
		var isQuantityInvalid = '<%=isQuantityInvalid%>';
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
		var displayGenerateIcon = '<%=displayGenerateIcon%>';
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
		var higherRevision = '<%=higherRevision%>';
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
		var isObsolete = '<%=isObsolete%>';
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
		var featureId = '<%=featureId%>';
		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
		var parentId = '<%=parentId%>';
		var visualCue='';
		var actionIcon='';

		
       
		var partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForURL(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForURL(context,partOid)%>'+'\')"> '+newPart+'</a></c>';
		
		var partRevision = '<c>'+newRevision+'</c>';
		var partState = '<c>'+newState+'</c>';
		var partType = '<c>'+newType+'</c>';
		var selectedAction = '<c a="&lt;img src=&quot;../common/images/iconActionCreateNewPart.gif&quot;/&gt;"><img src="../common/images/iconActionCreateNewPart.gif"/></c>';
		//logic to refresh visual cue cell start
		if(isQuantityInvalid=="true"){
			
			visualCue = '<img src="../common/images/iconStatusValidationError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipInvalidQuantity%></xss:encodeForHTMLAttribute>"/>';
			
		}
		if(higherRevision=="true"){
			visualCue = visualCue + '<img src="../common/images/iconSmallHigherRevision.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipHigherRevision%></xss:encodeForHTMLAttribute>"/>';
			
		}
		
		if(isObsolete=="true"){
			visualCue = visualCue + '<img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipObsoletePart%></xss:encodeForHTMLAttribute>"/>';
			
		}
		
		
		var visualCueColumn = '<c>'+visualCue+'</c>';
		//logic to refresh visual cue cell end
		//logic to refresh Action Icon cell start
		actionIcon = '<img src="../common/images/iconActionReplaceWithNewPart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipCreate%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/>';
		actionIcon = actionIcon + '<img src="../common/images/iconActionReplaceWithExistingPart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipAdd%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/>';
		if(displayGenerateIcon=="true"){
			actionIcon = actionIcon + '<img src="../common/images/iconActionReplaceWithGeneratedpart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipGenerate%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=true\');"/>';
		}

		var actionIconColumn = '<c>'+actionIcon+'</c>';
		
		//logic to refresh Action Icon cell end
	
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partName,'3');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partRevision,'6');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partState,'7');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partType,'8');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,visualCueColumn,'5');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,actionIconColumn,'4');
//			window.parent.window.close();
            getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
		  </script>
	<%
		
		
  		
		}
	}
    else if(strMode.equalsIgnoreCase("createpart") || strMode.equalsIgnoreCase("replacebycreatepart")) {

		  
  		if(partOid==null) { 
  		session.setAttribute("submitURL","../configuration/ClonePartUtil.jsp");
  		%>
  		  <script language="javascript" type="text/javaScript">
  		var strURL= "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart&header=CreatePart&type=type_Part&suiteKey=EngineeringCentral&  StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=FTR&createJPO=emxPart:createPartJPO&preProcessJavaScript=setRDO";
        
  		document.location.href = strURL;
  		 </script>
  		<% } else {
      		    
      		
      		modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
    		if(modifiedFeatures == null) {
    		    modifiedFeatures = new Hashtable();
    		}
      		HashMap hmModifiedData = new HashMap();
      		hmModifiedData.put("mode",strMode);
    		hmModifiedData.put("partId",partOid);
    		hmModifiedData.put("generate",generate);
    		hmModifiedData.put("duplicate",duplicate);
    		hmModifiedData.put("featureId",featureId);
			hmModifiedData.put("parentId",parentId);
    		//modifiedFeatures.add(hmModifiedData);
    		modifiedFeatures.put(featureId,hmModifiedData);
    		session.putValue("modifiedFeatures",modifiedFeatures);
    		session.removeValue("currentmodifiedfeature");
			//cell refresh start
			String partName = new DomainObject(partOid).getInfo(context,"name");
			String partRevision = new DomainObject(partOid).getInfo(context,"revision");
			String partState = new DomainObject(partOid).getInfo(context,"current");
			String partType = new DomainObject(partOid).getInfo(context,"type");
			String higherRevision = "";
			String isObsolete = "";
			
			if(!new DomainObject(partOid).isLastRevision(context)){
				higherRevision = "true";
			}
			if((new DomainObject(partOid).getInfo(context,ProductLineConstants.SELECT_CURRENT)).equalsIgnoreCase("obsolete")){
				isObsolete = "true";
			}
			Map mapTemp = new HashMap();
                Map programMap = new HashMap();
                String[] arrJPOArguments=new String[1];
                mapTemp.put(DomainConstants.SELECT_ID,partOid.trim());
				mapTemp.put("featureId",featureId.trim());
				
				mapTemp.put("parentId",parentId.trim());
                MapList objectList1 = new MapList();
                objectList1.add(mapTemp);
                programMap.put("objectList", objectList1);
                arrJPOArguments = JPO.packArgs(programMap);
				
				
				
                
    		%>
    		 <script language="javascript" type="text/javaScript">
    		//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
    		var level = '<%=level%>';
			var newPart = '<%=XSSUtil.encodeForJavaScript(context,partName)%>';
			var newRevision = '<%=XSSUtil.encodeForJavaScript(context,partRevision)%>';
			var newState = '<%=XSSUtil.encodeForJavaScript(context,partState)%>';
			var newType = '<%=XSSUtil.encodeForJavaScript(context,partType)%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var isQuantityInvalid = '<%=isQuantityInvalid%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var displayGenerateIcon = '<%=displayGenerateIcon%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var higherRevision = '<%=higherRevision%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var isObsolete = '<%=isObsolete%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var featureId = '<%=featureId%>';
			//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
			var parentId = '<%=parentId%>';
			var visualCue='';
			var actionIcon='';

			
           
			var partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForURL(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForURL(context,partOid)%>'+'\')"> '+newPart+'</a></c>';
			
			var partRevision = '<c>'+newRevision+'</c>';
			var partState = '<c>'+newState+'</c>';
			var partType = '<c>'+newType+'</c>';
			var selectedAction = '<c a="&lt;img src=&quot;../common/images/iconActionCreateNewPart.gif&quot;/&gt;"><img src="../common/images/iconActionCreateNewPart.gif"/></c>';
			//logic to refresh visual cue cell start
			if(isQuantityInvalid=="true"){
				
				visualCue = '<img src="../common/images/iconStatusValidationError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipInvalidQuantity%></xss:encodeForHTMLAttribute>"/>';
				
			}
			if(higherRevision=="true"){
				visualCue = visualCue + '<img src="../common/images/iconSmallHigherRevision.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipHigherRevision%></xss:encodeForHTMLAttribute>"/>';
				
			}
			
			if(isObsolete=="true"){
				visualCue = visualCue + '<img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipObsoletePart%></xss:encodeForHTMLAttribute>"/>';
				
			}
			
	
			var visualCueColumn = '<c>'+visualCue+'</c>';
			//logic to refresh visual cue cell end
			//logic to refresh Action Icon cell start
			actionIcon = '<img src="../common/images/iconActionReplaceWithNewPart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipCreate%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/>';
			actionIcon = actionIcon + '<img src="../common/images/iconActionReplaceWithExistingPart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipAdd%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/>';
			if(displayGenerateIcon=="true"){
				actionIcon = actionIcon + '<img src="../common/images/iconActionReplaceWithGeneratedpart.gif" border="0" align="middle" TITLE="<xss:encodeForHTMLAttribute><%=strToolTipGenerate%></xss:encodeForHTMLAttribute>" onclick="javascript:showDialog(\'../configuration/ClonePartUtil.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=true\');"/>';
			}
			var actionIconColumn = '<c>'+actionIcon+'</c>';
			
			//logic to refresh Action Icon cell end
			

			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partName,'3');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partRevision,'6');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partState,'7');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,partType,'8');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,visualCueColumn,'5');
			getTopWindow().window.getWindowOpener().editableTable.updateXMLByRowId(level,actionIconColumn,'4');
			getTopWindow().closeWindow();
			 </script>
		<%
    		}
  
    if(strMode.equals("cleanupsession")) 
    {
		session.removeAttribute("productConfiguration");
		Hashtable hsModifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
        if(hsModifiedFeatures!=null && hsModifiedFeatures.size()>0) {
			Map mapTemp = new HashMap();
            Enumeration en = hsModifiedFeatures.keys();
			while(en.hasMoreElements()){
				mapTemp = (HashMap)hsModifiedFeatures.get(en.nextElement());
	            String fId = (String)mapTemp.get("featureId");
	            String mode = (String)mapTemp.get("mode");
	            String part = (String)mapTemp.get("partId");
				if(mode.equalsIgnoreCase("createpart") || mode.equalsIgnoreCase("replacebycreatepart") || mode.equalsIgnoreCase("generate") || mode.equalsIgnoreCase("generatebyreplace")) 
				{
					DomainObject objPart = new DomainObject(part);
					objPart.delete(context);
				}
			}
	        session.removeValue("modifiedFeatures");
        }

  }
  }
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
    //emxNavErrorObject.addMessage(e.toString().trim());
  }// End of main Try-catck block

%>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
