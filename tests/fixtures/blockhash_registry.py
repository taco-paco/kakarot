import json
from pathlib import Path
from typing import Dict, Union

import pytest
import pytest_asyncio
from starkware.starknet.testing.starknet import Starknet

from tests.utils.uint256 import int_to_uint256


@pytest.fixture(scope="session")
def blockhashes() -> Dict[str, Union[Dict[str, int], int]]:
    # For testing, we use the mock file
    with open(Path("sequencer") / "mock_blockhashes.json") as file:
        blockhashes = json.load(file)
    return blockhashes


@pytest_asyncio.fixture(scope="session")
async def blockhash_registry(starknet: Starknet, blockhashes: dict):
    owner = 1
    registry = await starknet.deploy(
        source="./src/kakarot/registry/blockhash/blockhash_registry.cairo",
        cairo_path=["src"],
        disable_hint_validation=True,
        constructor_calldata=[owner],
    )
    await registry.set_blockhashes(
        block_number=[
            int_to_uint256(int(x)) for x in blockhashes["last_256_blocks"].keys()
        ],
        block_hash=list(blockhashes["last_256_blocks"].values()),
    ).execute(caller_address=owner)
    return registry
