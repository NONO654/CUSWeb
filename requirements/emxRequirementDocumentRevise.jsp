<%--  emxRequirementDocumentRevise   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRequirementDocumentRevise.rca 1.14 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
      are added under respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview KIE1 ZUD 16:09:05 : IR-065329-3DEXPERIENCER2017x: When user try to Revise Requirement Specification which is Reserved it throw error.
--%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  //get document Id
  String[] oids = emxGetParameterValues(request, "emxTableRowId");
  String objectId = emxGetParameter(request, "objectId");
// Added for 368104
    String oldobjectId = objectId;
  String strCopyFiles = emxGetParameter(request, "copyFiles");
  String nextRev = emxGetParameter(request, "nextRev");
  
  //added for bug 344195
  boolean isRevised = false;

  // User can reach this page in two ways,
  // One thru Document Summary page, where multiple rows can be selected for revise
  // Two thru Document properties page, in this case ONLY objectId will be passed
  if( oids == null)
  {
    oids = new String[]{objectId};
  }

  if( oids != null)
  {
    Map objectMap = UIUtil.parseRelAndObjectIds(context, oids,false);
   
    boolean copyFiles = (new Boolean(strCopyFiles)).booleanValue();
    try
    {
      for (int i=0; i<oids.length; i++ )
      {
          //build business object/open/unlock/close
          String oid = oids[i];

          CommonDocument commonDocument = (CommonDocument)DomainObject.newInstance(context,oid);
          String strIsVCDoc = commonDocument.getInfo(context,CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
          //if (strIsVCDoc != null && strIsVCDoc.equalsIgnoreCase("true"))
          {
            BusinessObject newbo = RequirementsCommon.revise(context, oid, copyFiles);
            objectId = newbo.getObjectId();
          }
          
          isRevised = true;
     }
    } catch (Exception ex)
    {
    	//ZUD IR-065329-3DEXPERIENCER2017x:  Reserved Object throw System error.
    	String Error_Msg = "";
    	String[] errorArgs = ex.toString().split(":");
    	if(errorArgs.length > 3)
    	{
    		Error_Msg = errorArgs[2]+": "+errorArgs[3];    		
    		Error_Msg = Error_Msg.trim();
    	}
	        
    	else
    	{
    		Error_Msg = ex.getMessage();
                Error_Msg = Error_Msg.trim();
    	}
    	//ZUD IR-065329-3DEXPERIENCER2017x:  Reserved Object throw System error.
    %>
	   	<script language="Javascript" >
	   	window.alert("<%=Error_Msg%>");
	   	</script>
    <%
    }
  }
%>

<%@page import="com.matrixone.apps.requirements.RequirementSpecification"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.BusinessObject"%><html>
<body>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script src="../webapps/AmdLoader/AmdLoader.js"></script>
<script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
<script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
<script language="Javascript" >
function replaceObjectId(strHref,newObjectId)//function Added for Bug : 373517
{
        var stringIndex = strHref.indexOf("objectId=");     
        var startString = strHref.substring(0,stringIndex);
        var endString = strHref.substring(stringIndex,strHref.length);
        stringIndex = endString.indexOf("&");
        if (stringIndex>0)
        {
            endString = endString.substring(stringIndex,endString.length); 
        }
        else
        {
            endString = "";
        }
        strHref = startString+"objectId="+newObjectId+endString;
return strHref;
}
</script>
<script language="Javascript" >
	var frame = findFrame(getTopWindow(),'detailsDisplay')
	if(frame.editableTable !=null&&frame.emxEditableTable!=null){
		//there is no portal displayed
		frame.editableTable.loadData();
		frame.emxEditableTable.refreshStructureWithOutSort();
	}else{
		require(['DS/ENORMTCusto/ENORMTCusto'], function(){
			//the table is in a portal
			var channel = findCurrentChannel();
			if(channel!=null){
				//the channel is found 
				channel.editableTable.loadData();
				channel.emxEditableTable.refreshStructureWithOutSort();
			}else{
				//default behavior;
				refreshTablePage();
			}
		});
	}
</script>

</body>
</html>
<%
   // } //check if doc Id is null
%>
