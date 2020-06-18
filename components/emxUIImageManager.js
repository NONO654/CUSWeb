//
// There can be one more variable 'ids' defined in parent window,
// we here, not using this variable so remove the value for this variable.
// This code is fix of bug 344433
//
var lastImg             = null;
var str3diconcode = null;
var currentImageIndex = 0;
var swfPlayerInstalled  = false;
var svgPlayerInstalled = false;


if (parent.ids) {
	parent.ids = null;
}

var ids = "~";

function checkToolbarStatus (objCheckbox)
{
    var strID = objCheckbox.value;
    if(objCheckbox.checked)
    {
        if (!ids) 
        {
            ids = "~";
        }
        if (ids.indexOf("~" + strID + "~") == -1) 
        {
            ids += strID + "~";
        }
    }
    else
    {
        var strTemp = ids;
        if (strTemp.indexOf("~" + strID + "~") > -1) 
        {
            strTemp = strTemp.replace(strID + "~", "");
            ids = strTemp;
        }
    }
    if (this.toolbars && this.toolbars.setListLinks) 
    {
        this.toolbars.setListLinks(ids.length > 1);
    }
}

function openPrinterFriendlyPage()
{
    window.print();
}

function detectPlugin(pluginName,pluginFailMessage)
{
    var xmlplugin=null;     
    try 
    {
        if(window.ActiveXObject)
        {                   
            xmlplugin = new ActiveXObject(pluginName);                  
        }
        else if(navigator.plugins.length > 0)
        {
            xmlplugin=navigator.plugins['Dassault Systemes 3D XML Plug-in'].name;               
        }
        else
        {
            alert(pluginFailMessage);
        }               
    }
    catch(e)
    {       
        //do nothing
    }       
    return xmlplugin;
}

function play3dxmlImage(path,divImage)
{
	divImage.innerHTML= "<object type='application/x-3dxmlplugin' id='Dassault Systemes 3D XML Player Plugin' width='100%' height='100%' style='MARGIN: 0px' border='0'><param name='DocumentFile' value='"+path+"' ></object>";
}

if (navigator.mimeTypes && navigator.mimeTypes.length)
{
	x = navigator.mimeTypes['application/x-shockwave-flash'];
    if (x && x.enabledPlugin)
    {
    	swfPlayerInstalled = true;
    }
}
else
{
	try
    {
    	var xmlplugin = new ActiveXObject("SWCtl.SWCtl");
        if(xmlplugin)
        {
        	swfPlayerInstalled = true;
		}
	}
    catch(e)
    {
    }
}

var isFF = Browser.FIREFOX;
if (isFF)
{
	svgPlayerInstalled = true;
}
else
{
	try
    {
    	var xmlplugin   = new ActiveXObject("Adobe.SVGCtl");
        if(xmlplugin)
        {
        	svgPlayerInstalled = true;
		}
	}
    catch(e)
    {
    }
}

function displaySVGFile(whichImage, backImage) {
	if(!backImage){
		backImage = window.backImage;
	}
	var imageURL = backImage[whichImage].imageURL;
	var divImage = document.getElementById("divImage");
	
	if(svgPlayerInstalled) {
		divImage.innerHTML= "<object data='"+ backImage[whichImage].imageURL +"' type='image/svg+xml' width='100%' height='100%' style='MARGIN: 0px' border='0'><param name=src value='"+backImage[whichImage].imageURL+"' ></object>";
    } else {
     	divImage.innerHTML = svgPluginFailMessage + "<br/><a target='_blank' href='http://www.adobe.com/svg/viewer/install/old.html'>" + "<emxUtil:i18n localize='i18nId'>emxComponents.svg.svgPlayerDownload</emxUtil:i18n>" + "</a>";
    }
}

function displaySWFFile(whichImage, backImage) {
	if(!backImage){
		backImage = window.backImage;
	}
	var imageURL = backImage[whichImage].imageURL;
	var divImage = document.getElementById("divImage");
	
	if(svgPlayerInstalled) {
		divImage.innerHTML= "<object data='"+backImage[whichImage].imageURL+"' type='application/x-shockwave-flash' width='100%' height='100%' style='MARGIN: 0px' border='0'><param name=src value='"+backImage[whichImage].imageURL+"' ></object>";		
    } else {
		divImage.innerHTML = swfPluginFailMessage + "<br/><a target='_blank' href='http://www.adobe.com/shockwave/download/'>" + "<emxUtil:i18n localize='i18nId'>emxComponents.swf.swfPlayerDownload</emxUtil:i18n>" + "</a>";     	
    }
}

