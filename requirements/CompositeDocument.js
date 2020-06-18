function isNodeCollapsed(m1Node)
{
	if(m1Node.expandStatus && m1Node.expandStatus=='min'){
		return true;
	}
	return false;
}


/**
 * event handler to expand/collapse a M1 node
 *
 */

function flipNode(e){
	var event = e? e : window.event;
	var clpbox = event.srcElement? event.srcElement : event.target;
	var listNode = clpbox.parentNode.parentNode;
	if(listNode){
		if(isNodeCollapsed(listNode)){ //expand
			expandNode(listNode, clpbox);
		}else{ //collpase
			collpaseNode(listNode, clpbox);
		}
	}
	cancelEventBubble(event);
}

/**
 * Collapse a M1 node
 *
 */

function collpaseNode(node, clpbox)
{	
	if(node && clpbox && !isNodeCollapsed(node))
	{
		node.expandStatus = 'min'; //record current expand status
	    var children = getChildrenOtherThanTitlebar(node);
	   	for(var n = 0; n < children.length; n++){
	    	children[n].style.display = 'none';
	    }
	    
		clpbox.className = 'expbox'; //change the link image
	}

}

/**
 * Expand a M1 node
 *
 */

function expandNode(node, clpbox)
{
	if(!clpbox){
		clpbox = getMinbox(node);
	}
	if(node && clpbox && isNodeCollapsed(node)){
		node.expandStatus = 'std'; //record current expand status
		//node.style.height = "auto";
	    var children = getChildrenOtherThanTitlebar(node);
	   	for(var n = 0; n < children.length; n++){
	    	children[n].style.display = '';
	    }

		clpbox.className = 'clpbox'; //change the link image

	}
}
function getChildrenOtherThanTitlebar(m1Node)
{
	var children = new Array();
	for(var n = 0; n < m1Node.childNodes.length; n++){
		//to avoid problems in firefox (with blanks)
		if(m1Node.childNodes[n].nodeName !=  'H3' ){
			children[children.length] = m1Node.childNodes[n];
		}
	}
	return children;
}

function cancelEventBubble(e)
{
	if(e.stopPropagation){
		e.stopPropagation();
	}
	e.cancelBubble = true;
}

//JX5 start IR-375534-V6R2013x
//JX5 start base64 decoding
var Base64 = {}; // Base64 namespace

Base64.code = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

/**
* Decode string from Base64, as defined by RFC 4648 [http://tools.ietf.org/html/rfc4648]
* (instance method extending String object). As per RFC 4648, newlines are not catered for.
*
* @param {String} str The string to be decoded from base-64
* @param {Boolean} [utf8decode=false] Flag to indicate whether str is Unicode string to be decoded 
*   from UTF8 after conversion from base64
* @returns {String} decoded string
*/ 
Base64.decode = function(str, utf8decode) {
utf8decode =  (typeof utf8decode == 'undefined') ? false : utf8decode;
var o1, o2, o3, h1, h2, h3, h4, bits, d=[], plain, coded;
var b64 = Base64.code;

coded = utf8decode ? Utf8.decode(str) : str;

for (var c=0; c<coded.length; c+=4) {  // unpack four hexets into three octets
  h1 = b64.indexOf(coded.charAt(c));
  h2 = b64.indexOf(coded.charAt(c+1));
  h3 = b64.indexOf(coded.charAt(c+2));
  h4 = b64.indexOf(coded.charAt(c+3));
    
  bits = h1<<18 | h2<<12 | h3<<6 | h4;
    
  o1 = bits>>>16 & 0xff;
  o2 = bits>>>8 & 0xff;
  o3 = bits & 0xff;
  
  d[c/4] = String.fromCharCode(o1, o2, o3);
  // check for padding
  if (h4 == 0x40) d[c/4] = String.fromCharCode(o1, o2);
  if (h3 == 0x40) d[c/4] = String.fromCharCode(o1);
}
plain = d.join('');  // join() is far faster than repeated string concatenation in IE

return utf8decode ? Utf8.decode(plain) : plain; 
}
//JX5 End base64 decoding

function onLoadXMLReport(e){
	
	window.addEventListener("DOMContentLoaded", function(event) { 
		
		//decode content text field if applicable
		var contentFields = document.getElementsByClassName('content');
		for(var i=0; i < contentFields.length; i++){
			var contentField = contentFields[i];
			var content = contentField.getElementsByTagName('pre');
			if(content.length != 0){
				content[0].innerHTML = Base64.decode(content[0].innerHTML);
			}
		}
		//
	});
			




}
//JX5 end IR-375534-V6R2013x 
