pragma solidity ^0.6.0;
//0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
import "./IERC20.sol";
/*
owner address 
0xc021089463b2e8d35723CD0A86C69993A635BFC7
Spender Address 
0x5171314d1d9f4CF7E1a0a26248dEF372CB05e8f2
Recipient Address 
0x136ca875724d121c2518C5269CB14fD695549299
*/

contract PIAICBCCToken is IERC20{

    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    //mapping to hold approved allowance of token to certain address
    //       Owner               Spender    allowance
    mapping (address => mapping (address => uint256)) private _allowances;

    //the amount of tokens in existence
    uint256 private _totalSupply;

    //owner
    address public owner;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public tokenPrice;
    
    constructor () public {
        name = "Haris Token";
        symbol = "SHBH";
        decimals = 17;
        owner = msg.sender;
        tokenPrice = 2;
        //1 million tokens to be generated
        //1 * (10**18)  = 1;
        
        _totalSupply = 100000000 * (10 ** uint256(decimals));
        
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }
     
     function displayContractAddress() public view returns(address){
         return address(this);
     }
     
     function withDrawAmount() public {
         require(owner == msg.sender, "Only owner can withdraw the amount");
        msg.sender.transfer(address(this).balance);
    }

    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }
    
    function isContract(address account) public view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
     
     function buyTokens() public payable returns(bool){
         require(!isContract(msg.sender),"The account should be EOA");
         require(owner != msg.sender, "It is an owner account");
         require(msg.value > 0, "amount should be greater than 1 wei");
         transfer(msg.sender, msg.value*tokenPrice);
         return true;
     }
     
     function adjustPrice(uint256 amount) public returns(bool){
         require(owner == msg.sender, "Only owner can change the price");
         tokenPrice=amount;
         return true;
     }
     
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        address sender = owner;
        require(sender != address(0), "BCC1: transfer from the zero address");
        require(recipient != address(0), "BCC1: transfer to the zero address");
        require(_balances[sender] > amount,"BCC1: transfer amount exceeds balance");

        //decrease the balance of token sender account
        _balances[sender] = _balances[sender] - amount;
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     * msg.sender: TokenOwner;
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address tokenOwner = msg.sender;
        require(tokenOwner != address(0), "BCC1: approve from the zero address");
        require(spender != address(0), "BCC1: approve to the zero address");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     * msg.sender: Spender
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address tokenOwner, address recipient, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[tokenOwner][spender];
        require(_allowance > amount, "BCC1: transfer amount exceeds allowance");
        
        //deducting allowance
        _allowance = _allowance - amount;
        
        //--- start transfer execution -- 
        
        //owner decrease balance
        _balances[tokenOwner] =_balances[tokenOwner] - amount; 
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(tokenOwner, recipient, amount);
        //-- end transfer execution--
        
        //decrease the approval amount;
        _allowances[tokenOwner][spender] = _allowance;
        
        emit Approval(tokenOwner, spender, amount);
        
        return true;
    }
    

}