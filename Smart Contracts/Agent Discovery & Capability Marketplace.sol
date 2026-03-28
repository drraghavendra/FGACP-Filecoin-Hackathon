// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AgentRegistry {
    mapping(string => address[]) public capabilities;
    mapping(address => string[]) public agentCapabilities;
    mapping(address => uint256) public reputation;

    event AgentRegistered(address indexed agent, string[] caps);
    event CapabilityAdded(address indexed agent, string cap);

    function registerAgent(string[] calldata caps) external {
        for (uint i = 0; i < caps.length; i++) {
            capabilities[caps[i]].push(msg.sender);
            agentCapabilities[msg.sender].push(caps[i]);
        }
        emit AgentRegistered(msg.sender, caps);
    }

    function getAgentsByCapability(string calldata cap) external view returns (address[] memory) {
        return capabilities[cap];
    }
}
