const { expect, util } = require('chai');
const { BigNumber } = require('ethers');
const { formatEther, parseEther } = require('ethers/lib/utils');

const wait = ms => new Promise(resolve => setTimeout(resolve, ms));

describe('KickStarter contract', function () {
  let kickStarter;
  let owner;
  
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    [owner] = await ethers.getSigners();

    const KickStarterContract = await ethers.getContractFactory('KickStarter');
    kickStarter = await KickStarterContract.deploy();
  });

  it('Deployment should assign the owner of the Contract and set the Minimum Contribution', async function () {
    expect(await kickStarter.owner()).to.equal(owner.address);
  });
});


describe('KickStarter contract contribution', function () {
  let kickStarter;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let projectId;
  let project;
  let projectContribution;
  let contractWithSigner;
  let overrides;
  let balance;
  let totalContractBalance;

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    // To deploy our contract, we just have to call Token.deploy() and await
    // for it to be deployed(), which happens once its transaction has been mined.
    const KickStarterContract = await ethers.getContractFactory('KickStarter');
    kickStarter = await KickStarterContract.deploy();

    // Creating a project
    await kickStarter.createProject('Project 1', parseEther('100'));

    // balance = await owner.getBalance();
    // console.log('Owner: ' + formatEther(balance));
  });

  // it('should check whether new project has been created or not', async function () {
  //   projectId = await kickStarter.getProject('Project 1');
  //   projectId = projectId.toBigInt();

  //   console.log(await kickStarter.ownerToProject(projectId));

  //   const balance = await addr1.getBalance();
  //   console.log(formatEther(balance));

  //   await kickStarter.connect(addr1, { 
  //       value: 1000
  //   }).contribute(projectIndex);
  // });

  it('should contribute 100 ETH to the project 1', async function () {
    projectId = await kickStarter.getProject('Project 1');
    projectId = projectId.toBigInt();
    project = await kickStarter.projectIdToProject(projectId);

    // let balance = await addr1.getBalance();
    // console.log(formatEther(balance));

    contractWithSigner = kickStarter.connect(addr1);
    overrides = {
      gasLimit: 200000,
      value: parseEther('98'),
    };
    await contractWithSigner.contribute(projectId, overrides);

    // project = await kickStarter.ownerToProject(projectId);
    // console.log(formatEther(project.goal));

    // balance = await addr1.getBalance();
    // console.log(formatEther(balance));



    // balance = await addr2.getBalance();
    // console.log(formatEther(balance));

    contractWithSigner = kickStarter.connect(addr2);
    overrides = {
      gasLimit: 200000,
      value: ethers.utils.parseEther('5'),
    };
    await contractWithSigner.contribute(projectId, overrides);

    // project = await kickStarter.ownerToProject(projectId);
    // console.log(formatEther(project.goal));
    // console.log(project.archive);

    projectTotalContribution = await kickStarter.projectIdToTotalContribution(projectId);
    // console.log(formatEther(projectTotalContribution));

    // balance = await addr2.getBalance();
    // console.log(formatEther(balance));

    // totalContractBalance = await kickStarter.getBalance();
    // console.log(formatEther(balance));

    expect(formatEther(projectTotalContribution)).to.equal("100.0");
    expect(formatEther(project.goal)).to.equal("100.0");
  });

  it('should withdraw 10% of ETH from the project 1', async function () {
      projectId = await kickStarter.getProject('Project 1');
      projectId = projectId.toBigInt();
      project = await kickStarter.projectIdToProject(projectId);

      // balance = await kickStarter.getBalance();
      // console.log('Contract: ' + formatEther(balance));

      contractWithSigner = kickStarter.connect(addr1);
      overrides = {
        gasLimit: 300000,
        value: parseEther('100'),
      };
      await contractWithSigner.contribute(projectId, overrides);

      // totalContractBalance = await kickStarter.getBalance();
      // console.log('Contract: ' + formatEther(totalContractBalance));

      // balance = await addr1.getBalance();
      // console.log('Address1: ' + formatEther(balance));



      // balance = await owner.getBalance();
      // console.log('Owner: ' + formatEther(balance));

      contractWithSigner = kickStarter.connect(owner);
      await contractWithSigner.withdraw(projectId, 10);

      // balance = await owner.getBalance();
      // console.log('Owner: ' + formatEther(balance));

      totalContractBalance = await kickStarter.getBalance();
      // console.log('Contract: ' + formatEther(totalContractBalance));

      expect(formatEther(totalContractBalance)).to.equal("90.0");
  });
});
