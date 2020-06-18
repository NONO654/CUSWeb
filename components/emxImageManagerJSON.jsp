  <%-- emxImageManagerJSON.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxImageManager.jsp.rca 1.2.2.5.1.5 Wed Jul  2 11:55:31 2008 msikhinam Experimental $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="javax.json.*"%>
<%@include file = "emxImageManager.inc"%>
<%
try{
	boolean skip3d = true;
	try{
		skip3d = "false".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.InPlaceImageManager.Skip3D")); 
	}catch(Exception e){
	}
	
	JsonArrayBuilder imageInfoListJSONBuilder = Json.createArrayBuilder();

	for(int i=0; i < imageInfoList.size(); i++){
		ImageManagerImageInfo imageInfo = (ImageManagerImageInfo) imageInfoList.get(i);
		if(skip3d && imageInfo.show3dImage()) continue;
		JsonObject imageInfoJSON = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder())
			.add("fileName",imageInfo.getImageName())
			.add("imageURL",imageInfo.getImageURL())
			.add("fileExtn",imageInfo.getFileExtension())
			.add("show3dImage",imageInfo.show3dImage())
			.add("thumbnailURL",imageInfo.getThumbnailURL())
			.add("imageIcon3d",imageInfo.get3dImageIcon())
			.add("fileBaseName",imageInfo.getFileBaseName())
			.add("checkBoxValue",imageInfo.getCheckBoxValue())
			.add("isPrimary", i == primaryImageIndex)
			.build();
		imageInfoListJSONBuilder.add(imageInfoJSON);
		
	}
	JsonObject imageData = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder())
		.add("images", imageInfoListJSONBuilder.build())


		.add("primaryImageIndex", primaryImageIndex)
		.add("hasModifyAccess", showCheckbox)
		.add("action", "success")
		.build();
	
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(imageData.toString());
}
catch(Exception ex){
	JsonObject output = Json.createObjectBuilder()

		.add("action", "error")
		.add("message", ex.getMessage())
		.build();

	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(output.toString());
}
%>
