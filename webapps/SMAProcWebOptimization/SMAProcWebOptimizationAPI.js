define("DS/SMAProcWebOptimization/SMAProcWebOptimizationAPI",["DS/JSCMM/SMAJSCMMProperty","DS/SMAProcWebCMMUtils/SMAJSCMMUtils"],function(b,c){var a={readConfiguration:function(l,m){try{if(false==this.isValidAdapter(l)){return}}catch(h){console.warn("Unsupported optimization configuration");throw (h)}var q=l.getPropertyByName("Design Parameters");if(q===undefined||q===null){return}var j=q.getProperties();if(!j||j.length<3){throw"Unable to read Optimization configuration. \n 					Not able to find design variables and objectives properties \n 					Check your base Optimization configuration and technique selection";return}var k,o,u;for(var x=0;x<j.length;x++){var v=j[x];var t=v.getName();if(t.toLowerCase()==="design variable"){k=v}else{if(t.toLowerCase()==="objective"){o=v}else{if(t.toLowerCase()==="output constraint"){u=v}}}}if(!k||!o||!u){throw"Unable to read Optimization configuration. \n 					Not able to find design variables and objectives properties \n 					Check your base Optimization configuration and technique selection";return}var i=k.getProperties();m.factors=[];for(var d=0;d<i.length;d++){var r=i[d];if(!r){continue}var g=r.findPropertyByName("Name",false);if(!g){continue}var z=g.getValue();m.factors.push(z)}var w=o.getProperties();m.responses=[];for(var s=0;s<w.length;s++){var y=w[s];if(!y){continue}var g=y.findPropertyByName("Name",false);if(!g){continue}var z=g.getValue();m.responses.push(z)}var f=u.getProperties();m.constraints=[];for(var p=0;p<f.length;p++){var e=f[p];if(!e){continue}var g=e.findPropertyByName("Name",false);if(!g){continue}var z=g.getValue();m.constraints.push(z)}return m},modifyConfiguration:function(m,o){try{if(false==this.isValidAdapter(m)){return}}catch(i){console.warn("Unsupported optimization configuration");throw (i)}var s=m.getPropertyByName("Design Parameters");if((s===undefined||s===null)&&("factors" in o||"responses" in o)){s=new b();s.setName("Design Parameters");s.setStructure(c.Structure.client.Aggregate);var u=new b();u.setName("Design Variable");u.setStructure(c.Structure.client.Aggregate);s.addProperty(u);var u=new b();u.setName("Output Constraint");u.setStructure(c.Structure.client.Aggregate);s.addProperty(u);var t=new b();t.setName("Objective");t.setStructure(c.Structure.client.Aggregate);s.addProperty(t);m.properties.push(s)}if(s===undefined||s===null){return}if(!("factors" in o)&&!("responses" in o)&&!("constraints" in o)){return}var k=s.getProperties();if(!k||k.length<3){throw"Unable to modify Optimization configuration. \n 					Not able to find Design Variables, Constraints and Objectives properties \n 					Check your base Optimization configuration and technique selection";return}var l,p,y;for(var E=0;E<k.length;E++){var z=k[E];var x=z.getName();if(x.toLowerCase()==="design variable"){l=z}else{if(x.toLowerCase()==="objective"){p=z}else{if(x.toLowerCase()==="output constraint"){y=z}}}}if(!l||!p||!y){throw"Unable to modify Optimization configuration. \n 					Not able to find design variables and objectives properties \n 					Check your base Optimization configuration and technique selection";return}if("factors" in o){l.getProperties();l.removeAllProperties();var j=o.factors.length;for(var f=0;f<o.factors.length;f++){if(!o.factors[f]||null==o.factors[f]){continue}if(o.factors[f].factor&&o.factors[f].factor===false){continue}var v=new b();v.setStructure(c.Structure.client.Aggregate);v.setName("Design Variable "+f);var h=new b();h.setName("Name");h.setStructure(c.Structure.client.Scalar);h.setDataType(c.DataType.String);h.setValue(o.factors[f].name);var g=new b();g.setStructure(c.Structure.client.Aggregate);g.setName("Attributes");if(o.factors[f].lower!==undefined){var B=new b();B.setName("Lower Bound");B.setStructure(c.Structure.client.Scalar);B.setDataType(c.DataType.Real);B.setValue(o.factors[f].lower);g.addProperty(B)}if(o.factors[f].upper!==undefined){var A=new b();A.setName("Upper Bound");A.setStructure(c.Structure.client.Scalar);A.setDataType(c.DataType.Real);A.setValue(o.factors[f].upper);g.addProperty(A)}v.addProperty(h);v.addProperty(g);l.addProperty(v)}}if("constraints" in o){y.getProperties();y.removeAllProperties();var j=o.constraints.length;for(var f=0;f<o.constraints.length;f++){if(!o.constraints[f]||null==o.constraints[f]){continue}var d=new b();d.setStructure(c.Structure.client.Aggregate);d.setName("Output Constraint "+f);var h=new b();h.setName("Name");h.setStructure(c.Structure.client.Scalar);h.setDataType(c.DataType.String);h.setValue(o.constraints[f].name);var g=new b();g.setStructure(c.Structure.client.Aggregate);g.setName("Attributes");if(o.constraints[f].lower!==undefined){var B=new b();B.setName("Lower Bound");B.setStructure(c.Structure.client.Scalar);B.setDataType(c.DataType.Real);B.setValue(o.constraints[f].lower);g.addProperty(B)}if(o.constraints[f].upper!==undefined){var A=new b();A.setName("Upper Bound");A.setStructure(c.Structure.client.Scalar);A.setDataType(c.DataType.Real);A.setValue(o.constraints[f].upper);g.addProperty(A)}var D=new b();D.setName("Scale Factor");D.setStructure(c.Structure.client.Scalar);D.setDataType(c.DataType.Real);D.setValue(1);g.addProperty(D);var r=new b();r.setName("Weight Factor");r.setStructure(c.Structure.client.Scalar);r.setDataType(c.DataType.Real);r.setValue(1);g.addProperty(r);d.addProperty(h);d.addProperty(g);y.addProperty(d)}}if("responses" in o){p.getProperties();p.removeAllProperties();for(var w=0;w<o.responses.length;w++){if(!o.responses[w]||null==o.responses[w]){continue}var e=new b();e.setStructure(c.Structure.client.Aggregate);e.setName("Objective "+w);var h=new b();h.setName("Name");h.setStructure(c.Structure.client.Scalar);h.setDataType(c.DataType.String);h.setValue(o.responses[w].name);var g=new b();g.setStructure(c.Structure.client.Aggregate);g.setName("Attributes");if(o.responses[w].objective!==undefined){var q=new b();q.setName("Direction");q.setStructure(c.Structure.client.Scalar);q.setDataType(c.DataType.String);q.setValue(o.responses[w].objective);g.addProperty(q);if(o.responses[w].objective.toLowerCase()==="target"){var C=new b();C.setName("Target");C.setStructure(c.Structure.client.Scalar);C.setDataType(c.DataType.Real);C.setValue(o.responses[w].value);g.addProperty(C)}}if(o.responses[w].scale!==undefined){var D=new b();D.setName("Scale Factor");D.setStructure(c.Structure.client.Scalar);D.setDataType(c.DataType.Real);D.setValue(o.responses[w].scale);g.addProperty(D)}var r=new b();r.setName("Weight Factor");r.setStructure(c.Structure.client.Scalar);r.setDataType(c.DataType.Real);r.setValue(1);g.addProperty(r);e.addProperty(h);e.addProperty(g);p.addProperty(e)}}},isValidAdapter:function(f){if(f.getExtensionName()!=="com.dassault_systemes.sma.adapter.Optimization"){return false}var d=f.getPluginConfigurations();var e=true;if(!d||d.length<0){throw"Optimization API only supports valid Optimization technique selected \n 					Please select one of supported optimization techniques";return false}return e}};return a});