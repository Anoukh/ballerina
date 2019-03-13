import ballerina/http;

listener http:MockListener testEP = new(9090);
listener http:MockListener mockEP1 = new(9091);
listener http:MockListener mockEP2 = new(9092);

@http:ServiceConfig {
    cors: {
        allowCredentials: true
    }
}
service serviceName on testEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:""
    }
    resource function test1 (http:Caller caller, http:Request req) {
        http:Response res = new;
        json responseJson = {"echo":"dispatched to service name"};
        res.setJsonPayload(responseJson);
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }
}

@http:ServiceConfig {
    basePath:"/"
}
service serviceEmptyName on testEP {

    resource function test1(http:Caller caller, http:Request req) {
        http:Response res = new;
        json responseJson = {"echo":"dispatched to empty service name"};
        res.setJsonPayload(responseJson);
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        path:"/*"
    }
    resource function proxy(http:Caller caller, http:Request req) {
        http:Response res = new;
        json responseJson = {"echo":"dispatched to a proxy service"};
        res.setJsonPayload(responseJson);
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }
}

service serviceWithNoAnnotation on testEP {

    resource function test1(http:Caller caller, http:Request req) {
        http:Response res = new;
        json responseJson = {"echo":"dispatched to a service without an annotation"};
        res.setJsonPayload(responseJson);
        error? err = caller->respond(res);
        if err is error {
            panic err;
        }
    }
}

service on mockEP1 {
    resource function testResource(http:Caller caller, http:Request req) {
        error? err = caller->respond({"echo":"dispatched to the service that neither has an explicitly defined basepath nor a name"});
        if err is error {
            panic err;
        }
    }
}

@http:ServiceConfig {
    compression: {enable: http:COMPRESSION_AUTO}
}
service on mockEP2 {
    resource function testResource(http:Caller caller, http:Request req) {
        error? err = caller->respond("dispatched to the service that doesn't have a name but has a config without a basepath");
        if err is error {
            panic err;
        }
    }
}
