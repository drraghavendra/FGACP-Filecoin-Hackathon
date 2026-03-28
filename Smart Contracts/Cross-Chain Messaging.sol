// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrossChainMessenger {
    // Wormhole integration placeholder
    event MessageSent(uint256 sequence, bytes payload);
    event MessageReceived(bytes payload);

    function sendMessage(bytes calldata payload, uint16 targetChain) external {
        // Call Wormhole
        emit MessageSent(0, payload);
    }

    function receiveMessage(bytes calldata payload) external {
        emit MessageReceived(payload);
    }
}
