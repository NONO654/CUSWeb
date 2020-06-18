<%--  emxTeamTreeUtilInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%
	String action = emxGetParameter(request, "menuAction");
%>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
	//XSSOK
	var action = "<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(action)%>";
	var topRef = getTopWindow();
	if("moveFolder"==action)
	{
		topRef=getTopWindow().getWindowOpener().getTopWindow();
	}
	
 function changeTreeNodeName(sFolderId, sTreeLabel)
  {
    var contentFrame = openerFindFrame(getTopWindow(), "content");
    var strucTree     = contentFrame.objStructureTree;
    if(strucTree && !strucTree.objects[sFolderId]){
    	strucTree     = contentFrame.getTopWindow().objStructureTree;
    }     
    var contextTree       = contentFrame.getTopWindow().objDetailsTree;    
	    if(strucTree){
    var struTreeNodeArray = strucTree.objects[sFolderId];
    if(struTreeNodeArray) {
    var i = 0;
    var nodeLabel = "";
    //XSS OK
    var linkedLabel = "(" + "<%=i18nNow.getI18nString("emxTeamCentral.Common.Linked","emxTeamCentralStringResource",request.getHeader("Accept-Language"))%>" + ")";
    var linkedLabelPattern = /\(<%=i18nNow.getI18nString("emxTeamCentral.Common.Linked","emxTeamCentralStringResource",request.getHeader("Accept-Language"))%>\)$/i;
    for(i = 0; i < struTreeNodeArray.nodes.length; i++){
    var currentLabel = struTreeNodeArray.nodes[i].text;
    nodeLabel = sTreeLabel;
    if(linkedLabelPattern.test(currentLabel)){
    nodeLabel = sTreeLabel + linkedLabel;
    }
   		 struTreeNodeArray.nodes[i].changeNodeStructureTreeClick(nodeLabel);
         // this functions are added for ie10 suport IR-200653V6R2014 
   		 struTreeNodeArray.nodes[i].setText(nodeLabel);
         struTreeNodeArray.nodes[i].setHtmlText(nodeLabel.htmlEncode(false));
         //end of IR-200653V6R2014 
         struTreeNodeArray.nodes[i].tree.doNavigate=false;
         struTreeNodeArray.nodes[i].changeObjectName(sTreeLabel,false);
    }
    }
  }
  
	  }
  
   function deleteTreeNode(sObjectId, blnRefresh)
  {
    var contentFrame = openerFindFrame(topRef, "content");
    var strucTree     = contentFrame.getTopWindow().objStructureTree;
    var contextTree       = contentFrame.getTopWindow().objDetailsTree;
    var struTreeNodeArray = strucTree.objects[sObjectId];
    if(struTreeNodeArray) {
    var i = 0;
    //XSS OK
    var linkedLabel = "(" + "<%=i18nNow.getI18nString("emxTeamCentral.Common.Linked","emxTeamCentralStringResource",request.getHeader("Accept-Language"))%>" + ")";
    var linkedLabelPattern = /\(<%=i18nNow.getI18nString("emxTeamCentral.Common.Linked","emxTeamCentralStringResource",request.getHeader("Accept-Language"))%>\)$/i;
    for(i = 0; i < struTreeNodeArray.nodes.length; i++){
    var currentLabel = struTreeNodeArray.nodes[i].text;
    if(!linkedLabelPattern.test(currentLabel)){
       if(struTreeNodeArray.nodes[i].parent != null){
       struTreeNodeArray.nodes[i].parent.removeChildByID(struTreeNodeArray.nodes[i].nodeID, blnRefresh);
       }
    }
    }
    }
  }
</script>
