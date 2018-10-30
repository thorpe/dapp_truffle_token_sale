pragma solidity ^0.4.0;

import "zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

/**
 * @title ExampleCrowdsale
 * @dev Minted refundable crowdsale with min and max cap, min purchase, pre-sale and sale time and rate
 */
contract ExampleCrowdSale is CappedCrowdsale, RefundableCrowdsale, MintedCrowdsale {
    using SafeMath for uint256;

    uint256 public preSaleRate;
    uint256 public saleRate;
    uint256 public finalRate;

    uint256 public preSaleTime;
    uint256 public saleTime;

    uint256 public minPurchase;

    function ExampleCrowdsale
    (
        uint256 _openingTime,
        uint256 _preSaleTime,
        uint256 _saleTime,
        uint256 _closingTime,
        uint256 _preSaleRate,
        uint256 _saleRate,
        uint256 _finalRate,
        uint256 _minPurchase,
        uint256 _cap,
        uint256 _goal,
        address _wallet,
        MintableToken _token
    )
    public
    Crowdsale(_finalRate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableCrowdsale(_goal)
    {
        require(_goal <= _cap);

        require(_minPurchase > 0);
        minPurchase = _minPurchase;

        require(_preSaleRate >= _saleRate);
        require(_saleRate >= _finalRate);
        require(_finalRate > 0);
        preSaleRate = _preSaleRate;
        saleRate = _saleRate;
        finalRate = _finalRate;

        require(_preSaleTime >= _openingTime);
        require(_saleTime >= _preSaleTime);
        require(_closingTime >= _saleTime);
        preSaleTime = _preSaleTime;
        saleTime = _saleTime;
    }

    /**
     * @dev Income value should be greater than min purchase
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(_weiAmount >= minPurchase);
    }

    /**
     * @dev Returns the rate of tokens per wei at the present time.
     * Note that, as price _increases_ with time, the rate _decreases_.
     * @return The number of tokens a buyer gets per wei at a given time
     */
    function getCurrentRate() public view returns (uint256) {
        if (block.timestamp <= preSaleTime){
            return preSaleRate;
        }
        if (block.timestamp <= saleTime){
            return saleRate;
        }

        return finalRate;
    }

    /**
     * @dev Overrides parent method taking into account variable rate.
     * @param _weiAmount The value in wei to be converted into tokens
     * @return The number of tokens _weiAmount wei will buy at present time
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return currentRate.mul(_weiAmount);
    }
}