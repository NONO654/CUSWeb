 <%-- CopyFromProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
   
<%@include file="../emxUIFramesetUtil.inc"%>
<%@ page import="java.util.List"%>
<%@ page import="com.matrixone.jdom.*,com.matrixone.jdom.input.*,com.matrixone.jdom.output.*,com.matrixone.jsystem.util.StringUtils"%>
<%@ page import="com.matrixone.apps.effectivity.*"%>
<%@ page import="com.matrixone.apps.domain.*"%>
<%@ page import="com.matrixone.apps.domain.util.*"%>
<%@ page import="com.matrixone.apps.unresolvedebom.CFFUtil"%>
<%-- <jsp:useBean id="unresolvedEBOM" class="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" scope="session"/>
<jsp:useBean id="unresolvedBean" class="com.matrixone.apps.unresolvedebom.UnresolvedPart" scope="session"/> --%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>   
<script language="Javascript">
var objWin        = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),'PUEUEBOM');//getTopWindow().getWindowOpener();
var prevParID     = ""; 
var prevParRow    = null;
var currParRow    = null;


function copySelectedRows(postXML,currParID,prevParID,closeWindow) {
     try {
         var dupemxUICore  = objWin.emxUICore;
         var xmlDOM        = dupemxUICore.createXMLDOM();
         xmlDOM.loadXML(postXML);
         dupemxUICore.checkDOMError(xmlDOM);
               //make the previous parent id attribute checked empty and current parent id attribute checked
                 if(prevParID != "" && prevParID != currParID) {
                     prevParRow   = dupemxUICore.selectSingleNode(objWin.oXML,"/mxRoot/rows//r[@o = '" + prevParID + "']");
                     prevParRow.setAttribute("checked","");
                     currParRow   = dupemxUICore.selectSingleNode(objWin.oXML,"/mxRoot/rows//r[@o = '" + currParID + "']");
                     currParRow.setAttribute("checked","checked");
                 }    
                var callback = eval(objWin.emxEditableTable.addToSelected);
                var status   = callback(xmlDOM.xml);
                if (closeWindow) {
                	currParRow = dupemxUICore.selectSingleNode(objWin.oXML,"/mxRoot/rows//r[@o = '" + currParID + "']");
                	var checkedRows = emxUICore.selectNodes(objWin.oXML, "/mxRoot/rows//r[@checked='checked']");
                	var arrRowIds= new Array();
                	var rowsLength  = checkedRows.length; 
                	if (checkedRows != null && rowsLength > 0){
                		for(var i=0; i<rowsLength; i++){
                			arrRowIds[i] = checkedRows[i].getAttribute("id");
                		}
                	}	
                	//currParRow.setAttribute("checked","");
                	//objWin.clearAllCheckedItems();
                	//objWin.emxEditableTable.refreshRowByRowId(currParRow.getAttribute("id"));
                	objWin.emxEditableTable.unselect(arrRowIds);
                    parent.closeWindow();  
                }  
    } catch (e) {
        alert(e.message);
    }
}         

