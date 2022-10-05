import ape


def test_erc165(nft):
    assert nft.supportsInterface("0x01ffc9a7")
    assert not nft.supportsInterface("0xffffffff")
    assert nft.supportsInterface("0x80ac58cd")
    assert nft.supportsInterface("0x5b5e139f")


def test_owner(nft, owner):
    assert nft.owner() == owner


def test_balance_of(nft, owner):
    assert nft.balanceOf(owner) == 1


def test_owner_of(nft, owner):
    assert nft.ownerOf(0) == owner


def test_total_supply(nft):
    assert nft.totalSupply() == 1


def test_transfer_from(nft, owner, receiver):
    nft.transferFrom(owner, receiver, 0, sender=owner)
    assert nft.balanceOf(owner) == 0
    assert nft.balanceOf(receiver) == 1
    assert nft.ownerOf(0) == receiver.address

    # Undo
    nft.transferFrom(receiver, owner, 0, sender=receiver)
    assert nft.balanceOf(receiver) == 0
    assert nft.balanceOf(owner) == 1
    assert nft.ownerOf(0) == owner.address


def test_transfer_from_bad_id(nft, owner, receiver):
    with ape.reverts():
        nft.transferFrom(owner, receiver, 1, sender=owner)


def test_transfer_from_not_owner(nft, owner, receiver):
    with ape.reverts():
        nft.transferFrom(owner, receiver, 1, sender=receiver)


def test_approve(nft, owner, receiver):
    nft.approve(receiver, 0, sender=owner)
    assert nft.getApproved(0) == receiver
    nft.transferFrom(owner, receiver, 0, sender=receiver)
    assert nft.balanceOf(receiver) == 1
    assert nft.balanceOf(owner) == 0
    assert nft.ownerOf(0) == receiver


def test_approve_not_owner(nft, receiver):
    with ape.reverts():
        nft.approve(receiver, 0, sender=receiver)


def test_approve_bad_id(nft, owner, receiver):
    with ape.reverts():
        nft.approve(receiver, 1, sender=owner)
