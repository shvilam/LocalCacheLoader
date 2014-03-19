/**
 *
 * Copyright (c) 2010 - 2013, http://sgmnt.org/
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */
package com.ma.net.loader{
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * By registering Loader, is a class that will optimize the read issues in order request.
	 * @author sgmnt.org
	 */
	public class LoaderSequentializer extends EventDispatcher{
		
		// ------- MEMBER ---------------------------------------------
		
		private var _running:Boolean;
		
		private var _timer:Timer;
		
		private var _loaderVec:Vector.<Loader>;
		
		private var _loaderDict:Dictionary;
		private var _requestDict:Dictionary;
		private var _contextDict:Dictionary;
		
		// ------- PUBLIC ---------------------------------------------

		private var _loader:Loader;
		
		/**
		 * Constructor.
		 * @param target
		 */		
		public function LoaderSequentializer( delay:Number = 0 ){
			
			super(null);
			
			_timer = new Timer( delay, 1 );
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, _onTimerComplete );
			
			_running = false;
			
			_loaderVec = new Vector.<Loader>();
			
			_loaderDict  = new Dictionary(true);
			_requestDict = new Dictionary(true);
			_contextDict = new Dictionary(true);
			
		}
		
		/** 現在読み込み実行中か否か. */		
		public function get running():Boolean{ return _running; }
		
		/**
		 * I will start reading. 
		 * Reason as opposed to creating a loader, passed in argument for the specified context is complicated when using the LocalCacheLoader. 
		 * @param request
		 * @param context
		 * @param complete
		 * @param error
		 * @return 
		 */
		public function addLoaderQueue( loader:Loader, request:URLRequest, context:LoaderContext = null, immediately:Boolean = false ):void{
			
			// contentLoaderInfo から Loader を引ける様にする.
			_loaderDict[loader.contentLoaderInfo] = loader;
			
			// Loader から URLRequest を引ける様にする.
			_requestDict[loader] = request;
			
			// Context の設定がある場合 Loader から引ける様にする.
			if( context != null ){
				_contextDict[loader] = context;
			}
			
			// loader にイベントを付与しておく.
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE                   , _onComplete, false, 0, true );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR            , _onComplete, false, 0, true );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete, false, 0, true );
			
			if( immediately == true ){
				_loaderVec.unshift( loader );
			}else{
				_loaderVec.push( loader );
			}
			
			_load();
			
		}
		
		/** 
		* I remove the read queue. 
		* @ Param loader 
		*/
		public function removeLoaderQueue( loader:Loader ):void{
			
			for( var i:int = 0, len:int = _loaderVec.length; i < len; i++ ){
				
				var l:Loader = _loaderVec[i];
				
				if( loader == l ){
					
					_timer.stop();
					
					_loaderVec.splice( i, 1 );
					
					try{
						loader.close();
					}catch(e){}
					
					loader.contentLoaderInfo.removeEventListener( Event.COMPLETE                   , _onComplete, false );
					loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR            , _onComplete, false );
					loader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onComplete, false );
					
					delete _loaderDict[ loader.contentLoaderInfo ];
					delete _requestDict[loader];
					delete _contextDict[loader];
					
					// 現在読み込み中のものであった場合.
					if( _loader == loader ){
						_loader = null;
						if( _running == true ){
							_running = false;
							_load();
						}
					}
					
					return;
					
				}
				
			}
			
		}
		
		/** 
		* I will cut the processing of communication. 
		*/
		public function close():void{
			if( _loader != null ){
				try{
					_loader.close();
				}catch(e){}
				_loader = null;
				_running = false;
			}
		}
		
		// ------- PROTECTED ------------------------------------------
		
		protected function _load():void{
			
			// I read in the case of reading already in progress.
			if( _running == true ){
				return;
			}
			
			if( !_loaderVec || _loaderVec.length == 0 ){
				_running = false;
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
			_timer.reset();
			_timer.start();
			
		}
		
		private function _onTimerComplete(event:TimerEvent):void{
			_loader = _loaderVec[0];
			_loader.load( _requestDict[_loader] as URLRequest, _contextDict[_loader] as LoaderContext );
			_running = true;
		}
		/** 
		* I do read the following, regardless of read completion, failure, the security error. 
		* @ Param event 
		*/
		protected function _onComplete( event:Event ):void{
			removeLoaderQueue( _loaderDict[event.target] );
		}
		
		// ------- PRIVATE --------------------------------------------
		// ------- INTERNAL -------------------------------------------
		
	}
	
}