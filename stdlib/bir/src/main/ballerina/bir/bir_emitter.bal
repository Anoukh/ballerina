import ballerina/io;


type BirEmitter object {

    private Package pkg;
    private TypeEmitter typeEmitter;
    private InstructionEmitter insEmitter;
    private TerminalEmitter termEmitter;

    function __init (Package pkg){
        self.pkg = pkg;
        self.typeEmitter = new;
        self.insEmitter = new;
        self.termEmitter = new;
    }


    function emitPackage() {
        println("################################# Begin bir program #################################");
        println("org - ", self.pkg.org.value);
        println("name - ", self.pkg.name.value);
        // println("version - " + pkg.versionValue);
        
        println(); // empty line
        self.emitTypeDefs();
        self.emitFunctions();
        println("################################## End bir program ##################################");
    }

    function emitTypeDefs() {
        foreach var bTypeDef in self.pkg.typeDefs {
            self.emitTypeDef(bTypeDef);
            println();
        }
    }

    function emitTypeDef(TypeDef bTypeDef) {
        print(bTypeDef.visibility, " type ", bTypeDef.name.value, " ");
        self.typeEmitter.emitType(bTypeDef.typeValue);
        println(";");
    }

    function emitFunctions() {
        foreach var bFunction in self.pkg.functions {
            self.emitFunction(bFunction);
            println();
        }
    }

    function emitFunction(Function bFunction) {
        print(bFunction.visibility, " function ", bFunction.name.value, " ");
        self.typeEmitter.emitType(bFunction.typeValue);
        println(" {");
        foreach var v in bFunction.localVars {
            self.typeEmitter.emitType(v.typeValue, tabs="\t");
            println(" ", v.name.value, "\t// local");
        }
        println();// empty line
        foreach var b in bFunction.basicBlocks {
            self.emitBasicBlock(b, "\t");
            println();// empty line
        }
        println("}");
    }

    function emitBasicBlock(BasicBlock bBasicBlock, string tabs) {
        println(tabs, bBasicBlock.id.value, " {");
        foreach var i in bBasicBlock.instructions {
            self.insEmitter.emitIns(i, tabs = tabs + "\t");
        }
        self.termEmitter.emitTerminal(bBasicBlock.terminator, tabs = tabs + "\t");
        println(tabs, "}");
    }
};

type InstructionEmitter object {
    private OperandEmitter opEmitter;

    function __init() {
        self.opEmitter = new;
    }

    function emitIns(Instruction ins, string tabs = "") {
        if (ins is Move) {
            print(tabs);
            self.opEmitter.emitOp(ins.lhsOp);
            print(" = ", ins.kind, " ");
            self.opEmitter.emitOp(ins.rhsOp);
            println();
        } else if (ins is BinaryOp) {
            print(tabs);
            self.opEmitter.emitOp(ins.lhsOp);
            print(" = ", ins.kind, " ");
            self.opEmitter.emitOp(ins.rhsOp1);
            print(" ");
            self.opEmitter.emitOp(ins.rhsOp2);
            println();
        } else if (ins is ConstantLoad) {
            print(tabs);
            self.opEmitter.emitOp(ins.lhsOp);
            println(" = ", ins.kind, " ", ins.value);
        }
    }
};

type TerminalEmitter object {
    private OperandEmitter opEmitter;

    function __init() {
        self.opEmitter = new;
    }

    function emitTerminal(Terminator term, string tabs = "") {
        if (term is Call) {
            print(tabs);
            VarRef? lhsOp = term.lhsOp;
            if (lhsOp is VarRef) {
                self.opEmitter.emitOp(lhsOp);
                print(" = ");
            }
            print(term.name.value, "(");
            int i = 0;
            foreach var o in term.args {
                if (i != 0) {
                    print(", "); 
                }
                self.opEmitter.emitOp(o);    
                i = i + 1;            
            }
            print(") -> ", term.thenBB.id.value, ";");
        } else if (term is Branch) {
            print(tabs, "branch ");
            self.opEmitter.emitOp(term.op);
            println(" [true:", term.trueBB.id.value, ", false:", term.falseBB.id.value,"];");
        } else if (term is GOTO) {
            println(tabs, "goto ", term.targetBB.id.value, ";");
        } else { //if (term is Return) {
            println(tabs, "return;");
        }
    }
};

type OperandEmitter object {
    function emitOp(Operand op, string tabs = "") {
        // if (op is VarRef) {
            print(op.variableDcl.name.value);
        // }
        // TODO add the rest, currently only have var ref
    }
};

type TypeEmitter object {
    
    function emitType(BType typeVal, string tabs = "") {
        if (typeVal is BTypeInt) {
            print(tabs, typeVal);
        } else if (typeVal is BTypeString) {
            print(tabs, typeVal);
        } else if (typeVal is BRecordType) {
            self.emitRecordType(typeVal, tabs);
        } else if (typeVal is BObjectType) {
            self.emitObjectType(typeVal, tabs);
        } else if (typeVal is BInvokableType) {
            self.emitInvokableType(typeVal, tabs);
        } else if (typeVal is BUnionType) {
            self.emitUnionType(typeVal, tabs);
        } else if (typeVal is BTypeNil) {
            print("()");
        }
    }

    function emitRecordType(BRecordType bRecordType, string tabs) {
        println("record { \\\\ sealed - ", bRecordType.sealed);
        foreach var f in bRecordType.fields {
            self.emitType(f.typeValue, tabs = tabs + "\t");
            println(" ", f.name.value);
        }
        self.emitType(bRecordType.restFieldType, tabs = tabs + "\t");
        println("...");
        print(tabs, "}");
    }

    function emitObjectType(BObjectType bObjectType, string tabs) {
        println("object {");
        foreach var f in bObjectType.fields {
            print(tabs + "\t", f.visibility);
            self.emitType(f.typeValue);
            println(" ", f.name.value);
        }
        print(tabs, "}");
    }

    function emitInvokableType(BInvokableType bInvokableType, string tabs) {
        print(tabs, "(");
        // int pCount = bInvokableType.paramTypes.size(); 
        int i = 0;
        foreach var p in bInvokableType.paramTypes {
            if (i != 0) {
                print(", ");
            }
            self.emitType(p);
            i = i + 1;
        }
        print(") -> ");
        self.emitType(bInvokableType.retType);
    }

    function emitUnionType(BUnionType bUnionType, string tabs) {
        int i = 0;
        foreach var t in bUnionType.members {
            if (i != 0) {
                print(" | ");
            }
            self.emitType(t, tabs = tabs);
            i = i + 1;
        }
    }
};


function println(any... vals) {
    io:println(...vals);
}

function print(any... vals) {
    io:print(...vals);
}