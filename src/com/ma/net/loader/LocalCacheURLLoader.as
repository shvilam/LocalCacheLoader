﻿/** * * Copyright (c) 2010 - 2013, http://sgmnt.org/ *  * Permission is hereby granted, free of charge, to any person obtaining * a copy of this software and associated documentation files (the * "Software"), to deal in the Software without restriction, including * without limitation the rights to use, copy, modify, merge, publish, * distribute, sublicense, and/or sell copies of the Software, and to * permit persons to whom the Software is furnished to do so, subject to * the following conditions: *  * The above copyright notice and this permission notice shall be * included in all copies or substantial portions of the Software. *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. * */package com.ma.net.loader{        import flash.display.LoaderInfo;    import flash.events.Event;    import flash.events.IOErrorEvent;    import flash.events.OutputProgressEvent;    import flash.events.ProgressEvent;    import flash.events.SecurityErrorEvent;    import flash.filesystem.File;    import flash.filesystem.FileMode;    import flash.filesystem.FileStream;    import flash.net.URLLoader;    import flash.net.URLLoaderDataFormat;    import flash.net.URLRequest;    import flash.utils.ByteArray;    import flash.utils.Dictionary;    import flash.utils.escapeMultiByte;        /**      * A class that can be used to read the related files via HTTP AIR.       * You read when it is requested via HTTP, and then save it to a folder in the application directory in the file read.       * Even in the case of failure in the HTTP request, you can read the file, if it was stored at any one time locally.     * @author sgmnt.org     */    public class LocalCacheURLLoader extends URLLoader{                // ------- MEMBER -----------------------------------------------------------------		/*        private static var _WORKING_DIRECTORY:File;        private static var _DEFAULT_CONTEXT:LoaderInfo;		private static var _FIRST_TIME_DICTIONRY:Dictionary;        */		        private var _context:LoaderInfo;		private var _workingDirectory:File;        private var _loadRemoteFileFirst:Boolean;		private var _remoteFileChecked:Boolean;                // ------- PUBLIC STATIC ----------------------------------------------------------                // ------- PUBLIC -----------------------------------------------------------------                /**         *          * @param context         */        public function LocalCacheURLLoader( context:LoaderInfo = null, loadRemoteFileFirst:Boolean = false ){                        super();            			if( !LocalCacheSettings.WORKING_DIRECTORY ){				LocalCacheSettings.WORKING_DIRECTORY = File.applicationDirectory.resolvePath("/cache/__http__");			}			            _context             = LocalCacheSettings.DEFAULT_CONTEXT;			_workingDirectory    = LocalCacheSettings.WORKING_DIRECTORY;            _loadRemoteFileFirst = loadRemoteFileFirst;            			_remoteFileChecked   = false;			        }                // ------- PROTECTED -----------------------------------------------------------------                /**         * I allow you to load the file.           * If you specify a location starting from http in the URL of the request, you can read it after you save the application directory of the AIR file.         * @param request         * @param loaderContext         */        override public function load( request:URLRequest ):void{			if( _loadRemoteFileFirst ){				//trace("Load remote file first.");				_loadRemoteFile( request );            }else{				//trace("Load local file first.");				_loadLocalFile( request );            }        }                // ------- PRIVATE -----------------------------------------------------------------                /**         * I read the file.         * @param filepath         */        private function _load( req:URLRequest, extention:String = null ):void{			//trace( "Load local file :: " + req.url );            super.load( req );        }                /**         * The attempt to read the file on the local, get the file on the remote and if it does not exist.         * @param request         */		        private function _loadLocalFile( request:URLRequest ):void{			var f:File;            var url:String = request.url;			if( url.indexOf("http") == 0 ){				// I check the cache directory if the http request.				url = LocalCacheSettings.encode(url);				f   = new File( _workingDirectory.resolvePath( url.substring( url.indexOf("://") + 3, url.length ) ).nativePath );                if( f.exists ){					_load( new URLRequest( f.url ) );                }else{					//trace("Local file does not exists.");					if( !_remoteFileChecked ){						_loadRemoteFile( request );					}else{						dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );					}                }            }else{				if( _context ){					f = new File( _context.url );					if(f.isDirectory){						request.url = f.resolvePath(request.url).url;					}else{						request.url = f.resolvePath('../'+request.url).url;					}				}				// I make a request of the usual case of relative path request.				_load( request );            }        }                /**        * I read save the file locally on the remote.          * If it fails to access the network, it will attempt to load the file on the local.         * @param request         */        private function _loadRemoteFile( request:URLRequest ):void{                        var url:String = request.url;						// If the URL is not start from _workingDirectory read source exists and. 			// In other words, were present in the original remote, but to fix the relative path from there such thing. Present in the local current.						if( request.url.indexOf('http') != 0 && _context && -1 < _context.url.indexOf(_workingDirectory.url) ){				var url2 = _context.url;				url2 = url2.replace(_workingDirectory.url,"http:/");				url2 = url2.substr( 0, url2.lastIndexOf("/") ) + "/" + request.url;				url2 = LocalCacheSettings.decode(url2);				request.url = url2;			}else{				url = request.url;			}			            if( url.indexOf("http") == 0 ){								url = LocalCacheSettings.encode(url);								var filename:String = url.substring( url.lastIndexOf("/") + 1, url.length );				var filepath:String = url.substring( url.indexOf("://") + 3, url.lastIndexOf("/") );								// Processing of reading failure.                var onerror:Function = function(e:Event){                    //trace(e);                    _loadLocalFile( request );                }								// Processing of reading success.                var oncomplete:Function = function(e:Event){                                        //trace(e);										//trace("Create cache file...");					                    var f:File   = new File( _workingDirectory.resolvePath( filepath + "/" + filename ).nativePath );                    var tmp:File = new File( _workingDirectory.resolvePath( filepath + "/" + filename +".tmp").nativePath );                    var fs:FileStream = new FileStream();                                        if( f.exists ){                        f.copyTo( tmp, true );                    }                                        try{                        fs.open(f,FileMode.WRITE);                        fs.writeBytes( urlLoader.data as ByteArray );                        fs.close();                        if( tmp.exists ){                            tmp.deleteFile();                        }						//trace("Complete.");                    }catch(e){                        //trace(e);						//trace("Failure.");                        if( tmp.exists ){							//trace("Rollback from temporary copy.");                            tmp.moveTo( f, true );                        }                    }										_loadLocalFile( request );                                    }								//trace( "Load remote file :: " + request.url );								_remoteFileChecked = true;								var urlLoader:URLLoader = new URLLoader();				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;				urlLoader.addEventListener( Event.COMPLETE, oncomplete );                urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onerror );                urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onerror );                urlLoader.load( request );                            }else{                                _load( request );                            }                    }		    }    }