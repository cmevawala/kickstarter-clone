// contracts/KickStarter.sol
// SPDX-License-Identifier: MIT

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.7;

contract KickStarter {

    struct Project {
        uint id;
        string name;
        uint goal;
        uint created;
        address owner;
        bool archive;
    }

    struct ProjectContribution {
        uint id;
        address from;
        uint amount;
    }

    address public owner;
    uint constant minimumContribution = 0.01 ether;

    uint[] projectIds;

    mapping(uint => Project) public ownerToProject;
    mapping(uint => ProjectContribution) public projectToContribution;
    mapping(string => uint) public projectNameToId;


    constructor() {
        owner = msg.sender;
    }

    // uint value;
    // function conrtivalue() public view returns (uint) {
    //     return value;
    // }
    // function getTime() public view returns(bool){
    //     if ((block.timestamp - projects[0].created) >= 5 seconds) {
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }

    function getMinimumContribution() public pure returns (uint) {
        // Without utils function use variables for testing.
        return minimumContribution;
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

        ownerToProject[newProject.id] = newProject;
        projectNameToId[newProject.name] = newProject.id;
        
        projectIds.push(newProject.id);
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
        // value = msg.value;
        address _to = msg.sender;

        // Validate if the project is archived or not
        require(!ownerToProject[projectId].archive, 'Project is already archived.');

        // Validate if the contribution amount is less than minimum
        require(msg.value >= minimumContribution, 'Contribution amount less than Minimum');

        // Validate if the goal is already achieved or not
        require(projectToContribution[projectId].amount < ownerToProject[projectId].goal, 'Goal Achieved! No more funds are accepted.');

        uint incommingContribution = msg.value;
        if (projectToContribution[projectId].amount + incommingContribution > ownerToProject[projectId].goal) {
            incommingContribution = ownerToProject[projectId].goal - projectToContribution[projectId].amount;
            
            // Send back to contributer/sender : msg.value - incommingContribution;
            uint remainingAmount = msg.value - incommingContribution;
            (bool sent, bytes memory data) = _to.call{value: remainingAmount}("");
            require(sent, "Failed to send Ether");
        }

        // Update the amount contributed by sender
        projectToContribution[projectId].amount += incommingContribution;

        // Update the address of contributor/sender
        projectToContribution[projectId].from = msg.sender;

        // archive the project when the goal is met
        if (projectToContribution[projectId].amount == ownerToProject[projectId].goal) {
            Project memory project = ownerToProject[projectId];
            project.archive = true;
        }
    }

    function withdraw(uint projectId, uint8 percentage) public payable {
        Project memory project = ownerToProject[projectId];
        ProjectContribution storage projectContribution = projectToContribution[projectId];

        // validate owner 
        require(project.owner == msg.sender, 'Error! You are not the owner of the current project');

        // Validate is 30 days completed
        require((block.timestamp - project.created) >= 30, 'Error! You are not the owner of the current project');

        // Calculate amount to withdraw
        uint amountToWithdraw = project.goal * percentage / 100;

        // Reduce the balance from total contribution
        projectContribution.amount = projectContribution.amount - amountToWithdraw;

        // Send the withdrawable amount to creator
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
