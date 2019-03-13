// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/io;
import ballerina/grpc;

listener grpc:Listener ep = new (9000);

// This is negative testcase, map field type is not supported currently. So we should be compilation error.
// Unsupported field type, field type map currently not supported.
service UnsupportedMapType on ep {

    resource function testInputMapType(grpc:Caller caller, MapMessage msg) {
        io:println(msg);
        string message = "Testing Map types";
        error? err1 = caller->send(message);
        if (err1 is error) {
            io:println("Error from Connector: " + err1.reason());
        } else {
            io:println("Server send response : " + message);
        }
        error? err2 = caller->complete();
        if err2 is error {
            panic err2;
        }
    }

    resource function testOutputMapType(grpc:Caller caller, string msg) {
        io:println(msg);
        MapMessage message = {};
        error? err1 = caller->send(message);
        if (err1 is error) {
            io:println("Error from Connector: " + err1.reason());
        } else {
            io:println("Server send response successfully");
        }
        error? err2 = caller->complete();
        if err2 is error {
            panic err2;
        }
    }
}

type MapMessage record {
    map<any> payload = {};
};
