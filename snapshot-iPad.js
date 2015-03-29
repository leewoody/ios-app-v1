#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);

target.delay(3);
target.frontMostApp().mainWindow().tableViews()[1].cells()[0].textFields()[0].setValue("http://localhost/");
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[1].cells()[1].textFields()[0].setValue("3");
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[1].cells()[2].textFields()[0].setValue("TRgHMwDCkJ9nv");
target.delay(1);

target.frontMostApp().navigationBar().rightButton().tap();
target.delay(3);

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(2);
captureLocalizedScreenshot("1-Article1");

target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.delay(2);
captureLocalizedScreenshot("2-Article2");

target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
target.delay(1);
target.frontMostApp().toolbar().buttons()[1].tap();
target.delay(2);
captureLocalizedScreenshot("3-Article3-Dark");
