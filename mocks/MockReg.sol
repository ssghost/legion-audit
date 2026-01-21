// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract MockRegistry {
    fallback() external payable {
        assembly {
            mstore(0, 1) 
            return(0, 32) 
        }
    }
}