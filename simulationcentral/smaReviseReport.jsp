<%-- 
 © Dassault Systemes, 2007, 2008
--%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%

final String locale = request.getLocale().getLanguage();
String header=SimulationUtil.getI18NString(context,"smaSimulationCentral.Label.MassRevisionReport");
String totalCount= request.getParameter("totalCount");
String noObjPassed =request.getParameter("noObjPassed");
int noObjFailed=2;

String errorMessage= Integer.parseInt(noObjPassed)  + " " 
                     + EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Common.MassPromote.Of")
                     + " "+Integer.parseInt(totalCount) + " "
                     + EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Common.MassPromote.SuccessObjects")
                     + " " + (Integer.parseInt(totalCount)-Integer.parseInt(noObjPassed)) + " "
                     + EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Common.MassPromote.FailedObjects");

String href = "../common/emxTable.jsp?table=SMARevise_Report&program=jpo.simulation.SimulationUI:getReviseError&header="
              +errorMessage+"&selection=none&CancelButton=true&CancelLabel=smaSimulationCentral.Button.Close"
              +"&suiteKey=SimulationCentral&autoFilter=false&showClipboard=false&showRMB=false&multiColumnSort=false&customize=false"
              +"&jpoAppServerParamList=session:objectList";
%>
<body>
<h3><%=header %></h3>

<iframe id="smaReviseReport" src="<%=href%>" height="90%"  width="100%"  frameborder="0"></iframe>

</body>
