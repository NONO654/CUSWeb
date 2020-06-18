<%-- emxMetricsLifecycleDurationReport.jsp - This file displays the Lifecycle Duration Report Over Time dialog page
   
   Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsLifecycleDurationReport.jsp.rca 1.12 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<html>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>

<head>
    <script type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
    <script type="text/javascript" src="emxMetrics.js"></script>
    <script type="text/javascript" src="emxMetricsLifecycleDurationUtils.js"></script>
    <script type="text/javascript" src="emxMetricsPolicyChooserUtils.js"></script>
    <script type="text/javascript" language="JavaScript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUIMenu");
        addStyleSheet("emxUIForm");
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIList");
		addStyleSheet("emxUIContainedInSearch");
    </script>
</head>

<%
     String useTypeChooser        = emxGetParameter(request, "useTypeChooser");
    String typeSelection         = emxGetParameter(request, "SelectType");
    String editable              = emxGetParameter(request, "editable");
    String strLanguage            = request.getHeader("Accept-Language");
    String strInclusionList       = emxGetParameter(request, "InclusionList");
    String strExclusionList       = emxGetParameter(request, "ExclusionList");
    String strSelectAbstractTypes = emxGetParameter(request,"SelectAbstractTypes");
    String strSearchedTypes       = "";
    String translatedTypeNames    = "";
    String strBundle              = "emxMetricsStringResource";
    String typeChooserURL         = "";
    String strType                = "";
    String strPolicy              = "";
    String strTargetState         = "";
    String strTimeFrame           = "";
    String strDateUnit            = "";
    String strReportStates        = "";
    String strDisplayFormat       = "";
    String strDates               = "";
    String strFrom                = "";
    String strTo                  = "";
    String strPeriods             = "";
    String strWeek                = "";
    String strMonth               = "";
    String strQuarter             = "";
    String strYear                = "";
    String strTabular             = "";
    String strBarChart            = "";
    String strStackBarChart       = "";
    String strLineChart           = "";
    String requiredText           = "";
    String strDateFrm             = "";
    String strAxisLabels          = "";
    String strHorizontal          = "";
    String strVertical            = "";
    String strRenderOptions       = "";
    String str3D                  = "";
     

	  String strContainedIn = "";
    String strActualContainedIn = "";
    String strContainedInType="";
    String strContainedInRev="";
    String strShowPercentage  = emxGetParameter(request,"showPercentage");

	 boolean showAdvancedLink     = true;
	 boolean isTypeFieldEditable  = true;
     
    try {


		ContextUtil.startTransaction(context, false);
        if(!"false".equalsIgnoreCase(useTypeChooser) && !"true".equalsIgnoreCase(editable)) {
            isTypeFieldEditable = false;
        }
        typeChooserURL = "../common/emxTypeChooser.jsp?callbackFunction=updatePolicyAndStates&formName=frmLifecycleDurationReport&frameName=metricsReportContent&fieldNameActual=txtTypeActual&fieldNameDisplay=txtTypeDisplay";
        typeChooserURL += "&SelectType=" + XSSUtil.encodeForURL(context, typeSelection);

        //Allow type chooser to use abstract types?
        if(strSelectAbstractTypes != null && !"null".equals(strSelectAbstractTypes) && !"".equals(strSelectAbstractTypes) && "false".equals(strSelectAbstractTypes.toLowerCase())) {
            strSelectAbstractTypes = "false";
        }else{
            strSelectAbstractTypes = "true";
        }
        
        //typeChooserURL = "../common/emxTypeChooser.jsp?callbackFunction=updatePolicyAndStates&formName=frmLifecycleDurationReport&frameName=metricsReportContent&fieldNameActual=txtTypeActual&fieldNameDisplay=txtTypeDisplay";
        typeChooserURL += "&SelectAbstractTypes=" +  XSSUtil.encodeForURL(context, strSelectAbstractTypes);

        if(strInclusionList != null && strInclusionList.trim().length() > 0) {
            typeChooserURL += "&InclusionList=" +  XSSUtil.encodeForURL(context, strInclusionList);
        } else if(strExclusionList != null && strExclusionList.trim().length() > 0) {
            typeChooserURL += "&ExclusionList=" +  XSSUtil.encodeForURL(context, strExclusionList);
        } else {
            typeChooserURL += "&InclusionList=emxMetrics.MetricsReports.Types";
        }

        strDateFrm        = PersonUtil.getPreferenceDateFormatString(context);
        strType           = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Type");
        strPolicy         = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Policy");
        strTargetState    = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.TargetState");
        strTimeFrame      = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.TimeFrame");
        strDateUnit       = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.DateUnit");
        strReportStates   = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.ReportStates");
        strDisplayFormat  = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.DisplayFormat");
        strDates          = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Dates");
        strFrom           = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.From");
        strTo             = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.To");
        strPeriods        = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.PeriodsPriortoCurrentDate");
        strWeek           = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Week");
        strMonth          = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Month");
        strQuarter        = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Quarter");
        strYear           = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.Year");
        strTabular        = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.TabularFormat");
        strBarChart       = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.BarChart");
        strStackBarChart  = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.StackBarChart");
        strLineChart      = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.label.LineChart");
        requiredText      = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Commom.RequiredText");
        strAxisLabels     = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.ChartOptions.XAxisLabels");      
        strHorizontal     = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.ChartOptions.XAxisLabels.Horizontal");
        strVertical       = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.ChartOptions.XAxisLabels.Vertical");
        strRenderOptions  = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.ChartOptions.RenderOptions");
        str3D             = EnoviaResourceBundle.getProperty(context,strBundle,context.getLocale(),"emxMetrics.ChartOptions.3D");
			/*  start of added code for ContainedIn Functionality  */
			
		   strContainedIn = emxGetParameter(request, "txtContainedIn");
		   strActualContainedIn = emxGetParameter(request, "txtActualContainedIn");

		if ((strContainedIn == null) || "null".equalsIgnoreCase(strContainedIn)||"".equals(strContainedIn))
		 {
		  strContainedIn = "";
		 }
		if ((strActualContainedIn == null) || "null".equalsIgnoreCase(strActualContainedIn))
		{
		  strActualContainedIn = "";
		 }
		//Contained Object Type Name and Rev Information
    strContainedInType = emxGetParameter(request, "txtContainedInType");

    if ((strContainedInType == null) || "null".equalsIgnoreCase(strContainedInType))
     {
          strContainedInType = "";
     }
    
	strContainedInRev = emxGetParameter(request, "txtContainedInRev");

    if ((strContainedInRev == null) || "null".equalsIgnoreCase(strContainedInRev))
     {
          strContainedInRev = "";
     }
	
	
	/* end of added code for ContainedIn Functionality  */
	
	
    } catch (Exception ex) {
        if(ex.toString() != null && (ex.toString().trim()).length()>0) {
            emxNavErrorObject.addMessage("Metrics Lifecycle Duration Report dialog page : " + ex.toString().trim());
        }
    }
