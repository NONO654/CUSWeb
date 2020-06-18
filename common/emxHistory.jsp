<%-- emxHistory.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorCheckReadAccess.inc"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%
        String initSource = emxGetParameter(request,"initSource");

          if (initSource == null){
            initSource = "";
          }
        String jsTreeID       = emxGetParameter(request,"jsTreeID");
        String suiteKey       = emxGetParameter(request,"suiteKey");
        String HistoryMode    = emxGetParameter(request,"HistoryMode");
        String Header         = emxGetParameter(request,"Header");
        String subHeader      = emxGetParameter(request,"subHeader");
        boolean eMsg          = false;

        String objectId       = emxGetParameter(request,"objectId");
        String isFromRMB       = emxGetParameter(request,"isFromRMB");
        String emxTableRowId       = emxGetParameter(request,"emxTableRowId");
              
        if("true".equals(isFromRMB)&& UIUtil.isNotNullAndNotEmpty(emxTableRowId)){
        	matrix.util.StringList sList = null;
            StringTokenizer st = null;
    	    if(emxTableRowId.indexOf("|") != -1){
    	        st = new StringTokenizer(emxTableRowId, "|");
    	        sList = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId,"|");
    	        if(sList.size() == 3){
    	        	objectId = (String)sList.get(0);
    	        }else{
    	        	objectId = (String)sList.get(1);
    	        }
    	    }else{
    	    	objectId = emxTableRowId;
    	    }
        }
        	
        String preFilter      = emxGetParameter(request,"preFilter");
        String showFilterAction     = emxGetParameter(request,"showFilterAction");
        String showFilterTextBox     = emxGetParameter(request,"showFilterTextBox");
        String categoryTreeName =  emxGetParameter(request, "categoryTreeName");
        String sFilter                  = emxGetParameter(request, "txtFilter");
        String aFilter                  = emxGetParameter(request, "hiddenActionFilter");
        
        String headerdisplay  ="";
        String strFrom="";
        String strTo="";
        String strRefresh="";
        String sHeader="";
        boolean isPreFilter =true;
        String isStructure = emxGetParameter(request, "isStructure");
        
        // ----------------- Do Not Edit Above ------------------------------

        
    	boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);
        String pageTitle="emxFramework.History.History";
        pageTitle=UINavigatorUtil.getI18nString(pageTitle, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
        pageTitle=UIUtil.getWindowTitleName(context,null,objectId,pageTitle);
        boolean isSuiteKey=false;
        String SuiteKey = emxGetParameter(request,"SuiteKey");
        Properties suiteProperties = null;
        String PropertyFileTypeList="";
        String historySelects = emxGetParameter(request,"historySelects");

        if(preFilter != null && !preFilter.equalsIgnoreCase("null") && preFilter.length()>0)
        {
            PropertyFileTypeList=EnoviaResourceBundle.getProperty(context, preFilter);
            if(PropertyFileTypeList==null){
                  PropertyFileTypeList=preFilter;
            }
        }else{
             PropertyFileTypeList=null;
          }

        String InvalidObjectMessage="emxFramework.History.InvalidObject";
        InvalidObjectMessage= EnoviaResourceBundle.getFrameworkStringResourceProperty(context, InvalidObjectMessage, request.getLocale());
        if(objectId == null  || objectId.equals("")){
        throw new Exception(InvalidObjectMessage);
        }

        if(preFilter == null  || preFilter.equals("")){
                 preFilter="*";
        }

        if(showFilterAction == null  || showFilterAction.equals("")){
               showFilterAction="true";
        }

        if(showFilterTextBox == null  || showFilterTextBox.equals("")){
               showFilterTextBox="true";
        }

        if(HistoryMode == null  || HistoryMode.equals("")){
               HistoryMode="CurrentRevision";
        }

        if(Header == null  || Header.equals("")){
               Header="emxFramework.Common.History";
        }
        else{
              Header=Header;
        }

        if(subHeader == null  || subHeader.equals("")){
                 subHeader="emxFramework.History.Revision";
        }
        else{
                  if(subHeader != null && subHeader.equalsIgnoreCase("Version")){
                            subHeader="emxFramework.History.Version";
                    }else{
                            subHeader="emxFramework.History.Revision";
                      }
           }

        Header=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(Header);

        // Specify URL to come in middle of frameset
        StringBuffer contentURL = new StringBuffer(150);
        contentURL.append("emxHistorySummary.jsp");

        // add these parameters to each content URL, and any others the App needs
        contentURL.append("?suiteKey=");
        contentURL.append(XSSUtil.encodeForURL(context, suiteKey));
        contentURL.append("&initSource=");
        contentURL.append(XSSUtil.encodeForURL(context, initSource));
        contentURL.append("&jsTreeID=");
        contentURL.append(XSSUtil.encodeForURL(context, jsTreeID));
        contentURL.append("&objectId=");
        contentURL.append(XSSUtil.encodeForURL(context, objectId));
        contentURL.append("&HistoryMode=");
        contentURL.append(XSSUtil.encodeForURL(context, HistoryMode));
        contentURL.append("&Header=");
        contentURL.append(Header);
        contentURL.append("&subHeader=");
        contentURL.append(XSSUtil.encodeForURL(context, subHeader));
        contentURL.append("&preFilter=");
        contentURL.append(PropertyFileTypeList);
        contentURL.append("&showFilterAction=");
        contentURL.append(XSSUtil.encodeForURL(context, showFilterTextBox));
        contentURL.append("&historySelects=");
        contentURL.append(XSSUtil.encodeForURL(context, historySelects));

        /*String HelpMarker = emxGetParameter(request,"HelpMarker");
        String sHelpMarker="emxhelphistory";
        String sRegDir="common";
        StringBuffer headerURL = new StringBuffer(100);
        headerURL.append("emxHistoryHeader.jsp?SuiteDirectory=");
        headerURL.append(sRegDir);
        headerURL.append("&suiteKey=");
        headerURL.append(suiteKey);
        headerURL.append("&HelpMarker=");
        headerURL.append(sHelpMarker);
        headerURL.append("&HistoryMode=");
        headerURL.append(HistoryMode);
        headerURL.append("&objectId=");
        headerURL.append(objectId);
        headerURL.append("&Header=");
        headerURL.append(Header);
        headerURL.append("&subHeader=");
        headerURL.append(subHeader);
        headerURL.append("&preFilter=");
        headerURL.append(PropertyFileTypeList);
        headerURL.append("&showFilterAction=");
        headerURL.append(showFilterAction);
        headerURL.append("&showFilterTextBox=");
        headerURL.append(showFilterTextBox);
        headerURL.append("&categoryTreeName=");
        headerURL.append(categoryTreeName);*/
        
      //*********History header*******//
        strFrom= EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.From", request.getLocale());
        strTo= EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.To" , request.getLocale());
        strRefresh= EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Refresh" , request.getLocale());
      
          if(preFilter == null  || preFilter.equals("")){
             preFilter="*";
             isPreFilter=false;
          }
      
      
        if(HistoryMode==null)
         HistoryMode="CurrentRevision";
      
        String resourceFile = ( suiteKey != null && suiteKey.length() > 0 ) ?
            UINavigatorUtil.getStringResourceFileId(context, suiteKey) :
            "emxFrameworkStringResource";
        
          
        String sSubHeader = subHeader;
        if(subHeader!=null)
            subHeader= EnoviaResourceBundle.getProperty(context,resourceFile, request.getLocale(), subHeader);
                  
        // If key is not found in resource file, try the framework file
        if ( subHeader != null && subHeader.equals(sSubHeader) )
            subHeader= EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", request.getLocale(), subHeader);
      
      
        if(Header.indexOf("$<")>=0)
          sHeader=UIExpression.substituteValues(context, pageContext, Header, objectId);
        else{
            sHeader= EnoviaResourceBundle.getProperty(context,resourceFile, request.getLocale(), Header);
                    
                   // If key is not found in resource file, try the framework file
                     if ( Header != null && Header.equals(sHeader) )       
                          sHeader = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, Header , request.getLocale());
            
                   if(sHeader.indexOf("$<")>=0)
             sHeader=UIExpression.substituteValues(context, pageContext, sHeader, objectId);
      
        }
        
        String sHelpMarker=emxGetParameter(request,"HelpMarker");
        String portalMode = emxGetParameter(request, "portalMode");
        String suiteDir="common";
        String dropDownPrefix="";

        if (sHelpMarker == null || sHelpMarker.trim().length() == 0)
          sHelpMarker = "emxhelphistory";

        //By default set the filter to "*"
        if (sFilter == null || sFilter.trim().equals("")) {
          sFilter = "*";
        }

        //By default set History filter to "CurrentRevision"
        if (HistoryMode == null || HistoryMode.trim().equals("")) {
          HistoryMode = "CurrentRevision";
        }

        if (subHeader == null || subHeader.trim().equals("")) {
          subHeader = "Revision";
        }

        String sVersion = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Version" , request.getLocale());

        if(subHeader.equalsIgnoreCase(sVersion)) {
            dropDownPrefix=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Version" , request.getLocale());
        } else {
          dropDownPrefix=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.Revision" , request.getLocale());
        }

        //By default set the action filter to "*"
        if (aFilter == null || aFilter.trim().equals("")) {
          if(preFilter==null || preFilter.equalsIgnoreCase("null"))
            aFilter = "*";
          else
            aFilter=preFilter;
        }

       BusinessObjectList bObjList=new BusinessObjectList();
            BusinessObject passedObj = new BusinessObject(objectId);
            passedObj.open(context);
            String fromDp="";
            String toDp="";
            String revisionlist="";
            if(HistoryMode.equalsIgnoreCase("AllRevisions"))
            {
                   bObjList = passedObj.getRevisions(context);
                   fromDp=getRevisionDrowdown(bObjList,"fromlist");
                   StringTokenizer stFrom=new StringTokenizer(fromDp,"|||");
                     fromDp=stFrom.nextToken();
                     revisionlist=stFrom.nextToken();
                   toDp=getRevisionDrowdown(bObjList,"tolist");
                   StringTokenizer stTo=new StringTokenizer(toDp,"|||");
                   toDp=stTo.nextToken();
            }

      passedObj.close(context);
      //***************//
        %>
        
	<%!
	  //
	  // returns true/false based on whether it is to be displayed or not
	  //
	  static public String getRevisionDrowdown(BusinessObjectList bObjList,String SelectlistName)
	  {
	    StringBuffer dropDownOptions = new StringBuffer(80);
	    String revisionlist="$";
	    StringBuffer dropDownSelect = new StringBuffer(80);
	    dropDownSelect.append("<select name=\"");
	    dropDownSelect.append(SelectlistName);
	    dropDownSelect.append("\">\n");
	    BusinessObject lastObj = null;
	
	   for(int Rev=bObjList.size()-1;Rev>=0;Rev--){
	          lastObj = bObjList.getElement(Rev);
	        String sBusRev=lastObj.getRevision();
	        revisionlist+=sBusRev+"$";
	        if( dropDownOptions.toString().equals(""))
	        {
	               dropDownOptions.append("<option value=\"");
	               dropDownOptions.append(sBusRev);
	               dropDownOptions.append("\">");
	               dropDownOptions.append(sBusRev);
	               dropDownOptions.append("</option>\n");
	        }
	        else
	        {
	               dropDownOptions.append("<option value=\"");
	               dropDownOptions.append(sBusRev);
	               dropDownOptions.append("\">");
	               dropDownOptions.append(sBusRev);
	               dropDownOptions.append("</option>\n");
	        }
	    }
	    dropDownOptions.insert(0,dropDownSelect.toString());
	    dropDownOptions.append("</select>");
	
	    return dropDownOptions.toString()+"|||"+revisionlist;
	
	  }
	%>
