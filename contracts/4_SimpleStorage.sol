// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 private number;
    address public owner;

    // Оголошуємо подію
    event NumberUpdated(address indexed updater, uint256 oldNumber, uint256 newNumber);

    constructor() {
        owner = msg.sender; // Власником стає той, хто розгортає контракт
    }

    // Функція для збереження числа (з перевірками)
    function setNumber(uint256 _number) public {
        require(msg.sender == owner, "Only owner can set number");
        require(_number != 0, "Number cannot be zero");

        uint256 oldNumber = number;
        number = _number;

        // Викликаємо подію
        emit NumberUpdated(msg.sender, oldNumber, _number);
    }

    function getNumber() public view returns (uint256) {
        return number;
    }
}