// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    struct Transaction {
        address to;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }

    Transaction[] public transactions;
    mapping(address => bool) public isOwner;
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    constructor(address[3] memory _owners) {
        for (uint256 i = 0; i < 3; i++) {
            require(_owners[i] != address(0), "Invalid owner address");
            require(!isOwner[_owners[i]], "Owners must be unique");
            isOwner[_owners[i]] = true;
        }
    }

    receive() external payable {}

    function submitTransaction(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid target address");
        
        transactions.push(Transaction({
            to: to,
            amount: amount,
            approvals: 0,
            executed: false
        }));
    }

    function approveTransaction(uint256 txId) external onlyOwner {
        require(txId < transactions.length, "Transaction does not exist");
        require(!transactions[txId].executed, "Transaction already executed");
        require(!hasApproved[txId][msg.sender], "Already approved by you");

        hasApproved[txId][msg.sender] = true;
        transactions[txId].approvals++;
    }

    function executeTransaction(uint256 txId) external onlyOwner {
        require(txId < transactions.length, "Transaction does not exist");
        
        Transaction storage transaction = transactions[txId];
        require(!transaction.executed, "Transaction already executed");
        require(transaction.approvals >= 2, "Not enough approvals");
        require(address(this).balance >= transaction.amount, "Insufficient wallet balance");

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.amount}("");
        require(success, "Transaction failed");
    }
}