</script>
<%
    Map requestMap = (Map)request.getParameterMap();
    StringBuffer strInput  = new StringBuffer();
    strInput.append("<mxRoot>").append("<action>add</action>").append("<data status=\"pending\">");
    String language  = request.getHeader("Accept-Language");
    String strInvalidSelectionMsg = i18nStringNowUtil("emxUnresolvedEBOM.Alert.BadStructureSelection","emxUnresolvedEBOMStringResource", language);
      
    String oXML        		= ((String [])requestMap.get("oXML"))[0];
    String selectedParts    = emxGetParameter(request,"selectedParts");
    StringList slObjectList = FrameworkUtil.splitString(selectedParts, "~");

    String  strWipMode = emxGetParameter(request,"isWipMode");
    boolean isWipMode  ="false".equalsIgnoreCase(strWipMode)?false:true;
    
    Element rootElement = null;
    SAXBuilder builder  = null;
    Document docXML     = null;
    
    XMLOutputter xmlOutputter = null;
    //String strTarPartId       = unresolvedEBOM.getSTargetPartId(); 
   // String strTarCtxtECOId    = unresolvedEBOM.getSTargetCtxtECOId();
    String strTarPartId       ="";
    String strTarCtxtECOId    ="";
    String ecoName      = "";
    String displayValue = ""; 
    String inputStr 	= "";
    
    if (!isWipMode) {
	    com.matrixone.apps.domain.DomainObject ecoObj = new com.matrixone.apps.domain.DomainObject(strTarCtxtECOId);
	    matrix.util.StringList ecoSelectables = new matrix.util.StringList(com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
	    java.util.Map<String,String> ecoMap   = ecoObj.getInfo(context,ecoSelectables);
	    ecoName        = ecoMap.get(com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
	    //displayValue   = unresolvedBean.getEffectivityValue(context, strTarCtxtECOId, EffectivityFramework.DISPLAY_VALUE, true);
	    displayValue   = "";
    }
    
    String relId   = "";
    String selOid  = ""; 
    String parenId = "";
    String selFN   = "";
    String selRD   = "";
   
    String selQTY  = "";
    String selLoc  = "";
    String selUSG  = "";
    String currParId = "";
    String currLevel = "";
    String prevLevel = "";
    String selUOM = "";
    HashMap paramMap   = new HashMap();
    
    try{
        builder          = new SAXBuilder();
		builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
		builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
		builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        docXML           = builder.build(new java.io.StringReader(oXML));
        rootElement      = docXML.getRootElement();
        List rows        = rootElement.getChild("rows").getChildren();
        Iterator rowIter = rows.iterator();
        Element row      = null;
        Element column   = null;
        while(rowIter.hasNext()){
                row     = (Element)rowIter.next();
                relId   = row.getAttributeValue("r");
                parenId = row.getAttributeValue("p");
                currLevel = row.getAttributeValue("level");
                
                column    =(Element)row.getChild("column");
                selFN     = column.getAttributeValue("FindNo");
                selRD     = column.getAttributeValue("RefDes");
                selQTY    = column.getAttributeValue("Qty");
                selLoc    = column.getAttributeValue("CompLoc");
                selUSG    = column.getAttributeValue("Usage");
                selUOM    = column.getAttributeValue("UOM");
                	if (!"".equals(prevLevel) && !prevLevel.equals(currLevel)) {
                    //if the level changed then close the xml construction and call the callbackfunction
                    strInput.append("</data></mxRoot>");
                    inputStr = StringUtils.replaceAll(strInput.toString(),"&","&amp;");


%>                  
                    <script language="Javascript">
                     copySelectedRows("<%=XSSUtil.encodeForJavaScript(context,inputStr)%>", "<%=XSSUtil.encodeForJavaScript(context,currParId)%>", prevParID, false);
                     prevParID    = "<%=XSSUtil.encodeForJavaScript(context, currParId)%>";
                    </script>
<%                
                    strInput = new StringBuffer();
                    strInput.append("<mxRoot>").append("<action>add</action>").append("<data status=\"pending\">");
             
              } 
                prevLevel = currLevel;
                selOid    = row.getAttributeValue("o");
                strInput.append("<item oid=\"").append(selOid).append("\" pid=\"");
                //if the retrieved parent id of each row is not in the selected obj list then obviously parent will be target parent.
                currParId = ("1".equals(currLevel) || !slObjectList.contains(parenId))?strTarPartId:parenId;
                strInput.append(currParId);
                //String relationshipToFollow = isWipMode?"relationship_EBOM":"relationship_EBOMPending";
                
                String relationshipToFollow = "relationship_EBOM";
                
                strInput.append("\" relType=\"" +relationshipToFollow+ "\">");
                if (!isWipMode) {
	                strInput.append("<column name=\"Add\">");
	                strInput.append(ecoName).append("</column>");
                }
                strInput.append("<column name=\"Find Number\" edited=\"true\">");
                strInput.append(selFN);
                strInput.append("</column><column name=\"Reference Designator\" edited=\"true\">");
                strInput.append(selRD);
                strInput.append("</column><column name=\"Quantity\" edited=\"true\">");
                strInput.append(selQTY);
                strInput.append("</column><column name=\"Component Location\" edited=\"true\">");
                strInput.append(selLoc);
                strInput.append("</column><column name=\"UOM\" edited=\"true\">");
                strInput.append(selUOM);
                strInput.append("</column><column name=\"Usage\" edited=\"true\">");
                strInput.append(selUSG).append("</column>");
                if (!isWipMode) {
	                strInput.append("<column name=\"ProposedEffectivity\">");
	                strInput.append(displayValue);
	                strInput.append("</column>");
                }
                strInput.append("</item>");
                
         }        
                strInput.append("</data></mxRoot>");
                inputStr = StringUtils.replaceAll(strInput.toString(),"&","&amp;");
                inputStr = strInput.toString();

%>
                    <script language="Javascript">
                    //XSSOK
                    copySelectedRows("<%=XSSUtil.encodeForJavaScript(context,inputStr)%>","<%=XSSUtil.encodeForJavaScript(context,currParId)%>",prevParID,true);
                    </script>
<%  

  }    
    catch (Exception e){
       throw new Exception(e);
    }
%>
