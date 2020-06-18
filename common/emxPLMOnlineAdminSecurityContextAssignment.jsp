<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%
    String ctxName  = emxGetParameter(request,"ctxName");
	// RBR2: FUN[080973]
	String ctxTitle = emxGetParameter(request,"ctxTitle"); 
		
%>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript">
	addStyleSheet("emxUIToolbar");
</script>
<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
<script>
    var xmlreqs = new Array();
    var ctxTitle = "";
  	function formatResponseAssignments(){
           var xmlhttp2= xmlreqs[0];
            xmlhttp2.onreadystatechange=function()
            {
                if(xmlhttp2.readyState==4){
                   var ctxName = xmlhttp2.responseXML.getElementsByTagName("Context");
                     ctxTitle = ctxName[0].getElementsByTagName("V_Name")[0].firstChild.data;
                     updateTitleWindow(ctxTitle);
                   var tableResultat = document.getElementById("tabRes");
                   if(ctxName.length == 0){
                   }else{
                            for (var i = 0 ; i < ctxName.length ; i++){								
                                var ctxChild="";
                                if (ctxName[i].getElementsByTagName("member") != null){ 
									ctxChild = ctxName[i].getElementsByTagName("member");
								} 
                                if(ctxChild.length>0){
                                    for (var j = 0 ; j < ctxChild.length ; j++){
										var row=tableResultat.insertRow(-1);
										var newCell = addCellInARow(row, "MatrixFeel", 0);
                                        var theText=document.createTextNode(ctxChild[j].firstChild.data);
                                        newCell.appendChild(theText);
                                    }
                                }
                            }
                         turnOffProgress();
                     }
				}
			}
	}
    
  	function updateTitleWindow(title){
  		document.getElementById("contextTitleHeader").innerHTML = title;
  	}
  	
  	// RBR2: FUN[080973] Modified this, to address the unique Context quering
     function LoadAssignments(ctx){
    	  xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","select=person&response=v_id,member&source=Context&ctxID="+ctx,formatResponseAssignments,0);
     }
  
     function doneClose(){
         top.document.getElementById("layerOverlay").style.display ="none";
		 top.closeSlideInDialog();
	 }

 </script>
</head>
<body class="slide-in-panel" onload="javascript:LoadAssignments('<%=ctxName%>');turnOnProgress()">
    <div id="pageHeadDiv">
        <table>
            <tbody>
                <tr>
                    <td class="page-title">
                         <h2 id="contextTitleHeader"><%=ctxTitle%></h2>
                     </td>
                </tr>
                <tr>
                     <td class="functions">
                         <table>
                             <tbody>
                                 <tr>
                                    <td class="progress-indicator">
                                        <div id="imgProgressDiv" style="visibility: hidden;"></div>
                                    </td>
                                </tr>
                             </tbody>
                         </table>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <div id="divPageBody">
        <table border="1px" id="tabRes" style=" overflow:scroll; height: 20px ;  border-color: white" width="100%">
            <tbody>
                <tr id="Header" style=" width: 100%" >
                    <td class="MatrixLabel"><%=getNLS("Person")%></td>
                </tr>
            </tbody>
        </table>
    </div>
      
    <div id="divPageFoot">
        <script>addFooter("javascript:doneClose()", "images/buttonDialogDone.gif", '<%=getNLS("Done")%>','<%=getNLS("Done")%>');</script>
    </div>
</body>
</html>
