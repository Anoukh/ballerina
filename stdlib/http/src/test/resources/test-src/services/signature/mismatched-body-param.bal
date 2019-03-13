import ballerina/http;

listener http:MockListener echoEP = new(9090);

@http:ServiceConfig {
    basePath:"/signature"
}
service echo on echoEP {

    @http:ResourceConfig {
        methods:["POST"],
        body:"person"
    }
    resource function echo1 (http:Caller caller, http:Request req, string key, json ballerina) {
        http:Response res = new;
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }
}
