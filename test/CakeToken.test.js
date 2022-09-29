const { assert } = require("chai");

const TaalToken = artifacts.require('TaalToken');

contract('TaalToken', ([alice, bob, carol, dev, minter]) => {
    beforeEach(async () => {
        this.cake = await TaalToken.new({ from: minter });
    });


    it('mint', async () => {
        await this.cake.mint(alice, 1000, { from: minter });
        assert.equal((await this.cake.balanceOf(alice)).toString(), '1000');
    })
});
