// SPDX-License-Identifier: MIT

%lang starknet

from openzeppelin.access.ownable.library import Ownable
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.default_dict import default_dict_new
from starkware.starknet.common.syscalls import deploy as deploy_syscall
from starkware.starknet.common.syscalls import get_caller_address, get_tx_info

from kakarot.accounts.library import Accounts
from kakarot.constants import (
    native_token_address,
    contract_account_class_hash,
    externally_owned_account_class_hash,
    blockhash_registry_address,
    account_proxy_class_hash,
)
from kakarot.execution_context import ExecutionContext
from kakarot.instructions import EVMInstructions
from kakarot.instructions.system_operations import CreateHelper
from kakarot.interfaces.interfaces import IAccount, IContractAccount, IEth
from kakarot.memory import Memory
from kakarot.model import model
from kakarot.stack import Stack
from utils.utils import Helpers

// @title Kakarot main library file.
// @notice This file contains the core EVM execution logic.
namespace Kakarot {
    // @notice The constructor of the contract.
    // @dev Set up the initial owner, accounts class hash and native token.
    // @param owner The address of the owner of the contract.
    // @param native_token_address_ The ERC20 contract used to emulate ETH.
    // @param contract_account_class_hash_ The clash hash of the contract account.
    // @param externally_owned_account_class_hash_ The externally owned account class hash.
    // @param account_proxy_class_hash_ The account proxy class hash.
    func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        owner: felt,
        native_token_address_,
        contract_account_class_hash_,
        externally_owned_account_class_hash_,
        account_proxy_class_hash_,
    ) {
        Ownable.initializer(owner);
        native_token_address.write(native_token_address_);
        contract_account_class_hash.write(contract_account_class_hash_);
        externally_owned_account_class_hash.write(externally_owned_account_class_hash_);
        account_proxy_class_hash.write(account_proxy_class_hash_);
        return ();
    }

    // @notice Run the given bytecode with the given calldata and parameters
    // @dev starknet_contract_address and evm_contract_address can be set to 0 if
    //      there is no notion of deployed contract in the bytecode. Otherwise,
    //      they should match (ie. that
    //      compute_starknet_address(IAccount.get_evm_address(starknet_contract_address))
    //      shou equal starknet_contract_address. In a future version, either one or the
    //      other will be removed
    // @param starknet_contract_address The starknet contract address of the called contract
    // @param evm_contract_address The corresponding EVM contract address of the called contract
    // @param bytecode_len The length of the bytecode
    // @param bytecode The bytecode run
    // @param calldata_len The length of the calldata
    // @param calldata The calldata of the execution
    // @param value The value of the execution
    // @param gas_limit The gas limit of the execution
    // @param gas_price The gas price for the execution
    func execute{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }(
        starknet_contract_address: felt,
        evm_contract_address: felt,
        bytecode_len: felt,
        bytecode: felt*,
        calldata_len: felt,
        calldata: felt*,
        value: felt,
        gas_limit: felt,
        gas_price: felt,
    ) -> (
        stack_accesses_len: felt,
        stack_accesses: felt*,
        stack_len: felt,
        memory_accesses_len: felt,
        memory_accesses: felt*,
        memory_bytes_len: felt,
        starknet_contract_address: felt,
        evm_contract_address: felt,
        return_data_len: felt,
        return_data: felt*,
        gas_used: felt,
    ) {
        alloc_locals;

        // Prepare execution context
        let root_context = ExecutionContext.init_empty();
        let return_data: felt* = alloc();

        tempvar call_context = new model.CallContext(
            bytecode=bytecode,
            bytecode_len=bytecode_len,
            calldata=calldata,
            calldata_len=calldata_len,
            value=value,
        );

        let ctx = ExecutionContext.init(
            call_context=call_context,
            starknet_contract_address=starknet_contract_address,
            evm_contract_address=evm_contract_address,
            gas_limit=gas_limit,
            gas_price=gas_price,
            calling_context=root_context,
            return_data_len=0,
            return_data=return_data,
            read_only=FALSE,
        );

        // Compute intrinsic gas cost and update gas used
        let cost = ExecutionContext.compute_intrinsic_gas_cost(ctx);
        let ctx = ExecutionContext.increment_gas_used(self=ctx, inc_value=cost);

        // Start execution
        let ctx = EVMInstructions.run(ctx);
        ExecutionContext.maybe_throw_revert(ctx);

        // Finalize
        let summary = ExecutionContext.finalize(self=ctx);

        let memory_accesses_len = summary.memory.squashed_end - summary.memory.squashed_start;
        let stack_accesses_len = summary.stack.squashed_end - summary.stack.squashed_start;

        return (
            stack_accesses_len=stack_accesses_len,
            stack_accesses=summary.stack.squashed_start,
            stack_len=summary.stack.len_16bytes,
            memory_accesses_len=memory_accesses_len,
            memory_accesses=summary.memory.squashed_start,
            memory_bytes_len=summary.memory.bytes_len,
            starknet_contract_address=summary.starknet_contract_address,
            evm_contract_address=summary.evm_contract_address,
            return_data_len=summary.return_data_len,
            return_data=summary.return_data,
            gas_used=summary.gas_used,
        );
    }

    // @notice The Blockhash registry is used by the BLOCKHASH opcode
    // @dev Set the Blockhash registry contract address
    // @param blockhash_registry_address_ The address of the new blockhash registry contract.
    func set_blockhash_registry{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        blockhash_registry_address_: felt
    ) {
        Ownable.assert_only_owner();
        blockhash_registry_address.write(blockhash_registry_address_);
        return ();
    }

    // @notice The Blockhash registry is used by the BLOCKHASH opcode
    // @dev Get the Blockhash registry contract address
    // @return address The address of the current blockhash registry contract.
    func get_blockhash_registry{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (address: felt) {
        let (blockhash_registry_address_) = blockhash_registry_address.read();
        return (blockhash_registry_address_,);
    }

    // @notice Set the native Starknet ERC20 token used by kakarot.
    // @dev Set the native token which will emulate the role of ETH on Ethereum.
    // @param native_token_address_ The address of the native token.
    func set_native_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        native_token_address_: felt
    ) {
        Ownable.assert_only_owner();
        native_token_address.write(native_token_address_);
        return ();
    }

    // @notice Get the native token address
    // @dev Return the address used to emulate the role of ETH on Ethereum
    // @return native_token_address The address of the native token
    func get_native_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        native_token_address: felt
    ) {
        let (native_token_address_) = native_token_address.read();
        return (native_token_address_,);
    }

    // @notice Transfer "value" native tokens to "to"
    // @dev "from" parameter is taken from get_caller_address syscall
    // @param to_ The address the transaction is directed to.
    // @param value Integer of the value sent with this transaction
    // @return success Boolean to indicate success or failure of transfer
    func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        to_: felt, value: felt
    ) -> (success: felt) {
        alloc_locals;
        if (value == 0) {
            return (success=TRUE);
        }
        let (local native_token_address) = get_native_token();
        let (from_) = get_caller_address();
        let (recipient) = Accounts.compute_starknet_address(to_);
        let amount = Helpers.to_uint256(value);
        let (success) = IEth.transferFrom(
            contract_address=native_token_address, sender=from_, recipient=recipient, amount=amount
        );
        return (success=success);
    }

    // @notice Deploy contract account.
    // @dev First deploy a contract_account with no bytecode, then run the calldata as bytecode with the new address,
    //      then set the bytecode with the result of the initial run.
    // @param bytecode_len The deploy bytecode length.
    // @param bytecode The deploy bytecode.
    // @return starknet_contract_address The newly deployed starknet contract address.
    // @return evm_contract_address The evm address that is mapped to the newly deployed starknet contract address.
    func deploy_contract_account{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }(bytecode_len: felt, bytecode: felt*) -> (
        starknet_contract_address: felt, evm_contract_address: felt
    ) {
        alloc_locals;
        let (caller_address) = get_caller_address();
        let (sender_evm_address) = IAccount.get_evm_address(caller_address);
        let (nonce) = IAccount.get_nonce(caller_address);
        let (evm_contract_address) = CreateHelper.get_create_address(sender_evm_address, nonce);
        let (class_hash) = contract_account_class_hash.read();
        let (starknet_contract_address) = Accounts.create(class_hash, evm_contract_address);
        let (empty_array: felt*) = alloc();

        let (
            stack_accesses_len,
            stack_accesses,
            stack_len,
            memory_accesses_len,
            memory_accesses,
            memory_bytes_len,
            starknet_contract_address,
            evm_contract_address,
            return_data_len,
            return_data,
            gas_used,
        ) = execute(
            starknet_contract_address=starknet_contract_address,
            evm_contract_address=evm_contract_address,
            bytecode_len=bytecode_len,
            bytecode=bytecode,
            calldata_len=0,
            calldata=empty_array,
            value=0,
            gas_limit=0,
            gas_price=0,
        );

        // Update contract bytecode with execution result
        IContractAccount.write_bytecode(
            contract_address=starknet_contract_address,
            bytecode_len=return_data_len,
            bytecode=return_data,
        );
        return (
            starknet_contract_address=starknet_contract_address,
            evm_contract_address=evm_contract_address,
        );
    }

    // @notice Deploy a new externally owned account.
    // @param evm_contract_address The evm address that is mapped to the newly deployed starknet contract address.
    // @return starknet_contract_address The newly deployed starknet contract address.
    func deploy_externally_owned_account{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }(evm_contract_address: felt) -> (starknet_contract_address: felt) {
        let (class_hash) = externally_owned_account_class_hash.read();
        let (starknet_contract_address) = Accounts.create(class_hash, evm_contract_address);
        return (starknet_contract_address=starknet_contract_address);
    }

    // @notice The eth_call function as described in the RPC spec, see https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_call
    // @dev "from" parameter is taken from the get_caller_address syscall
    // @param to The address the transaction is directed to.
    // @param gas_limit Integer of the gas provided for the transaction execution
    // @param gas_price Integer of the gas price used for each paid gas
    // @param value Integer of the value sent with this transaction
    // @param data_len The length of the data
    // @param data Hash of the method signature and encoded parameters. For details see Ethereum Contract ABI in the Solidity documentation
    // @return return_data_len The length of the returned bytes
    // @return return_data The returned bytes array
    func eth_call{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }(to: felt, gas_limit: felt, gas_price: felt, value: felt, data_len: felt, data: felt*) -> (
        return_data_len: felt, return_data: felt*
    ) {
        let (success) = transfer(to, value);
        with_attr error_message("Kakarot: eth_call: failed to transfer {value} tokens to {to}") {
            assert success = TRUE;
        }

        // TODO: add check that target contract does not exist or has empty bytecode
        if (data_len == 0) {
            let (return_data) = alloc();
            return (0, return_data);
        }

        if (to == 0) {
            with_attr error_message("Kakarot: value should be 0 when deploying a contract") {
                assert value = 0;
            }
            let (starknet_contract_address, evm_contract_address) = deploy_contract_account(
                bytecode_len=data_len, bytecode=data
            );
            let (return_data) = alloc();
            assert [return_data] = evm_contract_address;
            assert [return_data + 1] = starknet_contract_address;
            return (2, return_data);
        } else {
            let (starknet_contract_address) = Accounts.compute_starknet_address(to);
            let (bytecode_len, bytecode) = IAccount.bytecode(
                contract_address=starknet_contract_address
            );
            let summary = execute(
                starknet_contract_address,
                to,
                bytecode_len,
                bytecode,
                data_len,
                data,
                value,
                gas_limit,
                gas_price,
            );
            return (summary.return_data_len, summary.return_data);
        }
    }

    // @notice Assert that the calling contract is a Kakarot account, ie. that it has been
    //         deployed by kakarot. This is currently required to make sure that evm and
    //         starknet addresses remain consistents along an execution
    // @dev Raise if the declared corresponding evm address (retrieved with get_evm_address)
    //      does not lead to the actual caller address
    func assert_caller_is_kakarot_account{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }() {
        alloc_locals;
        let (local starknet_caller_address) = get_caller_address();
        let (local evm_caller_address) = IAccount.get_evm_address(starknet_caller_address);
        let (local computed_starknet_address) = Accounts.compute_starknet_address(
            evm_caller_address
        );

        with_attr error_message("Kakarot: caller contract is not a Kakarot Account") {
            assert computed_starknet_address = starknet_caller_address;
        }

        return ();
    }

    // @notice The eth_send_transaction function as described in the RPC spec,
    //         see https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sendtransaction
    // @dev "from" parameter is taken from the get_caller_address syscall
    // @dev "nonce" parameter is taken from the caller account
    // @param to The address the transaction is directed to.
    // @param gas_limit Integer of the gas provided for the transaction execution
    // @param gas_price Integer of the gas price used for each paid gas
    // @param value Integer of the value sent with this transaction
    // @param data_len The length of the data
    // @param data Hash of the method signature and encoded parameters. For details see Ethereum Contract ABI in the Solidity documentation
    // @return return_data_len The length of the returned bytes
    // @return return_data The returned bytes array
    func eth_send_transaction{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr,
        bitwise_ptr: BitwiseBuiltin*,
    }(to: felt, gas_limit: felt, gas_price: felt, value: felt, data_len: felt, data: felt*) -> (
        return_data_len: felt, return_data: felt*
    ) {
        assert_caller_is_kakarot_account();
        return eth_call(to, gas_limit, gas_price, value, data_len, data);
    }
}
