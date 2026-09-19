// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RealEstateRegistry {
    struct Property {
        address owner;
        uint256 price;
        bool isForSale;
    }

    mapping(bytes32 => Property) public properties;

    event PropertyRegistered(bytes32 indexed propertyId, address indexed owner, string physicalAddress);
    event OwnershipTransferred(bytes32 indexed propertyId, address indexed oldOwner, address indexed newOwner);

    function registerProperty(string memory physicalAddress) external {
        bytes32 propertyId = keccak256(abi.encodePacked(physicalAddress));
        require(properties[propertyId].owner == address(0), "Property already registered");

        properties[propertyId] = Property({
            owner: msg.sender,
            price: 0,
            isForSale: false
        });

        emit PropertyRegistered(propertyId, msg.sender, physicalAddress);
    }

    function transferOwnership(bytes32 propertyId, address newOwner) external {
        require(properties[propertyId].owner == msg.sender, "Not the property owner");
        require(newOwner != address(0), "Invalid new owner address");

        properties[propertyId].owner = newOwner;

        emit OwnershipTransferred(propertyId, msg.sender, newOwner);
    }
}