%>
<body  onLoad="getTopWindow().loadReport(); setTimeout('doLoad()',100); turnOffProgress();">
    <div>
        <form name="frmLifecycleDurationReport" method="post" onsubmit="javascript:getTopWindow().generateReport(); return false">
            
            
            <table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
                <tr><td class="requiredNotice" align="center" nowrap ><%=requiredText%></td></tr>
            </table>
            <table width="100%" border="0" cellpadding="5" cellspacing="2">
                <tr>
                    <td class="labelRequired" width="150" align="left"><%=strType%></td>
                    <td class="inputField"> <input type="text" value="<%=translatedTypeNames%>" name="txtTypeDisplay" id="txtTypeDisplay" size="20" readonly="readonly" maxlength="25" />
                        <input type="hidden" name="txtTypeActual" id="txtTypeActual" value="<%=strSearchedTypes%>" /> 
                        <input name="button" type="button" id="button" value="..." onclick="javascript:getTopWindow().showChooser('<%=typeChooserURL%>', 500, 500)" />
                        &nbsp;
			<input type="hidden" name="hdnXML" id="hdnXML" value="" />
            <input type="hidden" name="hdnAllStates" id="hdnAllStates" value="" />
            <input type="hidden" name="txtFromDate_msvalue" id="txtFromDate_msvalue" value="" />
            <input type="hidden" name="txtToDate_msvalue" id="txtToDate_msvalue" value="" />
                     </td>
                </tr>
               <tr>
                    <td class="labelRequired" width="150" align="left"><%=strPolicy%></td>
                    <td class="inputField"> <input type="text" name="txtPolicyDisplay" id="txtPolicyDisplay" value="" size="19" readonly="readonly" maxlength="25" />
                        <input type="hidden" name="txtPolicyActual" id="txtPolicyActual" value="<%=strSearchedTypes%>" />
                        <input type="button" value="..." name="btnPolicy" id="btnPolicy" onClick="javascript:setSelectedPolicyOption()" />
                    </td>
                </tr>
                <tr>
                    <td class="labelRequired" width="150" align="left"><%=strTargetState%></td>
                    <td class="inputField">
                        <table>
                            <tr>
                            <td>
                                <div id="trgState">
                                    <select name="lstTargetState"></select>
                                </div>
                            </td>
                            </tr>
                        </table>
                    </td>
                </tr>


