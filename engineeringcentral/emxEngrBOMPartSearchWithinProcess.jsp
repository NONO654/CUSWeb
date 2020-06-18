<%-- emxEngrBOMPartSearchWithinProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<% String frameName = emxGetParameter(request,"frameName");%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
 var frameName = "<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>";
	var dupemxUICore   = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName).emxUICore;
	var dupTimeStamp   = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName).timeStamp;
	var mxRoot         = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName).oXML.documentElement;
	var selectedObject = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked = 'checked']");
	if (selectedObject == null  || selectedObject == undefined)
	{
		selectedObject = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows/r");
	}
	var arrSelect = new Array();

</script>
<%

Map mapKeyPartId = (Map)session.getAttribute("mapKeyPartId");
String strFromPlantSpecific =(String) session.getAttribute("fromPlantSpecific");
com.matrixone.apps.engineering.Part partObj = new com.matrixone.apps.engineering.Part();
String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
for (int i=0; i < selectedItems.length ;i++){
	StringList slTokens = FrameworkUtil.split(" "+selectedItems[i], "|");
	String strSelected = (String)slTokens.get(1);
	strSelected = DomainObject.newInstance(context,strSelected).getInfo(context, DomainObject.SELECT_ID);

	StringList slParentStructure = (StringList)mapKeyPartId.get(strSelected);

	if(slParentStructure != null){
		for(int j=0;j<slParentStructure.size();j++){
			String strHierarchy = (String)slParentStructure.get(j);
			%>
			<script language="javascript">
				var vHierarchy = "<xss:encodeForJavaScript><%=strHierarchy%></xss:encodeForJavaScript>";
				var vSelected  = "<xss:encodeForJavaScript><%=strSelected%></xss:encodeForJavaScript>";
				var arrHierarchy = vHierarchy.split("|");
				var countHierarchy = arrHierarchy.length - 1;
				var checkObject = selectedObject;
			</script>
			<script language="javascript">
			</script>
			<script language="javascript" src="../common/scripts/emxUICore.js"></script>
			<script language="javascript">
				var expand = checkObject.getAttribute("expand");
				if(expand == null || (typeof expand == 'undefined')){
					var pLevel = checkObject.getAttribute("level");
					var pRowIdArr = new Array();
					pRowIdArr[0] = checkObject.getAttribute("id");
					getTopWindow().getWindowOpener().emxEditableTable.expand(pRowIdArr, pLevel);
				}
				// Start: Bug 370797
				else if(expand == 'true')
				{
					selectedObject.setAttribute("display","block");
				}
				// End: Bug 370797
				//expand(checkObject);				
				do{
					var selectRows = dupemxUICore.selectNodes(checkObject, "r[@o='"+vSelected+"']");
					if(selectRows.length >0 && countHierarchy == -1){
						for(var i=0;i<selectRows.length;i++){
							//selectRows[i].setAttribute("checked", "checked");
							arrSelect.push(selectRows[i].getAttribute("id"));
						}
					}
					else{
						var expandRow = dupemxUICore.selectSingleNode(checkObject, "r[@o='"+arrHierarchy[countHierarchy]+"']");
						if(expandRow != null){
							var expandC = expandRow.getAttribute("expand");
							if(expandC == null || (typeof expandC == 'undefined')){
								var parentLevel = expandRow.getAttribute("level");
								var parentRowIdArr = new Array();
								parentRowIdArr[0] = expandRow.getAttribute("id");
								getTopWindow().getWindowOpener().emxEditableTable.expand(parentRowIdArr, parentLevel);
							}
							// Start: Bug 370797
							else if(expandC == 'true')
							{
								expandRow.setAttribute("display","block");
							}
							// End: Bug 370797
							//expand(expandRow);
							checkObject = expandRow;
						}
					}
					countHierarchy--;
				}while(countHierarchy >= -1);

			</script>
			<%
		}
	}
}
session.removeAttribute("fromPlantSpecific");
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName).emxEditableTable.select(arrSelect);
var selectedRowIdArr = new Array();
selectedRowIdArr[0] = selectedObject.getAttribute("id");
emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName).emxEditableTable.unselect(selectedRowIdArr);
arrSelect = new Array();
getTopWindow().closeWindow();
</script>
