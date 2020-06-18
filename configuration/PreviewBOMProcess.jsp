<%-- PreviewBOMProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/PreviewBOMProcess.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="com.matrixone.apps.domain.util.MapList" %>
<%@ page import="com.matrixone.apps.domain.DomainObject" %>
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>
<%@ page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@ page import="com.matrixone.apps.configuration.ProductConfiguration"%>
<%@ page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@ page import="com.matrixone.apps.configuration.Part"%>
<%@ page import= "com.matrixone.apps.productline.ProductLineUtil"%>
<%@ page import= "com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.List"%>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript">

// Removes leading and ending whitespaces
function trim( value )
{
  return LTrim(RTrim(value));
}
 
function LTrim( value )
{
  var re = /\s*((\S+\s*)*)/;
  return value.replace(re, "$1");
}

// Removes ending whitespaces
function RTrim( value ) 
{
	var re = /((\s*\S+)*)\s*/;
	return value.replace(re, "$1");
}

function updateXMLByRowId(frame,rowId,xmlCellData,columnId){
	var contentFrame = "";
	var oXML = "";	
	if(frame == "content"){
		contentFrame = findFrame(getTopWindow(),"content");
	} else {
		contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
	}
	if(contentFrame != undefined && contentFrame != null){
		oXML = contentFrame.oXML;
		if(oXML != null && oXML != undefined){
			var oldColumn = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id = '" + rowId + "']/c["+columnId+"]");
			var row = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id = '" + rowId + "']");
			var objDOM = emxUICore.createXMLDOM();
			objDOM.loadXML(xmlCellData);
			row.replaceChild(objDOM.documentElement,oldColumn);
		}
	}
}

</script>

