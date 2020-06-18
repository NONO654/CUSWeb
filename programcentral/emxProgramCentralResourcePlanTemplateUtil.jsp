<%--
  emxProgramCentralResourcePlanTemplateUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.framework.ui.UITableCommon"%>
<%@page import="matrix.util.*"%>
<%@page import="com.matrixone.apps.domain.util.PolicyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="matrix.db.MQLCommand"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.program.ResourcePlanTemplate"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%><jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<script language="javascript" src="../common/emxJSValidation.jsp"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="javascript" type="text/javascript" src="emxProgramUtil.js"></script>

<%
            boolean bFlag = false;
            try
            {
                String languageStr = context.getSession().getLanguage();
                String strMode = emxGetParameter(request, "FunctionMode");
                String projectTemplateId = emxGetParameter(request, "objectId");
                String strReturnResult = "";
                StringBuffer sBuff = new StringBuffer();
                String [] strObjectIds = emxGetParameterValues(request,"objectId");
                //String strObjectId = emxGetParameter(request,"objectId");
                String strObjectId = strObjectIds[0];

                if (("create").equals(strMode))
                {
                    String strName = emxGetParameter(request,"Name");
                    String strDescription = emxGetParameter(request,"Description");
                    strDescription = FrameworkUtil.findAndReplace(strDescription,"<","&lt;");
                    strDescription = FrameworkUtil.findAndReplace(strDescription,">","&gt;");
                    ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
                    resourcePlanTemplate.createResourcePlanTemplate(context,strObjectId,strName,strDescription);
                    //durationKeywordsUtil.createDurationKeywords(context, strObjectId, durationKeyword);
%>
                        <script language="javascript" type="text/javaScript">
                        getTopWindow().window.getWindowOpener().location.href =  getTopWindow().window.getWindowOpener().location.href; //To refresh the background SB
                        </script>
<%
                }//Added:4-Jun-2010:di1:R210 PRG:Advanced Resource Planning
                else if (("delete").equals(strMode))
                {
                	 String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
                	 StringList strIds = null;
                	 String strRelId = null;
                	 ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
                     for (int i = 0; i < strEmxTableRowIds.length; i++)
                     {
                    	 strIds = FrameworkUtil.split(strEmxTableRowIds[i],"|");
                    	 strRelId = (String)strIds.get(0);
                    	 resourcePlanTemplate.deleteResourcePlanTemplate(context,strObjectId,strRelId);
                     }



                    %>
                    <script language="javascript" type="text/javaScript">
	                    var topFrame = findFrame(getTopWindow(), "PMCResourcePlanTemplateSummaryTable");	
	        	 		if (topFrame != null) {
	        	 			topFrame.location.href = topFrame.location.href;                        
	        	        }else{
	        	        	parent.location.href = parent.location.href;
	        	        }
                    </script>
<%
                }else if (("deleteResourceRequest").equals(strMode))
                {
                    String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
                    StringList strIds = null;
                    String strResourceReqId = null;
                    ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
                    for (int i = 0; i < strEmxTableRowIds.length; i++)
                    {
                        strIds = FrameworkUtil.split(strEmxTableRowIds[i],"|");
                        strResourceReqId = (String)strIds.get(0);
                        resourcePlanTemplate.deleteResourceRequest(context,strResourceReqId);
                    }
                   %>
                   <script language="javascript" type="text/javaScript">

                   var contentFrame = findFrame(getTopWindow(),"content");
                   contentFrame.location.href = contentFrame.location.href;
                   </script>
<%
               }
                else if (("clone").equals(strMode))
                {
                	String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
                	if(null!=strTableRowIds && strTableRowIds.length!=0)
                	{
                	   StringList slTableRowId  = FrameworkUtil.split(strTableRowIds[0],"|");
                	   String strResourcePlanTemplateId = (String) slTableRowId.get(0);
                	   String strProjectTempalteId = (String) slTableRowId.get(2);

                	   ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
                	   resourcePlanTemplate.cloneResourcePlanTemplate(context,strResourcePlanTemplateId,strProjectTempalteId);
                	}
                    //durationKeywordsUtil.createDurationKeywords(context, strObjectId, durationKeyword);
%>
                        <script language="javascript" type="text/javaScript">
                        getTopWindow().window.getWindowOpener().location.href =  getTopWindow().window.getWindowOpener().location.href; //To refresh the background SB
                        </script>
<%
                }
                else
                {
                    throw new IllegalArgumentException(strMode);
                }
            }
            catch (Exception e)
            {
                bFlag = true;
                e.printStackTrace();
                session.putValue("error.message", e.getMessage());
            }

%>
<script language="javascript" type="text/javaScript">getTopWindow().closeWindow();</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
