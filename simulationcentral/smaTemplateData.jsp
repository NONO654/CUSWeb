<%-- (c) Dassault Systemes, 2010 --%>
<%--
  trying to display on the link on the RHS
--%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template,
                java.util.Map, com.matrixone.apps.domain.util.MapList,
                com.dassault_systemes.smaslm.matrix.common.SimulationConstants,
                com.dassault_systemes.smaslm.matrix.server.SlmUtil,
                matrix.util.StringList"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>


<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>

<%@page import="org.w3c.dom.Document"%>
<%@page import="org.w3c.dom.Element"%>
<%@page import="com.dassault_systemes.smaslm.common.util.W3CUtil"%>

<%@page import="matrix.db.JPO"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script type="text/javascript"  src="./smaAdviseLaunchHelper.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<html>
    <head>
      <meta charset="utf-8" />
    </head>
    <body style="height:100%;width:100%;">
    
<%
    String objectID = emxGetParameter(request, "objectId"),
        parentId  = emxGetParameter(request, "parentOID"),
        locale = context.getSession().getLanguage(),
        sError = "",
        objectAction = emxGetParameter(request, "objectAction"),
        cosError = SimulationUtil.getI18NString(context,"Error.Station.COSError"),
        reqError = SimulationUtil.getI18NString(context,"Error.Station.COSRequestError"),              
        emxTableRowId = "", 
        simId = null;
    
    String[] sRowIds;
    final String TITLE =  SimulationUtil.getSelectAttributeTitleString();
    final String Children ="/template/Connector";
    int flag=0;
    String isTask="false";
    boolean isSimulationTemplate = false, isTemplateView = false;
    if("ReqCentralInstantiate".equals(objectAction))
    {
        isTask="true";
    }
    
    if("HomePageInstantiate".equals(objectAction) || "InstantiateLite".equals(objectAction) || "InstantiateGlobalSearch".equals(objectAction) || "HomePageInstantiateRun".equals(objectAction) || "InstantiateRunLite".equals(objectAction) ||"InstantiateRunGlobalSearch".equals(objectAction) || "ReqCentralInstantiate".equals(objectAction))
    {
        sRowIds = emxGetParameterValues(request, "emxTableRowId");
        StringList ids = FrameworkUtil.split(sRowIds[0], "|");
        objectID = (String)ids.get(0);
        parentId = (String)ids.get(1);
    }
    Template template = new Template(objectID);
    String Template_Def=template.getAttributeValue(context,SimulationConstants.ATTRIBUTE_DEFINITION);
    //Warning message in case of Blank template
    if("".equals(Template_Def))
    {
    	String warningMessage= SimulationUtil.getI18NString(context,"Error.Template.Instantiate.NoContent");
    	%>
    	
    	<script>

    	alert('<%=warningMessage%>');
    	</script> 	
    <% 
    return;	
    }
    Document doc=W3CUtil.loadXml(Template_Def);
    Element element=W3CUtil.findElement(doc,Children);
    if(objectAction!=null)
    {
      if(element!=null && element.getAttribute("id")!=null && element.getAttribute("id")!="")
        {
          flag=1;
          StringBuffer urlBuffer1 = new StringBuffer();
          urlBuffer1.append("../simulationcentral/smaRunExePreProcessing.jsp?")
          .append("&runApplication=ExternalUILaunch")
          .append("&objectId=").append(objectID)
          .append("&HelpMarker=SMATemplate_SimActUILaunch")
          .append("&isTask=").append(isTask);
          %>
          <script>
          var isTask="<%=isTask%>";
          var topWin = getTopWindow();
          if(isTask!=="true")
              {
          if(topWin.opener != null)
          {
            topWin = topWin.opener.getTopWindow();
          }
              }
          var hiddenFrame =findFrame(topWin,"hiddenFrame");
          hiddenFrame.location.href = "<%=urlBuffer1.toString()%>";          
          </script>
          <%
          if ("InstantiateGlobalSearch".equals(objectAction) || "InstantiateLite".equals(objectAction) || "InstantiateRunLite".equals(objectAction) || "InstantiateRunGlobalSearch".equals(objectAction))
          {
              
          %>
          <script>
          getTopWindow().close();
          </script>
          <%
          }
        }
    }  
    String drms = (String)(session.getAttribute("drms"));
     
    if(flag==0)
    {
    if(drms != null)
    {
        String url = "";
        //start
        //Template 
        template = new Template(objectID);
        StringList templateSelects = new StringList(new String[] {SimulationConstants.PHYSICAL_ID, TITLE});     
        Map templateInfo = template.getInfo(context, templateSelects);
        String templateId = (String)(templateInfo.get(SimulationConstants.PHYSICAL_ID)),
            templateTitle = (String)(templateInfo.get(TITLE)),
            templateViewId = null;
          
        String parentPhysicalId = "";
        if (parentId != null && !"".equals(parentId))
        {
            DomainObject doObj = new DomainObject(parentId);
            parentPhysicalId = doObj.getInfo(context, SimulationConstants.PHYSICAL_ID);
        }
		
          
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
                url = "../webapps/SMAProcXSUI/xs-app-instantiator/xs-app-instantiator.html?templateId="+templateId+"&templateTitle="+templateTitle+"&parentOID="+parentPhysicalId;
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
                .append("&showApply=true");
                
                if ("Instantiate".equals(objectAction) || "HomePageInstantiate".equals(objectAction) || "ReqCentralInstantiate".equals(objectAction))
                {
                    urlBuffer.append("&mode=Instantiate")
                    .append("&HelpMarker=SMATemplate_ListInstantiate");
                    if(parentId!= null && !"".equals(parentId))
                        urlBuffer.append("&parentOID="+parentId);
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
                 if(contentframe)
                 {
                 contentframe.location.href = "<%=urlBuffer.toString()%>";
                 }
                 else
                 {
                     getTopWindow().location.href = "<%=urlBuffer.toString()%>";
                 }
              }
             </script>
            <%
             }else
             {
                 %>
                 <script>
                 
                 if("<%=urlBuffer.toString()%>".length !== 0) {
                     getTopWindow().window.open("<%=urlBuffer.toString()%>","newwindow","status=1,scrollbars=1,resizable=1,width=600,height=700"); 
                 }
                 
                  </script>
                 <%   
             }          
        }
    }
    else
    {
        // set content url to point to smaTemplateOptions.jsp.
        // The data is past to the program jpo by using a post 
        // of a form containing the url and an argument set through 
        // jQuery for the drm list xml returned by the web service 
        // call.  
        URLBuilder contentURL = new URLBuilder(request.getRequestURI().length(),request.getCharacterEncoding());
        contentURL.append("../simulationcentral/smaTemplateOptions.jsp?")
        .append("&objectID=").append(objectID)
        .append("&locale=").appendEncoded(context,locale)        
        .append("&objectAction=").append(objectAction)
        .append("&parentOID="+parentId);
        
        StringBuffer eedURL= new StringBuffer();
        try
        {
            //  call a jpo method to get the EED url to use
            // for the drm list COS web service call
            HashMap<String,String> eedInfo = (HashMap<String,String>)JPO.invoke(context, 
               "jpo.simulation.SimulationHost", null, 
               "getEEDData", null, HashMap.class);
            
            eedURL.append(eedInfo.get("eedURL")).append("/admin/drm");
        }
        catch(Exception e)
        {
            //Missing SMAExeConfiguration.properties file
            eedURL.append("/admin/drm");
        }
        // use java script to define the form holding the content url
        // so the drm list can be past as a POST method since it
        // may be to long to pass in a GET method by setting the href
        
        // also make the web service call to get the drm data in the
        // java script so it runs on the client not the server
%>
        
        <form style="display: hidden" action="<%=contentURL.toString()%>" method="POST" id="form1">
          <input type="hidden" id="drm" name="drm" value=""/>
        </form>
        
        <script language="javascript">
        
           var dataStr = "";
           var eedURL1 =  "<%=eedURL.toString()%>";
            jQuery.ajax({ 
                url : eedURL1,
                type : "GET",
                cache:false,
                success : function(returndata, status, xhr) {
                dataStr = (new XMLSerializer()).serializeToString(returndata.documentElement);
                $("#drm").val(dataStr);
                $("#form1").submit();
                },
                error : function(jqXHR, textStatus, errorThrown) 
                {
                 $("#drm").val("");
                 $("#form1").submit();
                }
            });
        
            </script>
<%
    }
    }
%>
        
    </body>
</html>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>




