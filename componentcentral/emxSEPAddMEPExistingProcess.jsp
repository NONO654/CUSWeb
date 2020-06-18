<%--
  emxSEPAddMEPExistingProcess.jsp

 (c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxCPCInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
   boolean isError=false;
try{
   //String timeStamp = emxGetParameter(request, "timeStamp");
   String strObjectId=emxGetParameter(request,"objectId");
   String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
   //HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
   //DebugUtil.debug("requestMap: "+requestMap);
   DebugUtil.debug("Inside the SEP: strObjectId"+strObjectId);
   CPCPart cpcpart=new CPCPart(strObjectId);

   // Fix for IR-162712V6R2013x, IR-162708V6R2013x (Start)
   String[] crossRefIds = null;

  	if(strTableRowIds !=null)
    {
		crossRefIds = new String[strTableRowIds.length];
		for(int ct=0;ct<strTableRowIds.length;ct++)
		{
			DebugUtil.debug("emxSEPAddMEPExistingProcess.jsp: strTableRowIds[ct]==>"+strTableRowIds[ct]);
			StringList rowIdList=FrameworkUtil.split(strTableRowIds[ct],"|");
			// Format: [<selected id>, <parent id>, <unknown>,<unknown>]
			// Example:[30760.40752.152.23177, 30760.40752.17784.49066, 0,0]
			DebugUtil.debug("emxSEPAddMEPExistingProcess.jsp: rowIdList==>"+rowIdList);
			crossRefIds[ct] = (String)rowIdList.get(0); // Get only first element which is cross reference object
		}
		cpcpart.addMEPtoSEP(context,crossRefIds);
	}
	// Fix for IR-162712V6R2013x, IR-162708V6R2013x (End)

   //cpcpart.addMEPtoSEP(context,strTableRowIds);
  }
catch(Exception ex){
    //isError=true;
    session.putValue("error.message", ex.getMessage());
    ex.printStackTrace();
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript">
  var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
  if (contentFrame) {
   contentFrame.location.href=contentFrame.location.href;
  }else{
   parent.location.href=parent.location.href;
  }  
   getTopWindow().closeWindow();
</script>

