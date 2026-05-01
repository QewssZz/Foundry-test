// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 private number;

    // Функція для збереження числа
    function setNumber(uint256 _number) public {
        number = _number;
    }

    // Функція для отримання числа
    function getNumber() public view returns (uint256) {
        return number;
    }
}