<html>
<head>
    <script language="javascript" type="text/javascript" src="scripts/emxUIConstants.js"></script>
            <script language="JavaScript" src="scripts/emxUIConstants.js"></script>
        <script language="JavaScript" src="scripts/emxUICore.js"></script>
        <script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
    <script language="JavaScript" src="scripts/emxUIModal.js"></script>

    <script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>
    <script type="text/javascript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
    </script>
    <%if(UINavigatorUtil.isMobile(context)) { %>
    	<LINK rel="stylesheet" href="mobile/styles/emxUIMobile.css" type="text/css" />
    <%} %>
        <script language="JavaScript">
		  // This Function Checks For The Length Of The Data That Has
		  // Been Entered And Trims the Extra Spaces In The Front And Back.
		  function trim(varTextBox) {
		    while (varTextBox.charAt(varTextBox.length-1) == ' ' || varTextBox.charAt(varTextBox.length-1) == "\r" || varTextBox.charAt(varTextBox.length-1) == "\n" )
		      varTextBox = varTextBox.substring(0,varTextBox.length - 1);
		    while (varTextBox.charAt(0) == ' ' || varTextBox.charAt(0) == "\r" || varTextBox.charAt(0) == "\n")
		      varTextBox = varTextBox.substring(1,varTextBox.length);
		      return varTextBox;
		  }
		
		  //Trims the filter criteria and submits the form
		  function Validate() {

			var objFrame = frames['objectHistoryFrame'];
		
		    if (!objFrame.document.objectHistory)
		    {
		      return;
		    }
		
		  <%if(showFilterTextBox.equalsIgnoreCase("true")){%>
		  		objFrame.document.objectHistory.txtFilter.value=encodeURIComponent(document.objectHistoryHeader.txtFilter.value);		  
		  <%}%>
		    <%if(HistoryMode.equalsIgnoreCase("AllRevisions")){%>
		    objFrame.document.objectHistory.fromlist.value = document.objectHistoryHeader.fromlist.options[document.objectHistoryHeader.fromlist.selectedIndex].value;
		    objFrame.document.objectHistory.tolist.value = document.objectHistoryHeader.tolist.options[document.objectHistoryHeader.tolist.selectedIndex].value;
		    objFrame.document.objectHistory.revisionlist.value = document.objectHistoryHeader.revisionlist.value;
		
		    <%}%>
		    objFrame.document.objectHistory.hiddenActionFilter.value = document.objectHistoryHeader.actionFilter.value;
		
		    <%if(isPreFilter){
		       if(showFilterAction.equalsIgnoreCase("true")){
		    %>
		    objFrame.document.objectHistory.preFilter.value = document.objectHistoryHeader.actionFilter.value;
		
		     <%}else{%>
		     objFrame.document.objectHistory.preFilter.value = "<xss:encodeForJavaScript><%=preFilter%></xss:encodeForJavaScript>";
		
		     <%}%>
		
		    <%}%>
		    objFrame.document.objectHistory.submit();
		  }
		
		  //Trims the filter criteria and submits the form
		  function ActionFilter() {
			var objFrame = frames['objectHistoryFrame'];//document.getElementById('objectHistoryFrame');
		    if (!objFrame.document.objectHistory)
		    {
		      return;
		    }
		    var actionFil = trim(objFrame.document.objectHistory.hiddenActions.value);
		    var objId=document.objectHistoryHeader.objectId.value;
		    var previouactionfilter=document.objectHistoryHeader.actionFilter.value;
		    var windowParams = "700,700,false";
		    //var linkHref="showActionSelections.jsp";
		    var linkHref="emxShowHistoryActions.jsp?hiddenActions="+escape(actionFil)+"&actionfilter="+escape(previouactionfilter)+"&objectId="+objId;
		    showModalDialog(linkHref,'300','400',true, 'Small');
		    //window.open(linkHref, "Action Selection",'','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=1,copyhistory=1,dependent=0');
		  }
		
		  var printDialog = null;
		   function callPrinterPage(heading){
		    var randomnumber=Math.floor(Math.random()*123456789101112);
		    strURL = "";
		    var strFilterit="";
		    var filteringValue="";
		    var objFrame = frames['objectHistoryFrame'];//document.getElementById('objectHistoryFrame');
		    currentURL = objFrame.document.location.href;
		
		
		    if (currentURL.indexOf("?") == -1){
		      strURL = currentURL + "?PrinterFriendly=true&mx.rnd=" + randomnumber + "&pfheading=" + heading;
		    }else{
		      strURL = currentURL + "&PrinterFriendly=true&mx.rnd=" + randomnumber + "&pfheading=" + heading;
		    }
		    iWidth = "700";
		    iHeight = "600";
		    bScrollbars = true;
		
		      //make sure that there isn't a window already open
		    if (!printDialog || printDialog.closed) {
		
		      //build up features string
		      var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=yes";
		
		      //calculate center of the screen
		      var winleft = parseInt((screen.width - iWidth) / 2);
		      var wintop = parseInt((screen.height - iHeight) / 2);
		
		      if (isIE)
		        strFeatures += ",left=" + winleft + ",top=" + wintop;
		      else
		        strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;
		
		      strFeatures +=  ",toolbar=yes";
		
		      //are there scrollbars?
		      if (bScrollbars) strFeatures += ",scrollbars=yes";
		
		      //open the window
		      printDialog = window.open(strURL, "printDialog" + (new Date()).getTime(), strFeatures);
		
		      //set focus to the dialog
		      printDialog.focus();
		
		    } else {
		          //if there is already a window open, just bring it to the forefront (NCZ, 6/4/01)
		      if (printDialog) printDialog.focus();
		    }
		  }
		   
		   function openPrinterFriendlyPage(){
		       callPrinterPage('<xss:encodeForJavaScript><%=Header%></xss:encodeForJavaScript>');
		   }


    </script>


    <style type="text/css">
		div#divPageBody {
		  top:119px;
		  bottom:0px;
		}
    </style>
