define('DS/ENOXEnhancersUI/Views/ENOXHistoryView', [
  'UWA/Core',
  'DS/UIKIT/Scroller'
], function (
  Core,
  Scroller
) {
  var HistoryView = function () {};

  function getHistoryIcon(data, renderTo) {
    var iconClass = '';
    var iconDiv = UWA.createElement('div', {
      class: 'history-icon-div'
    });
    //iconDiv.setStyle('display', 'inline');
    switch (data.action) {
    case "create":
      iconClass = 'fonticon fonticon-new-create history-icon';
      break;
    case "promote":
      iconClass = 'fonticon fonticon-up history-icon';
      break;
    case "demote":
      iconClass = 'fonticon fonticon-down history-icon';
      break;
    case "connect":
      iconClass = 'fonticon fonticon-flow-branch-add history-icon';
      break;
    case "disconnect":
      iconClass = 'fonticon fonticon-flow-branch-delete history-icon';
      break;
    case "modify":
      iconClass = 'fonticon fonticon-arrows-ccw history-icon';
      break;
    case "changeowner":
      iconClass = 'fonticon fonticon-user-change history-icon';
      break;
    case "add interface":
      iconClass = 'fonticon fonticon-link  history-icon';
      break;
      case "checkout":
      iconClass = 'fonticon fonticon-export history-icon';
      break;
      case "checkin":
      iconClass = 'fonticon fonticon-import history-icon';
      break;
      case "download":
      iconClass = 'fonticon fonticon-download history-icon';
      break;
    default:
      iconClass = '';
    }
    iconSpan = UWA.createElement('span', {
      class: iconClass
    });
    iconSpan.inject(iconDiv);
    iconDiv.inject(renderTo);
    return iconDiv;

  }

  function getLoggedInUserIcon() {

  }

  function getHistoryContentHeader(data, renderTo) {
    var userIcon = UWA.createElement('span', {
        class: 'fonticon fonticon-2x fonticon-user-alt'
      }),
      userName = UWA.createElement('span', {
        text: data.author.user
      }),
      dateAndTime = UWA.createElement('span', {
        text: data.date, //data.actionDate
        class: 'history-header-date'
      }),
      headerDiv = UWA.createElement('div');
    userIcon.inject(headerDiv);
    userName.inject(headerDiv);
    dateAndTime.inject(headerDiv);
    headerDiv.inject(renderTo);
    return headerDiv;
  }

  function getHistoryAction(data, renderTo) {
    var action = UWA.createElement('div', {
      html: data.description
    });

    action.inject(renderTo);
    return action;
  }

  function getHistoryContent(data, renderTo) {
    getHistoryContentHeader(data, renderTo);
    getHistoryAction(data, renderTo);
  }

  function addHistory(data) {
    var historyDiv = UWA.createElement('div', {
        id: data.id,
        class: 'history-main-div'
      }),
      contentDiv = UWA.createElement('div', {
        class: 'history-content'
      });
    //contentDiv.setStyle('display', 'inline-grid');
    getHistoryIcon(data, historyDiv);
    contentDiv.inject(historyDiv);
    getHistoryContent(data, contentDiv);
    return historyDiv;
  }

  HistoryView.prototype.init = function (data, renderTo) {
    mainHistoryDiv = UWA.createElement('div', {
      styles: {
        height: widget.body.clientHeight
      }
    });

    this.renderTo = renderTo;
    for (var i = data.length - 1; i >= 0; i--) {
      data[i].id = 'history_' + i;
      addHistory(data[i]).inject(mainHistoryDiv);
    }

    this.scroller = new Scroller({
      element: mainHistoryDiv
    });
  }

  HistoryView.prototype.render = function () {
    this.scroller.inject(this.renderTo);
  }

  return HistoryView;
});
