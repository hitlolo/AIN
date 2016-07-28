
function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
};


setupWebViewJavascriptBridge(function(bridge) {
                             
 /* Initialize your app here */
    
     var imageUrlsArray = new Array();
                             
     function handleImgs () {
     
         var imgOnClick = function() {
            console.log("image clicked:" + this.src);
            
             var x = this.getBoundingClientRect().left;
             var y = this.getBoundingClientRect().top;
             x = x + document.documentElement.scrollLeft;
             y = y + document.documentElement.scrollTop;
             var width = this.width;
             var height = this.height;
             
             var frame = {'x':x,'y':y,'width':width,'height':height};

                             
             bridge.callHandler('imageDidClicked', this.src, function responseCallback(responseData){
                    console.log("JS received response:", responseData)
            })
                                
         };
     
         var imgs = document.getElementsByTagName('img');
        
         for (var i = 0; i < imgs.length ; i++) {
             var img = imgs[i];
             img.addEventListener('click', imgOnClick);
             imageUrlsArray.push(img.src);
                             
         };
     };
    
     handleImgs();
     
     bridge.callHandler('imagesDidLoad', imageUrlsArray, function responseCallback(responseData) {
            console.log("JS received response:", responseData)
     })
     
     bridge.registerHandler('frameOfImageAtIndex', function(index, responseCallback) {
            
            var imgs = document.getElementsByTagName('img');
            var img = imgs[index];
            var x = img.getBoundingClientRect().left;
            var y = img.getBoundingClientRect().top;
                x = x + document.documentElement.scrollLeft;
                y = y + document.documentElement.scrollTop;
            var width = img.width;
            var height = img.height;

                            
            var responseData = {'x':x,'y':y,'width':width,'height':height};

            responseCallback(responseData)
     })
      
});


function frameOfImageAtIndex(index){
    var imgs = document.getElementsByTagName('img');
    var img = imgs[index];
    var x = img.getBoundingClientRect().left;
    var y = img.getBoundingClientRect().top;
    x = x + document.documentElement.scrollLeft;
    y = y + document.documentElement.scrollTop;
    var width = img.width;
    var height = img.height;
    
    
    var responseData = {'x':x,'y':y,'width':width,'height':height};
    console.log("frame of image at index:"+index, responseData)
    return '\{\"x\":'+x + ','+ '\"y\"'+':'+y+','+'\"width\":'+width+','+'\"height\":'+height+'\}';
};