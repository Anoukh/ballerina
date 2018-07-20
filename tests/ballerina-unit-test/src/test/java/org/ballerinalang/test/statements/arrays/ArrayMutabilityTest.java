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

//    @Test
//    public void testNegativeSealedArrays() {
//        BAssertUtil.validateError(resultNegative, 0, "array index out of range: index: '5', size: '5'", 19, 30);
//        BAssertUtil.validateError(resultNegative, 1, "array index out of range: index: '5', size: '5'", 25, 33);
//        BAssertUtil.validateError(
//                resultNegative, 2, "size mismatch in sealed array. expected '4', but found '3'", 30, 31);
//        BAssertUtil.validateError(
//                resultNegative, 3, "size mismatch in sealed array. expected '4', but found '5'", 31, 31);
//        BAssertUtil.validateError(
//                resultNegative, 4, "array index out of range: index: '5', size: '5'", 37, 18);
//        BAssertUtil.validateError(
//                resultNegative, 5, "array index out of range: index: '5', size: '5'", 38, 18);
//        BAssertUtil.validateError(
//                resultNegative, 6, "invalid usage of sealed type: array not initialized", 39, 5);
//        BAssertUtil.validateError(
//                resultNegative, 7, "incompatible types: expected 'int[3]', found 'int[]'", 46, 17);
//        BAssertUtil.validateError(
//                resultNegative, 8, "incompatible types: expected 'boolean[4]', found 'boolean[3]'", 52, 47);
//        BAssertUtil.validateError(
//                resultNegative, 9, "incompatible types: expected 'string[2]', found 'string[]'", 52, 34);
//        BAssertUtil.validateError(
//                resultNegative, 10, "ambiguous type 'int|int[]|int[4]'", 63, 30);
//        BAssertUtil.validateError(
//                resultNegative, 11, "ambiguous type 'int|int[]|int[4]|int[5]'", 65, 40);
//        BAssertUtil.validateError(
//                resultNegative, 12, "unreachable pattern: preceding patterns are too" +
//                        " general or the pattern ordering is not correct", 73, 9);
//        BAssertUtil.validateError(
//                resultNegative, 13, "size mismatch in sealed array. expected '4', but found '2'", 78, 18);
//        BAssertUtil.validateError(
//                resultNegative, 14, "size mismatch in sealed array. expected '4', but found '5'", 79, 18);
//        BAssertUtil.validateError(
//                resultNegative, 15, "array index out of range: index: '4', size: '4'", 82, 8);
//        BAssertUtil.validateError(
//                resultNegative, 16, "invalid usage of sealed type: can not infer array size", 84, 21);
//        BAssertUtil.validateError(
//                resultNegative, 17, "incompatible types: expected 'json[3]', found 'json[]'", 86, 18);
//    }

}
