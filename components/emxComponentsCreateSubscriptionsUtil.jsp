<%-- emxComponentsCreateSubscriptionUtil.jsp

  Util page for the Components.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCreateSubscriptionsUtil.jsp.rca 1.6 Wed Oct 22 16:17:55 2008 przemek Experimental przemek $

--%>

<%@include file="emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%
    
    /* String variable to get the mode */
       String mode = (String) emxGetParameter(request, "mode")==null? "":(String) emxGetParameter(request, "mode");
try {
        if(mode.equals("Subscribe")) {
            String selectedEvents=emxGetParameter(request,"selectedEvents");
            String UnselectedEvents=emxGetParameter(request,"UnselectedEvents");
            String SpecificationOrSpecTemplateId=emxGetParameter(request,"objectId");
            com.matrixone.apps.common.DiscussionEvent discussion = null;
            discussion = new com.matrixone.apps.common.DiscussionEvent();
	    discussion.setId(SpecificationOrSpecTemplateId);
            com.matrixone.apps.common.Person contextPerson = null;
            contextPerson = com.matrixone.apps.common.Person.getPerson(context);
            StringTokenizer st,unselectedst=null;
            String event,autoNamePubSubscribe="";
            String autoNameEvent,eventResult,personId="";
            String result,eventExists,unSubResult="";
            boolean flag=true;
            st= new StringTokenizer(selectedEvents,";");
            unselectedst= new StringTokenizer(UnselectedEvents,";");
            while (st.hasMoreElements()) {
                event=st.nextToken();
                 result=discussion.getPublishSubscribe(context,SpecificationOrSpecTemplateId);
                if (result==null) {
                    autoNamePubSubscribe = FrameworkUtil.autoName(context,"type_PublishSubscribe","policy_PublishSubscribe");                   
                    flag=discussion.connectPublishSubscribe(context,autoNamePubSubscribe,SpecificationOrSpecTemplateId);
                    result=autoNamePubSubscribe;
                }

                eventExists=discussion.ifEventExists(context,event,result);
                if(eventExists==null) {
                        autoNameEvent = FrameworkUtil.autoName(context,"type_Event","policy_Event");
                        eventResult=discussion.createEvent(context,autoNameEvent,event);

                } else {
                     eventResult=discussion.createEvent(context,eventExists,event);
                     autoNameEvent=eventExists;
                }
                    
                boolean eventConnect=discussion.connectEvent(context,result,autoNameEvent);
                personId=contextPerson.getId();
                boolean personConnect=discussion.connectPerson(context,autoNameEvent,personId);
            }
            event="";
            autoNamePubSubscribe="";         
            autoNameEvent="";
            eventResult="";
            unSubResult="";
            personId="";
            flag=true;                              
            while (unselectedst.hasMoreElements()) 
                {
                event=unselectedst.nextToken();
                unSubResult=discussion.unsubscribeEvents(context,event,SpecificationOrSpecTemplateId);
                }
        } else     if(mode.equals("SubscriptionRemove")){
            String selectedEvents=emxGetParameter(request,"selectedEvents");
            String UnselectedEvents=emxGetParameter(request,"UnselectedEvents");
            String SpecificationOrSpecTemplateId=emxGetParameter(request,"objectId");
            com.matrixone.apps.common.DiscussionEvent discussion = null;
            discussion = new com.matrixone.apps.common.DiscussionEvent();

            com.matrixone.apps.common.Person contextPerson = null;
            contextPerson = com.matrixone.apps.common.Person.getPerson(context);

        
                String[] a=emxGetParameterValues(request,"emxTableRowId");
                int len=a.length;
                for(int i=0;i<len;i++)
                    {
                    discussion.unSubscribe(context,emxGetParameter(request,a[i]));
                    }
        }


  } catch (Exception e) {
      session.putValue("error.message", e.getMessage());
  }

 %>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<!--            Javascript files   -->

	<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<!--            Javascript methods     -->

  <script language="javascript" type="text/javaScript">
    <!-- hide JavaScript from non-JavaScript browsers


	var mode = "<%= XSSUtil.encodeForJavaScript(context, mode)%>";

	if (mode == "SubscriptionRemove") {
			refreshTablePage();
        } else if (mode == "Subscribe") {
           window.closeWindow();
		}
		
   // Stop hiding here -->//]]>
  </script>
<!--  End of Javascript methods    -->
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
