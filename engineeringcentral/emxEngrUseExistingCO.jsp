<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%

	
    String objectId = emxGetParameter(request, "partId");
    String sChangeId = emxGetParameter(request, "CAId");
    String sCOId = emxGetParameter(request, "COId");
    
    HashMap hmArgs = new HashMap();
	hmArgs.put("CAId",sChangeId);
	hmArgs.put("COId",sCOId);
	hmArgs.put("partId",objectId);
	JPO.invoke(context,"enoBGTPManager",null,"createItemMarkupAndApproveForAlreadyConnectedChange",JPO.packArgs(hmArgs),void.class);    
   
   %>
