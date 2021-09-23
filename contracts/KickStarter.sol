// contracts/KickStarter.sol
// SPDX-License-Identifier: MIT

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.7;

contract KickStarter {

    // Sequencing of properties can reduce the GAS
    // Memory vs Storage revise again
    // Learn about transactions send, receive
    // Learn about ethers js
    // Make use emit for projectId
    struct Project {
        uint id;
        string name;
        uint goal;
        uint created;
        address owner;
        bool archive;
    }

    struct ProjectContribution {
        address from;
        uint amount;
    }

    address public owner;
    uint constant minimumContribution = 0.01 ether;

    uint[] projectIds;

    mapping(uint => Project) public projectIdToProject;
    
    mapping(uint => ProjectContribution[]) public projectIdToContribution;
    mapping(uint => uint) public projectIdToTotalContribution;

    mapping(address => uint) public ownerToProjectId;
    mapping(string => uint) public projectNameToId;


    constructor() {
        owner = msg.sender;
    }
    
    /******************************  public functions ****************************/

    function createProject(string memory name, uint amount) public {
        Project memory newProject = Project({
            id: random(),
            name: name,
            goal: amount,
            owner: msg.sender,
            created: block.timestamp,
            archive: false
        });

        projectIdToProject[newProject.id] = newProject;
        projectNameToId[newProject.name] = newProject.id;
        ownerToProjectId[msg.sender] = newProject.id;
        
        // projectIds.push(newProject.id);
    }

    function getProject(string memory name) public view returns (uint) {
        return projectNameToId[name];
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function contribute(uint projectId) public payable {

        address _to = msg.sender;

        // Validate if the contribution amount is less than minimum
        require(msg.value >= minimumContribution, 'Contribution amount less than Minimum');

        // Validate if the goal is already achieved or not
        require(projectIdToTotalContribution[projectId] < projectIdToProject[projectId].goal, 'Goal Achieved! No more funds are accepted.');

        uint incommingContribution = msg.value;
        if (projectIdToTotalContribution[projectId] + incommingContribution > projectIdToProject[projectId].goal) {
            incommingContribution = projectIdToProject[projectId].goal - projectIdToTotalContribution[projectId];
            
            // Send back to contributer/sender : msg.value - incommingContribution;
            uint remainingAmount = msg.value - incommingContribution;
            (bool sent, bytes memory data) = _to.call{value: remainingAmount}("");
            require(sent, "Failed to send Ether");
        }

        ProjectContribution memory projectContribution = ProjectContribution({
            amount: incommingContribution,
            from: msg.sender
        });

        // // Update the amount contributed by sender
        // projectIdToContribution[projectId].amount += incommingContribution;

        // // Update the address of contributor/sender
        // projectIdToContribution[projectId].from = msg.sender;

        projectIdToContribution[projectId].push(projectContribution);
        projectIdToTotalContribution[projectId] += incommingContribution;
    }

    function withdraw(uint projectId, uint8 percentage) public payable {
        Project memory project = projectIdToProject[projectId];
        address _to = msg.sender;

        // Invalid Percentage Value
        require(percentage <= 100, 'Invalid Percentage Value');

        // validate owner 
        require(project.owner == msg.sender, 'Error! You are not the owner of the current project');

        // Validate if the goal is met
        require(projectIdToTotalContribution[projectId] == projectIdToProject[projectId].goal, 'Error! Project Goal has not been met');

        // Validate is 30 days completed and goal is not met
        // require(block.timestamp <= project.created + 10 seconds &&  projectIdToContribution[projectId].amount < projectIdToProject[projectId].goal, 'Error! You did not met goal within 30 days');

        // Calculate amount to withdraw
        uint amountToWithdraw = (projectIdToTotalContribution[projectId] * percentage) / 100;

        // Trying to withdraw amount more than the available amount
        require(amountToWithdraw < projectIdToTotalContribution[projectId], 'Insufficient Funds.');

        // Reduce the balance from total contribution
        projectIdToTotalContribution[projectId] = projectIdToTotalContribution[projectId] - amountToWithdraw;

        // Send the withdrawable amount to creator
        (bool sent, bytes memory data) = _to.call{ value: amountToWithdraw }("");
        require(sent, "Failed to send Ether");
    }

    function cancelProject() public {
        address _to = msg.sender;

        Project storage project = projectIdToProject[ownerToProjectId[msg.sender]];



        project.archive = true;

    }

    /******************************  public functions ****************************/



    /******************************  private functions ****************************/

    function random() private view returns (uint) {
        // sha3 and now have been deprecated
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, "12435")));
        // convert hash to integer
        // players is an array of entrants
    }

    /******************************  private functions ****************************/
}
