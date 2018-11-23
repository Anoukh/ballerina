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

function testBasicErrorMatch() returns string {
    error<string, map<string>> err1 = error ("Error Code", {message: "Msg"});
    match err1 {
        var error(reason, detail) => return "Matched with error : " + reason + " " + io:sprintf("%s", detail);
    }
    return "Default";
}

function testBasicErrorMatch2() returns string {
    error<string, map<string>> err1 = error ("Error Code", {message: "Msg"});
    (string, map)|error t1 = err1;
    match t1 {
        var (reason, detail) => return "Matched with tuple : " + reason + " " + io:sprintf("%s", detail);
        var error(reason, detail) => return "Matched with error : " + reason + " " + io:sprintf("%s", detail);
    }
    return "Default";
}

function testBasicErrorMatch3() returns string {
    error<string> err1 = error ("Error Code");
    (string, map)|error<string> t1 = err1;
    match t1 {
        var (reason, detail) => return "Matched with tuple : " + reason + " " + io:sprintf("%s", detail);
        var error(reason, detail) => return "Matched with error : " + reason + " " + io:sprintf("%s", detail);
    }
    return "Default";
}

type Foo record {
    boolean fatal;
};

type ER1 error<string, Foo>;
type ER2 error<string, map<any>>;

function testBasicErrorMatch4() returns string[] {
    ER1 er1 = error ("Error 1", {fatal: true});
    ER2 er2 = error ("Error 2", {message: "It's fatal"});

    string[] results = [foo(er1), foo(er2)];

    return results;
}

function foo(ER1|ER2 t1) returns string {
    match t1 {
        var error (reason, {fatal, message}) => {
            if fatal is boolean {
                return "Matched with Foo : " + fatal;
            } else if message is string {
                return "Matched with message : " + message;
            } else {
                return "Matched with fatal as Nil";
            }
        }
    }
    return "Default";
}