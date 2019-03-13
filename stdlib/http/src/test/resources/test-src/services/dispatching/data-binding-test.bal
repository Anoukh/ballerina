import ballerina/http;
import ballerina/mime;

listener http:MockListener testEP = new(9090);

type Person record {
    string name;
    int age;
    !...;
};

type Stock record {
    int id;
    float price;
    !...;
};

service echo on testEP {

    @http:ResourceConfig {
        body: "person"
    }
    resource function body1(http:Caller caller, http:Request req, string person) {
        json responseJson = { "Person": person };
        error? err = caller->respond(untaint responseJson);
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/body2/{key}",
        body: "person"
    }
    resource function body2(http:Caller caller, http:Request req, string key, string person) {
        json responseJson = { Key: key, Person: person };
        error? err = caller->respond(untaint responseJson);
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["GET", "POST"],
        body: "person"
    }
    resource function body3(http:Caller caller, http:Request req, json person) {
        json name = untaint person.name;
        json team = untaint person.team;
        error? err = caller->respond({ Key: name, Team: team });
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        body: "person"
    }
    resource function body4(http:Caller caller, http:Request req, xml person) {
        string name = untaint person.getElementName();
        string team = untaint person.getTextValue();
        error? err = caller->respond({ Key: name, Team: team });
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        body: "person"
    }
    resource function body5(http:Caller caller, http:Request req, byte[] person) {
        string name = untaint mime:byteArrayToString(person, "UTF-8");
        error? err = caller->respond({ Key: name });
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        body: "person"
    }
    resource function body6(http:Caller caller, http:Request req, Person person) {
        string name = untaint person.name;
        int age = untaint person.age;
        error? err = caller->respond({ Key: name, Age: age });
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        body: "person"
    }
    resource function body7(http:Caller caller, http:Request req, Stock person) {
        error? err = caller->respond(());
        if err is error {
            panic err;
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        body: "persons"
    }
    resource function body8(http:Caller caller, http:Request req, Person[] persons) {
        var jsonPayload = json.convert(persons);
        if (jsonPayload is json) {
            error? err = caller->respond(untaint jsonPayload);
            if err is error {
                panic err;
            }
        } else {
            error? err = caller->respond(untaint string.convert(jsonPayload.detail().message));
            if err is error {
                panic err;
            }
        }
    }
}
