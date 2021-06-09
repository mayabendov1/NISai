pragma solidity ^0.5.16; /* maybe need to change to 0.4.18*/

contract NISai{
    
    int convertRate;
    contract_address
    DaiStablecoin dai_contract = DaiStablecoin(_daiToken); 
    
    address private constant _daiToken = 0x6b175474e89094c44da98b954eedeac495271d0f;

    // --- ERC20 Data ---
    string  public constant name     = "NISai Stablecoin";
    string  public constant symbol   = "NISAI";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint totalSupply_;

    mapping (address => uint)                      public balances;
    mapping (address => uint)                      public daiCashed;
    mapping (address => mapping (address => uint)) public allowed;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    
    // --- ERC20 Functions ---
    function totalSupply() public view returns (uint) {
        return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint){
        return balances[tokenOwner];
    }
    
    function allowance(address tokenOwner, address spender) public view returns (uint){
        return allowed[tokenOwner][spender];
    }

    // --- Math ---
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

    constructor(uint total) public {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
    }

    // --- Token ---
    function transfer(address receiver,
                     uint numTokens) public returns (bool) {
      require(numTokens <= balances[msg.sender]);
      balances[msg.sender] = sub(balances[msg.sender], numTokens);
      balances[receiver] = add(balances[receiver], numTokens);
      emit Transfer(msg.sender, receiver, numTokens);
      return true;
    }
    
    function transferFrom(address owner, address buyer,
                     uint numTokens) public returns (bool) {
      require(numTokens <= balances[owner]);
      require(numTokens <= allowed[owner][msg.sender]);
      balances[owner] = sub(balances[owner], numTokens);
      allowed[owner][msg.sender] = sub(
            allowed[owner][msg.sender], numTokens);
      balances[buyer] = add(balances[buyer], numTokens);
      emit Transfer(owner, buyer, numTokens);
      return true;
    }

    function approve(address delegate,
                    uint numTokens) public returns (bool) {
      allowed[msg.sender][delegate] = numTokens;
      emit Approval(msg.sender, delegate, numTokens);
      return true;
    }
    
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply_ = add(totalSupply_, amount);
        balances[account] = add(balances[account], amount);
        
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        balances[account] = sub(balances[account], amount);
        totalSupply_ = sub(totalSupply_, amount);
    }
    
    function buy(address owner, uint amount) public returns (bool){
        int convertedAmount = amount*convertRate/(1.66);
        Dai.transfer(owner, address(this), amount); //add check here
        daiCashed[owner] += amount;
        _mint(owner, convertedAmount);
    }
    
    function sell(address owner, uint amount) public returns (bool){
        int convertedAmount = amount/(convertRate)*1.66;
        if (daiCashed[owner] >= convertedAmount){
            Dai.transfer(address(this), owner, convertedAmount);
            daiCashed[owner] -= convertedAmount;
            _burn(owner, amount);
        }
    }
}