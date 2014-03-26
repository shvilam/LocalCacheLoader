Main reason for forking is translated the code and docs to english 

LocalCacheLoader is library fully compatible with Loader / URLLoader/ NetStream and it try to replace a very light weight version of the brower cashe.


By using this class , the data of images text  and video will be fetch from server once
locally , and then when every it will be request again we will recheck the local file system first and local file will be use. 


As a result , you can eliminate unnecessary communication to the server by requesting the same file over and over agin.
The usage is exactly the same as Loader / URLLoader /NetStream.

The main difference is that the initialization process that requires 2 Lines of code.
1. the fist is spesfied the application the main cache directory.
2. is passing the  LocalCacheLoader, LocalCacheURLLoader, LocalCacheNetStream.
3. Using the factory to create instances for thous classes. 

    Help is needed!
    
    Help is needed for the NetStream loader it doesnt have the optimal soltion it first save the file to local disc 
    and then play. it will be perfect if i could baffer the stream and in end create file out of it.

p.s 
Tt is obligatory to use a Factory class to generate the local loader classes.

# # How to use

Lest look at an example even that it is quite easy to understand. File is in  sample/main.as
It is used first initialize something like the following .
For us to save on local without permission is after .

So keep that uniquely file based on the URL, unless it is the same URL completely
I may not file will be overwritten .

    // Setup cache Directory.
    // Can be cached in the directory that you specify here .
    LocalCacheSettings.WORKING_DIRECTORY = File.applicationDirectory;
    
    // Please set the following: If AIR for Android, the AIR for iOS.
    // LocalCacheSettings.WORKING_DIRECTORY = File.applicationStorageDirectory;

    // Init Factory Class.
    // Loader like normal will be used if you do not initialize the factory class .
    NetClassFactory.initialize (LocalCacheLoader, LocalCacheURLLoader, LocalCacheNetStream);

    // Create Class.
    // If true the second argument here , regardless of there without a cache that is stored in the local
    // I will take the file from the Web always on .
    _loader = NetClassFactory.createLoader (null, false);
    / / I use normally after .
    _loader.contentLoaderInfo.addEventListener (Event.COMPLETE, _onComplete);
    _loader.load (new URLRequest ("https://www.google.co.jp/images/srpr/logo11w.png"));


Fork from https://github.com/sgmnt/LocalCacheLoader
