// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
// Виходимо з папки tests (../) і заходимо в contracts
import "../contracts/4_SimpleStorage.sol"; 

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;

    function setUp() public {
        simpleStorage = new SimpleStorage();
    }

    function test_SetNumber() public {
        simpleStorage.setNumber(42);
        assertEq(simpleStorage.getNumber(), 42);
    }

    function test_InitialValueIsZero() public {
        assertEq(simpleStorage.getNumber(), 0);
    }
}