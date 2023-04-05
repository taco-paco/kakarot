// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

// Local dependencies
from utils.utils import Helpers
from kakarot.model import model
from kakarot.stack import Stack
from kakarot.execution_context import ExecutionContext
from kakarot.instructions.stop_and_arithmetic_operations import StopAndArithmeticOperations
from tests.utils.helpers import TestHelpers

@external
func test__exec_add__should_add_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_add(ctx);

    // Then
    assert result.gas_used = 3;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(5, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_mul__should_mul_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_mul(ctx);

    // Then
    assert result.gas_used = 5;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(6, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_sub__should_sub_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_sub(ctx);

    // Then
    assert result.gas_used = 3;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(1, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_div__should_div_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_div(ctx);

    // Then
    assert result.gas_used = 5;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(1, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_sdiv__should_signed_div_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_sdiv(ctx);

    // Then
    assert result.gas_used = 5;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(1, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_mod__should_mod_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_mod(ctx);

    // Then
    assert result.gas_used = 5;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(1, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_smod__should_smod_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_smod(ctx);

    // Then
    assert result.gas_used = 5;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(1, 0);
    let (stack, index1) = Stack.peek(stack, 1);
    assert index1 = Uint256(1, 0);
    return ();
}

@external
func test__exec_addmod__should_add_0_and_1_and_div_rem_by_2{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_addmod(ctx);

    // Then
    assert result.gas_used = 8;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 1;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(1, 0);
    return ();
}

@external
func test__exec_mulmod__should_mul_0_and_1_and_div_rem_by_2{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_mulmod(ctx);

    // Then
    assert result.gas_used = 8;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 1;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(0, 0);
    return ();
}

@external
func test__exec_exp__should_exp_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_exp(ctx);

    // Then
    assert result.gas_used = 10;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(9, 0);
    return ();
}

@external
func test__exec_signextend__should_signextend_0_and_1{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    let stack: model.Stack* = Stack.init();

    let stack: model.Stack* = Stack.push(stack, Uint256(1, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(2, 0));
    let stack: model.Stack* = Stack.push(stack, Uint256(3, 0));
    let ctx: model.ExecutionContext* = TestHelpers.init_context_with_stack(0, bytecode, stack);

    // When
    let result = StopAndArithmeticOperations.exec_signextend(ctx);

    // Then
    assert result.gas_used = 5;
    let len: felt = result.stack.len_16bytes / 2;
    assert len = 2;
    let (stack, index0) = Stack.peek(result.stack, 0);
    assert index0 = Uint256(2, 0);
    return ();
}

@external
func test__exec_stop{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    alloc_locals;
    let (bytecode) = alloc();
    let ctx: model.ExecutionContext* = TestHelpers.init_context(0, bytecode);
    assert ctx.stopped = FALSE;

    let stopped_ctx = StopAndArithmeticOperations.exec_stop(ctx);

    assert stopped_ctx.stopped = TRUE;

    return ();
}