</head>
<body onload="turnOffProgress();">
		<div id="pageHeadDiv">
        <form name="objectHistoryHeader" method="post" action="emxHistorySummary.jsp" onsubmit="Validate(); return false">
		   <table>
		<tr>
		    <td class="page-title">
		      <h2><xss:encodeForHTML><%=sHeader%></xss:encodeForHTML></h2>
		<%
		      if(subHeader != null && !"".equals(subHeader)) {
		%>
		        <h3><xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></h3>
		<%
		        }
		%>
		    </td>
		    <%
		       String processingText = UINavigatorUtil.getProcessingText(context, request.getHeader("Accept-Language"));
		    %>
		        <td class="functions">
		              <table>
		<tr>
		                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
		<%
		if(HistoryMode.equalsIgnoreCase("AllRevisions")){%>
		<td nowrap align="right">
		<!-- //XSSOK -->
		<%=strFrom%>&nbsp;<%=dropDownPrefix%>:<%=fromDp%> <%=strTo%>&nbsp;<%=dropDownPrefix%>:<%=toDp%>&nbsp;<input type="button" value="<%=strRefresh%>" onClick="Validate()"/>
		    </td>
		<%}%>
		              </tr></table>
		        </td>
		</tr>
		</table>
		<script language="JavaScript" src="../common/emxToolbarJavaScript.jsp?export=false&isStructure=<%=XSSUtil.encodeForURL(context, isStructure)%>&categoryTreeName=<%=XSSUtil.encodeForURL(context, categoryTreeName)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId) %>&HelpMarker=<%=XSSUtil.encodeForURL(context, sHelpMarker)%>&portalMode=<%=XSSUtil.encodeForURL(context, portalMode)%>" type="text/javascript"></script>
		<div class="toolbar-container" id="divToolbarContainer">
			<div id="divToolbar" class="toolbar-frame"></div>
		</div>
		        <div class="toolbar-container" id="divRevisionHistoryFilter"><div class="toolbar-frame"><div class="toolbar">
		  <table cellspacing="0" cellpadding="0" border="0">
		  <tr>
		    <td>
		          <%if(showFilterAction.equalsIgnoreCase("true")){%>
		          <emxUtil:i18n localize="i18nId">emxFramework.History.ActionType</emxUtil:i18n>
		          <%}%>
		          </td>
		          <td>
		          <%if(showFilterAction.equalsIgnoreCase("true")){%>
		          <input type="text"  size="20" name="actionFilterDisplay" value="<xss:encodeForHTMLAttribute><%=aFilter%></xss:encodeForHTMLAttribute>" onFocus="this.blur()" />
		          <input type="hidden"  size="20" name="actionFilter" value="<xss:encodeForHTMLAttribute><%=aFilter%></xss:encodeForHTMLAttribute>" onFocus="this.blur()" />
		          <%}else{%>
		          <input type="hidden"  size="20" name="actionFilter" value="<xss:encodeForHTMLAttribute><%=preFilter%></xss:encodeForHTMLAttribute>" onFocus="this.blur()" />
		          <%}%>
		          <%if(showFilterAction.equalsIgnoreCase("true")){%>
		          <input type="button" value="..." onClick="ActionFilter()" />
		          <%}%>
		          <%if(showFilterAction.equalsIgnoreCase("true") && showFilterTextBox.equalsIgnoreCase("true")){%>
		          <emxUtil:i18n localize="i18nId">emxFramework.History.And</emxUtil:i18n>
		          <%}%>
		          <%if(showFilterTextBox.equalsIgnoreCase("true")){%>
		          <input type="text" size="10" name="txtFilter" value="<xss:encodeForHTMLAttribute><%=sFilter%></xss:encodeForHTMLAttribute>" />
		          <%}%>
		          <%if(showFilterAction.equalsIgnoreCase("true") || showFilterTextBox.equalsIgnoreCase("true")){%>
		          <input type=button value="<emxUtil:i18n localize="i18nId">emxFramework.History.Filter</emxUtil:i18n>" onClick="Validate()" />
		          <%}%>
		          </td>
		         </tr>
		       </table>
		</div></div></div>
		  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
		    <input type="hidden" name="revisionlist" value="<%=revisionlist%>" />
		</form>
		</div>
    <div id="divPageBody">
                <iframe src="<%=contentURL.toString()%>" name="objectHistoryFrame" id="objectHistoryFrame" height="100%" width="100%" frameborder="0" ></iframe>
     </div>
</body>
</html>
