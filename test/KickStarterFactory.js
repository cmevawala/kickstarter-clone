const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { formatEther, parseEther } = require('ethers/lib/utils');

describe.only('KickStarterFactory contract', function () {
  let kickStarter;
  let owner;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    [owner] = await ethers.getSigners();

    const KickStarterContract = await ethers.getContractFactory(
      'KickStarterFactory'
    );
    kickStarter = await KickStarterContract.deploy();
  });

  it('Deployment should assign the owner of the Contract and set the Minimum Contribution', async function () {
    expect(await kickStarter.owner()).to.equal(owner.address);
  });
});

describe.only('KickStarterFactory Project Management', function () {
  let kickStarter;
  let owner;
  let addr1;
  let addr2;
  let addr3;

  let overrides;
  let balance;
  let totalContractBalance;

  let KickStarter;
  let contractWithSigner;
  let projectAddress;
  let tx;
  let txReceipt;

  let Project;
  let project;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    KickStarter = await ethers.getContractFactory('KickStarterFactory');
    kickStarter = await KickStarter.deploy();

    tx = await kickStarter.createProject('Project 1', parseEther('100'));
  });

  it('should check whether new project has been created or not', async function () {
    txReceipt = await tx.wait();
    projectAddress = txReceipt.events[0].args[0];

    Project = await ethers.getContractFactory('Project');
    project = await Project.attach(projectAddress);

    expect(projectAddress).not.undefined;

    expect(
      await kickStarter.createProject('Project 1', parseEther('100'))
    ).to.emit(kickStarter, 'ProjectCreated');
  });

  it('should contribute 100 ETH to the project 1', async function () {
    overrides = { gasLimit: 200000, value: parseEther('90') };
    await project.connect(addr1).contribute(overrides);

    overrides = { ...overrides, value: ethers.utils.parseEther('10') };
    await project.connect(addr2).contribute(overrides);

    expect(formatEther(await project.total())).to.equal('100.0');
  });

  it('should withdraw 10% of ETH from the project 1', async function () {

    await project.connect(owner).withdraw(10);
    expect(formatEther(await project.total())).to.equal('90.0');
  });

  it('should create and close the project 2', async function () {

      tx = await kickStarter.createProject('Project 2', parseEther('200'));

      txReceipt = await tx.wait();
      projectAddress = txReceipt.events[0].args[0];

      Project = await ethers.getContractFactory('Project');
      project = await Project.attach(projectAddress);

      overrides = { gasLimit: 200000, value: parseEther('100')};
      await project.connect(addr3).contribute(overrides);

      // const date = new Date();
      // date.setDate(date.getDate() + 1);
      // const thirtyDaysFromNow = date.getTime();

      // await network.provider.send("evm_setNextBlockTimestamp", [
      //   thirtyDaysFromNow,
      // ]);
      // await ethers.provider.send("evm_mine");

      await project.connect(owner).close();
      expect(await project.archive()).true;
  });

  it('should fail the project 3', async function () {

      tx = await kickStarter.createProject('Project 3', parseEther('300'));

      txReceipt = await tx.wait();
      projectAddress = txReceipt.events[0].args[0];

      Project = await ethers.getContractFactory('Project');
      project = await Project.attach(projectAddress);

      overrides = { gasLimit: 200000, value: parseEther('100')};
      await project.connect(addr3).contribute(overrides);


      const date = new Date();
      date.setDate(date.getDate() + 1);
      const thirtyDaysFromNow = date.getTime();

      await network.provider.send("evm_setNextBlockTimestamp", [
        thirtyDaysFromNow,
      ]);
      await ethers.provider.send("evm_mine");
      

      await project.connect(owner).fail();
      expect(await project.archive()).true;
  });
});
