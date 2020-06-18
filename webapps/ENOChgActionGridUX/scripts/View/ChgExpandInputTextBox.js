define("DS/ENOChgActionGridUX/scripts/View/ChgExpandInputTextBox", [
  "UWA/Core",
  "DS/Controls/Abstract",
  "DS/Controls/LineEditor",
  "DS/Controls/Button",
  'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS',
  'DS/ENOChgActionGridUX/scripts/View/ChgCreateChangeAction',
  "css!DS/ENOChgActionGridUX/ENOChgActionGridUX"
], function (core, Abstract, WUXLineEditor, WUXButton, APP_NLS, ChgCreateChangeAction) {
  "use strict";
  var expandInputTextBox = Abstract.inherit({
    name: "ExpandInput",
    //Do Something
    _preBuildView: function () {
      this.elements.container = new UWA.Element("div", {
        'class': "container-expandInput wux-tweakers"
      });

      this.createCAContainer = new UWA.Element("div", {});

      this.lineEditor = new WUXLineEditor({
        placeholder: APP_NLS.CHG_CREATE_NEW_PLACEHOLDER,
        sizeInCharNumber: 25,
        selectAllOnFocus: true,
        displayClearFieldButtonFlag: true
      });
      this.lineEditor.inject(this.createCAContainer);

      this.dropdown = new UWA.Element("div", {
        class: 'createCAdropdown'
      });

      var createList = new UWA.Element("ul", {
        class: 'createUL'
      });

      var listItem = new UWA.Element("li", {
          class: 'createLI'
        });

      var createIcon = new UWA.Element("span", {
        class: 'item-icon fonticon fonticon-doc cursorPointer'
      });

      var createLabel = new UWA.Element("span", {
            class: "item-text",
              html: 'Create a blank CA'
          });
      createIcon.inject(listItem);
      createLabel.inject(listItem);
      listItem.inject(createList);
      createList.inject(this.dropdown);

      createList.addEvents({
          click: ChgCreateChangeAction.createChangeAction,
          touchstart: ChgCreateChangeAction.createChangeAction
      });

      this.dropdown.inject(this.createCAContainer);

      this.createCAContainer.inject(this.elements.container);
      this.createCAContainer.style.display = "none";

      var options = {};
      options.icon = {};
      options.icon.iconName = "plus";
      options.icon.fontIconFamily = 1;
      options.tooltip = "YOLO";
      var me = this.createCAContainer;
      var editor = this.lineEditor;
      options.onClick = function () {
        if (me.style.display == "none") {
              me.style.display = "block";
              editor._myInput.focus();
        } else {
              me.style.display = "none"
        }
      };

      this.plusBtn = new WUXButton(options);
      this.plusBtn
        .getContent()
        .addClassName("wux-tweakers-multirep-button")
        .addClassName("wux-tweaker-function")
        .addClassName("wux-ui-style-icon");
      this.plusBtn.inject(this.elements.container);

      this._parent();
      this.isMultiSelection = false;
    },
    toggleDisplayLineEditor: function () {
      console.log(arguments, this);
    }
  });

  return expandInputTextBox;
});
