import ballerina/http;
import ballerina/io;

listener http:MockListener passthruEP  = new(9090);

@http:ServiceConfig {
    basePath:"/echo/{version}/bar",
    versioning:{
        pattern:"v{major}"
    }
}
service echo1 on passthruEP {

    @http:ResourceConfig {
        path:"/go"
    }
    resource function sample(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setJsonPayload({hello:"only match major but no major"});
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }
}

@http:ServiceConfig {
    basePath:"/echo/{version}/bar",
    versioning:{
        pattern:"v{major}.{minor}",
        matchMajorVersion:true
    }
}
service echo2 on passthruEP {

    @http:ResourceConfig {
        path:"/go"
    }
    resource function sample(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.setJsonPayload({hello:"only match major but no major"});
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }
}
