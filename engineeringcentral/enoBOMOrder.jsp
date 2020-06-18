<%--  enoTreeOrder.jsp -  This Page is used for all Tree Order Operations.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>

<jsp:useBean id="resequenceBean" class="com.matrixone.apps.engineering.Part" scope="session" />
<%

String sFunctionality = emxGetParameter(request, "functionality");
String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
String objId = emxGetParameter(request, "objectId");
String language           = request.getHeader("Accept-Language");
String strProcessing         =  EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.Processing");

boolean blnValid = false;
String objectId = "";
String sRowId = "0";
String validObjects = "";
String invalidObjects = "";
String selPartParentOId="";
String strPolicy ="";
String strCurrent = "";
StringList spartList=new StringList();
String strPolicyAndAllowedStates = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.AllowedStates");
StringList policyAndAllowedStatesList=FrameworkUtil.split(strPolicyAndAllowedStates, ",");
Map policyAndAllowedStatesMap=new HashMap();
String strTemp;
String stringPolicyActual;
String stringPolicy;
try {
		if (tableRowIdList==null) {
		           tableRowIdList = new String[1];
		           tableRowIdList[0] = "|"+objId+"||0";
		}

       for(int i=0;i<tableRowIdList.length;i++){
           StringList slList = FrameworkUtil.split(" "+tableRowIdList[i], "|");
           objectId  = ((String)slList.get(1)).trim();
           selPartParentOId  = ((String)slList.get(2)).trim();
           sRowId    = ((String)slList.get(3)).trim();
           if("0".equals(sRowId)){
               selPartParentOId = objectId;
           }
           if(!"".equals(validObjects)){
               validObjects += "^";
           }
           validObjects += objectId + "|" +sRowId;
       }
           
   } catch (Exception ex) {
       throw ex;
   } 
            

%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
    
    var functionality = "<xss:encodeForJavaScript><%=sFunctionality%></xss:encodeForJavaScript>";
    var contentFrame   = findFrame(parent,"listHidden");
    var dupemxUICore   = contentFrame.parent.emxUICore;
    var dupcolMap      = contentFrame.parent.colMap;
    var dupTimeStamp   = contentFrame.parent.timeStamp;
    var postXML        = null;
    var theRoot        = null;
    var mxRoot         = contentFrame.parent.oXML.documentElement;
    var dialogLayerOuterDiv, dialogLayerInnerDiv, iframeEl;
    </script>
    <script language="Javascript">
/**************************************************************************/
/* function addMask() - this function doesn't allows the user to do       */
/* anything while processing Resequence operation.                        */
/**************************************************************************/
function addMask(){
try {
        dialogLayerOuterDiv = contentFrame.parent.document.createElement("div");
        dialogLayerOuterDiv.className = "mx_divLayerDialogMask";
        contentFrame.parent.document.body.appendChild(dialogLayerOuterDiv);
     
        if (isIE) {
            iframeEl = contentFrame.parent.document.createElement("IFRAME");
            iframeEl.frameBorder = 0;
            iframeEl.src = "../common/emxBlank.jsp";
            iframeEl.allowTransparency = true;
            contentFrame.parent.document.body.insertBefore(iframeEl, dialogLayerOuterDiv);
        }

        dialogLayerInnerDiv = contentFrame.parent.document.createElement("div");
        dialogLayerInnerDiv.className = "mx_alert";
        dialogLayerInnerDiv.setAttribute("id", "mx_divLayerDialog");
     
            
        dialogLayerInnerDiv.style.top = contentFrame.parent.editableTable.divPageHead.offsetHeight + 10 + "px";
        dialogLayerInnerDiv.style.left = contentFrame.parent.getWindowWidth()/3 + "px";
        
        contentFrame.parent.document.body.appendChild(dialogLayerInnerDiv);

        var CENTER = contentFrame.parent.document.createElement("CENTER");
        var BOLD = contentFrame.parent.document.createElement("b");
        if(isIE) {
        	//XSSOK
            BOLD.innerText = "<%=strProcessing%>";
        } else {
        	//XSSOK
            BOLD.textContent = "<%=strProcessing%>";
        }

        CENTER.appendChild(BOLD);
        dialogLayerInnerDiv.appendChild(CENTER);
        contentFrame.parent.turnOnProgress();
    }
    catch(e){
    }
}

/**************************************************************************/
/* function removeMask() - Once the Resequence process is finished, it    */
/* removes the added Mask to the BOM Page.                                */
/**************************************************************************/
function removeMask(){
    try{
        contentFrame.parent.document.body.removeChild(dialogLayerInnerDiv);
        contentFrame.parent.document.body.removeChild(dialogLayerOuterDiv);
        
        if(isIE){
            contentFrame.parent.document.body.removeChild(iframeEl);
        }
        contentFrame.parent.turnOffProgress();
    }
    catch(e){
        }
      }
function persistOrder(){
	addMask();
	//XSSOK
	var sObjects = "<%=validObjects%>";
    var arrValidIds = sObjects.split("^");
    var responseTxt;
    var success = true;
	        //Iterate all the selected parts
	        for(var j=0;j<arrValidIds.length;j++){
	            var arrCombi = arrValidIds[j].split("|");
	            if(arrCombi[0] != null && arrCombi[0] != "" && (typeof arrCombi[0] != "undefiend")){
	                
	            	var rowToAdd = dupemxUICore.selectSingleNode(contentFrame.parent.oXML.documentElement, "/mxRoot/rows//r[@o = '" + arrCombi[0] + "' and @id = '" + arrCombi[1] + "']");
					 var SBRows   = dupemxUICore.selectNodes(rowToAdd, "r");
					 var relIdList = null;
					 for(var i=0;i<SBRows.length;i++){
						 var relid = SBRows[i].getAttribute("r");
						 if(relIdList == null){
							 relIdList = relid;
						 }
						 else {
							 relIdList = relIdList +"~"+relid;
						 }
					 }
					 var url="../engineeringcentral/enoBOMOrderOperations.jsp?";  
						var strData = "relIdList="+relIdList;
			 			responseTxt = emxUICore.getDataPost(url,strData);
			 			responseTxt = responseTxt.trim();
			 			if(responseTxt !=""){
			 				success = false;
			 				break;
			 			}
	        	}
	            
	        }
		if(success){
			parent.removePersistenceData("sortColumnName","ENCEBOMIndentedSummarySB");
			parent.removePersistenceData("sortDirection","ENCEBOMIndentedSummarySB");
			removeMask();
		}else{
			removeMask();
			window.location.href = "../components/emxMQLNotice.jsp";
		}
}
      </script>
    <script language="javascript">
if("persistOrder" ==  functionality){
	persistOrder();
} 
else if("clearSort" ==  functionality){
	parent.removePersistenceData("sortColumnName","ENCEBOMIndentedSummarySB");
	parent.removePersistenceData("sortDirection","ENCEBOMIndentedSummarySB");
	var url = parent.location.href;
	url = url.replace("&persist=true", "");
	parent.location.href = url;
}

</script>

