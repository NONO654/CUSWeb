# 3DLean Version 19.9.24

## Browser and Operating System Compatibility

|                              |Web Brower                     |Operating System              |
|:-----------------------------|:------------------------------|:-----------------------------|
|**Fully compatible**          |Chrome - Firefox               |Windows 10                    |
|**Partially compatible**      |IE11 - Edge - Safari           |Linux - macOS - iOS - Android |

# Change Log
**Beta Features** features in Beta, still in progress. <br />

## Features on 2019-09-18 for 2020x
### New Features
- **Actions** The Sketch tab has been added in the Edit menu of an Action: it lets you add information or schematics about the action.
<a href="https://help.3ds.com/2020x/English/DSDoc/Del3dlUserMap/del3dl-t-tu-CreatingActionItem.htm" target="_blank">See: Assigning Actions.</a>
- **Issues** The Context tab has been added in the Edit menu of an Issue: it lets you take a screenshot of the Issue within the Leanget.
<a href="https://help.3ds.com/2020x/English/DSDoc/Del3dlUserMap/del3dl-t-tu-Issue.htm" target="_blank">See: Monitoring Issues.</a>
- **Issues** The Sketch tab has been added in the Edit menu of an Issue: it lets you add information or schematics about the Issue.
<a href="https://help.3ds.com/2020x/English/DSDoc/Del3dlUserMap/del3dl-t-tu-Issue.htm" target="_blank">See: Monitoring Issues.</a>

### New Beta Features
- **PDF Viewer** A PDF Viewer Leanget is now available: it lets you display, annotate, and capture a PDF file.
<a href="https://help.3ds.com/2020x/English/DSDoc/Del3dlUserMap/del3dl-c-Basic.htm#c-Leangets" target="_blank">See: Leangets.</a>
- **Notes** In the settings, you can associate an E-Note color with a label. This can help you sort E-Notes by categories.

### Improvements
- **Actions** In the Context tab of the Edit menu, a new button lets you add or update the Context picture. The uploaded picture is attached as document to the corresponding ENOVIA Collaborative Task.
<a href="https://help.3ds.com/2020x/English/DSDoc/Del3dlUserMap/del3dl-t-tu-CreatingActionItem.htm" target="_blank">See: Assigning Actions.</a>
- **Issues** In the Context tab of the Edit menu, a new button lets you add or update the Context picture.
<a href="https://help.3ds.com/2020x/English/DSDoc/Del3dlUserMap/del3dl-t-tu-Issue.htm" target="_blank">See: Monitoring Issues.</a>
- **Performance** The overall performance has been improved.
- **UI/UX** New loading screen.

### Fixed Issues
- **App** If the minimum font size provided by the browser is wrong it no longer prevents the app from loading.
<a href="https://bugs.chromium.org/p/chromium/issues/detail?id=949471" target="_blank">See: Issue 949471 in bugs.chromium website.</a>
- **App** When upgrading to a new version of 3DLean, the data migration no longer creates an error and no longer prevents the app from loading.
- **Live Meeting** The correct view now appears whenever joins a meeting,
- **Live Meeting** The Sketch resolution during a meeting has been fixed.
- **Meeting** All actions created during a slideshow meeting now appear in the Action Log.
- **Notes** When you edit a note, the keyboard is automatically selected if the note contains a description.
- **Sketch** With Live feature, the lines no longer creates lines in every way.

### Known Issues
- **Performance** On Firefox, touch mode can slow down performance.
- **Notes** If the minimum font size provided by the browser is wrong, the E-Note size and font size may not be displayed correctly. To fix this, reinstall your browser.
<a href="https://bugs.chromium.org/p/chromium/issues/detail?id=949471" target="_blank">See: Issue 949471 on bugs.chromium.</a>
- **Notes** In an Action attached to an ENOVIA Collaborative Task, images have a transparent background whereas erased parts are filled with the background color.
- **Notes** The impossibility to use the Eraser when notes have a background image (current quickfix: we disabled the Eraser button in this case).
- **Team** If you add an user already displayed in the App (his picture), the user doesn't appear in the Leanget Team. You have to reload 3DLean to see it.
- **Team** If you add an user, he appears at the last position of the list in the side menu team. You have to reload 3DLean to see it at good position.

