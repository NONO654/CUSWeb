<%-- (c) Dassault Systemes, 2008 --%>
<%--
  Process various SLM commands on the SLM Home page.
--%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%

    String objectAction = emxGetParameter(request, "objectAction");
    String oid = emxGetParameter(request, "physicalId");
    if( objectAction.equals("EntryInPerformanceStudy")){
                final String TYPE_SIMULATIONJOB =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_SimulationJob);
                final String TYPE_SIMULATION = SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_Simulation);
                
                if(oid != null) {
                    DomainObject doObj = new DomainObject(oid);
                    if(doObj.isKindOf(context,TYPE_SIMULATIONJOB))
                    {
                        oid = doObj.getInfo(context, "relationship[Simulation Job].from.physicalid");
                    }else if(doObj.isKindOf(context,TYPE_SIMULATION)){
                        oid = doObj.getInfo(context, "physicalid");
                    }
                }
                String argsDi[] = null;
                boolean isLicenced =SimulationContentUtil.isDiscoverUser(context, argsDi);
                if(!isLicenced){
                  return;
                }

                %>
                <script>
                var topFrm = getTopWindow();
                var frame = findFrame(getTopWindow(),'content');
                if (frame == null || frame == undefined)
                    {
                    topFrm = getTopWindow().getWindowOpener().getTopWindow();
                    frame = findFrame(topFrm,"content");
                    }
                topFrm.currentApp = "SIMDISB_AP";
                var appsMenuList = new Array();
                appsMenuList[0] = 'SMAScenario_Definition_New';
                topFrm.changeProduct('SIMULIA', 'Performance Study', 'SIMDISB_AP', appsMenuList, 'SIMDISB_AP', null); 
                topFrm.showMyDesk();
                var openURL = topFrm.openURL;
                if(typeof openURL != 'string'){
                     openURL = openURL ? openURL.value : null;
                }
                var objId = "<%=oid%>";
                if(objId == "null")
                    frame.location.href = openURL ? openURL : "../webapps/SMAProcPSUI/ps-app/ps-app.html";
                else
                    frame.location.href = openURL ? openURL : "../webapps/SMAProcPSUI/ps-app/ps-app.html?physicalId="+"<%=oid%>";

                
                </script>
                <%
                return;
            }
%>



