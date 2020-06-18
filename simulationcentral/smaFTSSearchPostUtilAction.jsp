<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>

<%@page import="matrix.util.StringList"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="matrix.db.BusinessType"%>
<%@page import="matrix.db.BusinessTypeList"%>
<%@page import="matrix.db.BusinessTypeItr"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.RelationshipType"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Map"%>

<jsp:useBean id="indentedTableBean"
    class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />

<html>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>

<%
    String sMode = emxGetParameter(request, "slmmode");
    String sMode1 = emxGetParameter(request, "slmmode1");
    if(sMode1!=null && !sMode1.equals("") )
    {
    	sMode=sMode1;
    }


            if (sMode.equalsIgnoreCase("chooserMultiple")) {
                String sRowIds[] = emxGetParameterValues(request,
                        "emxTableRowId");
                String[] arrSplitRowId = null;
                StringBuilder selObjID = new StringBuilder();
                StringBuilder sTitle = new StringBuilder();

                // if more than one attribute group is selected
                // use them both separated by "; "
                if (sRowIds != null) {
                    for (int idx = 0; idx < sRowIds.length; idx++) {

                        String objID = sRowIds[idx];
                        if (objID.indexOf('|') != -1) {
                            arrSplitRowId = objID.split("\\|");
                            objID = arrSplitRowId[1];
                        }

                        HashMap paramMap = new HashMap();
                        HashMap programMap = new HashMap();

                        paramMap.put("objectId", objID);
                        programMap.put("paramMap", paramMap);

                        String[] methodargs = JPO.packArgs(programMap);

                        String objTitle = (String) JPO.invoke(context,
                                "jpo.simulation.SimulationUI", null,
                                "getTitle", methodargs, String.class);

                        if (idx > 0) {
                            selObjID.append("; ");
                            sTitle.append("; ");
                        }
                        selObjID.append(objID);
                        sTitle.append(objTitle);
                    }

                    String timeStamp = emxGetParameter(request, "timeStamp");
                    Map map = (HashMap) indentedTableBean
                            .getRequestMap(timeStamp);

                    String sFrm = (String) map.get(Search.REQ_PARAM_FORM_NAME);
                    String sFND = (String) map
                            .get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
                    String sFNA = (String) map
                            .get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
%>
<script language="javascript" type="text/javaScript">
    var sFrame = getTopWindow().getWindowOpener();
    //alert("sFrame2 = "+sFrame);
    var txtTypeDisplay = sFrame.document.<%=sFrm%>.<%=sFND%>;
    var txtTypeActual  = sFrame.document.<%=sFrm%>.<%=sFNA%>;
    //alert("txtTypeDisplay = "+txtTypeDisplay +" txtTypeActual  = "+txtTypeActual  );
    txtTypeDisplay.value = "<%=sTitle%>";
    txtTypeActual.value = "<%=selObjID%>";

    getTopWindow().closeWindow();
    </script>
<%
    } else {
                    String message = SimulationUtil.getI18NString(context,
                            "smaSimulationCentral.Error.NoSelection");
                    if (message == null
                            || "smaSimulationCentral.Error.NoSelection"
                                    .equals(message))
                        message = "Nothing Selected";
%>
<script type="text/javascript">
        var s="<%=message%>
    ";
    alert(s);
    var sFrame = getTopWindow().getWindowOpener();
</script>
<%
    }

    } else if (sMode.equalsIgnoreCase("chooser")) {
		String sFrm = "";
        String sFND = "";
        String sFNA = "";
        String sFNAOID = "";
        String sFID =  "";
        String actualfieldId = "";
        String invokedFrom = "";
        String sRowIds[] = emxGetParameterValues(request,"emxTableRowId");
		String uiType = emxGetParameter(request, "uiType");
		
		
		//String selObjID = sRowIds[0];
        String[] arrSplitRowId = null;
        StringBuilder selObjID = new StringBuilder();
        StringBuilder sTitle = new StringBuilder();
        if (sRowIds != null) {
            for (int idx = 0; idx < sRowIds.length; idx++) {

                String objID = sRowIds[idx];
                if (objID.indexOf('|') != -1) {
                    arrSplitRowId = objID.split("\\|");
                    objID = arrSplitRowId[1];
                }

                HashMap paramMap = new HashMap();
                HashMap programMap = new HashMap();

                paramMap.put("objectId", objID);
                programMap.put("paramMap", paramMap);

                String[] methodargs = JPO.packArgs(programMap);

                String objTitle = (String) JPO.invoke(context,
                        "jpo.simulation.SimulationUI", null,
                        "getTitle", methodargs, String.class);

                if (idx > 0) {
                    selObjID.append("; ");
                    sTitle.append("; ");
                }
                selObjID.append(objID);
                sTitle.append(objTitle);
            }            
        }
		if("structureBrowser".equalsIgnoreCase(uiType)){
  	String timeStamp = emxGetParameter(request, "timeStamp");
        Map map = (HashMap)indentedTableBean.getRequestMap(timeStamp);

        sFrm = (String)map.get(Search.REQ_PARAM_FORM_NAME);
        sFND = (String)map.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
        sFNA = (String)map.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
        sFNAOID = sFNA + "OID"; //fix for 178683V6R2013x
        sFID =  (String)map.get("fieldId");
        actualfieldId = (String)map.get("actualfieldId");
        invokedFrom = (String)map.get("invokedFrom");
  }else{
	   sFrm = emxGetParameter(request,"formName");
       sFND = emxGetParameter(request,Search.REQ_PARAM_FIELD_NAME_DISPLAY);
       sFNA = emxGetParameter(request,Search.REQ_PARAM_FIELD_NAME_ACTUAL);
  }
		
%>
        <script language="javascript" type="text/javaScript">
        //<![CDATA[
        try{
<%
            if("performanceStudy".equalsIgnoreCase(invokedFrom)) {      
                DomainObject DO = DomainObject.newInstance(context,selObjID.toString());
                String physicalId = DO.getInfo(context,"physicalid");
%>

			var contentFrame = getTopWindow().getWindowOpener();
			var iocomponent = contentFrame.document.body.querySelector('ps-container').shadowRoot.querySelector('ps-simulation-contents').shadowRoot.querySelector('ps-input-output');
			iocomponent.refSearchReplace("<%=sFNA%>", "<%=sTitle%>", "<%=selObjID%>", "<%=physicalId%>");

<%
            } 
            else if("simulationCompanion".equalsIgnoreCase(invokedFrom)) {
            	DomainObject DO = DomainObject.newInstance(context,selObjID.toString());
			    String title = DO.getAttributeValue(context, 
			        DomainConstants.ATTRIBUTE_TITLE);
%>
				var contentFrame = getTopWindow().getWindowOpener();
				var scAdAppMain = contentFrame.document.body.querySelector('ad-app-main');
				if( scAdAppMain != null ) {
					var scDataview = scAdAppMain.shadowRoot.querySelector('ad-data-view');
					if( scDataview != null ) {
						var scMdataView = scDataview.shadowRoot.querySelector('ad-mdata-view');
						if( scMdataView != null ) {
							scMdataView.addReferencedContent("<%=selObjID%>", "<%=title%>");
						}
					}
				}
				
<%
		} 
            else {      
%>
            var sFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
            if( sFrame == null )
			{
			    sFrame = getTopWindow().getWindowOpener();
			}
            

            var txtTypeDisplay = sFrame.document.<%=sFrm%>.<%=sFND%>;
            var txtTypeActual  = sFrame.document.<%=sFrm%>.<%=sFNA%>;
            //var txtTypeActualOID  = sFrame.document.<%=sFrm%>.<%=sFNAOID%>; 

            //txtTypeDisplay.value = "<%=sTitle%>";
            //txtTypeActual.value = "<%=selObjID%>";
            //txtTypeActualOID.value = "<%=selObjID%>";
            //var txtTypeActualOID  = sFrame.document.<%=sFrm%>.<%=sFNAOID%>;
           // var txtTypeId  = sFrame.document.<%=sFrm%>.<%=sFID%>;

            txtTypeDisplay.value = "<%=sTitle%>";
            txtTypeActual.value = "<%=selObjID%>";
            //txtTypeActualOID.value = "<%=selObjID%>";
<%
          }
%>
                   
      }
      catch(error)
      {
            
            getTopWindow().closeWindow();                
      }
        

        <%
                    // This is not an elegant solution but it is the only
                    // way I can find to hide/show the sim type attributes
                    if ( sFNA.equals("SimType") )
                    {
        %>
                       if ( getTopWindow().getWindowOpener().getSimTypeAttrs )
                          getTopWindow().getWindowOpener().getSimTypeAttrs(true);
        <%
                    }
        %>

        getTopWindow().closeWindow();
        
        </script>
<%
    }
%>
