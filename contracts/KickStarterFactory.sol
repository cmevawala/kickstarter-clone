// contracts/KickStarterFactory.sol
// SPDX-License-Identifier: MIT

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.7;
import "hardhat/console.sol";

contract KickStarterFactory {

    event ProjectCreated(address projecId);
   
    address public owner;
    address[] public projectContracts;

    constructor() {
        owner = msg.sender;
    }

    function createProject(string memory name, uint goal) external returns (address) {
        Project newProject = new Project(name, goal, msg.sender);

        projectContracts.push(address(newProject));

        emit ProjectCreated(address(newProject));

        return address(newProject);
    }

}


contract Project {
    
    event ContributionReceived(string message);
    event Withdraw(string message);

    struct ProjectContribution {
        address from;
        uint amount;
    }
    
    uint constant minimumContribution = 0.01 ether;

    string public name;
    uint public goal;
    uint public created;
    address public owner;
    uint public total;
    bool public archive;
    ProjectContribution[] contributors; // Remove array and replace it with Map
    
    uint idCounter;
    mapping(uint => address) awards;

    function getName() public view returns (string memory) {
        return name;
    }
    

    modifier restricted() {
        require(msg.sender == owner, "Error! You are not the owner of the current project");
        _;
    }

    modifier isArchived() {
        require(!archive, 'Project is already archieved');
        _;
    }

    constructor(string memory _name, uint _goal, address _owner) {
        name = _name;
        goal = _goal; // Goal should be greater than 0
        created = block.timestamp;
        owner = _owner;
        archive = false;
        total = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function contribute() public payable isArchived {
        // TODO: Hack Reentrace
        // TODO: Tokens Mint

        // Validate if the contribution amount is less than minimum
        require(msg.value >= minimumContribution, 'Contribution amount less than Minimum');

        // Validate if the project is failed to met the goal within 30 days
        require(block.timestamp <= created + 30 days , 'Error! Project is no more accepting contributions after 30 days');

        // Validate if the goal is already achieved or not
        require(total < goal, 'Goal Achieved! No more funds are accepted.');

        bool refund = false;
        uint incommingContribution = msg.value;
        if (total + incommingContribution > goal) {  // 98 + 5 > 100
            incommingContribution = goal - total;    // 100 - 98 = 2
            refund = true;
        }

        contributors.push(ProjectContribution({
            from: msg.sender,
            amount: incommingContribution
        }));
        
        total += incommingContribution;

        if (refund) {
            // Send back to contributer/sender : msg.value - incommingContribution;  // 5 - 2 = 3
            (bool sent,) = msg.sender.call{value: msg.value - incommingContribution}("");
            require(sent, "Failed to send Ether");
        }

        emit ContributionReceived('Contribution received.');
    }

    function withdraw(uint8 percentage) public payable restricted isArchived {
        // Invalid Percentage value
        require(percentage > 0 && percentage <= 100, 'Invalid Percentage Value');

        // Validate if the goal is met
        require(total == goal, 'Error! Project Goal has not been met');

        // Calculate amount to withdraw
        uint amountToWithdraw = (total * percentage) / 100;

        // Trying to withdraw amount more than the available amount
        require(amountToWithdraw < total && amountToWithdraw > 0, 'Insufficient Funds.');

        // Reduce the balance from total contribution
        total = total - amountToWithdraw;

        // Send the withdrawable amount to creator
        (bool sent, ) = owner.call{ value: amountToWithdraw }("");
        require(sent, "Withdraw Failed : Failed to send Ether");

        emit Withdraw('Funds withdrawn');
    }

    function ownerOf(uint tokenId) public view returns (address) {
        return awards[tokenId];
    }

    function close() public payable restricted {
        
        // Validate if the project has not completed 30 days
        require(block.timestamp < (created + 30 days), 'Failed: Project as already completed 30 days');

        // Validate if the goal is met, then throw
        if (total == goal) {
            require(false, 'Error! You cannot close this project as the goal is met');
        }

        // Archieve the project and refund the amount
        archive = true;
        goal = 0;
        total = 0;
        refund();
    }

    function fail() public restricted isArchived {

        // Validate if the project has completed 30 days and expired
        require(block.timestamp > created + 30 days, 'Failed: Project has not completed 30 days');

        // Validate if the goal is not met
        require(total <= goal, 'Error! You cannot fail this project as the goal is met');

        archive = true;
        goal = 0;
        total = 0;
        refund();
    }

    function refund() public payable {

        // Return the money back to contributors
        // This is wrong. Favor pull over push
        for (uint i = 0; i < contributors.length; i++) {
            
            address addr = contributors[i].from;
            (bool sent, ) = addr.call{ value: contributors[i].amount}("");
            
            require(sent, "Failed to send Ether to the contributors");
        }

        delete contributors;
    }

    function _mint(uint8 tier, address receiver) internal {
        uint id = (idCounter << 1) + tier;
        awards[id] = receiver;
        idCounter += 1;
    }
}
