import pytest
import pytest_asyncio
from starkware.starknet.testing.starknet import Starknet


@pytest_asyncio.fixture(scope="module")
async def comparison_operations(starknet: Starknet):
    return await starknet.deploy(
        source="./tests/src/kakarot/instructions/test_comparison_operations.cairo",
        cairo_path=["src"],
        disable_hint_validation=True,
    )


@pytest.mark.asyncio
class TestComparisonOperations:
    async def test__exec_lt__should_pop_0_and_1_and_push_0__when_0_not_lt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_lt__should_pop_0_and_1_and_push_0__when_0_not_lt_1().call()

    async def test__exec_lt__should_pop_0_and_1_and_push_1__when_0_lt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_lt__should_pop_0_and_1_and_push_1__when_0_lt_1().call()

    async def test__exec_gt__should_pop_0_and_1_and_push_0__when_0_not_gt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_gt__should_pop_0_and_1_and_push_0__when_0_not_gt_1().call()

    async def test__exec_gt__should_pop_0_and_1_and_push_1__when_0_gt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_gt__should_pop_0_and_1_and_push_1__when_0_gt_1().call()

    async def test__exec_slt__should_pop_0_and_1_and_push_0__when_0_not_slt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_slt__should_pop_0_and_1_and_push_0__when_0_not_slt_1().call()

    async def test__exec_slt__should_pop_0_and_1_and_push_1__when_0_slt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_slt__should_pop_0_and_1_and_push_1__when_0_slt_1().call()

    async def test__exec_sgt__should_pop_0_and_1_and_push_0__when_0_not_sgt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_sgt__should_pop_0_and_1_and_push_0__when_0_not_sgt_1().call()

    async def test__exec_sgt__should_pop_0_and_1_and_push_1__when_0_sgt_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_sgt__should_pop_0_and_1_and_push_1__when_0_sgt_1().call()

    async def test__exec_eq__should_pop_0_and_1_and_push_0__when_0_not_eq_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_eq__should_pop_0_and_1_and_push_0__when_0_not_eq_1().call()

    async def test__exec_eq__should_pop_0_and_1_and_push_1__when_0_eq_1(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_eq__should_pop_0_and_1_and_push_1__when_0_eq_1().call()

    async def test__exec_iszero__should_pop_0_and_push_0__when_0_is_not_zero(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_iszero__should_pop_0_and_push_0__when_0_is_not_zero().call()

    async def test__exec_iszero__should_pop_0_and_push_1__when_0_is_zero(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_iszero__should_pop_0_and_push_1__when_0_is_zero().call()

    async def test__exec_and__should_pop_0_and_1_and_push_0__when_0_and_1_are_not_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_and__should_pop_0_and_1_and_push_0__when_0_and_1_are_not_true().call()

    async def test__exec_and__should_pop_0_and_1_and_push_1__when_0_and_1_are_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_and__should_pop_0_and_1_and_push_1__when_0_and_1_are_true().call()

    async def test__exec_and__should_pop_0_and_1_and_push_0x89__when_0_is_0xC9_and_1_is_0xBD(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_and__should_pop_0_and_1_and_push_0x89__when_0_is_0xC9_and_1_is_0xBD().call()

    async def test__exec_or__should_pop_0_and_1_and_push_0__when_0_or_1_are_not_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_or__should_pop_0_and_1_and_push_0__when_0_or_1_are_not_true().call()

    async def test__exec_or__should_pop_0_and_1_and_push_1__when_0_or_1_are_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_or__should_pop_0_and_1_and_push_1__when_0_or_1_are_true().call()

    async def test__exec_or__should_pop_0_and_1_and_push_0xCD__when_0_is_0x89_and_1_is_0xC5(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_or__should_pop_0_and_1_and_push_0xCD__when_0_is_0x89_and_1_is_0xC5().call()

    async def test__exec_xor__should_pop_0_and_1_and_push_0__when_0_and_1_are_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_xor__should_pop_0_and_1_and_push_0__when_0_and_1_are_true().call()

    async def test__exec_xor__should_pop_0_and_1_and_push_0__when_0_and_1_are_not_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_xor__should_pop_0_and_1_and_push_0__when_0_and_1_are_not_true().call()

    async def test__exec_xor__should_pop_0_and_1_and_push_1__when_0_is_true_and_1_is_not_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_xor__should_pop_0_and_1_and_push_1__when_0_is_true_and_1_is_not_true().call()

    async def test__exec_xor__should_pop_0_and_1_and_push_1__when_0_is_not_true_and_1_is_true(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_xor__should_pop_0_and_1_and_push_1__when_0_is_not_true_and_1_is_true().call()

    async def test__exec_xor__should_pop_0_and_1_and_push_0x64__when_0_is_0xB9_and_1_is_0xDD(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_xor__should_pop_0_and_1_and_push_0x64__when_0_is_0xB9_and_1_is_0xDD().call()

    async def test__exec_byte__should_pop_0_and_1_and_push_0__when_0_is_less_than_16_bytes_and_1_is_23(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_byte__should_pop_0_and_1_and_push_0__when_0_is_less_than_16_bytes_and_1_is_23().call()

    async def test__exec_byte__should_pop_0_and_1_and_push_0__when_0_is_larger_than_16_bytes_and_1_is_8(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_byte__should_pop_0_and_1_and_push_0__when_0_is_larger_than_16_bytes_and_1_is_8().call()

    async def test__exec_shl__should_pop_0_and_1_and_push_left_shift(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_shl__should_pop_0_and_1_and_push_left_shift().call()

    async def test__exec_shr__should_pop_0_and_1_and_push_right_shift(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_shr__should_pop_0_and_1_and_push_right_shift().call()

    async def test__exec_sar__should_pop_0_and_1_and_push_shr(
        self, comparison_operations
    ):
        await comparison_operations.test__exec_sar__should_pop_0_and_1_and_push_shr().call()
