<%--  emxPageHistoryProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPageHistorySessionProcess.jsp.rca 1.2.1.5 Wed Oct 22 15:48:03 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@page import  = "com.matrixone.apps.domain.util.*"%>

<%
String strMode = emxGetParameter(request, "mode");
String strAction = emxGetParameter(request, "action");
String strForwardCmdCnt = emxGetParameter(request, "forwardCmdCnt");
int intForwardCmdCnt = 0;
if(strForwardCmdCnt != null && strForwardCmdCnt.trim().length()>0){
	intForwardCmdCnt = Integer.parseInt(strForwardCmdCnt);
}
MapList backHistoryList = (MapList)session.getAttribute("AEF.backHistory");
MapList forwardHistoryList = (MapList)session.getAttribute("AEF.forwardHistory");
if(strMode != null){
	if(strMode.equalsIgnoreCase("backHistory")){
			if(strAction != null && strAction.equalsIgnoreCase("removeLast")){
				if(backHistoryList != null && backHistoryList.size()>0){
					backHistoryList.remove(backHistoryList.size()-1);
				}
			} else if (strAction != null && strAction.equalsIgnoreCase("goBack")){
				String strdepth = emxGetParameter(request, "depth");
				int intDepth = 0;
				if(strdepth != null){
					try{
						intDepth = Integer.parseInt(strdepth);
					} catch (NumberFormatException ex){
						//do nothing
					}
				}
				if(backHistoryList != null && backHistoryList.size()>0){
					if(forwardHistoryList == null){
						forwardHistoryList = new MapList();
						session.setAttribute("AEF.forwardHistory",forwardHistoryList);
					}
					for(int i=0,j=backHistoryList.size()-1; (i<intDepth && j>=0); i++,j--){
						forwardHistoryList.add((HashMap)backHistoryList.remove(j));
						if(intForwardCmdCnt<forwardHistoryList.size()){
							forwardHistoryList.remove(0);
						}
					}
				}
			}
	} else if (strMode.equalsIgnoreCase("forwardHistory")){
			if(strAction != null && strAction.equalsIgnoreCase("goForward")){
				String strdepth = emxGetParameter(request, "depth");
				if(forwardHistoryList != null && forwardHistoryList.size()>0 && backHistoryList != null){
					int intDepth = 0;
					if(strdepth != null){
						try{
							intDepth = Integer.parseInt(strdepth);
						} catch (NumberFormatException ex){
							//do nothing
						}
					}
					for(int i=0,j=forwardHistoryList.size()-1; (i<intDepth && j>=0); i++,j--){
						backHistoryList.add((HashMap)forwardHistoryList.remove(j));
					}
				}
			}//end Go forward
      else if(strAction != null && strAction.equalsIgnoreCase("removeAll")){
        // To clear the forward list maintained in session when the user navigates 
        // to new page in the application
        if(forwardHistoryList != null && forwardHistoryList.size()>0){
          forwardHistoryList.clear();
          session.setAttribute("AEF.forwardHistory",forwardHistoryList);
        }
      }//end Clear the forward list       
	}//end forwardHistory
}
%>
