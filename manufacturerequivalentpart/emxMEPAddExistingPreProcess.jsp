<%--
  emxMEPAddExistingPreProcess.jsp

   Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPAddExistingPreProcess.jsp 1.1.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="java.util.*"%>
<%@page import="matrix.util.*"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.manufacturerequivalentpart.Part"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<% 
   boolean isError=false;
try{
   String timeStamp = emxGetParameter(request, "timeStamp");
   String strObjectId=emxGetParameter(request,"objectId");
   String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
   Part part = new Part(strObjectId);
   String placeholderMEP = emxGetParameter(request, "placeholderMEP");
   boolean alreadyConnected = false;
   String mode = emxGetParameter(request, "mode");
   String mepAddExisting = "";
   if(mode==null || mode.length()==0){
	   HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
	   mepAddExisting=(String)requestMap.get("mepAddExisting");
   }
   StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] ,"|");

	//Extracting the Object Id from the String.
    String idsToConnect = "";//FrameworkUtil.join(strTableRowIds, ",");
	Object objToConnectObject = strTokenizer.nextElement();
    idsToConnect = objToConnectObject.toString();
    

   if("true".equals(mepAddExisting)){
              if(placeholderMEP!=null && !"null".equalsIgnoreCase(placeholderMEP) && !"".equalsIgnoreCase(placeholderMEP)) {
                  DomainObject dom = new DomainObject(strObjectId);  //MPN Object
           String locationId = dom.getInfo(context,"to["+DomainConstants.RELATIONSHIP_ALLOCATION_RESPONSIBILITY+"].from.id");
           String meId = dom.getInfo(context,"to["+DomainConstants.RELATIONSHIP_MANUFACTURER_EQUIVALENT+"].from.id");

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
             if ((strTableRowIds[0]).equals(Id)) {
                 alreadyConnected = true;
                 break;
             }
           }
           if(!alreadyConnected) {

               //Remove the MPN Object
               dom.deleteObject(context);

                //Connect Location with selected MEP
               part.setId(strTableRowIds[0]);
               StringList sl = part.getInfoList(context, "to["+DomainConstants.RELATIONSHIP_ALLOCATION_RESPONSIBILITY+"].from.id");
               if(!sl.contains(locationId)) {
                   part.addLocations(context, locationId, " ");
               }
           }
           strObjectId = meId;
            //Connect MEP Part and MEP with Manufacturer Equivalent

              }
 part.setId(strObjectId);
part.addManufacturerEquivalentParts(context, strTableRowIds);
   }else{
   part.addLocations(context,idsToConnect,",");
   }
   /*StringBuffer whereClause = new StringBuffer("(id matchlist \'");
   whereClause.append(idsToConnect);
   whereClause.append("\' \',\')");
   MapList resultMapList = domObj.getRelatedObjects(context,
                                                    reltype,
                                                        "*",
                                                       null,
                                                       null,
                                                       true,
                                                       true,
                                                  (short) 1,
                                     whereClause.toString(),
                                                      null);
    if(resultMapList.size()>0){
        isAlreadyConnected=true;
    }
    
    if(isAlreadyConnected){
       throw new Exception("Some Objects are already connected");
    }else{
    if("true".equals(strIsFrom)){
    DomainRelationship.connect(context,domObj,reltype,true,strTableRowIds);
    }else{
    DomainRelationship.connect(context,domObj,reltype,false,strTableRowIds);
    }
    }*/
}catch(Exception ex){
    //isError=true;
    session.putValue("error.message", ex.getMessage());
    ex.printStackTrace();
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript">
   //top.getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
   getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
   getTopWindow().closeWindow();
</script>

