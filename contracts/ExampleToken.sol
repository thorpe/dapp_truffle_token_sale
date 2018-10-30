pragma solidity ^0.4.0;


import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "zeppelin-solidity/contracts/ownership/CanReclaimToken.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

/**
 * @title ExampleToken
 * @dev Burnable pausable mintable token with reclaim function and whtelisted owners
 */
contract ExampleToken is Whitelist, CanReclaimToken, BurnableToken, PausableToken, MintableToken {

    string public name = "EXAMPLE COIN";
    string public symbol = "EEC";
    uint8 public decimals = 18;

    /**
     * @dev Burn only when token is not paused
     */
    function burn(uint256 _value) whenNotPaused public {
        super.burn(_value);
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyWhitelisted canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyWhitelisted canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyWhitelisted whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyWhitelisted whenPaused public {
        paused = false;
        Unpause();
    }

    /**
     * @dev Reclaim all ERC20Basic compatible tokens
     * @param token ERC20Basic The address of the token contract
     */
    function reclaimToken(ERC20Basic token) external onlyWhitelisted {
        uint256 balance = token.balanceOf(this);
        token.safeTransfer(owner, balance);
    }
}