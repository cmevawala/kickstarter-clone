// contracts/KickStarterFactory.sol
// SPDX-License-Identifier: MIT

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.7;

contract KickStarterFactory {
   
    address public owner;
    // uint constant minimumContribution = 0.01 ether;

    address[] projectContracts;

    constructor() {
        owner = msg.sender;
    }

    modifier restricted(address _projectAddress) {
        Project projectContract = Project(_projectAddress);

        require(msg.sender == projectContract.owner(), "Error! You are not the owner of the current project");
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Create Project
    function createProject(string memory name, uint goal) public returns (address) {
        Project newProject = new Project(name, goal, msg.sender);

        projectContracts.push(address(newProject));

        return address(newProject);
    }

    function contribute(address _projectAddress) public payable {
        // TODO: Hack Reentrace

        Project projectContract = Project(_projectAddress);

        // Validate if the contribution amount is less than minimum
        require(msg.value >= minimumContribution, 'Contribution amount less than Minimum');
        
        // Validate if the goal is already achieved or not
        require(projectContract.total() < projectContract.goal(), 'Goal Achieved! No more funds are accepted.');

        uint incommingContribution = msg.value;
        if (projectContract.total() + incommingContribution > projectContract.goal()) {  // 98 + 5 > 100
            incommingContribution = projectContract.goal() - projectContract.total();    // 100 - 98 = 2
            
            // Send back to contributer/sender : msg.value - incommingContribution;      // 5 - 2 = 3
            uint remainingAmount = msg.value - incommingContribution;
            (bool sent, bytes memory data) = msg.sender.call{value: remainingAmount}("");
            require(sent, "Failed to send Ether");
        }

        projectContract.addContribution(msg.sender, msg.value);
    }

    // function getTotal(address _projectAddress) public view returns (uint) {
    //     Project projectContract = Project(_projectAddress);
    //     return projectContract.total();
    // }

    // function getGoal(address _projectAddress) public view returns (uint) {
    //     Project projectContract = Project(_projectAddress);
    //     return projectContract.goal();
    // }

    function withdraw(address _projectAddress, uint8 percentage) public payable restricted(_projectAddress) {
        Project projectContract = Project(_projectAddress);

        // Validate if the project is archieve
        require(!projectContract.archive(), 'Project is archieved');

        // Invalid Percentage Value
        require(percentage <= 100, 'Invalid Percentage Value');

        // // validate owner 
        // require(projectContract.owner() == msg.sender, 'Error! You are not the owner of the current project');

        // Validate if the goal is met
        require(projectContract.total() == projectContract.goal(), 'Error! Project Goal has not been met');

        // Validate is 30 days completed and goal is not met
        // require(block.timestamp <= projectContract.created() + 30 days &&  projectIdToContributors[projectId].amount < projectIdToProject[projectId].goal, 'Error! You did not met goal within 30 days');

        // Calculate amount to withdraw
        uint amountToWithdraw = (projectContract.total() * percentage) / 100;

        // Trying to withdraw amount more than the available amount
        require(amountToWithdraw < projectContract.total(), 'Insufficient Funds.');

        // Reduce the balance from total contribution
        projectContract.reduceContribution(amountToWithdraw);

        // Send the withdrawable amount to creator
        (bool sent, bytes memory data) = msg.sender.call{ value: amountToWithdraw }("");
        require(sent, "Withdraw Failed : Failed to send Ether");
    }

    function cancelProject(address _projectAddress) public payable restricted(_projectAddress) {
        Project projectContract = Project(_projectAddress);

        if (block.timestamp < projectContract.created() + 30 days) {
            projectContract.close();
        }
    }

    function archieveProjects() public payable {

        // Validate is a contract owner
        require(owner == msg.sender, 'Restricted Access');

        for (uint i; i < projectContracts.length; i++) {

            Project projectContract = Project(projectContracts[i]);

            // Check whether the project is expired
            if (projectContract.isExpired()) {
                projectContract.close();

                delete projectContracts[i];
            }

        }
        
    }

}


contract Project {

    struct ProjectContribution {
        address from;
        uint amount;
    }

    address id;
    string public name;
    uint public goal;
    bool public archive;
    uint public created;
    address public owner;
    uint public total;
    ProjectContribution[] contributors; 


    constructor(string memory _name, uint _goal, address _owner) {
        id = _owner;
        name = _name;
        goal = _goal * 1 ether;
        archive = false;
        created = block.timestamp;
        owner = _owner;
        total = 0;
    }

    function addContribution(address _from, uint _amount) public {
        contributors.push(ProjectContribution({
            from: _from,
            amount: _amount
        }));
        
        total += _amount;
    }

    function reduceContribution(uint _amount) public {
        total = total - _amount;
    }

    function close() public {
        archive = true;
        total = 0;

        // Return the money back to contributors
        for (uint i = 0; i < contributors.length; i++) {
            address addr = contributors[i].from;
            (bool sent, bytes memory data) = addr.call{ value: contributors[i].amount }("");
            require(sent, "Failed to send Ether to the contributors");
        }

        delete contributors;
    }

    function isExpired() public view returns (bool) {
        return block.timestamp > created + 30 days;
    }
}
