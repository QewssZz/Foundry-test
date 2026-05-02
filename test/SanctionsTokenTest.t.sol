// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TestToken} from "../src/TestToken.sol"; // Вкажи правильний шлях до твого контракту

contract SanctionsTokenTest is Test {
    TestToken public token;

    // Створюємо тестові адреси
    address public owner = address(this); // Тестовий контракт буде власником (deployer)
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    uint256 public constant INITIAL_BALANCE = 1000 * 10**18;

    /**
     * @dev Функція setUp() запускається автоматично перед кожним тестом.
     * Тут ми розгортаємо контракт і видаємо початкові токени для тестів.
     */
    function setUp() public {
        token = new TestToken(); // owner автоматично стає address(this)
        
        // Випускаємо токени для user1 та user2 для подальших тестів
        token.mint(user1, INITIAL_BALANCE);
        token.mint(user2, INITIAL_BALANCE);
    }

    /**
     * 1. Успішний переказ токенів між двома звичайними адресами.
     */
    function test_SuccessfulTransfer() public {
        uint256 transferAmount = 100 * 10**18;

        // Імітуємо виклик від user1
        vm.prank(user1);
        token.transfer(user2, transferAmount);

        // Перевіряємо, чи змінилися баланси правильно
        assertEq(token.balanceOf(user1), INITIAL_BALANCE - transferAmount);
        assertEq(token.balanceOf(user2), INITIAL_BALANCE + transferAmount);
    }

    /**
     * 2. Перевірка, що власник може додати адресу до чорного списку.
     */
    function test_OwnerCanBlacklist() public {
        // Додаємо user1 до чорного списку
        token.addToBlacklist(user1);

        // Перевіряємо статус
        assertTrue(token.isBlacklisted(user1));
    }

    /**
     * 3. Перевірка, що транзакція скасовується, 
     * якщо користувач з чорного списку намагається відправити токени.
     */
    function test_RevertWhenSenderIsBlacklisted() public {
        uint256 transferAmount = 100 * 10**18;

        // Власник додає user1 до чорного списку
        token.addToBlacklist(user1);

        // Імітуємо транзакцію від заблокованого user1
        vm.prank(user1);
        
        // Очікуємо, що наступний виклик завершиться помилкою (revert) з вказаним повідомленням
        vm.expectRevert("Blacklisted address");
        token.transfer(user2, transferAmount);
    }

    /**
     * 4. Перевірка, що транзакція скасовується, 
     * якщо хтось намагається відправити токени на заблоковану адресу.
     */
    function test_RevertWhenRecipientIsBlacklisted() public {
        uint256 transferAmount = 100 * 10**18;

        // Власник додає user2 до чорного списку
        token.addToBlacklist(user2);

        // Імітуємо транзакцію від незаблокованого user1 до заблокованого user2
        vm.prank(user1);
        
        // Очікуємо revert
        vm.expectRevert("Blacklisted address");
        token.transfer(user2, transferAmount);
    }

    /**
     * 5. Перевірка контролю доступу: звичайний користувач не може керувати чорним списком.
     */
    function test_RevertIf_NonOwnerTriesToBlacklist() public {
        // Очікувана кастомна помилка від OpenZeppelin v5
        bytes memory expectedRevert = abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1);

        // --- Сценарій 1: Спроба додати до чорного списку ---
        
        // Імітуємо виклик від звичайного користувача (user1)
        vm.prank(user1);
        
        // Очікуємо помилку OwnableUnauthorizedAccount з адресою user1
        vm.expectRevert(expectedRevert);
        token.addToBlacklist(user2);

        // --- Сценарій 2: Спроба видалити з чорного списку ---
        
        // Спочатку власник (owner) успішно додає user2 до чорного списку, 
        // щоб ми могли протестувати саме помилку доступу при видаленні, а не помилку "не в чорному списку"
        token.addToBlacklist(user2);

        // Знову імітуємо виклик від user1
        vm.prank(user1);
        
        // Очікуємо ту саму помилку доступу
        vm.expectRevert(expectedRevert);
        token.removeFromBlacklist(user2);
    }

    /**
     * 6. Fuzz-тестування: перевірка, що відправка токенів на заблоковану адресу
     * завжди скасовується, незалежно від адреси отримувача та суми переказу.
     */
    function testFuzz_BlacklistTransferReverts(address randomUser, uint256 randomAmount) public {
        // 1. Відкидаємо нерелевантні для цього сценарію адреси
        vm.assume(randomUser != address(0)); // Нульова адреса задіяна у mint/burn
        vm.assume(randomUser != address(token)); // Уникаємо адреси самого контракту
        vm.assume(randomUser != user1); // Відкидаємо user1, оскільки він буде відправником

        // 2. Власник (address(this)) додає випадкову адресу до чорного списку
        token.addToBlacklist(randomUser);

        // 3. Імітуємо відправку від user1 на цю випадкову заблоковану адресу
        vm.prank(user1);
        
        // Очікуємо, що транзакція буде відхилена через чорний список
        vm.expectRevert("Blacklisted address");
        token.transfer(randomUser, randomAmount);
    }
}