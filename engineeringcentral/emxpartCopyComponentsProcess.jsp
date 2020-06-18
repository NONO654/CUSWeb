<%-- emxpartCopyComponentsProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUIUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.constants.BOMMgtConstants"%>

<jsp:useBean id="connectPart" class="com.matrixone.apps.engineering.Part" scope="session" />
<%
  DomainObject partObj = DomainObject.newInstance(context);
  DomainObject selObj = DomainObject.newInstance(context);


  String objectId     = emxGetParameter(request, "sObjectId");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String relType      = DomainConstants.RELATIONSHIP_EBOM;
  DomainObject dobj = DomainObject.newInstance(context, objectId);
  String sType = dobj.getInfo(context,DomainConstants.SELECT_TYPE);
  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
   suiteKey = "EngineeringCentral";
  }

  boolean booError      =false;
  Map StoredAttributes  =new HashMap();
  String RelId          ="";

  partObj.setId(objectId);

	String[] objectid = emxGetParameterValues(request, "objectId");
	String strPartId = objectid[0];

	HashMap programMap = new HashMap();
	programMap.put("objectId", strPartId);

	Boolean  blnIsApplyAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);

	boolean blnApply = blnIsApplyAllowed.booleanValue();


  // get the Selected EBOM's RelIds
  String strRelEbomIds  = (String) session.getAttribute("strRelEbomIds");

  Vector attrNames = new Vector();
  Map attrMap = DomainRelationship.getAttributeTypeMapFromRelType(context,relType);
  Iterator itr = attrMap.keySet().iterator();
  while(itr.hasNext())
  {
    Map mapinfo = (Map)attrMap.get((String)itr.next());
    attrNames.addElement(mapinfo.get("name"));

  }

  // Get the User Entered Attribute Values & put that into a Map
  if(strRelEbomIds !=null){
  StringTokenizer st0 = new StringTokenizer(strRelEbomIds, ",");
  int Count = st0.countTokens();
  for(int i =0; i <Count; i++)
  {
    try
    {
      RelId = st0.nextToken();
      Map map = new HashMap();
      Enumeration e = attrNames.elements();
      while(e.hasMoreElements())
      {
          String attrName = (String)e.nextElement();
          String attribute = emxGetParameter(request, attrName+i);
          map.put(attrName,attribute);
      }

      String strFindNumber =emxGetParameter(request, "FindNumber"+String.valueOf(i));
      if (strFindNumber == null){
        strFindNumber = "";
      }


      String qty =emxGetParameter(request, "Qty"+String.valueOf(i));
      if (qty == null){
        qty = "";
      }

      map.put(DomainConstants.ATTRIBUTE_FIND_NUMBER,strFindNumber);
      map.put(DomainConstants.ATTRIBUTE_QUANTITY,qty);
      map.put(DomainConstants.ATTRIBUTE_USAGE,"Standard");

      StoredAttributes.put(RelId,map);

    }
    catch(Exception Ex)
    {
       session.putValue("error.message",Ex.getMessage());
    }
  }  // if ends for selectedECRs

  }

  Pattern typePattern = new Pattern(DomainObject.TYPE_PART);
  Pattern relPattern  = new Pattern(DomainObject.RELATIONSHIP_EBOM);
  StringList objectSelect = new StringList();
  objectSelect.add(DomainObject.SELECT_ID);
  StringList relationshipSelects = new StringList();
  relationshipSelects.add(DomainObject.SELECT_RELATIONSHIP_ID);

  // Get already connected EBOMs of Target Part
  MapList connectedObjs = partObj.getRelatedObjects(context, relPattern.getPattern(), typePattern.getPattern(),objectSelect, relationshipSelects, false, true, (short)1, null, null);

  String strXML = "<mxRoot><object objectId=\"" + objectId + "\">";

  // Connect the Selected EBoms to the Target Part
  if(strRelEbomIds !=null){
    StringTokenizer st1 = new StringTokenizer(strRelEbomIds, ",");
    int count = st1.countTokens();
%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%
   for(int k =0; k <count; k++)
    {
    try {
           RelId = st1.nextToken();
           String selOid = emxGetParameter(request, "selId"+String.valueOf(k));
           //IR-059773: Added to retrieve Find number, ref des and other values
           String selFN = emxGetParameter(request, "selFN" + k);
           String selQTY = emxGetParameter(request, "selQTY" + k);
           String selUSG = emxGetParameter(request, "selUSG" + k);
           String selRD = emxGetParameter(request, "selRD" + k);
           String selCMPLOC = emxGetParameter(request, "selCMPLOC" + k);
           String selNOTE = emxGetParameter(request, "selNOTE" + k);
           String selSOURCE = emxGetParameter(request, "selSOURCE" + k);
           selCMPLOC = FrameworkUtil.findAndReplace(selCMPLOC,"&","&amp;");
           selNOTE = FrameworkUtil.findAndReplace(selNOTE,"&","&amp;");
           selSOURCE = FrameworkUtil.findAndReplace(selSOURCE,"&","&amp;");
           String selUOM = emxGetParameter(request, "selUOM" + k);
           selObj.setId(selOid);
          //Added for IR-097616V6R2012 starts                        
          /* String   strLangUsage = i18nNow.getI18nString("emxFramework.Range.Usage."+ selUSG.replaceAll(" ","_"),
                   "emxFrameworkStringResource", context.getSession().getLanguage());*/
          String   strLangUsage = EnoviaResourceBundle.getProperty(context ,"emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.Usage."+ selUSG.replaceAll(" ","_"));
          //Added for IR-097616V6R2012 ends
           //Check if it Already connected
           String ObjId="";
           String relId="";
           
           String vpmControlState = "false".equalsIgnoreCase( BOMMgtUIUtil.getBOMColumnDesignCollaborationValue(context, strPartId, null) ) ? "true" : "false";
           String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
           String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
           boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false);  
           String selPartInstance = (new DomainRelationship(RelId)).getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_TITLE);
   		   String selPartInstanceDesc = (new DomainRelationship(RelId)).getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_DESCRIPTION);
           
           Map attrmap1 = (Map)StoredAttributes.get(RelId);
            //DomainRelationship dr = partObj.connect(context,relType, selObj, false);
            //dr.setAttributeValues(context, attrmap1);
            //connectPart.connectPartToBOMBean(context, objectId, selOid, relType);
            StringBuffer sb = new StringBuffer();
            sb.append(strXML);
            sb.append("<object objectId=\"" + selOid + "\" relId=\"\" markup=\"add\" relType=\"relationship_EBOM\">");
            sb.append("<column name=\"Find Number\" edited=\"true\">"+selFN+"</column>");
            sb.append( "<column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column>");
            sb.append( "<column name=\"Quantity\" edited=\"true\">"+selQTY+"</column>");
            sb.append("<column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column>");
            sb.append("<column name=\"Notes\" edited=\"true\">"+selNOTE+"</column>");
            sb.append("<column name=\"Source\" edited=\"true\">"+selSOURCE+"</column>");
            sb.append("<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"); //UOM Management
            sb.append("<column name=\"InstanceTitle\" edited=\"true\">"+selPartInstance+"</column>");
            sb.append("<column name=\"InstanceDescription\" edited=\"true\">"+selPartInstanceDesc+"</column>");
            
       		if("true".equalsIgnoreCase(vpmControlState)) { 
       			sb.append("<column name=\"VPMVisible\" edited=\"true\" a=\"False\" actual=\"False\">"+strVPMVisibleFalse+"</column>");
            } else {
               	sb.append("<column name=\"VPMVisible\" edited=\"true\" a=\"True\" actual=\"True\">"+strVPMVisibleTrue+"</column>");
            } 
            
            //Modified for IR-097616V6R2012 
            sb.append("<column name=\"Usage\" edited=\"true\" a=\""+selUSG+"\">"+strLangUsage+"</column></object>");
            strXML = sb.toString();
            
         } catch(Exception ex) {
           booError=true;
           session.putValue("error.message",ex.getMessage());
          //Commented for Bug Fix 302270 - Start
           //ContextUtil.abortSavePoint(context, "CopySelectedTo");
          //Commented for Bug Fix 302270 - End
         }
    }

	strXML = FrameworkUtil.findAndReplace(strXML,"'","\\\'");
	strXML = strXML + "</object></mxRoot>";

    session.setAttribute("XMLINFO",strXML);
  }
