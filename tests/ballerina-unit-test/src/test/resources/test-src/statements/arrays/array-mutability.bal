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

// Super Type
type Person record {
    string name,
    !...
};

// Assignable to Person type
type Employee record {
    string name,
    boolean intern,
};

// Assignable to Employee type and Person Type
type Intern record {
    string name,
    boolean intern,
    int salary,
};

// Assignable to Person type
type Student record {
    string name,
    int studentId,
    !...
};

Person[] personArray;
Employee[] employeeArray;

Person person1 = { name: "Anoukh" };
Employee employee1 = { name: "Anoukh", intern: false };
Intern intern1 = { name: "Anoukh", intern: true, salary: 100 };
Student student1 = { name: "Anoukh", studentId: 001 };

function testValidArrayAssignment() {
    personArray = employeeArray;
    personArray[0] = employee1;
    personArray[1] = intern1;
}

function testAssignmentOfSuperTypeMember() {
    personArray = employeeArray;
    personArray[1] = person1;
}

function testInvalidAssignment() {
    personArray = employeeArray;
    personArray[1] = student1;
}

// TODO: Add basic type array tests