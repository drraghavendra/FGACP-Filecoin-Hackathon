// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ValidationRegistry {
    struct ValidationRequestEntry {
        uint256 AgentValidatorID;
        uint256 AgentServerID;
        uint256 timestamp;
        bool active;
    }

    mapping(bytes32 => ValidationRequestEntry) private _requests;

    event ValidationRequest(uint256 indexed AgentValidatorID, uint256 indexed AgentServerID, bytes32 DataHash);
    event ValidationResponse(uint256 indexed AgentValidatorID, uint256 indexed AgentServerID, bytes32 DataHash, uint256 Response);

    function ValidationRequest(bytes32 DataHash, uint256 AgentValidatorID, uint256 AgentServerID) external {
        require(DataHash != bytes32(0), "Invalid DataHash");
        require(!_requests[DataHash].active, "Request already exists");

        _requests[DataHash] = ValidationRequestEntry({
            AgentValidatorID: AgentValidatorID,
            AgentServerID: AgentServerID,
            timestamp: block.timestamp,
            active: true
        });

        emit ValidationRequest(AgentValidatorID, AgentServerID, DataHash);
    }

    function ValidationResponse(bytes32 DataHash, uint256 Response) external {
        ValidationRequestEntry storage req = _requests[DataHash];
        require(req.active, "No active request for DataHash");

        emit ValidationResponse(req.AgentValidatorID, req.AgentServerID, DataHash, Response);
        req.active = false;
    }
}
