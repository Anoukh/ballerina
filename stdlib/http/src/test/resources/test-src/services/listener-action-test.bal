import ballerina/http;

listener http:MockListener echoEP  = new(9090);

@http:ServiceConfig {basePath:"/listener"}
service echo on echoEP {

    string serviceLevelStringVar = "sample value";

    @http:ResourceConfig {
        methods:["GET"],
        path:"/message"
    }
    resource function echo(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setTextPayload(self.serviceLevelStringVar);
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
        self.serviceLevelStringVar = "done";
    }
}
