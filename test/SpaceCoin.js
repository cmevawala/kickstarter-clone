const { expect } = require('chai');
const { formatEther, parseEther, parseUnits, formatUnits } = require('ethers/lib/utils');

describe.only('SpaceCoin Token', function () {
  let SpaceCoinContract;
  let spaceCoin;
  let owner;
  let w1, w2, w3, w4;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    [owner, w1, w2, w3, w4] = await ethers.getSigners();

    SpaceCoinContract = await ethers.getContractFactory('SpaceCoin');
    spaceCoin = await SpaceCoinContract.deploy(parseUnits("500000"));

    // expect(formatUnits(await spaceCoin.getBalance())).to.equal("0.0");
    // expect(formatUnits(await w1.getBalance())).to.equal("10000.0");
  });

  // it('should have match the owner', async function () {
  //   expect(await spaceCoin.owner()).to.equal(owner.address)
  // });
  
  // it('should have name `SpaceCoin`', async function () {
  //   expect(await spaceCoin.name()).to.equal("SpaceCoin")
  // });

  // it('should have Symbol `WSPC`', async function () {
  //   expect(await spaceCoin.symbol()).to.equal("WSPC")
  // });


  // it('should have total supply of 500,000 coins', async function () {
  //   expect(formatUnits(await spaceCoin.totalSupply())).to.equal("500000.0")
  // });

  it('should have contribute 150 ETH in Seed Phase', async function () {
    await spaceCoin.addWhitelisted(w1.address);

    // console.log(formatEther(await spaceCoin.getBalance()));

    let overrides = { gasLimit: 200000, value: parseEther('150') };
    await spaceCoin.connect(w1).contribute(overrides);

    expect(formatEther(await spaceCoin.getBalance())).to.equal('150.0');
  });

  it('should not allow to contribute other than the whitelisted address in Seed Phase', async function () {
    await spaceCoin.addWhitelisted(w1.address);

    let overrides = { gasLimit: 200000, value: parseEther('150') };
    await expect(spaceCoin.connect(w2).contribute(overrides)).to.be.revertedWith('Error: Address not in whitelist');
  });

  it('should not allow to contribute ETH more than the individual contribution limit', async function () {
    await spaceCoin.addWhitelisted(w1.address);
    
    let overrides = { gasLimit: 200000, value: parseEther('160') };
    await expect(spaceCoin.connect(w1).contribute(overrides)).to.be.revertedWith('Error: More than contribution limit');
  });

  it('should not allow to contribute ETH more than phaseLimit in Seed Phase', async function () {
    await spaceCoin.addWhitelisted(w1.address);

    let overrides = { gasLimit: 200000, value: parseEther('150') };
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    spaceCoin.connect(w1).contribute(overrides)
    
    overrides = { gasLimit: 200000, value: parseEther('120') };
    spaceCoin.connect(w1).contribute(overrides)
    
    overrides = { gasLimit: 200000, value: parseEther('120') };
    spaceCoin.connect(w1).contribute(overrides)

    await expect(spaceCoin.connect(w1).contribute(overrides)).to.be.revertedWith('Error: Phase limit over');
  });

  it('should forward to Public Phase', async function () {
    // console.log(await spaceCoin.getPhase());

    // await spaceCoin.setPhase(1);
    
    // console.log(await spaceCoin.getPhase());

    // let overrides = { gasLimit: 200000, value: parseEther('150') };
    // spaceCoin.connect(w1).contribute(overrides)

    // expect(formatEther(await spaceCoin.getBalance())).to.equal('150.0');

    // overrides = { gasLimit: 200000, value: parseEther('1500') };
    // await expect(spaceCoin.connect(w3).contribute(overrides)).to.be.revertedWith('Error: Phase limit over');
  });

  
});
