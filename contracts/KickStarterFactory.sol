// contracts/KickStarterFactory.sol
// SPDX-License-Identifier: MIT

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.7;

contract KickStarterFactory {
    // address[] carAssets;

    // function createChildContract(string memory brand, string memory model) public payable {
    //     // insert check if the sent ether is enough to cover the car asset ...
    //     address newCarAsset = address(new CarAsset(brand, model, msg.sender));
    //     carAssets.push(address(newCarAsset));
    // }

    // function getDeployedChildContracts() public view returns (address[] memory) {
    //     return carAssets;
    // }

    address public owner;
    uint constant minimumContribution = 0.01 ether;

    address[] projectContracts;

    function createProject(string memory name, uint amount) public {
        address newProjectAddress = address(new Project(name, amount, msg.sender));
        projectContracts.push(newProjectAddress);
    }

    function getDeployedProjects() public view returns (address[] memory) {
        return projectContracts;
    }

    function getDeployedProject(address _projectAddress) public pure returns (Project) {
        return Project(_projectAddress);
    }
    
    function contribute(address _projectAddress) public payable returns (string memory) {
        // TODO: Hack Reentrace
        address _to = msg.sender;

        Project projectContact = Project(_projectAddress);

        // Validate if the contribution amount is less than minimum
        require(msg.value >= minimumContribution, 'Contribution amount less than Minimum');
        
        // Validate if the goal is already achieved or not
        require(projectContact.total() < projectContact.goal(), 'Goal Achieved! No more funds are accepted.');

        uint incommingContribution = msg.value;
        if (projectContact.total() + incommingContribution > projectContact.goal()) {  // 98 + 5 > 100
            incommingContribution = projectContact.goal() - projectContact.total();    // 100 - 98 = 2
            
            // Send back to contributer/sender : msg.value - incommingContribution;
            uint remainingAmount = msg.value - incommingContribution;
            (bool sent, bytes memory data) = _to.call{value: remainingAmount}("");
            require(sent, "Failed to send Ether");
        }

        projectContact.addContribution(msg.sender, msg.value);
    }

    function getTotal(address _projectAddress) public view returns (uint) {
        Project projectContact = Project(_projectAddress);
        return projectContact.total();
    }

}


contract Project {

    struct ProjectContribution {
        address from;
        uint amount;
    }

    uint id;
    string public name;
    uint public goal;
    bool archive;
    uint created;
    address owner;
    uint public total;
    mapping(address => uint) public ownerToContribution;


    constructor(string memory _name, uint _goal, address _owner) {
        id = 1; // random
        name = _name;
        goal = _goal;
        archive = false;
        created = block.timestamp;
        owner = _owner;
        total = 0;
    }

    function addContribution(address _from, uint _amount) public {
        ownerToContribution[_from] += _amount;
        total += _amount;
    }
}


// contract CarAsset {
//     string public brand;
//     string public model;
//     address public owner;

//     constructor( string memory _brand, string memory _model, address _owner ) {
//         brand = _brand;
//         model = _model;
//         owner = _owner;
//     }
// }