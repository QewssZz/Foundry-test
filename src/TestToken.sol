// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestToken is ERC20, Ownable {
    
    mapping(address => bool) private _isBlacklisted;

    event AddedToBlacklist(address indexed account);
    event RemovedFromBlacklist(address indexed account);

    constructor() ERC20("Test Token", "TST") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addToBlacklist(address account) external onlyOwner {
        require(!_isBlacklisted[account], "Blacklist: account is already blacklisted");
        _isBlacklisted[account] = true;
        emit AddedToBlacklist(account);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        require(_isBlacklisted[account], "Blacklist: account is not blacklisted");
        _isBlacklisted[account] = false;
        emit RemovedFromBlacklist(account);
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    /**
     * @dev Перевизначення функції _update (OpenZeppelin 5.x) для блокування переказів.
     * Викликається перед будь-якою зміною балансів (включаючи mint та burn).
     */
    function _update(address from, address to, uint256 value) internal override {
        // Перевіряємо відправника (ігноруємо address(0), бо це процес mint)
        if (from != address(0)) {
            require(!_isBlacklisted[from], "Blacklisted address");
        }
        
        // Перевіряємо отримувача (ігноруємо address(0), бо це процес burn)
        if (to != address(0)) {
            require(!_isBlacklisted[to], "Blacklisted address");
        }

        // Обов'язковий виклик батьківського методу для фактичного оновлення балансів.
        // Без цього жоден переказ не відбудеться.
        super._update(from, to, value);
    }
}