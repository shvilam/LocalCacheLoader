Fork from https://github.com/sgmnt/LocalCacheLoader
Main resone for forking is translte to english 

LocalCacheLoader of fully compatible with Loader / URLLoader.


By using this class , the data of the image or text that is read
Save once locally , if a file of the same already exists
I will use that file .

As a result , you can eliminate unnecessary communication of the same file .
The usage is exactly the same as Loader / URLLoader normal .

Point of difference is that the initialization process requires some prior to use .
It is that it is necessary to use a Factory class dedicated to the generation of class .

It is also available on AIR for Android / AIR for iOS.

# # How to use

While it is easy to understand it 's get a look at the sample / main.as
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
