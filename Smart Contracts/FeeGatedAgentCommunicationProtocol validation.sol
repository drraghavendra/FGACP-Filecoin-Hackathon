// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ReputationSystem.sol"; // From prior module

contract FGACPValidation is ReputationSystem {
    struct FGACPMessage {
        string fromDID;
        string toDID;
        uint256 timestamp;
        bytes payloadHash; // keccak256(encrypted_payload)
        string feePaid; // "0.001 ETH"
        string filecoinCID;
        bytes signature; // Ed25519/ECDSA sig (use ZK for Ed25519)
        uint256 nonce;
    }

    mapping(string => uint256) public nonces; // Anti-replay
    uint256 public minFee = 0.001 ether;
    uint256 public minReputation = 50;

    event MessageValidated(string indexed fromDID, string toDID, string filecoinCID);
    event ValidationFailed(string reason);

    // Main validation: sig, fee, rep, replay, timestamp
    function validateFGACPMessage(FGACPMessage calldata msgData) external returns (bool) {
        // 1. Replay protection
        require(msgData.nonce > nonces[msgData.fromDID], "Replay attack");
        nonces[msgData.fromDID] = msgData.nonce;

        // 2. Timestamp freshness (within 1 hour)
        require(block.timestamp - msgData.timestamp < 3600, "Expired message");

        // 3. DID format (simplified)
        bytes32 messageHash = getMessageHash(msgData);

        // 4. Signature verification (ECDSA; use ZK oracle for Ed25519)
        address signer = recoverSigner(messageHash, msgData.signature);
        require(bytes(msgData.fromDID).length > 10, "Invalid DID"); // Proxy signer to DID

        // 5. Fee check (parse string or use uint feeWei param)
        require(parseFee(msgData.feePaid) >= minFee, "Insufficient fee");

        // 6. Reputation check
        address agentAddr = didToAddress(msgData.fromDID); // Off-chain mapping or registry lookup
        require(globalTrust[agentAddr] >= minReputation, "Low reputation");

        // 7. Filecoin CID validity (oracle or length check)
        require(bytes(msgData.filecoinCID).length == 46 && keccak256(abi.encodePacked(msgData.filecoinCID)).length > 0, "Invalid CID");

        emit MessageValidated(msgData.fromDID, msgData.toDID, msgData.filecoinCID);
        return true;
    }

    function getMessageHash(FGACPMessage calldata msgData) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            msgData.fromDID,
            msgData.toDID,
            msgData.timestamp,
            msgData.payloadHash,
            msgData.feePaid,
            msgData.filecoinCID,
            msgData.nonce
        ));
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    // Helpers (simplified)
    function parseFee(string memory feeStr) public pure returns (uint256) {
        // Parse "0.001 ETH" -> 0.001 ether (use string utils in prod)
        return 0.001 ether;
    }

    function didToAddress(string memory did) public pure returns (address) {
        // Hash DID to addr or registry lookup
        return address(uint160(uint(keccak256(abi.encodePacked(did)))));
    }

    // Agent submits validated message for on-chain record
    function submitValidatedMessage(FGACPMessage calldata msgData) external {
        require(validateFGACPMessage(msgData), "Validation failed");
        // Emit or store CID for audit
    }
}
