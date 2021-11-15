//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                     

pragma solidity ^0.7.6;
//SPDX-License-Identifier: MIT

import "./utils/Admin.sol";
import "./utils/Errors.sol";

/** @title Paladin Controller contract  */
/// @author Paladin
contract ControllerProxy is Admin {

    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    event NewImplementation(address oldImplementation, address newImplementation);

    /** @notice Implementation currently used through delegatecalls */
    address public currentIplementation;
    /** @notice Proposed future Implementation */
    address public pendingImplementation;

    constructor(){
        admin = msg.sender;
    }

    /**
     * @dev Proposes the address of a new Implementation (the new Controller contract)
     */
    function proposeImplementation(address newPendingImplementation) public adminOnly {

        address oldPendingImplementation = pendingImplementation;

        pendingImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, newPendingImplementation);
    }

    /**
     * @dev Accpets the Pending Implementation as new Current Implementation
     * Only callable by the Pending Implementation contract
     */
    function acceptImplementation() public returns(bool) {
        require(msg.sender == pendingImplementation || pendingImplementation == address(0), Errors.CALLER_NOT_IMPLEMENTATION);

        address oldImplementation = currentIplementation;
        address oldPendingImplementation = pendingImplementation;

        currentIplementation = pendingImplementation;
        pendingImplementation = address(0);

        emit NewImplementation(oldImplementation, currentIplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingImplementation);

        return true;
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback() external payable {
        // delegate all other functions to current implementation
        (bool success, ) = currentIplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize())

              switch success
              case 0 { revert(free_mem_ptr, returndatasize()) }
              default { return(free_mem_ptr, returndatasize()) }
        }
    }

}