<!--  start  of added code for ContainedIn Functionality   -->
                <tr>
<%
//Added for Note Type Feature 
	strInclusionList = "emxFramework.ContextSearch.ContainedIn.Types";
%>
<!--  Added for Note Type feature  -->
                <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.ContainedIn</emxUtil:i18n></td>
                <td class="inputField">
<!--       <input type="text" size="20" name="txtContainedIn" readonly="readonly" value="" />-->
		   <input type="text" name="txtContainedIn" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strContainedIn%></xss:encodeForHTMLAttribute>" />
		   <input name="button" type="button" value="..." onclick="javascript:showAffectedItemSelector()" />

		   <a class="dialogClear" href="#" onclick="javascript:clearContainedIn()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
		   <iframe name="hiddenFrm" id="hiddenFrm" frameborder="0"  style="position:absolute;display:none;" src="javascript:false;" scrolling="no"></iframe>
		   <input type="hidden" name="txtActualContainedIn" value="<xss:encodeForHTMLAttribute><%=strActualContainedIn%></xss:encodeForHTMLAttribute>" />
		   <input type="hidden" name="txtContainedInType" value="<xss:encodeForHTMLAttribute><%=strContainedInType%></xss:encodeForHTMLAttribute>" />
		   <input type="hidden" name="txtContainedInRev" value="<xss:encodeForHTMLAttribute><%=strContainedInRev%></xss:encodeForHTMLAttribute>" />
					   &nbsp;
		&nbsp;<img src="../common/images/iconActionHelp.gif" border="0" style="cursor: pointer" id="imgTag" ></img>
			</td>
			  </tr>

