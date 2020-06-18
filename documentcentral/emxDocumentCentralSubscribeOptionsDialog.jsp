<%--  emxTeamSubscribeWorkspaceOptionsDialog.jsp

    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of  MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: Frameset Page for Subscription

    Author     : Neaz Faiyaz
    Date       : 04/02/2003
    History    :

    static const char RCSID[] = $Id: emxDocumentCentralSubscribeOptionsDialog.jsp.rca 1.20 Wed Oct 22 16:02:41 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="subBean"
             scope="page"
             class="com.matrixone.apps.library.SubscriptionBean"/>

<%
    String targetLocation   = emxGetParameter(request,"targetLocation");
%>
<script language="javascript">

  function submitForm()
  {
    var sAllIds = "";

    for( var i = 0; i < document.formEvents.elements.length; i++ )
    {
      if((document.formEvents.elements[i].type == "checkbox")
          && (!document.formEvents.elements[i].checked)
          && (document.formEvents.elements[i].name == "chkUnSubscribeEvent") )
      {
            sAllIds += document.formEvents.elements[i].value + ";";
      }
    }

    document.formEvents.sUnsubscribedEventIds.value = sAllIds;
    if(jsDblClick())
    {
      document.formEvents.submit();
    }
    return;
  }

  function closeWindow()
  {
    if("slidein" == "<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>") {
        getTopWindow().closeSlideInDialog();
    } else {
        parent.closeWindow();
    }

    return;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    //Get ObjectID passed in

    String objectIdString   = emxGetParameter(request, "objectIdString");
    StringTokenizer st      = new StringTokenizer(objectIdString,",");
    String sObjId           = "";

    while(st.hasMoreTokens())
    {
        sObjId   = st.nextToken();
    }

    //Get Language Setting
    String strLang          = request.getHeader("Accept-Language");
    TreeMap projectMap      = new TreeMap();
    DomainObject objTemp  = new DCWorkspaceVault(sObjId);
    StringList subEvents    = ((Subscribable)objTemp).getSubscribableEvents(context);
    for( int i = 0; i < subEvents.size(); i++ )
    {
        String key              = (String)subEvents.elementAt(i);
        StringBuffer tempBuffer = new StringBuffer(key);
        String spaceToBeReplacedWith = "" ;
        int index = 0;
        while( ( index = tempBuffer.toString().indexOf( " " )) != -1 )
        {
               tempBuffer = tempBuffer.replace( index, index + 1, spaceToBeReplacedWith) ;
        }
        String value = EnoviaResourceBundle.getProperty(context, "emxLibraryCentralStringResource", new Locale(strLang),"emxLibraryCentral.EventFrmwrk."  + tempBuffer.toString());
        projectMap.put(key, value);
    }
%>
    <img src="images/utilSpace.gif" width=1 height=8>

    <form name="formEvents" method="post" action="emxDocumentCentralSubscribeOptions.jsp">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.PublishSubscribeSummary.AlertEvents</emxUtil:i18n></td>
          <td class="inputField">
            <table border="0">
              <tr>
                <td class="field">
<%
    //Create a TreeMap of all events, and list both events with checkboxes
    //checked/unchecked
    TreeMap hashSubEvt = new TreeMap();

    if(new StringTokenizer(objectIdString,";").countTokens()==1)
    {
       hashSubEvt   = subBean.getAllObjectEvents(context, sObjId);
    }


    java.util.Set hashSubEvntKeys = hashSubEvt.keySet();
    Iterator itEvents = hashSubEvntKeys.iterator();

    String sKeyRemoveStr = "";

    while (itEvents.hasNext())
    {
        sKeyRemoveStr       = (String) itEvents.next();
        String displayString= (String)projectMap.get(sKeyRemoveStr);
        if(displayString == null || "".equals(displayString))
        {
          displayString = sKeyRemoveStr;
        }
%>
                  <input type="checkbox" value="<xss:encodeForHTML><%=hashSubEvt.get(sKeyRemoveStr)%></xss:encodeForHTML>" name="chkUnSubscribeEvent" checked />
                    <xss:encodeForHTML><%=displayString%></xss:encodeForHTML><br>
<%
        projectMap.remove(sKeyRemoveStr);
    }

    java.util.Set projectKeys = projectMap.keySet();
    Iterator it = projectKeys.iterator();
    String sKeyStr = "";

    while (it.hasNext())
    {
        sKeyStr = (String) it.next();
        String displayString=(String)projectMap.get(sKeyStr);
        if(displayString==null || "".equals(displayString))
        {
          displayString=sKeyStr;
        }

%>
                  <input type=checkbox  value="<xss:encodeForHTML><%=sKeyStr%></xss:encodeForHTML>"  name=chkSubscribeEvent /><xss:encodeForHTML><%=displayString%></xss:encodeForHTML><br>
<%
    }
%>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>

      <input type="hidden" name="objectIdString" value="<xss:encodeForHTMLAttribute><%=objectIdString%></xss:encodeForHTMLAttribute>" />
      <input type=hidden name="sUnsubscribedEventIds" value="" />
      <input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%=targetLocation%></xss:encodeForHTMLAttribute>" />

    </form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
