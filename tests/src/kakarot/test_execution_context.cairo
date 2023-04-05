// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256

// Local dependencies
from utils.utils import Helpers
from kakarot.constants import Constants
from kakarot.model import model
from kakarot.execution_context import ExecutionContext

from tests.utils.helpers import TestHelpers

@external
func test__init__should_return_an_empty_execution_context{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    assert [bytecode] = 00;
    tempvar bytecode_len = 1;
    let (calldata) = alloc();
    assert [calldata] = '';

    // When
    local call_context: model.CallContext* = new model.CallContext(
        bytecode=bytecode, bytecode_len=bytecode_len, calldata=calldata, calldata_len=1, value=0
    );
    let calling_ctx = ExecutionContext.init_empty();
    let (return_data: felt*) = alloc();
    let result: model.ExecutionContext* = ExecutionContext.init(
        call_context,
        starknet_contract_address=0,
        evm_contract_address=0,
        gas_limit=Constants.TRANSACTION_GAS_LIMIT,
        gas_price=0,
        calling_context=calling_ctx,
        return_data_len=0,
        return_data=return_data,
        read_only=0,
    );

    // Then
    assert result.call_context.bytecode = bytecode;
    assert result.call_context.bytecode_len = 1;
    assert result.call_context.calldata = calldata;
    assert result.program_counter = 0;
    assert result.stopped = FALSE;
    assert result.stack.len_16bytes = 0;
    assert result.memory.bytes_len = 0;
    assert result.gas_used = 0;
    assert result.gas_limit = Constants.TRANSACTION_GAS_LIMIT;  // TODO: Add support for gas limit
    assert result.gas_price = 0;
    return ();
}

@external
func test__update_program_counter__should_set_pc_to_given_value{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    assert bytecode[0] = 56;
    assert bytecode[1] = 60;
    assert bytecode[2] = 0x0a;
    assert bytecode[3] = 0x5b;
    assert bytecode[4] = 60;
    assert bytecode[5] = 0x0b;
    tempvar bytecode_len = 6;

    // When
    let ctx: model.ExecutionContext* = TestHelpers.init_context(bytecode_len, bytecode);
    let result = ExecutionContext.update_program_counter(ctx, 3);

    // Then
    assert result.program_counter = 3;
    return ();
}

@external
func test__update_program_counter__should_fail__when_given_value_not_in_code_range{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    assert bytecode[0] = 56;
    assert bytecode[1] = 60;
    assert bytecode[2] = 0x0a;
    assert bytecode[3] = 0x5b;
    assert bytecode[4] = 60;
    assert bytecode[5] = 0x0b;
    tempvar bytecode_len = 6;

    // When & Then
    let ctx: model.ExecutionContext* = TestHelpers.init_context(bytecode_len, bytecode);
    let result = ExecutionContext.update_program_counter(ctx, 6);
    return ();
}

@external
func test__update_program_counter__should_fail__when_given_destination_that_is_not_JUMPDEST{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}() {
    // Given
    alloc_locals;
    let (bytecode) = alloc();
    assert bytecode[0] = 56;
    assert bytecode[1] = 60;
    assert bytecode[2] = 0x0a;
    assert bytecode[3] = 0x5b;
    assert bytecode[4] = 60;
    assert bytecode[5] = 0x0b;
    tempvar bytecode_len = 6;

    // When & Then
    let ctx: model.ExecutionContext* = TestHelpers.init_context(bytecode_len, bytecode);
    let result = ExecutionContext.update_program_counter(ctx, 2);
    return ();
}
