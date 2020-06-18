<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosDisciplineServices" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%--
    Document   : emxPLMOnlineAdminQueryProject.jsp
    Author     : LXM
    Modified :  19/10/2010 -> New UI
                22/03/2011 -> Added Ajax & Project Rules in file
--%>
<%
    // String plmid = emxGetParameter(request,"Param1");
	// String plmidEscaped = EncodeUtil.escape(title);
    String title = emxGetParameter(request,"Param1"); // This will be Title now
    String titleEscaped = EncodeUtil.escape(title);  // RBR2: This might not be required
    String source = emxGetParameter(request,"Param2");
    String plmID = emxGetParameter(request,"Param3"); // CASE 2 P mode. TODO: Remove if not required.

    String iDestination ="XP";
    String iSolution ="";
	String filter = getNLS("Filter");

    if (source.equals("Project")){ 
    	//CSE mode
        iSolution="VPLM";
        iDestination = "VPLMAdmin";
    }
	
    if (source.equals("XPProject") && plmID != null && !plmID.trim().isEmpty()){ 
    	// RBR2: Added this to support XP mode CASE 2 [Refer doc]
    	// TODO: Check whether  title is * and plmid is valid then perform name based search 
    	plmID = EncodeUtil.escape(plmID); // This can be used to initialize the below page
    }
    
    String NLSMessage = getNLSMessageWithParameter("ERR_ThereIsNoMatchingThisCriteria", "Project"); // TODO : What is this ERROR message
    Map Attributes =  getAttributes(mainContext ,"Project", iSolution); //RBR2: This will return the Required attributes
    StringList AttributesToShow = (StringList)Attributes.get("ListAttributes");
%>
<html>
    <head>
       <script>
            var xmlreqs = new Array();
            var xmlhttpProject = "";

            function computeChildNodesData(childNodes)
            {
                var data = ""
                for (var k = 0; k < childNodes.length; k++)
                {
                    data = data + childNodes[k].data;
                }
                return data;
            }
          
            function formatResponse()
            {
                xmlhttpProject = xmlreqs[0];
                xmlhttpProject.onreadystatechange=function()
                {
                    if(xmlhttpProject.readyState==4)
                    {
                    	var projectName = xmlhttpProject.responseXML.getElementsByTagName("Project");
                        var tableResultat = document.getElementById("tableRes");
                        var tableHeader = document.getElementById("Header");
                        if(projectName.length == 0){
                            document.getElementById("loadingMessage").style.display="none";
                            document.getElementById("ErrorMessage").innerHTML = "<%=NLSMessage%>";
                        }else{
                            for (var i = 0 ; i < projectName.length ; i++){
                                var row=tableResultat.insertRow(-1);
                                //Adding the First Cell
                                // JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                                //var project = projectName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                                var childNodes = projectName[i].getElementsByTagName("PLM_ExternalID")[0].childNodes;
                                var project = ""
                                for (var k = 0; k < childNodes.length; k++)
                                {
                                    project = project + childNodes[k].data;
                                }
								var source = "<%=source%>";
								var cellInnerHTML = document.createElement("a");
								if(source=="XPProject"){
									cellInnerHTML.setAttribute("href","emxPLMOnlineAdminXPProject.jsp?PLM_ExternalID="+encodeURIComponent(project)+"&source="+encodeURIComponent(source));
								}else{
									cellInnerHTML.setAttribute("href","emxPLMOnlineAdminProjectSubTree.jsp?PLM_ExternalID="+encodeURIComponent(project));
								}
								
								
								// Title
								var childNodesTitle = projectName[i].getElementsByTagName("V_Name")[0].childNodes;
								var projectTitle = computeChildNodesData(childNodesTitle);
                               	var copyAnchorForTitle  = cellInnerHTML.cloneNode(true);
                               	copyAnchorForTitle.appendChild(document.createTextNode(projectTitle));
                               	var cellTitle = addCellInARow(row, "MatrixFeel", 0); // new cell
                               	cellTitle.appendChild(copyAnchorForTitle);
								
								// PLM_ExternaliD
								cellInnerHTML.appendChild(document.createTextNode(project));
                                var newCell = addCellInARow(row, "MatrixFeel", 1);
								newCell.appendChild(cellInnerHTML);
								
                                for (var j = 2 ; j < tableHeader.cells.length ; j++){ // RBR2: Move to 2 index
                                    var cellNameToAdd = tableHeader.cells[j].id;
                                    var projectAttribute= "" ;
                                    //RBR2: Fetch parent or childrens Title to serve rendering
                                    if(cellNameToAdd === "project_Parent"){
                                    	cellNameToAdd = "Project_Parent_V_Name";
                                    } else if (cellNameToAdd === "child") {
                                    	cellNameToAdd = "Project_Child_V_Name";
                                    }
                                    
                                    if ( (projectName[i].getElementsByTagName(cellNameToAdd).length > 1  ) ){
                                    	// This is for multi value data
                                         var newCell = addCellInARow(row, "MatrixFeel", j);
                                         var myselect = document.createElement("select");

                                         for (var k = 0 ; k < (projectName[i].getElementsByTagName(cellNameToAdd)).length ; k++){
                                            var nouvel_element = document.createElement("option");
                                            // JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                                            //var theText=document.createTextNode(projectName[i].getElementsByTagName(cellNameToAdd)[k].firstChild.data);
                                            var theText=document.createTextNode(computeChildNodesData(projectName[i].getElementsByTagName(cellNameToAdd)[k].childNodes));
                                            nouvel_element.appendChild(theText);
                                            myselect.appendChild(nouvel_element);
                                        }
                                        newCell.appendChild(myselect);
                                    }else{
                                        if ( (projectName[i].getElementsByTagName(cellNameToAdd).length == 1  ) && projectName[i].getElementsByTagName(cellNameToAdd)[0].firstChild != null){
                                            // JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                                            //projectAttribute =projectName[i].getElementsByTagName(cellNameToAdd)[0].firstChild.data;
                                            projectAttribute=computeChildNodesData(projectName[i].getElementsByTagName(cellNameToAdd)[0].childNodes);
                                        }
                                        var newCell = addCellInARow(row, "MatrixFeel", j);
										newCell.appendChild(document.createTextNode(projectAttribute));
										// RBR2: Pending 
										// When Parent and Child column has entries show the Title and name will be tooltip
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
         <body onload="javascript:initAjaxCall('Project','VPM','<%=iDestination%>','Query','<%=titleEscaped%>',formatResponse,0)">
        <div class="divPageBodyVPLMNoFooter">
            <table style="height:10% ; border-color: white" border="1px" id="tableRes" width="100%"  >
            <%if (source.equals("Project")){%>
            <%}%>
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
