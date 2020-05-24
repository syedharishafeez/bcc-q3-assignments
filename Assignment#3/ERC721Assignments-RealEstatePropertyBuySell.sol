pragma solidity ^0.6.0;


contract ERC721token{
    
    mapping (address =>uint256[]) ownerTokens;
    mapping (address =>mapping(uint256=>uint256)) ownerTokenIndex;
    mapping(uint256 =>address ) public tokenOwners;
    mapping(uint256=>address) tokenApproval;
    mapping(uint256=>string) public tokenURI;
    mapping(address=>mapping(address=>bool)) operatorApproval;
    
    mapping(uint256=>uint256) requestedTokenPrice;
    mapping(uint256=>address) requestedTokenAddress;
    
    mapping(uint256=>bool) propertiesForSale;
    mapping(uint256=>uint256) baseValue;
    
    uint256 token;
    mapping(uint256=>bool) public existingTokens;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
     
    constructor() public{
        token = 0;
    }
     
    function registerProperty(string memory propertyURI) public{
        token = token+1;
        existingTokens[token] = true;
        ownerTokens[msg.sender].push(token);
        ownerTokenIndex[msg.sender][token] = ownerTokens[msg.sender].length - 1;
        tokenOwners[token] = msg.sender;
        tokenURI[token] = propertyURI;
    }
    
    function setPropertiesForSale(uint tokenId)public{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(msg.sender == tokenOwners[tokenId], "You are not authorize to sale this property");
        require(baseValue[tokenId] != 0, "Firstly set base value of this property");
        require(propertiesForSale[tokenId] != true, "This property is already in sale list");
        propertiesForSale[tokenId]=true;
    }
    
    function myTokens()public view returns(uint256[] memory){
        return ownerTokens[msg.sender];
    }
    
    function setBaseValue(uint256 tokenId, uint256 price)public{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(tokenOwners[tokenId] != address(0),"Address of tokenID is not valid");
        require(tokenOwners[tokenId] == msg.sender,"Only owner of this token can accept the offer");
        baseValue[tokenId] = price;
    }
    
    function balanceOf(address owner) external view returns (uint256 balance){
        return ownerTokens[msg.sender].length;
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    // function ownerOf(uint256 tokenId) external view returns (address owner){
    //     return tokenOwners[tokenId];
    // }

    // function listPropertyForSale() view public returns(uint256[] memory){
    //     return propertiesForSale;
    // }
    
    function buyingRequest(uint256 tokenId) public payable{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(propertiesForSale[tokenId]==true,"This property is not for sale");
        require(msg.sender != tokenOwners[tokenId],"You are already owner of this token");
        require(msg.value>baseValue[tokenId],"offering value should be greater than base value");
        requestedTokenPrice[tokenId]=msg.value;
        requestedTokenAddress[tokenId]=msg.sender;
    }
    
    function checkBuyingRequestPrice(uint tokenId)public view returns(uint256){
        return requestedTokenPrice[tokenId];
    }
    
    function checkBuyingRequestAddress(uint tokenId)public view returns(address){
        return requestedTokenAddress[tokenId];
    }
    
    function OfferReject(uint256 tokenId) public{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(tokenOwners[tokenId] == msg.sender,"Only owner of this token can reject the offer");
        payable(requestedTokenAddress[tokenId]).transfer(requestedTokenPrice[tokenId]);
        delete requestedTokenPrice[tokenId];
        delete requestedTokenAddress[tokenId];
    }
    
    
    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from`, `to` cannot be zero.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    // function safeTransferFrom(address from, address to, uint256 tokenId) external{
        
    // }

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from`, `to` cannot be zero.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address owner, address to, uint256 tokenId)  internal{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(owner != address(0),"Invalid Address");
        require(to != address(0),"Invalid Address");
        require(tokenOwners[tokenId] == owner,"Only owner of this token can transfer it");
        tokenOwners[tokenId] = to;
        ownerTokens[to].push(tokenId);
        ownerTokens[owner][ownerTokenIndex[owner][tokenId]] = ownerTokens[owner][ownerTokens[owner].length - 1];
        delete ownerTokens[owner][ownerTokens[owner].length - 1];
        ownerTokenIndex[to][tokenId] = ownerTokens[to].length - 1;
        delete ownerTokenIndex[owner][tokenId];
    }
    
    function OfferAccept(uint256 tokenId)public{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(tokenOwners[tokenId] == msg.sender,"Only owner of this token can accept the offer");
        transferFrom(msg.sender,requestedTokenAddress[tokenId],tokenId);
        propertiesForSale[tokenId]=false;
    }
    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId)  external{
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(tokenOwners[tokenId] == msg.sender,"You can not approve anyone for this token");
        tokenApproval[tokenId] = to;
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)  external returns (address operator){
        require(existingTokens[tokenId] == true, "Token doesn't exist");
        require(tokenOwners[tokenId] == address(0),"No operator assign");
        return tokenOwners[tokenId];
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved)  external{
        require(operator != msg.sender,"Owner cannot be the operator");
        operatorApproval[msg.sender][operator]=true;
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)  external view returns (bool){
        return operatorApproval[msg.sender][operator];
    }

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from`, `to` cannot be zero.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    // function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data)  external{
        
    // }
    
    
    // function supportsInterface(bytes4 interfaceId)  external view returns (bool){
        
    // }
}