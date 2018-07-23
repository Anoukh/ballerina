/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
package org.ballerinalang.test.statements.arrays;

import org.ballerinalang.launcher.util.BCompileUtil;
import org.ballerinalang.launcher.util.BRunUtil;
import org.ballerinalang.launcher.util.CompileResult;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.util.exceptions.BLangRuntimeException;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Test cases for ballerina.model.arrays.
 */
public class ArrayMutabilityTest {

    private CompileResult compileResult;

    @BeforeClass
    public void setup() {
        compileResult = BCompileUtil.compile("test-src/statements/arrays/array-mutability.bal");
    }

    @Test
    public void testValidArrayAssignment() {
        BValue[] returnValues = BRunUtil.invoke(compileResult, "testValidArrayAssignment");
    }

    @Test(description = "",
            expectedExceptions = {BLangRuntimeException.class},
            expectedExceptionsMessageRegExp =
                    ".*message: type mismatch: expected type 'Employee', found type 'Person.*")
    public void testAssignmentOfSuperTypeMember() {
        BRunUtil.invoke(compileResult, "testAssignmentOfSuperTypeMember");
    }

    @Test(description = "",
            expectedExceptions = {BLangRuntimeException.class},
            expectedExceptionsMessageRegExp =
                    ".*message: type mismatch: expected type 'Employee', found type 'Student.*")
    public void testInvalidAssignment() {
        BRunUtil.invoke(compileResult, "testInvalidAssignment");
    }
    @Test(description = "",
            expectedExceptions = {BLangRuntimeException.class},
            expectedExceptionsMessageRegExp =
                    ".*message: type mismatch: expected type 'int', found type 'null.*")
    public void testArrayWithBasicTypeCovariance() {
        BRunUtil.invoke(compileResult, "testArrayWithBasicTypeCovariance");
    }


}
