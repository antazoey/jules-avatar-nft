# @version 0.3.6

from vyper.interfaces import ERC165
from vyper.interfaces import ERC721

implements: ERC165
implements: ERC721

SUPPORTED_INTERFACES: constant(bytes4[3]) = [
    0x01ffc9a7,  # ERC165 interface ID of ERC165
    0x80ac58cd,  # ERC165 interface ID of ERC721
    0x5b5e139f,  # ERC165 interface ID of ERC721 Metadata Extension
]

interface ERC721Receiver:
    def onERC721Received(
            operator: address,
            owner: address,
            tokenId: uint256,
            data: Bytes[1024]
        ) -> bytes4: view

interface ERC721Metadata:
	def name() -> String[64]: view

	def symbol() -> String[32]: view

	def tokenURI(
		_tokenId: uint256
	) -> String[128]: view

interface ERC721Enumerable:
	def totalSupply() -> uint256: view

	def tokenByIndex(
		_index: uint256
	) -> uint256: view

	def tokenOfOwnerByIndex(
		_address: address,
		_index: uint256
	) -> uint256: view


event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    tokenId: indexed(uint256)


event Approval:
    owner: indexed(address)
    approved: indexed(address)
    tokenId: indexed(uint256)


event ApprovalForAll:
    owner: indexed(address)
    operator: indexed(address)
    approved: bool

TOTAL_SUPPLY: constant(uint256) = 1
owner: public(address)
idToOwner: public(HashMap[uint256, address])
balanceOf: public(HashMap[address, uint256])
isApprovedForAll: public(HashMap[address, HashMap[address, bool]])
idToApprovals: public(HashMap[uint256, address])

# ERC20 Token Metadata
NAME: constant(String[20]) = "Jules Avatar"
SYMBOL: constant(String[5]) = "JULES"
baseURI: public(String[100])


@external
def __init__():
    # The owner (me) gets the 1 and only NFT
    self.owner = msg.sender
    self.baseURI = "ipfs://QmbYVQXcibEoRrdGrF1zh9i1mkXVB3vtPzLA9BFYicKuGc"
    self.idToOwner[0] = msg.sender
    self.balanceOf[msg.sender] = 1


@pure
@external
def name() -> String[40]:
    return NAME


@pure
@external
def symbol() -> String[5]:
    return SYMBOL
    
@pure
@external
def totalSupply() -> uint256:
    return TOTAL_SUPPLY


@view
@external
def tokenURI(tokenId: uint256) -> String[184]:
    return concat(self.baseURI, "/", uint2str(tokenId), ".json")


@external
def setBaseURI(_baseURI: String[100]):
    assert msg.sender == self.owner
    self.baseURI = _baseURI


@pure
@external
def supportsInterface(interface_id: bytes4) -> bool:
    """
    @dev Interface identification is specified in ERC-165.
    @param interface_id Id of the interface
    """
    return interface_id in SUPPORTED_INTERFACES


@view
@external
def ownerOf(tokenId: uint256) -> address:
    """
    @dev Returns the address of the owner of the NFT.
         Throws if `tokenId` is not a valid NFT.
    @param tokenId The identifier for an NFT.
    """
    owner: address = self.idToOwner[tokenId]
    # Throws if `tokenId` is not a valid NFT
    assert owner != empty(address)
    return owner


@view
@external
def getApproved(tokenId: uint256) -> address:
    """
    @dev Get the approved address for a single NFT.
         Throws if `tokenId` is not a valid NFT.
    @param tokenId ID of the NFT to query the approval of.
    """
    # Throws if `tokenId` is not a valid NFT
    assert self.idToOwner[tokenId] != empty(address)
    return self.idToApprovals[tokenId]


@external
def transferFrom(owner: address, receiver: address, tokenId: uint256):
    """
    @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
         address for this NFT.
         Throws if `owner` is not the current owner.
         Throws if `receiver` is the zero address.
         Throws if `tokenId` is not a valid NFT.
    @notice The caller is responsible to confirm that `receiver` is capable of receiving NFTs or else
            they maybe be permanently lost.
    @param owner The current owner of the NFT.
    @param receiver The new owner.
    @param tokenId The NFT to transfer.
    """
    self._transferFrom(owner, receiver, tokenId, msg.sender)


