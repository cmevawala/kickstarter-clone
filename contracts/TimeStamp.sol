pragma solidity ^0.8.7;

contract Timestamp {
    uint256 public startDateTime;
    uint256 public endDateTime;

    function start() public {
        startDateTime = block.timestamp;
    }

    function end() public {
        endDateTime = block.timestamp;
    }

    function getTimeDiff() public view returns (uint256) {
        return endDateTime - startDateTime;
    }
}
