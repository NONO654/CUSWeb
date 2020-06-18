var RTProxyDriver=undefined;var RTDriver=undefined;var RTSettingController=undefined;var webrtcCtrl=undefined;var swymURL1=undefined;function initialize(a){require(["DS/RTProxyDriver/RTProxyDriver"],function(b){console.log(" **********************************************\ninitialize\n user_id :"+a+"\n **********************************************\n");b.dispatch("CONNECTED",{user_id:a})})}function sendNotification(b,d){if(typeof CATCefSendString!=="undefined"){CATCefSendString(b+"="+d)}else{var a=document.createElement("textarea");a.setAttribute("name",b);a.appendChild(document.createTextNode(d));var c=document.createElement("form");c.setAttribute("method","POST");c.setAttribute("action","jsnotif://");c.appendChild(a);document.documentElement.appendChild(c);c.submit();c.parentNode.removeChild(c);c=null}}function iceCandidateReceived(c,a,b){require(["DS/RTProxyDriver/RTProxyDriver"],function(d){console.log(" **********************************************\nwebrtcIceCandidateReceived\n user_id :"+a+"\n room_id: "+c+"\ncandidate :"+b+"\n **********************************************\n");d.dispatch("webrtcIceCandidateReceived",{user_id:a,room_id:c,user:{user_id:a},candidate:{candidate:b}})})}function sdpReceived(b,h,f,g,e,a,d,i,c){require(["DS/RTProxyDriver/RTProxyDriver"],function(o){var j,l,k;if(e=="true"){j=true}else{if(e=="false"){j=false}}if(a=="true"){l=true}else{if(a=="false"){l=false}}if(d=="true"){k=true}else{if(d=="false"){k=false}}var n=g.replace(/##r/g,"\r");var m=n.replace(/##n/g,"\n");console.log(" **********************************************\nSDPReceived\n user.login :"+b+"\n user_id : "+h+"\n room_id : "+f+"\n SDP : "+m+"\n isCaller : "+j+"\n renegotiating : "+l+"\n secondSwitch : "+k+"\n SDPType : "+i+"\n user_from : "+c+"\n **********************************************\n");o.dispatch("SDPreceived",{user_id:h,room_id:f,sdp:{type:i,sdp:m},isCaller:j,user:{login:b,user_id:h},renegotiating:l,secondSwitch:k,userFrom:c})})}function incomingCallNotification(c,e,a,b,f,d){require(["DS/RTProxyDriver/RTProxyDriver"],function(g){g.dispatch("inviteToCall",{type:d,user_id:c,room_id:e,error:"",room:{room_id:e},user:{login:a,user_id:c,email:b,username:f}})})}function inviteSentNotification(c,f,a,b,g,e,d){require(["DS/RTProxyDriver/RTProxyDriver"],function(i){var h;if(d=="true"){h=true}else{if(d=="false"){h=false}}console.log(" **********************************************\ninviteSentNotification\n isCaller :"+h+"\n callType :"+e+"\n user_id :"+c+"\n room_id :"+f+"\n user_login :"+a+"\n user_username :"+g+"\n **********************************************\n");i.dispatch("inviteSent",{isCaller:h,type:e,user_id:c,room_id:f,error:"",room:{room_id:f},user:{login:a,user_id:c,email:b,username:g}})})}function callAccepted(c,i,b,d,e,a,f,j,h,g){require(["DS/RTProxyDriver/RTProxyDriver"],function(l){console.log(" **********************************************\ncallAccepted\n isCaller :"+k+"\n type : "+f+"\n user_id : "+a+"\n room_id : "+e+"\n STUN_URL : "+h+"\n TURN_URL : "+g+"\n user_login : "+c+"\n user_username : "+d+"\n **********************************************\n");var k;if(j=="true"){k=true}else{if(j=="false"){k=false}}l.dispatch("callAccepted",{isCaller:k,type:f,user_id:a,room_id:e,room:{room_id:e},user:{login:c,user_id:i,email:b,username:d},webrtcConfig:{iceServers:[{url:h},{url:g,username:"rtcoturn",credential:"rtcoturntigase"}]}})});webrtcCtrl.onCallComponents.addEventToView("minimizeNWAY",this.minimize);webrtcCtrl.onCallComponents.addEventToView("maximizeNWAY",this.maximize)}function minimize(){console.log("Inside Minimize");sendNotification("minimize")}function maximize(){console.log("Inside Maximize");sendNotification("maximize")}function callEnded(a,b){require(["DS/RTProxyDriver/RTProxyDriver"],function(c){console.log(" **********************************************\ncallEnded\n user_Id :"+a+"\n room_Id :"+b+"\n **********************************************\n");c.dispatch("callEnded",{user_id:a,room_id:b,room:{room_id:b},user:{user_id:a}})})}require(["DS/RTProxyDriver/RTProxyDriver"],function(a){this.endCallListener=(function(b){return function(d){console.log("inside end call listener");var c;var g=JSON.stringify(d);var f=JSON.parse(g);var e=f.reason;if(e==undefined){e=""}c=f.room_id+","+e;sendNotification("EndCall",c);console.log(" **********************************************\nendCallListener\n room_id :"+f.room_id+"\n **********************************************\n")}})(this);a.addEvent("endCall",this.endCallListener);this.callAcceptedListener=(function(b){return function(d){console.log("inside call Accepted listener");var c;var f=JSON.stringify(d);var e=JSON.parse(f);c=e.room_id+","+e.type+","+e.user_id;sendNotification("acceptCall",c);console.log(" **********************************************\ncallAcceptedListener\n room_id :"+e.room_id+"\n callType :"+e.type+"\n user_id :"+e.user_id+"\n **********************************************\n")}})(this);a.addEvent("acceptCall",this.callAcceptedListener);this.SDPListener=(function(b){return function(f){console.log("inside SDP listener");var c;var h=JSON.stringify(f);var g=JSON.parse(h);var e=g.renegotiating;var d=g.secondSwitch;if(e==undefined){e=false}if(d==undefined){d=false}c=g.user_id+","+g.room_id+","+g.sdp.sdp+","+g.isCaller+","+g.sdp.type+","+e+","+d;sendNotification("SDP",c);console.log(" **********************************************\nSDPListener\n room_id :"+g.room_id+"\n sdp :"+g.sdp.sdp+"\n user_id :"+g.user_id+"\nisCaller : "+g.isCaller+"\nsdpType : "+g.sdp.type+"\nrenegotiating : "+e+"\nsecondSwitch : "+d+"\n **********************************************\n")}})(this);a.addEvent("SDP",this.SDPListener);this.ICECandidateListener=(function(b){return function(e){console.log("inside ICE Candidate listener");var c;var g=JSON.stringify(e);var f=JSON.parse(g);var d=f.renegotiating;if(d==undefined){d=false}c=f.user_id+","+f.room_id+","+f.candidate.candidate+","+f.candidate.sdpMid+","+f.candidate.sdpMLineIndex+","+d;sendNotification("webrtcIceCandidate",c);console.log(" **********************************************\nICECandidateListener\n room_id :"+f.room_id+"\n user_id :"+f.user_id+"\ncandidate : "+f.candidate.candidate+"\nrenegotiating : "+d+"\n **********************************************\n")}})(this);a.addEvent("webrtcIceCandidate",this.ICECandidateListener)});var loadWidget=function(a,c,b){require(["DS/MessageBus/MessageBus","UWA/Drivers/Alone","DS/InstantMessagingWebRTC/InstantMessagingWebRTC","DS/RTProxyDriver/RTProxyDriver","DS/InstantMessagingWebRTC/js/view/RTCallingComponentView"],function(h,i,d,f,e){if(RTProxyDriver==undefined){RTProxyDriver=f}var g={appName:"",passportUrl:"",topBarId:"",messaging:undefined,userName:"",tenants:{},url:a,platformId:"",swymUrl:c,doLogRTC:false,ringtoneURL:b};webrtcCtrl=new d(g)})};if(typeof widget!="undefined"){widget.addEvent("onLoad",function(){var a=null;sendNotification("LoadWidget",a)});widget.addEvent("onRefresh",function(){document.location.reload()})}else{require(["UWA/Drivers/Alone"],function(b){var a=null;sendNotification("LoadWidget",a)})};