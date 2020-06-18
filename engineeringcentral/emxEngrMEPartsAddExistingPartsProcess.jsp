<%-- emxEngrMEPartsAddExistingPartsProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIActionbar.js"></script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
    String objectId = emxGetParameter(request, "objectId");
    String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");

	//When parts are displayed in custom jsp
    if(selPartIds == null) {
        selPartIds = emxGetParameterValues(request, "checkBox");
    }
    selPartIds = selPartIds[0].split("\\|");
    selPartIds = new String[]{selPartIds[1]};

    String placeholderMEP = emxGetParameter(request, "placeholderMEP");
    boolean alreadyConnected = false;
    Part part = (Part)DomainObject.newInstance(context,
                           DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

%>
    <%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%
      try {
		  ContextUtil.pushContext(context);
        if(placeholderMEP!=null && !"null".equalsIgnoreCase(placeholderMEP) && !"".equalsIgnoreCase(placeholderMEP)) {
            //Getting Location info
           DomainObject dom = new DomainObject(objectId);  //MPN Object
           String locationId = dom.getInfo(context,"to["+DomainConstants.RELATIONSHIP_ALLOCATION_RESPONSIBILITY+"].from.id");
           String meId = dom.getInfo(context,"to["+DomainConstants.RELATIONSHIP_MANUFACTURER_EQUIVALENT+"].from.id");

           //Check the selected part is already connected or not.
           part.setId(meId);
           StringList selectStmts = new StringList(1);
           StringList selectRelStmts = new StringList (1);
           selectStmts.add(DomainConstants.SELECT_ID);
           selectRelStmts.add(DomainRelationship.SELECT_ID);
           MapList mepList = part.getManufacturerEquivalents(context,selectStmts,selectRelStmts);
           Iterator itr = mepList.iterator();
           while (itr.hasNext()) {
             Map map = (Map) itr.next();
             String Id = (String)map.get(DomainConstants.SELECT_ID);
             if ((selPartIds[0]).equals(Id)) {
                 alreadyConnected = true;
                 break;
             }
           }

           if(!alreadyConnected) {

               //Remove the MPN Object
               dom.deleteObject(context);

                //Connect Location with selected MEP
               part.setId(selPartIds[0]);
               StringList sl = part.getInfoList(context, "to["+DomainConstants.RELATIONSHIP_ALLOCATION_RESPONSIBILITY+"].from.id");
               if(!sl.contains(locationId)) {
                   part.addLocations(context, locationId, " ");
               }
           }
           objectId = meId;
            //Connect MEP Part and MEP with Manufacturer Equivalent
        }

        part.setId(objectId);
        part.addManufacturerEquivalentParts(context, selPartIds);
       }catch(Exception ex) {
%>
          <%@include file = "emxEngrAbortTransaction.inc"%>
<%
          session.putValue("error.message", ex.getMessage());
       }
       finally
       {
		   ContextUtil.popContext(context);
	   }
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%@include file = "emxDesignBottomInclude.inc"%>

<script language="Javascript">
  getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
  getTopWindow().closeWindow();

</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
