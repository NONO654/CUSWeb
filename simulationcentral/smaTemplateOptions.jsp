<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template,
                java.util.Map, com.matrixone.apps.domain.util.MapList,
                com.dassault_systemes.smaslm.matrix.common.SimulationConstants,
                com.dassault_systemes.smaslm.matrix.server.SlmUtil,
                matrix.util.StringList,
                com.dassault_systemes.smaslm.matrix.common.AccessUtil,
                com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<html>
    <head>
      <meta charset="utf-8" />
    </head>
    <body style="height:100%;width:100%;">
    
<%
        String drm = emxGetParameter(request, "drm"),
            drms = drm.replace("\"","$$$"),     
            objectAction = emxGetParameter(request, "objectAction"),
            objectID = emxGetParameter(request, "objectID"),
            url = "",
            sError = "",
            contentStr1 = null, 
            simId = null;

        String parentId = emxGetParameter(request, "parentOID");
        boolean isSimulationTemplate = false, 
            isTemplateView = false;
        
        session.setAttribute("drms", drms);
        
        //start
        final String TITLE = SimulationUtil.getSelectAttributeTitleString();

        Template template = new Template(objectID);
        StringList templateSelects = new StringList(new String[] {SimulationConstants.PHYSICAL_ID, TITLE});     
        Map templateInfo = template.getInfo(context, templateSelects);
        String templateId = (String)(templateInfo.get(SimulationConstants.PHYSICAL_ID)),
            templateTitle = (String)(templateInfo.get(TITLE)),
            templateViewId = null;
          
        MapList mapList = template.getContentAndViewInfo(context);
        
        for (int i = 0; i < mapList.size(); i++) 
        {
            Map map = (Map) mapList.get(i);
            String relationshipName = (String) map.get("relationship");
            if (SimulationConstants.RELATIONSHIP_SIMULATION_TEMPLATE_CONTENT.equals(relationshipName))
            {
                isSimulationTemplate = Boolean.valueOf((String)map.get(SimulationConstants.SELECT_IS_KIND_OF_SIMULATION));
                simId = (String) map.get(SimulationConstants.SELECT_PHYSICAL_ID);
            } else if (SimulationConstants.RELATIONSHIP_SIMULATION_TEMPLATE_VIEW.equals(relationshipName)) {
                isTemplateView = true;
                templateViewId = (String) map.get(SimulationConstants.SELECT_PHYSICAL_ID);
            }
        }
        //end
        
        StringBuffer urlBuffer = new StringBuffer();
        if("Instantiate".equals(objectAction) || "HomePageInstantiate".equals(objectAction) || 
                  "InstantiateGlobalSearch".equals(objectAction) || "InstantiateLite".equals(objectAction) || "ReqCentralInstantiate".equals(objectAction))
        {
            if (isSimulationTemplate && isTemplateView) {
                if (AccessUtil.canCopyOrRevise(context, objectID) == false)
                {
                    emxNavErrorObject.addMessage(UINavigatorUtil.getI18nString(
                        "Error.Template.Instantiate.NoAccessRef",
                        "smaSimulationCentralStringResource",
                        context.getSession().getLanguage()));
                    String errorMsg = emxNavErrorObject.toString().trim(),
                    message = MessageServices.massageMessage(errorMsg);
    %>
                    <script>
                    alert("<%=message%>");
                    getTopWindow().closeWindow();
                    </script>
    <%                       
                }
                else
                {
                    url = "../webapps/SMAProcXSUI/xs-app-instantiator/xs-app-instantiator.html?templateId="+templateId+"&templateTitle="+templateTitle+"&parentOID="+parentId;
	%>
                    <script>
                         if ("InstantiateGlobalSearch" === ("<%=objectAction%>") || 
                         		"InstantiateLite" === ("<%=objectAction%>") || 
                         		"InstantiateRunLite" === ("<%=objectAction%>") || 
                         		"InstantiateRunGlobalSearch" === ("<%=objectAction%>")) {
                      	   
                         	getTopWindow().location.href = "<%=url.toString()%>";
                         }
                         else {
                         	getTopWindow().showModalDialog("<%=url.toString()%>");
                         	
                         	}
					</script>
    <%
                                    
                }
            } 
            else {
                      
                urlBuffer.append("../simulationcentral/smaInstantiateTemplate.jsp?")
                .append("objectId=").append(objectID)
                .append("&parentOID="+parentId)
                .append("&showApply=true");
                
                if ("Instantiate".equals(objectAction) || "HomePageInstantiate".equals(objectAction) || "ReqCentralInstantiate".equals(objectAction))
                {
                    urlBuffer.append("&mode=Instantiate")
                    .append("&HelpMarker=SMATemplate_ListInstantiate");
                } 
                else if ("InstantiateGlobalSearch".equals(objectAction) || "InstantiateLite".equals(objectAction))
                {
                    urlBuffer.append("&mode=InstantiateLite")
                    .append("&HelpMarker=SMATemplate_ListInstantiateRunLite");
                }
            }
        }
        else if("HomePageInstantiateRun".equals(objectAction) || "InstantiateRun".equals(objectAction) ||
            "InstantiateRunLite".equals(objectAction) || "InstantiateRunGlobalSearch".equals(objectAction))
        {
            if(isSimulationTemplate && isTemplateView){
                emxNavErrorObject.addMessage(UINavigatorUtil.getI18nString(
                    "smaSimulationCentral.Template.InstantiateRun.Customview",
                    "smaSimulationCentralStringResource",
                    context.getSession().getLanguage()));
                String errorMsg = emxNavErrorObject.toString().trim(),
                message = MessageServices.massageMessage(errorMsg);
%>
                <script>
                alert("<%=message%>");
                getTopWindow().closeWindow();
                </script>
<%   
            }
            else{

                urlBuffer.append("../simulationcentral/smaInstantiateTemplate.jsp?")
                .append("&objectId=").append(objectID);
                
                if("HomePageInstantiateRun".equals(objectAction) || "InstantiateRun".equals(objectAction)){

                        urlBuffer.append("&mode=InstantiateRun")
                        .append("&HelpMarker=SMATemplate_ListInstantiateRun");
                }
                else if("InstantiateRunLite".equals(objectAction) || "InstantiateRunGlobalSearch".equals(objectAction)){

                        urlBuffer.append("&mode=InstantiateRunLite")
                        .append("&HelpMarker=SMATemplate_ListInstantiateRunLite");
                }
            }
        }
        else
        {
            urlBuffer.append("../common/emxTable.jsp?")
                   .append("&table=SMATemplate_Options")
                   .append("&customize=false")
                   .append("&header=Template.Options.PageHeading")
                   .append("&toolbar=SMATemplate_OptionsViewToolbar")
                   .append("&selection=none")
                   .append("&HelpMarker=SMATemplate_NavTreeOptions")
                   .append("&Export=false")
                   .append("&PrinterFriendly=true")
                   .append("&program=jpo.simulation.Template:getOptions")
                   .append("&disableSorting=true")
                   .append("&multiColumnSort=false")
                   .append("&headerRepeat=0")
                   .append("&objectBased=false")
                   .append("&pagination=0")
                   .append("&massUpdate=false")
                   .append("&suiteKey=SimulationCentral")
                   .append("&SuiteDirectory=simulationcentral")
                   .append("&objectId=").append(objectID);
        }
        
        url = urlBuffer.toString();
        if(objectAction==null)
        {
%>
    <form style="display: hidden"  action="<%=url%>" method="POST" id="form2">
       <input type="hidden" id="drms" name="drms" value="<%=drms%>"/>
    </form>
    <script language="javascript">
        objForm = document.forms["form2"];
        objForm.submit();
     </script>
    
<%
        }else
        {
         if ("InstantiateGlobalSearch".equals(objectAction) || "InstantiateLite".equals(objectAction) || "InstantiateRunLite".equals(objectAction) || "InstantiateRunGlobalSearch".equals(objectAction))
            
             {
             %>
             <script>
             
             if("<%=urlBuffer.toString()%>".length !== 0) {
            	 var contentframe = findFrame(getTopWindow(),"content");
                 contentframe.location.href = "<%=urlBuffer.toString()%>";
             }
             </script>
            <%
             }else
             {
                 %>
                 <script>
                 
                 if("<%=urlBuffer.toString()%>" .length !== 0) {
                	 getTopWindow().window.open("<%=urlBuffer.toString()%>","newwindow","status=1,scrollbars=1,resizable=1,width=600,height=700");  
                 }

                 </script>
                 <%   
             }          
        }
%>            
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>
