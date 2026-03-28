// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PaymentChannel {
    mapping(bytes32 => uint256) public balances;
    mapping(bytes32 => uint256) public timeouts;

    event Deposit(bytes32 indexed channelId, address sender, uint256 amount);
    event Withdrawal(bytes32 indexed channelId, address receiver, uint256 amount);
    event Settle(bytes32 indexed channelId);

    function deposit(bytes32 channelId, uint256 amount) external payable {
        require(msg.value == amount, "Incorrect amount");
        balances[channelId] += amount;
        emit Deposit(channelId, msg.sender, amount);
    }

    function withdraw(bytes32 channelId, uint256 amount, bytes memory signature) external {
        bytes32 hash = keccak256(abi.encodePacked(channelId, amount));
        address signer = recoverSigner(hash, signature);
        require(signer == msg.sender, "Invalid signature");
        require(balances[channelId] >= amount, "Insufficient balance");
        balances[channelId] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(channelId, msg.sender, amount);
    }

    function settle(bytes32 channelId) external {
        require(block.timestamp > timeouts[channelId], "Channel not expired");
        emit Settle(channelId);
    }

    function recoverSigner(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Simplified ecrecover logic
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(hash, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