function open3dxml(whichImage, backImage) {
	if(!backImage){
		backImage = window.backImage;
	}
    var imageURL = backImage[whichImage].imageURL;
    var divImage = document.getElementById("divImage");
    divImage.innerHTML ="";
    
	/*
		IR-485222-3DEXPERIENCER2018x
		3dplay annotaion issue.
		Added iframe to override default styling. 
	*/
    	var iframe = document.createElement('iframe');
    	iframe.frameBorder=0;
    	iframe.width="100%";
    	iframe.height="100%";
    	iframe.id="divImageFrame";
    	document.getElementById("divImage").appendChild(iframe);
			
    		if(backImage[whichImage].physicalId == ''||typeof backImage[whichImage].physicalId=='undefined' ||backImage[whichImage].physicalId==null) {
    			
     		      document.getElementById('divImageFrame').src = "\emxImageManager3DPlayFrame.jsp?isUrl=true&filename="+encodeURI(imageURL);

    		
    	   }else {
        		   
        		   document.getElementById('divImageFrame').src = "\emxImageManager3DPlayFrame.jsp?physicalid="+backImage[whichImage].physicalId+"&dType="+backImage[whichImage].dType+"&isUrl=false"+"&serverUrl="+encodeURI(backImage[whichImage].serverUrl);
        		   
}
    		
    	
    
}



function changeBGImage(whichImage, backImage) {
	if(!backImage){
		backImage = window.backImage;
	}
	var ext = backImage[whichImage].fileExtn.toLowerCase();
    if(ext == "svg") {
		displaySVGFile(whichImage, backImage);
     } else if(ext == "swf"){
		displaySWFFile(whichImage, backImage);
     } else if(ext == "3dxml" || ext == "cgr") {
    	 	if(getTopWindow().isMobile || (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().isMobile)){
    	 		  var divImage = document.getElementById("divImage");
    	 		  divImage.innerHTML = emxUIConstants.UnSupportedContentMsg;
    	 	}else{
        	open3dxml(whichImage, backImage);
    	 	}
     } else {
	     var imageURL = backImage[whichImage].imageURL;
	     var divImage = document.getElementById("divImage");
     	 divImage.innerHTML = "<img src='"+backImage[whichImage].imageURL+"' border='0' name='product' id='product'>";
     }	

     var imgClick    = document.getElementById("img"+whichImage);
     if(lastImg!=null) {
     	lastImg.style.borderColor="";
     }
     if(imgClick != null && imgClick != 'undefined') {
         imgClick.style.borderColor="#D00";
     }
     lastImg = imgClick;
}



function chgImg(direction) {
    var ImgNum      = currentImageIndex;
    var ImgCount    = backImage.length;
	if (document.images) {
		if (ImgNum==0 && direction == -1) {
        	ImgNum   = ImgCount-1;
        } else if (ImgNum == ImgCount-1 && direction != -1) {
        	ImgNum   = 0;
		} else {
        	ImgNum   = ImgNum + direction;
		}
	}
	if(backImage.length != 0) {
    	showImage(ImgNum);
    }        
}
    
function showImage(index) {
	if(!(backImage.length == 0 || index == -1)) {
		//set currentImageIndex
		currentImageIndex = index;
		changeBGImage(index);
	}
}

function adjustImageStyles() {
	var phd = document.getElementById("pageHeadDiv");
	var dpb = document.getElementById("divPageBody");
	if(phd && dpb){
		var ht = phd.clientHeight;
		if(ht <= 0){
			ht = phd.offsetHeight;
		}
		dpb.style.top = ht + "px";
	}	
	if(backImage.length <= 0)
		return;
	adjustThumbnailImgWidth();
	adjustThumbnailTableWidth();
	adjustPageFootTDButtonsWidth();
	adjustDivImageWidth();
}

function adjustWidthFromThubmbnailsTable(element, incValue) {
	if(element)
	element.style.width = (document.getElementById("thubmbnailsTable").offsetWidth + incValue)+  "px";
}
function adjustThumbnailTableWidth() {
	adjustWidthFromThubmbnailsTable(document.getElementById("divThumbnails"), 26);
}

function adjustPageFootTDButtonsWidth() {
	adjustWidthFromThubmbnailsTable(document.getElementById("tdButtons"), 26);
}

function adjustDivImageWidth() {
	var element = document.getElementById("divImage");
	var incValue = 26;
	element.style.right = (document.getElementById("thubmbnailsTable").offsetWidth + incValue)+  "px";	
}

function adjustThumbnailImgWidth() {
	var standardImageWidth = document.getElementById("img0").height + 20;
	for(var i = 0; i < backImage.length; i ++) {
		var imgClick    = document.getElementById("img" + i);
		var imageWidth = imgClick.width;
		if(imageWidth > standardImageWidth) {
			imgClick.width = standardImageWidth;  
		}
	}
	document.getElementById("tdthumbnail").style.width = standardImageWidth;
}

