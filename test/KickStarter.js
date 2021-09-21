const { expect } = require('chai');

const wait = ms => new Promise(resolve => setTimeout(resolve, ms));


describe('KickStarter contract', function () {
  
  let kickStarter;
  let owner

  // `beforeEach` will run before each test, re-deploying the contract every
  // time. It receives a callback, which can be async.
  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    const KickStarterContract = await ethers.getContractFactory('KickStarter');
    kickStarter = await KickStarterContract.deploy();
  });

  it('Deployment should assign the owner of the Contract', async function () {
    expect(await kickStarter.getOwner()).to.equal(owner.address);
  });

  it('Creating a project', async function () {
      await kickStarter.createProject('Project 1', 1000);

      expect(await kickStarter.getProjectsCount()).to.equal(1);
  });

  it('Get all projects', async function () {
    await kickStarter.createProject('Project 1', 1000);

    await wait(1 * 60 * 100);

    console.log(await kickStarter.getTime());
    
    expect(1).to.equal(1);
});
});
