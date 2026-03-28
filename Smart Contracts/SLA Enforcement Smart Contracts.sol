// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AgentSLA {
    struct SLA {
        uint256 responseTime; // seconds
        uint256 uptime; // basis points
        uint256 stake;
    }

    mapping(address => SLA) public slas;
    mapping(address => uint256) public violations;

    event SLAViolation(address agent, uint256 penalty);

    function commitSLA(uint256 responseTime, uint256 uptime) external payable {
        slas[msg.sender] = SLA(responseTime, uptime, msg.value);
    }

    function reportViolation(address agent, bool valid) external {
        if (!valid) {
            violations[agent]++;
            if (violations[agent] > 3) {
                payable(msg.sender).transfer(slas[agent].stake / 2);
                emit SLAViolation(agent, slas[agent].stake / 2);
            }
        }
    }
}
