var lastImg=null;
 var backImage = new Array();
function changeBGImage(whichImage){
var theImage=document.getElementById("product");
var theLabel=document.getElementById("label");
if(theImage != null && theImage != 'undefined') {
	theImage.src = backImage[whichImage];
}
///
var imgClick = document.getElementById("img"+whichImage);
if(lastImg!=null){
	lastImg.style.borderColor="rgb(188,188,188)";
}
if(imgClick != null && imgClick != 'undefined') {
	imgClick.style.borderColor="rgb(255,0,0)";
}
lastImg = imgClick;
//document.body.focus();
}
