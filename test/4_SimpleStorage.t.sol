// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/4_SimpleStorage.sol"; // переконайся, що шлях правильний

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;

    // Створюємо тестові адреси
    address public OWNER = makeAddr("Owner");
    address public STRANGER = makeAddr("Stranger");

    // Дублюємо подію з контракту для тестування (expectEmit)
    event NumberUpdated(address indexed updater, uint256 oldNumber, uint256 newNumber);

    function setUp() public {
        // Розгортаємо контракт від імені OWNER
        vm.prank(OWNER);
        simpleStorage = new SimpleStorage();
    }

    // -----------------------------------------------------------
    // Тест 1: Підміна msg.sender (vm.prank) + Очікуваний Revert
    // -----------------------------------------------------------
    function test_RevertWhen_CallerIsNotOwner() public {
        // Підміняємо msg.sender на чужу адресу
        vm.prank(STRANGER);

        // Кажемо Foundry чекати конкретну помилку
        vm.expectRevert("Only owner can set number");
        
        // Робимо виклик, який має провалитися
        simpleStorage.setNumber(42);
    }

    // -----------------------------------------------------------
    // Тест 2: Очікувана подія (vm.expectEmit)
    // -----------------------------------------------------------
    function test_SetNumber_EmitsEvent() public {
        // Налаштовуємо expectEmit: true для першого indexed (updater) параметра. 
        // 2 і 3 параметри у нас не indexed, тому false. 
        // Останній true перевіряє data (oldNumber та newNumber).
        vm.expectEmit(true, false, false, true);
        
        // 1. Спочатку декларуємо, ЯКУ подію ми очікуємо побачити (ми чекаємо, що 0 зміниться на 777)
        emit NumberUpdated(OWNER, 0, 777);
        
        // 2. Від імені OWNER робимо реальний виклик, який викличе цю подію
        vm.prank(OWNER);
        simpleStorage.setNumber(777);
    }

    // -----------------------------------------------------------
    // Тест 3: Fuzz-тест (випадкові значення)
    // -----------------------------------------------------------
    function testFuzz_setNumber_WithAnyValidAmount(uint256 newNumber) public {
        // Кажемо Foundry генерувати будь-які числа, ОКРІМ нуля 
        // (бо у нас є require(_number != 0))
        vm.assume(newNumber > 0);

        // Робимо виклик від імені власника з випадковим числом
        vm.prank(OWNER);
        simpleStorage.setNumber(newNumber);

        // Перевіряємо, чи контракт правильно зберіг це випадкове число
        assertEq(simpleStorage.getNumber(), newNumber);
    }
}