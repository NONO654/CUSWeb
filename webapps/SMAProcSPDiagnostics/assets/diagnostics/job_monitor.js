import DiagnosticsBase from "./base.js";

class Diagnostics extends DiagnosticsBase {
    
  _$contextRequest () {
    const $action = '_$contextRequest';

    const securityContext = widget.data['collab-space'];
    let jobId = undefined;
    
    // get the selected element
    const selectedElement = document.querySelector('.selected');    
    // if there is a selection
    if (selectedElement) {
      // find the index of selection
      let index = 0;
      for (let elem of selectedElement.parentElement.children) {
        // if its the selected element
        if (elem.id === selectedElement.id) {
          break;
        } else {
          index++;
        }
      }
      
      jobId = document.querySelector('sp-6wtagger').idlist[index].id;
    }

           
    const preferences = widget.preferences.map(pref => {
      return {name: pref.name, value: widget.getPreference(pref.name).value};
    });

    const platform = widget.data.x3dPlatformId;

    // example:
    // --------
    // objectId = 4B709B568954000079572C5BFDED0C00
    // contextId = ctx::VPLMProjectLeader.MyCompany.3DS Collab Space
    // widgetData = {...}
    this.send({
      $action,
      jobId,
      securityContext,
      preferences,
      platform
    });
  }
}


// create a new diagnostics instance
const diagnostics = new Diagnostics();
diagnostics.init();




