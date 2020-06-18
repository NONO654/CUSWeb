define('DS/ENOChgActionGridUX/scripts/Wrapper/ChgIDCardWrapper', [
    'DS/ENOChangeActionUX/scripts/ChangeAction',
    'DS/ENOChangeActionUX/scripts/CAUtility',
  ],
  function(ChangeAction,CAUtility) {
    var ChangeActionWrapper = ChangeAction;
    
    /**
     * @pid : CA physical Id
     * @target : Destination div
     */
    ChangeActionWrapper.CAIDCardWrapper = function(Config) {

      var contextCAID = "pid:"
      if (Config.pid) {
        contextCAID = contextCAID + Config.pid;
      } else {
        //TODO: get from a global variable
      }
      var options = {
        transientCAPid: contextCAID,
        nameTitlePref: enoviaServerCAWidget.NamePref,
        target: Config.target
      }
      Config.target.empty();
      // intialization the IDCard
      ChangeAction.getCAIDCard(options);

      this._modelEvents = Config._modelEvents;
      var that = this;
      var NewIdCard=enoviaServerCAWidget.IDCard;
      if(NewIdCard){
        NewIdCard.model.addEvent("onChange:synopsis",function(model,title){
                if(model.previous("synopsis") != "" && model.previous("synopsis") != undefined){
                  console.log("----------------------on change title");
                  that._modelEvents.publish(
                     {
                       event: 'ca-IDCard-on-change-title',
                       data: { model: model, id: model.id, title:title },
                       context: model
                     }
                   );
                }
          });

          NewIdCard.model.addEvent("onChange:severity",function(model,sev){
                if(model.previous("severity") != "" && model.previous("severity") != undefined){
                  console.log("----------------on change sev");
                  that._modelEvents.publish(
                     {
                       event: 'ca-IDCard-on-change-severity',
                       data: { model: model, id: model.id, sev:sev },
                       context: model
                     }
                   );
                }
          });

          NewIdCard.model.addEvent("onChange:current",function(model,maturity){
            if(model.previous("currentDisplay") != "" && model.previous("currentDisplay") != undefined){
              console.log("----------------------on change maturity");
              that._modelEvents.publish(
                 {
                   event: 'ca-IDCard-on-change-maturity',
                   data: { model: model, id: model.id, maturity:maturity },
                   context: model
                 }
               );
            }
          });

          NewIdCard.model.addEvent("onChange:due",function(model,dueDate){
          if(model.previous("due") != "" && model.previous("due") != undefined){
            if(dueDate != ""){
              console.log("----------------------on change due date");
              that._modelEvents.publish(
                 {
                   event: 'ca-IDCard-on-change-duedate',
                   data: { model: model, id: model.id, dueDate:dueDate },
                   context: model
                 }
               );
             }
          }
          });

          NewIdCard.model.addEvent("onChange:contextUserRole",function(model,responsibility){
            if(model.previous("contextUserRole") != "" && model.previous("contextUserRole") != undefined){
               console.log("----------------------on change responsible");
               that._modelEvents.publish(
                  {
                    event: 'ca-IDCard-on-change-responsibility',
                    data: { model: model, id: model.id, responsibility:responsibility },
                    context: model
                  }
                );
            }
          });
      }

      //Disable tagger on back to summary
      var CAUtilityWrapper = CAUtility;
      this._modelEvents.subscribe({ event: 'ca-back-to-summary' }, function (data) {
        console.log("on back button" + NewIdCard);
        console.log(CAUtilityWrapper);
        CAUtilityWrapper.killTaggerProxies(-1);
        debugger ;
      });
    }


    return ChangeActionWrapper;

  });