@internal
def _transferFrom(owner: address, receiver: address, tokenId: uint256, sender: address):
    """
    @dev Execute transfer of a NFT.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
         address for this NFT. (NOTE: `msg.sender` not allowed in private function so pass `_sender`.)
         address for thisassert self.idToOwner[tokenId] == owner NFT. (NOTE: `msg.sender` not allowed in private function so pass `_sender`.)
         Throws if `receiver` is the zero address.
         Throws if `owner` is not the current owner.
         Throws if `tokenId` is not a valid NFT.
    """
    # Check requirements
    assert self._isApprovedOrOwner(sender, tokenId)
    assert receiver != empty(address)
    assert owner != empty(address)
    assert self.idToOwner[tokenId] == owner

    # Reset approvals, if any
    if self.idToApprovals[tokenId] != empty(address):
        self.idToApprovals[tokenId] = empty(address)

    # Change the owner
    self.idToOwner[tokenId] = receiver

    # Change count tracking
    self.balanceOf[owner] -= 1
    self.balanceOf[receiver] += 1

    # Log the transfer
    log Transfer(owner, receiver, tokenId)


@view
@internal
def _isApprovedOrOwner(spender: address, tokenId: uint256) -> bool:
    """
    @dev Returns whether the given spender can transfer a given token ID
    @param spender address of the spender to query
    @param tokenId uint256 ID of the token to be transferred
    @return bool whether the msg.sender is approved for the given token ID,
        is an operator of the owner, or is the owner of the token
    """
    owner: address = self.idToOwner[tokenId]

    if owner == spender:
        return True

    if spender == self.idToApprovals[tokenId]:
        return True

    if (self.isApprovedForAll[owner])[spender]:
        return True

    return False


@external
def safeTransferFrom(
        owner: address,
        receiver: address,
        tokenId: uint256,
        data: Bytes[1024]=b""
    ):
    """
    @dev Transfers the ownership of an NFT from one address to another address.
         Throws unless `msg.sender` is the current owner, an authorized operator, or the
         approved address for this NFT.
         Throws if `owner` is not the current owner.
         Throws if `receiver` is the zero address.
         Throws if `tokenId` is not a valid NFT.
         If `receiver` is a smart contract, it calls `onERC721Received` on `receiver` and throws if
         the return value is not `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
         NOTE: bytes4 is represented by bytes32 with padding
    @param owner The current owner of the NFT.
    @param receiver The new owner.
    @param tokenId The NFT to transfer.
    @param data Additional data with no specified format, sent in call to `receiver`.
    """
    self._transferFrom(owner, receiver, tokenId, msg.sender)
    if receiver.is_contract: # check if `receiver` is a contract address
        returnValue: bytes4 = ERC721Receiver(receiver).onERC721Received(msg.sender, owner, tokenId, data)
        # Throws if transfer destination is a contract which does not implement 'onERC721Received'
        assert returnValue == method_id("onERC721Received(address,address,uint256,bytes)", output_type=bytes4)


@external
def approve(operator: address, tokenId: uint256):
    """
    @dev Set or reaffirm the approved address for an NFT. The zero address indicates there is no approved address.
         Throws unless `msg.sender` is the current NFT owner, or an authorized operator of the current owner.
         Throws if `tokenId` is not a valid NFT. (NOTE: This is not written the EIP)
         Throws if `operator` is the current owner. (NOTE: This is not written the EIP)
    @param operator Address to be approved for the given NFT ID.
    @param tokenId ID of the token to be approved.
    """
    # Throws if `tokenId` is not a valid NFT
    owner: address = self.idToOwner[tokenId]
    assert owner != empty(address)

    # Throws if `operator` is the current owner
    assert operator != owner

    # Throws if `msg.sender` is not the current owner, or is approved for all actions
    assert owner == msg.sender or (self.isApprovedForAll[owner])[msg.sender]

    self.idToApprovals[tokenId] = operator
    log Approval(owner, operator, tokenId)

@external
def setApprovalForAll(operator: address, approved: bool):
    """
    @dev Enables or disables approval for a third party ("operator") to manage all of
         `msg.sender`'s assets. It also emits the ApprovalForAll event.
    @notice This works even if sender doesn't own any tokens at the time.
    @param operator Address to add to the set of authorized operators.
    @param approved True if the operators is approved, false to revoke approval.
    """
    self.isApprovedForAll[msg.sender][operator] = approved
    log ApprovalForAll(msg.sender, operator, approved)
