===========
BGTY README
===========


“Be Good To Yourself” is an event tracker and countdown App. Users can add as many events as they want, however only the first 64 events will use notifications (Apple iOS limitation). Events are automatically saved after they are created/edited.  The app includes the ability to create ToDo lists and budget sheets for each event. Users can add their event to their local calendar and share them with social media apps.  Finally, BGTY includes a special feature called the Magic Wand. Originally called the “MG” Coefficient, the magic wand visually removes 2 days from the overall countdown; the first day, which is the current day, and the final day, both of which really don’t count, especially if you are excited and ready to "Be Good To Yourself".


---------------
My Events Scene
---------------

Files:
------
BeGoodTableViewController.swift
BeGoodCollectionViewController.swift
BeGoodCollectionViewCell.swift

The My Events scenes display the list of events currently saved. There are 2 views: Table view and Collection view. Both behave the same way and have similar options.

My Events Table Scene:

How to use the My Events Table scene:

Tap (if necessary) the Table icon in the bottom tab bar to view the My Events table view.

•	Each event shows the selected event image, event descriptions, and event date.

•	Tap the event to push to the main countdown display view.

•	Tap the “+” to add a new event.

•	Tap the “Edit” button to delete an event. Tap the red circle to display the Delete button. Tap the Delete button to delete the item. Tap “Done” when editing is complete. Also, Swiping an event to the left pulls up the DELETE button on the right.

My Events Collection Scene:

How to use the My Events Collection scene:

Tap (if necessary) the Collection icon in the bottom tab bar to view the My Events collection view.

•	Each event shows the selected event image and event date.

•	Tap the event to push to the main countdown display view.

•	Tap the “+” to add a new event.

•	Tap the “Edit” button to delete an event. Tap each event item to select it (turns ligher). When ready, tap the “Remove Event” button on the bottom of the screen to delete the event. Tap “Done” when editing is complete.


---------------
Countdown Scene
---------------

Files:
------
BeGoodShowViewController.swift

The Countdown scene displays the event in countdown mode. This app centers around the countdown display scene. The scene can be accessed by tapping an existing event in the MyEvents scene.

How to use the Countdown scene:

•	Tap the “Edit” button to edit the currently picked event.

•	Tap the share icon to share a snapshot of the event with social media, make a copy of the screen, print the snapshot, etc.

•	Tap the calendar icon to add the event to the user’s local calendar. The calendar event will alert 1 hour prior to the event date.

•	Tap the Magic Wang icon to turn on and off "magic mode" (see more information below).

•	Tap the trash can icon to delete the current event.

•	Tap the menu icon to display a popover list.

    o	Select To Do List to add/edit your event to do list.
    o	Select Budget Sheet to add/edit your event budget sheet.


-----------------
“Until” Selector:
-----------------

Tap one of the time elements (Weeks, Days, Hours, Minutes, Seconds) on the Selector to change the UNTIL counter based on your selection. Both the Main and UNTIL countdown dynamically update 1 second at a time.  Note: As the event time ticks away, the Selector date items will automatically grey out/not be selectable. 

--------------
The Magic Wand
--------------

The Magic Wand method, previously known as the MG Coefficient, is a very unique countdown element not available in any other countdown App. This fun method:
    1. removes the 1st day of the event counter. Reasoning is the 1st day has already started and doesn’t really count (as part of the countdown when using the MG Coefficient).
    2. removes the final day of the event counter. Reasoning is the last day is considered part of the event day (as part of countdown when using the MG Coefficient).

Magic Mode:

•	Magic Wand OFF: Displays the standard countdown values.

•	Magic Wand ON: Take 1 day off the front of the count and 1 day off the end of the count. 

    NOTE: the Magic Wand button will be automatically disabled if the event date is less than 2 days away from current date.

If you exit out of the scene and go back, the Magic Wand will be reset to OFF.


--------------------
Add/Edit Event Scene
--------------------

Files:
------
BeGoodAddEventViewController.swift


The Add/Edit Event scene provides a way to add or edit an Event. The user is presented with a new scene and default values. A temporary image is shown.

How to use the Add/Edit Event scene:

•	Tap the text field to add an Event name. Enter event text similar to the following examples: “our trip to the Grand Canyon” or “George’s Graduation”  or “Mom’s Birthday”. 

