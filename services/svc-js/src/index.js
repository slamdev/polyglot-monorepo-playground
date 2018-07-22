var http = require('http');
 
http.createServer(function(request,response) {
    response.writeHead(200);
    response.write("It's alive!");
    response.end();
}).listen(8080);
