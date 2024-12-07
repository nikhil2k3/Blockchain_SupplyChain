// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Migrations {
    address public owner;
    uint256 public lastCompletedMigration;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this.");
        _;
    }

    function setCompleted(uint256 completed) public onlyOwner {
        lastCompletedMigration = completed;
    }

    function upgrade(address newAddress) public onlyOwner {
        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(lastCompletedMigration);
    }
}
