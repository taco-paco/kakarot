import pytest
import pytest_asyncio
from starkware.starknet.testing.starknet import Starknet

from tests.utils.errors import kakarot_error


@pytest_asyncio.fixture(scope="module")
async def exchange_operations(starknet: Starknet):
    return await starknet.deploy(
        source="./tests/src/kakarot/instructions/test_exchange_operations.cairo",
        cairo_path=["src"],
        disable_hint_validation=True,
    )


@pytest.mark.asyncio
class TestExchangeOperations:
    async def test_everything_context(self, exchange_operations):
        await exchange_operations.test__util_init_stack__should_create_stack_with_top_and_preswapped_elements().call()
        await exchange_operations.test__exec_swap1__should_swap_1st_and_2nd().call()
        await exchange_operations.test__exec_swap2__should_swap_1st_and_3rd().call()
        await exchange_operations.test__exec_swap8__should_swap_1st_and_9th().call()
        await exchange_operations.test__exec_swap9__should_swap_1st_and_10th().call()
        await exchange_operations.test__exec_swap10__should_swap_1st_and_11th().call()
        await exchange_operations.test__exec_swap11__should_swap_1st_and_12th().call()
        await exchange_operations.test__exec_swap12__should_swap_1st_and_13th().call()
        await exchange_operations.test__exec_swap13__should_swap_1st_and_14th().call()
        await exchange_operations.test__exec_swap14__should_swap_1st_and_15th().call()
        await exchange_operations.test__exec_swap15__should_swap_1st_and_16th().call()
        await exchange_operations.test__exec_swap16__should_swap_1st_and_17th().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap1__should_fail__when_index_1_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap2__should_fail__when_index_2_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap8__should_fail__when_index_8_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap9__should_fail__when_index_9_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap10__should_fail__when_index_10_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap11__should_fail__when_index_11_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap12__should_fail__when_index_12_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap13__should_fail__when_index_13_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap14__should_fail__when_index_14_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap15__should_fail__when_index_15_is_underflow().call()

        with kakarot_error("Kakarot: StackUnderflow"):
            await exchange_operations.test__exec_swap16__should_fail__when_index_16_is_underflow().call()
