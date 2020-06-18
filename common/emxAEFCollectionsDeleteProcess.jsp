<%--  emxCollectionDeleteProcess.jsp   -  The process page for deleting a
      collection.

   Copyright (c) 199x-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAEFCollectionsDeleteProcess.jsp.rca 1.12 Tue Oct 28 22:59:40 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="java.util.Locale"%>

<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String sCollections = emxGetParameter(request, "Collections"); 
    String sDeleteMembers = emxGetParameter(request, "deleteRadio");
    boolean deleteMembers = false;
    if (sDeleteMembers.equals("true")) {
        deleteMembers = true;
    }
    String sCharSet = Framework.getCharacterEncoding(request);
    StringTokenizer stok = new StringTokenizer(sCollections,"|",false);
    boolean bSuccess = true;

    ContextUtil.startTransaction(context, true);
    while(stok.hasMoreTokens()) {
    	String sCollectionId = stok.nextToken();
        String sCollectionName = SetUtil.getCollectionName(context,sCollectionId);
        // Commented for bug no 346725
        //sCollectionName = FrameworkUtil.decodeURL(sCollectionName,sCharSet);
        // End
        try {
            //Start Bug 363945-Remove members of Type "Person" from Set,as Person cannot be deleted using Collections
            
            SelectList selects = new SelectList();
            selects.add(DomainObject.SELECT_ID);
            selects.add(DomainObject.SELECT_TYPE);
            MapList resultList= SetUtil.getMembers(context,sCollectionName,selects);
           
                      
          	Iterator memberItr = resultList.iterator();
          
         	 while (memberItr.hasNext()){              
               	    HashMap memberMap = (HashMap)memberItr.next();
               	    String memberType=(String)memberMap.get("type");
               
               if (memberType.equals(DomainConstants.TYPE_PERSON)){
                   SelectList ids=new SelectList();
                   ids.add((String)memberMap.get("id"));
                   SetUtil.removeMembers(context,sCollectionName,ids,false);
               }
          }
           
            // End of Bug 363945         
            
            SetUtil.delete(context, sCollectionName, deleteMembers);
        }catch(MatrixException me) {
            ContextUtil.abortTransaction(context);
			
			String errMsg = me.toString();

				if(UIUtil.isNotNullAndNotEmpty(errMsg) && errMsg.contains("1500028")){
					
				String msg = me.getMessage();
				String strSingleQuote="'";	
				String strObjNames="";		
					if(UIUtil.isNotNullAndNotEmpty(msg) && msg.contains(strSingleQuote)){
						int fromInd=msg.indexOf(strSingleQuote);
						int toInd=msg.indexOf(strSingleQuote,fromInd+1);
						strObjNames=strObjNames+msg.substring(fromInd+1,toInd);
					}
					String[] messageValues= new String[]{strObjNames};
					errMsg = com.matrixone.apps.domain.util.MessageUtil.getMessage(context,null,
																							"emxFramework.Error.NoDisconnectAccess",
																							messageValues,null,
																							new Locale(context.getSession().getLanguage()),"emxFrameworkStringResource");
			}
			
            emxNavErrorObject.addMessage(errMsg);
            bSuccess = false;
            break;
        }
    }
    if(bSuccess == true) {
        ContextUtil.commitTransaction(context);
    }
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<script language="Javascript">
    var tabFrame = findFrame(getTopWindow().getWindowOpener().parent, "listDisplay");
    if(tabFrame == 'undefined' || tabFrame == null){
    	tabFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "AEFCollections");
    }
    if(tabFrame != 'undefined' && tabFrame != null) {
        tabFrame.document.location.href = tabFrame.document.location.href;
    }else {
        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
    }
    getTopWindow().closeWindow();
    getTopWindow().getWindowOpener().getTopWindow().refreshShortcut();
    
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