•	Tap the date field to call the event date picker view.

•	Tap the Album button to select a picture from your device library.

•	Tap the camera icon to take a picture to be used for the event.

•	Tap the Flickr icon to call the Flickr Picture Selector view.

NOTE: If the Event Description is not changed or left blank, the app will provide a warning and not save the information until the description is changed to new value.
NOTE: If the picked Event Date is less than or equal to the current date, the app will provide a warning and not save the information until the date is greater than the current date.

Pinch & Pan:

After selecting an image to be used as your event background, users will have the option of using the pinch and pan gestures to zoom and reposition the image.


------------------------
Event Date Picker Scene:
------------------------

Files:
------
BeGoodPickDateViewController.swift


The current date or the event date will be the default date shown on the picker view.

How to use the Event Date Picker scene:

•	Scroll up or down to pick a date, hour, minute, and AM/PM.

•	Tap “Select Event Date” when finished selecting an event date.

•	Tap the Back button to exit the view.

NOTE: The event date picker will not allow the user to pick a date prior to the current date.


------------------------------
Flickr Picture Selector Scene:
------------------------------

Files:
------
BeGoodFlickrViewController.swift


How to use the Flickr Picture Selector scene:

•	Enter any word or phrase in the text field. Tap the search icon to access Flickr (via the Flickr Search API) where the word/phrase will be used to search for a picture. A random picture based on the search criteria will be displayed. If the selected picture is satisfactory, tap the “Use This Picture” button at the bottom of the screen. Or tap the search icon again (as many times as you want) to find a different picture. If a satisfactory picture cannot be found, try changing your search word/phrase.

•	Tap the Save button to save your new event or changes. If you are editing an existing event, the countdown view will reappear with the update content.

•	Tap the BACK button to exit the Flickr Picture Selector view.

NOTE: If the Flickr search API does not find an image matching the search criteria, a warning message will be given that will suggest trying again.


-----------------
To Do List Scene:
-----------------

Files:
------
TodoTableViewController.swift
TodoEditTableViewController.swift
TodoAddTableViewController.swift


“Be Good To Yourself” allows the user to add a To Do List unique to each event.

From the Countdown view, tap the Menu icon on the top right.

Next, tap “To Do List” in the Popover view.

•	Tap the “+” icon to add a new item. Enter the item and tap the Save button. Tap “DONE” to exit the Add Item view.

•	Tap the “Edit” button to delete one or more to do list items. Tap the red circle to display the Delete button. Tap the Delete button to delete the item. Tap “Done” when editing is complete.

•	Tap “Event” to exit the To Do List view.



-------------------
Budget Sheet Scene:
-------------------

Files:
------
BudgetTableViewController.swift
BudgetEditTableViewController.swift
BudgetAddTableViewController.swift


“Be Good To Yourself” allows the user to add a budget sheet unique to each event.

From the Countdown view, tap the Menu icon on the top right.

Next, tap “To Do List” in the Popover view.

•	Tap the “+” icon to add a new item. Enter the item and tap the Save button. Tap “DONE” to exit the Add Item view.

•	Tap the “Edit” button to delete one or more to do list items. Tap the red circle to display the Delete button. Tap the Delete button to delete the item. Tap “Done” when editing is complete.

•	Tap “Event” to exit the To Do List view.


----------------
Other App Files:
----------------

Delegate Files:
---------------

AppDelegate.swift: Default delegate file
EventTextDelegate.swift: Text field delegate file
PriceTextDelegate.swift: Text field delegate file
FlickrTextDelegate.swift: Text field delegate file

Object Files:
-------------

Events.swift: 
•	Primary object for storing event data
•	One-to-Many relationship with ToDoList object
•	One-to-Many relationship with Budget object

ToDoList.swift: 
•	Stores To Do List text list
•	One-to-One relationship with Events object

Budget.swift
•	Stores Budget items and price text list
•	One-to-One relationship with Events object


Model Object:
-------------

BGClient.swift: Class for running the Flickr API
BGConstants.swift: Shared static values


Button Attributes:
------------------

BGButton.swift
CornerButton.swift
RoundButton.swift
ActivitySquare.swift


Images:
-------
image-placeholder.png
BGTY1.png