<%
try
{ 
      //************************************strMode*****************************
      String strMode = emxGetParameter(request, "mode");
      //************************************strMode*****************************
      String partOid = emxGetParameter(request, "emxTableRowId");
      ProductConfiguration pcBean = new ProductConfiguration();
      String featureId                   = "";
      String duplicate                   = "";
      String generate                    = "";
      String parentId                    = "";
      String level                       = "";
      String quantity                    = "";
      String strPartMode                 = "";
      String strPartFamilyId = "";
      String isQuantityInvalid = "";
      String displayGenerateIcon = "";
      String isUsedInBOM = "";
      String strLanguage=context.getSession().getLanguage();
      String strLFParentId = "";
      String strLFisLeaf = "";
      String strResolvedPart = "";
      String strResolvedPartRelId = "";      
      String strDuplicateParts = "";
      String strForcePartReuse = "";
      
      boolean isMobileMode = UINavigatorUtil.isMobile(context);
      boolean isFTRUser = ConfigurationUtil.isFTRUser(context);
	  boolean isCMMUser = ConfigurationUtil.isCMMUser(context);
      String editLink="true";
      String mode="edit";
      if(isMobileMode||(!isFTRUser&&!isCMMUser)){
         editLink="false";
         mode="view";
      }

      boolean isECInstalled = false;
      isECInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMEngineering",false,null,null);
      HashMap hmCurrentModifiedFeatureFromSession = (HashMap)session.getValue("currentmodifiedfeature");
      if(hmCurrentModifiedFeatureFromSession!=null && hmCurrentModifiedFeatureFromSession.size()>0) 
      {
        strMode = emxGetParameter(request, "mode");
        if(strMode==null || strMode.length()==0)
        {
              strMode                     = (String)hmCurrentModifiedFeatureFromSession.get("mode");
              featureId                   = (String)hmCurrentModifiedFeatureFromSession.get("featureId");
              duplicate                   = (String)hmCurrentModifiedFeatureFromSession.get("duplicate");
              generate                    = (String)hmCurrentModifiedFeatureFromSession.get("generate");
              level                       = (String)hmCurrentModifiedFeatureFromSession.get("level");
              isQuantityInvalid           = (String)hmCurrentModifiedFeatureFromSession.get("isQuantityInvalid");
              displayGenerateIcon         = (String)hmCurrentModifiedFeatureFromSession.get("displayGenerateIcon");
              isUsedInBOM                 = (String)hmCurrentModifiedFeatureFromSession.get("isUsedInBOM");
              parentId                    = (String)hmCurrentModifiedFeatureFromSession.get("parentId");
              strPartMode                 = (String)hmCurrentModifiedFeatureFromSession.get("PartMode");
              strPartFamilyId                 = (String)hmCurrentModifiedFeatureFromSession.get("partFamilyId");
              
              // IVU - BOM XML
              strLFParentId               = (String)hmCurrentModifiedFeatureFromSession.get("LFParentID");
              strLFisLeaf                 = (String)hmCurrentModifiedFeatureFromSession.get("isLFLeaf");
              strResolvedPart			  = (String)hmCurrentModifiedFeatureFromSession.get("ResolvedPart");
              strResolvedPartRelId	 	  = (String)hmCurrentModifiedFeatureFromSession.get("ResolvedPartRelID");
              strDuplicateParts			  = (String)hmCurrentModifiedFeatureFromSession.get("DuplicateParts");
              strForcePartReuse			  = (String)hmCurrentModifiedFeatureFromSession.get("ForcePartReuse");
              
        }
        else
        {
              session.removeValue("currentmodifiedfeature");
              HashMap hmCurrentModifiedFeature = new HashMap();
              hmCurrentModifiedFeature.put("mode",emxGetParameter(request, "mode"));
              hmCurrentModifiedFeature.put("featureId",emxGetParameter(request, "featureId"));
              hmCurrentModifiedFeature.put("duplicate",emxGetParameter(request, "duplicate"));
              hmCurrentModifiedFeature.put("generate",emxGetParameter(request, "generate"));
              hmCurrentModifiedFeature.put("parentId",emxGetParameter(request, "parentId"));
              hmCurrentModifiedFeature.put("level",emxGetParameter(request, "level"));
              hmCurrentModifiedFeature.put("isQuantityInvalid",emxGetParameter(request, "isQuantityInvalid"));
              hmCurrentModifiedFeature.put("displayGenerateIcon",emxGetParameter(request, "displayGenerateIcon"));
              hmCurrentModifiedFeature.put("isUsedInBOM",emxGetParameter(request, "isUsedInBOM"));
              hmCurrentModifiedFeature.put("quantity",emxGetParameter(request, "quantity"));
              hmCurrentModifiedFeature.put("PartMode",emxGetParameter(request, "PartMode"));
              hmCurrentModifiedFeature.put("partFamilyId",emxGetParameter(request, "partFamilyId"));
              
              // IVU - BOM XML
              // Add the LFParent and the Leaf Level
              hmCurrentModifiedFeature.put("LFParentID",emxGetParameter(request, "LFParentID"));
              hmCurrentModifiedFeature.put("isLFLeaf",emxGetParameter(request, "isLFLeaf"));
              hmCurrentModifiedFeature.put("ResolvedPart",emxGetParameter(request, "ResolvedPart"));   
              hmCurrentModifiedFeature.put("DuplicateParts",emxGetParameter(request, "DuplicateParts"));
              hmCurrentModifiedFeature.put("ResolvedPartRelID",emxGetParameter(request, "ResolvedPartRelID"));
              hmCurrentModifiedFeature.put("ForcePartReuse",emxGetParameter(request, "ForcePartReuse"));
              
              
              session.putValue("currentmodifiedfeature",hmCurrentModifiedFeature);
              hmCurrentModifiedFeatureFromSession = (HashMap)session.getValue("currentmodifiedfeature");
              strMode                     = (String)hmCurrentModifiedFeatureFromSession.get("mode");
              featureId                   = (String)hmCurrentModifiedFeatureFromSession.get("featureId");
              duplicate                   = (String)hmCurrentModifiedFeatureFromSession.get("duplicate");
              generate                    = (String)hmCurrentModifiedFeatureFromSession.get("generate");
              parentId                    = (String)hmCurrentModifiedFeatureFromSession.get("parentId");
              level                       = (String)hmCurrentModifiedFeatureFromSession.get("level");
              quantity                    = (String)hmCurrentModifiedFeatureFromSession.get("quantity");
              isQuantityInvalid           = (String)hmCurrentModifiedFeatureFromSession.get("isQuantityInvalid");
              displayGenerateIcon         = (String)hmCurrentModifiedFeatureFromSession.get("displayGenerateIcon");
              isUsedInBOM                 = (String)hmCurrentModifiedFeatureFromSession.get("isUsedInBOM");
              strPartMode                 = (String)hmCurrentModifiedFeatureFromSession.get("PartMode");
              strPartFamilyId 			  = (String)hmCurrentModifiedFeatureFromSession.get("partFamilyId");
              
              // IVU - BOM XML
              strLFParentId               = (String)hmCurrentModifiedFeatureFromSession.get("LFParentID");
              strLFisLeaf                 = (String)hmCurrentModifiedFeatureFromSession.get("isLFLeaf");
              strResolvedPart			  = (String)hmCurrentModifiedFeatureFromSession.get("ResolvedPart");      
              strDuplicateParts			  = (String)hmCurrentModifiedFeatureFromSession.get("DuplicateParts");
              strResolvedPartRelId			  = (String)hmCurrentModifiedFeatureFromSession.get("ResolvedPartRelID");
              strForcePartReuse			  = (String)hmCurrentModifiedFeatureFromSession.get("ForcePartReuse");
              
          }
      }else
      {                       
              featureId                   = emxGetParameter(request, "featureId");
              duplicate                   = emxGetParameter(request, "duplicate");
              generate                    = emxGetParameter(request, "generate");
              parentId                    = emxGetParameter(request, "parentId");
              level                    = emxGetParameter(request, "level");
              quantity                    = emxGetParameter(request, "quantity");
              isQuantityInvalid  = emxGetParameter(request, "isQuantityInvalid");
              displayGenerateIcon  = emxGetParameter(request, "displayGenerateIcon");
              isUsedInBOM  = emxGetParameter(request, "isUsedInBOM");
              strPartMode = emxGetParameter(request, "PartMode");
              strPartFamilyId = emxGetParameter(request, "partFamilyId");

              // IVU - BOM XML
              strLFParentId               = emxGetParameter(request, "LFParentID"); 
              strLFisLeaf                 =  emxGetParameter(request, "isLFLeaf");
              strResolvedPart                 =  emxGetParameter(request, "ResolvedPart");
              strDuplicateParts                 =  emxGetParameter(request, "DuplicateParts"); 
              strResolvedPartRelId                 =  emxGetParameter(request, "ResolvedPartRelID");
              strForcePartReuse                 =  emxGetParameter(request, "ForcePartReuse");
              
              HashMap hmCurrentModifiedFeature = new HashMap();
              hmCurrentModifiedFeature.put("mode",strMode);
              hmCurrentModifiedFeature.put("featureId",featureId);
              hmCurrentModifiedFeature.put("duplicate",duplicate);
              hmCurrentModifiedFeature.put("generate",generate);
              hmCurrentModifiedFeature.put("parentId",parentId);
              hmCurrentModifiedFeature.put("level",level);
              hmCurrentModifiedFeature.put("isQuantityInvalid",isQuantityInvalid);
              hmCurrentModifiedFeature.put("displayGenerateIcon",displayGenerateIcon);
              hmCurrentModifiedFeature.put("isUsedInBOM",isUsedInBOM);
              hmCurrentModifiedFeature.put("quantity",quantity);
              hmCurrentModifiedFeature.put("PartMode",strPartMode);
              hmCurrentModifiedFeature.put("partFamilyId",strPartFamilyId);
              
              
              // IVU - BOM XML
              // Add the LFParent and the Leaf Level
              hmCurrentModifiedFeature.put("LFParentID",strLFParentId);
              hmCurrentModifiedFeature.put("isLFLeaf",strLFisLeaf);
              hmCurrentModifiedFeature.put("ResolvedPart",strResolvedPart);
              hmCurrentModifiedFeature.put("DuplicateParts",strDuplicateParts);
              hmCurrentModifiedFeature.put("ResolvedPartRelID",strResolvedPartRelId);
              hmCurrentModifiedFeature.put("ForcePartReuse",strForcePartReuse);              
              
              
              session.putValue("currentmodifiedfeature",hmCurrentModifiedFeature);
              
                     
      }
      Hashtable modifiedFeatures = new Hashtable();  
      //************************************PreviewBOM************************************
      if(strMode.equalsIgnoreCase("PreviewBOM")) 
      {        
    	  session.removeValue("modifiedFeatures");
    	  String strObjectId  = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
    	  DomainObject domObj = new DomainObject(strObjectId);
    	  boolean isPendingJobConnected = domObj.hasRelatedObjects(context, ConfigurationConstants.RELATIONSHIP_PENDINGJOB, true);
    	  String strErrorMessage = i18nNow.getI18nString("emxProduct.Error.Alert.BackgroundJob.Reserved",bundle,acceptLanguage);
    	  if(isPendingJobConnected){
    		  %>
    		          <script language="javascript" type="text/javascript">
    		          //XSSOK
    		            alert("<%=XSSUtil.encodeForJavaScript(context,strErrorMessage)%>");
    		            getTopWindow().isPBOMApplyClicked=false;
    		            window.close();
    		          </script>
    		  <%
    		        }else{
    	  String strURL = "../common/emxIndentedTable.jsp?header=emxConfiguration.Heading.Table.PreviewEBOM&massUpdate=false&selection=multiple&editRelationship=relationship_LogicalFeatures,relationship_SelectedOptions&freezePane=Display Name,ActionIcons&showApply=false&suiteKey=Configuration&SuiteDirectory=configuration&expandProgram=emxProductConfigurationEBOM:getPreviewBOMForProductConfiguration&table=FTRPreviewBOMStructureTable&editLink="+XSSUtil.encodeForJavaScript(context,editLink)+"&mode="+XSSUtil.encodeForJavaScript(context,mode)+"&toolbar=FTRPreviewBOMTableToolbar&editRootNode=false&autoFilter=false&HelpMarker=emxhelpbompreview&expandLevelFilterMenu=FTRExpandAllLevelFilter&customize=true&displayView=details&postProcessURL=../configuration/PreviewBOMProcess.jsp?mode=apply&parentOID="+strObjectId+"&objectId="+strObjectId;
    		      
        %>
        <script language="javascript" type="text/javascript">
              // document.location.href ="<%=XSSUtil.encodeForJavaScript(context,strURL)%>"; code change IR-534685
				var strURL ="<%=XSSUtil.encodeForJavaScript(context,strURL)%>";
              showModalDialog(strURL,700,800,true,'Large');
        </script>
        <%    
    		        }
      }//************************************PreviewBOM - Apply*****************************
      else if(strMode.equalsIgnoreCase("apply"))
      {
    	  String strBOMAttributeAlert = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.PreviewBOM.BOMAttribute.Alert",strLanguage);
    	  
          %>
          <script language="javascript" type="text/javascript">
          var contentFrame   = findFrame(getTopWindow(),"listHidden");
          var xmlRef 	= contentFrame.parent.oXML;
          var changedRXML 	=	emxUICore.selectNodes(xmlRef, "/mxRoot/rows//r[@status='changed' or @status='cut' or @status='add']");
          var modifiedRowData = new Array(changedRXML.length);
          var pcID = null;

          var rootID = emxUICore.selectNodes(xmlRef, "/mxRoot/rows//r[@level='0']");
          pcID =   rootID[0].getAttribute("o");
		  var unResolvedPartExist = false;
		  var isIE = Browser.IE;
		  
          for(var k = 0; k < changedRXML.length; k++){
        	  var objId =changedRXML[k].getAttribute("o");
        	  var relId=changedRXML[k].getAttribute("r");
        	  var parentId=changedRXML[k].getAttribute("p");
        	  var rowId=changedRXML[k].getAttribute("id");
        	  var status = changedRXML[k].getAttribute("status");
			 

        	  var childNodes=changedRXML[k].childNodes;
        	  var q = 0;
        	  var partIndex = 0;
        	  var skipPart = false;
    		  var columnName = null;
    		  var columnvalue = null;
    		  var partName = null;
    		  var GBOMRelID = null;
    		  var modifiedColumnData = new Array();
    		  var modifiedColumnCount = 0;
    		  var partXML = null;

    		  
        	  for(var count1 = 0; count1 < childNodes.length ; count1++){
        		  var IsEdited = childNodes[count1].getAttribute("edited");
        		  if(childNodes[count1].tagName == "c"){
            		  if(IsEdited=='true'){
            			  columnName = window.parent.colMap.getColumnByIndex(q).name;
            			  columnvalue = childNodes[count1].getAttribute("newA");
            			  modifiedColumnData[modifiedColumnCount]= columnName +'='+columnvalue;
            			  modifiedColumnCount ++;
            		  }
        			  q++;
					  if(!skipPart && window.parent.colMap.getColumnByIndex(partIndex).name == 'Part Number'){
						  var tempPartNumber = "";
						  if(isIE){
						  tempPartNumber = childNodes[count1].text;
						  }
						  else{
						  tempPartNumber = childNodes[count1].textContent;
						  }
						  tempPartNumber     = trim(tempPartNumber);
						  if(tempPartNumber =='???' || tempPartNumber == 'undefined'){
							  partName = '???';
						  }else{
							  partName =  childNodes[count1].childNodes[2].getAttribute("value");
							  GBOMRelID =childNodes[count1].childNodes[3].getAttribute("value");
						  }
						  skipPart = true;
					  }
					  partIndex ++;
        		  }
        	  }
        	  modifiedColumnData[modifiedColumnCount] = 'Part Number ='+partName;
        	  modifiedRowData[k] = objId +':'+ modifiedColumnData +',status='+ status+',GBOMRelID='+ GBOMRelID+'~~';
              if(partName== '???'){
            	  unResolvedPartExist = true;
              }
          }

			if(unResolvedPartExist){
				//XSSOK
				alert("<%=strBOMAttributeAlert%>");
			}
          
          var strURL = "../configuration/PreviewBOMProcess.jsp?mode=PostApply&ModifiedDetails="+modifiedRowData+"&PCID="+pcID;         
          document.location.href = strURL;
          </script>
          <%  
      }
      else if(strMode.equalsIgnoreCase("PostApply")){
    	  String strModifiedData= (String)emxGetParameter(request, "ModifiedDetails");
    	  String strProductConfigID = XSSUtil.encodeForURL(context,(String)emxGetParameter(request, "PCID"));
    	  
          MapList hmModifiedQuantityFeatures = new MapList();
          MapList hmModifiedFeatures = new MapList();
          if(hmModifiedQuantityFeatures.size()>0)
          {
                   hmModifiedFeatures.addAll(hmModifiedQuantityFeatures);
           }
           Hashtable hsModifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
           Map mapTemp = new HashMap();
           Map mapTemp1 = new HashMap();
           Map programMap = new HashMap();
           if(hsModifiedFeatures!=null && hsModifiedFeatures.size()>0) 
           {
               Enumeration en = hsModifiedFeatures.keys();
               while(en.hasMoreElements())
               {
                   Object obj = hsModifiedFeatures.get(en.nextElement());
                   if(obj!=null && obj instanceof MapList){
                	   MapList mapListTemp = (MapList) obj;
                	   for(int k=0; k<mapListTemp.size();k++){
                		   hmModifiedFeatures.add(mapListTemp.get(k));
                	   }
                   }else if(obj!=null && obj instanceof HashMap){
                       mapTemp = (HashMap)obj;
                	   hmModifiedFeatures.add(mapTemp);
                   }
               }
           }
           //if(hmModifiedFeatures.size() >0){
        	   mapTemp1.put("modifiedFeatures",hmModifiedFeatures);
               MapList objectList = new MapList();
               objectList.add(mapTemp1);
               programMap.put("objectList", objectList);
               pcBean.processApplyAction(context,(HashMap)programMap,strProductConfigID,strModifiedData);   
          // }           
           session.removeValue("modifiedFeatures");
           %>
           <SCRIPT language="javascript" type="text/javaScript">
               var windowToRefresh=getTopWindow().findFrame(getTopWindow().window,"content");
               windowToRefresh.location.href  = windowToRefresh.location.href;
      //         getTopWindow().window.location = getTopWindow().window.location;
           </SCRIPT>
           <%
      }
      //************************************PreviewBOM - Create Part OR Replace By Create Part*****************************
      else if(strMode.equalsIgnoreCase("createpart") || strMode.equalsIgnoreCase("replacebycreatepart")) 
      {
        if(partOid==null) 
        { 
        	session.setAttribute("PartMode",strPartMode);
            session.setAttribute("submitURL","../configuration/PreviewBOMProcess.jsp");  
            %>
            <SCRIPT language="javascript" type="text/javaScript">
            var strURL= "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart&header=emxFramework.Command.CreateNewPart&type=type_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=FTR&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessInCreatePart";        
            document.location.href = strURL;
            </SCRIPT>
     <% }else 
        {         
            modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
            if(modifiedFeatures == null) 
            {
                modifiedFeatures = new Hashtable();
            }
            HashMap hmModifiedData = new HashMap();
            hmModifiedData.put("mode",strMode);
            hmModifiedData.put("partId",partOid);
            hmModifiedData.put("generate",generate);
            hmModifiedData.put("duplicate",duplicate);
            hmModifiedData.put("featureId",featureId);
            hmModifiedData.put("parentId",parentId);
            hmModifiedData.put("PartMode",strPartMode);
            
            
  		  // IVU - BOM XML
  		  hmModifiedData.put("LFParentID",strLFParentId);
  		  hmModifiedData.put("isLFLeaf",strLFisLeaf);
          hmModifiedData.put("RemovedPart",strResolvedPart);
          hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);
          hmModifiedData.put("DuplicateParts",strDuplicateParts);
          hmModifiedData.put("ForcePartReuse",strForcePartReuse);
          
          
          if(modifiedFeatures.get(featureId)!=null && strLFisLeaf.equalsIgnoreCase("Yes")){
              MapList mapDupLF = new MapList();
              Object obj = modifiedFeatures.get(featureId);
              if(obj!=null && obj instanceof MapList){
            	  mapDupLF.addAll((MapList)modifiedFeatures.get(featureId));
              }else if(obj!=null && obj instanceof HashMap){
            	  mapDupLF.add((HashMap)modifiedFeatures.get(featureId));
              }
        	  mapDupLF.add(hmModifiedData)	;
        	  modifiedFeatures.put(featureId,mapDupLF);
          }else{
        	  modifiedFeatures.put(featureId,hmModifiedData);  
          }
            	
            session.putValue("modifiedFeatures",modifiedFeatures);
            session.removeValue("currentmodifiedfeature");
            //cell refresh start
            Hashtable mapPartInfo = (Hashtable)ProductConfiguration.getPartInfo(context,partOid);
            String partName = (String)mapPartInfo.get(ConfigurationConstants.SELECT_NAME);
            String releasePhase = (String)mapPartInfo.get(ConfigurationConstants.SELECT_ATTRIBUTE_RELEASE_PHASE);
            
            String changeControlled = DomainConstants.EMPTY_STRING;
            HashMap partMap        = new HashMap();
			List<Map> objectList   = new MapList();
			partMap.put(DomainConstants.SELECT_ID, partOid);
			objectList.add(partMap);
			
			HashMap programMap = new HashMap();
			programMap.put("objectList", objectList);
			String[] arrPackedArgument = (String[]) JPO.packArgs(programMap);
			Vector lstChangeControlled = (Vector)JPO.invoke(context, "enoECMChangeUX", null,"getHTMLForChangeControlValue", arrPackedArgument, Vector.class);
			
			if(lstChangeControlled.size() > 0){
				changeControlled = (String)lstChangeControlled.get(0);
				System.out.println("changeControlled || " + changeControlled);
				if(changeControlled.contains("JavaScript:emxTableColumnLinkClick")){
					String changeId   = changeControlled.substring(changeControlled.indexOf("objectId=")+9, changeControlled.indexOf("',"));
			    	String changeName = changeControlled.substring(changeControlled.indexOf("/>")+2, changeControlled.indexOf("</a>"));
			    	changeControlled  = "<a class=\\\"object\\\" href=\\\"JavaScript:emxTableColumnLinkClick('../common/emxTree.jsp?objectId="+changeId+"', '800', '575','true','popup')\\\"><img border=\\\"0\\\" src=\\\"../common/images/iconSmallChangeAction.png\\\"/>"+changeName+"</a>";
				}
			}
            
            partName = XSSUtil.encodeForXML(context,partName);
            String partRevision = (String)mapPartInfo.get(ConfigurationConstants.SELECT_REVISION);
            String partState = (String)mapPartInfo.get(ConfigurationConstants.SELECT_CURRENT);
            String partType = (String)mapPartInfo.get(ConfigurationConstants.SELECT_TYPE);
            Boolean strHigherRevExists = (Boolean)mapPartInfo.get("HigherRevisionExists");
            String higherRevision = "";
            String isObsolete = "";     
            if(!strHigherRevExists)
            {
                higherRevision = "true";
            }
            if(partState.equalsIgnoreCase("obsolete"))
            {
                isObsolete = "true";
            }    
            boolean isEBOMDifferent = false; 
            isEBOMDifferent =  pcBean.checkForEBOMDifferent(context,partOid.trim(),featureId.trim(),parentId.trim());
            
            boolean hasDuplicateParts = false;
            if(strDuplicateParts!=null && strDuplicateParts.length()>0){
          	  hasDuplicateParts = true;
            }
            

            String strToolTipReplaceByCreateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsCustom",strLanguage);
            String strToolTipReplaceByAddCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsCustom",strLanguage);
            String strToolTipReplaceByGenerateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsCustom",strLanguage);

            String strToolTipReplaceByCreateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsDefault",strLanguage);
            String strToolTipReplaceByAddDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsDefault",strLanguage);
            String strToolTipReplaceByGenerateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsDefault",strLanguage);
            
            String strToolTipCreateNewAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsCustom",strLanguage);
            String strToolTipAddExistAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsCustom",strLanguage);
            String strToolTipGenerateAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsCustom",strLanguage);
            
            String strToolTipCreateNewAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsDefault",strLanguage);
            String strToolTipAddExistAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsDefault",strLanguage);
            String strToolTipGenerateAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsDefault",strLanguage);
            
            String strToolTipInvalidQuantity = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.InvalidQuantity",strLanguage);
            String strToolTipHigherRevision  = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.HigherRevision",strLanguage);
            String strToolTipObsoletePart    = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.ObsoletePart",strLanguage);
            String strToolTipEBOMDifferent   =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.EBOMDifferent",strLanguage);
            String strToolTipUsedInBOM       = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.UsedInBOM",strLanguage);  
            String strToolTipOptionalChoice = "";
            String strCustomPartMode = EnoviaResourceBundle.getProperty(context,"emxConfiguration.PreviewBOM.EnableCustomPartMode");
            if (ProductLineCommon.isNotNull(strCustomPartMode)&& strCustomPartMode.equalsIgnoreCase("true")) {
                strToolTipOptionalChoice = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage);
            } else {                         
                strToolTipOptionalChoice = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage); 
            }
            
            String strPartUsage = "";
            
            if(ProductLineCommon.isNotNull(strPartMode) && strPartMode.equalsIgnoreCase("custom")){
                strPartUsage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Custom",strLanguage);
            }else{
                strPartUsage =EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Default",strLanguage);
            }
            
            if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_DEVELOPMENT.equalsIgnoreCase(releasePhase)){
            	releasePhase = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Development",strLanguage);
            }else if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_PRODUCTION.equalsIgnoreCase(releasePhase)){
            	releasePhase =EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Production",strLanguage);
            }
          //get the GBOM Attributed for Refresh
      	  Map bomAttributes = ProductConfiguration.getBOMAttributes(context,null,featureId,strLFParentId,parentId);
    	  String strFN = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_FIND_NUMBER).toString();
    	  String strRD = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_REFERENCE_DESIGNATOR).toString();
    	  String strCL = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_COMPONENT_LOCATION).toString();
    	  String strQuantity =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_QUANTITY).toString();
    	  String strUsg =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_USAGE).toString();
            
            
            %>
            <SCRIPT language="javascript" type="text/javaScript">
            var level = "<%=XSSUtil.encodeForJavaScript(context,level)%>";
            var newPart = "<%=partName%>";
            var newRevision = "<%=XSSUtil.encodeForJavaScript(context,partRevision)%>";
            var newState = "<%=XSSUtil.encodeForJavaScript(context,partState)%>";
            var newType = "<%=XSSUtil.encodeForJavaScript(context,partType)%>";
            var isQuantityInvalid = "<%=XSSUtil.encodeForJavaScript(context,isQuantityInvalid)%>";
            var displayGenerateIcon = "<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";
            var isUsedInBOM = "<%=XSSUtil.encodeForJavaScript(context,isUsedInBOM)%>";
            var higherRevision = "<%=higherRevision%>";
            var isObsolete = "<%=isObsolete%>";
            var isEBOMDifferent = "<%=isEBOMDifferent%>";
            var featureId = "<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
            var parentId = "<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
            var strLFParentId = "<%=XSSUtil.encodeForJavaScript(context,strLFParentId)%>";
            var strLFisLeaf = "<%=XSSUtil.encodeForJavaScript(context,strLFisLeaf)%>";
            var partUsage = "<c><%=strPartUsage%></c>";
            var visualCue='';
            var actionIcon='';
            var actionCustIcon='';
            var isECInstalled = "<%=isECInstalled%>";
            var strToolTipReplaceByCreateCustom = "<%=strToolTipReplaceByCreateCustom%>";
            var strToolTipReplaceByAddCustom = "<%=strToolTipReplaceByAddCustom%>";
            var strToolTipReplaceByGenerateCustom = "<%=strToolTipReplaceByGenerateCustom%>";   
            var strToolTipReplaceByCreateDefault = "<%=strToolTipReplaceByCreateDefault%>";
            var strToolTipReplaceByAddDefault = "<%=strToolTipReplaceByAddDefault%>";
            var strToolTipReplaceByGenerateDefault = "<%=strToolTipReplaceByGenerateDefault%>";
            var strToolTipCreateNewAsCustom = "<%=strToolTipCreateNewAsCustom%>";
            var strToolTipAddExistAsCustom = "<%=strToolTipAddExistAsCustom%>";
            var strToolTipGenerateAsCustom = "<%=strToolTipGenerateAsCustom%>";   
            var strToolTipCreateNewAsDefault = "<%=strToolTipCreateNewAsDefault%>";
            var strToolTipAddExistAsDefault = "<%=strToolTipAddExistAsDefault%>";
            var strToolTipGenerateAsDefault = "<%=strToolTipGenerateAsDefault%>";
            var strToolTipInvalidQuantity = "<%=strToolTipInvalidQuantity%>";
            var strToolTipHigherRevision = "<%=strToolTipHigherRevision%>";
            var strToolTipObsoletePart = "<%=strToolTipObsoletePart%>";
            var strToolTipEBOMDifferent = "<%=strToolTipEBOMDifferent%>";
            var strToolTipUsedInBOM = "<%=strToolTipUsedInBOM%>";                
            var partName = '';
            var hasDuplicateParts = "<%=hasDuplicateParts%>";
            var strToolTipOptionalChoice = "<%=strToolTipOptionalChoice%>";
            var GBOMRelId = "";
            
            var strForcePartReuse    = "<%=XSSUtil.encodeForJavaScript(context,strForcePartReuse)%>";
            var strDuplicateParts    = "<%=XSSUtil.encodeForJavaScript(context,strDuplicateParts)%>";
            var strResolvedPart      = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPart)%>";
            var strResolvedPartRelId = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPartRelId)%>";            

            var partObjId = "<%=XSSUtil.encodeForJavaScript(context,partOid)%>";
            var partOIDElement = '<input type="hidden" value="'+partObjId+'"/>'; 
            var GBOMRelIdlement = '<input type="hidden" value="'+GBOMRelId+'"/>';
            var releasePhase = "<c><%=releasePhase%></c>";
            var changeControlled = "<c><%=changeControlled%></c>";

            if(isECInstalled=="true"){
                partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+ GBOMRelIdlement +'</c>';
            }
            else{
                partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getAllEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getAllEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+ GBOMRelIdlement +'</c>';
            }
            var partRevision = '<c>'+newRevision+'</c>';
            var partState = '<c>'+newState+'</c>';
            var partType = '<c>'+newType+'</c>';
            var selectedAction = '<c a="&lt;img src=&quot;../common/images/iconSmallCreatePart.png&quot;/&gt;"><img src="../common/images/iconSmallCreatePart.png"/></c>';
            //logic to refresh visual cue cell start
            if(isQuantityInvalid=="true")
            {                    
                visualCue = '  <img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="'+strToolTipInvalidQuantity+'"/>';
            }
            if(higherRevision=="true")
            {
                visualCue = visualCue + '  <img src="../common/images/HigherRevision16.png" border="0" align="middle" TITLE="'+strToolTipHigherRevision+'"/>';
            }                
            if(isObsolete=="true")
            {
                visualCue = visualCue + '  <img src="../common/images/IconSmallObsoletePart.png" border="0" align="middle" TITLE="'+strToolTipObsoletePart+'"/>';
            }                
            if(isEBOMDifferent=="true")
            {                    
                visualCue = visualCue + '  <img src="../common/images/CompareDifferences16.png" border="0" align="middle" TITLE="'+strToolTipEBOMDifferent+'"/>';
            }
            if(isUsedInBOM=="true")
            {
                visualCue = visualCue + '  <img src="../common/images/UsedInBom16.png" border="0" align="middle" TITLE="'+strToolTipUsedInBOM+'"/>';
            }
            if(hasDuplicateParts=="true")
            {
                visualCue = visualCue + '  <a><img src="../common/images/DuplicateParts16.png" border="0" align="middle" TITLE="'+strToolTipOptionalChoice+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=duplicate&amp;duplicate=true&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/></a>';
            }
            var visualCueColumn = '<c>'+visualCue+'</c>';
            //logic to refresh visual cue cell end
            //logic to refresh Action Icon cell start
            actionIcon = '<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsDefault+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/></a>';
            actionCustIcon ='<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsCustom+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;PartMode=custom\');"/></a>';
            
            actionIcon = actionIcon + ' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsDefault+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=null&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\')"/></a>';
            
            actionCustIcon = actionCustIcon +  ' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsCustom+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=custom&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\');"/></a>';
            
	        if(displayGenerateIcon=="true")
            {
            	 actionIcon = actionIcon + "<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;LFParentID="+strLFParentId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsDefault+"\'/></a>";
           	  	 actionCustIcon = actionCustIcon +"<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;LFParentID="+strLFParentId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true&amp;PartMode=custom', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsCustom+"\'/></a>";
            }
            var actionIconColumn = '<c>'+actionIcon+'</c>';
            var colMapObj = getTopWindow().window.getWindowOpener().colMap;
            //var SelActColmn = colMapObj.getColumnByName("Selected Action");
            var PNColmn = colMapObj.getColumnByName("Part Number");
            var RevColmn = colMapObj.getColumnByName("Revision");
            var StateColmn = colMapObj.getColumnByName("State");
            var TypeColmn = colMapObj.getColumnByName("Type");
            var VisCuColmn = colMapObj.getColumnByName("Visual Cue");
            var ActIcnColmn = colMapObj.getColumnByName("Action Icons");
            var stdActIcnColmn = colMapObj.getColumnByName("Std Action Icons");
            var cstActIcnColmn = colMapObj.getColumnByName("Custom Actions Icons");
            var PartUsgColmn = colMapObj.getColumnByName("Part Usage");
            var partPhaseColumn = colMapObj.getColumnByName("Phase");
            var changeContrColumn = colMapObj.getColumnByName("Change Controlled");
            var contentFrame = "formCreateHidden";
			
            //logic to refresh Action Icon cell end                
            //top.window.getWindowOpener().editableTable.updateXMLByRowId(level,selectedAction,SelActColmn.index);
            updateXMLByRowId(contentFrame,level,partName,PNColmn.index);
            updateXMLByRowId(contentFrame,level,partRevision,RevColmn.index);
            updateXMLByRowId(contentFrame,level,partState,StateColmn.index);
            updateXMLByRowId(contentFrame,level,partType,TypeColmn.index);
            updateXMLByRowId(contentFrame,level,visualCueColumn,VisCuColmn.index);
            if(ActIcnColmn !=null){
            	updateXMLByRowId(contentFrame,level,actionIconColumn,ActIcnColmn.index);
            }
            if(stdActIcnColmn !=null){
                updateXMLByRowId(contentFrame,level,actionIconColumn,stdActIcnColmn.index);
            }
            if(cstActIcnColmn !=null){
                updateXMLByRowId(contentFrame,level,'<c>'+actionCustIcon+'</c>',cstActIcnColmn.index);
            }
            if(PartUsgColmn !=null){
                updateXMLByRowId(contentFrame,level,partUsage,PartUsgColmn.index);
            }
            if(partPhaseColumn !=null){
            	updateXMLByRowId(contentFrame,level,releasePhase,partPhaseColumn.index);
            }
            if(changeContrColumn !=null){
            	updateXMLByRowId(contentFrame,level,changeControlled,changeContrColumn.index);
            }

			// Logic to refresh the BOM Attributes.
            var FNColmn = colMapObj.getColumnByName("Find Number");
            var RDColmn = colMapObj.getColumnByName("ReferenceDesignator");
            var CLColmn = colMapObj.getColumnByName("ComponentLocation");
            var QuantityColmn = colMapObj.getColumnByName("Quantity");
            var UsgColmn = colMapObj.getColumnByName("Usage");
            var findno = "<%=XSSUtil.encodeForJavaScript(context,strFN)%>";
            var refdes = "<%=XSSUtil.encodeForJavaScript(context,strRD)%>";
            var comploc = "<%=XSSUtil.encodeForJavaScript(context,strCL)%>";
            var qty = "<%=XSSUtil.encodeForJavaScript(context,strQuantity)%>";
            var usg = "<%=XSSUtil.encodeForJavaScript(context,strUsg)%>";		  
            if(findno!="")
            {
            	updateXMLByRowId(contentFrame,level,'<c>'+findno+'</c>',FNColmn.index);
            }if(refdes!="")
            {
                updateXMLByRowId(contentFrame,level,'<c>'+refdes+'</c>',RDColmn.index);
                
            }if(comploc!="")
            {
            	updateXMLByRowId(contentFrame,level,'<c>'+comploc+'</c>',CLColmn.index);
                                
            }if(qty!="")
            {
                updateXMLByRowId(contentFrame,level,'<c>'+qty+'</c>',QuantityColmn.index);
            }if(usg!="")
            {
                updateXMLByRowId(contentFrame,level,'<c>'+usg+'</c>',UsgColmn.index);
            }
            
            getTopWindow().window.getWindowOpener().rebuildView();
            getTopWindow().location.href = "../common/emxCloseWindow.jsp";
            </SCRIPT>
     <%
        }
      }//************************************PreviewBOM - Add Existing Part OR Replace By Existing Part*****************************
      else if(strMode.equalsIgnoreCase("addexisting") || strMode.equalsIgnoreCase("replacebyaddexisting")) 
      {
    	    if(partOid==null) 
            {          
                %>
                <SCRIPT language="javascript" type="text/javaScript">
                //var strURL    = "../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_DevelopmentPart.state_Obsolete,policy_StandardPart.state_Obsolete&table=FTRFeatureSearchResultsTable&HelpMarker=emxhelpfullsearch&showInitialResults=false&hideHeader=true";
                var strURL    = "../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&table=FTRFeatureSearchResultsTable&HelpMarker=emxhelpfullsearch&showInitialResults=false&hideHeader=true";
                strURL        = strURL  + "&featureId=<%=XSSUtil.encodeForJavaScript(context,featureId)%>";         
                strURL        = strURL  + "&duplicate=<%=XSSUtil.encodeForJavaScript(context,duplicate)%>";
                strURL        = strURL  + "&generate=<%=XSSUtil.encodeForJavaScript(context,generate)%>";
                strURL        = strURL  + "&objectId=<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
                strURL        = strURL  + "&parentId=<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
                strURL        = strURL  + "&suiteKey=Configuration";
                strURL        = strURL  + "&selection=single";
                //strURL        = strURL  + "&excludeOIDprogram=emxFeatureSearch:excludePartsForPreviewBOM";
                strURL        = strURL  + "&submitURL=../configuration/PreviewBOMProcess.jsp?PartMode=<%=XSSUtil.encodeForJavaScript(context,strPartMode)%>&displayGenerateIcon=<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";         
                document.location.href = strURL;
                </SCRIPT>
         <% }else 
            {
                modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");         
                if(modifiedFeatures == null) 
                {
                    modifiedFeatures = new Hashtable();
                }
                HashMap hmModifiedData = new HashMap();
                hmModifiedData.put("mode",strMode);
                String strPartId= partOid.substring(1,partOid.length());
                StringTokenizer stIntermediate =   new StringTokenizer(strPartId,"|");
                String strPartid=stIntermediate.nextToken();                
                hmModifiedData.put("partId",strPartid);
                hmModifiedData.put("generate",generate);
                hmModifiedData.put("duplicate",duplicate);
                hmModifiedData.put("featureId",featureId);
                hmModifiedData.put("featureId",featureId);
                hmModifiedData.put("parentId",parentId);
                hmModifiedData.put("PartMode",strPartMode);
                
      		  // IVU - BOM XML
      		  hmModifiedData.put("LFParentID",strLFParentId);
      		  hmModifiedData.put("isLFLeaf",strLFisLeaf);
              hmModifiedData.put("RemovedPart",strResolvedPart);
              hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);              
              hmModifiedData.put("DuplicateParts",strDuplicateParts);   
              hmModifiedData.put("ForcePartReuse",strForcePartReuse);
              
                
                
              if(modifiedFeatures.get(featureId)!=null && strLFisLeaf.equalsIgnoreCase("Yes")){
                  MapList mapDupLF = new MapList();
                  Object obj = modifiedFeatures.get(featureId);
                  if(obj!=null && obj instanceof MapList){
                	  mapDupLF.addAll((MapList)modifiedFeatures.get(featureId));
                  }else if(obj!=null && obj instanceof HashMap){
                	  mapDupLF.add((HashMap)modifiedFeatures.get(featureId));
                  }
            	  mapDupLF.add(hmModifiedData)	;
            	  modifiedFeatures.put(featureId,mapDupLF);
              }else{
            	  modifiedFeatures.put(featureId,hmModifiedData);  
              }
                	
                session.putValue("modifiedFeatures",modifiedFeatures);
                session.removeValue("currentmodifiedfeature");
                //cell refresh start
                Hashtable mapPartInfo = (Hashtable)ProductConfiguration.getPartInfo(context,strPartid);
                String partName = (String)mapPartInfo.get(ConfigurationConstants.SELECT_NAME);
                String releasePhase = (String)mapPartInfo.get(ConfigurationConstants.SELECT_ATTRIBUTE_RELEASE_PHASE);
                
                String changeControlled = DomainConstants.EMPTY_STRING;
                HashMap partMap        = new HashMap();
    			List<Map> objectList   = new MapList();
    			partMap.put(DomainConstants.SELECT_ID, strPartid);
    			objectList.add(partMap);
    			
    			HashMap programMap = new HashMap();
    			programMap.put("objectList", objectList);
    			String[] arrPackedArgument = (String[]) JPO.packArgs(programMap);
    			Vector lstChangeControlled = (Vector)JPO.invoke(context, "enoECMChangeUX", null,"getHTMLForChangeControlValue", arrPackedArgument, Vector.class);
    			
    			if(lstChangeControlled.size() > 0){
    				changeControlled = (String)lstChangeControlled.get(0);
    				System.out.println("changeControlled || " + changeControlled);
    				if(changeControlled.contains("JavaScript:emxTableColumnLinkClick")){
    					String changeId   = changeControlled.substring(changeControlled.indexOf("objectId=")+9, changeControlled.indexOf("',"));
    			    	String changeName = changeControlled.substring(changeControlled.indexOf("/>")+2, changeControlled.indexOf("</a>"));
    			    	changeControlled  = "<a class=\\\"object\\\" href=\\\"JavaScript:emxTableColumnLinkClick('../common/emxTree.jsp?objectId="+changeId+"', '800', '575','true','popup')\\\"><img border=\\\"0\\\" src=\\\"../common/images/iconSmallChangeAction.png\\\"/>"+changeName+"</a>";
    				}
    			}
    			
                partName = XSSUtil.encodeForXML(context,partName);
                String partRevision = (String)mapPartInfo.get(ConfigurationConstants.SELECT_REVISION);
                String partState = (String)mapPartInfo.get(ConfigurationConstants.SELECT_CURRENT);
                String partType = (String)mapPartInfo.get(ConfigurationConstants.SELECT_TYPE);
                Boolean strHigherRevExists = (Boolean)mapPartInfo.get("HigherRevisionExists");
                String higherRevision = "";
                String isObsolete = "";     
                if(!strHigherRevExists)
                {
                    higherRevision = "true";
                }
                if(partState.equalsIgnoreCase("obsolete"))
                {
                    isObsolete = "true";
                }                    
                boolean isEBOMDifferent = false;     
                isEBOMDifferent = pcBean.checkForEBOMDifferent(context,strPartid.trim(),featureId.trim(),parentId.trim());
                boolean hasDuplicateParts = false;
                if(strDuplicateParts!=null && strDuplicateParts.length()>0){
              	  hasDuplicateParts = true;
                }
                String strToolTipReplaceByCreateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsCustom",strLanguage);
                String strToolTipReplaceByAddCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsCustom",strLanguage);
                String strToolTipReplaceByGenerateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsCustom",strLanguage);

                String strToolTipReplaceByCreateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsDefault",strLanguage);
                String strToolTipReplaceByAddDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsDefault",strLanguage);
                String strToolTipReplaceByGenerateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsDefault",strLanguage);
                
                String strToolTipCreateNewAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsCustom",strLanguage);
                String strToolTipAddExistAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsCustom",strLanguage);
                String strToolTipGenerateAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsCustom",strLanguage);
                
                String strToolTipCreateNewAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsDefault",strLanguage);
                String strToolTipAddExistAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsDefault",strLanguage);
                String strToolTipGenerateAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsDefault",strLanguage);
                
                String strToolTipInvalidQuantity =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.InvalidQuantity",strLanguage);
                String strToolTipHigherRevision  =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.HigherRevision",strLanguage);
                String strToolTipObsoletePart    = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.ObsoletePart",strLanguage);
                String strToolTipEBOMDifferent   = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.EBOMDifferent",strLanguage);
                String strToolTipUsedInBOM       = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.UsedInBOM",strLanguage);
                String strToolTipOptionalChoice = "";
                String strCustomPartMode = EnoviaResourceBundle.getProperty(context,"emxConfiguration.PreviewBOM.EnableCustomPartMode");
                if (ProductLineCommon.isNotNull(strCustomPartMode)&& strCustomPartMode.equalsIgnoreCase("true")) {
                	strToolTipOptionalChoice = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage);
                } else {  
                	strToolTipOptionalChoice = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage);          
                }
                
                String strPartUsage = "";
                
                if(ProductLineCommon.isNotNull(strPartMode) && strPartMode.equalsIgnoreCase("custom")){
                	strPartUsage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Custom",strLanguage);
                }else{
                	strPartUsage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Default",strLanguage);
}
                
                if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_DEVELOPMENT.equalsIgnoreCase(releasePhase)){
                	releasePhase = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Development",strLanguage);
                }else if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_PRODUCTION.equalsIgnoreCase(releasePhase)){
                	releasePhase =EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Production",strLanguage);
                }
                
               // get the BOM Attributes
          	  Map bomAttributes = ProductConfiguration.getBOMAttributes(context,null,featureId,strLFParentId,parentId);
        	  String strFN = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_FIND_NUMBER).toString();
        	  String strRD = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_REFERENCE_DESIGNATOR).toString();
        	  String strCL = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_COMPONENT_LOCATION).toString();
        	  String strQuantity =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_QUANTITY).toString();
        	  String strUsg =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_USAGE).toString();
                
                
                %>
                <SCRIPT language="javascript" type="text/javaScript">
                var level = "<%=XSSUtil.encodeForJavaScript(context,level)%>";         
                var newPart = "<%=partName%>";         
                var newRevision = "<%=XSSUtil.encodeForJavaScript(context,partRevision)%>";         
                var newState = "<%=XSSUtil.encodeForJavaScript(context,partState)%>";         
                var newType = "<%=XSSUtil.encodeForJavaScript(context,partType)%>";         
                var isECInstalled = "<%=isECInstalled%>";
                var isQuantityInvalid = "<%=XSSUtil.encodeForJavaScript(context,isQuantityInvalid)%>";
                var displayGenerateIcon = "<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";
                var isUsedInBOM = "<%=XSSUtil.encodeForJavaScript(context,isUsedInBOM)%>";
                var higherRevision = "<%=higherRevision%>";
                var isObsolete = "<%=isObsolete%>";
                var isEBOMDifferent = "<%=isEBOMDifferent%>";
                var featureId = "<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
                var parentId = "<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
                var strLFParentId = "<%=XSSUtil.encodeForJavaScript(context,strLFParentId)%>";
                var strLFisLeaf = "<%=XSSUtil.encodeForJavaScript(context,strLFisLeaf)%>";
                var partUsage = "<c><%=strPartUsage%></c>";
                var visualCue='';
                var actionIcon='';
                var actionCustIcon='';
                var strToolTipReplaceByCreateCustom = "<%=strToolTipReplaceByCreateCustom%>";
                var strToolTipReplaceByAddCustom = "<%=strToolTipReplaceByAddCustom%>";
                var strToolTipReplaceByGenerateCustom = "<%=strToolTipReplaceByGenerateCustom%>";   
                var strToolTipReplaceByCreateDefault = "<%=strToolTipReplaceByCreateDefault%>";
                var strToolTipReplaceByAddDefault = "<%=strToolTipReplaceByAddDefault%>";
                var strToolTipReplaceByGenerateDefault = "<%=strToolTipReplaceByGenerateDefault%>";
                var strToolTipCreateNewAsCustom = "<%=strToolTipCreateNewAsCustom%>";
                var strToolTipAddExistAsCustom = "<%=strToolTipAddExistAsCustom%>";
                var strToolTipGenerateAsCustom = "<%=strToolTipGenerateAsCustom%>";   
                var strToolTipCreateNewAsDefault = "<%=strToolTipCreateNewAsDefault%>";
                var strToolTipAddExistAsDefault = "<%=strToolTipAddExistAsDefault%>";
                var strToolTipGenerateAsDefault = "<%=strToolTipGenerateAsDefault%>";   
                var strToolTipInvalidQuantity = "<%=strToolTipInvalidQuantity%>";
                var strToolTipHigherRevision = "<%=strToolTipHigherRevision%>";
                var strToolTipObsoletePart = "<%=strToolTipObsoletePart%>";
                var strToolTipEBOMDifferent = "<%=strToolTipEBOMDifferent%>";
                var strToolTipUsedInBOM = "<%=strToolTipUsedInBOM%>";         
                var partName = '';
                var hasDuplicateParts = "<%=hasDuplicateParts%>";
                var strToolTipOptionalChoice = "<%=strToolTipOptionalChoice%>"; 

                var strForcePartReuse    = "<%=XSSUtil.encodeForJavaScript(context,strForcePartReuse)%>";
                var strDuplicateParts    = "<%=XSSUtil.encodeForJavaScript(context,strDuplicateParts)%>";
                var strResolvedPart      = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPart)%>";
                var strResolvedPartRelId = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPartRelId)%>";   
                
                var partObjId = "<%=XSSUtil.encodeForJavaScript(context,strPartid)%>";
                var partOIDElement = '<input type="hidden" value="'+partObjId+'"/>'; 

                var GBOMRelId = "";
                var GBOMRelIdlement = '<input type="hidden" value="'+GBOMRelId+'"/>';
                var releasePhase = "<c><%=releasePhase%></c>";   
				
				var changeControlled = "<c><%=changeControlled%></c>";
				
                if(isECInstalled=="true")
                {
                    partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,strPartid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,strPartid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+GBOMRelIdlement+'</c>';
                }
                else
                {
                    partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getAllEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,strPartid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getAllEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,strPartid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+GBOMRelIdlement+'</c>';
                }         
                var partRevision = '<c>'+newRevision+'</c>';
                var partState = '<c>'+newState+'</c>';
                var partType = '<c>'+newType+'</c>';
                var selectedAction = '<c a="&lt;img src=&quot;../common/images/IconSmallAddExistingPart.png&quot;/&gt;"><img src="../common/images/IconSmallAddExistingPart.png"/></c>';
                //logic to refresh visual cue cell start
                if(isQuantityInvalid=="true")
                {                       
                    visualCue = '  <img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="'+strToolTipInvalidQuantity+'"/>';
                }
                if(higherRevision=="true")
                {
                    visualCue = visualCue + '  <img src="../common/images/HigherRevision16.png" border="0" align="middle" TITLE="'+strToolTipHigherRevision+'"/>';
                }         
                if(isObsolete=="true")
                {
                    visualCue = visualCue + '  <img src="../common/images/IconSmallObsoletePart.png" border="0" align="middle" TITLE="'+strToolTipObsoletePart+'"/>';
                }         
                if(isEBOMDifferent=="true")
                {
                    visualCue = visualCue + '  <img src="../common/images/CompareDifferences16.png" border="0" align="middle" TITLE="'+strToolTipEBOMDifferent+'"/>';
                }
                if(isUsedInBOM=="true")
                {
                    visualCue = visualCue + '  <img src="../common/images/UsedInBom16.png" border="0" align="middle" TITLE="'+strToolTipUsedInBOM+'"/>';
                }
                if(hasDuplicateParts=="true")
                {
                	visualCue = visualCue + '  <a><img src="../common/images/DuplicateParts16.png" border="0" align="middle" TITLE="'+strToolTipOptionalChoice+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=duplicate&amp;duplicate=true&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/></a>';
                }
                var visualCueColumn = '<c>'+visualCue+'</c>';
                //if EC is installed
                if(isECInstalled=="true")
                {
                    actionIcon = '<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsDefault+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/></a>';
                    actionCustIcon = '<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsCustom+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;PartMode=custom\');"/></a>';
                }
                actionIcon = actionIcon + ' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsDefault+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=null&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\')"/></a>';
                actionCustIcon = actionCustIcon+  ' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsCustom+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=custom&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\');"/></a>';
                if(displayGenerateIcon=="true")
                {
                	 actionIcon = actionIcon + "<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;LFParentID="+strLFParentId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsDefault+"\'/></a>";
               	  	 actionCustIcon = actionCustIcon +"<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;LFParentID="+strLFParentId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true&amp;PartMode=custom', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsCustom+"\'/></a>";
                }
                var actionIconColumn = '<c>'+actionIcon+'</c>';         
               
                var colMapObj = getTopWindow().window.getWindowOpener().colMap;
                
                //var SelActColmn = colMapObj.getColumnByName("Selected Action");
                var PNColmn = colMapObj.getColumnByName("Part Number");
                var RevColmn = colMapObj.getColumnByName("Revision");
                var StateColmn = colMapObj.getColumnByName("State");
                var TypeColmn = colMapObj.getColumnByName("Type");
                var VisCuColmn = colMapObj.getColumnByName("Visual Cue");
                var ActIcnColmn = colMapObj.getColumnByName("Action Icons");
                var stdActIcnColmn = colMapObj.getColumnByName("Std Action Icons");
                var cstActIcnColmn = colMapObj.getColumnByName("Custom Actions Icons");
                var PartUsgColmn = colMapObj.getColumnByName("Part Usage");
                var partPhaseColumn = colMapObj.getColumnByName("Phase");
                var changeContrColumn = colMapObj.getColumnByName("Change Controlled");
                var contentFrame = "addExisting";
				
                //logic to refresh Action Icon cell end          
                //top.window.getWindowOpener().editableTable.updateXMLByRowId(level,selectedAction,SelActColmn.index);
                updateXMLByRowId(contentFrame,level,partName,PNColmn.index);
				updateXMLByRowId(contentFrame,level,partRevision,RevColmn.index);
				updateXMLByRowId(contentFrame,level,partState,StateColmn.index);
				updateXMLByRowId(contentFrame,level,partType,TypeColmn.index);
				updateXMLByRowId(contentFrame,level,visualCueColumn,VisCuColmn.index);
                
                if(ActIcnColmn !=null){
                    updateXMLByRowId(contentFrame,level,actionIconColumn,ActIcnColmn.index);
                }
                if(stdActIcnColmn !=null){
                    updateXMLByRowId(contentFrame,level,actionIconColumn,stdActIcnColmn.index);
                }
                if(cstActIcnColmn !=null){
                    updateXMLByRowId(contentFrame,level,'<c>'+actionCustIcon+'</c>',cstActIcnColmn.index);
                }
                if(PartUsgColmn !=null){
                	updateXMLByRowId(contentFrame,level,partUsage,PartUsgColmn.index);
                }
                if(partPhaseColumn !=null){
                	updateXMLByRowId(contentFrame,level,releasePhase,partPhaseColumn.index);
                }
                if(changeContrColumn !=null){
                	updateXMLByRowId(contentFrame,level,changeControlled,changeContrColumn.index);
                }
    			// Logic to refresh the BOM Attributes.
                var FNColmn = colMapObj.getColumnByName("Find Number");
                var RDColmn = colMapObj.getColumnByName("ReferenceDesignator");
                var CLColmn = colMapObj.getColumnByName("ComponentLocation");
                var QuantityColmn = colMapObj.getColumnByName("Quantity");
                var UsgColmn = colMapObj.getColumnByName("Usage");
                var findno = "<%=XSSUtil.encodeForJavaScript(context,strFN)%>";
                var refdes = "<%=XSSUtil.encodeForJavaScript(context,strRD)%>";
                var comploc = "<%=XSSUtil.encodeForJavaScript(context,strCL)%>";
                var qty = "<%=XSSUtil.encodeForJavaScript(context,strQuantity)%>";
                var usg = "<%=XSSUtil.encodeForJavaScript(context,strUsg)%>";		  
                if(findno!="")
                {
                	updateXMLByRowId(contentFrame,level,'<c>'+findno+'</c>',FNColmn.index);
                }if(refdes!="")
                {
                    updateXMLByRowId(contentFrame,level,'<c>'+refdes+'</c>',RDColmn.index);
                    
                }if(comploc!="")
                {
                	updateXMLByRowId(contentFrame,level,'<c>'+comploc+'</c>',CLColmn.index);
                                    
                }if(qty!="")
                {
                    updateXMLByRowId(contentFrame,level,'<c>'+qty+'</c>',QuantityColmn.index);
                }if(usg!="")
                {
                    updateXMLByRowId(contentFrame,level,'<c>'+usg+'</c>',UsgColmn.index);
                }
				
				getTopWindow().window.getWindowOpener().rebuildView();
  
                //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                getTopWindow().closeWindow();
                </SCRIPT>
            <%
            }        
      }//************************************PreviewBOM - Generate OR Generate By Replace*****************************
      else if(strMode.equalsIgnoreCase("generate") || strMode.equalsIgnoreCase("generatebyreplace")) 
      {
            //if((strMode.equalsIgnoreCase("generate"))||(strMode.equalsIgnoreCase("generatebyreplace")))
            {
             	String logFeatId = emxGetParameter(request, "featureId");
            	strPartFamilyId = emxGetParameter(request, "partFamilyId");//(String)hmCurrentModifiedFeatureFromSession.get("partFamilyId");
              	if(!ProductLineCommon.isNotNull(strPartFamilyId)){
              		strPartFamilyId = ConfigurationUtil.getPartFamilyFromLogFeat(context,logFeatId);
              	}
              if (!context.isTransactionActive())
                  context.start(true);	
              partOid = pcBean.generatePart(context,strMode.trim(),strPartFamilyId.trim());
              if (context.isTransactionActive())
                  context.commit();
              //--------create part from part family end
              
              modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");  
              if(modifiedFeatures == null) 
              {
                  modifiedFeatures = new Hashtable();
              }
              HashMap hmModifiedData = new HashMap();
              hmModifiedData.put("mode",strMode);
              hmModifiedData.put("partId",partOid);
              hmModifiedData.put("generate",generate);
              hmModifiedData.put("duplicate",duplicate);
              hmModifiedData.put("featureId",featureId);
              hmModifiedData.put("parentId",parentId);
              hmModifiedData.put("PartMode",strPartMode);
              hmModifiedData.put("partFamilyId",strPartFamilyId);
              
              
    		  // IVU - BOM XML
    		  hmModifiedData.put("LFParentID",strLFParentId);
    		  hmModifiedData.put("isLFLeaf",strLFisLeaf);
              hmModifiedData.put("RemovedPart",strResolvedPart);
              hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);              
              hmModifiedData.put("DuplicateParts",strDuplicateParts);     
              hmModifiedData.put("ForcePartReuse",strForcePartReuse);
              
              if(modifiedFeatures.get(featureId)!=null && strLFisLeaf.equalsIgnoreCase("Yes")){
                  MapList mapDupLF = new MapList();
                  Object obj = modifiedFeatures.get(featureId);
                  if(obj!=null && obj instanceof MapList){
                	  mapDupLF.addAll((MapList)modifiedFeatures.get(featureId));
                  }else if(obj!=null && obj instanceof HashMap){
                	  mapDupLF.add((HashMap)modifiedFeatures.get(featureId));
                  }
            	  mapDupLF.add(hmModifiedData)	;
            	  modifiedFeatures.put(featureId,mapDupLF);
              }else{
            	  modifiedFeatures.put(featureId,hmModifiedData);  
              }
                	
                session.putValue("modifiedFeatures",modifiedFeatures);
                session.removeValue("currentmodifiedfeature");

              //cell refresh start
              Hashtable mapPartInfo = (Hashtable)ProductConfiguration.getPartInfo(context,partOid);
              String partName = (String)mapPartInfo.get(ConfigurationConstants.SELECT_NAME);
              String releasePhase = (String)mapPartInfo.get(ConfigurationConstants.SELECT_ATTRIBUTE_RELEASE_PHASE);
              
              String changeControlled = DomainConstants.EMPTY_STRING;
              HashMap partMap        = new HashMap();
  			  List<Map> objectList   = new MapList();
  			  partMap.put(DomainConstants.SELECT_ID, partOid);
  			  objectList.add(partMap);
  			
  			  HashMap programMap = new HashMap();
  			  programMap.put("objectList", objectList);
  			  String[] arrPackedArgument = (String[]) JPO.packArgs(programMap);
  			  Vector lstChangeControlled = (Vector)JPO.invoke(context, "enoECMChangeUX", null,"getHTMLForChangeControlValue", arrPackedArgument, Vector.class);
  			
  			  if(lstChangeControlled.size() > 0){
  				changeControlled = (String)lstChangeControlled.get(0);
  				System.out.println("changeControlled || " + changeControlled);
  				if(changeControlled.contains("content")){
  					changeControlled = changeControlled.replace("content", "popup");
  				}
  			  }
              
              partName = XSSUtil.encodeForXML(context,partName);
              String partRevision = (String)mapPartInfo.get(ConfigurationConstants.SELECT_REVISION);
              String partState = (String)mapPartInfo.get(ConfigurationConstants.SELECT_CURRENT);
              String partType = (String)mapPartInfo.get(ConfigurationConstants.SELECT_TYPE);
              Boolean strHigherRevExists = (Boolean)mapPartInfo.get("HigherRevisionExists");
              String higherRevision = "";
              String isObsolete = "";     
              if(!strHigherRevExists)
              {
                  higherRevision = "true";
              }
              if(partState.equalsIgnoreCase("obsolete"))
              {
                  isObsolete = "true";
              }                    
          
              boolean isEBOMDifferent = false; 
              isEBOMDifferent = pcBean.checkForEBOMDifferent(context,partOid.trim(),featureId.trim(),parentId.trim());
              boolean hasDuplicateParts = false;
              if(strDuplicateParts!=null && strDuplicateParts.length()>0){
            	  hasDuplicateParts = true;
              }
              
              String strToolTipReplaceByCreateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsCustom",strLanguage);
              String strToolTipReplaceByAddCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsCustom",strLanguage);
              String strToolTipReplaceByGenerateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsCustom",strLanguage);

              String strToolTipReplaceByCreateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsDefault",strLanguage);
              String strToolTipReplaceByAddDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsDefault",strLanguage);
              String strToolTipReplaceByGenerateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsDefault",strLanguage);
              
              String strToolTipCreateNewAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsCustom",strLanguage);
              String strToolTipAddExistAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsCustom",strLanguage);
              String strToolTipGenerateAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsCustom",strLanguage);
              
              String strToolTipCreateNewAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsDefault",strLanguage);
              String strToolTipAddExistAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsDefault",strLanguage);
              String strToolTipGenerateAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsDefault",strLanguage);

              String strToolTipInvalidQuantity = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.InvalidQuantity",strLanguage);
              String strToolTipHigherRevision  = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.HigherRevision",strLanguage);
              String strToolTipObsoletePart    = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.ObsoletePart",strLanguage);
              String strToolTipEBOMDifferent   = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.EBOMDifferent",strLanguage);
              String strToolTipUsedInBOM       = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.UsedInBOM",strLanguage);
              String strToolTipOptionalChoice = "";
              String strCustomPartMode = EnoviaResourceBundle.getProperty(context,"emxConfiguration.PreviewBOM.EnableCustomPartMode");
              if (ProductLineCommon.isNotNull(strCustomPartMode)&& strCustomPartMode.equalsIgnoreCase("true")) {                 
            	  strToolTipOptionalChoice = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage);
              } else {                         
                  strToolTipOptionalChoice = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage);
              }
              
              String strPartUsage = "";
              
              if(ProductLineCommon.isNotNull(strPartMode) && strPartMode.equalsIgnoreCase("custom")){
                  strPartUsage =EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Custom",strLanguage);
              }else{
                  strPartUsage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Default",strLanguage);
}
              
              if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_DEVELOPMENT.equalsIgnoreCase(releasePhase)){
              	releasePhase = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Development",strLanguage);
              }else if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_PRODUCTION.equalsIgnoreCase(releasePhase)){
              	releasePhase =EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Production",strLanguage);
              }
              
              // get the GBOM Attributes
              Map bomAttributes = ProductConfiguration.getBOMAttributes(context,null,featureId,strLFParentId,parentId);
           	  String strFN = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_FIND_NUMBER).toString();
           	  String strRD = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_REFERENCE_DESIGNATOR).toString();
           	  String strCL = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_COMPONENT_LOCATION).toString();
           	  String strQuantity =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_QUANTITY).toString();
           	  String strUsg =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_USAGE).toString();
              
           	String strPartGenerated = partType+" "+ partName+ " " + partRevision + (EnoviaResourceBundle.getProperty(context,"Configuration",
                    "emxProduct.PreviewBOM.GenerateByReplace",strLanguage));
              
              %>
              <SCRIPT language="javascript" type="text/javaScript">
              var level = "<%=XSSUtil.encodeForJavaScript(context,level)%>";      
              var newPart = "<%=partName%>";      
              var newRevision = "<%=XSSUtil.encodeForJavaScript(context,partRevision)%>";      
              var newState = "<%=XSSUtil.encodeForJavaScript(context,partState)%>";      
              var newType = "<%=XSSUtil.encodeForJavaScript(context,partType)%>";
              var isECInstalled = "<%=isECInstalled%>";
              var isQuantityInvalid = "<%=XSSUtil.encodeForJavaScript(context,isQuantityInvalid)%>";
              var displayGenerateIcon = "<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";
              var isUsedInBOM = "<%=XSSUtil.encodeForJavaScript(context,isUsedInBOM)%>";
              var higherRevision = "<%=higherRevision%>";
              var isObsolete = "<%=isObsolete%>";
              var isEBOMDifferent = "<%=isEBOMDifferent%>";
              var featureId = "<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
              var parentId = "<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
              var strLFParentId = "<%=XSSUtil.encodeForJavaScript(context,strLFParentId)%>";
              var strLFisLeaf = "<%=XSSUtil.encodeForJavaScript(context,strLFisLeaf)%>";
              var partUsage = "<c><%=strPartUsage%></c>"
              var visualCue='';
              var actionIcon='';
              var actionCustIcon='';
              var strToolTipReplaceByCreateCustom = "<%=strToolTipReplaceByCreateCustom%>";
              var strToolTipReplaceByAddCustom = "<%=strToolTipReplaceByAddCustom%>";
              var strToolTipReplaceByGenerateCustom = "<%=strToolTipReplaceByGenerateCustom%>";   
              var strToolTipReplaceByCreateDefault = "<%=strToolTipReplaceByCreateDefault%>";
              var strToolTipReplaceByAddDefault = "<%=strToolTipReplaceByAddDefault%>";
              var strToolTipReplaceByGenerateDefault = "<%=strToolTipReplaceByGenerateDefault%>";
              var strToolTipCreateNewAsCustom = "<%=strToolTipCreateNewAsCustom%>";
              var strToolTipAddExistAsCustom = "<%=strToolTipAddExistAsCustom%>";
              var strToolTipGenerateAsCustom = "<%=strToolTipGenerateAsCustom%>";   
              var strToolTipCreateNewAsDefault = "<%=strToolTipCreateNewAsDefault%>";
              var strToolTipAddExistAsDefault = "<%=strToolTipAddExistAsDefault%>";
              var strToolTipGenerateAsDefault = "<%=strToolTipGenerateAsDefault%>";   
              var strToolTipInvalidQuantity = "<%=strToolTipInvalidQuantity%>";
              var strToolTipHigherRevision = "<%=strToolTipHigherRevision%>";
              var strToolTipObsoletePart = "<%=strToolTipObsoletePart%>";
              var strToolTipEBOMDifferent = "<%=strToolTipEBOMDifferent%>";
              var strToolTipUsedInBOM = "<%=strToolTipUsedInBOM%>";      
              var partName = '';
              var hasDuplicateParts = "<%=hasDuplicateParts%>";
              var strToolTipOptionalChoice = "<%=strToolTipOptionalChoice%>"; 

              var strForcePartReuse    = "<%=XSSUtil.encodeForJavaScript(context,strForcePartReuse)%>";
              var strDuplicateParts    = "<%=XSSUtil.encodeForJavaScript(context,strDuplicateParts)%>";
              var strResolvedPart      = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPart)%>";
              var strResolvedPartRelId = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPartRelId)%>";   

              var partObjId = "<%=XSSUtil.encodeForJavaScript(context,partOid)%>";
              var partOIDElement = '<input type="hidden" value="'+partObjId+'"/>'; 

              var GBOMRelId = "";
              var GBOMRelIdlement = '<input type="hidden" value="'+GBOMRelId+'"/>';
              var releasePhase = "<c><%=XSSUtil.encodeForJavaScript(context,releasePhase)%></c>";           
              var changeControlled = "<c><%=changeControlled%></c>";
              
              if(isECInstalled=="true")
              {
                  partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+GBOMRelIdlement+'</c>';
              }
              else
              {
                  partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getAllEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getAllEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+GBOMRelIdlement+'</c>';
              }      
              var partRevision = '<c>'+newRevision+'</c>';
              var partState = '<c>'+newState+'</c>';
              var partType = '<c>'+newType+'</c>';
              var selectedAction = '<c a="&lt;img src=&quot;../common/images/IconSmallGenerateParts.png&quot;/&gt;"><img src="../common/images/IconSmallGenerateParts.png"/></c>';
              //logic to refresh visual cue cell start
              if(isQuantityInvalid=="true")
              {          
                  visualCue = '  <img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="'+strToolTipInvalidQuantity+'"/>';
              }
              if(higherRevision=="true")
              {
                  visualCue = visualCue + '  <img src="../common/images/HigherRevision16.png" border="0" align="middle" TITLE="'+strToolTipHigherRevision+'"/>';
              }     
              if(isObsolete=="true")
              {
                  visualCue = visualCue + '  <img src="../common/images/IconSmallObsoletePart.png" border="0" align="middle" TITLE="'+strToolTipObsoletePart+'"/>';
              }      
              if(isEBOMDifferent=="true")
              {          
                  visualCue = visualCue + '  <img src="../common/images/CompareDifferences16.png" border="0" align="middle" TITLE="'+strToolTipEBOMDifferent+'"/>';  
              }
              if(isUsedInBOM=="true")
              {
                  visualCue = visualCue + '  <img src="../common/images/UsedInBom16.png" border="0" align="middle" TITLE="'+strToolTipUsedInBOM+'"/>';
              }
              if(hasDuplicateParts=="true")
              {
                  visualCue = visualCue + '  <a><img src="../common/images/DuplicateParts16.png" border="0" align="middle" TITLE="'+strToolTipOptionalChoice+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=duplicate&amp;duplicate=true&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/></a>';
              }
              var visualCueColumn = '<c>'+visualCue+'</c>';
              if(isECInstalled=="true")
              {
                  actionIcon = '<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsDefault+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false\');"/></a>';
                  actionCustIcon = '<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsCustom+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;PartMode=custom\');"/></a>';;
              }
              actionIcon = actionIcon + ' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsDefault+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=null&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\')"/></a>';
              actionCustIcon = actionCustIcon +  ' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsCustom+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=custom&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\');"/></a>';
              if(displayGenerateIcon=="true")
              {
            	  actionIcon = actionIcon + "<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;LFParentID="+strLFParentId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsDefault+"\'/></a>";
            	  actionCustIcon = actionCustIcon +"<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;LFParentID="+strLFParentId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true&amp;PartMode=custom', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsCustom+"\'/></a>";
              }     
              var actionIconColumn = '<c>'+actionIcon+'</c>';   
              var colMapObj = findFrame(getTopWindow(),"content").colMap ; //getTopWindow().colMap;
              //var SelActColmn = colMapObj.getColumnByName("Selected Action");
              var PNColmn = colMapObj.getColumnByName("Part Number");
              var RevColmn = colMapObj.getColumnByName("Revision");
              var StateColmn = colMapObj.getColumnByName("State");
              var TypeColmn = colMapObj.getColumnByName("Type");
              var VisCuColmn = colMapObj.getColumnByName("Visual Cue");
              var ActIcnColmn = colMapObj.getColumnByName("Action Icons");
              var stdActIcnColmn = colMapObj.getColumnByName("Std Action Icons");
              var cstActIcnColmn = colMapObj.getColumnByName("Custom Actions Icons");
              var PartUsgColmn = colMapObj.getColumnByName("Part Usage");
              var partPhaseColumn = colMapObj.getColumnByName("Phase");
              var changeContrColumn= colMapObj.getColumnByName("Change Controlled");
              var contentFrame = "content";
			  
              //logic to refresh Action Icon cell end                
              //top.window.getWindowOpener().editableTable.updateXMLByRowId(level,selectedAction,SelActColmn.index);
              updateXMLByRowId(contentFrame,level,partName,PNColmn.index);
              updateXMLByRowId(contentFrame,level,partRevision,RevColmn.index);
              updateXMLByRowId(contentFrame,level,partState,StateColmn.index);
              updateXMLByRowId(contentFrame,level,partType,TypeColmn.index);
              updateXMLByRowId(contentFrame,level,visualCueColumn,VisCuColmn.index);

              if(ActIcnColmn !=null){
                  updateXMLByRowId(contentFrame,level,actionIconColumn,ActIcnColmn.index);
              }
              if(stdActIcnColmn !=null){
                  updateXMLByRowId(contentFrame,level,actionIconColumn,stdActIcnColmn.index);
              }
              if(cstActIcnColmn !=null){
                  updateXMLByRowId(contentFrame,level,'<c>'+actionCustIcon+'</c>',cstActIcnColmn.index);
              }
              if(PartUsgColmn !=null){
                  updateXMLByRowId(contentFrame,level,partUsage,PartUsgColmn.index);
 }
              if(partPhaseColumn !=null){
            	  updateXMLByRowId(contentFrame,level,releasePhase,partPhaseColumn.index);
              }
              if(changeContrColumn !=null){
            	  updateXMLByRowId(contentFrame,level,changeControlled,changeContrColumn.index);
              }

  			 // Logic to refresh the BOM Attributes.
              var FNColmn = colMapObj.getColumnByName("Find Number");
              var RDColmn = colMapObj.getColumnByName("ReferenceDesignator");
              var CLColmn = colMapObj.getColumnByName("ComponentLocation");
              var QuantityColmn = colMapObj.getColumnByName("Quantity");
              var UsgColmn = colMapObj.getColumnByName("Usage");
              var findno = "<%=XSSUtil.encodeForJavaScript(context,strFN)%>";
              var refdes = "<%=XSSUtil.encodeForJavaScript(context,strRD)%>";
              var comploc = "<%=XSSUtil.encodeForJavaScript(context,strCL)%>";
              var qty = "<%=XSSUtil.encodeForJavaScript(context,strQuantity)%>";
              var usg = "<%=XSSUtil.encodeForJavaScript(context,strUsg)%>";		  
              if(findno!="")
              {
              	updateXMLByRowId(contentFrame,level,'<c>'+findno+'</c>',FNColmn.index);
              }if(refdes!="")
              {
                updateXMLByRowId(contentFrame,level,'<c>'+refdes+'</c>',RDColmn.index);
                  
              }if(comploc!="")
              {
              	updateXMLByRowId(contentFrame,level,'<c>'+comploc+'</c>',CLColmn.index);
                                  
              }if(qty!="")
              {
                updateXMLByRowId(contentFrame,level,'<c>'+qty+'</c>',QuantityColmn.index);
              }if(usg!="")
              {
                updateXMLByRowId(contentFrame,level,'<c>'+usg+'</c>',UsgColmn.index);
              }
			  
			  findFrame(getTopWindow(), contentFrame).rebuildView();
              //XSS OK
              //alert("<%=strPartGenerated%>");
              //getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
              </SCRIPT>
              <%
              }
      }//************************************PreviewBOM - Generate Engineering BOM*****************************
      else if(strMode.equalsIgnoreCase("generateEngineeringEBOM")) 
      {
              Hashtable hsModifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
              if(hsModifiedFeatures!=null && hsModifiedFeatures.size()>0) 
              {
                    MapList hmModifiedFeatures = new MapList();
                    Map mapTemp = new HashMap();
                    Map mapTemp1 = new HashMap();
                    Enumeration en = hsModifiedFeatures.keys();
                    while(en.hasMoreElements())
                    {
                        Object obj = hsModifiedFeatures.get(en.nextElement());
                        if(obj!=null && obj instanceof MapList){
                     	   MapList mapListTemp = (MapList) obj;
                     	   for(int k=0; k<mapListTemp.size();k++){
                     		   hmModifiedFeatures.add(mapListTemp.get(k));
                     	   }
                        }else if(obj!=null && obj instanceof HashMap){
                            mapTemp = (HashMap)obj;
                            hmModifiedFeatures.add(mapTemp);
                        }
                    }
                    HashMap programMap = new HashMap();
                    mapTemp1.put("modifiedFeatures",hmModifiedFeatures);
                    MapList objectList1 = new MapList();
                    objectList1.add(mapTemp1);
                    programMap.put("objectList", objectList1);
                    pcBean.processApplyAction(context,programMap,emxGetParameter(request,"objectId"),"");
                    session.removeValue("modifiedFeatures");
              }
              try
              {
                  String strProductConfigurationID = emxGetParameter(request,"objectId");
                  Map pcInfoMap = ProductConfiguration.getPCInfo(context,strProductConfigurationID);
                  boolean isTopLevelPart = false;
                  String strTopLevelObjId = (String)pcInfoMap.get("from["+ConfigurationConstants.RELATIONSHIP_TOP_LEVEL_PART+"].to."+ConfigurationConstants.SELECT_ID);
                  if(strTopLevelObjId == null) 
                  {
                          // check for part family associated with product
                          String objProductId = (String)pcInfoMap.get("to["
									                                  + ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION
									                                  + "].from."
									                                  + ConfigurationConstants.SELECT_ID);
                         LogicalFeature lfbean = new LogicalFeature(objProductId);
                         MapList gbomList = lfbean.getActiveGBOMStructure(context, ConfigurationConstants.TYPE_PART_FAMILY, "", new StringList(), ProductConfiguration.getRelSelectsForGBOM(), false, true, 1, 0, null, null, (short)0, ""); 
                         if (gbomList.size() != 1) 
                         {                      
                              // No part family with product, so error out.
                              String strNoTLPFailure = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.NoTopLevelPartFailure",strLanguage);
                              if(gbomList.size() > 1){
                            	  strNoTLPFailure = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.MultiplePartFamily",strLanguage);
                              }
                          %>
                          <SCRIPT language="javascript" type="text/javaScript">
                              getTopWindow().isgenerateBOMClicked=false;
                              alert("<%=strNoTLPFailure%>");
                          </SCRIPT>
                          <%
                         }
                         else
                         {
                              isTopLevelPart = true;
                         }
                  }
                  else
                  {
                      isTopLevelPart=true;
                  }
                  if(isTopLevelPart)
                  {
                	 ENOCsrfGuard.validateRequest(context, session, request, response);
                    pcBean.generateEBOMForProductConfiguration(context,strProductConfigurationID);                    
                    if(strTopLevelObjId==null)
                    {
                    	 pcInfoMap = ProductConfiguration.getPCInfo(context,strProductConfigurationID);
                         strTopLevelObjId = (String)pcInfoMap.get("from["+ConfigurationConstants.RELATIONSHIP_TOP_LEVEL_PART+"].to."+ConfigurationConstants.SELECT_ID);
                    }
                    String strPC = strProductConfigurationID;
                    String strTLP = strTopLevelObjId;
                    String strBOMGenerated = EnoviaResourceBundle.getProperty(context,"Configuration",
                                                               "emxProduct.Alert.EBOMGeneratedSuccessfully",strLanguage);
                   
                    
                    if(isECInstalled)
                    {                   
                        %>
                         
                        <SCRIPT language="javascript" type="text/javaScript">
                        var strPC = '<%=XSSUtil.encodeForJavaScript(context,strPC)%>';
                          
                          var strTLP = '<%=XSSUtil.encodeForJavaScript(context,strTLP)%>';
                          var strTreeId = "<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "jsTreeID"))%>";
                          var strURL;
                          strURL = "../common/emxTree.jsp?mode=insert&jsTreeID=" + strTreeId + "&DefaultCategory=ENCEBOMPowerViewCommand&objectId=";
                          
                          var strTLP = '<%=XSSUtil.encodeForJavaScript(context,strTLP)%>';
                          if(strTLP!="null" && strTLP!=""){                              
                              strURL        = strURL  + strTLP;
                          }
                          else{
                              strURL        = strURL  + strPC;
                          }
                          //XSSOK
                          //display alert
                          alert("<%=strBOMGenerated%>");
                          getTopWindow().isgenerateBOMClicked=false;
                        //to refresh back side window Moved here to fix Safari specific issue
                          getTopWindow().getWindowOpener().location.href=strURL;
                          if(isIE)
                          {       
                            getTopWindow().open('','_self','');   
                            getTopWindow().close();
                          }
                          else
                          {
                            getTopWindow().close();
                          }
                              
                        </SCRIPT>
                    <%
                    }
                    else
                    {
                        %>
                        <SCRIPT language="javascript" type="text/javaScript">
                                    
                        strTLP = '<%=XSSUtil.encodeForJavaScript(context,strTLP)%>';
                        strPC = '<%=XSSUtil.encodeForJavaScript(context,strPC)%>';
                        strURL    = "../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getEBOMWithSelects&categoryTreeName=type_ProductConfiguration&table=FTRBOMSummary&header=emxComponents.BOM.TableHeading&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelpebom&PrinterFriendly=true&editRootNode=false&relationship=relationship_EBOM&direction=from&SuiteDirectory=configuration&suiteKey=Configuration&objectId=";
                        strURL    = strURL  + strPC;
                        strURL    = strURL+"&parentOID="  + strPC;
                        //XSSOK
                        //display alert
                        alert("<%=strBOMGenerated%>");
                        getTopWindow().isgenerateBOMClicked=false;
                        //to refresh back side window Moved here to fix Safari specific issue
                        getTopWindow().getWindowOpener().location.href=strURL;
                        if(isIE)
                        {       
                           getTopWindow().open('','_self','');   
                           getTopWindow().close();
                        }
                        else
                        {
                           getTopWindow().close();
                        }
                        </SCRIPT>
            <%
                      }                      
                   }             
              }
              catch(Exception e)
              {
                  %>
                  <SCRIPT language="javascript" type="text/javaScript">
                      getTopWindow().isgenerateBOMClicked=false;
                  </SCRIPT>
                  <%
                          session.putValue("error.message", e.getMessage());                      
              }
        }else if(strMode.equalsIgnoreCase("duplicate")) 
        {
          //cell refresh start         
            if(partOid==null) {
            %>
            <SCRIPT language="javascript" type="text/javaScript">          
            var strURL    = "../common/emxIndentedTable.jsp?program=emxProductConfigurationEBOM:getDuplicateParts&table=FTRSearchPartsTable&selection=single";              
            strURL        = strURL  + "&parentId=<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
            strURL        = strURL  + "&featureId=<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
            strURL        = strURL  + "&objectId=<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
            //strURL        = strURL  + "&CancelButton=true";
            strURL        = strURL  + "&header=emxConfiguration.HeadingOptionalChoices";
            strURL        = strURL  + "&suiteKey=Configuration";
            strURL        = strURL  + "&submitLabel=emxProduct.Button.Done";
            strURL        = strURL  + "&cancelLabel=emxProduct.Button.Cancel";
            strURL        = strURL  + "&HelpMarker=emxhelpduplicatepartresolve";
            if(<%=isFTRUser%>||<%=isCMMUser%>){
                strURL        = strURL  + "&submitURL=../configuration/PreviewBOMProcess.jsp?PartMode=<%=XSSUtil.encodeForJavaScript(context,strPartMode)%>";
            }
            strURL        = strURL  + "&displayGenerateIcon=<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";
            strURL        = strURL  + "&LFParentID=<%=XSSUtil.encodeForJavaScript(context,strLFParentId)%>";
            strURL        = strURL  + "&isLFLeaf=<%=XSSUtil.encodeForJavaScript(context,strLFisLeaf)%>";
            strURL        = strURL  + "&ResolvedPart=<%=XSSUtil.encodeForJavaScript(context,strResolvedPart)%>";
            strURL        = strURL  + "&ResolvedPartRelID=<%=XSSUtil.encodeForJavaScript(context,strResolvedPartRelId)%>";            
            strURL        = strURL  + "&ForcePartReuse=<%=XSSUtil.encodeForJavaScript(context,strForcePartReuse)%>";
            
            document.location.href = strURL;
            </SCRIPT>
            <% } else {
                
                String partOidRelIds[] = emxGetParameterValues(request, "emxTableRowId");
             	String arrObjectIds[] = (String[])(ProductLineUtil.getObjectIdsRelIds(partOidRelIds)).get("ObjId");
             	StringTokenizer stObjIDs = new StringTokenizer(arrObjectIds[0],"|");
             	partOid = stObjIDs.nextToken();
             	
             	String arrRelIds[] = (String[])(ProductLineUtil.getObjectIdsRelIds(partOidRelIds)).get("RelId");
             	StringTokenizer stRelIDs = new StringTokenizer(arrRelIds[0],"|");
             	String strGBOMRelId = stRelIDs.nextToken();
             	
             	
            	  DomainRelationship domGBOMRel = new DomainRelationship(strGBOMRelId);
            	  String strRelType = (String)((StringList)((domGBOMRel.getRelationshipData(context,new StringList(ConfigurationConstants.SELECT_TYPE))).get(ConfigurationConstants.SELECT_TYPE))).get(0);
            	  if(!ProductLineCommon.isNotNull(strPartMode) && ProductLineCommon.isOfParentRel(context,strRelType,ConfigurationConstants.RELATIONSHIP_CUSTOM_GBOM)){
            		  strPartMode = "custom";
            	  }
            	  modifiedFeatures = (Hashtable)session.getValue("modifiedFeatures");
            	  HashMap hmModifiedData = new HashMap();
            	  if(modifiedFeatures == null) {
            		  modifiedFeatures = new Hashtable();
            		  hmModifiedData.put("mode",strMode);
            		  hmModifiedData.put("partId",partOid);
            		  hmModifiedData.put("RelId",strGBOMRelId);
            		  hmModifiedData.put("generate",generate);
            		  hmModifiedData.put("duplicate",duplicate);
            		  hmModifiedData.put("featureId",featureId);
            		  hmModifiedData.put("parentId",parentId);
            		  hmModifiedData.put("PartMode",strPartMode);
            		  
            		  // IVU - BOM XML
            		  hmModifiedData.put("LFParentID",strLFParentId);
            		  hmModifiedData.put("isLFLeaf",strLFisLeaf);
                      hmModifiedData.put("RemovedPart",strResolvedPart);
                      hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);                      
                      hmModifiedData.put("DuplicateParts",strDuplicateParts);      
                      hmModifiedData.put("ForcePartReuse",strForcePartReuse);
                      
            	  } else{
            		  if(strLFisLeaf.equalsIgnoreCase("Yes")){
            			  //code change for bug 362127 end
            			  hmModifiedData.put("mode",strMode);
            			  hmModifiedData.put("partId",partOid);
                          hmModifiedData.put("RelId",strGBOMRelId);
            			  hmModifiedData.put("generate",generate);
            			  hmModifiedData.put("duplicate",duplicate);
            			  hmModifiedData.put("featureId",featureId);
            			  hmModifiedData.put("parentId",parentId);
            			  hmModifiedData.put("PartMode",strPartMode);
                          hmModifiedData.put("RemovedPart",strResolvedPart);
                          hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);
                          hmModifiedData.put("ForcePartReuse",strForcePartReuse);
            		  }else{
                		  hmModifiedData = (HashMap)modifiedFeatures.get(featureId);
                		  if(hmModifiedData!=null){
                			  hmModifiedData.put("partId",partOid);
                              hmModifiedData.put("RelId",strGBOMRelId);
                              hmModifiedData.put("PartMode",strPartMode);
                              hmModifiedData.put("RemovedPart",strResolvedPart);
                              hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);
                              hmModifiedData.put("ForcePartReuse",strForcePartReuse);
                		  }else{
                			  //code change for bug 362127 start
                			  if(hmModifiedData==null){
                				  hmModifiedData = new HashMap();
                			  }
                			  //code change for bug 362127 end
                			  hmModifiedData.put("mode",strMode);
                			  hmModifiedData.put("partId",partOid);
                              hmModifiedData.put("RelId",strGBOMRelId);
                			  hmModifiedData.put("generate",generate);
                			  hmModifiedData.put("duplicate",duplicate);
                			  hmModifiedData.put("featureId",featureId);
                			  hmModifiedData.put("parentId",parentId);
                			  hmModifiedData.put("PartMode",strPartMode);
                              hmModifiedData.put("RemovedPart",strResolvedPart);
                              hmModifiedData.put("RemovedPartRelId",strResolvedPartRelId);
                              hmModifiedData.put("ForcePartReuse",strForcePartReuse);
                		  }
            		  }
            	  }
                  if(modifiedFeatures.get(featureId)!=null && strLFisLeaf.equalsIgnoreCase("Yes")){
                      MapList mapDupLF = new MapList();
                      Object obj = modifiedFeatures.get(featureId);
                      if(obj!=null && obj instanceof MapList){
                    	  mapDupLF.addAll((MapList)modifiedFeatures.get(featureId));
                      }else if(obj!=null && obj instanceof HashMap){
                    	  mapDupLF.add((HashMap)modifiedFeatures.get(featureId));
                      }
                	  mapDupLF.add(hmModifiedData)	;
                	  modifiedFeatures.put(featureId,mapDupLF);
                  }else{
                	  modifiedFeatures.put(featureId,hmModifiedData);  
                  }
                    	
                  session.putValue("modifiedFeatures",modifiedFeatures);
                  session.removeValue("currentmodifiedfeature");
            	  
            	  Part selPartObj = new Part(partOid);
            	  String partName = selPartObj.getInfo(context,"name");
            	  String partRevision =selPartObj.getInfo(context,"revision");
            	  String partpolicy = selPartObj.getInfo(context,"policy");
            	  String partCurrentState = selPartObj.getInfo(context,"current");
            	  String partState = EnoviaResourceBundle.getStateI18NString(context, 
            			  partpolicy, partCurrentState,strLanguage);


            	  String partType = selPartObj.getInfo(context,"type");
            	  String releasePhase = selPartObj.getInfo(context,ConfigurationConstants.SELECT_ATTRIBUTE_RELEASE_PHASE);
				  
				  String changeControlled = DomainConstants.EMPTY_STRING;
				  HashMap partMap        = new HashMap();
				  List<Map> objectList   = new MapList();
				  partMap.put(DomainConstants.SELECT_ID, partOid);
				  objectList.add(partMap);
				
				  HashMap progMap = new HashMap();
				  progMap.put("objectList", objectList);
				  String[] arrPackedArgument = (String[]) JPO.packArgs(progMap);
				  Vector lstChangeControlled = (Vector)JPO.invoke(context, "enoECMChangeUX", null,"getHTMLForChangeControlValue", arrPackedArgument, Vector.class);
				
				  if(lstChangeControlled.size() > 0){
					changeControlled = (String)lstChangeControlled.get(0);
					System.out.println("changeControlled || " + changeControlled);
					if(changeControlled.contains("JavaScript:emxTableColumnLinkClick")){
    					String changeId   = changeControlled.substring(changeControlled.indexOf("objectId=")+9, changeControlled.indexOf("',"));
    			    	String changeName = changeControlled.substring(changeControlled.indexOf("/>")+2, changeControlled.indexOf("</a>"));
    			    	changeControlled  = "<a class=\\\"object\\\" href=\\\"JavaScript:emxTableColumnLinkClick('../common/emxTree.jsp?objectId="+changeId+"', '800', '575','true','popup')\\\"><img border=\\\"0\\\" src=\\\"../common/images/iconSmallChangeAction.png\\\"/>"+changeName+"</a>";
    				}
				  }
				  
            	  String higherRevision = "";
            	  String isObsolete = "";
            	  
            	  Map bomAttributes = ProductConfiguration.getBOMAttributes(context,strGBOMRelId,featureId,strLFParentId,parentId);
            	  String strFN = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_FIND_NUMBER).toString();
            	  String strRD = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_REFERENCE_DESIGNATOR).toString();
            	  String strCL = bomAttributes.get(ConfigurationConstants.ATTRIBUTE_COMPONENT_LOCATION).toString();
            	  String strQuantity =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_QUANTITY).toString();
            	  String strUsg =  bomAttributes.get(ConfigurationConstants.ATTRIBUTE_USAGE).toString();
            	  
		       	  isECInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMEngineering",false,null,null);
		       	  StringTokenizer strTokenizer = new StringTokenizer(partOid, "|");
        	      String strTempPart = strTokenizer.nextToken();
	        	  Part selPartObjTemp = new Part(strTempPart);
	        	  boolean isUsedInEBOM = pcBean.checkForUsedInBOM(context,featureId,strTempPart,strLFParentId,parentId); 
	        	  isUsedInBOM = String.valueOf(isUsedInEBOM);
	        	  
	        	  strResolvedPart = strTempPart;
	        	  strResolvedPartRelId = strGBOMRelId;
	       	
	       	  if(!selPartObjTemp.isLastRevision(context)){
	       		  higherRevision = "true";
	       	  }
            if((selPartObj.getInfo(context,ConfigurationConstants.SELECT_CURRENT)).equalsIgnoreCase("obsolete")){
                isObsolete = "true";
            }
            Map mapTemp = new HashMap();
            Map programMap = new HashMap();
            String[] arrJPOArguments=new String[1];
            mapTemp.put(ConfigurationConstants.SELECT_ID,partOid.trim());
            mapTemp.put("featureId",featureId.trim());
            
            mapTemp.put("parentId",parentId.trim());
            MapList objectList1 = new MapList();
            objectList1.add(mapTemp);
            programMap.put("objectList", objectList1);
            arrJPOArguments = JPO.packArgs(programMap);
             
             boolean isEBOMDifferent = false; 
             isEBOMDifferent = pcBean.checkForEBOMDifferent(context,partOid.trim(),featureId.trim(),parentId.trim());
             
             String strToolTipReplaceByCreateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsCustom",strLanguage);
             String strToolTipReplaceByAddCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsCustom",strLanguage);
             String strToolTipReplaceByGenerateCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsCustom",strLanguage);

             String strToolTipReplaceByCreateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByCreateNewAsDefault",strLanguage);
             String strToolTipReplaceByAddDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByAddExistingAsDefault",strLanguage);
             String strToolTipReplaceByGenerateDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.ReplabeByGenerateAsDefault",strLanguage);
             
             String strToolTipCreateNewAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsCustom",strLanguage);
             String strToolTipAddExistAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsCustom",strLanguage);
             String strToolTipGenerateAsCustom = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsCustom",strLanguage);
             
             String strToolTipCreateNewAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.CreateNewAsDefault",strLanguage);
             String strToolTipAddExistAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.AddExistingAsDefault",strLanguage);
             String strToolTipGenerateAsDefault = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.GenerateAsDefault",strLanguage);

                String strToolTipInvalidQuantity = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.InvalidQuantity",strLanguage);
                String strToolTipHigherRevision = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.HigherRevision",strLanguage);
                String strToolTipObsoletePart = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.ObsoletePart",strLanguage);
                String strToolTipEBOMDifferent =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.EBOMDifferent",strLanguage);
                String strToolTipUsedInBOM = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.UsedInBOM",strLanguage);
                String strToolTipDuplicate = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.ToolTip.VisualCue.DuplicateParts",strLanguage);
                String strPartUsage = "";
                
                if(ProductLineCommon.isNotNull(strPartMode) && strPartMode.equalsIgnoreCase("custom")){
                    strPartUsage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Custom",strLanguage);
                }else{
                    strPartUsage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Range.Part_Usage.Default",strLanguage);
}
                
                if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_DEVELOPMENT.equalsIgnoreCase(releasePhase)){
                	releasePhase = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Development",strLanguage);
                }else if(ProductLineCommon.isNotNull(releasePhase) && ConfigurationConstants.RANGE_VALUE_RELEASE_PHASE_PRODUCTION.equalsIgnoreCase(releasePhase)){
                	releasePhase =EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ReleasePhase.Production",strLanguage);
                }
                
            %>
            <SCRIPT language="javascript" type="text/javaScript">
            var level = "<%=XSSUtil.encodeForJavaScript(context,level)%>";
            var newPart = "<%=XSSUtil.encodeForJavaScript(context,partName)%>";
            var newRevision = "<%=XSSUtil.encodeForJavaScript(context,partRevision)%>";
            var newState = "<%=XSSUtil.encodeForJavaScript(context,partState)%>";
            var newType = "<%=XSSUtil.encodeForJavaScript(context,partType)%>";
            var isECInstalled = "<%=isECInstalled%>";
            var isQuantityInvalid = "<%=XSSUtil.encodeForJavaScript(context,isQuantityInvalid)%>";
            var displayGenerateIcon = "<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";
            var isUsedInBOM = "<%=XSSUtil.encodeForJavaScript(context,isUsedInBOM)%>";
            var higherRevision = "<%=higherRevision%>";
            var isObsolete = "<%=isObsolete%>";
            var isEBOMDifferent = "<%=isEBOMDifferent%>";
            var featureId = "<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
            var parentId = "<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
            var partUsage = "<c><%=strPartUsage%></c>"
            var visualCue='';
            var actionIcon='';
            var actionCustIcon='';
            var strToolTipReplaceByCreateCustom = "<%=strToolTipReplaceByCreateCustom%>";
            var strToolTipReplaceByAddCustom = "<%=strToolTipReplaceByAddCustom%>";
            var strToolTipReplaceByGenerateCustom = "<%=strToolTipReplaceByGenerateCustom%>";   
            var strToolTipReplaceByCreateDefault = "<%=strToolTipReplaceByCreateDefault%>";
            var strToolTipReplaceByAddDefault = "<%=strToolTipReplaceByAddDefault%>";
            var strToolTipReplaceByGenerateDefault = "<%=strToolTipReplaceByGenerateDefault%>";
            var strToolTipCreateNewAsCustom = "<%=strToolTipCreateNewAsCustom%>";
            var strToolTipAddExistAsCustom = "<%=strToolTipAddExistAsCustom%>";
            var strToolTipGenerateAsCustom = "<%=strToolTipGenerateAsCustom%>";   
            var strToolTipCreateNewAsDefault = "<%=strToolTipCreateNewAsDefault%>";
            var strToolTipAddExistAsDefault = "<%=strToolTipAddExistAsDefault%>";
            var strToolTipGenerateAsDefault = "<%=strToolTipGenerateAsDefault%>";   
            var strToolTipInvalidQuantity = "<%=strToolTipInvalidQuantity%>";
            var strToolTipHigherRevision = "<%=strToolTipHigherRevision%>";
            var strToolTipObsoletePart = "<%=strToolTipObsoletePart%>";
            var strToolTipEBOMDifferent = "<%=strToolTipEBOMDifferent%>";
            var strToolTipUsedInBOM = "<%=strToolTipUsedInBOM%>";
            var strToolTipDuplicate = "<%=strToolTipDuplicate%>";
            var partOID = "<%=XSSUtil.encodeForJavaScript(context,partOid)%>";
            var GBOMRelId = "<%=XSSUtil.encodeForJavaScript(context,strGBOMRelId)%>";
            var strLFisLeaf="<%=XSSUtil.encodeForJavaScript(context,strLFisLeaf)%>";
            var partOIDElement = '<input type="hidden" value="'+partOID+'"/>'; 
            var GBOMRelIdlement = '<input type="hidden" value="'+GBOMRelId+'"/>';
          //Added for IR-341141 - Updating variable for custom part
            var bNotDuplicate = "<%=XSSUtil.encodeForJavaScript(context,duplicate)%>";
            
            var strLFParentId        = "<%=XSSUtil.encodeForJavaScript(context,strLFParentId)%>";
            var strForcePartReuse    = "<%=XSSUtil.encodeForJavaScript(context,strForcePartReuse)%>";
            var strDuplicateParts    = "<%=XSSUtil.encodeForJavaScript(context,strDuplicateParts)%>";
            var strResolvedPart      = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPart)%>";
            var strResolvedPartRelId = "<%=XSSUtil.encodeForJavaScript(context,strResolvedPartRelId)%>";   
            
            var partName = '';
            var releasePhase = "<c><%=XSSUtil.encodeForJavaScript(context,releasePhase)%></c>"; 
            var changeControlled = "<c><%=changeControlled%></c>";
			
            if(isECInstalled=="true"){
                partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgramMenu=ENCBOMDisplayFormat&amp;table=ENCEBOMIndentedSummary&amp;header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&amp;reportType=BOM&amp;sortColumnName=Find Number&amp;sortDirection=ascending&amp;HelpMarker=emxhelppartbom&amp;suiteKey=EngineeringCentral&amp;PrinterFriendly=true&amp;toolbar=ENCBOMToolBar&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+GBOMRelIdlement +'</c>';
            }
            else{
                partName = '<c a="&lt;img src=&quot;../common/images/iconSmallPart.gif&quot;/&gt;&lt;a href=&quot;JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;SuiteDirectory=configuration&amp;suiteKey=Configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')&quot;&gt;'+newPart+'&lt;/a&gt;'+'"><img src="../common/images/iconSmallPart.gif"/><img src="../common/images/iconStatusChanged.gif"/><a href="JavaScript:showDialog(\'../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getEBOMWithSelects&amp;table=FTRBOMSummary&amp;header=emxComponents.BOM.TableHeading&amp;sortColumnName=Name&amp;sortDirection=ascending&amp;HelpMarker=emxhelpebom&amp;PrinterFriendly=true&amp;relationship=relationship_EBOM&amp;direction=from&amp;suiteKey=Configuration&amp;SuiteDirectory=configuration&amp;objectId= '+ '<%=XSSUtil.encodeForJavaScript(context,partOid)%>'+'\')"> '+newPart+'</a>'+partOIDElement+ GBOMRelIdlement +'</c>';
            }
            
            var partRevision = '<c>'+newRevision+'</c>';
            var partState = '<c>'+newState+'</c>';
            var partType = '<c>'+newType+'</c>';
            //var selectedAction = '<c a="&lt;img src=&quot;../common/images/iconSmallCreatePart.png&quot;/&gt;"><img src="../common/images/iconSmallCreatePart.png"/></c>';
            //logic to refresh visual cue cell start
            if(isQuantityInvalid=="true"){
                
                visualCue = '  <img src="../common/images/iconStatusError.gif" border="0" align="middle" TITLE="'+strToolTipInvalidQuantity+'"/>';
                
            }
            if(higherRevision=="true"){
                visualCue = visualCue + '  <img src="../common/images/HigherRevision16.png" border="0" align="middle" TITLE="'+strToolTipHigherRevision+'"/>';
                
            }
            
            if(isObsolete=="true"){
                visualCue = visualCue + '  <img src="../common/images/IconSmallObsoletePart.png" border="0" align="middle" TITLE="'+strToolTipObsoletePart+'"/>';
                
            }
            
            if(isEBOMDifferent=="true"){
                
                visualCue = visualCue + '  <img src="../common/images/CompareDifferences16.png" border="0" align="middle" TITLE="'+strToolTipEBOMDifferent+'"/>';
                
            }
            if(isUsedInBOM=="true"){
                visualCue = visualCue + '  <img src="../common/images/UsedInBom16.png" border="0" align="middle" TITLE="'+strToolTipUsedInBOM+'"/>';
            }



            var strURL    = "../configuration/PreviewBOMProcess.jsp?";
            strURL        = strURL  + "&amp;parentId=<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
            strURL        = strURL  + "&amp;featureId=<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
            strURL        = strURL  + "&amp;objectId=<%=XSSUtil.encodeForJavaScript(context,featureId)%>";
            strURL        = strURL  + "&amp;LFParentID=<%=XSSUtil.encodeForJavaScript(context,parentId)%>";
            strURL        = strURL  + "&amp;ResolvedPart=<%=XSSUtil.encodeForJavaScript(context,strResolvedPart)%>";
            strURL        = strURL  + "&amp;ResolvedPartRelID=<%=XSSUtil.encodeForJavaScript(context,strResolvedPartRelId)%>";            
            strURL        = strURL  + "&amp;isLFLeaf=<%=XSSUtil.encodeForJavaScript(context,strLFisLeaf)%>";
            strURL        = strURL  + "&amp;ForcePartReuse=<%=XSSUtil.encodeForJavaScript(context,strForcePartReuse)%>";
            strURL        = strURL  + "&amp;displayGenerateIcon=<%=XSSUtil.encodeForJavaScript(context,displayGenerateIcon)%>";
            strURL        = strURL  + "&amp;level=<%=XSSUtil.encodeForJavaScript(context,level)%>";
            strURL        = strURL  + "&amp;isQuantityInvalid=<%=XSSUtil.encodeForJavaScript(context,isQuantityInvalid)%>";
            strURL        = strURL  + "&amp;mode=duplicate&amp;duplicate=true";
            
			if(bNotDuplicate=="true")
	           	visualCue = visualCue + '  <a><img src="../common/images/DuplicateParts16.png" border="0" align="middle" TITLE="'+strToolTipDuplicate+'" onclick="javascript:showDialog(\''+strURL+'\');"/></a>';
            
            var visualCueColumn = '<c>'+visualCue+'</c>';
            //logic to refresh visual cue cell end
             if(isECInstalled=="true")
              {
                  actionIcon = '<a><img src="../common/images/IconSmallReplacePartNewPart.png" border="0" align="middle" TITLE="'+strToolTipReplaceByCreateDefault+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;isLFLeaf='+strLFisLeaf+'&amp;generate=false\');"/></a>';
                  actionCustIcon ='<a><img src="../common/images/iconSmallCreatePart.png" border="0" align="middle" TITLE="'+strToolTipCreateNewAsCustom+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=replacebycreatepart&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;isLFLeaf='+strLFisLeaf+'&amp;generate=false&amp;PartMode=custom\');"/></a>';
              }
              actionIcon = actionIcon + ' <a><img src="../common/images/IconSmallReplacePartExistingPart.png" border="0" align="middle" TITLE="'+strToolTipReplaceByAddDefault+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=null&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\')"/></a>';
              actionCustIcon= actionCustIcon +' <a><img src="../common/images/IconSmallAddExistingPart.png" border="0" align="middle" TITLE="'+strToolTipAddExistAsCustom+'" onclick="javascript:showModalDialog(\'../common/emxFullSearch.jsp?field=TYPES=type_Part:CURRENT!=policy_ECPart.state_Obsolete:POLICY!=policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart&amp;table=FTRFeatureSearchResultsTable&amp;HelpMarker=emxhelpfullsearch&amp;showInitialResults=false&amp;hideHeader=true&amp;featureId='+featureId+'&amp;Object='+featureId+'&amp;LFParentID='+strLFParentId+'&amp;isLFLeaf='+strLFisLeaf+'&amp;ForcePartReuse='+strForcePartReuse+'&amp;DuplicateParts='+strDuplicateParts+'&amp;suiteKey=Configuration&amp;selection=single&amp;mode=replacebyaddexisting&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;ResolvedPart='+strResolvedPart+'&amp;ResolvedPartRelID='+strResolvedPartRelId+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=false&amp;submitURL=../configuration/PreviewBOMProcess.jsp?level='+level+'&amp;PartMode=custom&amp;displayGenerateIcon=true \', \'700\', \'600\', \'true\',\'Large\');"/></a>';              
              if(displayGenerateIcon=="true")
              {
                  //actionIcon = actionIcon + ' <a><img src="../common/images/IconSmallReplaceNewGeneratedPart.png" border="0" align="middle" TITLE="'+strToolTipGenerate+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=true\');"/></a>';
                  actionIcon = actionIcon + "<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallReplaceNewGeneratedPart.png\" title=\'"+strToolTipReplaceByGenerateDefault+"\'/></a>";                  
                  //actionCustIcon=actionCustIcon+' <a><img src="../common/images/IconSmallGenerateParts.png" border="0" align="middle" TITLE="'+strToolTipGeneratePart+'" onclick="javascript:showDialog(\'../configuration/PreviewBOMProcess.jsp?featureId='+featureId+'&amp;level='+level+'&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId='+parentId+'&amp;isQuantityInvalid='+isQuantityInvalid+'&amp;isUsedInBOM='+isUsedInBOM+'&amp;displayGenerateIcon='+displayGenerateIcon+'&amp;generate=true&amp;PartMode=custom\');"/></a>';
                  actionCustIcon = actionCustIcon +"<a href=\"javaScript:emxTableColumnLinkClick('../configuration/PreviewBOMProcess.jsp?featureId="+featureId+"&amp;isLFLeaf="+strLFisLeaf+"&amp;level="+level+"&amp;mode=generatebyreplace&amp;duplicate=false&amp;parentId="+parentId+"&amp;isQuantityInvalid="+isQuantityInvalid+"&amp;isUsedInBOM="+isUsedInBOM+"&amp;displayGenerateIcon="+displayGenerateIcon+"&amp;generate=true&amp;PartMode=custom', '700', '600', 'true', 'listHidden', '')\"><img border=\"0\" align=\"middle\" src=\"../common/images/IconSmallGenerateParts.png\" title=\'"+strToolTipGenerateAsCustom+"\'/></a>";
              }     
              var actionIconColumn = '<c>'+actionIcon+'</c>';              
            var colMapObj = getTopWindow().window.getWindowOpener().colMap;
            //var SelActColmn = colMapObj.getColumnByName("Selected Action");
            var PNColmn = colMapObj.getColumnByName("Part Number");
            var RevColmn = colMapObj.getColumnByName("Revision");
            var StateColmn = colMapObj.getColumnByName("State");
            var TypeColmn = colMapObj.getColumnByName("Type");
            var VisCuColmn = colMapObj.getColumnByName("Visual Cue");
            var ActIcnColmn = colMapObj.getColumnByName("Action Icons");
            var stdActIcnColmn = colMapObj.getColumnByName("Std Action Icons");
            var cstActIcnColmn = colMapObj.getColumnByName("Custom Actions Icons");
            var PartUsgColmn = colMapObj.getColumnByName("Part Usage");
            var partPhaseColumn = colMapObj.getColumnByName("Phase");
            var changeContrColumn= colMapObj.getColumnByName("Change Controlled");  
			
			// Logic to refresh the BOM Attributes.
            var FNColmn = colMapObj.getColumnByName("Find Number");
            var RDColmn = colMapObj.getColumnByName("ReferenceDesignator");
            var CLColmn = colMapObj.getColumnByName("ComponentLocation");
            var QuantityColmn = colMapObj.getColumnByName("Quantity");
            var UsgColmn = colMapObj.getColumnByName("Usage");
            var findno = "<%=XSSUtil.encodeForJavaScript(context,strFN)%>";
            var refdes = "<%=XSSUtil.encodeForJavaScript(context,strRD)%>";
            var comploc = "<%=XSSUtil.encodeForJavaScript(context,strCL)%>";
            var qty = "<%=XSSUtil.encodeForJavaScript(context,strQuantity)%>";
            var usg = "<%=XSSUtil.encodeForJavaScript(context,strUsg)%>";
			var contentFrame = "listHidden";
            
            //logic to refresh Action Icon cell end
            updateXMLByRowId(contentFrame,level,partName,PNColmn.index);
            updateXMLByRowId(contentFrame,level,partRevision,RevColmn.index);
            updateXMLByRowId(contentFrame,level,partState,StateColmn.index);
            updateXMLByRowId(contentFrame,level,partType,TypeColmn.index);
            updateXMLByRowId(contentFrame,level,visualCueColumn,VisCuColmn.index);

            if(findno!="")
            {
            	updateXMLByRowId(contentFrame,level,'<c>'+findno+'</c>',FNColmn.index);
            }if(refdes!="")
            {
                updateXMLByRowId(contentFrame,level,'<c>'+refdes+'</c>',RDColmn.index);
                
            }if(comploc!="")
            {
            	updateXMLByRowId(contentFrame,level,'<c>'+comploc+'</c>',CLColmn.index);
                                
            }if(qty!="")
            {
                updateXMLByRowId(contentFrame,level,'<c>'+qty+'</c>',QuantityColmn.index);
            }if(usg!="")
            {
                updateXMLByRowId(contentFrame,level,'<c>'+usg+'</c>',UsgColmn.index);
            }
            
            if(ActIcnColmn !=null){
                updateXMLByRowId(contentFrame,level,actionIconColumn,ActIcnColmn.index);
            }
            if(stdActIcnColmn !=null){
                updateXMLByRowId(contentFrame,level,actionIconColumn,stdActIcnColmn.index);
            }
            if(cstActIcnColmn !=null){
                updateXMLByRowId(contentFrame,level,'<c>'+actionCustIcon+'</c>',cstActIcnColmn.index);
            }
            if(PartUsgColmn !=null){
                updateXMLByRowId(contentFrame,level,partUsage,PartUsgColmn.index);
            }
            if(partPhaseColumn !=null){
            	updateXMLByRowId(contentFrame,level,releasePhase,partPhaseColumn.index);
            }
            if(changeContrColumn !=null){
            	updateXMLByRowId(contentFrame,level,changeControlled,changeContrColumn.index);
            }
			
			getTopWindow().window.getWindowOpener().rebuildView();
            //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
            getTopWindow().closeWindow();
            </SCRIPT>
        <%
            } 
	} else if (strMode.equalsIgnoreCase("displayBOM")) {
		isECInstalled = FrameworkUtil.isSuiteRegistered(context,
				"appVersionX-BOMEngineering", false, null, null);
		String strPC = emxGetParameter(request, "objectId");
		pcBean.setId(strPC);
		String strTLP = pcBean.getInfo(context, "from["
				+ ConfigurationConstants.RELATIONSHIP_TOP_LEVEL_PART
				+ "].to.id");
		if (isECInstalled) {
%>
<SCRIPT language="javascript" type="text/javaScript">
            var strPC = '<%=XSSUtil.encodeForJavaScript(context,strPC)%>';
            var strTreeId = "<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "jsTreeID"))%>";
            var errMssg = "<%=EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.NoTopLevelPartFailure",context.getSession().getLanguage())%>"
            var strURL;
            strURL = "../common/emxTree.jsp?mode=insert&jsTreeID=" + strTreeId + "&DefaultCategory=ENCEBOMPowerViewCommand&objectId=";
            
            var strTLP = '<%=XSSUtil.encodeForJavaScript(context,strTLP)%>';
            var strURL;
            if(strTLP!="null" && strTLP!=""){
                strURL        = strURL  + strTLP;                
            }
            else{
            	 strURL    = "../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getEBOMWithSelects&categoryTreeName=type_ProductConfiguration&table=FTRBOMSummary&header=emxComponents.BOM.TableHeading&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelpebom&PrinterFriendly=true&editRootNode=false&relationship=relationship_EBOM&direction=from&SuiteDirectory=configuration&suiteKey=Configuration&objectId=";
                strURL        = strURL  + strPC;
                strURL        = strURL+"&parentOID="  + strPC;
            }
            var contentFrame = findFrame(getTopWindow(), "detailsDisplay");
            contentFrame.location.href = strURL;           
          </SCRIPT>
<%
	}
	      else{
	          %>
	          <SCRIPT language="javascript" type="text/javaScript">
	          	          
	          strTLP = '<%=XSSUtil.encodeForJavaScript(context,strTLP)%>';
	          strPC = '<%=XSSUtil.encodeForJavaScript(context,strPC)%>';
	          strURL    = "../common/emxIndentedTable.jsp?expandProgram=emxProductConfigurationEBOM:getEBOMWithSelects&categoryTreeName=type_ProductConfiguration&table=FTRBOMSummary&header=emxComponents.BOM.TableHeading&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelpebom&PrinterFriendly=true&editRootNode=false&relationship=relationship_EBOM&direction=from&SuiteDirectory=configuration&suiteKey=Configuration&objectId=";
              strURL    = strURL  + strPC;
              strURL        = strURL+"&parentOID="  + strPC;
	          var contentFrame = findFrame(getTopWindow(), "detailsDisplay");
	          contentFrame.location.href = strURL;
	          </SCRIPT>
	      <%
	      }    
	}
}catch(Exception e)
{
      session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

