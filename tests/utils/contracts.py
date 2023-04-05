import json
from pathlib import Path
from typing import List, Optional, cast

from starkware.starknet.testing.starknet import StarknetContract
from web3 import Web3
from web3._utils.abi import map_abi_data
from web3._utils.events import get_event_data
from web3._utils.normalizers import BASE_RETURN_NORMALIZERS
from web3.contract import Contract
from web3.types import LogReceipt

from tests.utils.helpers import hex_string_to_bytes_array
from tests.utils.reporting import traceit


def get_matching_logs_for_event(codec, event_abi, log_receipts) -> List[dict]:
    logs = []
    for log_receipt in log_receipts:
        try:
            event_data = get_event_data(codec, event_abi, log_receipt)
            logs += [event_data.args]
        except:
            pass
    return logs


def use_kakarot_backend(
    contract: Contract, kakarot: StarknetContract, evm_contract_address: int
):
    """
    Wrap a web3.contract to use kakarot as backend.
    """

    # query_logs enables three cases
    # no kwargs means you get all of the log_receipts
    # when a contract is supplied, you get all the log entries that correspond to the contract's event abi
    # when a contract is supplied with an event name, you get the log entries that match that event name
    def query_logs(self_contract, *args, **kwargs):
        logs = []
        codec = Web3().codec
        contract = kwargs.pop("contract", None)
        event_name = kwargs.pop("event_name", None)
        log_receipts = self_contract.raw_log_receipts

        # Case 1: No contract key supplied
        # return all raw logs
        if contract is None:
            return log_receipts

        # Case 2: Contract key supplied, no event name
        # user gets all the events associated with a contract
        if event_name is None:
            for event_abi in contract.events._events:
                logs += get_matching_logs_for_event(codec, event_abi, log_receipts)
            return logs

        # Case 3: Contract key and event name supplied
        event_abi = next(
            (
                event_abi
                for event_abi in contract.events._events
                if event_abi["name"] == event_name
            ),
            None,
        )
        if event_abi is None:
            raise ValueError(
                f"Cannot find event ABI for {event_name} in contract {contract._contract_name}"
            )
        logs += get_matching_logs_for_event(codec, event_abi, log_receipts)
        return logs

    def wrap_zk_evm(fun: str, evm_contract_address: int):
        """
        Decorator to update contract.fun to target kakarot instead.
        """

        async def _wrapped(contract, *args, **kwargs):
            abi = contract.get_function_by_name(fun).abi
            gas_limit = kwargs.pop("gas_limit", 1_000_000_000)
            value = kwargs.pop("value", 0)
            # 0 is the default caller_address in both call and execute
            caller_address = kwargs.pop("caller_address", 0)
            call_kwargs = {
                "to": evm_contract_address,
                "value": value,
                "gas_limit": gas_limit,
                "gas_price": 0,
                "data": hex_string_to_bytes_array(
                    contract.encodeABI(fun, args, kwargs)
                ),
            }

            if abi["stateMutability"] == "view":
                prepared_call = kakarot.eth_call(**call_kwargs)
                res = await prepared_call.call(caller_address=caller_address)
            else:
                prepared_call = kakarot.eth_send_transaction(**call_kwargs)
                res = await prepared_call.execute(caller_address=caller_address)
            if prepared_call._traced:
                traceit.pop_record()
                traceit.record_tx(
                    res,
                    contract_name=contract._contract_name,
                    attr_name=fun,
                    args=args,
                    kwargs=kwargs,
                )

            codec = Web3().codec
            types = [o["type"] for o in abi["outputs"]]
            data = bytearray(res.result.return_data)
            decoded = codec.decode(types, data)
            normalized = map_abi_data(BASE_RETURN_NORMALIZERS, types, decoded)
            result = normalized[0] if len(normalized) == 1 else normalized
            log_receipts = []
            for log_index, event in enumerate(res.raw_events):
                # Using try/except as some events are emitted by cairo code and not LOG opcode
                try:
                    log_receipts.append(
                        LogReceipt(
                            address=Web3.toChecksumAddress(
                                f"{evm_contract_address:040x}"
                            ),
                            blockHash=bytes(),
                            blockNumber=bytes(),
                            data=bytes(event.data),
                            logIndex=log_index,
                            topic=bytes(),
                            topics=[
                                bytes.fromhex(
                                    # event "keys" in cairo are event "topics" in solidity
                                    # they're returned as list where consecutive values are indeed
                                    # low, high, low, high, etc. of the Uint256 cairo representation
                                    # of the bytes32 topics. This recomputes the original topic
                                    f"{(event.keys[i] + 2**128 * event.keys[i + 1]):064x}"
                                )
                                for i in range(0, len(event.keys), 2)
                            ],
                            transactionHash=bytes(),
                            transactionIndex=0,
                        )
                    )
                except:
                    continue

            for event_abi in contract.events._events:
                logs = get_matching_logs_for_event(codec, event_abi, log_receipts)
                setattr(contract.events, event_abi["name"], logs)

            setattr(contract, "raw_log_receipts", log_receipts)
            setattr(contract, "tx", res)

            return result

        return _wrapped

    for fun in contract.functions:
        setattr(
            contract,
            fun,
            classmethod(wrap_zk_evm(fun, evm_contract_address)),
        )
    setattr(contract, "query_logs", classmethod(query_logs))
    return contract


# When fetching a contract, you need to provide a contract_app and contract_name
# to get the corresponding solidity file.
# An app is a group of solidity files living in tests/integration/solidity_contracts.
#
# Example: get_contract("Solmate", "ERC721") will load the ERC721.sol file in the tests/integration/solidity_contracts/Solmate folder
# Example: get_contract("StarkEx", "StarkExchange") will load the StarkExchange.sol file in the tests/integration/solidity_contracts/StarkEx/starkex folder
#
def get_contract(
    contract_app: str, contract_name: str, contract_alias: Optional[str] = None
) -> Contract:
    """
    Return a web3.contract instance based on the corresponding solidity files
    defined in tests/integration/solidity_files.

    If contract_alias is provided, use it instead of contract_name for the result of compilation_outputs.
    """
    solidity_contracts_dir = Path("tests") / "integration" / "solidity_contracts"
    target_solidity_file_path = list(
        (solidity_contracts_dir / contract_app).glob(f"**/{contract_name}.sol")
    )
    if len(target_solidity_file_path) != 1:
        raise ValueError(f"Cannot locate a unique {contract_name} in {contract_app}")

    if contract_alias:
        contract_name = contract_alias

    compilation_outputs = [
        json.load(open(file))
        for file in (
            (solidity_contracts_dir / "build").glob(f"**/{contract_name}.json")
        )
    ]

    compilation_output = [
        compilation_output
        for compilation_output in compilation_outputs
        if compilation_output["metadata"]["settings"]["compilationTarget"].get(
            str(target_solidity_file_path[0])
        )
    ]
    if len(compilation_output) != 1:
        raise ValueError(
            f"Cannot locate a unique compilation output for target {target_solidity_file_path[0]}: "
            f"found {len(compilation_output)} outputs:\n{compilation_output}"
        )

    contract = Web3().eth.contract(
        abi=compilation_output[0]["abi"],
        bytecode=compilation_output[0]["bytecode"]["object"],
    )
    setattr(contract, "_contract_name", contract_name)
    return cast(Contract, contract)
