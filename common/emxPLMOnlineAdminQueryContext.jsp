<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<%
    String NLSMessage = getNLSMessageWithParameter("ERR_ThereIsNoMatchingThisCriteria", "SecurityContexts");
    String ctxFilter = emxGetParameter(request,"PLM_ExternalID");
    // TItle
    String ctxFilterTitle = emxGetParameter(request,"V_Name");
    String CTXName = getNLS("Name");
  	//SSI21 TITLE
    String CTXTitleNLS = getNLS("Title");			
    String CTXDesc = getNLS("Description");
    String CTXAssign = getNLS("Assignees");
    String show = getNLS("Show");
%><html>
    <head>
        <script>
             var xmlreqs = new Array();

             function formatResponse()
             {
                xmlhttpRole = xmlreqs[0];
                xmlhttpRole.onreadystatechange=function()
                {
                    if(xmlhttpRole.readyState==4){
                        var ctxName = xmlhttpRole.responseXML.getElementsByTagName("Context");
                        
                        var tableResultat = document.getElementById("tableRes");
                        if(ctxName.length == 0){
                            document.getElementById("loadingMessage").style.display="none";
                            document.getElementById("ErrorMessage").innerHTML = "<%=NLSMessage%>";
                        }else{
                            for (var i = 0 ; i < ctxName.length ; i++){
                                var ctxDesc="";
                                var ctxChild="";

                                var ctx = ctxName[i].getElementsByTagName("PLM_ExternalID")[0].firstChild.data;
                                //SSI21 tITLE
                                var ctxTitle = "";
                                if(ctxName[i].getElementsByTagName("V_Name")[0].firstChild != null)
                                	{
                                	ctxTitle = ctxName[i].getElementsByTagName("V_Name")[0].firstChild.data;
                                	}
                                
                                
                                if (ctxName[i].getElementsByTagName("v_id")[0].firstChild != null){ ctxDesc =ctxName[i].getElementsByTagName("v_id")[0].firstChild.data;}
                                if (ctxName[i].getElementsByTagName("member") != null){ ctxChild =ctxName[i].getElementsByTagName("member");}

                                var row=tableResultat.insertRow(-1);
                                var newCell = addCellInARow(row, "MatrixFeel", 0);
                                // RBR2:FUN[080973] Title Node holder + Adding ID -- Name of Context
                                newCell.id = encodeURIComponent(ctx);
								newCell.appendChild(document.createTextNode(ctxTitle));  	//SSI21 Title
								newCell = addCellInARow(row,"MatrixFeel",1);
								newCell.appendChild(document.createTextNode(ctx));
                                newCell = addCellInARow(row, "MatrixFeel", 2);
								newCell.appendChild(document.createTextNode(ctxDesc));
 
                                if(ctxChild.length>0){
                                    if(ctxChild.length == 1 )
                                    {
										newCell = addCellInARow(row, "MatrixFeel", 3);						//cHANGED index
										newCell.appendChild(document.createTextNode(ctxChild[0].firstChild.data));
                                    }
									else{
                                    var newCell = addCellInARow(row, "MatrixFeel", 3);						//cHANGED index
                                    var myselect = document.createElement("select");
                                    for (var j = 0 ; j < ctxChild.length ; j++){
                                        var nouvel_element = document.createElement("option");
                                        var theText=document.createTextNode(ctxChild[j].firstChild.data);
                                        nouvel_element.appendChild(theText);
                                        myselect.appendChild(nouvel_element);
                                    }
                                    newCell.appendChild(myselect);
                                    }
                                }else{
									var inhtml = "<%=show%> <%=CTXAssign%> <img src='images/utilProcessStepArrow.gif' style='cursor:pointer' title='<%=CTXAssign%>' onclick=javascript:editSecurityContext('"+encodeURIComponent(ctx)+"')>";
                                   addCellInARow(row, "MatrixFeel", 3, inhtml);
                                }
                            }
                            HideLoading();
                        }
                    }
                }
            }

            function editSecurityContext(ctx){
            	// RBR2: FUN[080973] Added this to not perform additional DB query for available info.
            	var ctxTitle = document.getElementById(ctx).innerText; // Already URI encoded .
            	top.showSlideInDialog("emxPLMOnlineAdminSecurityContextAssignment.jsp?ctxName="+ctx+"&ctxTitle="+ctxTitle, true);
            }

            function initQueryContext(Filter){
                xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","response=v_id&source=Context&ctxFilter="+Filter,formatResponse,0);
            }
        </script>
    </head>
    <body onload='javascript:initQueryContext("<%=ctxFilterTitle%>")'> <!-- TITLE RBR2 -->
        <div class="divPageBodyVPLMNoFooter">
            <table   width="100%" style="height:10% ; border-color: white" border="1px" id="tableRes">
                <tr bgcolor="#b0b2c3" >
                	<!-- //SSI21 TITLE -->
                	<td class="MatrixLabel"><%=CTXTitleNLS%></td>										
                    <td class="MatrixLabel"><%=CTXName%></td>
                    <td class="MatrixLabel"><%=CTXDesc%></td>
                    <td class="MatrixLabel"><%=CTXAssign%></td>
                </tr>
            </table>
            <div   style=" height: 50%; " id="loading">
                <table width="100%" style="height : 100%" >
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
