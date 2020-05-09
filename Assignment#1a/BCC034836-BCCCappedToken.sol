pragma solidity ^0.6.0;
//0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
import "./IERC20.sol";
import "./SafeMath.sol";
// SafeMath library will allow to use arthemtic operation on Uint256
contract PIAICBCCToken is IERC20{
    //Extending Uint256 with SafeMath Library.
    using SafeMath for uint256;
    
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
   
   uint private _cappedLimit; 
   
    constructor () public {
        name = "Haris Token";
        symbol = "SHBH";
        decimals = 2;
        owner = msg.sender;
        //1 million tokens to be generated
        //1 * (10**18)  = 1;
        
        _totalSupply = 100000000 * (10 ** uint256(decimals));
        _cappedLimit = 200000000 * (10 ** uint256(decimals));
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }
     
     
    /**
     * @dev See {IERC20-totalSupply}.
     */
     
    
     
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function limitTotalSupply(uint256 amount)public returns (bool){
        require(owner==msg.sender, "Only owner can change the Capped Limit");
        require(amount>_totalSupply, "Capped limit cannot be less than current total supply");
        _cappedLimit=amount;
        
        
        return true;
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
     
    function transfer(address recipient, uint256 amount) public virtual  override returns (bool) {
        address sender = msg.sender;
        require(sender != address(0), "BCC1: transfer from the zero address");
        require(recipient != address(0), "BCC1: transfer to the zero address");
        require(_balances[sender] > amount,"BCC1: transfer amount exceeds balance");

        //decrease the balance of token sender account
        _balances[sender] = _balances[sender].sub(amount);
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address tokenOwner, address spender) public view virtual  override returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     * msg.sender: TokenOwner;
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override  returns (bool) {
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
    function transferFrom(address tokenOwner, address recipient, uint256 amount) public  virtual override returns (bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[tokenOwner][spender];
        require(_allowance > amount, "BCC1: transfer amount exceeds allowance");
        
        //deducting allowance
        _allowance = _allowance.sub(amount);
        
        //--- start transfer execution -- 
        
        //owner decrease balance
        _balances[tokenOwner] =_balances[tokenOwner].sub(amount); 
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(tokenOwner, recipient, amount);
        //-- end transfer execution--
        
        //decrease the approval amount;
        _allowances[tokenOwner][spender] = _allowance;
        
        emit Approval(tokenOwner, spender, amount);
        
        return true;
    }
     /**
     * This function will allow owner to Mint more tokens.
     * 
     * Requirements:
     * - the caller must have Owner of Contract
     * - amount should be valid incremental value.
     */
    function mint(uint256 amount) public onlyOwner returns(uint256){
        require((_balances[owner]+amount) < _cappedLimit, ("Total Supply of token cannot exceed from Capped Limit"));
        require(amount > 0,"BCC1: Invalid Amount. Minted amount should be greater than 0");
        _totalSupply = _totalSupply+amount;

    }
    
    
   
    modifier onlyOwner(){
        require(msg.sender == owner,"BCC1: Only owner can execute this feature");
        _;
    }
}
