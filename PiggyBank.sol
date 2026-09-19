// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PiggyBank {
    address public owner;
    uint256 public goal;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    constructor(uint256 _goal) {
        owner = msg.sender;
        goal = _goal;
    }

    receive() external payable {}

    function deposit() external payable {}

    function breakPiggyBank() external onlyOwner {
        uint256 currentBalance = address(this).balance;
        require(currentBalance >= goal, "Goal not reached yet");

        (bool success, ) = owner.call{value: currentBalance}("");
        require(success, "Transfer failed");
    }
}