### Limitations
- **Actions** Edits on an ENOVIA Collaborative Task are not applied to the corresponding Action in 3DLean.
- **Action Log** Only one Action Log is supported per account. You can have only one Action Log across all your boards.
- **Capture** You cannot capture content from another origin.
<a href="https://www.w3.org/Security/wiki/Same_Origin_Policy" target="_blank">See: W3C Same Origin Policy.</a>
- **Issue Log** Only one Issue Log is supported per account. You can have only one Issue Log across all your boards.
- **Navigation** The swipe gesture (sliding two fingers across the screen) is not supported in the Web Page Leanget.
- **PDF Viewer** You cannot display content from another origin.
<a href="https://www.w3.org/Security/wiki/Same_Origin_Policy" target="_blank">See: W3C Same Origin Policy.</a>

## Features on 2019-07-19 for 2019xFD04 (FP1931)
### Improvements
- **Board** Pinch: move 3 fingers closer together to exit Boards.
- **Interface** The Customized menu was reordered: the Sketch Leanget is now in first position.
- **Leangets** You can now add/remove members or collaborators directly from the Team Leanget.
- **Leangets** You can now move E-Notes when annotating Leangets.
- **Leangets** You can now show/hide E-Notes when annotating Leangets.
- **Live** 3DLean now features real-time collaboration, providing live meetings, screen-sharing, and interfaced updates.
- **Live Meeting** Thanks to the real-time collaboration, you can now share your navigation in real-time with other team members during a meeting.
- **Meeting** Free Meeting: a new mode without slideshow, where you navigate freely within the interface, is now available.
- **Notes** You can now remove assignees or stickers from E-Notes: long press on the element you want to remove in the edit view.
- **Notes** You can now edit colors for E-Notes.
- **Notes** E-Notes: move 2 fingers further apart or closer together to zoom in or out + move 2 fingers in a clockwise or counterclockwise direction to rotate.
- **Notes** The input field for E-Notes has been improved to allow more text in it.
- **Sketch** In the Sketch Leanget, the reload command enables you to update the background.
- **Sketch** In the Sketch Leanget, a button to hide/show the sketch toolbar is now available.
- **UI/UX** Current title Board displayed as Widget title.
- **UI/UX** The terminology for of the smoothing settings has been updated.
- **UI/UX** The UX has been improved in slideshow meetings.
- **UI/UX** The UI responsiveness has been improved and some thumbnails/icons updated.
- **UI/UX** In fullscreen, the white space between 3DLean and the top bar is now hidden.
- **UI/UX** You can now use the mouse wheel to scroll the Customize menu, the Team members, and Stickers lists.
- **Web Page** A cast command has been added to the Web Page Leanget: you can now share a screenshot of your web page with all connected users.

### Fixed Issues
- **Action Log** Actions created during a meeting are now displayed in the Action Log Leanget of the meeting.
- **App** On mobile, 3DLean interface is no more truncated at the top.
- **App** The error of Security Context (ERR0x00000411) is now displayed only if 3DLean cannot be launched.
- **App** The first launch of 3DLean is now operational.
- **App** After an update of 3DLean, the launch of the application no longer fails because of unrefreshed browser cache.
- **Leangets** Screen captures of the KPI Leanget now have the right color and font.
- **Leangets** Screen captures are no longer slow when some content is unreachable (CORS).
- **Notes** Words in E-Notes are no longer cut in half at the end of the line.
- **Sketch** The different device pixel ratio for drawings in the Sketch Leanget (zoom in Windows or web browsers) is now correct.
- **Sketch** In the Sketch Leanget, the erasing feedback with multiple touch is now correctly displayed.

### Removed
- **App** In the settings, Swym pictures are no longer available as source for team members pictures.
- **Sketch** After you reload in the Sketch Leanget, changes you had made using the undo/redo buttons become permanent: to improve perfomance, you can no longer revert them after reloading.

## Features on 2019-03-22 for 2019xFD02 (FP1914)
### Improvements
- **Interface** The navigation button, at the bottom right and left, has been improved.
- **Interface** Close button in the side panel has been moved to the top right corner.
- **Leangets/Boards** We are now asking a confirmation when deleting Leangets or Boards.
- **Notes** Undo and redo commands have been added to E-Notes.

