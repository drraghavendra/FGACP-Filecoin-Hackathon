// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AgentRegistry.sol";

contract ReputationSystem is AgentRegistry {
    mapping(address => mapping(address => uint256)) public trust;
    mapping(address => uint256) public globalTrust;

    function rateAgent(address target, uint256 score) external {
        trust[msg.sender][target] = score;
        // Simplified EigenTrust: average incoming trust
        uint256 sum = 0;
        uint256 count = 0;
        // Iterate raters (simplified, use events for production)
        globalTrust[target] = (globalTrust[target] * count + score) / (count + 1);
    }

    function getReputation(address agent) external view returns (uint256) {
        return globalTrust[agent];
    }
}
