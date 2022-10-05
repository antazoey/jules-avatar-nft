import ape


def test_erc165(nft):
    assert nft.supportsInterface("0x01ffc9a7")
    assert not nft.supportsInterface("0xffffffff")
    assert nft.supportsInterface("0x80ac58cd")
    assert nft.supportsInterface("0x5b5e139f")


def test_init(nft, owner):
    assert nft.balanceOf(owner) == 0
    with ape.reverts():
        assert nft.ownerOf(0)


def test_total_supply(nft, owner):
    assert nft.totalSupply() == 0
    nft.mint(owner, sender=owner)
    assert nft.totalSupply() == 1


def test_transfer(nft, owner, receiver):
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 0
    nft.mint(owner, sender=owner)
    assert nft.balanceOf(owner) == 1
    assert nft.ownerOf(1) == owner.address
    nft.transferFrom(owner, receiver, 1, sender=owner)
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 1
    assert nft.ownerOf(1) == receiver.address
    nft.transferFrom(receiver, owner, 1, sender=receiver)
    assert nft.balanceOf(receiver) == 0
    assert nft.balanceOf(owner) == 1
    assert nft.ownerOf(1) == owner.address


def test_incorrect_signer_transfer(nft, owner, receiver):
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 0
    nft.mint(owner, sender=owner)
    with ape.reverts():
        nft.transferFrom(owner, receiver, 1, sender=receiver)

    assert nft.balanceOf(receiver) == 0
    assert nft.balanceOf(owner) == 1
    assert nft.ownerOf(1) == owner.address


def test_incorrect_signer_minter(nft, owner, receiver):
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 0

    with ape.reverts():
        nft.mint(owner, sender=receiver)

    assert not nft.isMinter(receiver)
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 0


def test_approve_transfer(nft, owner, receiver):
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 0
    nft.mint(owner, sender=owner)
    assert nft.balanceOf(receiver) == 0
    assert nft.balanceOf(owner) == 1
    assert nft.ownerOf(1) == owner.address

    with ape.reverts():
        nft.approve(receiver, 1, sender=receiver)
        nft.transferFrom(owner, receiver, 1, sender=receiver)
    assert nft.balanceOf(receiver) == 0
    assert nft.balanceOf(owner) == 1
    assert nft.ownerOf(1) == owner.address

    nft.approve(receiver, 1, sender=owner)
    assert nft.getApproved(1) == receiver
    nft.transferFrom(owner, receiver, 1, sender=receiver)
    assert nft.balanceOf(receiver) == 1
    assert nft.balanceOf(owner) == 0
    assert nft.ownerOf(1) == receiver.address


def test_uri(nft, owner):

    assert nft.baseURI() == "ipfs://QmfBhQ7jk64f852pwYsj5RKZp68ntX1LqGod98MZQxbwrv"
    nft.mint(owner, sender=owner)
    assert nft.tokenURI(1) == "ipfs://QmfBhQ7jk64f852pwYsj5RKZp68ntX1LqGod98MZQxbwrv/1"

    nft.setBaseURI("new base uri", sender=owner)
    assert nft.baseURI() == "new base uri"
    assert nft.tokenURI(1) == "new base uri/1"
