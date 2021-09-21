// contracts/KickStarter.sol
// SPDX-License-Identifier: MIT

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.7;

contract KickStarter {

    struct Project {
        string name;
        uint fund;
        uint created;
    }

    address public owner;
    Project[] public projects;

    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address){
        return owner;
    }

    function getTime() public view returns(bool){
        if ((block.timestamp - projects[0].created) >= 5 seconds) {
            return true;
        } else {
            return false;
        }
    }

    function getProjects() public view returns (Project[] memory) {
        return projects;
    }

    function getProjectsCount() public view returns (uint) {
        return projects.length;
    }

    function createProject(string memory name, uint fund) public {
        Project memory newProject = Project({
            name: name,
            fund: fund,
            created: block.timestamp
        });

        projects.push(newProject);
    }

    function contribute(uint projectId, uint amount) public {

    }

    function withdraw() public {
        
    }
}
