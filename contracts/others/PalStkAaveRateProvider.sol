//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝
                                               

pragma solidity 0.8.10;
//SPDX-License-Identifier: MIT

// SEB: Interface matches the Interface defined by Balancer Labs here
//      https://github.com/balancer-labs/metastable-rate-providers/blob/master/contracts/interfaces/IRateProvider.sol
//      function name ist the same
//      visibility is the same
//      return type is the same
interface IRateProvider {
    function getRate() external view returns (uint256);
}

// PalPool Minimal Interface
interface IPalPool {

    // SEB: This function returns the same type as the IstETH does here
    //      https://github.com/balancer-labs/metastable-rate-providers/blob/master/contracts/interfaces/IwstETH.sol
    //      caution: I have not reviewed that `exchangeRateStored` returns the exchangeRate for 1 stkAave
    //      and not something else or a different unit.
    function exchangeRateStored() external view returns(uint);
    function exchangeRateCurrent() external returns(uint);

}

// Paladin Controller Minimal Interface
interface IPaladinController {
    
    function palTokenToPalPool(address palToken) external view returns(address);
}

/** @title RateProvider for palStkAave (used in Balancer's Metastable Pools) */
/// @author Paladin
contract PalStkAaveRateProvider is IRateProvider {

    /** @dev 1e18 mantissa used for calculations */
    uint256 internal constant MANTISSA_SCALE = 1e18;

    IPalPool public immutable palStkAavePool;

    constructor(IPalPool _palStkAavePool) {
        palStkAavePool = _palStkAavePool;
    }

    /**
     * @return the value of palStkAAVE in terms of stkAAVE (where 1 stkAAVE redeems 1 AAVE in the Aave Safety Module)
     *  !!! Uses the last stored exchange rate, not one calculated based on current block
     */
    function getRate() external view override returns (uint256) {
        uint256 exchangeRate = palStkAavePool.exchangeRateStored();
        
        // SEB: I understand they use the mantissa_scale for their own calculations
        //      I am not sure what implications this operation has within the EVM
        //      But why not leave it out and just return exchangeRate
        return (1e18 * exchangeRate) / MANTISSA_SCALE;
    }

}
