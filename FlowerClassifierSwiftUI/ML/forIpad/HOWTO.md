In order to run this app on an iPad, there is a step more that has to be done, compared to the mac.

You can copy paste the exact same files or write the exact same code, but in order to run in iPad, you have to do the following.

First, you drag and drop the .mlmodel file to the project (this has to be done on mac's xcode as well)

But then, you also need the "bridging file", which is automatically generated on the mac, but not on the ipad.
You get this file, when you click on the ML model and then on the model class.
It is an auto generated file.

When the file is open, click on File -> Open in Finder.
This file needs to be copied to the iPad and imported to the project as well.

But that's still not everything, because the ipad needs a compiled ML model.

I did very lot of researching and created the mlmodelc file, but it didn't work.

Fortunately, theres a - deprecated - method, which can compile the model directly on the device.

So I implemented this into the file which we just copied from the mac and put it here, so you can use it.

Now the app should run just fine on the ipad as well.