if (!booError)
{
%>
   <%@include file = "emxEngrCommitTransaction.inc"%>
<%
}

  // Construct the Attribute values map to Restore the Previos page with values
  if(booError){
      session.setAttribute("StoredAttrMapList",StoredAttributes);
      String strPageURL = "emxpartCopyComponentsEditEBOMsDialogFS.jsp?objectId="+objectId+"&errorFlag=true";
      strPageURL = Framework.encodeURL(response, strPageURL);
%>
      <script language="Javascript">
      //XSSOK
        document.location.href = "<%=XSSUtil.encodeForJavaScript(context,strPageURL)%>";
      </script>
<%
  } else {
    session.removeAttribute("strRelEbomIds");
    session.removeAttribute("searchPARTprop_KEY");
    session.removeAttribute("selectedPARTprop");
%>

<%@include file = "emxDesignBottomInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript">

//Modified for IR-173121 start
//var strURL="../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&selection=multiple&editRootNode=false&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>&mode=edit&preProcessURL=../engineeringcentral/emxEngrBOMCopyToPreProcess.jsp&preProcessJPO=emxPart:sendXML&showApply=<%=blnApply%>&connectionProgram=emxPart:updateBOM&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
//XSSOK
var strURL="../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&table=ENCEBOMIndentedSummarySB&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&BOMMode=ENG&selection=multiple&editRootNode=false&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>&mode=edit&preProcessURL=../engineeringcentral/emxEngrBOMCopyToPreProcess.jsp&preProcessJPO=emxPart:sendXML&showApply=<%=blnApply%>&connectionProgram=enoUnifiedBOM:bomConnection&relType=EBOM&postProcessJPO=enoUnifiedBOM:updateBOM&openShowModalDialog=true&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&type=<%= sType%>&showRMBInlineCommands=true&showReplaceCommands=true";
//document.location.href = "../common/emxNavigatorDialog.jsp?contentURL=" + escape(strURL);
//window.location.href= strURL;
showNonModalDialog(strURL);
setTimeout(function() {
	closeWindow();
}, 900);
</script>

<%
  }
%>