<!-- end of added code for ContainedIn Functionality  -->

               <tr>
                    <td class="labelRequired" width="150" align="left"><%=strTimeFrame%></td>
                    <td class="inputField">
                    
                        <table>
                            <tr>
                                <td>
                                    <input name="optPeriod" id="optPeriodDates" type="radio" checked="false" value="DateWise" onClick="javascript:disablePeriod()" />
                                    <%=strDates%>&nbsp;<%=strFrom%>
                                    <input type="text" name="txtFromDate" id="txtFromDate" size="15" value = "<emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getValue("timeZone"))%>' format='<%=strDateFrm %>' displaydate ="true" displaytime ="false"></emxUtil:lzDate>"  readonly="readonly" disabled="true" />
                                    <a href="javascript:document.forms[0].optPeriodDates.checked=true;disablePeriod();showCalendar('frmLifecycleDurationReport','txtFromDate','')">
                                        <img src="../common/images/iconSmallCalendar.gif" id="fromDate" border="0" valign="bottom" />
                                    </a>
                                    &nbsp;
                                    <%=strTo%>
                                    <input type="text" name="txtToDate" id="txtToDate" size="15" value = "<emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getValue("timeZone"))%>' format='<%=strDateFrm %>' displaydate ="true" displaytime ="false"></emxUtil:lzDate>" readonly="readonly" disabled="true">
                                    <a href="javascript:document.forms[0].optPeriodDates.checked=true;disablePeriod();showCalendar('frmLifecycleDurationReport','txtToDate','')">
                                        <img src="../common/images/iconSmallCalendar.gif" id="toDate" border="0" valign="bottom" />
                                    </a>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <table border="0">
                            <tr>
                                <td>
                                    <input type="radio" name="optPeriod" id="optPeriods" checked="false" value="PeriodWise" onClick="javascript:disableDates()" />
                                    <%=strPeriods%>
                                    <input type="text" name="txtPeriod" id="txtPeriod" size="15" value = "" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="150" class="labelRequired"><div id="dlabelDir"><%=strDateUnit%></div></td>
                    <td class="inputField"> 
                        <div id="dlabelDirVal">
                            <table>
                                <tr>
                                    <td>
                                        <input type="radio" name="optDateUnit" value="w" checked />
                                        <%=strWeek%>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="radio" name="optDateUnit" value="m" />
                                        <%=strMonth%>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="radio" name="optDateUnit" value="q" />
                                        <%=strQuarter%>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="radio" name="optDateUnit" value="y" />
                                        <%=strYear%>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="labelRequired" width="150" align="left"><%=strReportStates%></td>
                    <td class="inputField">
                        <table>
                            <tr>
                                <td><%=strFrom%></td>
                                <td>
                                    <div id="frmState">
                                        <select name="lstFromState" id="lstFromState"></select>
                                    </div>
                                </td>
                                <td><%=strTo%></td>
                                <td> 
                                    <div id="toState">               
                                        <select name="lstToState" id="lstToState"></select>  
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="150" class="labelRequired"><%=strDisplayFormat%></td>
                    <td class="inputField"> 
                        <select name="chartType" id="chartType">
                            <option value="Tabular" selected><%=strTabular%></option>
                            <option value="BarChart"><%=strBarChart%></option>
                            <option value="StackBarChart"><%=strStackBarChart%></option>
                            <option value="LineChart"><%=strLineChart%></option>
                        </select>
                    </td>
                </tr>
                <tr id="labeldirectionrow">
                    <td width="150" class="label"><div id="dlabelDir"><%=strAxisLabels%></div></td>
                    <td class="inputField">
                        <div id="dDirVal">
                        <table>
                            <tr>
                                <td>
                                    <input type="radio" name="labelDirection" value="Vertical" checked />
                                    <%=strVertical%>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="radio" name="labelDirection" value="Horizontal" />
                                    <%=strHorizontal%>
                                </td>
                            </tr>
                        </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td width="150" class="label"><%=strRenderOptions%></td>
                    <td class="inputField">
                        <table>
                            <tr>
                                <td>
                                    <input type="checkbox" name="draw3D" onclick="javascript:set3DValue()" />
                                    <%=str3D%>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>

			<% 
        if(showAdvancedLink){ 
%>

			  <table border="0" cellpadding="5" cellspacing="2" width="100%">
                <tr>
                    <td width="150"><img src="../common/images/utilSearchPlus.gif" width="15" height="15" align="texttop" border="0" id="imgMore" /><a href="#" onclick="javascript:toggleMore();return false;"><emxUtil:i18n localize="i18nId">emxFramework.Common.More</emxUtil:i18n></a></td>
                    <td>&nbsp;</td>
                </tr>
            </table>
<!-- start of added code for ContainedIn Functionality  -->

<%
			}
String containedInStr = "emxFramework.Common.ContainedIn";
%>
            <script type="text/javascript" language="JavaScript">
            var floatingDiv=null;
            var hiddenIFrame=null;
      function showAffectedItemSelector(){
      var sURL= "../common/emxSearch.jsp?formName=frmLifecycleDurationReport&containedInFlag=false&defaultSearch=AEFContainedInSearch";
      sURL = sURL + "&frameName=metricsReportContent&fieldNameActual=txtActualContainedIn";
      sURL = sURL + "&fieldNameDisplay=txtContainedIn&searchmode=chooser&suiteKey=Components";
      sURL = sURL + "&InclusionList=<%=XSSUtil.encodeForURL(context, strInclusionList)%>&SubmitURL=../common/emxObjectSelect.jsp&CancelButton=true&title=<%=containedInStr%>&containedInFieldType=txtContainedInType&containedInFieldRev=txtContainedInRev";
      sURL = sURL + "&selection=Single&showToolbar=false";
      showModalDialog(sURL,700,600);
    }
</script>

<!-- end of added code for ContainedIn Functionality  -->

 <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
        <!-- the following div MUST come just before closing form tag -->
        <div id="divMore" style="display:none"></div>

        </form>
    </div>
        <div id = "showPercentage" style = "visibility:hidden "><xss:encodeForHTML><%=strShowPercentage%></xss:encodeForHTML></div>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