### Fixed Issues
- **Action Log** When you add the Action Log Leanget, the Actions you created before automatically appear to the Leanget.
- **Action Log** Actions sent to an offline collaborating team appear in their Action Log when they log in their 3DLean.
- **Actions** Screenshots inside Actions edit panel are no longer replaced by the content of the Note.
- **Notes** E-Notes can be wrote with the keyboard without freezing the Tools menu.
- **Sketch** Draw outside the Sketch field no longer creates bugs after reloading.
- **Web Page** The zoom is now correctly applied when the Web Page Leanget is minified.

## Features on 2019-01-25 for 2019xFD01 (FP1907)
### New Features
- **Actions** The content filled with the keyboard in Actions is automatically filled in the Description of the same Enovia Task.
- **Actions** A new functionality to take a screenshot of the Action within the Leanget has been added: the screenshot is attached as document to the same Enovia Task.
- **Actions** A new tab to display the context screenshot of Actions has been added.
- **Actions** A new tab to edit Enovia Tasks attributes and properties has been added.
- **Changelog** You now have access to the Change Log by clicking on the megaphone icon on the top right of the Navigation Pane.
- **Issue** A new functionality to create Issues has been added.
- **Leangets** The Issue Log Leanget is now available.
- **Notes** A new functionality to fill the Notes with the keyboard is now available.
- **Pictures** There is new option in the preferences to choose the 3DSwym picture: you can choose between User Picture, Community Logo, or Media Logo.
- **Settings** A new option to automatically delete Done Actions after a set of days has been added.
- **Sketch** A new option to set writing smoothing is now available in the preferences of the Sketch Leanget.

### Improvements
- **Actions** The Edit button is now available on send and done Actions but only for consulting.
- **Actions** The edition interface has been modified.
- **Board** From the navigation pane, when you click the Customize button, you can now modify Leangets titles directly from Boards.
- **Favorites** Default favorites can be set on the server.
- **Favorites** You can modify the name for the favorites.
- **Interface** The navigation pane button information has been improved.
- **Issue** When editing Issues, the created Action is automatically selected and displayed.
- **Leangets** A sketch command is now available for annotation for all the Leangets.
- **Leangets** When an empty Board, Web Page or Player Leanget is opened, the Customize menu is automatically displayed.
- **Menus** The side menu functionnalities have been reorganized: Tools - Meeting - Customize - Select.
- **Pictures** Team members profile picture are now retrieved from 3DSwym.
- **Sketch** The Eraser has been improved, as well as its size display.
- **Sketch** A new smoothing algorithm and option have been added.
- **Sketch** After you reload in the Sketch Leanget, changes you had made using the undo/redo buttons are persisted.

### Deprecated Features
- **Notes** To erase text typed with a keyboard you no longer need to use the Eraser: you can now use the RETURN key.

### Removed
- **Pictures** The 3DLean Public - People collaborative space to manage pictures has been removed: user profile pictures are now retrieved from 3DSwym.

### Fixed Issues
- **Browsers** IE11: Firefox and Edge corrections have been made.
- **Capture** The Capture command includes now fonts and icons.
- **Capture** The Capture command including other domain resources doesn't crash anymore.
- **Player** The Capture command is now available on the Video Player Leanget.
- **Sketch** The background images URL in the Sketch Leanget is now correctly saved.
- **Sketch** Pictures are no longer pixelated over time.

## Features on 2018-07-13 for 2018xFD04 (FP1830)
### New Features
- **Favorites** New options to use predefined settings for Web Page, Player, KPI, Sketch Leangets have been added.
- **Meeting** A new functionality to run a meeting is now available: you can create a slideshow by selecting Leangets.
- **Settings** A new option that force fullscreen on load of 3DLean has been added.

### Improvements
- **Collaboration** We can now add collaborating teams and send them Actions.
- **Performance** The overall performance has been improved.

## Features on 2018-05-18 for 2018xFD03 (FP1822) and Older
### New Features
- **Actions** The functionality to create and manage Actions is now linked to Enovia Tasks (Collaborative Task).
- **Actions** A new functionality to send Actions to other 3DLean Teams is now available.
- **Customize** You can now customize Boards and Leangets using the Customize menu.
- **Leangets** The following Leangets are now available: Action Log, Web Page, Player,  KPI, Sketch, and Team.
- **Leangets** New commands to annotate and capture Leangets content are now available.
- **Notes** A new functionality to create and manage sticky notes has been added.
