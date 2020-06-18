<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%
    String NLSMessage = getNLSMessageWithParameter("ERR_ThereIsNoMatchingThisCriteria", "Role");
    Map Attributes = getAttributes(mainContext,"Role","");
    StringList AttributesToShow = (StringList)Attributes.get("ListAttributes");
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            var xmlreqs = new Array();
            
        
         function formatResponse()
            {
                var xmlhttpRole = xmlreqs[0];
                xmlhttpRole.onreadystatechange=function()
                {
                    if(xmlhttpRole.readyState==4)
                    {
                         var projectName = xmlhttpRole.responseXML.getElementsByTagName("Role");
                        var tableResultat = document.getElementById("tableRes");
                        var tableHeader = document.getElementById("Header");
                        if(projectName.length == 0){
                             document.getElementById("loadingMessage").style.display="none";
                            document.getElementById("ErrorMessage").innerHTML = "<%=NLSMessage%>";
                        }else{
                            for (var i = 0 ; i < projectName.length ; i++){
                                var row=tableResultat.insertRow(-1);
                                //Adding the First Cell
								// ALU4 2017:09:14 IR-534399-3DEXPERIENCER2018x - Roles with hyphen is not displayed correctly
                                // var project = projectName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                                var project = projectName[i].getElementsByTagName("PLM_ExternalID")[0];
                                var projectChild = projectName[i].getElementsByTagName("child");
                                var child ="";

								var projectChildNodes = project.childNodes ;
								// Determine project name 	
								var projectRes = "";
								for (var j = 0; j < projectChildNodes.length; j++)
								{
									projectRes = projectRes + projectChildNodes[j].data ;
								}
								
                                for (var k = 0 ; k < projectChild.length ; k++){
									 // ALU4 2017:09:14 IR-534399-3DEXPERIENCER2018x - Roles with hyphen is not displayed correctly
                                     // child = child +","+ projectChild[k].firstChild.data;
										var tempChildNodes = projectChild[k].childNodes ;
										var tempProjectChild = "";
										for(var l = 0; l < tempChildNodes.length; l++)
										{
											tempProjectChild = tempProjectChild + tempChildNodes[l].data
										}
									  child = child +","+ tempProjectChild;
                                }

                                var newCell = addCellInARow(row, "MatrixFeel", 0);
								// newCell.appendChild(document.createTextNode(project));
								newCell.appendChild(document.createTextNode(projectRes));

                                for (var j = 1 ; j < tableHeader.cells.length ; j++){
                                    var cellNameToAdd = tableHeader.cells[j].id;
                                    var projectAttribute= "" ;
                                    if ( (projectName[i].getElementsByTagName(cellNameToAdd).length > 1  ) ){
                                         var newCell = addCellInARow(row, "MatrixFeel", j);
                                         var myselect = document.createElement("select");

                                         for (var k = 0 ; k < (projectName[i].getElementsByTagName(cellNameToAdd)).length ; k++){
                                            var nouvel_element = document.createElement("option");
											// ALU4 2017:09:14 IR-534399-3DEXPERIENCER2018x - Roles with hyphen is not displayed correctly 
                                            // var theText=document.createTextNode(projectName[i].getElementsByTagName(cellNameToAdd)[k].firstChild.data);
											var projectNameChildNodes = projectName[i].getElementsByTagName(cellNameToAdd)[k].childNodes; 
											var projectNameRes = "";
											for(var l = 0; l < projectNameChildNodes.length; l++)
											{
												projectNameRes = projectNameRes + projectNameChildNodes[l].data;
											}
                                            var theText=document.createTextNode(projectNameRes);
											
                                            nouvel_element.appendChild(theText);
                                            myselect.appendChild(nouvel_element);
                                        }
                                        newCell.appendChild(myselect);
                                    }else{
                                        if ( (projectName[i].getElementsByTagName(cellNameToAdd).length == 1  ) && projectName[i].getElementsByTagName(cellNameToAdd)[0].firstChild != null){
											// ALU4 2017:09:14 IR-534399-3DEXPERIENCER2018x - Roles with hyphen is not displayed correctly 
                                            // projectAttribute =projectName[i].getElementsByTagName(cellNameToAdd)[0].firstChild.data;
											var projectAttributeChildNodes = projectName[i].getElementsByTagName(cellNameToAdd)[0].childNodes;
											for (var l = 0; l < projectAttributeChildNodes.length ; l++)
											{
												projectAttribute = projectAttribute + projectAttributeChildNodes[l].data;
											}
                                        }
                                        newCell = addCellInARow(row, "MatrixFeel", j);
										newCell.appendChild(document.createTextNode(projectAttribute));
                                    }
                                }
                            }
                         HideLoading();
                      }
                }
                }
            }


        </script>
    </head>
    <%String filterRole = emxGetParameter(request,"PLM_ExternalID");%>
    <body onload="javascript:initAjaxCall('Role','VPM','XP','Query','<%=filterRole%>',formatResponse,0)">
        <div class="divPageBodyVPLMNoFooter">
            <table id="tableRes" width="100%" style="height:10% ;border-color: white" border="1px">
                <tr id="Header" width="100%" style="overflow : auto">
                    <%
                        for (int i = 0 ; i < AttributesToShow.size() ; i++) {
                            String NLSName = (String)Attributes.get(AttributesToShow.get(i));
                    %>
                    <td class="MatrixLabel" id="<%=AttributesToShow.get(i)%>"><%=NLSName%></td>
                       <%}%>
                 </tr>
            </table>
            <div   style=" height: 50%; " id="loading">
                <table width="100%" style="height : 100%">
                    <tr valign="middle" align="middle" style=" height: 100%">
                        <td   id="loadingMessage">
                            <img src="images/iconParamProgress.gif">
                        </td>
                        <td style=" color: #990000 ; font-size: 12pt ; font-style: italic ; font-weight: bold " id="ErrorMessage">

                        </td>
                    </tr>
                 </table>
            </div>
        </div>
    </body>
</html>
